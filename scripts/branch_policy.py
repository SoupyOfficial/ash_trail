#!/usr/bin/env python3
"""Branch Policy Enforcement

Enforces linear stacked feature branch workflow:
- Feature branches must follow naming pattern: feat/<seq>-<slug>
  * <seq> is zero-padded integer (e.g., 001, 002, 010)
  * <slug> is lowercase words/dashes
- Each new feature branch N (> first) must be based on (have as ancestor) the head
  commit of feature branch N-1.
- Main (or master) branch may not receive direct commits for new feature work.

Exit Codes:
 0 success / compliant
 1 policy violation (message emitted)
 2 unexpected internal error

Flags / Environment:
  --allow-main   Allow running on main without failing (used for CI after merges)
  DEV_BRANCH_POLICY_SKIP=1  Skip all checks (escape hatch for emergency builds)

Assumptions:
 * Local git repository available.
 * Python script run from anywhere inside repo.
"""
from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys
from pathlib import Path
from typing import List, Tuple

ROOT = Path(os.environ.get("BRANCH_POLICY_REPO_ROOT", Path(__file__).resolve().parent.parent))
PATTERN = re.compile(r"^feat/(\d{3,})-([a-z0-9\-]+)$")


def run(cmd: List[str]) -> Tuple[int, str]:
    try:
        p = subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True, timeout=30)
        return p.returncode, (p.stdout.strip() + ("\n" + p.stderr.strip() if p.stderr.strip() else "")).strip()
    except Exception as e:  # pragma: no cover
        return 99, str(e)


def current_branch() -> str:
    code, out = run(["git", "rev-parse", "--abbrev-ref", "HEAD"])
    if code != 0:
        return "unknown"
    return out


def list_feature_branches() -> List[str]:
    code, out = run(["git", "for-each-ref", "--format=%(refname:short)", "refs/heads/feat/"])
    if code != 0 or not out:
        return []
    return [l.strip() for l in out.splitlines() if l.strip()]


def get_head_commit(branch: str) -> str | None:
    code, out = run(["git", "rev-parse", branch])
    return out if code == 0 else None


def is_ancestor(ancestor: str, descendant: str) -> bool:
    code, _ = run(["git", "merge-base", "--is-ancestor", ancestor, descendant])
    return code == 0


def enforce(args) -> int:
    if os.environ.get("DEV_BRANCH_POLICY_SKIP") == "1":
        return 0

    branch = current_branch()
    if branch in {"main", "master"}:
        if args.allow_main:
            return 0
        # Allow being on main only if no feat branches exist yet
        feats = list_feature_branches()
        if feats:
            print("Branch policy violation: work must occur on sequential feat/<seq>-<slug> branch, not on main.")
            return 1
        return 0

    m = PATTERN.match(branch)
    if not m:
        print(f"Branch policy violation: '{branch}' does not match required pattern feat/###-slug (e.g., feat/001-initial-setup)")
        return 1

    seq = int(m.group(1))
    if seq == 0:
        print("Branch policy violation: sequence must start at 001")
        return 1

    feature_branches = list_feature_branches()
    # Build mapping seq -> branch
    seq_map = {}
    for b in feature_branches:
        mm = PATTERN.match(b)
        if not mm:
            continue
        s = int(mm.group(1))
        if s in seq_map and seq_map[s] != b:
            print(f"Branch policy violation: multiple branches share sequence {s}: {seq_map[s]}, {b}")
            return 1
        seq_map[s] = b

    # Ensure no gaps up to current sequence
    missing = [i for i in range(1, seq) if i not in seq_map]
    if missing:
        first_missing = missing[0]
        print(f"Branch policy violation: missing previous sequence feat/{first_missing:03d}-<slug> before {branch}; gap(s): {', '.join(f'{m:03d}' for m in missing)}")
        return 1

    if seq > 1:
        prev_branch = seq_map.get(seq - 1)
        if not prev_branch:
            print(f"Branch policy violation: previous branch feat/{seq-1:03d}-<slug> not found")
            return 1
        prev_head = get_head_commit(prev_branch)
        if not prev_head:
            print(f"Branch policy violation: could not resolve head of {prev_branch}")
            return 1
        if not is_ancestor(prev_branch, branch):
            print(f"Branch policy violation: {prev_branch} is not an ancestor of {branch}; new feature branches must be created from the immediate prior feature branch head.")
            return 1

    # Enforce monotonically increasing (if a higher sequence exists, cannot work on lower sequence except continuing it)
    higher = [s for s in seq_map if s > seq]
    if higher:
        print(f"Branch policy violation: higher sequence branches {sorted(higher)} exist; cannot commit on older sequence {seq:03d} except for finishing previous review.")
        return 1

    return 0


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description="Enforce linear feature branch policy")
    ap.add_argument("--allow-main", action="store_true", help="Allow main branch (CI merges)")
    args = ap.parse_args(argv)
    try:
        return enforce(args)
    except Exception as e:  # pragma: no cover
        print(f"Branch policy internal error: {e}")
        return 2

if __name__ == "__main__":  # pragma: no cover
    raise SystemExit(main())
