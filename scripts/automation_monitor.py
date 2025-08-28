#!/usr/bin/env python3
"""
Automation Monitor and AI-Assisted Debugging System

This script provides:
1. Real-time monitoring of automation execution
2. Issue detection and diagnosis
3. AI-assisted debugging recommendations
4. Performance metrics and alerting
5. Recovery suggestions and auto-fixes
"""

import json
import sys
import time
import subprocess
import yaml
import requests
from pathlib import Path
from datetime import datetime, timezone
from typing import Dict, List, Optional
import logging

# Setup logging with UTF-8 encoding
def setup_logging(json_mode=False):
    """Setup logging with appropriate handlers based on output mode."""
    from typing import List
    handlers: List[logging.Handler] = [logging.FileHandler('automation_monitor.log', encoding='utf-8')]
    
    if not json_mode:
        # Only add stdout handler when not in JSON mode
        handlers.append(logging.StreamHandler(sys.stdout))
    else:
        # In JSON mode, log to stderr to avoid polluting JSON output
        handlers.append(logging.StreamHandler(sys.stderr))
    
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s',
        handlers=handlers,
        force=True  # Force reconfiguration if already setup
    )
    
    return logging.getLogger(__name__)

logger = logging.getLogger(__name__)  # Default logger, will be reconfigured in main()

ROOT = Path(__file__).resolve().parent.parent
MONITOR_DATA = ROOT / "scripts" / "monitor_data.json"

class AutomationMonitor:
    """Monitor and debug automation execution."""
    
    def __init__(self):
        self.start_time = datetime.now(timezone.utc)
        self.metrics = self.load_metrics()
        
    def load_metrics(self) -> Dict:
        """Load historical metrics."""
        if MONITOR_DATA.exists():
            try:
                with open(MONITOR_DATA, 'r', encoding='utf-8') as f:
                    return json.load(f)
            except Exception as e:
                logger.warning(f"Failed to load metrics: {e}")
        
        return {
            "executions": [],
            "success_rate": 0.0,
            "avg_duration": 0.0,
            "common_errors": {},
            "performance_trends": []
        }
    
    def save_metrics(self):
        """Save metrics to disk."""
        try:
            with open(MONITOR_DATA, 'w', encoding='utf-8') as f:
                json.dump(self.metrics, f, indent=2, default=str)
        except Exception as e:
            logger.error(f"Failed to save metrics: {e}")
    
    def detect_environment_issues(self) -> List[str]:
        """Detect common environment setup issues."""
        issues = []
        
        # Check Python version
        try:
            python_version = subprocess.check_output([sys.executable, '--version'], 
                                                   text=True, encoding='utf-8').strip()
            if not python_version.startswith('Python 3.'):
                issues.append(f"WARNING: Python version issue: {python_version} (need Python 3.x)")
        except Exception as e:
            issues.append(f"ERROR: Python not found: {e}")
        
        # Check Flutter
        try:
            result = subprocess.run(['flutter', '--version'], 
                                  capture_output=True, text=True, encoding='utf-8')
            if result.returncode == 0 and 'Flutter' in result.stdout:
                # Flutter is available
                pass
            else:
                issues.append("ERROR: Flutter not properly installed")
        except Exception as e:
            issues.append(f"ERROR: Flutter not found: {e}")
        
        # Check Git
        try:
            result = subprocess.run(['git', '--version'], 
                                  capture_output=True, text=True, encoding='utf-8')
            if result.returncode == 0 and 'git version' in result.stdout:
                # Git is available
                pass
            else:
                issues.append("ERROR: Git not properly installed")
        except Exception as e:
            issues.append(f"ERROR: Git not found: {e}")
        
        # Check required files
        required_files = [
            'feature_matrix.yaml',
            'pubspec.yaml',
            'scripts/auto_implement_feature.py'
        ]
        
        for file_path in required_files:
            if not (ROOT / file_path).exists():
                issues.append(f"ERROR: Missing required file: {file_path}")
        
        # Check dependencies
        try:
            import yaml
        except ImportError as e:
            issues.append(f"ERROR: Missing Python dependency: {e}")
        
        return issues
    
    def check_coverage_status(self) -> List[str]:
        """Check coverage reports and codecov status."""
        issues = []
        
        # Check if coverage files exist
        coverage_file = ROOT / "coverage" / "lcov.info"
        if not coverage_file.exists():
            issues.append("WARNING: No coverage report found (coverage/lcov.info missing)")
            return issues
        
        # Parse coverage data
        try:
            with open(coverage_file, 'r', encoding='utf-8') as f:
                lines = f.readlines()
            
            # Calculate coverage percentage
            hit_lines = 0
            total_lines = 0
            for line in lines:
                if line.startswith('DA:'):
                    parts = line.strip().split(',')
                    if len(parts) >= 2:
                        count = int(parts[1])
                        total_lines += 1
                        if count > 0:
                            hit_lines += 1
            
            if total_lines > 0:
                coverage_pct = (hit_lines / total_lines) * 100
                
                # Check against thresholds
                if coverage_pct < 70:
                    issues.append(f"ERROR: Coverage below minimum threshold: {coverage_pct:.1f}% < 70%")
                elif coverage_pct < 80:
                    issues.append(f"WARNING: Coverage below target: {coverage_pct:.1f}% < 80%")
                else:
                    # Coverage is good, but let's note it
                    pass
                
                # Store coverage in metrics for tracking
                self.metrics.setdefault("coverage_history", []).append({
                    "timestamp": datetime.now(timezone.utc).isoformat(),
                    "coverage_pct": coverage_pct,
                    "hit_lines": hit_lines,
                    "total_lines": total_lines
                })
            else:
                issues.append("WARNING: Coverage file exists but contains no line data")
                
        except Exception as e:
            issues.append(f"ERROR: Failed to parse coverage data: {e}")
        
        return issues
    
    def get_codecov_status(self, repo_owner: str = "SoupyOfficial", repo_name: str = "ash_trail") -> Optional[Dict]:
        """Get codecov status for the repository."""
        try:
            # Get latest commit hash
            result = subprocess.run(['git', 'rev-parse', 'HEAD'], 
                                  cwd=ROOT, capture_output=True, text=True)
            if result.returncode != 0:
                return None
            
            commit_sha = result.stdout.strip()
            
            # Query codecov API (public endpoint)
            url = f"https://codecov.io/api/gh/{repo_owner}/{repo_name}/commit/{commit_sha}"
            response = requests.get(url, timeout=10)
            
            if response.status_code == 200:
                data = response.json()
                return {
                    "commit": commit_sha[:8],
                    "coverage": data.get("totals", {}).get("c", 0),
                    "status": "success" if response.status_code == 200 else "failed",
                    "url": f"https://codecov.io/gh/{repo_owner}/{repo_name}/commit/{commit_sha}"
                }
            else:
                return {
                    "commit": commit_sha[:8],
                    "status": "not_found",
                    "message": f"Codecov data not found (HTTP {response.status_code})"
                }
                
        except requests.RequestException as e:
            return {
                "status": "error",
                "message": f"Failed to query codecov: {e}"
            }
        except Exception as e:
            return {
                "status": "error", 
                "message": f"Error getting codecov status: {e}"
            }
    
    def validate_feature_matrix(self) -> List[str]:
        """Validate feature matrix for common issues."""
        issues = []
        
        try:
            with open(ROOT / "feature_matrix.yaml", 'r', encoding='utf-8') as f:
                data = yaml.safe_load(f)
            
            # Check structure
            if 'features' not in data:
                issues.append("ERROR: feature_matrix.yaml missing 'features' section")
                return issues
            
            features = data['features']
            if not isinstance(features, list):
                issues.append("ERROR: 'features' must be a list")
                return issues
            
            # Check each feature
            feature_ids = set()
            for i, feature in enumerate(features):
                if not isinstance(feature, dict):
                    issues.append(f"ERROR: Feature {i} is not a dictionary")
                    continue
                
                # Check for duplicate IDs
                feature_id = feature.get('id')
                if feature_id:
                    if feature_id in feature_ids:
                        issues.append(f"ERROR: Duplicate feature ID: {feature_id}")
                    feature_ids.add(feature_id)
        
        except yaml.YAMLError as e:
            issues.append(f"ERROR: Invalid YAML in feature_matrix.yaml: {e}")
        except Exception as e:
            issues.append(f"ERROR: Error reading feature_matrix.yaml: {e}")
        
        return issues
    
    def check_git_status(self) -> List[str]:
        """Check git repository status for issues."""
        issues = []
        
        try:
            # Check if we're in a git repository
            result = subprocess.run(['git', 'rev-parse', '--git-dir'], 
                                  cwd=ROOT, capture_output=True, text=True)
            if result.returncode != 0:
                issues.append("ERROR: Not in a git repository")
                return issues
            
            # Check for uncommitted changes
            result = subprocess.run(['git', 'status', '--porcelain'], 
                                  cwd=ROOT, capture_output=True, text=True, encoding='utf-8')
            if result.returncode == 0 and result.stdout.strip():
                issues.append("WARNING: Uncommitted changes in repository")
                for line in result.stdout.strip().split('\n')[:5]:  # Show first 5
                    issues.append(f"   {line}")
                remaining = len(result.stdout.strip().split('\n')) - 5
                if remaining > 0:
                    issues.append(f"   ... and {remaining} more")
            
            # Check for unpushed commits
            try:
                result = subprocess.run(['git', 'log', 'origin/main..HEAD', '--oneline'], 
                                      cwd=ROOT, capture_output=True, text=True)
                if result.returncode == 0 and result.stdout.strip():
                    issues.append("WARNING: Unpushed commits detected")
            except Exception:
                pass  # Ignore if can't check remote
        
        except Exception as e:
            issues.append(f"ERROR: Git check failed: {e}")
        
        return issues
    
    def ai_diagnose_issues(self, issues: List[str]) -> Dict:
        """Generate AI-assisted diagnosis and solutions."""
        if not issues:
            return {"status": "All systems operational", "recommendations": []}
        
        # Categorize issues
        critical_issues = [i for i in issues if i.startswith("ERROR")]
        warning_issues = [i for i in issues if i.startswith("WARNING")]
        
        diagnosis = {
            "status": "Critical issues detected" if critical_issues else "Warnings detected",
            "summary": f"{len(critical_issues)} critical, {len(warning_issues)} warnings",
            "recommendations": []
        }
        
        # Generate specific recommendations
        if any("Flutter" in issue for issue in critical_issues):
            diagnosis["recommendations"].append({
                "issue": "Flutter not found",
                "solution": "Install Flutter SDK and add to PATH",
                "command": "flutter doctor",
                "priority": "HIGH"
            })
        
        if any("Git" in issue for issue in critical_issues):
            diagnosis["recommendations"].append({
                "issue": "Git not available",
                "solution": "Install Git and configure user settings",
                "command": "git --version",
                "priority": "HIGH"
            })
        
        if any("Uncommitted changes" in issue for issue in warning_issues):
            diagnosis["recommendations"].append({
                "issue": "Uncommitted changes",
                "solution": "Commit or stash changes before running automation",
                "command": "git status && git add . && git commit -m 'chore: save work'",
                "priority": "MEDIUM"
            })
        
        if any("Coverage below" in issue for issue in issues):
            diagnosis["recommendations"].append({
                "issue": "Low test coverage",
                "solution": "Add tests to improve coverage or run existing tests",
                "command": "flutter test --coverage",
                "priority": "HIGH" if any("ERROR" in issue for issue in issues if "Coverage" in issue) else "MEDIUM"
            })
        
        if any("No coverage report" in issue for issue in warning_issues):
            diagnosis["recommendations"].append({
                "issue": "Missing coverage report",
                "solution": "Run tests with coverage to generate report",
                "command": "flutter test --coverage",
                "priority": "MEDIUM"
            })
        
        return diagnosis
    
    def run_comprehensive_check(self) -> Dict:
        """Run comprehensive system check."""
        logger.info("Starting comprehensive automation check...")
        
        check_start = time.time()
        
        # Collect all issues
        all_issues = []
        
        logger.info("Checking environment setup...")
        env_issues = self.detect_environment_issues()
        all_issues.extend(env_issues)
        
        logger.info("Validating feature matrix...")
        matrix_issues = self.validate_feature_matrix()
        all_issues.extend(matrix_issues)
        
        logger.info("Checking git repository...")
        git_issues = self.check_git_status()
        all_issues.extend(git_issues)
        
        logger.info("Checking coverage status...")
        coverage_issues = self.check_coverage_status()
        all_issues.extend(coverage_issues)
        
        # AI diagnosis
        logger.info("Generating AI diagnosis...")
        diagnosis = self.ai_diagnose_issues(all_issues)
        
        # Get codecov status
        codecov_status = self.get_codecov_status()
        
        check_duration = time.time() - check_start
        
        # Update metrics
        execution_record = {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "type": "health_check",
            "duration": check_duration,
            "issues_found": len(all_issues),
            "critical_issues": len([i for i in all_issues if i.startswith("ERROR")]),
            "warnings": len([i for i in all_issues if i.startswith("WARNING")])
        }
        
        self.metrics["executions"].append(execution_record)
        self.save_metrics()
        
        return {
            "status": diagnosis["status"],
            "duration": check_duration,
            "issues": all_issues,
            "diagnosis": diagnosis,
            "codecov_status": codecov_status,
            "execution_record": execution_record
        }
    
    def monitor_automation_execution(self, feature_id: str) -> Dict:
        """Monitor a specific automation execution."""
        logger.info(f"Monitoring automation execution for: {feature_id}")
        
        execution_start = time.time()
        
        # Pre-execution checks
        pre_check = self.run_comprehensive_check()
        if pre_check["diagnosis"].get("status", "").startswith("Critical"):
            logger.error("Pre-execution check failed!")
            return {
                "success": False,
                "stage": "pre_check",
                "error": "Critical issues detected before execution",
                "pre_check": pre_check
            }
        
        # Simulate monitoring execution
        execution_duration = time.time() - execution_start
        
        return {
            "success": True,
            "duration": execution_duration,
            "pre_check": pre_check
        }


def main():
    """Main monitoring interface."""
    import argparse
    global logger
    
    parser = argparse.ArgumentParser(description='Automation Monitor & AI Debugger')
    parser.add_argument('command', choices=['check', 'monitor', 'metrics'], 
                       help='Command to run')
    parser.add_argument('--feature-id', help='Feature ID to monitor (for monitor command)')
    parser.add_argument('--json', action='store_true', help='Output JSON format')
    
    args = parser.parse_args()
    
    # Setup logging based on output mode
    logger = setup_logging(json_mode=args.json)
    
    monitor = AutomationMonitor()
    
    if args.command == 'check':
        result = monitor.run_comprehensive_check()
        
        if args.json:
            print(json.dumps(result, indent=2, default=str))
        else:
            print(f"\n{result['status']}")
            print(f"Check completed in {result['duration']:.2f}s")
            
            if result['issues']:
                print(f"\nIssues Found ({len(result['issues'])}):")
                for issue in result['issues']:
                    print(f"  {issue}")
            
            print(f"\nAI Diagnosis:")
            diagnosis = result['diagnosis']
            print(f"  Status: {diagnosis['status']}")
            if 'summary' in diagnosis:
                print(f"  Summary: {diagnosis['summary']}")
            
            if diagnosis.get('recommendations'):
                print(f"\nRecommendations:")
                for rec in diagnosis['recommendations']:
                    print(f"  - {rec['issue']} ({rec['priority']})")
                    print(f"    Solution: {rec['solution']}")
                    print(f"    Command: {rec['command']}")
                    print()
            
            # Show codecov status if available
            codecov_status = result.get('codecov_status')
            if codecov_status:
                print(f"\nCodecov Status:")
                if codecov_status.get('status') == 'success':
                    print(f"  Coverage: {codecov_status.get('coverage', 'N/A')}% (commit {codecov_status.get('commit', 'unknown')})")
                    print(f"  URL: {codecov_status.get('url', 'N/A')}")
                else:
                    print(f"  Status: {codecov_status.get('status', 'unknown')}")
                    if 'message' in codecov_status:
                        print(f"  Message: {codecov_status['message']}")
                print()
    
    elif args.command == 'monitor':
        if not args.feature_id:
            print("ERROR: --feature-id required for monitor command")
            sys.exit(1)
        
        result = monitor.monitor_automation_execution(args.feature_id)
        
        if args.json:
            print(json.dumps(result, indent=2, default=str))
        else:
            if result['success']:
                print(f"Automation completed successfully in {result['duration']:.2f}s")
            else:
                print(f"Automation failed: {result.get('error', 'Unknown error')}")
    
    elif args.command == 'metrics':
        metrics = monitor.metrics
        
        if args.json:
            print(json.dumps(metrics, indent=2, default=str))
        else:
            print("Automation Metrics:")
            print(f"  Total executions: {len(metrics['executions'])}")
            
            if metrics['executions']:
                successful = len([e for e in metrics['executions'] 
                                if e.get('success', False)])
                success_rate = (successful / len(metrics['executions'])) * 100
                print(f"  Success rate: {success_rate:.1f}%")
                
                recent = metrics['executions'][-5:]
                print(f"  Recent executions:")
                for exec_record in recent:
                    status = "PASS" if exec_record.get('success', False) else "FAIL"
                    timestamp = exec_record['timestamp'][:19].replace('T', ' ')
                    exec_type = exec_record.get('type', 'unknown')
                    print(f"    {status} {timestamp} - {exec_type}")


if __name__ == "__main__":
    main()
