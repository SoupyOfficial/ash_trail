#!/usr/bin/env python3
"""
Documentation Validation Script for AshTrail
Validates documentation files against defined standards.

Usage:
    python validate_docs.py [options]
    
Options:
    --fix          Attempt to auto-fix issues where possible
    --verbose      Show detailed output
    --rules        Comma-separated list of rules to run (default: all)
    --exclude      Comma-separated list of files to exclude
    
Exit Codes:
    0 - All validations passed
    1 - Validation failures found
    2 - Script error
"""

import re
import sys
from pathlib import Path
from dataclasses import dataclass
from typing import List, Tuple, Optional
from collections import defaultdict
import argparse


@dataclass
class ValidationIssue:
    """Represents a validation issue found in a document."""
    file: str
    line: int
    rule: str
    severity: str  # 'error', 'warning', 'info'
    message: str
    suggestion: Optional[str] = None


class DocumentValidator:
    """Main validator class that runs all validation rules."""
    
    def __init__(self, docs_path: Path, verbose: bool = False):
        self.docs_path = docs_path
        self.verbose = verbose
        self.issues: List[ValidationIssue] = []
        
    def log(self, message: str):
        """Log message if verbose mode is enabled."""
        if self.verbose:
            print(f"[INFO] {message}")
    
    def add_issue(self, issue: ValidationIssue):
        """Add a validation issue to the list."""
        self.issues.append(issue)
    
    def validate_all(self, rules: List[str], exclude: List[str]) -> List[ValidationIssue]:
        """Run all validation rules on all documentation files."""
        self.issues = []
        
        # Get all markdown files in the plan directory
        md_files = sorted(self.docs_path.glob("*.md"))
        
        # Add default exclusions (hidden files like macOS ._* files)
        default_excludes = ['combined.md', r'\._.*']
        all_excludes = default_excludes + exclude
        
        # Filter out excluded files
        exclude_patterns = [re.compile(pattern) for pattern in all_excludes]
        md_files = [
            f for f in md_files 
            if not any(pattern.search(f.name) for pattern in exclude_patterns)
        ]
        
        self.log(f"Found {len(md_files)} documentation files to validate")
        
        for md_file in md_files:
            self.log(f"Validating {md_file.name}")
            self._validate_file(md_file, rules)
        
        return self.issues
    
    def _validate_file(self, file_path: Path, rules: List[str]):
        """Validate a single file against all applicable rules."""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()
        except UnicodeDecodeError:
            # Try with a different encoding if UTF-8 fails
            try:
                with open(file_path, 'r', encoding='latin-1') as f:
                    lines = f.readlines()
            except Exception as e:
                self.add_issue(ValidationIssue(
                    file=file_path.name,
                    line=1,
                    rule='encoding',
                    severity='error',
                    message=f'Unable to read file: {e}',
                    suggestion='Ensure file is saved with UTF-8 encoding'
                ))
                return
        
        # Extract document number from filename (e.g., "1. Project Overview.md" -> 1)
        doc_num_match = re.match(r'^(\d+)\.', file_path.name)
        doc_num = int(doc_num_match.group(1)) if doc_num_match else None
        
        # Run each requested rule
        if 'heading-depth' in rules:
            self._check_heading_depth(file_path, lines)
        
        if 'section-numbering' in rules and doc_num is not None:
            self._check_section_numbering(file_path, lines, doc_num)
        
        if 'standard-sections' in rules:
            self._check_standard_sections(file_path, lines)
        
        if 'table-formatting' in rules:
            self._check_table_formatting(file_path, lines)
        
        if 'trailing-whitespace' in rules:
            self._check_trailing_whitespace(file_path, lines)
    
    def _check_heading_depth(self, file_path: Path, lines: List[str]):
        """Rule: Headings should not exceed depth H4 (####)."""
        for line_num, line in enumerate(lines, 1):
            # Check for H5 or deeper (5+ #'s)
            if match := re.match(r'^(#{5,})\s', line):
                heading_level = len(match.group(1))
                self.add_issue(ValidationIssue(
                    file=file_path.name,
                    line=line_num,
                    rule='heading-depth',
                    severity='error',
                    message=f'Heading depth H{heading_level} exceeds maximum of H4',
                    suggestion='Convert to H4 (####) or use bold text for subsections'
                ))
    
    def _check_section_numbering(self, file_path: Path, lines: List[str], doc_num: int):
        """Rule: Section numbers should follow X.Y.Z format with document number prefix."""
        # Pattern for H3 sections (### X.Y Title)
        h3_pattern = re.compile(r'^###\s+(\d+)\.(\d+)(?:\.(\d+))?\s+(.+)$')
        # Pattern for H4 sections (#### X.Y.Z Title)
        h4_pattern = re.compile(r'^####\s+(\d+)\.(\d+)\.(\d+)(?:\.(\d+))?\s+(.+)$')
        
        for line_num, line in enumerate(lines, 1):
            # Skip the document title (##)
            if line.startswith('## '):
                continue
            
            # Check H3 sections
            if line.startswith('### '):
                if match := h3_pattern.match(line):
                    prefix = int(match.group(1))
                    if prefix != doc_num:
                        self.add_issue(ValidationIssue(
                            file=file_path.name,
                            line=line_num,
                            rule='section-numbering',
                            severity='error',
                            message=f'Section number {prefix} does not match document number {doc_num}',
                            suggestion=f'Use {doc_num}.{match.group(2)} format'
                        ))
                else:
                    # H3 but doesn't match expected format
                    if not re.match(r'^###\s+\d+', line):  # Allow non-numbered sections
                        continue
                    self.add_issue(ValidationIssue(
                        file=file_path.name,
                        line=line_num,
                        rule='section-numbering',
                        severity='warning',
                        message='H3 section does not follow X.Y numbering format',
                        suggestion=f'Use format: ### {doc_num}.Y Title'
                    ))
            
            # Check H4 sections
            elif line.startswith('#### '):
                if match := h4_pattern.match(line):
                    prefix = int(match.group(1))
                    if prefix != doc_num:
                        self.add_issue(ValidationIssue(
                            file=file_path.name,
                            line=line_num,
                            rule='section-numbering',
                            severity='error',
                            message=f'Section number {prefix} does not match document number {doc_num}',
                            suggestion=f'Use {doc_num}.{match.group(2)}.{match.group(3)} format'
                        ))
    
    def _check_standard_sections(self, file_path: Path, lines: List[str]):
        """Rule: Documents should have standard sections where applicable."""
        content = ''.join(lines).lower()
        
        # Check for common standard sections
        expected_sections = {
            'overview': r'###\s+.*overview',
            'responsibilities': r'###\s+.*responsibilities',
            'assumptions': r'(###|####)\s+.*(assumptions|open questions)',
        }
        
        missing = []
        for section_name, pattern in expected_sections.items():
            if not re.search(pattern, content, re.IGNORECASE):
                missing.append(section_name)
        
        if missing:
            self.add_issue(ValidationIssue(
                file=file_path.name,
                line=1,
                rule='standard-sections',
                severity='info',
                message=f'Document may be missing standard sections: {", ".join(missing)}',
                suggestion='Consider adding these sections if applicable'
            ))
    
    def _check_table_formatting(self, file_path: Path, lines: List[str]):
        """Rule: Table separators should use consistent formatting."""
        in_table = False
        separator_style = None  # Will be 'single' or 'multiple'
        
        for line_num, line in enumerate(lines, 1):
            # Detect table separator line (|---|---|)
            if re.match(r'^\s*\|[\s\-:]+\|\s*$', line):
                # Determine style: single dash vs multiple dashes
                if re.match(r'^\s*\|[\s\-:]{1,3}\|', line):
                    current_style = 'single'
                else:
                    current_style = 'multiple'
                
                # Track first style found
                if separator_style is None:
                    separator_style = current_style
                elif separator_style != current_style:
                    self.add_issue(ValidationIssue(
                        file=file_path.name,
                        line=line_num,
                        rule='table-formatting',
                        severity='warning',
                        message='Inconsistent table separator formatting within document',
                        suggestion='Use consistent single-dash (|---|) or multi-dash (|-----|) format throughout'
                    ))
    
    def _check_trailing_whitespace(self, file_path: Path, lines: List[str]):
        """Rule: Lines should not have trailing whitespace."""
        for line_num, line in enumerate(lines, 1):
            if line.rstrip('\n') != line.rstrip():
                self.add_issue(ValidationIssue(
                    file=file_path.name,
                    line=line_num,
                    rule='trailing-whitespace',
                    severity='info',
                    message='Line has trailing whitespace',
                    suggestion='Remove trailing spaces'
                ))
    
    def print_report(self):
        """Print validation report to console."""
        if not self.issues:
            print("✅ All validation checks passed!")
            return
        
        # Group issues by file
        issues_by_file = defaultdict(list)
        for issue in self.issues:
            issues_by_file[issue.file].append(issue)
        
        # Count by severity
        errors = sum(1 for i in self.issues if i.severity == 'error')
        warnings = sum(1 for i in self.issues if i.severity == 'warning')
        infos = sum(1 for i in self.issues if i.severity == 'info')
        
        print(f"\n❌ Found {len(self.issues)} issue(s)")
        print(f"   Errors: {errors}, Warnings: {warnings}, Info: {infos}\n")
        
        # Print issues grouped by file
        for file_name in sorted(issues_by_file.keys()):
            print(f"\n📄 {file_name}")
            print("─" * 80)
            
            for issue in issues_by_file[file_name]:
                severity_icon = {
                    'error': '🔴',
                    'warning': '🟡',
                    'info': '🔵'
                }.get(issue.severity, '⚪')
                
                print(f"  {severity_icon} Line {issue.line}: [{issue.rule}] {issue.message}")
                if issue.suggestion:
                    print(f"     💡 {issue.suggestion}")
        
        print("\n" + "─" * 80)
        print(f"\n📊 Summary: {errors} errors, {warnings} warnings, {infos} info")


def main():
    """Main entry point for the validation script."""
    parser = argparse.ArgumentParser(
        description='Validate AshTrail documentation against defined standards'
    )
    parser.add_argument(
        '--verbose', '-v',
        action='store_true',
        help='Show detailed output during validation'
    )
    parser.add_argument(
        '--rules',
        type=str,
        default='all',
        help='Comma-separated list of rules to run (default: all)'
    )
    parser.add_argument(
        '--exclude',
        type=str,
        default='combined.md',
        help='Comma-separated list of file patterns to exclude'
    )
    parser.add_argument(
        '--path',
        type=str,
        default=None,
        help='Path to docs/plan directory (default: auto-detect)'
    )
    
    args = parser.parse_args()
    
    # Determine docs path
    if args.path:
        docs_path = Path(args.path)
    else:
        # Auto-detect: assume script is in docs/plan-review/
        script_dir = Path(__file__).parent
        docs_path = script_dir.parent / 'plan'
    
    if not docs_path.exists():
        print(f"❌ Error: Documentation path not found: {docs_path}", file=sys.stderr)
        return 2
    
    # Parse rules
    if args.rules == 'all':
        rules = [
            'heading-depth',
            'section-numbering',
            'standard-sections',
            'table-formatting',
            'trailing-whitespace'
        ]
    else:
        rules = [r.strip() for r in args.rules.split(',')]
    
    # Parse exclude patterns
    exclude = [p.strip() for p in args.exclude.split(',') if p.strip()]
    
    # Run validation
    validator = DocumentValidator(docs_path, verbose=args.verbose)
    
    print(f"🔍 Validating documentation in: {docs_path}")
    print(f"📋 Running rules: {', '.join(rules)}")
    default_excludes = ['combined.md', 'hidden files (._*)']
    all_excludes = default_excludes + exclude if exclude else default_excludes
    print(f"🚫 Excluding: {', '.join(all_excludes)}")
    print()
    
    try:
        validator.validate_all(rules, exclude)
        validator.print_report()
        
        # Return appropriate exit code
        has_errors = any(i.severity == 'error' for i in validator.issues)
        return 1 if has_errors else 0
        
    except Exception as e:
        print(f"❌ Script error: {e}", file=sys.stderr)
        if args.verbose:
            import traceback
            traceback.print_exc()
        return 2


if __name__ == '__main__':
    sys.exit(main())
