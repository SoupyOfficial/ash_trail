#!/usr/bin/env python3
"""Simple License Check for Dart (pubspec) Dependencies

Strategy:
  1. Run `dart pub deps --json` (or `flutter pub deps --json`) externally and pipe to file OR
     rely on existing `pubspec.lock` for a quick parse.
  2. Extract package names; (Optional) future enhancement: invoke `pub.dev` API to fetch license.
  3. Currently we implement a lightweight allowlist approach using a static set of permissive licenses.

NOTE: Full license resolution requires network calls (fetching package metadata). To keep CI deterministic
and offline-friendly we accept a curated mapping file when needed.

Exit codes:
  0 success / all allowed
  1 disallowed or unknown license encountered (strict mode only)
  2 unexpected error

Enhancement backlog (not implemented yet):
  * Optional `--update-cache` to populate a JSON cache of package->license
  * Support SPDX expression parsing and policy evaluation
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Dict, List

ROOT = Path(__file__).resolve().parent.parent
LOCK = ROOT / 'pubspec.lock'
LICENSE_CACHE = ROOT / 'tool' / 'license_cache.json'

ALLOWED = {
    'MIT', 'BSD-2-Clause', 'BSD-3-Clause', 'Apache-2.0', 'Apache 2.0', 'Apache License 2.0',
    'ISC', 'Zlib', 'MPL-2.0'
}


def parse_lock_packages(text: str) -> List[str]:
    pkgs = []
    current = None
    for line in text.splitlines():
        if re.match(r'^ {2}[A-Za-z0-9_\-]+:', line):
            name = line.strip().rstrip(':')
            current = name
            pkgs.append(name)
    # remove root sections like packages: etc.
    return [p for p in pkgs if p not in {'packages', 'sdks'}]


def load_license_cache() -> Dict[str, str]:
    if LICENSE_CACHE.exists():
        try:
            return json.loads(LICENSE_CACHE.read_text(encoding='utf-8'))
        except Exception:  # pragma: no cover
            return {}
    return {}


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description='Lightweight Dart dependency license check')
    ap.add_argument('--strict', action='store_true', help='Fail if any dependency license is unknown')
    args = ap.parse_args(argv)

    if not LOCK.exists():
        print('pubspec.lock not found', file=sys.stderr)
        return 1
    lock_text = LOCK.read_text(encoding='utf-8')
    packages = sorted(set(parse_lock_packages(lock_text)))
    cache = load_license_cache()

    unknown: List[str] = []
    disallowed: List[str] = []
    for pkg in packages:
        lic = cache.get(pkg)
        if lic is None:
            unknown.append(pkg)
        elif lic not in ALLOWED:
            disallowed.append(f'{pkg} ({lic})')

    if disallowed:
        print('Disallowed licenses detected:')
        for d in disallowed:
            print(' -', d)
        return 1

    if args.strict and unknown:
        print('Unknown licenses (strict mode):')
        for u in unknown:
            print(' -', u)
        return 1

    print(f'License check OK. Known={len(packages)-len(unknown)} Unknown={len(unknown)} Disallowed=0')
    if unknown:
        print('Hint: add entries to tool/license_cache.json: {"package":"MIT"}')
    return 0


if __name__ == '__main__':  # pragma: no cover
    raise SystemExit(main())
