#!/usr/bin/env python3
"""Patch Coverage Calculator

Computes coverage percentage for only the changed (added/modified) lines in the
current working tree relative to a base (default: origin/main or main).

Features:
 - Parses git unified diff (or a provided diff file) to collect added line numbers.
 - Parses LCOV file (coverage/lcov.info) to know which lines executed.
 - Outputs JSON (default) with:
   {
     "changed_files": <int>,
     "changed_lines": <int>,
     "covered_lines": <int>,
     "patch_coverage_pct": <float>,
     "threshold": <float>,
     "below_threshold": <bool>,
     "files": [ {"file": path, "changed": n, "covered": m, "pct": x } ... ]
   }
 - Exit code 0 if coverage >= threshold OR no changed lines; 1 otherwise.

Assumptions:
 - Only counts added lines (not removed) as needing coverage.
 - Treats empty diff (no changes) as 100%.
 - Accepts optional --threshold (default 85).
 - Accepts optional --diff-file to decouple from git (used in tests).

Usage examples:
  python scripts/patch_coverage.py --threshold 85
  python scripts/patch_coverage.py --base origin/main --threshold 90
  python scripts/patch_coverage.py --diff-file tmp.diff --lcov custom.info
"""
from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
from pathlib import Path
from typing import Dict, List, Set, Tuple

ROOT = Path(__file__).resolve().parent.parent
DEFAULT_LCOV = ROOT / "coverage" / "lcov.info"

HUNK_RE = re.compile(r"^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@")

def run(cmd: List[str], cwd: Path = ROOT, timeout: int = 60) -> Tuple[bool, str]:
    try:
        proc = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, timeout=timeout)
        return proc.returncode == 0, proc.stdout
    except Exception as e:  # pragma: no cover
        return False, str(e)


def parse_diff(diff_text: str) -> Dict[str, Set[int]]:
    files: Dict[str, Set[int]] = {}
    current: str | None = None
    new_line_no: int | None = None
    for line in diff_text.splitlines():
        if line.startswith("diff --git "):
            current = None
            continue
        if line.startswith("+++ b/"):
            current = line[6:].strip()
            if current == "/dev/null":  # deleted file
                current = None
            else:
                files.setdefault(current, set())
            continue
        if line.startswith("@@"):
            m = HUNK_RE.match(line)
            if not m:
                new_line_no = None
                continue
            start = int(m.group(1))
            length = int(m.group(2) or 1)
            new_line_no = start
            # length used implicitly by counting additions
            continue
        if current is None:
            continue
        if new_line_no is None:
            continue
        if line.startswith("+") and not line.startswith("+++"):
            files[current].add(new_line_no)
            new_line_no += 1
        elif line.startswith("-") and not line.startswith("---"):
            # removed line, do not advance new_line_no (since it belongs to old file)
            continue
        else:
            # context line
            new_line_no += 1
    return files


def parse_lcov(path: Path) -> Dict[str, Set[int]]:
    covered: Dict[str, Set[int]] = {}
    if not path.exists():
        return covered
    current: str | None = None
    for raw in path.read_text(encoding="utf-8", errors="ignore").splitlines():
        if raw.startswith("SF:"):
            current = raw[3:].strip()
            covered.setdefault(current, set())
        elif raw.startswith("DA:") and current:
            try:
                ln_s, hits_s = raw[3:].split(",")
                ln = int(ln_s)
                hits = int(hits_s)
                if hits > 0:
                    covered[current].add(ln)
            except ValueError:  # pragma: no cover
                pass
        elif raw.startswith("end_of_record"):
            current = None
    return covered


def map_file_to_lcov_hits(file_path: str, lcov_hits: Dict[str, Set[int]]) -> Set[int]:
    # Exact match first
    if file_path in lcov_hits:
        return lcov_hits[file_path]
    # Suffix match fallback
    for full, lines in lcov_hits.items():
        if full.endswith(file_path):
            return lines
    return set()


def compute_patch_coverage(diff_map: Dict[str, Set[int]], lcov_hits: Dict[str, Set[int]]) -> Dict:
    file_results = []
    total_changed = 0
    total_covered = 0
    for f, changed_lines in diff_map.items():
        if not changed_lines:
            continue
        hits = map_file_to_lcov_hits(f, lcov_hits)
        covered = len([l for l in changed_lines if l in hits])
        file_results.append({
            "file": f,
            "changed": len(changed_lines),
            "covered": covered,
            "pct": (covered / len(changed_lines) * 100.0) if changed_lines else 100.0
        })
        total_changed += len(changed_lines)
        total_covered += covered
    pct = (total_covered / total_changed * 100.0) if total_changed else 100.0
    file_results.sort(key=lambda x: x["file"])
    return {
        "changed_files": len(file_results),
        "changed_lines": total_changed,
        "covered_lines": total_covered,
        "patch_coverage_pct": pct,
        "files": file_results,
    }


def load_diff(base: str, diff_file: str | None) -> str:
    if diff_file:
        return Path(diff_file).read_text(encoding="utf-8")
    # Attempt origin/<base> first
    candidates = [f"origin/{base}", base]
    for cand in candidates:
        ok, out = run(["git", "diff", "--unified=0", cand])
        if ok:
            return out
    # Fallback: staged vs working tree
    ok, out = run(["git", "diff", "--unified=0"])
    return out if ok else ""


def main(argv: List[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="Patch coverage calculator")
    ap.add_argument("--base", default="main", help="Base branch to diff against (default: main)")
    ap.add_argument("--lcov", default=str(DEFAULT_LCOV), help="Path to lcov.info")
    ap.add_argument("--threshold", type=float, default=float(os.environ.get("PATCH_COVERAGE_MIN", "85")))
    ap.add_argument("--diff-file", help="Path to a pre-generated unified diff (testing)")
    ap.add_argument("--json", action="store_true", help="Force JSON output (default always JSON)")
    args = ap.parse_args(argv)

    diff_text = load_diff(args.base, args.diff_file)
    diff_map = parse_diff(diff_text)
    lcov_hits = parse_lcov(Path(args.lcov))
    result = compute_patch_coverage(diff_map, lcov_hits)
    result["threshold"] = args.threshold
    result["below_threshold"] = result["patch_coverage_pct"] < args.threshold and result["changed_lines"] > 0

    print(json.dumps(result, indent=2))
    return 1 if result["below_threshold"] else 0

if __name__ == "__main__":  # pragma: no cover
    raise SystemExit(main())
