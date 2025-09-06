#!/usr/bin/env python3
"""Generate a minimal SBOM (CycloneDX JSON) for Dart/Flutter dependencies.

NOTE: This is a lightweight, offline-friendly approximation. For a full SBOM,
consider using tools like cyclone-dx npm module or anchore/syft in CI.

Current approach:
  * Parse `pubspec.lock` for direct + transitive package names & versions.
  * Emit CycloneDX 1.5 JSON with minimal fields.
  * Optionally include a hash of the lock file for integrity.

Limitations:
  * Does not resolve licenses (separate license_check handles policy).
  * No component purl generation for hosted vs git packages (future work).
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LOCK = ROOT / 'pubspec.lock'
OUT = ROOT / 'build' / 'sbom.cdx.json'


def parse_lock(lock_text: str):
    packages = {}
    name = None
    version = None
    for line in lock_text.splitlines():
        m = re.match(r'^  ([A-Za-z0-9_\-]+):$', line)
        if m:
            if name and version:
                packages[name] = version
            name = m.group(1)
            version = None
            continue
        vm = re.match(r'^    version: "?([^"\n]+)"?$', line)
        if vm and name:
            version = vm.group(1)
    if name and version:
        packages[name] = version
    # remove non-package keys
    packages.pop('packages', None)
    packages.pop('sdks', None)
    return packages


def build_cyclonedx(packages: dict, lock_hash: str):
    components = []
    for name, ver in sorted(packages.items()):
        components.append({
            'type': 'library',
            'name': name,
            'version': ver,
            'bom-ref': f'pkg:dart/{name}@{ver}',
        })
    return {
        'bomFormat': 'CycloneDX',
        'specVersion': '1.5',
        'version': 1,
        'metadata': {
            'timestamp': datetime.now(timezone.utc).isoformat(),
            'tools': [{'vendor': 'ashtrail', 'name': 'sbom_generate.py', 'version': '0.1.0'}],
            'component': {'type': 'application', 'name': 'ash_trail'},
        },
        'components': components,
        'properties': [
            {'name': 'pubspec.lock.sha256', 'value': lock_hash},
        ],
    }


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description='Generate minimal CycloneDX SBOM for Dart dependencies')
    ap.add_argument('--out', help='Output file (default build/sbom.cdx.json)')
    args = ap.parse_args(argv)

    if not LOCK.exists():
        print('pubspec.lock missing', file=sys.stderr)
        return 1
    lock_text = LOCK.read_text(encoding='utf-8')
    pkgs = parse_lock(lock_text)
    lock_hash = hashlib.sha256(lock_text.encode()).hexdigest()
    sbom = build_cyclonedx(pkgs, lock_hash)
    out_path = Path(args.out) if args.out else OUT
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(sbom, indent=2) + '\n', encoding='utf-8')
    print(f'SBOM written {out_path} (packages={len(pkgs)})')
    return 0


if __name__ == '__main__':  # pragma: no cover
    raise SystemExit(main())
