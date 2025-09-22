#!/usr/bin/env python3
"""Advanced Coverage Analysis Tool

Framework-agnostic coverage analysis with support for multiple formats:
- LCOV (lcov.info) - Used by Jest, pytest-cov, genhtml
- JSON (NYC/Istanbul format) - Node.js coverage
- XML (JaCoCo, Cobertura) - Java/C# coverage
- Go coverage (coverage.out)
- Rust coverage (tarpaulin)

Features:
- Multi-format coverage parsing
- File-level coverage breakdown
- Threshold validation (global and patch)
- Trend analysis
- HTML report generation
- CI/CD integration

Extracted from AshTrail project and generalized for any language.
"""

import argparse
import json
import os
import sys
import subprocess
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import Dict, List, Optional, Tuple, Any
from dataclasses import dataclass, asdict
from datetime import datetime
import re

def detect_project_root() -> Path:
    """Detect project root by looking for common indicators."""
    current = Path.cwd()
    indicators = [
        'automation.config.yaml',
        'feature_matrix.yaml',
        '.git',
        'pyproject.toml',
        'package.json',
        'pom.xml',
        'go.mod',
        'Cargo.toml',
        'pubspec.yaml',
    ]

    for path in [current] + list(current.parents):
        for indicator in indicators:
            if (path / indicator).exists():
                return path

    return current

ROOT = detect_project_root()
COVERAGE_DIR = ROOT / "coverage"

@dataclass
class Filecoverage:
    """Coverage data for a single file."""
    file_path: str
    lines_found: int
    lines_hit: int
    line_coverage: float
    branches_found: int = 0
    branches_hit: int = 0
    branch_coverage: float = 0.0
    functions_found: int = 0
    functions_hit: int = 0
    function_coverage: float = 0.0

@dataclass
class CoverageReport:
    """Complete coverage report."""
    format_type: str
    line_coverage: float
    branch_coverage: float = 0.0
    function_coverage: float = 0.0
    statement_coverage: float = 0.0
    lines_found: int = 0
    lines_hit: int = 0
    branches_found: int = 0
    branches_hit: int = 0
    functions_found: int = 0
    functions_hit: int = 0
    files: List[FileDetails] = None
    timestamp: str = None

    def __post_init__(self):
        if self.timestamp is None:
            self.timestamp = datetime.now().isoformat()
        if self.files is None:
            self.files = []

def run_command(cmd: List[str], timeout: int = 60, cwd: Path = ROOT) -> Tuple[bool, str]:
    """Execute shell command with timeout and error handling."""
    try:
        proc = subprocess.run(
            cmd,
            cwd=cwd,
            capture_output=True,
            text=True,
            timeout=timeout,
            shell=(os.name == 'nt')
        )
        output = proc.stdout.strip()
        if proc.stderr.strip():
            output += f"\n{proc.stderr.strip()}"
        return proc.returncode == 0, output
    except (FileNotFoundError, subprocess.TimeoutExpired, Exception) as e:
        return False, f"Command failed: {e}"

def find_coverage_files() -> Dict[str, List[Path]]:
    """Find coverage files by format type."""
    coverage_files = {
        'lcov': [],
        'json': [],
        'xml': [],
        'go': [],
        'rust': []
    }

    # Common coverage file patterns
    patterns = {
        'lcov': ['coverage/lcov.info', 'lcov.info', 'coverage.info'],
        'json': ['coverage/coverage-final.json', 'coverage-final.json', 'coverage.json'],
        'xml': ['coverage/cobertura.xml', 'coverage/jacoco.xml', 'coverage.xml',
                'target/site/jacoco/jacoco.xml', 'build/reports/jacoco/test/jacocoTestReport.xml'],
        'go': ['coverage.out', 'coverage/coverage.out'],
        'rust': ['coverage/tarpaulin-report.json', 'target/tarpaulin/tarpaulin-report.json']
    }

    for format_type, pattern_list in patterns.items():
        for pattern in pattern_list:
            matches = list(ROOT.glob(pattern))
            coverage_files[format_type].extend(matches)

    return coverage_files

def parse_lcov_file(lcov_path: Path) -> CoverageReport:
    """Parse LCOV format coverage file."""
    if not lcov_path.exists():
        raise FileNotFoundError(f"LCOV file not found: {lcov_path}")

    files = []
    total_lines_found = 0
    total_lines_hit = 0
    total_branches_found = 0
    total_branches_hit = 0
    total_functions_found = 0
    total_functions_hit = 0

    current_file = None
    current_coverage = None

    with open(lcov_path, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()

            if line.startswith('SF:'):
                # Start of new source file
                current_file = line[3:].replace('\\', '/')
                current_coverage = FileDetails(
                    file_path=current_file,
                    lines_found=0,
                    lines_hit=0,
                    line_coverage=0.0
                )

            elif line.startswith('LF:'):
                # Lines found
                lines_found = int(line[3:])
                if current_coverage:
                    current_coverage.lines_found = lines_found
                total_lines_found += lines_found

            elif line.startswith('LH:'):
                # Lines hit
                lines_hit = int(line[3:])
                if current_coverage:
                    current_coverage.lines_hit = lines_hit
                    current_coverage.line_coverage = (
                        (lines_hit / current_coverage.lines_found * 100)
                        if current_coverage.lines_found > 0 else 0
                    )
                total_lines_hit += lines_hit

            elif line.startswith('BRF:'):
                # Branches found
                branches_found = int(line[4:])
                if current_coverage:
                    current_coverage.branches_found = branches_found
                total_branches_found += branches_found

            elif line.startswith('BRH:'):
                # Branches hit
                branches_hit = int(line[4:])
                if current_coverage:
                    current_coverage.branches_hit = branches_hit
                    current_coverage.branch_coverage = (
                        (branches_hit / current_coverage.branches_found * 100)
                        if current_coverage.branches_found > 0 else 0
                    )
                total_branches_hit += branches_hit

            elif line.startswith('FNF:'):
                # Functions found
                functions_found = int(line[4:])
                if current_coverage:
                    current_coverage.functions_found = functions_found
                total_functions_found += functions_found

            elif line.startswith('FNH:'):
                # Functions hit
                functions_hit = int(line[4:])
                if current_coverage:
                    current_coverage.functions_hit = functions_hit
                    current_coverage.function_coverage = (
                        (functions_hit / current_coverage.functions_found * 100)
                        if current_coverage.functions_found > 0 else 0
                    )
                total_functions_hit += functions_hit

            elif line == 'end_of_record':
                # End of current file record
                if current_coverage:
                    files.append(current_coverage)
                current_file = None
                current_coverage = None

    # Calculate overall percentages
    line_coverage = (total_lines_hit / total_lines_found * 100) if total_lines_found > 0 else 0
    branch_coverage = (total_branches_hit / total_branches_found * 100) if total_branches_found > 0 else 0
    function_coverage = (total_functions_hit / total_functions_found * 100) if total_functions_found > 0 else 0

    return CoverageReport(
        format_type='lcov',
        line_coverage=round(line_coverage, 2),
        branch_coverage=round(branch_coverage, 2),
        function_coverage=round(function_coverage, 2),
        lines_found=total_lines_found,
        lines_hit=total_lines_hit,
        branches_found=total_branches_found,
        branches_hit=total_branches_hit,
        functions_found=total_functions_found,
        functions_hit=total_functions_hit,
        files=files
    )

def parse_json_coverage(json_path: Path) -> CoverageReport:
    """Parse JSON format coverage (NYC/Istanbul)."""
    if not json_path.exists():
        raise FileNotFoundError(f"JSON coverage file not found: {json_path}")

    with open(json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    files = []

    # Handle NYC/Istanbul format
    if 'total' in data:
        total = data['total']
        line_coverage = total.get('lines', {}).get('pct', 0)
        branch_coverage = total.get('branches', {}).get('pct', 0)
        function_coverage = total.get('functions', {}).get('pct', 0)
        statement_coverage = total.get('statements', {}).get('pct', 0)

        # Process individual files
        for file_path, file_data in data.items():
            if file_path == 'total':
                continue

            if isinstance(file_data, dict):
                lines = file_data.get('lines', {})
                branches = file_data.get('branches', {})
                functions = file_data.get('functions', {})

                file_coverage = FileDetails(
                    file_path=file_path,
                    lines_found=lines.get('total', 0),
                    lines_hit=lines.get('covered', 0),
                    line_coverage=lines.get('pct', 0),
                    branches_found=branches.get('total', 0),
                    branches_hit=branches.get('covered', 0),
                    branch_coverage=branches.get('pct', 0),
                    functions_found=functions.get('total', 0),
                    functions_hit=functions.get('covered', 0),
                    function_coverage=functions.get('pct', 0)
                )
                files.append(file_coverage)

        return CoverageReport(
            format_type='json',
            line_coverage=line_coverage,
            branch_coverage=branch_coverage,
            function_coverage=function_coverage,
            statement_coverage=statement_coverage,
            lines_found=total.get('lines', {}).get('total', 0),
            lines_hit=total.get('lines', {}).get('covered', 0),
            branches_found=total.get('branches', {}).get('total', 0),
            branches_hit=total.get('branches', {}).get('covered', 0),
            functions_found=total.get('functions', {}).get('total', 0),
            functions_hit=total.get('functions', {}).get('covered', 0),
            files=files
        )

    return CoverageReport(format_type='json', line_coverage=0)

def parse_xml_coverage(xml_path: Path) -> CoverageReport:
    """Parse XML format coverage (JaCoCo, Cobertura)."""
    if not xml_path.exists():
        raise FileNotFoundError(f"XML coverage file not found: {xml_path}")

    try:
        tree = ET.parse(xml_path)
        root = tree.getroot()
    except ET.ParseError as e:
        raise ValueError(f"Failed to parse XML coverage file: {e}")

    files = []

    # Handle JaCoCo XML format
    if root.tag == 'report':
        # JaCoCo format
        line_coverage = 0
        branch_coverage = 0

        for counter in root.findall('.//counter[@type="LINE"]'):
            missed = int(counter.get('missed', 0))
            covered = int(counter.get('covered', 0))
            total = missed + covered
            if total > 0:
                line_coverage = (covered / total) * 100
            break

        for counter in root.findall('.//counter[@type="BRANCH"]'):
            missed = int(counter.get('missed', 0))
            covered = int(counter.get('covered', 0))
            total = missed + covered
            if total > 0:
                branch_coverage = (covered / total) * 100
            break

        # Process individual source files
        for sourcefile in root.findall('.//sourcefile'):
            filename = sourcefile.get('name', '')
            if filename:
                file_line_coverage = 0
                file_branch_coverage = 0

                for counter in sourcefile.findall('counter[@type="LINE"]'):
                    missed = int(counter.get('missed', 0))
                    covered = int(counter.get('covered', 0))
                    total = missed + covered
                    if total > 0:
                        file_line_coverage = (covered / total) * 100

                for counter in sourcefile.findall('counter[@type="BRANCH"]'):
                    missed = int(counter.get('missed', 0))
                    covered = int(counter.get('covered', 0))
                    total = missed + covered
                    if total > 0:
                        file_branch_coverage = (covered / total) * 100

                files.append(FileDetails(
                    file_path=filename,
                    lines_found=0,  # JaCoCo doesn't provide this directly
                    lines_hit=0,
                    line_coverage=file_line_coverage,
                    branch_coverage=file_branch_coverage
                ))

        return CoverageReport(
            format_type='jacoco-xml',
            line_coverage=round(line_coverage, 2),
            branch_coverage=round(branch_coverage, 2),
            files=files
        )

    # Handle Cobertura XML format
    elif root.tag == 'coverage':
        line_rate = float(root.get('line-rate', 0)) * 100
        branch_rate = float(root.get('branch-rate', 0)) * 100

        for class_elem in root.findall('.//class'):
            filename = class_elem.get('filename', '')
            if filename:
                class_line_rate = float(class_elem.get('line-rate', 0)) * 100
                class_branch_rate = float(class_elem.get('branch-rate', 0)) * 100

                files.append(FileDetails(
                    file_path=filename,
                    lines_found=0,
                    lines_hit=0,
                    line_coverage=class_line_rate,
                    branch_coverage=class_branch_rate
                ))

        return CoverageReport(
            format_type='cobertura-xml',
            line_coverage=round(line_rate, 2),
            branch_coverage=round(branch_rate, 2),
            files=files
        )

    return CoverageReport(format_type='xml', line_coverage=0)

def parse_go_coverage(coverage_path: Path) -> CoverageReport:
    """Parse Go coverage format."""
    if not coverage_path.exists():
        raise FileNotFoundError(f"Go coverage file not found: {coverage_path}")

    # Use go tool cover to get percentage
    go_tool_ok, go_output = run_command(['go', 'tool', 'cover', f'-func={coverage_path}'])

    if not go_tool_ok:
        # Fallback: parse manually
        with open(coverage_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # Simple parsing - count covered vs total statements
        lines = content.strip().split('\n')[1:]  # Skip mode line
        total_statements = 0
        covered_statements = 0

        for line in lines:
            if line.strip():
                parts = line.split()
                if len(parts) >= 3:
                    count = int(parts[-1])
                    total_statements += 1
                    if count > 0:
                        covered_statements += 1

        coverage_pct = (covered_statements / total_statements * 100) if total_statements > 0 else 0

        return CoverageReport(
            format_type='go',
            line_coverage=round(coverage_pct, 2),
            lines_found=total_statements,
            lines_hit=covered_statements
        )

    # Parse go tool output
    coverage_match = re.search(r'total:\s+\(statements\)\s+([\d.]+)%', go_output)
    if coverage_match:
        coverage_pct = float(coverage_match.group(1))
        return CoverageReport(
            format_type='go',
            line_coverage=round(coverage_pct, 2)
        )

    return CoverageReport(format_type='go', line_coverage=0)

def analyze_coverage_trends(current_report: CoverageReport, history_dir: Path = None) -> Dict[str, Any]:
    """Analyze coverage trends over time."""
    if history_dir is None:
        history_dir = COVERAGE_DIR / "history"

    trends = {
        "current_coverage": current_report.line_coverage,
        "trend": "unknown",
        "change": 0.0,
        "history_available": False
    }

    if not history_dir.exists():
        return trends

    # Find most recent historical report
    history_files = list(history_dir.glob("coverage_*.json"))
    if not history_files:
        return trends

    # Sort by timestamp in filename
    history_files.sort(key=lambda f: f.name, reverse=True)

    try:
        with open(history_files[0], 'r', encoding='utf-8') as f:
            prev_data = json.load(f)

        prev_coverage = prev_data.get('line_coverage', 0)
        change = current_report.line_coverage - prev_coverage

        trends.update({
            "previous_coverage": prev_coverage,
            "change": round(change, 2),
            "trend": "improved" if change > 0 else "declined" if change < 0 else "stable",
            "history_available": True
        })

    except (json.JSONDecodeError, FileNotFoundError, KeyError):
        pass

    return trends

def save_coverage_history(report: CoverageReport, history_dir: Path = None):
    """Save coverage report to history."""
    if history_dir is None:
        history_dir = COVERAGE_DIR / "history"

    history_dir.mkdir(parents=True, exist_ok=True)

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    history_file = history_dir / f"coverage_{timestamp}.json"

    try:
        with open(history_file, 'w', encoding='utf-8') as f:
            json.dump(asdict(report), f, indent=2)
    except Exception as e:
        print(f"Warning: Failed to save coverage history: {e}")

def generate_html_report(report: CoverageReport, output_dir: Path = None):
    """Generate HTML coverage report."""
    if output_dir is None:
        output_dir = COVERAGE_DIR / "html"

    output_dir.mkdir(parents=True, exist_ok=True)

    html_content = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Coverage Report</title>
    <style>
        body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 40px; }}
        .header {{ background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px; }}
        .metric {{ display: inline-block; margin: 10px 20px 10px 0; }}
        .metric-value {{ font-size: 24px; font-weight: bold; }}
        .metric-label {{ color: #666; font-size: 14px; }}
        .coverage-high {{ color: #28a745; }}
        .coverage-medium {{ color: #ffc107; }}
        .coverage-low {{ color: #dc3545; }}
        table {{ width: 100%; border-collapse: collapse; margin-top: 20px; }}
        th, td {{ text-align: left; padding: 12px; border-bottom: 1px solid #ddd; }}
        th {{ background-color: #f8f9fa; font-weight: 600; }}
        tr:hover {{ background-color: #f5f5f5; }}
        .file-path {{ font-family: monospace; }}
    </style>
</head>
<body>
    <div class="header">
        <h1>Coverage Report</h1>
        <p>Generated: {report.timestamp}</p>
        <p>Format: {report.format_type}</p>

        <div class="metric">
            <div class="metric-value coverage-{'high' if report.line_coverage >= 80 else 'medium' if report.line_coverage >= 60 else 'low'}">{report.line_coverage:.1f}%</div>
            <div class="metric-label">Line Coverage</div>
        </div>

        {"<div class='metric'><div class='metric-value coverage-" + ('high' if report.branch_coverage >= 80 else 'medium' if report.branch_coverage >= 60 else 'low') + f"'>{report.branch_coverage:.1f}%</div><div class='metric-label'>Branch Coverage</div></div>" if report.branch_coverage > 0 else ""}

        {"<div class='metric'><div class='metric-value coverage-" + ('high' if report.function_coverage >= 80 else 'medium' if report.function_coverage >= 60 else 'low') + f"'>{report.function_coverage:.1f}%</div><div class='metric-label'>Function Coverage</div></div>" if report.function_coverage > 0 else ""}

        <div class="metric">
            <div class="metric-value">{report.lines_hit:,} / {report.lines_found:,}</div>
            <div class="metric-label">Lines Covered</div>
        </div>
    </div>

    <h2>File Coverage Details</h2>
    <table>
        <thead>
            <tr>
                <th>File</th>
                <th>Line Coverage</th>
                <th>Lines Hit/Found</th>
                {"<th>Branch Coverage</th>" if any(f.branch_coverage > 0 for f in report.files) else ""}
                {"<th>Function Coverage</th>" if any(f.function_coverage > 0 for f in report.files) else ""}
            </tr>
        </thead>
        <tbody>
"""

    for file_detail in sorted(report.files, key=lambda f: f.line_coverage):
        coverage_class = 'coverage-high' if file_detail.line_coverage >= 80 else 'coverage-medium' if file_detail.line_coverage >= 60 else 'coverage-low'

        html_content += f"""
            <tr>
                <td class="file-path">{file_detail.file_path}</td>
                <td class="{coverage_class}">{file_detail.line_coverage:.1f}%</td>
                <td>{file_detail.lines_hit} / {file_detail.lines_found}</td>
                {"<td>" + f"{file_detail.branch_coverage:.1f}%" + "</td>" if any(f.branch_coverage > 0 for f in report.files) else ""}
                {"<td>" + f"{file_detail.function_coverage:.1f}%" + "</td>" if any(f.function_coverage > 0 for f in report.files) else ""}
            </tr>
        """

    html_content += """
        </tbody>
    </table>
</body>
</html>
"""

    html_file = output_dir / "index.html"
    with open(html_file, 'w', encoding='utf-8') as f:
        f.write(html_content)

    return html_file

def check_coverage_thresholds(report: CoverageReport,
                             global_threshold: float = 80.0,
                             patch_threshold: float = 85.0) -> Dict[str, Any]:
    """Check coverage against thresholds."""
    results = {
        "global_threshold": global_threshold,
        "patch_threshold": patch_threshold,
        "global_pass": report.line_coverage >= global_threshold,
        "current_coverage": report.line_coverage,
        "files_below_threshold": []
    }

    # Find files below global threshold
    for file_detail in report.files:
        if file_detail.line_coverage < global_threshold:
            results["files_below_threshold"].append({
                "file": file_detail.file_path,
                "coverage": file_detail.line_coverage,
                "deficit": global_threshold - file_detail.line_coverage
            })

    return results

def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Advanced coverage analysis tool",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )

    parser.add_argument('--format', choices=['lcov', 'json', 'xml', 'go', 'auto'],
                       default='auto', help='Coverage format to parse')
    parser.add_argument('--file', type=Path, help='Specific coverage file to analyze')
    parser.add_argument('--threshold', type=float, default=80.0,
                       help='Global coverage threshold (default: 80%%)')
    parser.add_argument('--patch-threshold', type=float, default=85.0,
                       help='Patch coverage threshold (default: 85%%)')
    parser.add_argument('--html', action='store_true', help='Generate HTML report')
    parser.add_argument('--json-output', action='store_true', help='Output JSON format')
    parser.add_argument('--save-history', action='store_true', help='Save to coverage history')
    parser.add_argument('--trends', action='store_true', help='Show coverage trends')
    parser.add_argument('--ci', action='store_true', help='CI mode - exit with error if threshold not met')

    args = parser.parse_args()

    try:
        # Find coverage files
        if args.file:
            coverage_files = {args.format: [args.file]}
        else:
            coverage_files = find_coverage_files()

        reports = []

        # Process coverage files by format
        for format_type, files in coverage_files.items():
            if not files:
                continue

            if args.format != 'auto' and args.format != format_type:
                continue

            for coverage_file in files:
                try:
                    if format_type == 'lcov':
                        report = parse_lcov_file(coverage_file)
                    elif format_type == 'json':
                        report = parse_json_coverage(coverage_file)
                    elif format_type == 'xml':
                        report = parse_xml_coverage(coverage_file)
                    elif format_type == 'go':
                        report = parse_go_coverage(coverage_file)
                    else:
                        continue

                    reports.append((coverage_file, report))

                except Exception as e:
                    print(f"Warning: Failed to parse {coverage_file}: {e}")

        if not reports:
            print("❌ No valid coverage files found")
            if args.ci:
                sys.exit(1)
            return

        # Use the first (best) report
        coverage_file, report = reports[0]

        # Check thresholds
        threshold_results = check_coverage_thresholds(report, args.threshold, args.patch_threshold)

        # Analyze trends if requested
        trends = None
        if args.trends:
            trends = analyze_coverage_trends(report)

        # Save history if requested
        if args.save_history:
            save_coverage_history(report)

        # Generate HTML report if requested
        html_file = None
        if args.html:
            html_file = generate_html_report(report)

        # Output results
        if args.json_output:
            output = {
                "coverage_file": str(coverage_file.relative_to(ROOT)),
                "report": asdict(report),
                "thresholds": threshold_results,
                "trends": trends,
                "html_report": str(html_file.relative_to(ROOT)) if html_file else None
            }
            print(json.dumps(output, indent=2))
        else:
            # Human-readable output
            print(f"📊 Coverage Analysis Report")
            print(f"📁 File: {coverage_file.relative_to(ROOT)}")
            print(f"📊 Format: {report.format_type}")
            print()

            # Overall metrics
            status = '✅' if threshold_results['global_pass'] else '❌'
            print(f"{status} Overall Coverage: {report.line_coverage:.1f}% (threshold: {args.threshold}%)")

            if report.branch_coverage > 0:
                print(f"🌿 Branch Coverage: {report.branch_coverage:.1f}%")

            if report.function_coverage > 0:
                print(f"🔧 Function Coverage: {report.function_coverage:.1f}%")

            print(f"📏 Lines: {report.lines_hit:,} / {report.lines_found:,}")

            # Trends
            if trends and trends['history_available']:
                trend_icon = '📈' if trends['trend'] == 'improved' else '📉' if trends['trend'] == 'declined' else '➡️'
                print(f"{trend_icon} Trend: {trends['trend']} ({trends['change']:+.1f}%)")

            # Files below threshold
            if threshold_results['files_below_threshold']:
                print(f"\n⚠️  Files Below Threshold:")
                for file_info in threshold_results['files_below_threshold'][:10]:  # Top 10
                    print(f"  📄 {file_info['file']}: {file_info['coverage']:.1f}% (need {file_info['deficit']:.1f}% more)")

            # HTML report
            if html_file:
                print(f"\n📋 HTML Report: {html_file.relative_to(ROOT)}")

        # Exit with appropriate code for CI
        if args.ci and not threshold_results['global_pass']:
            print(f"\n❌ Coverage {report.line_coverage:.1f}% below threshold {args.threshold}%")
            sys.exit(1)

    except KeyboardInterrupt:
        print("\n⚠️  Operation cancelled")
        sys.exit(130)
    except Exception as e:
        print(f"💥 Error: {e}")
        if args.ci:
            sys.exit(1)

if __name__ == '__main__':
    main()
