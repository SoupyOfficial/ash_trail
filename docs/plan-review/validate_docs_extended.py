#!/usr/bin/env python3
"""
Extended Documentation Validator
Checks for content quality, consistency, and completeness beyond basic formatting.
"""

import re
import sys
from pathlib import Path
from dataclasses import dataclass
from typing import List, Dict, Set, Optional
from collections import defaultdict

@dataclass
class ValidationIssue:
    """Represents a validation issue found in documentation."""
    file: str
    line: int
    rule: str
    severity: str  # 'error', 'warning', 'info'
    message: str
    suggestion: str

class ExtendedDocumentValidator:
    """Extended validator for documentation quality and consistency."""
    
    def __init__(self, docs_path: Path, verbose: bool = False):
        self.docs_path = docs_path
        self.verbose = verbose
        self.issues: List[ValidationIssue] = []
        
        # Terminology consistency tracking
        self.terminology_map: Dict[str, Set[str]] = defaultdict(set)
        self.all_headings: List[tuple] = []  # (file, line, level, text)
        
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
        
        # Get all markdown files
        md_files = sorted(self.docs_path.glob("*.md"))
        
        # Add default exclusions
        default_excludes = ['combined.md', r'\._.*']
        all_excludes = default_excludes + exclude
        
        # Filter out excluded files
        exclude_patterns = [re.compile(pattern) for pattern in all_excludes]
        md_files = [
            f for f in md_files 
            if not any(pattern.search(f.name) for pattern in exclude_patterns)
        ]
        
        self.log(f"Found {len(md_files)} documentation files to validate")
        
        # First pass: collect data for cross-file analysis
        for md_file in md_files:
            self._collect_file_data(md_file)
        
        # Second pass: validate each file
        for md_file in md_files:
            self.log(f"Validating {md_file.name}")
            self._validate_file(md_file, rules)
        
        # Run cross-file validations
        if 'terminology-consistency' in rules:
            self._check_terminology_consistency()
        
        return self.issues
    
    def _collect_file_data(self, file_path: Path):
        """Collect data from file for cross-file analysis."""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()
        except UnicodeDecodeError:
            try:
                with open(file_path, 'r', encoding='latin-1') as f:
                    lines = f.readlines()
            except Exception:
                return
        
        for line_num, line in enumerate(lines, 1):
            # Collect headings
            heading_match = re.match(r'^(#{1,6})\s+(.+)$', line.strip())
            if heading_match:
                level = len(heading_match.group(1))
                text = heading_match.group(2).strip()
                self.all_headings.append((file_path.name, line_num, level, text))
            
            # Collect terminology variations
            tech_terms = ['Hive', 'Isar', 'Riverpod', 'Firebase', 'Firestore']
            for term in tech_terms:
                if term.lower() in line.lower():
                    # Extract the actual usage
                    matches = re.findall(r'\b' + term + r'\b', line, re.IGNORECASE)
                    for match in matches:
                        self.terminology_map[term.lower()].add(match)
    
    def _validate_file(self, file_path: Path, rules: List[str]):
        """Validate a single file."""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()
        except UnicodeDecodeError:
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
        
        content = ''.join(lines)
        
        # Run validation rules
        if 'empty-sections' in rules:
            self._check_empty_sections(file_path.name, lines)
        
        if 'code-block-syntax' in rules:
            self._check_code_block_syntax(file_path.name, lines)
        
        if 'line-length' in rules:
            self._check_line_length(file_path.name, lines)
        
        if 'list-consistency' in rules:
            self._check_list_consistency(file_path.name, lines)
        
        if 'heading-capitalization' in rules:
            self._check_heading_capitalization(file_path.name, lines)
        
        if 'duplicate-headings' in rules:
            self._check_duplicate_headings(file_path.name, lines)
        
        if 'orphaned-content' in rules:
            self._check_orphaned_content(file_path.name, lines)
    
    def _check_empty_sections(self, filename: str, lines: List[str]):
        """Check for sections with no content between headings."""
        for i, line in enumerate(lines, 1):
            if re.match(r'^#{2,4}\s+\d+\.\d+', line.strip()):  # Numbered section
                # Check if next non-empty line is another heading
                j = i
                has_content = False
                while j < len(lines):
                    next_line = lines[j].strip()
                    if next_line and not next_line.startswith('---'):
                        if re.match(r'^#{2,4}\s+', next_line):
                            # Found another heading without content
                            if not has_content:
                                self.add_issue(ValidationIssue(
                                    file=filename,
                                    line=i,
                                    rule='empty-sections',
                                    severity='warning',
                                    message='Section appears to have no content before next heading',
                                    suggestion='Add content or remove empty section'
                                ))
                        else:
                            has_content = True
                        break
                    j += 1
    
    def _check_code_block_syntax(self, filename: str, lines: List[str]):
        """Check code blocks have proper syntax markers."""
        in_code_block = False
        code_block_start_line = 0
        fence_char = None
        
        for i, line in enumerate(lines, 1):
            stripped = line.strip()
            
            # Check for code fence start
            if re.match(r'^```+', stripped) or re.match(r'^~~~+', stripped):
                if not in_code_block:
                    in_code_block = True
                    code_block_start_line = i
                    fence_char = stripped[0]
                    
                    # Check if language is specified
                    if len(stripped) == 3:  # Just ``` or ~~~
                        self.add_issue(ValidationIssue(
                            file=filename,
                            line=i,
                            rule='code-block-syntax',
                            severity='info',
                            message='Code block missing language identifier',
                            suggestion='Add language identifier (e.g., ```dart, ```json)'
                        ))
                else:
                    # Code block end
                    if stripped[0] != fence_char:
                        self.add_issue(ValidationIssue(
                            file=filename,
                            line=i,
                            rule='code-block-syntax',
                            severity='warning',
                            message=f'Code block fence mismatch (started with {fence_char}, ended with {stripped[0]})',
                            suggestion='Use consistent fence characters'
                        ))
                    in_code_block = False
                    fence_char = None
        
        # Check for unclosed code block
        if in_code_block:
            self.add_issue(ValidationIssue(
                file=filename,
                line=code_block_start_line,
                rule='code-block-syntax',
                severity='error',
                message='Unclosed code block',
                suggestion='Add closing fence (``` or ~~~)'
            ))
    
    def _check_line_length(self, filename: str, lines: List[str]):
        """Check for overly long lines that hurt readability."""
        max_length = 120
        in_code_block = False
        in_table = False
        
        for i, line in enumerate(lines, 1):
            stripped = line.strip()
            
            # Skip code blocks
            if re.match(r'^```+', stripped) or re.match(r'^~~~+', stripped):
                in_code_block = not in_code_block
                continue
            
            if in_code_block:
                continue
            
            # Skip tables
            if '|' in stripped:
                in_table = True
                continue
            elif in_table and not stripped:
                in_table = False
            
            if in_table:
                continue
            
            # Check line length
            if len(line.rstrip()) > max_length:
                # Allow URLs to exceed limit
                if not re.search(r'https?://', line):
                    self.add_issue(ValidationIssue(
                        file=filename,
                        line=i,
                        rule='line-length',
                        severity='info',
                        message=f'Line exceeds {max_length} characters ({len(line.rstrip())} chars)',
                        suggestion='Consider breaking into multiple lines for readability'
                    ))
    
    def _check_list_consistency(self, filename: str, lines: List[str]):
        """Check for consistent list formatting."""
        list_markers = []
        in_list = False
        list_start = 0
        
        for i, line in enumerate(lines, 1):
            stripped = line.strip()
            
            # Check for list item
            list_match = re.match(r'^([-*+]|\d+\.)\s+', stripped)
            
            if list_match:
                marker = list_match.group(1)
                if not in_list:
                    in_list = True
                    list_start = i
                    list_markers = [marker if not marker[0].isdigit() else 'numbered']
                else:
                    list_markers.append(marker if not marker[0].isdigit() else 'numbered')
            elif in_list and stripped and not stripped.startswith(' '):
                # End of list
                # Check if markers are consistent
                unique_markers = set(list_markers)
                if len(unique_markers) > 1:
                    self.add_issue(ValidationIssue(
                        file=filename,
                        line=list_start,
                        rule='list-consistency',
                        severity='info',
                        message=f'Inconsistent list markers in same list: {unique_markers}',
                        suggestion='Use consistent markers (-, *, or numbered) throughout list'
                    ))
                in_list = False
                list_markers = []
    
    def _check_heading_capitalization(self, filename: str, lines: List[str]):
        """Check heading capitalization for consistency."""
        for i, line in enumerate(lines, 1):
            heading_match = re.match(r'^(#{2,6})\s+(.+)$', line.strip())
            if heading_match:
                heading_text = heading_match.group(2)
                
                # Skip numbered sections
                if re.match(r'^\d+\.', heading_text):
                    continue
                
                # Check if it's title case or sentence case
                words = heading_text.split()
                if len(words) > 1:
                    # Count capitalized words (excluding articles and prepositions)
                    skip_words = {'a', 'an', 'the', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for', 'of', 'with'}
                    capitalized = sum(1 for w in words[1:] if w[0].isupper() and w.lower() not in skip_words)
                    
                    # If mixed capitalization, suggest consistency
                    if 0 < capitalized < len(words) - 1:
                        self.add_issue(ValidationIssue(
                            file=filename,
                            line=i,
                            rule='heading-capitalization',
                            severity='info',
                            message='Heading has inconsistent capitalization',
                            suggestion='Use either Title Case or Sentence case consistently'
                        ))
    
    def _check_duplicate_headings(self, filename: str, lines: List[str]):
        """Check for duplicate headings within same file."""
        headings_seen = {}
        
        for i, line in enumerate(lines, 1):
            heading_match = re.match(r'^(#{2,6})\s+(.+)$', line.strip())
            if heading_match:
                level = len(heading_match.group(1))
                text = heading_match.group(2).strip().lower()
                
                if text in headings_seen and headings_seen[text][0] == level:
                    self.add_issue(ValidationIssue(
                        file=filename,
                        line=i,
                        rule='duplicate-headings',
                        severity='warning',
                        message=f'Duplicate heading "{heading_match.group(2)}" (first seen at line {headings_seen[text][1]})',
                        suggestion='Use unique headings or add distinguishing context'
                    ))
                else:
                    headings_seen[text] = (level, i)
    
    def _check_orphaned_content(self, filename: str, lines: List[str]):
        """Check for content before first heading."""
        found_heading = False
        found_content = False
        content_line = 0
        
        for i, line in enumerate(lines, 1):
            stripped = line.strip()
            
            if not stripped or stripped.startswith('<!--'):
                continue
            
            if re.match(r'^#{1,6}\s+', stripped):
                found_heading = True
                if found_content and not found_heading:
                    self.add_issue(ValidationIssue(
                        file=filename,
                        line=content_line,
                        rule='orphaned-content',
                        severity='info',
                        message='Content found before first heading',
                        suggestion='Add heading or move content under appropriate section'
                    ))
                break
            elif not found_heading:
                if not found_content:
                    found_content = True
                    content_line = i
    
    def _check_terminology_consistency(self):
        """Check for terminology consistency across all documents."""
        for term_lower, variations in self.terminology_map.items():
            if len(variations) > 1:
                # Multiple case variations found
                # This is just info level since some variation may be intentional
                most_common = max(variations, key=lambda v: sum(1 for h in self.all_headings if v in h[3]))
                for file, line, level, text in self.all_headings:
                    for var in variations:
                        if var in text and var != most_common:
                            self.add_issue(ValidationIssue(
                                file=file,
                                line=line,
                                rule='terminology-consistency',
                                severity='info',
                                message=f'Term "{var}" has multiple case variations: {variations}',
                                suggestion=f'Consider using consistent form: "{most_common}"'
                            ))
                            break

def print_issues(issues: List[ValidationIssue], docs_path: Path):
    """Print validation issues in a readable format."""
    if not issues:
        print("✅ All validation checks passed!")
        return
    
    # Group by severity
    errors = [i for i in issues if i.severity == 'error']
    warnings = [i for i in issues if i.severity == 'warning']
    infos = [i for i in issues if i.severity == 'info']
    
    print(f"\n❌ Found {len(issues)} issue(s)")
    print(f"   Errors: {len(errors)}, Warnings: {len(warnings)}, Info: {len(infos)}\n")
    
    # Group by file
    by_file = defaultdict(list)
    for issue in issues:
        by_file[issue.file].append(issue)
    
    for filename in sorted(by_file.keys()):
        file_issues = by_file[filename]
        print(f"\n📄 {filename}")
        print("─" * 80)
        
        for issue in sorted(file_issues, key=lambda x: x.line):
            icon = {
                'error': '🔴',
                'warning': '🟡',
                'info': '🔵'
            }[issue.severity]
            
            print(f"  {icon} Line {issue.line}: [{issue.rule}] {issue.message}")
            print(f"     💡 {issue.suggestion}")
    
    print("\n" + "─" * 80 + "\n")
    print(f"📊 Summary: {len(errors)} errors, {len(warnings)} warnings, {len(infos)} info\n")

def main():
    """Main entry point."""
    import argparse
    
    parser = argparse.ArgumentParser(
        description='Extended documentation validator for quality and consistency checks'
    )
    parser.add_argument(
        '--verbose',
        action='store_true',
        help='Enable verbose output'
    )
    parser.add_argument(
        '--rules',
        default='all',
        help='Comma-separated list of rules to run (or "all")'
    )
    parser.add_argument(
        '--exclude',
        default='',
        help='Comma-separated patterns to exclude'
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
        script_dir = Path(__file__).parent
        docs_path = script_dir.parent / 'plan'
    
    if not docs_path.exists():
        print(f"❌ Error: Documentation path not found: {docs_path}", file=sys.stderr)
        return 2
    
    # Parse rules
    if args.rules == 'all':
        rules = [
            'empty-sections',
            'code-block-syntax',
            'line-length',
            'list-consistency',
            'heading-capitalization',
            'duplicate-headings',
            'orphaned-content',
            'terminology-consistency'
        ]
    else:
        rules = [r.strip() for r in args.rules.split(',')]
    
    # Parse exclude patterns
    exclude = [p.strip() for p in args.exclude.split(',') if p.strip()]
    
    # Run validation
    validator = ExtendedDocumentValidator(docs_path, verbose=args.verbose)
    
    print(f"🔍 Running extended validation on: {docs_path}")
    print(f"📋 Rules: {', '.join(rules)}")
    if exclude:
        print(f"🚫 Excluding: {', '.join(exclude)}")
    print()
    
    try:
        issues = validator.validate_all(rules, exclude)
        print_issues(issues, docs_path)
        
        # Return appropriate exit code
        errors = sum(1 for i in issues if i.severity == 'error')
        warnings = sum(1 for i in issues if i.severity == 'warning')
        
        if errors > 0:
            return 1
        elif warnings > 0:
            return 0  # Warnings don't fail the build
        else:
            return 0
            
    except Exception as e:
        print(f"❌ Validation failed: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        return 2

if __name__ == '__main__':
    sys.exit(main())
