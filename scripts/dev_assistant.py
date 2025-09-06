#!/usr/bin/env python3
"""AshTrail Development Assistant (Rebuilt)

Implements Priority 0 + 1 automation:
 status, features, health, test-coverage, upload-codecov, dev-cycle, full-check,
 cache-features, adr-index, session manifest logging.

See internal docstring in repository AI guide for usage patterns.
"""
from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
import time
from dataclasses import dataclass, asdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, List, Optional, Tuple, Any

import yaml  # type: ignore

ROOT = Path(__file__).resolve().parent.parent
FEATURE_MATRIX = ROOT / "feature_matrix.yaml"
COVERAGE_FILE = ROOT / "coverage" / "lcov.info"
CACHE_DIR = ROOT / "build"
FEATURE_CACHE = CACHE_DIR / "feature_matrix_cache.json"
SESSIONS_DIR = ROOT / "automation_sessions"
ADR_DIR = ROOT / "docs" / "adr"
ADR_INDEX = ADR_DIR / "ADR-000-index.md"

MIN_PROJECT_COV = float(os.environ.get("COVERAGE_MIN", "80"))

def run(cmd: List[str], timeout: int = 60, cwd: Path = ROOT) -> Tuple[bool, str]:
    try:
        proc = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, timeout=timeout, shell=True)
        return proc.returncode == 0, proc.stdout.strip() + ("\n" + proc.stderr.strip() if proc.stderr.strip() else "")
    except FileNotFoundError:
        return False, f"tool_not_found:{cmd[0]}"
    except subprocess.TimeoutExpired:
        return False, f"timeout:{' '.join(cmd)}"
    except Exception as e:  # pragma: no cover
        return False, f"error:{e}"

def parse_lcov(path: Path) -> Optional[Dict[str, Any]]:
    if not path.exists():
        return None
    lines_hit = 0
    lines_found = 0
    file_totals: List[Tuple[str, int, int]] = []
    current_file = None
    current_hit = 0
    current_total = 0
    try:
        for raw in path.read_text(encoding="utf-8", errors="ignore").splitlines():
            if raw.startswith("SF:"):
                if current_file:
                    file_totals.append((current_file, current_hit, current_total))
                current_file = raw[3:]
                current_hit = 0
                current_total = 0
            elif raw.startswith("DA:"):
                parts = raw[3:].split(",")
                if len(parts) == 2:
                    cnt = int(parts[1])
                    current_total += 1
                    if cnt > 0:
                        current_hit += 1
            elif raw.startswith("end_of_record"):
                if current_file:
                    file_totals.append((current_file, current_hit, current_total))
                    current_file = None
        if current_file:
            file_totals.append((current_file, current_hit, current_total))
        for _, h, t in file_totals:
            lines_hit += h
            lines_found += t
        line_cov = (lines_hit / lines_found * 100.0) if lines_found else 0.0
        return {
            "line_coverage": line_cov,
            "lines_hit": lines_hit,
            "lines_found": lines_found,
            "files": [
                {"file": f, "hit": h, "total": t, "pct": (h / t * 100.0) if t else 0.0}
                for f, h, t in sorted(file_totals, key=lambda x: x[0])
            ],
        }
    except Exception:  # pragma: no cover
        return None

def load_feature_matrix() -> Dict[str, Any]:
    if not FEATURE_MATRIX.exists():
        return {}
    with FEATURE_MATRIX.open("r", encoding="utf-8") as f:
        return yaml.safe_load(f) or {}

def collect_next_features(limit: int = 10) -> List[Dict[str, Any]]:
    data = load_feature_matrix()
    feats = data.get("features", []) or []
    remaining = [f for f in feats if f.get("status") in {"planned", "in_progress"}]
    priority_rank = {"P0": 0, "P1": 1, "P2": 2, "P3": 3}
    remaining.sort(key=lambda f: (priority_rank.get(f.get("priority", "P3"), 9), f.get("order", 999)))
    return remaining[:limit]

def health_check() -> Dict[str, Any]:
    skip = os.environ.get("DEV_ASSISTANT_SKIP_TOOL_CHECKS") == "1"
    results: Dict[str, Any] = {"flutter": False, "git": False, "codecov": False, "coverage": COVERAGE_FILE.exists(), "issues": []}
    if not skip:
        ok, _ = run(["flutter", "--version"], timeout=25)
        results["flutter"] = ok
        if not ok:
            results["issues"].append("flutter_missing")
        ok, _ = run(["git", "--version"], timeout=10)
        results["git"] = ok
        if not ok:
            results["issues"].append("git_missing")
        ok, _ = run(["codecov", "--version"], timeout=5)
        results["codecov"] = ok
    else:  # simplified optimistic values for test contexts
        results.update({"flutter": True, "git": True, "codecov": True})
    if not results["coverage"]:
        results["issues"].append("coverage_missing")
    fm = load_feature_matrix()
    if not fm.get("features"):
        results["issues"].append("feature_matrix_empty")
    return results

def regenerate_adr_index() -> Dict[str, Any]:
    ADR_DIR.mkdir(parents=True, exist_ok=True)
    entries = []
    for f in sorted(ADR_DIR.glob("ADR-*.md")):
        if f.name == ADR_INDEX.name:
            continue
        try:
            with f.open("r", encoding="utf-8") as fh:
                first = fh.readline().strip()
        except Exception:
            first = ""
        title = first.lstrip("# ") or f.name
        entries.append((f.name, title))
    lines = ["# Architecture Decision Records Index", "", "Generated: " + datetime.now(timezone.utc).isoformat(), ""]
    if not entries:
        lines.append("_No ADRs found._")
    else:
        for name, title in entries:
            lines.append(f"- [{title}](./{name})")
    ADR_INDEX.write_text("\n".join(lines) + "\n", encoding="utf-8")
    return {"count": len(entries), "index_path": str(ADR_INDEX.relative_to(ROOT))}

@dataclass
class SessionManifest:
    id: str
    started_at: str
    command: str
    coverage_before: Optional[float]
    coverage_after: Optional[float]
    coverage_delta: Optional[float]
    tests_passed: bool
    uploaded: bool
    notes: List[str]
    branch: Optional[str] = None
    commit: Optional[str] = None
    changed_files: Optional[List[Dict[str, Any]]] = None  # {path,type}
    file_coverage_deltas: Optional[List[Dict[str, Any]]] = None  # {file,before,after,delta}
    duration_ms: Optional[int] = None
    def to_json(self) -> str:
        return json.dumps(asdict(self), indent=2)

def write_session_manifest(manifest: SessionManifest) -> Path:
    SESSIONS_DIR.mkdir(exist_ok=True)
    path = SESSIONS_DIR / f"session_{manifest.id}.json"
    path.write_text(manifest.to_json(), encoding="utf-8")
    return path

def cmd_status(args) -> Dict[str, Any]:
    hc = health_check()
    fm = load_feature_matrix()
    statuses = {"planned":0, "in_progress":0, "done":0, "parked":0}
    for f in fm.get("features", []):
        s = f.get("status", "planned")
        statuses[s] = statuses.get(s,0)+1
    cov = parse_lcov(COVERAGE_FILE)
    b_ok, branch = run(["git", "branch", "--show-current"])
    c_ok, commits = run(["git", "rev-list", "--count", "HEAD"])
    return {"health": hc, "git": {"branch": branch if b_ok else "unknown", "commits": int(commits) if c_ok and commits.isdigit() else 0}, "features": statuses, "coverage": cov, "next_features": collect_next_features(5)}

def cmd_features(args) -> Dict[str, Any]:
    return {"next": collect_next_features(args.limit)}

def cmd_health(args) -> Dict[str, Any]:
    return health_check()

def ensure_tests_with_coverage(timeout: int = 900) -> Tuple[bool, str]:
    return run(["flutter", "test", "--coverage"], timeout=timeout)

def cmd_test_coverage(args) -> Dict[str, Any]:
    before = parse_lcov(COVERAGE_FILE)
    ok, out = ensure_tests_with_coverage()
    after = parse_lcov(COVERAGE_FILE)
    warn = None
    if after and after["line_coverage"] < MIN_PROJECT_COV:
        warn = f"coverage_below_min:{after['line_coverage']:.1f}%<{MIN_PROJECT_COV:.0f}%"  # type: ignore
    return {"tests_passed": ok, "coverage_before": before, "coverage_after": after, "warning": warn, "output_tail": out[-2000:] if out else ""}

def cmd_test_codecov(args) -> Dict[str, Any]:
    if not COVERAGE_FILE.exists():
        return {"error": "coverage_missing"}
    ok, ver = run(["codecov", "--version"], timeout=5)
    return {"codecov_cli": ok, "version": ver.split()[1] if ok and ver else None}

def cmd_upload_codecov(args) -> Dict[str, Any]:
    if not COVERAGE_FILE.exists():
        return {"error": "coverage_missing"}
    ok, out = run(["codecov", "-f", str(COVERAGE_FILE.relative_to(ROOT)), "-F", "flutter_tests"], timeout=120)
    return {"uploaded": ok, "output_tail": out[-4000:] if out else ""}

def _git_info() -> Tuple[Optional[str], Optional[str]]:
    b_ok, branch = run(["git", "branch", "--show-current"])
    c_ok, commit = run(["git", "rev-parse", "HEAD"], timeout=10)
    return (branch if b_ok else None, commit if c_ok else None)

def _changed_files() -> List[Dict[str, Any]]:
    files: List[Dict[str, Any]] = []
    # staged and unstaged diffs
    for cmd in (["git", "diff", "--name-status"], ["git", "diff", "--name-status", "--cached"]):
        ok, out = run(cmd)
        if not ok or not out:
            continue
        for line in out.splitlines():
            parts = line.split()  # e.g. 'A\tpath'
            if len(parts) >= 2:
                status, path = parts[0], parts[1]
                typ = {"A": "added", "M": "modified", "R": "renamed", "D": "deleted"}.get(status[0], "other")
                entry = {"path": path, "status": status, "type": typ}
                if entry not in files:
                    files.append(entry)
    return files

def _coverage_map(cov: Optional[Dict[str, Any]]) -> Dict[str, float]:
    if not cov:
        return {}
    mapping: Dict[str, float] = {}
    for f in cov.get("files", []) or []:
        if isinstance(f, dict):
            mapping[f.get("file", "")] = f.get("pct", 0.0)
    return mapping

def cmd_dev_cycle(args) -> Dict[str, Any]:
    start_ts = time.time()
    start_cov = parse_lcov(COVERAGE_FILE)
    if args.skip_tests:
        ok = True
    else:
        ok, _ = ensure_tests_with_coverage()
    end_cov = parse_lcov(COVERAGE_FILE)
    uploaded = False
    notes: List[str] = []
    if ok and args.upload and COVERAGE_FILE.exists() and not args.skip_tests:
        up = cmd_upload_codecov(args)
        uploaded = bool(up.get("uploaded"))
        if not uploaded:
            notes.append("upload_failed")
    if end_cov and end_cov.get("line_coverage") is not None and end_cov["line_coverage"] < MIN_PROJECT_COV:
        notes.append("coverage_below_target")
    branch, commit = _git_info()
    changed = _changed_files()
    before_map = _coverage_map(start_cov)
    after_map = _coverage_map(end_cov)
    file_deltas: List[Dict[str, Any]] = []
    for fpath, after_pct in after_map.items():
        before_pct = before_map.get(fpath)
        if before_pct is None or before_pct == after_pct:
            continue
        file_deltas.append({"file": fpath, "before": before_pct, "after": after_pct, "delta": after_pct - before_pct})
    manifest = SessionManifest(
        id=datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S"),
        started_at=datetime.now(timezone.utc).isoformat(),
        command="dev-cycle",
        coverage_before=start_cov["line_coverage"] if start_cov else None,
        coverage_after=end_cov["line_coverage"] if end_cov else None,
        coverage_delta=(end_cov["line_coverage"] - start_cov["line_coverage"]) if start_cov and end_cov else None,
        tests_passed=ok,
        uploaded=uploaded,
        notes=notes,
        branch=branch,
        commit=commit,
        changed_files=changed or None,
        file_coverage_deltas=file_deltas or None,
        duration_ms=int((time.time() - start_ts) * 1000),
    )
    path = write_session_manifest(manifest)
    return {"tests_passed": ok, "coverage": end_cov, "uploaded": uploaded, "manifest": str(path.relative_to(ROOT)), "notes": notes, "branch": branch, "commit": commit, "file_coverage_deltas": file_deltas}

def cmd_full_check(args) -> Dict[str, Any]:
    hc = health_check()
    cov = parse_lcov(COVERAGE_FILE)
    fm = load_feature_matrix()
    return {"health": hc, "coverage": cov, "feature_count": len(fm.get("features", []))}

def cmd_cache_features(args) -> Dict[str, Any]:
    data = load_feature_matrix()
    CACHE_DIR.mkdir(exist_ok=True)
    FEATURE_CACHE.write_text(json.dumps(data, indent=2), encoding="utf-8")
    return {"cached": True, "path": str(FEATURE_CACHE.relative_to(ROOT))}

def cmd_adr_index(args) -> Dict[str, Any]:
    return regenerate_adr_index()

COMMANDS = {
    "status": cmd_status,
    "features": cmd_features,
    "health": cmd_health,
    "test-coverage": cmd_test_coverage,
    "test-codecov": cmd_test_codecov,
    "upload-codecov": cmd_upload_codecov,
    "dev-cycle": cmd_dev_cycle,
    "full-check": cmd_full_check,
    "cache-features": cmd_cache_features,
    "adr-index": cmd_adr_index,
}

# ----------------------------- Feature Start Command -----------------------------
def _suggest_next_feature(order_mode: str = "matrix") -> Optional[Dict[str, Any]]:
    """Reuse detect_feature_status script suggestion to avoid duplicating logic."""
    script = ROOT / 'scripts' / 'detect_feature_status.py'
    if not script.exists():
        return None
    try:
        proc = subprocess.run([
            sys.executable,
            str(script),
            '--suggest-next',
            '--json',
            '--order-mode', order_mode
        ], cwd=ROOT, capture_output=True, text=True)
        if proc.returncode != 0:
            return None
        data = json.loads(proc.stdout.strip() or '{}')
        # detect_feature_status returns None (printed) when nothing; ensure feature_id key present
        if not isinstance(data, dict) or 'feature_id' not in data:
            return None
        return data
    except Exception:
        return None

def _fallback_next_feature() -> Optional[str]:
    """Fallback selection when detect_feature_status script not present or returns none.

    Strategy: choose first planned feature by priority (P0..P3) then order ascending.
    If none planned, choose first in_progress without scaffold folder present (resume) else None.
    """
    fm = load_feature_matrix()
    feats = fm.get('features', []) or []
    prio_rank = {"P0":0, "P1":1, "P2":2, "P3":3}
    planned = [f for f in feats if f.get('status') == 'planned']
    planned.sort(key=lambda f: (prio_rank.get(f.get('priority','P3'), 99), f.get('order', 9999)))
    if planned:
        return planned[0].get('id')
    # fallback to in_progress needing scaffold
    for f in sorted([f for f in feats if f.get('status') == 'in_progress'], key=lambda x: (prio_rank.get(x.get('priority','P3'),99), x.get('order',9999))):
        fid = f.get('id')
        if fid and not _feature_dir(fid).exists():
            return fid
    return None

def _feature_dir(feature_id: str) -> Path:
    snake = feature_id.split('.')[-1]
    return ROOT / 'lib' / 'features' / snake

def _scaffold_feature(feature_id: str, dry_run: bool) -> Dict[str, Any]:
    base = _feature_dir(feature_id)
    created: List[str] = []
    skipped: List[str] = []
    subdirs = ['domain', 'data', 'presentation']
    for sub in subdirs:
        path = base / sub
        if path.exists():
            skipped.append(str(path.relative_to(ROOT)))
        else:
            if not dry_run:
                path.mkdir(parents=True, exist_ok=True)
                (path / '.gitkeep').write_text('', encoding='utf-8')
            created.append(str(path.relative_to(ROOT)))
    # tests directory
    test_dir = ROOT / 'test' / 'features' / feature_id.split('.')[-1]
    if test_dir.exists():
        skipped.append(str(test_dir.relative_to(ROOT)))
    else:
        if not dry_run:
            test_dir.mkdir(parents=True, exist_ok=True)
            (test_dir / f"{feature_id.split('.')[-1]}_placeholder_test.dart").write_text(
                f"// Placeholder test for {feature_id}\nvoid main() {{}}\n", encoding='utf-8')
        created.append(str(test_dir.relative_to(ROOT)))
    return {"created": created, "skipped": skipped}

def _update_feature_matrix_status(feature_id: str, dry_run: bool) -> Tuple[bool, Optional[str], Optional[str]]:
    data = load_feature_matrix()
    feats = data.get('features') or []
    prev = None
    new = None
    for f in feats:
        if f.get('id') == feature_id:
            prev = f.get('status')
            if prev == 'planned':
                new = 'in_progress'
                if not dry_run:
                    f['status'] = new
            else:
                new = prev  # unchanged
            break
    if not dry_run and prev == 'planned':
        FEATURE_MATRIX.write_text(yaml.safe_dump(data, sort_keys=False), encoding='utf-8')
    return (prev is not None, prev, new)

def cmd_start_next_feature(args) -> Dict[str, Any]:  # original implementation retained then wrapped later
    # Determine target feature
    order_mode = getattr(args, 'order_mode', 'matrix')
    dry_run = getattr(args, 'dry_run', False)
    feature_id = getattr(args, 'feature_id', None)
    if feature_id:
        # ensure exists in matrix
        fm = load_feature_matrix()
        ids = {f.get('id') for f in fm.get('features', [])}
        if feature_id not in ids:
            return {"error": "feature_not_found", "feature_id": feature_id}
        suggestion = next((f for f in fm.get('features', []) if f.get('id') == feature_id), {})
    else:
        suggestion = _suggest_next_feature(order_mode=order_mode)
        if suggestion:
            feature_id = suggestion.get('feature_id')
        else:
            fallback_id = _fallback_next_feature()
            if not fallback_id:
                return {"error": "no_feature_available"}
            feature_id = fallback_id
    if not isinstance(feature_id, str):  # safety
        return {"error": "invalid_feature_id", "detail": str(feature_id)}
    scaffold = _scaffold_feature(str(feature_id), dry_run)
    updated, prev_status, new_status = _update_feature_matrix_status(str(feature_id), dry_run)
    return {
        "started_feature": feature_id,
        "dry_run": dry_run,
        "scaffold": scaffold,
        "status_prev": prev_status,
        "status_new": new_status,
        "matrix_updated": (prev_status == 'planned' and new_status == 'in_progress' and not dry_run),
        "order_mode": order_mode,
    }

# register command
COMMANDS["start-next-feature"] = cmd_start_next_feature

# ----------------------------- Feature Branch & AI Prompt Enhancements -----------------------------
# Added: automatic branch creation + AI assistant implementation prompt generation when starting a feature.
# Rationale: streamline dev workflow so invoking `start-next-feature` immediately prepares an isolated branch
# and rich context prompt for AI / developer to implement according to architectural guardrails.

def _current_branch() -> Optional[str]:
    ok, out = run(["git", "branch", "--show-current"], timeout=10)
    return out if ok and out else None

def _create_feature_branch(feature_id: str, dry_run: bool) -> Dict[str, Any]:
    """Create a git branch for the feature.

    Branch naming convention: feat/<feature_id_with_dots_replaced_by_underscores>
    (Using underscores avoids potential tooling issues with dots in branch refs.)
    If branch already exists, we do not switch if already on it; otherwise checkout it.
    """
    result: Dict[str, Any] = {"created": False, "branch": None, "base": None, "exists": False}
    base = _current_branch()
    result["base"] = base
    sanitized = feature_id.replace(" ", "_").replace("/", "_").replace("..", ".")
    branch = f"feat/{sanitized.replace('.', '_')}"
    result["branch"] = branch
    if dry_run:
        return result
    # Check if git is available
    ok_git, _ = run(["git", "--version"], timeout=5)
    if not ok_git:
        result["error"] = "git_not_available"
        return result
    # Does branch already exist?
    exists_ok, _ = run(["git", "rev-parse", "--verify", branch], timeout=10)
    if exists_ok:
        result["exists"] = True
        # checkout existing branch if not already on it
        if base != branch:
            co_ok, co_out = run(["git", "checkout", branch], timeout=20)
            if not co_ok:
                result["error"] = f"checkout_failed:{co_out[:120]}"
        return result
    # Create new branch
    create_ok, create_out = run(["git", "checkout", "-b", branch], timeout=30)
    if create_ok:
        result["created"] = True
    else:
        result["error"] = f"branch_create_failed:{create_out[:160]}"
    return result

def _generate_ai_prompt(feature_record: Dict[str, Any], feature_id: str, dry_run: bool) -> Dict[str, Any]:
    """Generate an AI assistant implementation prompt inside the feature folder.

    File path: lib/features/<snake>/AI_PROMPT.md
    Content includes: summary, rationale, acceptance, components, data/offline/telemetry/a11y/errors.
    """
    out: Dict[str, Any] = {"path": None}
    if not feature_record:
        out["error"] = "feature_record_missing"
        return out
    snake = feature_id.split('.')[-1]
    feature_dir = _feature_dir(feature_id)
    prompt_path = feature_dir / "AI_PROMPT.md"
    if dry_run:
        out["path"] = str(prompt_path.relative_to(ROOT))
        return out
    feature_dir.mkdir(parents=True, exist_ok=True)
    title = feature_record.get("title", feature_id)
    rationale = feature_record.get("rationale")
    acceptance = feature_record.get("acceptance") or []
    user_stories = feature_record.get("user_stories") or []
    components = feature_record.get("components") or []
    screens = feature_record.get("screens") or feature_record.get("screen") or []
    telemetry_events = feature_record.get("telemetry", {}).get("events", []) if isinstance(feature_record.get("telemetry"), dict) else []
    data_block = feature_record.get("data") or {}
    offline_block = feature_record.get("offline") or {}
    a11y = feature_record.get("a11y") or {}
    errors = feature_record.get("errors") or []
    perf_budget = feature_record.get("perf_budget") or {}

    def bullet(lines):
        return "\n".join(f"- {l}" for l in lines)

    content_lines: List[str] = [
        f"# Feature Implementation Prompt: {title} ({feature_id})",
        "",
        "This prompt is auto-generated by dev_assistant `start-next-feature` to guide AI / developer implementation.",
        "Do not remove architectural guardrails. Keep changes minimal, tested, and aligned with Clean Architecture.",
        "",
        "## Context", f"Epic: {feature_record.get('epic','unknown')}", f"Priority: {feature_record.get('priority','')}  Status: {feature_record.get('status','')}",
        "", "## Rationale", rationale or "(None provided)", "",
    ]
    if user_stories:
        content_lines += ["## User Stories", bullet(user_stories), ""]
    content_lines += ["## Acceptance Criteria", bullet(acceptance) if acceptance else "(None listed)", ""]
    if components:
        content_lines += ["## Components / Modules", bullet(components), ""]
    if screens:
        content_lines += ["## Screens", bullet(screens), ""]
    if telemetry_events:
        content_lines += ["## Telemetry Events", bullet(telemetry_events), ""]
    if perf_budget:
        content_lines += ["## Performance Budget (Target)"]
        for k,v in perf_budget.items():
            content_lines.append(f"- {k}: {v}")
        content_lines.append("")
    # Data / Offline
    if data_block:
        reads = data_block.get("reads") or []
        writes = data_block.get("writes") or []
        content_lines += ["## Data Access", "Reads:", bullet([str(r) for r in reads]) if reads else "- (none)", "Writes:", bullet([str(w) for w in writes]) if writes else "- (none)", ""]
    if offline_block:
        content_lines += ["## Offline", bullet([f"{k}: {v}" for k,v in offline_block.items()]), ""]
    if a11y:
        content_lines += ["## Accessibility", bullet([f"{k}: {v}" for k,v in a11y.items()]), ""]
    if errors:
        content_lines += ["## Error Codes", bullet([f"{e.get('code')}: {e.get('message')}" if isinstance(e, dict) else str(e) for e in errors]), ""]
    content_lines += [
    "## Output Contract (Reminders)",
    "The PR for this feature should include in order:",
    "1. Plan (goal, assumptions, acceptance)",
    "2. Files changed list (paths + purpose)",
    "3. Code (full files, no TODO placeholders)",
    "4. Tests (unit/widget/integration as applicable)",
    "5. Docs diffs / ADR additions (if architectural decisions changed)",
    "6. Manual QA steps (including offline & error paths)",
    "7. Performance & Accessibility checks",
    "8. Conventional commit message (subject <=72 chars)",
    "",        
    "## Finalization Workflow",
    "Before requesting a PR: repeatedly run the dry-run finalize until all validations pass.",
    "Command: python scripts/dev_assistant.py finalize-feature --feature-id {feature_id} --dry-run --json",
    "Check JSON: validations.tests_ok, validations.coverage_ok (>= ${MIN_PROJECT_COV}% line), validations.todos_ok all true.",
    "If any false: add/adjust tests, raise coverage, or complete checklist (AI_PROMPT). Re-run dry-run.",
    "Only when all pass: run without --dry-run to auto-stage + commit (optionally add --push).",
    "Never commit partial feature via finalize-feature; use normal git commits for intermediate work.",
    "Always run all tests locally before finalize-feature.",
    "",
    "## Implementation Guidance",
    "1. Maintain feature-first folder structure (domain, data, presentation).",
    "2. Expose public API via Riverpod providers; avoid direct Firestore/Dio in widgets.",
    "3. Add Freezed entities & DTO mappers; ensure serialization isolated.",
    "4. Implement use cases (pure) in domain layer returning Either<AppFailure, T>.",
    "5. Add minimal tests: mapper, use case happy path + one failure, provider logic.",
    "6. Respect performance & accessibility notes above.",
    "7. Update feature status to in_progress only if delivering code (already auto-set).",
    "8. Keep AI generated explanations concise in PR body; no large boilerplate.",
    "",
    "## Initial TODO Checklist",
    "- [ ] Define domain entities / value objects (if new).",
    "- [ ] Add use cases (list in code comment).",
    "- [ ] Create repository interface + impl placeholders.",
    "- [ ] Wire Riverpod providers (autoDispose where suitable).",
    "- [ ] Implement presentation widgets/screens behind feature flag if needed.",
    "- [ ] Write unit tests (≥85% for new lines).",
    "- [ ] Update docs / ADR if architectural decisions differ.",
    "",
    "## Do Not",
    "- Introduce new heavy dependencies without ADR.",
    "- Bypass error handling (always map to AppFailure).",
    "- Expose raw exceptions or Firestore documents to UI.",
    "",
    "(End of prompt)",
    "",
    ]
    prompt_path.write_text("\n".join(content_lines), encoding="utf-8")
    out["path"] = str(prompt_path.relative_to(ROOT))
    return out

def _load_feature_record(feature_id: str) -> Dict[str, Any]:
    fm = load_feature_matrix()
    for f in fm.get('features', []) or []:
        if f.get('id') == feature_id:
            return f
    return {}

# Patch original cmd_start_next_feature to append branch + prompt generation (keeping existing logic)
original_cmd_start_next_feature = cmd_start_next_feature

def cmd_start_next_feature_enhanced(args) -> Dict[str, Any]:
    base_result = original_cmd_start_next_feature(args)
    if base_result.get("error"):
        return base_result
    feature_id = base_result.get("started_feature")
    if not isinstance(feature_id, str):
        base_result["prompt"] = {"error": "invalid_feature_id_type"}
        return base_result
    # Branch creation
    branch_info = _create_feature_branch(feature_id, bool(base_result.get("dry_run")))
    base_result["git_branch"] = branch_info
    # AI prompt generation
    record = _load_feature_record(feature_id)
    prompt_info = _generate_ai_prompt(record, feature_id, bool(base_result.get("dry_run")))
    base_result["prompt"] = prompt_info
    # Optional auto commit & push
    if not base_result.get("dry_run") and getattr(args, 'auto_commit', False):
        files_to_add: List[str] = []
        scaffold = base_result.get('scaffold', {}) or {}
        for rel in scaffold.get('created', []) or []:
            if isinstance(rel, str):
                # add entire directory or file
                files_to_add.append(rel)
        prompt_path = prompt_info.get('path') if isinstance(prompt_info, dict) else None
        if isinstance(prompt_path, str):
            files_to_add.append(prompt_path)
        if base_result.get('matrix_updated'):
            files_to_add.append(str(FEATURE_MATRIX.relative_to(ROOT)))
        added: Dict[str, Any] = {"staged": [], "errors": []}
        for rel in files_to_add:
            ok_add, out_add = run(["git", "add", rel], timeout=15)
            if ok_add:
                added["staged"].append(rel)
            else:
                added["errors"].append({"file": rel, "error": out_add[:120]})
        commit_msg = f"feat({feature_id.split('.')[-1]}): start {feature_id} scaffold"
        ok_commit, out_commit = run(["git", "commit", "-m", commit_msg], timeout=30)
        commit_info = {"committed": ok_commit, "message": commit_msg, "output": out_commit[-400:] if out_commit else "", "staged_count": len(added['staged'])}
        base_result['git_commit'] = commit_info
        base_result['git_add'] = added
        if ok_commit and getattr(args, 'push', False):
            branch_name = base_result.get('git_branch', {}).get('branch') if isinstance(base_result.get('git_branch'), dict) else None
            if branch_name:
                ok_push, out_push = run(["git", "push", "-u", "origin", branch_name], timeout=60)
                base_result['git_push'] = {"pushed": ok_push, "output": out_push[-400:] if out_push else ""}
    return base_result

# Re-register updated command
COMMANDS["start-next-feature"] = cmd_start_next_feature_enhanced

# ----------------------------- Finalize Feature Command -----------------------------
def _infer_feature_id_from_branch() -> Optional[str]:
    branch = _current_branch()
    if not branch:
        return None
    if not branch.startswith("feat/"):
        return None
    token = branch.split('/',1)[1]
    # token originally had '.' replaced with '_'. We'll map by comparing sanitized forms.
    fm = load_feature_matrix()
    for f in fm.get('features', []) or []:
        fid = f.get('id')
        if not isinstance(fid, str):
            continue
        if fid.replace('.', '_') == token:
            return fid
    return None

def _finalize_feature_matrix_status(feature_id: str, dry_run: bool) -> Tuple[bool, Optional[str], Optional[str]]:
    data = load_feature_matrix()
    feats = data.get('features') or []
    prev = None
    new = None
    for f in feats:
        if f.get('id') == feature_id:
            prev = f.get('status')
            if prev == 'in_progress':
                new = 'done'
                if not dry_run:
                    f['status'] = new
            else:
                new = prev
            break
    if not dry_run and prev == 'in_progress' and new == 'done':
        FEATURE_MATRIX.write_text(yaml.safe_dump(data, sort_keys=False), encoding='utf-8')
    return (prev is not None, prev, new)

def _scan_prompt_todos(feature_id: str) -> Dict[str, Any]:
    path = _feature_dir(feature_id) / 'AI_PROMPT.md'
    if not path.exists():
        return {"error": "prompt_missing"}
    text = path.read_text(encoding='utf-8')
    unchecked = []
    checked = 0
    for line in text.splitlines():
        if line.strip().startswith('- [ ]'):
            unchecked.append(line.strip())
        elif line.strip().startswith('- [x]'):
            checked += 1
    return {"path": str(path.relative_to(ROOT)), "unchecked": unchecked, "checked": checked}

def _feature_changed_files(feature_id: str) -> List[str]:
    """Heuristic: list staged + unstaged files under feature dir and core routing modifications."""
    feature_dir = _feature_dir(feature_id)
    rel = feature_dir.relative_to(ROOT)
    changed = _changed_files()
    matches: List[str] = []
    for entry in changed:
        p = entry.get('path')
        if isinstance(p, str) and (p.startswith(str(rel)) or p == 'feature_matrix.yaml'):
            matches.append(p)
    return sorted(set(matches))

def cmd_finalize_feature(args) -> Dict[str, Any]:
    feature_id = getattr(args, 'feature_id', None) or _infer_feature_id_from_branch()
    if not feature_id:
        return {"error": "feature_id_required"}
    fm = load_feature_matrix()
    record = next((f for f in fm.get('features', []) or [] if f.get('id') == feature_id), None)
    if not record:
        return {"error": "feature_not_found", "feature_id": feature_id}
    status = record.get('status')
    if status != 'in_progress':
        return {"error": "invalid_status", "expected": "in_progress", "actual": status}
    # Run tests & coverage unless skip-tests provided
    if getattr(args, 'skip_tests', False):
        tests_ok = True
        cov = parse_lcov(COVERAGE_FILE)
    else:
        tests_ok, _ = ensure_tests_with_coverage()
        cov = parse_lcov(COVERAGE_FILE)
    cov_pct = cov.get('line_coverage') if isinstance(cov, dict) else None
    coverage_ok = (isinstance(cov_pct, (int, float)) and cov_pct >= MIN_PROJECT_COV)
    prompt_check = _scan_prompt_todos(feature_id)
    todos_ok = not prompt_check.get('unchecked')
    changed = _feature_changed_files(feature_id)
    validations = {
        'tests_ok': tests_ok,
        'coverage_ok': coverage_ok,
        'coverage_pct': cov_pct,
        'todos_ok': todos_ok,
        'unchecked_todos': prompt_check.get('unchecked'),
        'prompt': prompt_check,
        'changed_files': changed,
    }
    all_pass = tests_ok and coverage_ok and todos_ok
    dry_run = getattr(args, 'dry_run', False)
    status_change: Optional[Dict[str, Any]] = None
    if all_pass:
        upd = _finalize_feature_matrix_status(feature_id, dry_run)
        status_change = {"updated": upd[0], "prev": upd[1], "new": upd[2]}
    else:
        status_change = {"skipped": True, "reason": "validation_failed"}
    commit_info = None
    if all_pass and not dry_run:
        # Stage ALL changes (user requested behavior) instead of heuristic subset.
        # This will include new files, modifications, deletions, and the updated feature_matrix.yaml.
        run(["git", "add", "."], timeout=60)
        # Capture staged files list
        staged_list: List[str] = []
        ok_ls, out_ls = run(["git", "diff", "--cached", "--name-only"], timeout=30)
        if ok_ls and out_ls:
            staged_list = [ln.strip() for ln in out_ls.splitlines() if ln.strip()]
        commit_msg = f"feat({feature_id.split('.')[-1]}): finalize {feature_id}"
        ok_commit, out_commit = run(["git", "commit", "-m", commit_msg], timeout=50)
        commit_info = {"attempted": True, "committed": ok_commit, "message": commit_msg, "staged": staged_list, "errors": [], "output": out_commit[-400:] if out_commit else ""}
        if ok_commit and getattr(args, 'push', False):
            branch = _current_branch()
            if branch:
                ok_push, out_push = run(["git", "push", "origin", branch], timeout=70)
                commit_info['push'] = {"pushed": ok_push, "output": out_push[-400:] if out_push else ""}
    return {"feature_id": feature_id, "validations": validations, "all_pass": all_pass, "status": status_change, "commit": commit_info, "dry_run": dry_run}

# Register finalize command
COMMANDS["finalize-feature"] = cmd_finalize_feature

def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(description="AshTrail Dev Assistant")
    p.add_argument("command", choices=COMMANDS.keys())
    p.add_argument("--json", action="store_true", help="JSON output")
    p.add_argument("--limit", type=int, default=10)
    p.add_argument("--upload", action="store_true", help="Upload coverage in dev-cycle")
    p.add_argument("--skip-tests", action="store_true", help="Skip running tests in dev-cycle (used for fast manifest generation / tests)")
    p.add_argument("--log-file", help="Append structured JSONL log to file")
    # start-next-feature options
    p.add_argument("--feature-id", help="Explicit feature id to start (overrides suggestion)")
    p.add_argument("--order-mode", choices=["matrix","priority","appearance"], default="matrix", help="Ordering mode for next feature suggestion")
    p.add_argument("--dry-run", action="store_true", help="Show actions without modifying files")
    p.add_argument("--auto-commit", action="store_true", help="Automatically git add + commit scaffold & prompt")
    p.add_argument("--push", action="store_true", help="Push newly created branch after committing (implies --auto-commit)")
    # finalize-feature options reuse --feature-id, --dry-run, --skip-tests, --push
    return p

def main(argv: Optional[List[str]] = None) -> int:
    args = build_parser().parse_args(argv)
    func = COMMANDS[args.command]
    start = time.time()
    exit_code = 0
    error: Optional[str] = None
    try:
        result = func(args)
    except Exception as e:  # pragma: no cover
        result = {"error": str(e)}
        error = str(e)
        exit_code = 2
    # Coverage-based exit code adjustment
    if exit_code == 0 and args.command in {"test-coverage", "dev-cycle", "full-check"}:
        cov = None
        if args.command == "test-coverage":
            cov = result.get("coverage_after") if isinstance(result, dict) else None
        elif args.command == "dev-cycle":
            cov = result.get("coverage") if isinstance(result, dict) else None
        elif args.command == "full-check":
            cov = result.get("coverage") if isinstance(result, dict) else None
        pct = cov.get("line_coverage") if isinstance(cov, dict) else None
        if isinstance(pct, (int, float)) and pct < MIN_PROJECT_COV:
            exit_code = 1
    out_str = json.dumps(result, indent=2, default=str)
    print(out_str)
    duration_ms = int((time.time() - start) * 1000)
    if args.log_file:
        try:
            log_entry = {
                "ts": datetime.now(timezone.utc).isoformat(),
                "cmd": args.command,
                "duration_ms": duration_ms,
                "exit_code": exit_code,
                "error": error,
                "coverage_line_pct": None,
            }
            if isinstance(result, dict):
                if args.command == "test-coverage":
                    cov_obj = result.get("coverage_after") or {}
                    if isinstance(cov_obj, dict):
                        log_entry["coverage_line_pct"] = cov_obj.get("line_coverage")
                elif args.command == "dev-cycle":
                    cov_obj = result.get("coverage") or {}
                    if isinstance(cov_obj, dict):
                        log_entry["coverage_line_pct"] = cov_obj.get("line_coverage")
                elif args.command == "full-check":
                    cov_obj = result.get("coverage") or {}
                    if isinstance(cov_obj, dict):
                        log_entry["coverage_line_pct"] = cov_obj.get("line_coverage")
            with open(args.log_file, "a", encoding="utf-8") as lf:
                lf.write(json.dumps(log_entry, default=str) + "\n")
        except Exception:  # pragma: no cover
            pass
    return exit_code

if __name__ == "__main__":  # pragma: no cover
    raise SystemExit(main())
