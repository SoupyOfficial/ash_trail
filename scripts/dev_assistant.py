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
    python scripts/dev_assistant.py health        # Run health check
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

def run_command(cmd: List[str], cwd: Path = ROOT) -> tuple[bool, str]:
    """Run a command and return success status and output."""
    try:
        result = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)
        return result.returncode == 0, result.stdout + result.stderr
    except Exception as e:
        return False, str(e)

def check_health() -> Dict:
    """Run health check and return status."""
    print("🔍 Running health check...")
    
    health_status = {
        "flutter": False,
        "git": False,
        "issues": [],
        "recommendations": []
    }
    
    # Check Flutter
    success, output = run_command(["flutter", "--version"])
    health_status["flutter"] = success
    if not success:
        health_status["issues"].append("Flutter not found in PATH")
        health_status["recommendations"].append("Install Flutter SDK and add to PATH")
    
    # Check Git
    success, output = run_command(["git", "status", "--porcelain"])
    health_status["git"] = success
    if success and output.strip():
        health_status["issues"].append(f"Uncommitted changes: {len(output.strip().split())} files")
        health_status["recommendations"].append("Commit or stash changes before development")
    
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

def main():
    parser = argparse.ArgumentParser(description='AshTrail Development Assistant')
    parser.add_argument('command', choices=['status', 'features', 'issues', 'health'],
                       help='Command to run')
    
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

if __name__ == "__main__":
    main()
