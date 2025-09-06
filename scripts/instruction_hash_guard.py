#!/usr/bin/env python3
"""Instruction Hash Guard

Purpose:
  Computes a stable SHA256 hash of the canonical AI instruction file and optionally
  compares it to a provided expected value (e.g., recorded in CI or a PR label/comment).

Use cases:
  * CI step: detect undocumented changes to canonical instructions.
  * Developer pre-flight: record new hash after intentional update.

Exit codes:
  0 OK / match
  1 Mismatch or file missing
  2 Unexpected error

Example:
  python scripts/instruction_hash_guard.py --print
  python scripts/instruction_hash_guard.py --expect <hash>
"""
from __future__ import annotations

import argparse
import hashlib
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CANONICAL = ROOT / '.github' / 'instructions' / 'instruction-prompt.instructions.md'


def compute_hash(path: Path) -> str:
    data = path.read_bytes()
    return hashlib.sha256(data).hexdigest()


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description='Canonical instruction hash guard')
    ap.add_argument('--expect', help='Expected SHA256 hash to compare')
    ap.add_argument('--print', action='store_true', help='Print the computed hash')
    args = ap.parse_args(argv)

    if not CANONICAL.exists():
        print('Canonical instruction file missing', file=sys.stderr)
        return 1
    try:
        h = compute_hash(CANONICAL)
    except Exception as e:  # pragma: no cover - defensive
        print(f'Error computing hash: {e}', file=sys.stderr)
        return 2

    if args.print:
        print(h)

    if args.expect and args.expect != h:
        print('Hash mismatch:')
        print(' expected:', args.expect)
        print(' actual  :', h)
        return 1

    return 0


if __name__ == '__main__':  # pragma: no cover
    raise SystemExit(main())
