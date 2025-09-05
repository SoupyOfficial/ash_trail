#!/usr/bin/env python3
"""
AshTrail Development Assistant

Simple script to help manage AI-assisted development workflow.
Provides utilities for checking project status, creating feature requests,
and monitoring development progress.

Usage:
    python scripts/dev_assistant.py status        # Check project status
    python scripts/dev_assistant.py features      # List next features to implement
    python scripts/dev_assistant.py issues        # Show GitHub issues summary
    python s    # Test upload preparation
    print("\n🔄 Validating coverage file...")
    try:
        coverage_info = get_coverage_summary()
        if coverage_info:
            coverage_pct = coverage_info["line_coverage"]
            lines_hit = coverage_info["lines_hit"]
            lines_found = coverage_info["lines_found"]
            print(f"✅ Coverage data: {coverage_pct:.1f}% ({lines_hit}/{lines_found} lines)")
        else:
            print("⚠️ Could not parse coverage data")
    except Exception as e:
        print(f"⚠️ Coverage parsing error: {e}")
    
    # Show upload command
    print("\n🚀 Ready for upload!")
    print("💡 To upload coverage:")
    if codecov_token:
        print("   python scripts/dev_assistant.py upload-codecov")
    else:
        print("   codecov -f coverage/lcov.info")
        print("   (or set CODECOV_TOKEN and use: python scripts/dev_assistant.py upload-codecov)")
    
    return True.py health        # Run health check
"""

import os
import sys
import json
import subprocess
import yaml
import argparse
from pathlib import Path
from typing import Dict, List, Optional
from datetime import datetime

# Setup paths
ROOT = Path(__file__).resolve().parent.parent
SCRIPTS_DIR = ROOT / "scripts"
FEATURE_MATRIX = ROOT / "feature_matrix.yaml"

def run_command(cmd: List[str], cwd: Path = ROOT, timeout: int = 30) -> tuple[bool, str]:
    """Run a command and return success status and output."""
    try:
        # On Windows, use shell=True to properly resolve commands in PATH
        result = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, shell=True, timeout=timeout)
        return result.returncode == 0, result.stdout + result.stderr
    except subprocess.TimeoutExpired:
        return False, f"Command timed out after {timeout} seconds"
    except Exception as e:
        return False, str(e)

def get_coverage_summary() -> Optional[Dict]:
    """Parse coverage report and return summary statistics."""
    coverage_file = ROOT / "coverage" / "lcov.info"
    if not coverage_file.exists():
        return None
    
    try:
        with open(coverage_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Parse LCOV format
        lines_found = 0
        lines_hit = 0
        
        for line in content.split('\n'):
            if line.startswith('LF:'):  # Lines found
                lines_found += int(line.split(':')[1])
            elif line.startswith('LH:'):  # Lines hit
                lines_hit += int(line.split(':')[1])
        
        if lines_found > 0:
            coverage_pct = (lines_hit / lines_found) * 100
            return {
                "line_coverage": coverage_pct,
                "lines_found": lines_found,
                "lines_hit": lines_hit
            }
        
        return None
    except Exception:
        return None

def check_health() -> Dict:
    """Run health check and return status."""
    print("🔍 Running health check...")
    
    health_status = {
        "flutter": False,
        "git": False,
        "codecov": False,
        "coverage": False,
        "issues": [],
        "recommendations": []
    }
    
    # Check Flutter with shorter timeout
    try:
        success, output = run_command(["flutter", "--version"], timeout=10)
        health_status["flutter"] = success
        if not success:
            health_status["issues"].append("Flutter not found in PATH")
            health_status["recommendations"].append("Install Flutter SDK and add to PATH")
        else:
            # Extract Flutter version for reporting
            version_line = output.split('\n')[0] if output else ""
            if version_line:
                print(f"   Flutter: {version_line}")
    except Exception as e:
        health_status["flutter"] = False
        health_status["issues"].append(f"Flutter check failed: {str(e)[:50]}")
    
    # Check Git
    try:
        success, output = run_command(["git", "status", "--porcelain"], timeout=5)
        health_status["git"] = success
        if success:
            if output.strip():
                changed_files = len(output.strip().split('\n'))
                health_status["issues"].append(f"Uncommitted changes: {changed_files} files")
                health_status["recommendations"].append("Commit or stash changes before development")
    except Exception as e:
        health_status["git"] = False
        health_status["issues"].append(f"Git check failed: {str(e)[:50]}")
    
    # Check Codecov CLI
    try:
        success, output = run_command(["codecov", "--version"], timeout=5)
        health_status["codecov"] = success
        if success and output:
            codecov_version = output.split('\n')[0] if output else ""
            print(f"   Codecov: {codecov_version}")
        elif not success:
            health_status["issues"].append("Codecov CLI not found")
            health_status["recommendations"].append("Install Codecov CLI: npm install -g codecov")
    except Exception as e:
        health_status["codecov"] = False
        health_status["issues"].append("Codecov CLI not available")
    
    # Check coverage report
    coverage_file = ROOT / "coverage" / "lcov.info"
    health_status["coverage"] = coverage_file.exists()
    if not coverage_file.exists():
        health_status["issues"].append("No coverage report found")
        health_status["recommendations"].append("Run: flutter test --coverage")
    else:
        # Parse coverage percentage
        try:
            coverage_info = get_coverage_summary()
            if coverage_info:
                coverage_pct = coverage_info.get("line_coverage", 0)
                print(f"   Coverage: {coverage_pct:.1f}%")
                if coverage_pct < 80:
                    health_status["issues"].append(f"Coverage below target: {coverage_pct:.1f}% < 80%")
                    health_status["recommendations"].append("Add tests to improve coverage")
        except Exception:
            pass
    
    # Check Codecov token (optional)
    codecov_token = os.environ.get("CODECOV_TOKEN")
    if not codecov_token:
        health_status["issues"].append("CODECOV_TOKEN not set (optional for local dev)")
        health_status["recommendations"].append("Set CODECOV_TOKEN for coverage uploads")
    else:
        print(f"   Codecov Token: Set")
    
    return health_status

def get_project_status() -> Dict:
    """Get overall project status."""
    print("📊 Checking project status...")
    
    status = {
        "features": {"total": 0, "planned": 0, "in_progress": 0, "completed": 0},
        "files": {"total": 0, "dart": 0, "test": 0},
        "git": {"branch": "unknown", "commits": 0}
    }
    
    # Check feature matrix
    if FEATURE_MATRIX.exists():
        try:
            with open(FEATURE_MATRIX, 'r', encoding='utf-8') as f:
                data = yaml.safe_load(f)
            
            features = data.get('features', [])
            status["features"]["total"] = len(features)
            
            for feature in features:
                feature_status = feature.get('status', 'planned')
                if feature_status in status["features"]:
                    status["features"][feature_status] += 1
        
        except Exception as e:
            print(f"⚠️ Error reading feature matrix: {e}")
    
    # Count files
    lib_dir = ROOT / "lib"
    if lib_dir.exists():
        dart_files = list(lib_dir.rglob("*.dart"))
        status["files"]["dart"] = len(dart_files)
    
    test_dir = ROOT / "test"
    if test_dir.exists():
        test_files = list(test_dir.rglob("*.dart"))
        status["files"]["test"] = len(test_files)
    
    status["files"]["total"] = status["files"]["dart"] + status["files"]["test"]
    
    # Git info
    success, output = run_command(["git", "branch", "--show-current"])
    if success:
        status["git"]["branch"] = output.strip()
    
    success, output = run_command(["git", "rev-list", "--count", "HEAD"])
    if success:
        try:
            status["git"]["commits"] = int(output.strip())
        except ValueError:
            pass
    
    return status

def get_next_features(limit: int = 5) -> List[Dict]:
    """Get next features to implement."""
    print("🎯 Finding next features to implement...")
    
    if not FEATURE_MATRIX.exists():
        print("⚠️ Feature matrix not found")
        return []
    
    try:
        with open(FEATURE_MATRIX, 'r', encoding='utf-8') as f:
            data = yaml.safe_load(f)
        
        features = data.get('features', [])
        
        # Filter planned features
        planned_features = [f for f in features if f.get('status') == 'planned']
        
        # Sort by priority
        priority_order = {'P0': 0, 'P1': 1, 'P2': 2, 'P3': 3}
        planned_features.sort(key=lambda x: priority_order.get(x.get('priority', 'P3'), 99))
        
        return planned_features[:limit]
    
    except Exception as e:
        print(f"⚠️ Error reading features: {e}")
        return []

def get_github_issues_summary() -> Dict:
    """Get summary of GitHub issues."""
    print("📋 Checking GitHub issues...")
    
    summary = {
        "total": 0,
        "open": 0,
        "closed": 0,
        "by_label": {},
        "recent": []
    }
    
    # Try to get issues using gh CLI
    success, output = run_command(["gh", "issue", "list", "--limit", "10", "--json", "number,title,labels,state,createdAt"])
    
    if success:
        try:
            issues = json.loads(output)
            summary["total"] = len(issues)
            
            for issue in issues:
                if issue["state"] == "open":
                    summary["open"] += 1
                else:
                    summary["closed"] += 1
                
                # Count labels
                for label in issue.get("labels", []):
                    label_name = label["name"]
                    summary["by_label"][label_name] = summary["by_label"].get(label_name, 0) + 1
                
                # Add to recent list
                summary["recent"].append({
                    "number": issue["number"],
                    "title": issue["title"],
                    "state": issue["state"]
                })
        
        except json.JSONDecodeError:
            print("⚠️ Failed to parse GitHub issues")
    else:
        print("⚠️ GitHub CLI not available or not authenticated")
    
    return summary

def print_status_report():
    """Print comprehensive status report."""
    print("🚀 AshTrail Development Status Report")
    print("=" * 50)
    
    # Health check
    health = check_health()
    print(f"\n🏥 Health Status:")
    print(f"   Flutter: {'✅' if health['flutter'] else '❌'}")
    print(f"   Git: {'✅' if health['git'] else '❌'}")
    print(f"   Coverage: {'✅' if health['coverage'] else '❌'}")
    print(f"   Codecov: {'✅' if health['codecov'] else '⚠️ '}")
    
    if health["issues"]:
        print(f"   Issues: {len(health['issues'])}")
        for issue in health["issues"]:
            print(f"     ⚠️ {issue}")
    
    # Project status
    status = get_project_status()
    print(f"\n📊 Project Status:")
    print(f"   Branch: {status['git']['branch']}")
    print(f"   Commits: {status['git']['commits']}")
    print(f"   Files: {status['files']['total']} total ({status['files']['dart']} lib, {status['files']['test']} test)")
    
    # Coverage summary
    coverage_info = get_coverage_summary()
    if coverage_info:
        coverage_pct = coverage_info["line_coverage"]
        coverage_icon = "✅" if coverage_pct >= 80 else "⚠️" if coverage_pct >= 70 else "❌"
        print(f"   Coverage: {coverage_icon} {coverage_pct:.1f}%")
    
    print(f"\n🎯 Features:")
    features = status['features']
    print(f"   Total: {features['total']}")
    print(f"   Planned: {features['planned']}")
    print(f"   In Progress: {features['in_progress']}")
    print(f"   Completed: {features['completed']}")
    
    # Next features
    next_features = get_next_features(3)
    if next_features:
        print(f"\n🔥 Next Priority Features:")
        for i, feature in enumerate(next_features, 1):
            print(f"   {i}. {feature['id']} ({feature.get('priority', 'P3')}) - {feature['title']}")
    
    # GitHub issues
    issues = get_github_issues_summary()
    if issues["total"] > 0:
        print(f"\n📋 GitHub Issues:")
        print(f"   Open: {issues['open']}, Closed: {issues['closed']}")
        
        if issues["by_label"]:
            print(f"   Top Labels:")
            sorted_labels = sorted(issues["by_label"].items(), key=lambda x: x[1], reverse=True)
            for label, count in sorted_labels[:3]:
                print(f"     {label}: {count}")
    
    # Quick actions
    print(f"\n⚡ Quick Actions:")
    print(f"   python scripts/dev_assistant.py features  # List next features")
    print(f"   python scripts/dev_assistant.py coverage  # Check coverage")
    print(f"   python scripts/dev_assistant.py test-coverage  # Run tests with coverage")

def print_features_list():
    """Print list of features to implement."""
    print("🎯 Next Features to Implement")
    print("=" * 40)
    
    features = get_next_features(10)
    
    if not features:
        print("🎉 No planned features found - all done!")
        return
    
    for i, feature in enumerate(features, 1):
        priority = feature.get('priority', 'P3')
        epic = feature.get('epic', 'Unknown')
        title = feature['title']
        feature_id = feature['id']
        
        print(f"\n{i}. [{priority}] {title}")
        print(f"   ID: {feature_id}")
        print(f"   Epic: {epic}")
        
        # Show acceptance criteria if available
        acceptance = feature.get('acceptance', [])
        if acceptance:
            print(f"   Acceptance Criteria: {len(acceptance)} items")
    
    print(f"\n💡 To implement a feature:")
    print(f"   1. Create a GitHub issue using the feature request template")
    print(f"   2. Use the trigger: #github-pull-request_copilot-coding-agent")
    print(f"   3. Provide the feature details and requirements")

def print_issues_summary():
    """Print GitHub issues summary."""
    print("📋 GitHub Issues Summary")
    print("=" * 30)
    
    issues = get_github_issues_summary()
    
    if issues["total"] == 0:
        print("No issues found (or GitHub CLI not available)")
        return
    
    print(f"Total Issues: {issues['total']}")
    print(f"Open: {issues['open']}, Closed: {issues['closed']}")
    
    if issues["by_label"]:
        print(f"\nBy Label:")
        sorted_labels = sorted(issues["by_label"].items(), key=lambda x: x[1], reverse=True)
        for label, count in sorted_labels:
            print(f"   {label}: {count}")
    
    if issues["recent"]:
        print(f"\nRecent Issues:")
        for issue in issues["recent"][:5]:
            state_icon = "🟢" if issue["state"] == "open" else "🔴"
            print(f"   {state_icon} #{issue['number']}: {issue['title']}")

def print_coverage_report():
    """Print detailed coverage report."""
    print("📊 Coverage Report")
    print("=" * 25)
    
    coverage_info = get_coverage_summary()
    
    if not coverage_info:
        print("❌ No coverage data available")
        print("\n💡 To generate coverage:")
        print("   flutter test --coverage")
        return
    
    coverage_pct = coverage_info["line_coverage"]
    lines_hit = coverage_info["lines_hit"]
    lines_found = coverage_info["lines_found"]
    
    # Status based on coverage percentage
    if coverage_pct >= 90:
        status_icon = "🟢"
        status = "Excellent"
    elif coverage_pct >= 80:
        status_icon = "🟡"
        status = "Good"
    elif coverage_pct >= 70:
        status_icon = "🟠"
        status = "Needs Improvement"
    else:
        status_icon = "🔴"
        status = "Critical"
    
    print(f"{status_icon} Overall Coverage: {coverage_pct:.1f}% ({status})")
    print(f"   Lines Hit: {lines_hit:,}")
    print(f"   Lines Found: {lines_found:,}")
    print(f"   Lines Missing: {lines_found - lines_hit:,}")
    
    # Coverage targets
    print(f"\n🎯 Targets:")
    print(f"   Project Target: 80.0% ({'✅' if coverage_pct >= 80 else '❌'})")
    print(f"   Domain Target: 90.0% (component-specific)")
    print(f"   Core Target: 85.0% (component-specific)")
    
    # Recommendations
    if coverage_pct < 80:
        print(f"\n💡 Recommendations:")
        print(f"   • Focus on domain layer (business logic)")
        print(f"   • Add unit tests for use cases")
        print(f"   • Test error handling scenarios")
        print(f"   • Add widget tests for key interactions")
    
    # Codecov integration
    codecov_token = os.environ.get("CODECOV_TOKEN")
    if codecov_token:
        print(f"\n☁️ Upload to Codecov:")
        print(f"   codecov -f coverage/lcov.info")
    else:
        print(f"\n☁️ Codecov Integration:")
        print(f"   Set CODECOV_TOKEN environment variable to upload coverage")
    
    # Coverage file info
    coverage_file = ROOT / "coverage" / "lcov.info"
    if coverage_file.exists():
        file_size = coverage_file.stat().st_size
        modified_time = datetime.fromtimestamp(coverage_file.stat().st_mtime)
        print(f"\n📄 Coverage File:")
        print(f"   Size: {file_size:,} bytes")
        print(f"   Modified: {modified_time.strftime('%Y-%m-%d %H:%M:%S')}")

def test_codecov_upload():
    """Test Codecov upload functionality."""
    print("🧪 Testing Codecov Upload")
    print("=" * 30)
    
    # Check if coverage exists
    coverage_file = ROOT / "coverage" / "lcov.info"
    if not coverage_file.exists():
        print("❌ No coverage file found")
        print("� Run: flutter test --coverage")
        return False
    
    # Check Codecov CLI
    success, output = run_command(["codecov", "--version"], timeout=5)
    if not success:
        print("❌ Codecov CLI not found")
        print("💡 Install: npm install -g codecov")
        return False
    
    print(f"✅ Codecov CLI: {output.split()[1] if output else 'installed'}")
    
    # Check token
    codecov_token = os.environ.get("CODECOV_TOKEN")
    if not codecov_token:
        print("⚠️ CODECOV_TOKEN not set")
        print("💡 Coverage will upload anonymously (may have limitations)")
    else:
        print("✅ CODECOV_TOKEN: Set")
    
    # Test upload (dry run first)
    print("\n� Testing upload (dry run)...")
    success, output = run_command([
        "codecov", 
        "-f", "coverage/lcov.info",
        "--dry-run"
    ], timeout=15)
    
    if success:
        print("✅ Dry run successful!")
        print("📊 Coverage file is valid for upload")
        
        # Ask if user wants to do actual upload
        print("\n🚀 Ready for actual upload")
        print("💡 To upload: codecov -f coverage/lcov.info")
        return True
    else:
        print("❌ Dry run failed")
        print(f"Error: {output}")
        return False

def upload_to_codecov():
    """Upload coverage to Codecov."""
    print("☁️ Uploading Coverage to Codecov")
    print("=" * 40)
    
    # Verify prerequisites
    coverage_file = ROOT / "coverage" / "lcov.info"
    if not coverage_file.exists():
        print("❌ No coverage file found")
        print("💡 Run: flutter test --coverage")
        return False
    
    # Upload to Codecov
    print("🔄 Uploading to Codecov...")
    success, output = run_command([
        "codecov", 
        "-f", "coverage/lcov.info",
        "-F", "flutter_tests"
    ], timeout=30)
    
    if success:
        print("✅ Upload successful!")
        print("🔗 Check results at: https://codecov.io/gh/SoupyOfficial/ash_trail")
        return True
    else:
        print("❌ Upload failed")
        print(f"Error: {output}")
        print("\n💡 Troubleshooting:")
        print("   • Check internet connection")
        print("   • Verify CODECOV_TOKEN is correct")
        print("   • Ensure repository exists on Codecov")
        return False

def run_coverage_analysis():
    """Run tests with coverage and generate report."""
    print("🧪 Running Coverage Analysis")
    print("=" * 35)
    
    print("🔄 Running tests with coverage...")
    success, output = run_command(["flutter", "test", "--coverage"], timeout=60)
    
    if not success:
        print("❌ Tests failed!")
        print(output)
        return False
    
    print("✅ Tests completed successfully")
    
    # Show coverage summary
    print("\n📊 Coverage Summary:")
    coverage_info = get_coverage_summary()
    
    if coverage_info:
        coverage_pct = coverage_info["line_coverage"]
        print(f"   Overall Coverage: {coverage_pct:.1f}%")
        
        if coverage_pct >= 80:
            print("   ✅ Coverage target met!")
        else:
            print(f"   ❌ Coverage below target (need {80 - coverage_pct:.1f}% more)")
    
    return True

def main():
    parser = argparse.ArgumentParser(description='AshTrail Development Assistant')
    parser.add_argument('command', choices=[
        'status', 'features', 'issues', 'health', 'coverage', 
        'test-coverage', 'test-codecov', 'upload-codecov'
    ], help='Command to run')
    
    args = parser.parse_args()
    
    if args.command == 'status':
        print_status_report()
    elif args.command == 'features':
        print_features_list()
    elif args.command == 'issues':
        print_issues_summary()
    elif args.command == 'health':
        health = check_health()
        if health["issues"]:
            print(f"❌ Issues found:")
            for issue in health["issues"]:
                print(f"   • {issue}")
            print(f"\n💡 Recommendations:")
            for rec in health["recommendations"]:
                print(f"   • {rec}")
        else:
            print("✅ All health checks passed!")
    elif args.command == 'coverage':
        print_coverage_report()
    elif args.command == 'test-coverage':
        run_coverage_analysis()
    elif args.command == 'test-codecov':
        test_codecov_upload()
    elif args.command == 'upload-codecov':
        upload_to_codecov()

if __name__ == "__main__":
    main()
