#!/usr/bin/env python3
"""Framework-Agnostic Development Assistant

Core automation commands for feature-driven development workflow:
- start-next-feature: Begin work on next planned feature
- finalize-feature: Complete feature with validation
- status: Show project and feature status
- health: Validate development environment
- coverage: Analyze test coverage and generate reports

Extracted from AshTrail project and generalized for any project type.
"""

import argparse
import json
import os
import subprocess
import sys
import time
from dataclasses import dataclass, asdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, List, Optional, Tuple, Any, Union
import tempfile

try:
    import yaml
except ImportError:
    print("Warning: PyYAML not installed. Install with: pip install PyYAML")
    yaml = None

# Project structure detection
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
        '*.csproj',
        '*.sln'
    ]

    for path in [current] + list(current.parents):
        for indicator in indicators:
            if '*' in indicator:
                # Glob pattern
                if list(path.glob(indicator)):
                    return path
            elif (path / indicator).exists():
                return path

    return current

ROOT = detect_project_root()
CONFIG_FILE = ROOT / "automation.config.yaml"
FEATURE_MATRIX = ROOT / "feature_matrix.yaml"
COVERAGE_DIR = ROOT / "coverage"
CACHE_DIR = ROOT / ".cache"
SESSIONS_DIR = ROOT / "automation_sessions"

# Default coverage thresholds
MIN_GLOBAL_COVERAGE = float(os.environ.get("COVERAGE_GLOBAL_THRESHOLD", "80"))
MIN_PATCH_COVERAGE = float(os.environ.get("COVERAGE_PATCH_THRESHOLD", "85"))

@dataclass
class SessionManifest:
    """Session tracking for automation runs."""
    command: str
    timestamp: str
    duration: float
    success: bool
    args: Dict[str, Any]
    result: Dict[str, Any]

def run_command(cmd: List[str], timeout: int = 60, cwd: Path = ROOT) -> Tuple[bool, str]:
    """Execute shell command with timeout and error handling."""
    try:
        proc = subprocess.run(
            cmd,
            cwd=cwd,
            capture_output=True,
            text=True,
            timeout=timeout,
            shell=(os.name == 'nt')  # Use shell on Windows
        )
        output = proc.stdout.strip()
        if proc.stderr.strip():
            output += f"\n{proc.stderr.strip()}"
        return proc.returncode == 0, output
    except FileNotFoundError:
        return False, f"Command not found: {cmd[0]}"
    except subprocess.TimeoutExpired:
        return False, f"Command timed out: {' '.join(cmd)}"
    except Exception as e:
        return False, f"Command failed: {e}"

def load_config() -> Dict[str, Any]:
    """Load automation configuration."""
    if not CONFIG_FILE.exists():
        return {}

    if yaml is None:
        print(f"Warning: Cannot load {CONFIG_FILE} - PyYAML not installed")
        return {}

    try:
        with open(CONFIG_FILE, 'r', encoding='utf-8') as f:
            return yaml.safe_load(f) or {}
    except Exception as e:
        print(f"Warning: Failed to load {CONFIG_FILE}: {e}")
        return {}

def detect_project_language() -> str:
    """Detect primary project language based on files present."""
    config = load_config()
    detect_patterns = config.get('detect', {})

    for language, patterns in detect_patterns.items():
        for pattern in patterns:
            if '*' in pattern:
                if list(ROOT.glob(pattern)):
                    return language
            elif (ROOT / pattern).exists():
                return language

    # Fallback detection
    if (ROOT / "pyproject.toml").exists() or (ROOT / "requirements.txt").exists():
        return "python"
    elif (ROOT / "package.json").exists():
        return "node"
    elif (ROOT / "pom.xml").exists() or (ROOT / "build.gradle").exists():
        return "java"
    elif (ROOT / "go.mod").exists():
        return "go"
    elif (ROOT / "Cargo.toml").exists():
        return "rust"
    elif list(ROOT.glob("*.csproj")) or list(ROOT.glob("*.sln")):
        return "csharp"
    elif (ROOT / "pubspec.yaml").exists():
        return "flutter"

    return "unknown"

def get_language_command(task: str, language: str = None) -> Optional[str]:
    """Get language-specific command for a task."""
    if language is None:
        language = detect_project_language()

    config = load_config()
    tasks = config.get('tasks', {})
    task_commands = tasks.get(task, {})

    return task_commands.get(language) or task_commands.get('default')

def load_feature_matrix() -> Dict[str, Any]:
    """Load feature matrix configuration."""
    if not FEATURE_MATRIX.exists():
        return {
            "features": [],
            "epics": [],
            "version": "1.0.0",
            "app": "Project"
        }

    if yaml is None:
        print(f"Warning: Cannot load {FEATURE_MATRIX} - PyYAML not installed")
        return {"features": [], "epics": []}

    try:
        with open(FEATURE_MATRIX, 'r', encoding='utf-8') as f:
            return yaml.safe_load(f) or {"features": [], "epics": []}
    except Exception as e:
        print(f"Warning: Failed to load {FEATURE_MATRIX}: {e}")
        return {"features": [], "epics": []}

def save_feature_matrix(data: Dict[str, Any]) -> bool:
    """Save feature matrix configuration."""
    if yaml is None:
        print("Error: Cannot save feature matrix - PyYAML not installed")
        return False

    try:
        FEATURE_MATRIX.parent.mkdir(parents=True, exist_ok=True)
        with open(FEATURE_MATRIX, 'w', encoding='utf-8') as f:
            yaml.dump(data, f, default_flow_style=False, sort_keys=False)
        return True
    except Exception as e:
        print(f"Error: Failed to save {FEATURE_MATRIX}: {e}")
        return False

def parse_coverage_file(coverage_path: Path) -> Optional[Dict[str, Any]]:
    """Parse coverage file and extract metrics."""
    if not coverage_path.exists():
        return None

    try:
        if coverage_path.suffix == '.info':
            # LCOV format
            return parse_lcov(coverage_path)
        elif coverage_path.suffix == '.json':
            # JSON format (Jest, etc.)
            return parse_coverage_json(coverage_path)
        elif coverage_path.suffix == '.xml':
            # XML format (JaCoCo, etc.)
            return parse_coverage_xml(coverage_path)
    except Exception as e:
        print(f"Warning: Failed to parse coverage file {coverage_path}: {e}")

    return None

def parse_lcov(path: Path) -> Dict[str, Any]:
    """Parse LCOV format coverage file."""
    lines_hit = 0
    lines_found = 0
    files_covered = {}

    current_file = None

    with open(path, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if line.startswith('SF:'):
                # Source file
                current_file = line[3:].replace('\\', '/')
                files_covered[current_file] = {'lines_found': 0, 'lines_hit': 0}
            elif line.startswith('LF:'):
                # Lines found
                found = int(line[3:])
                lines_found += found
                if current_file:
                    files_covered[current_file]['lines_found'] = found
            elif line.startswith('LH:'):
                # Lines hit
                hit = int(line[3:])
                lines_hit += hit
                if current_file:
                    files_covered[current_file]['lines_hit'] = hit
            elif line == 'end_of_record':
                current_file = None

    line_coverage = (lines_hit / lines_found * 100) if lines_found > 0 else 0

    return {
        'format': 'lcov',
        'line_coverage': round(line_coverage, 2),
        'lines_hit': lines_hit,
        'lines_found': lines_found,
        'files_covered': files_covered
    }

def parse_coverage_json(path: Path) -> Dict[str, Any]:
    """Parse JSON format coverage file (Jest, nyc, etc.)."""
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    if 'total' in data:
        # NYC/Istanbul format
        total = data['total']
        line_coverage = total.get('lines', {}).get('pct', 0)

        return {
            'format': 'json',
            'line_coverage': line_coverage,
            'branch_coverage': total.get('branches', {}).get('pct', 0),
            'function_coverage': total.get('functions', {}).get('pct', 0),
            'statement_coverage': total.get('statements', {}).get('pct', 0)
        }

    return {'format': 'json', 'line_coverage': 0}

def parse_coverage_xml(path: Path) -> Dict[str, Any]:
    """Parse XML format coverage file (JaCoCo, Cobertura, etc.)."""
    # Simplified XML parsing - would need full XML parser for production
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Basic JaCoCo XML parsing
    if 'jacoco' in content.lower():
        # Extract line rate from JaCoCo XML
        import re
        line_match = re.search(r'line-rate="([0-9.]+)"', content)
        if line_match:
            line_coverage = float(line_match.group(1)) * 100
            return {
                'format': 'jacoco-xml',
                'line_coverage': round(line_coverage, 2)
            }

    return {'format': 'xml', 'line_coverage': 0}

def find_coverage_files() -> List[Path]:
    """Find coverage files in the project."""
    language = detect_project_language()
    config = load_config()

    # Get language-specific coverage file patterns
    coverage_config = config.get('coverage', {})
    file_patterns = coverage_config.get('files', {})
    patterns = file_patterns.get(language, ['coverage/lcov.info'])

    found_files = []
    for pattern in patterns:
        if isinstance(pattern, str):
            matches = list(ROOT.glob(pattern))
            found_files.extend(matches)

    return found_files

def get_current_branch() -> Optional[str]:
    """Get current git branch."""
    ok, output = run_command(["git", "branch", "--show-current"], timeout=10)
    return output if ok and output else None

def suggest_next_feature() -> Optional[Dict[str, Any]]:
    """Suggest next feature to work on based on priority and status."""
    matrix = load_feature_matrix()
    features = matrix.get('features', [])

    # Find planned features ordered by priority
    planned = [f for f in features if f.get('status') == 'planned']

    if not planned:
        return None

    # Sort by priority (P0 > P1 > P2 > P3)
    priority_order = {'P0': 0, 'P1': 1, 'P2': 2, 'P3': 3}
    planned.sort(key=lambda f: priority_order.get(f.get('priority', 'P3'), 3))

    return planned[0] if planned else None

def create_feature_branch(feature_id: str, dry_run: bool = False) -> Dict[str, Any]:
    """Create git branch for feature."""
    result = {
        "created": False,
        "branch": None,
        "base": None,
        "exists": False
    }

    base_branch = get_current_branch()
    result["base"] = base_branch

    # Sanitize feature ID for branch name
    sanitized = feature_id.replace(" ", "_").replace("/", "_").replace(".", "_")
    branch_name = f"feat/{sanitized}"
    result["branch"] = branch_name

    if dry_run:
        return result

    # Check if git is available
    git_ok, _ = run_command(["git", "--version"], timeout=5)
    if not git_ok:
        result["error"] = "git_not_available"
        return result

    # Check if branch already exists
    exists_ok, _ = run_command(["git", "rev-parse", "--verify", branch_name], timeout=10)
    if exists_ok:
        result["exists"] = True
        # Switch to existing branch if not already there
        if base_branch != branch_name:
            checkout_ok, checkout_output = run_command(["git", "checkout", branch_name], timeout=20)
            if not checkout_ok:
                result["error"] = f"checkout_failed: {checkout_output}"
        return result

    # Create new branch
    create_ok, create_output = run_command(["git", "checkout", "-b", branch_name], timeout=30)
    if create_ok:
        result["created"] = True
    else:
        result["error"] = f"branch_create_failed: {create_output}"

    return result

def update_feature_status(feature_id: str, new_status: str, dry_run: bool = False) -> Tuple[bool, Optional[str], Optional[str]]:
    """Update feature status in matrix."""
    matrix = load_feature_matrix()
    features = matrix.get('features', [])

    prev_status = None
    updated = False

    for feature in features:
        if feature.get('id') == feature_id:
            prev_status = feature.get('status')
            if not dry_run:
                feature['status'] = new_status
                updated = save_feature_matrix(matrix)
            else:
                updated = True
            break

    return updated, prev_status, new_status

def generate_feature_scaffold(feature_id: str, dry_run: bool = False) -> Dict[str, Any]:
    """Generate basic feature scaffold."""
    language = detect_project_language()
    result = {
        "language": language,
        "created": [],
        "errors": []
    }

    if dry_run:
        result["created"] = [f"features/{feature_id}/README.md"]
        return result

    # Create feature directory
    feature_dir = ROOT / "features" / feature_id
    try:
        feature_dir.mkdir(parents=True, exist_ok=True)

        # Create basic README
        readme_path = feature_dir / "README.md"
        with open(readme_path, 'w', encoding='utf-8') as f:
            f.write(f"""# {feature_id.title()} Feature

## Overview

TODO: Describe the feature purpose and scope

## Implementation Status

- [ ] Domain logic
- [ ] Data layer
- [ ] Presentation layer
- [ ] Tests
- [ ] Documentation

## Architecture

TODO: Document key components and patterns

## Testing

TODO: Document test strategy and requirements

## Notes

TODO: Implementation notes and decisions
""")

        result["created"].append(str(readme_path.relative_to(ROOT)))

    except Exception as e:
        result["errors"].append(f"Failed to create scaffold: {e}")

    return result

def run_tests_with_coverage() -> Tuple[bool, Dict[str, Any]]:
    """Run tests with coverage measurement."""
    language = detect_project_language()
    test_cmd = get_language_command('test-coverage', language)

    if not test_cmd:
        return False, {"error": "no_test_command_configured"}

    # Run tests
    test_ok, test_output = run_command(test_cmd.split(), timeout=300)

    # Find and parse coverage
    coverage_files = find_coverage_files()
    coverage_data = None

    for cov_file in coverage_files:
        coverage_data = parse_coverage_file(cov_file)
        if coverage_data:
            break

    result = {
        "tests_passed": test_ok,
        "test_output": test_output,
        "coverage": coverage_data
    }

    return test_ok, result

def save_session_manifest(command: str, args: Dict[str, Any], result: Dict[str, Any],
                         success: bool, duration: float):
    """Save session manifest for tracking."""
    SESSIONS_DIR.mkdir(exist_ok=True)

    manifest = SessionManifest(
        command=command,
        timestamp=datetime.now(timezone.utc).isoformat(),
        duration=duration,
        success=success,
        args=args,
        result=result
    )

    timestamp = datetime.now().strftime("%Y%m%dT%H%M%S")
    manifest_file = SESSIONS_DIR / f"session_{timestamp}.json"

    try:
        with open(manifest_file, 'w', encoding='utf-8') as f:
            json.dump(asdict(manifest), f, indent=2)
    except Exception as e:
        print(f"Warning: Failed to save session manifest: {e}")

# Command implementations

def cmd_status(args) -> Dict[str, Any]:
    """Show project and feature development status."""
    language = detect_project_language()
    matrix = load_feature_matrix()
    features = matrix.get('features', [])

    # Count features by status
    status_counts = {}
    for feature in features:
        status = feature.get('status', 'unknown')
        status_counts[status] = status_counts.get(status, 0) + 1

    # Get current branch
    current_branch = get_current_branch()

    # Find coverage files
    coverage_files = find_coverage_files()
    coverage_status = "not_found"
    if coverage_files:
        coverage_status = "found"
        # Try to parse latest coverage
        for cov_file in coverage_files:
            cov_data = parse_coverage_file(cov_file)
            if cov_data:
                coverage_status = f"{cov_data.get('line_coverage', 0):.1f}%"
                break

    result = {
        "project_language": language,
        "project_root": str(ROOT),
        "current_branch": current_branch,
        "feature_status_counts": status_counts,
        "total_features": len(features),
        "coverage_status": coverage_status,
        "coverage_files": [str(f.relative_to(ROOT)) for f in coverage_files]
    }

    return result

def cmd_health(args) -> Dict[str, Any]:
    """Validate development environment health."""
    language = detect_project_language()
    health_cmd = get_language_command('doctor', language)

    checks = []
    overall_healthy = True

    # Check language environment
    if health_cmd:
        ok, output = run_command(health_cmd.split(), timeout=30)
        checks.append({
            "name": f"{language}_environment",
            "passed": ok,
            "output": output
        })
        overall_healthy = overall_healthy and ok

    # Check git
    git_ok, git_output = run_command(["git", "--version"], timeout=10)
    checks.append({
        "name": "git",
        "passed": git_ok,
        "output": git_output
    })
    overall_healthy = overall_healthy and git_ok

    # Check configuration files
    config_exists = CONFIG_FILE.exists()
    checks.append({
        "name": "automation_config",
        "passed": config_exists,
        "output": f"Config file: {CONFIG_FILE}" if config_exists else "automation.config.yaml not found"
    })

    # Check if in git repo
    git_repo_ok, _ = run_command(["git", "rev-parse", "--git-dir"], timeout=10)
    checks.append({
        "name": "git_repository",
        "passed": git_repo_ok,
        "output": "Git repository detected" if git_repo_ok else "Not in a git repository"
    })
    overall_healthy = overall_healthy and git_repo_ok

    return {
        "healthy": overall_healthy,
        "language": language,
        "checks": checks
    }

def cmd_coverage(args) -> Dict[str, Any]:
    """Analyze test coverage and generate report."""
    coverage_files = find_coverage_files()

    if not coverage_files:
        return {
            "error": "no_coverage_files_found",
            "searched_patterns": find_coverage_files.__doc__
        }

    results = []
    overall_coverage = None

    for cov_file in coverage_files:
        cov_data = parse_coverage_file(cov_file)
        if cov_data:
            results.append({
                "file": str(cov_file.relative_to(ROOT)),
                "coverage_data": cov_data
            })

            # Use first valid coverage as overall
            if overall_coverage is None:
                overall_coverage = cov_data.get('line_coverage', 0)

    # Check thresholds
    global_threshold_met = overall_coverage >= MIN_GLOBAL_COVERAGE if overall_coverage else False

    return {
        "coverage_files": results,
        "overall_coverage": overall_coverage,
        "global_threshold": MIN_GLOBAL_COVERAGE,
        "threshold_met": global_threshold_met,
        "analysis_complete": len(results) > 0
    }

def cmd_start_next_feature(args) -> Dict[str, Any]:
    """Start work on the next planned feature."""
    feature_id = getattr(args, 'feature_id', None)
    dry_run = getattr(args, 'dry_run', False)
    auto_commit = getattr(args, 'auto_commit', False)

    # Determine feature to start
    if feature_id:
        matrix = load_feature_matrix()
        feature_record = next((f for f in matrix.get('features', []) if f.get('id') == feature_id), None)
        if not feature_record:
            return {"error": "feature_not_found", "feature_id": feature_id}
    else:
        feature_record = suggest_next_feature()
        if not feature_record:
            return {"error": "no_planned_features"}
        feature_id = feature_record.get('id')

    # Create git branch
    branch_result = create_feature_branch(feature_id, dry_run)

    # Generate scaffold
    scaffold_result = generate_feature_scaffold(feature_id, dry_run)

    # Update feature status
    status_updated, prev_status, new_status = update_feature_status(feature_id, 'in_progress', dry_run)

    result = {
        "feature_id": feature_id,
        "feature_record": feature_record,
        "git_branch": branch_result,
        "scaffold": scaffold_result,
        "status_update": {
            "updated": status_updated,
            "previous": prev_status,
            "new": new_status
        },
        "dry_run": dry_run
    }

    # Auto-commit if requested
    if auto_commit and not dry_run and not branch_result.get("error"):
        files_to_add = []

        # Add scaffold files
        files_to_add.extend(scaffold_result.get('created', []))

        # Add feature matrix if updated
        if status_updated:
            files_to_add.append(str(FEATURE_MATRIX.relative_to(ROOT)))

        if files_to_add:
            # Stage files
            for file_path in files_to_add:
                run_command(["git", "add", file_path], timeout=15)

            # Commit
            commit_msg = f"feat: start {feature_id} development"
            commit_ok, commit_output = run_command(["git", "commit", "-m", commit_msg], timeout=30)

            result["auto_commit"] = {
                "attempted": True,
                "success": commit_ok,
                "files": files_to_add,
                "message": commit_msg,
                "output": commit_output
            }

    return result

def cmd_finalize_feature(args) -> Dict[str, Any]:
    """Finalize feature development with validation."""
    feature_id = getattr(args, 'feature_id', None)
    dry_run = getattr(args, 'dry_run', False)
    skip_tests = getattr(args, 'skip_tests', False)
    auto_merge = getattr(args, 'auto_merge', False)

    # Infer feature ID from branch if not provided
    if not feature_id:
        current_branch = get_current_branch()
        if current_branch and current_branch.startswith('feat/'):
            # Extract feature ID from branch name
            branch_suffix = current_branch.split('/', 1)[1]
            feature_id = branch_suffix.replace('_', '.')  # Reverse sanitization

    if not feature_id:
        return {"error": "feature_id_required"}

    # Validate feature exists and is in progress
    matrix = load_feature_matrix()
    feature_record = next((f for f in matrix.get('features', []) if f.get('id') == feature_id), None)
    if not feature_record:
        return {"error": "feature_not_found", "feature_id": feature_id}

    current_status = feature_record.get('status')
    if current_status != 'in_progress':
        return {
            "error": "invalid_status",
            "expected": "in_progress",
            "actual": current_status,
            "feature_id": feature_id
        }

    # Run validation checks
    validations = {}

    # Test validation
    if skip_tests:
        validations["tests"] = {"skipped": True}
        tests_ok = True
    else:
        tests_ok, test_result = run_tests_with_coverage()
        validations["tests"] = {
            "passed": tests_ok,
            "details": test_result
        }

    # Coverage validation
    coverage_result = cmd_coverage(args)
    coverage_ok = coverage_result.get('threshold_met', False)
    validations["coverage"] = {
        "threshold_met": coverage_ok,
        "details": coverage_result
    }

    all_validations_pass = tests_ok and coverage_ok

    # Update feature status if validations pass
    status_result = None
    if all_validations_pass:
        status_updated, prev_status, new_status = update_feature_status(feature_id, 'done', dry_run)
        status_result = {
            "updated": status_updated,
            "previous": prev_status,
            "new": new_status
        }

    result = {
        "feature_id": feature_id,
        "validations": validations,
        "all_validations_pass": all_validations_pass,
        "status_update": status_result,
        "dry_run": dry_run
    }

    # Auto-commit and merge if all validations pass
    if all_validations_pass and not dry_run:
        # Stage all changes
        run_command(["git", "add", "."], timeout=60)

        # Commit
        commit_msg = f"feat: finalize {feature_id}"
        commit_ok, commit_output = run_command(["git", "commit", "-m", commit_msg], timeout=60)

        commit_result = {
            "attempted": True,
            "success": commit_ok,
            "message": commit_msg,
            "output": commit_output
        }

        # Push and merge if requested
        if commit_ok and auto_merge:
            current_branch = get_current_branch()
            if current_branch and current_branch != "main":
                # Push feature branch
                push_ok, push_output = run_command(["git", "push", "origin", current_branch], timeout=90)
                commit_result["push"] = {
                    "success": push_ok,
                    "output": push_output
                }

                # Merge to main if push succeeded
                if push_ok:
                    # Switch to main
                    switch_ok, switch_output = run_command(["git", "checkout", "main"], timeout=30)
                    if switch_ok:
                        # Pull latest
                        pull_ok, pull_output = run_command(["git", "pull", "origin", "main"], timeout=60)
                        if pull_ok:
                            # Merge feature branch
                            merge_ok, merge_output = run_command(["git", "merge", current_branch], timeout=60)
                            if merge_ok:
                                # Push merged changes
                                push_main_ok, push_main_output = run_command(["git", "push", "origin", "main"], timeout=90)
                                # Clean up feature branch
                                if push_main_ok:
                                    run_command(["git", "branch", "-d", current_branch], timeout=30)
                                    run_command(["git", "push", "origin", "--delete", current_branch], timeout=60)

                            commit_result["merge"] = {
                                "success": merge_ok and push_main_ok,
                                "output": f"Merge: {merge_output}, Push: {push_main_output}"
                            }

        result["commit"] = commit_result

    return result

def cmd_upload_coverage(dry_run=False, **kwargs):
    """Upload coverage reports to Codecov.

    Uploads test coverage data to Codecov with proper token validation and error handling.
    Supports multiple coverage formats and project configurations.

    Args:
        dry_run: If True, shows what would be uploaded without actually uploading
        **kwargs: Additional arguments like token, flags, etc.

    Returns:
        Dict with upload status and results
    """
    result = {
        "coverage_found": [],
        "codecov_token": None,
        "upload_success": False,
        "upload_output": "",
        "error": None
    }

    try:
        project_root = detect_project_root()

        # Check for Codecov token
        token = kwargs.get('token') or os.environ.get('CODECOV_TOKEN')
        if not token:
            result["error"] = "codecov_token_missing"
            result["message"] = "CODECOV_TOKEN environment variable not set. Get token from https://codecov.io"
            return result

        result["codecov_token"] = "***" + token[-4:] if len(token) > 4 else "***"

        # Find coverage files
        coverage_patterns = [
            "coverage/lcov.info",           # LCOV format (JavaScript, Dart, etc.)
            "coverage.xml",                 # XML format (Python, Java, etc.)
            "coverage.json",                # JSON format
            "coverage.out",                 # Go format
            "**/target/site/jacoco/jacoco.xml",  # Java Maven
            "**/build/reports/jacoco/test/jacocoTestReport.xml",  # Java Gradle
            "cobertura.xml",                # Cobertura format
            "**/*.profdata",                # Swift/Objective-C
            "lcov.dat",                     # Alternative LCOV
            "coverage/clover.xml"           # Clover format
        ]

        import glob
        found_files = []
        for pattern in coverage_patterns:
            matches = glob.glob(str(project_root / pattern), recursive=True)
            found_files.extend(matches)

        if not found_files:
            result["error"] = "no_coverage_files"
            result["message"] = "No coverage files found. Run tests with coverage first."
            return result

        result["coverage_found"] = [os.path.relpath(f, project_root) for f in found_files]

        if dry_run:
            result["message"] = f"Would upload {len(found_files)} coverage files"
            result["dry_run"] = True
            return result

        # Install codecov CLI if not available
        codecov_cmd = "codecov"
        codecov_ok, _ = run_command([codecov_cmd, "--help"], timeout=10, capture_output=True)

        if not codecov_ok:
            # Try to install codecov
            print("📦 Installing Codecov CLI...")
            install_ok, install_output = run_command([
                sys.executable, "-m", "pip", "install", "codecov"
            ], timeout=60)

            if not install_ok:
                result["error"] = "codecov_install_failed"
                result["message"] = f"Failed to install codecov: {install_output}"
                return result

        # Build upload command
        upload_cmd = [codecov_cmd]

        # Add token
        upload_cmd.extend(["-t", token])

        # Add flags if specified
        flags = kwargs.get('flags', [])
        if isinstance(flags, str):
            flags = [flags]
        for flag in flags:
            upload_cmd.extend(["-F", flag])

        # Add specific files if found
        for coverage_file in found_files[:3]:  # Limit to first 3 files to avoid command line length issues
            upload_cmd.extend(["-f", coverage_file])

        # Add additional options
        upload_cmd.extend([
            "--name", f"coverage-{datetime.now().strftime('%Y%m%d-%H%M%S')}",
            "--fail-on-error"
        ])

        # Execute upload
        print(f"🚀 Uploading {len(found_files)} coverage files to Codecov...")
        upload_ok, upload_output = run_command(upload_cmd, timeout=120)

        result["upload_success"] = upload_ok
        result["upload_output"] = upload_output

        if not upload_ok:
            result["error"] = "upload_failed"
            result["message"] = f"Codecov upload failed: {upload_output}"
        else:
            result["message"] = "Coverage uploaded successfully to Codecov"

    except Exception as e:
        result["error"] = f"upload_error: {str(e)}"

    return result

# Command registry
COMMANDS = {
    'status': cmd_status,
    'health': cmd_health,
    'coverage': cmd_coverage,
    'upload-coverage': cmd_upload_coverage,
    'start-next-feature': cmd_start_next_feature,
    'finalize-feature': cmd_finalize_feature
}

def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Framework-agnostic development assistant",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Available commands:
  status              Show project and feature development status
  health              Validate development environment
  coverage            Analyze test coverage
  upload-coverage     Upload coverage reports to Codecov
  start-next-feature  Begin work on next planned feature
  finalize-feature    Complete feature with validation

Examples:
  python dev_assistant.py status
  python dev_assistant.py health
  python dev_assistant.py coverage
  python dev_assistant.py upload-coverage
  python dev_assistant.py upload-coverage --token YOUR_TOKEN --flags unit
  python dev_assistant.py start-next-feature --dry-run
  python dev_assistant.py finalize-feature --feature-id user.login

Additional tools:
  python ai_docs_assistant.py --interactive    # Generate documentation with AI
  python setup_codecov.py --interactive        # Setup Codecov integration
"""
    )

    parser.add_argument('command', choices=COMMANDS.keys(), help='Command to execute')
    parser.add_argument('--dry-run', action='store_true', help='Show what would be done without making changes')
    parser.add_argument('--json', action='store_true', help='Output results as JSON')

    # Coverage arguments
    parser.add_argument('--token', help='Codecov token (can also use CODECOV_TOKEN env var)')
    parser.add_argument('--flags', nargs='*', help='Coverage flags for Codecov upload')

    # Feature-specific arguments
    parser.add_argument('--feature-id', help='Specific feature ID to work with')
    parser.add_argument('--skip-tests', action='store_true', help='Skip test validation (finalize-feature)')
    parser.add_argument('--auto-commit', action='store_true', help='Automatically commit changes')
    parser.add_argument('--auto-merge', action='store_true', help='Automatically merge to main branch')

    args = parser.parse_args()

    # Execute command
    start_time = time.time()
    command_func = COMMANDS[args.command]

    try:
        result = command_func(args)
        success = not result.get('error')
        duration = time.time() - start_time

        # Save session manifest
        save_session_manifest(
            command=args.command,
            args=vars(args),
            result=result,
            success=success,
            duration=duration
        )

        # Output result
        if args.json:
            print(json.dumps(result, indent=2))
        else:
            if success:
                print(f"✅ {args.command} completed successfully")
                if args.command == 'status':
                    print(f"📊 Project: {result.get('project_language')} in {result.get('project_root')}")
                    print(f"🌿 Branch: {result.get('current_branch')}")
                    print(f"📈 Coverage: {result.get('coverage_status')}")
                    print(f"📋 Features: {result.get('total_features')} total, {result.get('feature_status_counts')}")
                elif args.command == 'health':
                    print(f"🏥 Environment: {'healthy' if result.get('healthy') else 'issues detected'}")
                    for check in result.get('checks', []):
                        status = '✅' if check.get('passed') else '❌'
                        print(f"  {status} {check.get('name')}: {check.get('output')}")
                elif args.command == 'coverage':
                    coverage = result.get('overall_coverage')
                    threshold = result.get('global_threshold')
                    status = '✅' if result.get('threshold_met') else '❌'
                    print(f"📊 {status} Coverage: {coverage:.1f}% (threshold: {threshold}%)")
                elif args.command == 'upload-coverage':
                    files_count = len(result.get('coverage_found', []))
                    upload_success = result.get('upload_success')
                    status = '✅' if upload_success else '❌'
                    if result.get('dry_run'):
                        print(f"🏃 Dry run: Would upload {files_count} coverage files")
                    else:
                        print(f"📤 {status} Coverage upload: {files_count} files")
                        if upload_success:
                            print("🎉 Coverage data sent to Codecov successfully")
                elif args.command == 'start-next-feature':
                    feature_id = result.get('feature_id')
                    branch = result.get('git_branch', {}).get('branch')
                    print(f"🚀 Started feature: {feature_id}")
                    print(f"🌿 Branch: {branch}")
                elif args.command == 'finalize-feature':
                    feature_id = result.get('feature_id')
                    passed = result.get('all_validations_pass')
                    status = '✅' if passed else '❌'
                    print(f"{status} Feature {feature_id}: {'finalized' if passed else 'validation failed'}")
            else:
                print(f"❌ {args.command} failed: {result.get('error')}")
                sys.exit(1)

    except KeyboardInterrupt:
        print("\n⚠️  Operation cancelled by user")
        sys.exit(130)
    except Exception as e:
        duration = time.time() - start_time
        error_result = {"error": f"unexpected_error: {e}"}

        save_session_manifest(
            command=args.command,
            args=vars(args),
            result=error_result,
            success=False,
            duration=duration
        )

        print(f"💥 Unexpected error: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()
