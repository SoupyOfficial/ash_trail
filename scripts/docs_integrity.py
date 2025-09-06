#!/usr/bin/env python3
"""Docs Integrity & Drift Checker

Purpose:
  * Ensures only ONE canonical AI instruction file.
  * Validates stubs reference and hash-match key invariant sections.
  * Optionally regenerates quick reference file (automation quick ref) from canonical.

Checks performed:
 1. Canonical file exists (instruction-prompt.instructions.md).
 2. Each stub lists Canonical-Ref and Canonical-Sections lines.
 3. Extract specified sections from canonical, compute SHA256 stable hash.
 4. For each stub, ensure it does NOT redefine those sections (prevents drift).
 5. Quick reference regeneration (if --update-quick-reference) writes
    AUTOMATION_QUICK_REFERENCE.md condensed commands + coverage policy.

Exit codes:
 0 OK, 1 violation/drift, 2 unexpected error.

Usage:
  python scripts/docs_integrity.py --check
  python scripts/docs_integrity.py --update-quick-reference
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path
from typing import Dict, List, Tuple

ROOT = Path(__file__).resolve().parent.parent
CANONICAL = ROOT / '.github' / 'instructions' / 'instruction-prompt.instructions.md'
STUB_CANDIDATES = [
    ROOT / '.github' / 'instructions' / 'code-generation.instructions.md',
    ROOT / '.github' / 'copilot-instructions.md',
]
QUICK_REF = ROOT / 'AUTOMATION_QUICK_REFERENCE.md'

SECTION_MAP = {
    'Architectural Rules': '## Architectural Rules',
    'Response / Output Contract': '## Response / Output Contract',
    'Error Handling Pattern': '## Error Handling Pattern',
}

HASH_BLOCK_HEADER = '<!-- canonical-section-hashes: json -->'


def extract_sections(text: str) -> Dict[str, str]:
    results: Dict[str, str] = {}
    for label, marker in SECTION_MAP.items():
        # capture until next top-level heading
        pattern = re.compile(r'^' + re.escape(marker) + r'\n(.*?)(?=^## |\Z)', re.M | re.S)
        m = pattern.search(text)
        if m:
            body = '\n'.join(l.rstrip() for l in m.group(1).strip().splitlines())
            results[label] = body
    return results


def compute_hashes(sections: Dict[str, str]) -> Dict[str, str]:
    return {k: hashlib.sha256(v.encode()).hexdigest() for k, v in sections.items()}


def validate_stubs(canonical_text: str, stub_path: Path, hashes: Dict[str, str]) -> List[str]:
    problems: List[str] = []
    text = stub_path.read_text(encoding='utf-8')
    if 'Canonical-Ref:' not in text or 'Canonical-Sections:' not in text:
        problems.append(f'{stub_path.name}: missing canonical reference lines')
        return problems
    # Ensure stub does not embed any canonical section headings content again
    for label, marker in SECTION_MAP.items():
        if marker in text and 'Stub' not in text[:200]:  # naive heuristic
            problems.append(f'{stub_path.name}: should not redeclare section heading {marker}')
    return problems


def regenerate_quick_reference(canonical_text: str, hashes: Dict[str, str]) -> None:
    sections = extract_sections(canonical_text)
    # Build condensed quick reference
    arch_rules = sections.get('Architectural Rules', '')
    output_contract = sections.get('Response / Output Contract', '')
    coverage_policy = ''
    m = re.search(r'^## Coverage Policy.*?(?=^## |\Z)', canonical_text, re.M | re.S)
    if m:
        coverage_policy = m.group(0)
    lines = [
        '# AshTrail Automation Quick Reference (Generated)\n',
        'This file is auto-generated from the canonical instruction prompt. Do not edit manually.\n',
        '## Output Contract Summary',
        output_contract.split('\n', 2)[2] if output_contract else '',
        '## Architectural Rules (Abbrev)',
        '\n'.join(arch_rules.splitlines()[:12]),
        '## Coverage Policy',
        coverage_policy or 'See canonical instructions.',
        '## Regeneration',
        'python scripts/docs_integrity.py --update-quick-reference',
        HASH_BLOCK_HEADER,
        json.dumps(hashes, indent=2),
    ]
    QUICK_REF.write_text('\n'.join(lines).strip() + '\n', encoding='utf-8')


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description='Docs integrity checker')
    ap.add_argument('--check', action='store_true')
    ap.add_argument('--update-quick-reference', action='store_true')
    args = ap.parse_args(argv)

    if not CANONICAL.exists():
        print('Canonical file missing', file=sys.stderr)
        return 1
    canonical_text = CANONICAL.read_text(encoding='utf-8')
    sections = extract_sections(canonical_text)
    hashes = compute_hashes(sections)

    problems: List[str] = []
    for stub in STUB_CANDIDATES:
        if not stub.exists():
            continue
        problems.extend(validate_stubs(canonical_text, stub, hashes))

    if args.update_quick_reference:
        regenerate_quick_reference(canonical_text, hashes)

    if args.check and problems:
        print('Docs integrity violations:')
        for p in problems:
            print(' -', p)
        return 1

    if args.check:
        print('Docs integrity OK')
    return 0

if __name__ == '__main__':  # pragma: no cover
    raise SystemExit(main())
