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

def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(description="AshTrail Dev Assistant")
    p.add_argument("command", choices=COMMANDS.keys())
    p.add_argument("--json", action="store_true", help="JSON output")
    p.add_argument("--limit", type=int, default=10)
    p.add_argument("--upload", action="store_true", help="Upload coverage in dev-cycle")
    p.add_argument("--skip-tests", action="store_true", help="Skip running tests in dev-cycle (used for fast manifest generation / tests)")
    p.add_argument("--log-file", help="Append structured JSONL log to file")
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
