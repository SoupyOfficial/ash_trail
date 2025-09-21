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
INSTRUCTIONS_DIR = ROOT / ".github" / "instructions"

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

def ensure_instructions_dir() -> None:
    """Ensure the .github/instructions directory exists."""
    INSTRUCTIONS_DIR.mkdir(parents=True, exist_ok=True)

def copy_coverage_to_instructions() -> Dict[str, Any]:
    """Copy coverage results to .github/instructions folder for AI reference."""
    ensure_instructions_dir()
    copied_files = []
    
    # Copy lcov.info if it exists
    if COVERAGE_FILE.exists():
        dest = INSTRUCTIONS_DIR / "latest_coverage.lcov"
        try:
            import shutil
            shutil.copy2(COVERAGE_FILE, dest)
            copied_files.append(str(dest.relative_to(ROOT)))
        except Exception as e:
            pass
    
    # Generate a human-readable coverage summary
    cov = parse_lcov(COVERAGE_FILE)
    if cov:
        summary_lines = [
            f"# Test Coverage Summary",
            f"",
            f"Generated: {datetime.now(timezone.utc).isoformat()}",
            f"",
            f"## Overall Coverage",
            f"- **Line Coverage**: {cov.get('line_coverage', 0):.1f}%",
            f"- **Lines Hit**: {cov.get('lines_hit', 0):,}",
            f"- **Total Lines**: {cov.get('lines_found', 0):,}",
            f"",
            f"## File Coverage Details",
            f"",
        ]
        
        for file_info in cov.get("files", [])[:20]:  # Top 20 files
            file_path = file_info.get("file", "unknown")
            hit = file_info.get("lines_hit", 0)
            total = file_info.get("lines_found", 0)
            pct = (hit / total * 100) if total > 0 else 0
            summary_lines.append(f"- `{file_path}`: {pct:.1f}% ({hit}/{total})")
        
        if len(cov.get("files", [])) > 20:
            summary_lines.append(f"- ... and {len(cov.get('files', [])) - 20} more files")
        
        summary_path = INSTRUCTIONS_DIR / "latest_coverage_summary.md"
        summary_path.write_text("\n".join(summary_lines), encoding="utf-8")
        copied_files.append(str(summary_path.relative_to(ROOT)))
    
    return {"copied_files": copied_files, "instructions_dir": str(INSTRUCTIONS_DIR.relative_to(ROOT))}

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
    
    # Copy coverage results to instructions folder
    copy_result = copy_coverage_to_instructions()
    
    return {
        "tests_passed": ok, 
        "coverage_before": before, 
        "coverage_after": after, 
        "warning": warn, 
        "output_tail": out[-2000:] if out else "",
        "copied_to_instructions": copy_result
    }

def cmd_test_codecov(args) -> Dict[str, Any]:
    if not COVERAGE_FILE.exists():
        return {"error": "coverage_missing"}
    ok, ver = run(["codecov", "--version"], timeout=5)
    return {"codecov_cli": ok, "version": ver.split()[1] if ok and ver else None}

def cmd_upload_codecov(args) -> Dict[str, Any]:
    if not COVERAGE_FILE.exists():
        return {"error": "coverage_missing"}
    
    # Read token from codecov.yml
    codecov_config = ROOT / "codecov.yml"
    token = None
    if codecov_config.exists():
        try:
            with open(codecov_config, 'r') as f:
                config = yaml.safe_load(f)
                token = config.get('codecov', {}).get('token')
        except Exception:
            pass  # Fallback to env var or no token
    
    # Get current branch info
    branch, commit = _git_info()
    
    # Build codecov command with explicit branch and commit
    cmd = [
        "codecov", 
        "-f", str(COVERAGE_FILE.relative_to(ROOT)),
        "--flag", "flutter_tests",
        "--verbose"
    ]
    
    if token:
        cmd.extend(["--token", token])
    if branch:
        cmd.extend(["--branch", branch])
    if commit:
        cmd.extend(["--sha", commit])
        
    ok, out = run(cmd, timeout=120)
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
    
    # Copy coverage results to instructions folder if tests were run
    copy_result = None
    if not args.skip_tests and end_cov:
        copy_result = copy_coverage_to_instructions()
    
    return {
        "tests_passed": ok, 
        "coverage": end_cov, 
        "uploaded": uploaded, 
        "manifest": str(path.relative_to(ROOT)), 
        "notes": notes, 
        "branch": branch, 
        "commit": commit, 
        "file_coverage_deltas": file_deltas,
        "copied_to_instructions": copy_result
    }

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

def _generate_ai_implementation_guide(feature_record: Dict[str, Any], feature_id: str, dry_run: bool) -> Dict[str, Any]:
    """Generate an AI assistant implementation prompt inside the feature folder.

    File path: lib/features/<snake>/AI_IMPLEMENTATION_GUIDE.md
    Content includes: summary, rationale, acceptance, components, data/offline/telemetry/a11y/errors.
    """
    out: Dict[str, Any] = {"path": None}
    if not feature_record:
        out["error"] = "feature_record_missing"
        return out
    snake = feature_id.split('.')[-1]
    feature_dir = _feature_dir(feature_id)
    prompt_path = feature_dir / "AI_IMPLEMENTATION_GUIDE.md"
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
    "If any false: add/adjust tests, raise coverage, or complete checklist (AI_IMPLEMENTATION_GUIDE). Re-run dry-run.",
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

def _analyze_feature_complexity(feature_record: Dict[str, Any]) -> str:
    """Analyze feature complexity based on components, acceptance criteria, and data operations."""
    complexity_score = 0
    
    # Base complexity factors
    acceptance = feature_record.get("acceptance") or []
    components = feature_record.get("components") or []
    screens = feature_record.get("screens") or feature_record.get("screen") or []
    user_stories = feature_record.get("user_stories") or []
    data_block = feature_record.get("data") or {}
    
    # Scoring criteria
    complexity_score += min(len(acceptance), 5)  # Max 5 points for acceptance criteria
    complexity_score += min(len(components), 4)  # Max 4 points for components
    complexity_score += min(len(screens), 3)     # Max 3 points for screens
    complexity_score += min(len(user_stories), 3) # Max 3 points for user stories
    
    # Data complexity
    reads = data_block.get("reads") or []
    writes = data_block.get("writes") or []
    complexity_score += min(len(reads) + len(writes), 4)  # Max 4 points for data ops
    
    # Special complexity indicators
    if feature_record.get("offline"):
        complexity_score += 2  # Offline features are more complex
    if feature_record.get("a11y"):
        complexity_score += 1  # Accessibility adds complexity
    if feature_record.get("perf_budget"):
        complexity_score += 1  # Performance requirements add complexity
    
    # Classify complexity
    if complexity_score <= 6:
        return "simple"
    elif complexity_score <= 12:
        return "moderate"
    else:
        return "complex"


def _find_related_features(feature_id: str, feature_record: Dict[str, Any]) -> List[str]:
    """Find related features based on epic, components, and data patterns."""
    related = []
    current_epic = feature_record.get("epic", "")
    current_components = set(feature_record.get("components") or [])
    
    fm = load_feature_matrix()
    for f in fm.get('features', []) or []:
        other_id = f.get('id')
        if not other_id or other_id == feature_id:
            continue
            
        # Same epic features (but not all of them)
        if f.get("epic") == current_epic and len(related) < 3:
            related.append(other_id)
            continue
            
        # Similar components
        other_components = set(f.get("components") or [])
        if current_components & other_components and len(related) < 5:
            related.append(other_id)
    
    return related[:5]  # Limit to 5 most relevant


def _generate_implementation_hints(feature_record: Dict[str, Any], feature_id: str) -> List[str]:
    """Generate context-specific implementation hints."""
    hints = []
    
    priority = feature_record.get("priority", "P3")
    epic = feature_record.get("epic", "")
    
    # Priority-based hints
    if priority == "P0":
        hints.append("Critical feature - prioritize reliability and comprehensive testing")
    
    # Epic-specific hints  
    if epic == "logging":
        hints.append("Ensure offline-first data persistence with sync queue")
        hints.append("Focus on user experience - minimal taps and fast interactions")
    elif epic == "insights":
        hints.append("Optimize chart rendering performance - target <200ms render time")
        hints.append("Consider data aggregation strategies for large datasets")
    elif epic == "ui":
        hints.append("Focus on responsive design and accessibility compliance")
        hints.append("Use consistent theming and semantic colors from design system")
    elif epic == "accounts":
        hints.append("Maintain data isolation between accounts")
        hints.append("Consider cached authentication state for performance")
    elif epic == "sync":
        hints.append("Implement exponential backoff for retry mechanisms")
        hints.append("Handle edge cases like partial sync failures gracefully")
    
    # Feature-specific patterns
    if feature_record.get("offline"):
        hints.append("Implement proper conflict resolution strategy")
    if feature_record.get("a11y"):
        hints.append("Test with screen readers and high contrast themes")
    if feature_record.get("perf_budget"):
        hints.append("Profile performance during development with DevTools")
    
    # Default architectural hints
    if not hints:
        hints.extend([
            "Follow Clean Architecture boundaries strictly", 
            "Implement comprehensive error handling",
            "Write tests first for critical business logic"
        ])
    
    return hints


def _load_feature_record(feature_id: str) -> Dict[str, Any]:
    fm = load_feature_matrix()
    for f in fm.get('features', []) or []:
        if f.get('id') == feature_id:
            return f
    return {}


def _generate_production_ai_implementation_guide(feature_record: Dict[str, Any], feature_id: str, dry_run: bool, 
                                  related_features: List[str], complexity: str, hints: List[str]) -> Dict[str, Any]:
    """Generate production-ready AI implementation prompt with comprehensive guidance."""
    out: Dict[str, Any] = {"path": None}
    if not feature_record:
        out["error"] = "feature_record_missing"
        return out
    
    snake = feature_id.split('.')[-1]
    prompt_path = INSTRUCTIONS_DIR / f"AI_IMPLEMENTATION_GUIDE_{snake}.md"
    
    if dry_run:
        out["path"] = str(prompt_path.relative_to(ROOT))
        return out
    
    ensure_instructions_dir()
    
    # Extract comprehensive feature metadata
    title = feature_record.get("title", feature_id)
    epic = feature_record.get("epic", "unknown")
    priority = feature_record.get("priority", "P3")
    order = feature_record.get("order", "N/A")
    rationale = feature_record.get("rationale", "")
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

    def bullet_list(items, prefix=""):
        if not items:
            return "  - _(None specified)_"
        return "\n".join(f"  - {prefix}{item}" for item in items)
    
    def code_block(code, lang="dart"):
        return f"```{lang}\n{code}\n```"

    # Create comprehensive AI implementation guide
    content_lines = [
        "# 🚀 Production AI Implementation Guide",
        "",
        f"## 🎯 Feature Overview",
        f"**Feature ID:** `{feature_id}`",
        f"**Title:** {title}",
        f"**Epic:** {epic} ({epic.upper()}) | **Priority:** {priority} | **Order:** {order}",
        f"**Complexity:** {complexity.title()} | **Estimated Duration:** {_estimate_duration(complexity)}",
        "",
        "---",
        "",
        "## 📝 Executive Summary",
        "",
        f"You are tasked with implementing **{title}** ({feature_id}) as part of the AshTrail mobile application.",
        "This is a production-grade implementation requiring adherence to established architectural patterns,",
        "comprehensive testing, and quality assurance measures.",
        "",
        "### 🎨 Rationale & Business Value",
        rationale if rationale else "_(Refer to acceptance criteria for implementation guidance)_",
        "",
        "---",
        "",
        "## 🏗️ Architecture & Technical Context",
        "",
        "### Clean Architecture Overview",
        "AshTrail follows Clean Architecture principles with strict layer separation:",
        "",
        code_block(f"""lib/features/{snake}/
├── domain/                    # Pure business logic (no dependencies)
│   ├── entities/              # Core business objects (immutable)
│   ├── repositories/          # Abstract contracts (interfaces)
│   └── usecases/              # Business use cases (pure functions)
├── data/                      # External data handling
│   ├── datasources/           # Remote (Firestore) & Local (Isar) sources
│   ├── repositories/          # Repository implementations
│   └── models/                # DTOs with JSON serialization
└── presentation/              # UI and state management
    ├── providers/             # Riverpod providers and controllers
    ├── screens/               # Full screen implementations
    └── widgets/               # Reusable UI components

test/features/{snake}/         # Comprehensive test coverage
├── domain/                    # Unit tests for use cases and entities
├── data/                      # Repository and data source tests
└── presentation/              # Widget and integration tests""", ""),
        "",
        "### 🔄 Data Flow Pattern",
        code_block("""UI Widget (Consumer)
    ↓ (user action)
Provider/Controller (Riverpod)
    ↓ (business operation)
UseCase (Domain)
    ↓ (data request)
Repository Interface (Domain)
    ↓ (implementation)
Repository Impl (Data)
    ↓ (I/O operation)
DataSource (Local/Remote)""", ""),
        "",
        "### 🛡️ Error Handling Pattern",
        code_block("""sealed class AppFailure extends Equatable {
  const AppFailure();
}

class NetworkFailure extends AppFailure {
  final String message;
  const NetworkFailure({required this.message});
  @override
  List<Object> get props => [message];
}

class CacheFailure extends AppFailure {
  final String message;
  const CacheFailure({required this.message});
  @override
  List<Object> get props => [message];
}"""),
        "",
        "---",
        "",
        "## 📋 Requirements Analysis",
        "",
        "### ✅ Acceptance Criteria",
        bullet_list(acceptance, "**Must:** ") if acceptance else "  - _(Review feature matrix for implicit requirements)_",
        "",
    ]

    # Add user stories if present
    if user_stories:
        content_lines.extend([
            "### 👤 User Stories",
            bullet_list(user_stories, "As a user, "),
            "",
        ])

    # Technical specifications
    content_lines.extend([
        "### 🔧 Technical Specifications",
        "",
    ])

    if components:
        content_lines.extend([
            "**Required Components:**",
            bullet_list(components),
            "",
        ])

    if screens:
        content_lines.extend([
            "**Screens/Views:**",
            bullet_list(screens),
            "",
        ])

    # Data operations
    if data_block:
        reads = data_block.get("reads") or []
        writes = data_block.get("writes") or []
        if reads or writes:
            content_lines.extend([
                "**Data Operations:**",
                f"- **Reads:** {len(reads)} operations" if reads else "- **Reads:** None",
                f"- **Writes:** {len(writes)} operations" if writes else "- **Writes:** None",
                "",
            ])

    # Offline behavior
    if offline_block:
        content_lines.extend([
            "**Offline Behavior:**",
            bullet_list([f"**{k}:** {v}" for k, v in offline_block.items()]),
            "",
        ])

    # Performance budget
    if perf_budget:
        content_lines.extend([
            "**Performance Targets:**",
            bullet_list([f"**{k}:** {v}" for k, v in perf_budget.items()]),
            "",
            "**Performance Implementation Guidance:**",
            "- Profile during development with Flutter DevTools",
            "- Use `flutter run --profile` for performance testing",
            "- Monitor frame rendering times and memory usage",
            "- Implement lazy loading where appropriate",
            "",
        ])

    # Accessibility requirements
    if a11y:
        content_lines.extend([
            "**Accessibility Requirements:**",
            bullet_list([f"**{k}:** {v}" for k, v in a11y.items()]),
            "",
            "**Accessibility Implementation:**",
            "- Use `Semantics` widgets with meaningful labels",
            "- Ensure touch targets meet minimum size requirements",
            "- Test with TalkBack/VoiceOver enabled",
            "- Support high contrast and large text modes",
            "",
        ])

    # Telemetry events
    if telemetry_events:
        content_lines.extend([
            "**Telemetry Events:**",
            bullet_list(telemetry_events),
            "",
            "**Telemetry Implementation:**",
            code_block(f"""// Track user interactions
await telemetryService.track('{telemetry_events[0] if telemetry_events else "feature_used"}', {{
  'feature_id': '{feature_id}',
  'user_id': currentUser.id,
  'timestamp': DateTime.now().toIso8601String(),
}});"""),
            "",
        ])

    # Error handling
    if errors:
        content_lines.extend([
            "**Feature-Specific Error Codes:**",
            bullet_list([f"`{e.get('code')}`: {e.get('message')}" if isinstance(e, dict) else str(e) for e in errors]),
            "",
            "**Error Implementation Pattern:**",
            code_block(f"""sealed class {snake.title().replace('_', '')}Failure extends AppFailure {{
  const {snake.title().replace('_', '')}Failure();
}}

class {snake.title().replace('_', '')}RecordFailure extends {snake.title().replace('_', '')}Failure {{
  final String message;
  const {snake.title().replace('_', '')}RecordFailure({{required this.message}});
  @override
  List<Object> get props => [message];
}}

// Usage in repository:
return Left({snake.title().replace('_', '')}RecordFailure(message: '{errors[0].get("message") if errors and isinstance(errors[0], dict) else "Operation failed"}'));"""),
            "",
        ])

    # Related features
    if related_features:
        content_lines.extend([
            "### 🔗 Related Features (Reference Patterns)",
            bullet_list([f"`{rf}` - Study existing implementation patterns" for rf in related_features]),
            "",
        ])

    # Implementation hints
    if hints:
        content_lines.extend([
            "###  Implementation Hints",
            bullet_list(hints),
            "",
        ])

    content_lines.extend([
        "---",
        "",
        "## 🛠️ Implementation Strategy",
        "",
        "### Phase 1: Domain Layer (Pure Business Logic)",
        "",
        "#### 1.1 Define Entities",
        code_block(f"""// lib/features/{snake}/domain/entities/{snake}_entity.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '{snake}_entity.freezed.dart';

@freezed
class {snake.title().replace('_', '')}Entity with _${snake.title().replace('_', '')}Entity {{
  const factory {snake.title().replace('_', '')}Entity({{
    required String id,
    required DateTime createdAt,
    DateTime? updatedAt,
    // Add your domain fields here based on requirements
  }}) = _{snake.title().replace('_', '')}Entity;
  
  // Add domain business logic methods
  // Example: bool get isValid => /* validation logic */;
}}"""),
        "",
        "#### 1.2 Define Repository Interface",
        code_block(f"""// lib/features/{snake}/domain/repositories/{snake}_repository.dart
import 'package:dartz/dartz.dart';
import '../entities/{snake}_entity.dart';
import '../../../../core/error/failures.dart';

abstract class {snake.title().replace('_', '')}Repository {{
  Future<Either<AppFailure, List<{snake.title().replace('_', '')}Entity>>> getAll();
  Future<Either<AppFailure, {snake.title().replace('_', '')}Entity>> getById(String id);
  Future<Either<AppFailure, {snake.title().replace('_', '')}Entity>> create({snake.title().replace('_', '')}Entity entity);
  Future<Either<AppFailure, {snake.title().replace('_', '')}Entity>> update({snake.title().replace('_', '')}Entity entity);
  Future<Either<AppFailure, void>> delete(String id);
}}"""),
        "",
        "#### 1.3 Implement Use Cases",
        code_block(f"""// lib/features/{snake}/domain/usecases/get_{snake}s_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entities/{snake}_entity.dart';
import '../repositories/{snake}_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

@injectable
class Get{snake.title().replace('_', '')}sUseCase implements UseCase<List<{snake.title().replace('_', '')}Entity>, NoParams> {{
  const Get{snake.title().replace('_', '')}sUseCase(this._repository);
  
  final {snake.title().replace('_', '')}Repository _repository;
  
  @override
  Future<Either<AppFailure, List<{snake.title().replace('_', '')}Entity>>> call(NoParams params) {{
    return _repository.getAll();
  }}
}}"""),
        "",
        "### Phase 2: Data Layer (External Dependencies)",
        "",
        "#### 2.1 Create Data Models",
        code_block(f"""// lib/features/{snake}/data/models/{snake}_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/{snake}_entity.dart';

part '{snake}_model.freezed.dart';
part '{snake}_model.g.dart';

@freezed
@Collection()
class {snake.title().replace('_', '')}Model with _${snake.title().replace('_', '')}Model {{
  const factory {snake.title().replace('_', '')}Model({{
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }}) = _{snake.title().replace('_', '')}Model;
  
  factory {snake.title().replace('_', '')}Model.fromJson(Map<String, dynamic> json) =>
      _${snake.title().replace('_', '')}ModelFromJson(json);
  
  {snake.title().replace('_', '')}Entity toEntity() => {snake.title().replace('_', '')}Entity(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
  
  factory {snake.title().replace('_', '')}Model.fromEntity({snake.title().replace('_', '')}Entity entity) =>
      {snake.title().replace('_', '')}Model(
        id: entity.id,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );
}}"""),
        "",
        "### Phase 3: Presentation Layer (UI & State)",
        "",
        "#### 3.1 Create Riverpod Providers",
        code_block(f"""// lib/features/{snake}/presentation/providers/{snake}_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/{snake}_entity.dart';
import '../../domain/usecases/get_{snake}s_usecase.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/di/injection.dart';

part '{snake}_providers.g.dart';

@riverpod
class {snake.title().replace('_', '')}ListNotifier extends _{snake.title().replace('_', '')}ListNotifier {{
  @override
  Future<List<{snake.title().replace('_', '')}Entity>> build() async {{
    final useCase = getIt<Get{snake.title().replace('_', '')}sUseCase>();
    final result = await useCase(NoParams());
    
    return result.fold(
      (failure) => throw failure,
      (entities) => entities,
    );
  }}
  
  Future<void> refresh() async {{
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }}
}}"""),
        "",
        "---",
        "",
        "## 🧪 Testing Requirements",
        "",
        f"### Test Coverage Target: ≥85% (Project minimum: {MIN_PROJECT_COV}%)",
        "",
        "### 📊 Codecov Integration & Coverage Monitoring",
        "",
        "This project uses **Codecov** for comprehensive test coverage tracking and quality gates. Understanding and leveraging Codecov is essential for maintaining code quality.",
        "",
        "#### Codecov Configuration",
        "The project uses component-based coverage tracking with different targets:",
        "- **Domain Layer**: 90% (business logic requires highest coverage)",
        "- **Core Infrastructure**: 85% (critical system components)",
        "- **Data Layer**: 85% (data handling and persistence)",
        "- **Use Cases**: 95% (critical business operations)",
        "- **Presentation Layer**: 70% (UI tests can be more challenging)",
        "- **Overall Project**: 80% minimum (with 75% patch coverage)",
        "",
        "#### Codecov Token & Authentication",
        "The project includes a Codecov token stored in `.codecov_token` for direct CLI usage:",
        code_block("""# View current token (first few characters only)
head -c 8 .codecov_token && echo "..."

# Use token for direct uploads
codecov -f coverage/lcov.info -t $(cat .codecov_token) -F flutter_tests

# Environment variable method (alternative)
export CODECOV_TOKEN=$(cat .codecov_token)
codecov -f coverage/lcov.info -F flutter_tests""", "bash"),
        "**Note**: The dev_assistant.py script handles token authentication automatically.",
        "",
        "#### Development Workflow with Codecov",
        "",
        "**Before Implementation:**",
        code_block("""# Check current Codecov CLI availability
python scripts/dev_assistant.py test-codecov

# Run baseline coverage check
python scripts/dev_assistant.py test-coverage""", "bash"),
        "",
        "**During Development:**",
        code_block("""# Run tests with coverage (generates coverage/lcov.info)
flutter test --coverage

# Quick development cycle with optional upload
python scripts/dev_assistant.py dev-cycle --upload

# Monitor coverage changes per file
# The dev-cycle command shows file-level coverage deltas""", "bash"),
        "",
        "**For CI/Production:**",
        code_block("""# Upload coverage to Codecov (with flutter_tests flag)
python scripts/dev_assistant.py upload-codecov

# This uploads coverage/lcov.info with proper flagging""", "bash"),
        "",
        "**Direct Codecov CLI Usage:**",
        "For advanced usage or troubleshooting, you can use Codecov CLI directly:",
        code_block("""# Using project token (stored in .codecov_token file)
codecov -f coverage/lcov.info -t $(cat .codecov_token) -F flutter_tests

# With verbose output for debugging
codecov -f coverage/lcov.info -t $(cat .codecov_token) -F flutter_tests -v

# Upload specific feature coverage
codecov -f coverage/lcov.info -t $(cat .codecov_token) -F flutter_tests -n "siri_shortcuts_feature"

# Upload with custom branch name
codecov -f coverage/lcov.info -t $(cat .codecov_token) -F flutter_tests -B feat/ui_siri_shortcuts""", "bash"),
        "",
        "#### Codecov Quality Gates",
        "- **Project Coverage**: Must maintain ≥80% overall",
        "- **Patch Coverage**: New code must have ≥75% coverage",
        "- **Component Targets**: Each architectural component has specific targets",
        "- **Threshold**: 1-2% drop allowed before failure (varies by component)",
        "",
        "#### Using Codecov Data During Development",
        "",
        "**1. Coverage Analysis:**",
        "```bash",
        "# View current coverage status",
        "python scripts/dev_assistant.py status",
        "# Shows: health check, coverage summary, next features",
        "",
        "# Detailed coverage analysis",
        "python scripts/dev_assistant.py test-coverage",
        "# Shows: before/after coverage, warnings if below minimum",
        "```",
        "",
        "**2. Session Tracking:**",
        "The `dev-cycle` command creates session manifests in `automation_sessions/` containing:",
        "- Coverage before/after with delta",
        "- File-level coverage changes",
        "- Test pass/fail status",
        "- Git branch and commit info",
        "",
        "**3. PR Integration:**",
        "Codecov automatically comments on PRs with:",
        "- Coverage diff showing changes",
        "- Component-level status",
        "- Files with coverage changes",
        "- Quality gate pass/fail status",
        "",
        "#### Coverage Best Practices",
        "",
        "**High-Priority Testing Areas:**",
        "- ✅ Domain entities and use cases (aim for 90-95%)",
        "- ✅ Repository implementations and data sources",
        "- ✅ Error handling and edge cases",
        "- ✅ State management providers and controllers",
        "",
        "**Acceptable Lower Coverage:**",
        "- 🎯 UI widgets (focus on critical user flows)",
        "- 🎯 Generated code (automatically excluded in codecov.yml)",
        "- 🎯 Platform-specific code (Android/iOS directories excluded)",
        "",
        "#### Troubleshooting Coverage Issues",
        "",
        "**Coverage Too Low:**",
        code_block("""# Identify uncovered code
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # View detailed coverage report

# Focus on critical paths in domain/use cases first""", "bash"),
        "",
        "**Coverage Upload Failing:**",
        code_block("""# Verify Codecov CLI installation
codecov --version

# Check coverage file exists
ls -la coverage/lcov.info

# Test token authentication
codecov -t $(cat .codecov_token) --dry-run

# Manual upload with debug info
codecov -f coverage/lcov.info -F flutter_tests -v

# Direct upload with token (bypassing dev_assistant.py)
codecov -f coverage/lcov.info -t $(cat .codecov_token) -F flutter_tests -v""", "bash"),
        "",
        "**⚠️ Coverage Requirements for This Feature:**",
        f"- Target ≥85% overall coverage for new `{snake}` feature code",
        "- Domain layer (entities/use cases) should achieve 90%+",
        "- All error scenarios must be tested",
        "- Widget tests should cover loading/error/success states",
        "",
        "#### Unit Tests",
        code_block(f"""// test/features/{snake}/domain/usecases/get_{snake}s_usecase_test.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {{
  group('Get{snake.title().replace('_', '')}sUseCase', () {{
    test('should return entities from repository', () async {{
      // arrange
      when(() => mockRepository.getAll())
          .thenAnswer((_) async => Right(testEntities));
      
      // act  
      final result = await useCase(NoParams());
      
      // assert
      expect(result, equals(Right(testEntities)));
      verify(() => mockRepository.getAll());
    }});
  }});
}}"""),
        "",
        "#### Widget Tests",
        code_block(f"""// test/features/{snake}/presentation/screens/{snake}_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {{
  testWidgets('displays loading state correctly', (tester) async {{
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          {snake}ListNotifierProvider.overrideWith((ref) {{
            return const AsyncValue.loading();
          }}),
        ],
        child: const MaterialApp(home: {snake.title().replace('_', '')}Screen()),
      ),
    );
    
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  }});
}}"""),
        "",
        "---",
        "",
        "## ✅ Quality Checklist",
        "",
        "### Architecture Compliance",
        "- [ ] Domain layer has no external dependencies",
        "- [ ] Repository interfaces defined in domain",
        "- [ ] Data layer implements repository contracts",
        "- [ ] Presentation layer uses providers for state",
        "",
        "### Error Handling",
        "- [ ] All operations return `Either<AppFailure, T>`",
        "- [ ] User-friendly error messages displayed",
        "- [ ] Network and cache failures handled",
        "",
        "### Testing",
        "- [ ] Unit tests cover use cases (happy + error paths)",
        "- [ ] Widget tests cover UI states (loading/error/success)",
        "- [ ] Integration tests verify critical flows",
        f"- [ ] Test coverage ≥85% for new code",
        "- [ ] Codecov upload successful (`python scripts/dev_assistant.py upload-codecov`)",
        "- [ ] Component-specific coverage targets met (check PR comments)",
        "- [ ] No critical business logic left uncovered",
        "- [ ] Coverage delta positive or within threshold limits",
        "",
        "### Performance & Accessibility",
        "- [ ] No unnecessary widget rebuilds",
        "- [ ] Proper provider disposal (autoDispose where needed)",
        "- [ ] Semantic labels on interactive elements",
        "- [ ] Touch targets ≥48dp minimum",
        "",
        "---",
        "",
        "## 🚫 Common Pitfalls & Anti-Patterns",
        "",
        f"### ❌ Feature-Specific Anti-Patterns for {epic.title()} Features",
        "",
    ])

    # Add epic-specific anti-patterns
    if epic == "logging":
        content_lines.extend([
            code_block("""// ❌ BAD: Synchronous logging operations
void logHit() {
  final log = SmokeLog(/*...*/);
  repository.save(log); // Blocks UI thread
}

// ✅ GOOD: Async with offline queue
Future<void> logHit() async {
  final log = SmokeLog(/*...*/);
  await localRepository.save(log); // Offline-first
  syncQueue.enqueue(log); // Background sync
}"""),
            "",
        ])
    elif epic == "ui":
        content_lines.extend([
            code_block("""// ❌ BAD: Hardcoded accessibility
Text('Record Hit'); // No semantic meaning

// ✅ GOOD: Accessible with proper sizing
Semantics(
  label: 'Record smoking hit. Hold to start timing.',
  child: GestureDetector(
    child: Container(width: 48, height: 48),
  ),
);"""),
            "",
        ])
    elif epic == "insights":
        content_lines.extend([
            code_block("""// ❌ BAD: Blocking chart rendering
Widget build(context) {
  final data = expensiveCalculation(); // Blocks UI
  return LineChart(data);
}

// ✅ GOOD: Async computation
@riverpod
Future<ChartData> chartData(ChartDataRef ref) async {
  return compute(processLargeDataset, rawData);
}"""),
            "",
        ])

    content_lines.extend([
        "### ❌ General Architecture Violations",
        code_block("""// ❌ BAD: Direct data import in presentation
import '../data/models/smoke_log_model.dart'; // Domain violation

// ❌ BAD: Business logic in widgets
class LogWidget extends StatelessWidget {
  Widget build(context) {
    final isValid = log.duration > 0 && log.timestamp.isBefore(DateTime.now());
    // Business logic belongs in domain layer
  }
}

// ✅ GOOD: Use domain entities
import '../domain/entities/smoke_log_entity.dart';

class LogWidget extends StatelessWidget {
  Widget build(context) {
    return log.isValid ? ValidLogView() : InvalidLogView();
    // Business logic in entity.isValid getter
  }
}"""),
        "",
        "---",
        "",
        "## 🚧 Development Workflow",
        "",
        "### Validation Commands",
        code_block(f"""# Continuous testing during development
flutter test --coverage test/features/{snake}/

# Run code generation  
flutter packages pub run build_runner build --delete-conflicting-outputs

# Check syntax and analysis
flutter analyze

# Complete dev cycle with coverage tracking
python scripts/dev_assistant.py dev-cycle --upload

# Check Codecov status and requirements
python scripts/dev_assistant.py test-codecov
python scripts/dev_assistant.py status

# Validate feature completion
python scripts/dev_assistant.py finalize-feature --feature-id {feature_id} --dry-run""", "bash"),
        "",
        "### Codecov Development Workflow",
        code_block("""# 1. Initial setup - verify Codecov CLI
python scripts/dev_assistant.py test-codecov

# Alternative: Direct CLI check
codecov --version
codecov -t $(cat .codecov_token) --dry-run

# 2. Development cycle - run tests, track coverage, upload
python scripts/dev_assistant.py dev-cycle --upload

# Alternative: Manual development cycle
flutter test --coverage
codecov -f coverage/lcov.info -t $(cat .codecov_token) -F flutter_tests -v

# 3. Review coverage changes
# Check automation_sessions/ for latest session manifest
# Review file-level coverage deltas

# 4. Manual coverage analysis (if needed)
python scripts/dev_assistant.py test-coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
# Open coverage/html/index.html for detailed analysis

# 5. Final validation before PR
python scripts/dev_assistant.py upload-codecov
# Alternative: Direct upload with feature naming
codecov -f coverage/lcov.info -t $(cat .codecov_token) -F flutter_tests -n "siri_shortcuts_implementation"
# Ensure coverage meets component targets""", "bash"),
        "",
        "### Quick Reference",
        f"- **Feature Matrix:** [`feature_matrix.yaml`](../../feature_matrix.yaml)",
        f"- **Architecture Docs:** [`docs/system-architecture.md`](../../docs/system-architecture.md)",
        f"- **AI Instructions:** [`.github/instructions/instruction-prompt.instructions.md`](../../.github/instructions/instruction-prompt.instructions.md)",
        "",
        "---",
        "",
        "## 🎯 Success Criteria",
        "",
        "✅ **Implementation Complete When:**",
        "- All acceptance criteria satisfied",
        "- Test coverage ≥85% for new code", 
        "- No architectural boundary violations",
        "- All error cases handled gracefully",
        "- Performance targets met (if specified)",
        "- Accessibility requirements satisfied", 
        "- Code review passes (automated + human)",
        "",
        "---",
        "",
        f"**Generated:** {datetime.now(timezone.utc).isoformat()}",
        f"**Complexity:** {complexity.title()} | **Epic:** {epic} | **Priority:** {priority}",
        "",
        "🚀 **Ready to implement? Follow Clean Architecture patterns and maintain quality standards!**",
    ])

    # Write the guide to file
    prompt_path.write_text("\n".join(content_lines), encoding="utf-8")
    out["path"] = str(prompt_path.relative_to(ROOT))
    return out


def _estimate_duration(complexity: str) -> str:
    """Estimate implementation duration based on complexity.""" 
    estimates = {
        "simple": "2-4 hours",
        "moderate": "4-8 hours", 
        "complex": "8-16 hours"
    }
    return estimates.get(complexity.lower(), "4-8 hours")


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
    # AI prompt generation with intelligent analysis
    record = _load_feature_record(feature_id)
    
    # Analyze feature characteristics
    complexity = _analyze_feature_complexity(record)
    related_features = _find_related_features(feature_id, record)
    implementation_hints = _generate_implementation_hints(record, feature_id)
    
    prompt_info = _generate_production_ai_implementation_guide(
        record, 
        feature_id, 
        bool(base_result.get("dry_run")),
        related_features,
        complexity,
        implementation_hints
    )
    base_result["prompt"] = prompt_info
    
    # Add analysis to result for debugging/telemetry
    base_result["analysis"] = {
        "complexity": complexity,
        "related_features": related_features,
        "implementation_hints": implementation_hints
    }
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
    path = _feature_dir(feature_id) / 'AI_IMPLEMENTATION_GUIDE.md'
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
        
        # Push by default (unless --no-push is specified)
        no_push = getattr(args, 'no_push', False)
        if ok_commit and not no_push:
            branch = _current_branch()
            if branch:
                ok_push, out_push = run(["git", "push", "origin", branch], timeout=70)
                commit_info['push'] = {"pushed": ok_push, "output": out_push[-400:] if out_push else ""}
                
                # Merge into main after successful push (unless --no-merge is specified)
                no_merge = getattr(args, 'no_merge', False)
                if ok_push and not no_merge and branch != "main":
                    # Switch to main
                    ok_switch, out_switch = run(["git", "checkout", "main"], timeout=30)
                    if ok_switch:
                        # Pull latest changes
                        ok_pull, out_pull = run(["git", "pull", "origin", "main"], timeout=60)
                        if ok_pull:
                            # Merge feature branch
                            merge_msg = f"Merge branch '{branch}' into main - {feature_id}"
                            ok_merge, out_merge = run(["git", "merge", branch, "-m", merge_msg], timeout=60)
                            if ok_merge:
                                # Push the merged changes to main
                                ok_push_main, out_push_main = run(["git", "push", "origin", "main"], timeout=70)
                                if ok_push_main:
                                    # Delete the merged feature branch
                                    run(["git", "branch", "-d", branch], timeout=30)
                                    run(["git", "push", "origin", "--delete", branch], timeout=60)
                                commit_info['merge'] = {
                                    "attempted": True,
                                    "switched_to_main": ok_switch,
                                    "pulled_main": ok_pull,
                                    "merged": ok_merge,
                                    "pushed_main": ok_push_main,
                                    "branch_deleted": ok_push_main,  # Only delete if push to main succeeded
                                    "merge_message": merge_msg,
                                    "output": f"Switch: {out_switch[-200:] if out_switch else ''}\nPull: {out_pull[-200:] if out_pull else ''}\nMerge: {out_merge[-200:] if out_merge else ''}\nPush: {out_push_main[-200:] if out_push_main else ''}"
                                }
                            else:
                                commit_info['merge'] = {"attempted": True, "merged": False, "error": "merge_failed", "output": out_merge[-400:] if out_merge else ""}
                        else:
                            commit_info['merge'] = {"attempted": True, "merged": False, "error": "pull_failed", "output": out_pull[-400:] if out_pull else ""}
                    else:
                        commit_info['merge'] = {"attempted": True, "merged": False, "error": "switch_failed", "output": out_switch[-400:] if out_switch else ""}
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
    # finalize-feature options reuse --feature-id, --dry-run, --skip-tests, plus new merge control options
    p.add_argument("--no-push", action="store_true", help="Skip pushing branch changes (finalize-feature only)")
    p.add_argument("--no-merge", action="store_true", help="Skip merging into main after push (finalize-feature only)")
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
