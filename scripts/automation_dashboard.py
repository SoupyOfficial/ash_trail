#!/usr/bin/env python3
"""
Interactive Automation Dashboard

A terminal-based dashboard for monitoring and controlling AshTrail automation.
"""

import json
import time
import subprocess
import sys
from pathlib import Path
from datetime import datetime
import yaml

ROOT = Path(__file__).resolve().parent.parent

class AutomationDashboard:
    """Interactive dashboard for automation monitoring."""
    
    def __init__(self):
        self.running = True
        
    def clear_screen(self):
        """Clear terminal screen."""
        subprocess.run(['cls' if sys.platform == 'win32' else 'clear'], shell=True)
    
    def load_feature_matrix(self):
        """Load available features."""
        try:
            with open(ROOT / "feature_matrix.yaml", 'r') as f:
                data = yaml.safe_load(f)
            return data.get('features', [])
        except Exception as e:
            return []
    
    def get_system_status(self):
        """Get current system status."""
        try:
            result = subprocess.run([
                sys.executable, 
                str(ROOT / "scripts" / "automation_monitor.py"), 
                "check", "--json"
            ], capture_output=True, text=True, cwd=ROOT)
            
            if result.returncode == 0:
                return json.loads(result.stdout)
            else:
                return {"status": "❌ Error getting status", "issues": ["Monitor script failed"]}
        except Exception as e:
            return {"status": "❌ Error getting status", "issues": [str(e)]}
    
    def get_metrics(self):
        """Get automation metrics."""
        try:
            result = subprocess.run([
                sys.executable, 
                str(ROOT / "scripts" / "automation_monitor.py"), 
                "metrics", "--json"
            ], capture_output=True, text=True, cwd=ROOT)
            
            if result.returncode == 0:
                return json.loads(result.stdout)
            else:
                return {"executions": []}
        except Exception as e:
            return {"executions": []}
    
    def render_header(self):
        """Render dashboard header."""
        print("=" * 80)
        print("🚀 AshTrail Automation Dashboard".center(80))
        print("=" * 80)
        print(f"Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print()
    
    def render_system_status(self, status):
        """Render system status section."""
        print("📊 SYSTEM STATUS")
        print("-" * 40)
        print(f"Status: {status.get('status', 'Unknown')}")
        print(f"Duration: {status.get('duration', 0):.2f}s")
        
        issues = status.get('issues', [])
        critical = len([i for i in issues if i.startswith("❌")])
        warnings = len([i for i in issues if i.startswith("⚠️")])
        
        print(f"Issues: {critical} critical, {warnings} warnings")
        
        if issues:
            print("\nRecent Issues:")
            for issue in issues[-3:]:  # Show last 3
                print(f"  {issue}")
        
        print()
    
    def render_metrics(self, metrics):
        """Render metrics section."""
        print("📈 AUTOMATION METRICS")
        print("-" * 40)
        
        executions = metrics.get('executions', [])
        if not executions:
            print("No executions recorded yet")
            print()
            return
        
        # Calculate success rate
        successful = len([e for e in executions if e.get('success', False)])
        total = len(executions)
        success_rate = (successful / total * 100) if total > 0 else 0
        
        print(f"Total Executions: {total}")
        print(f"Success Rate: {success_rate:.1f}%")
        print(f"Last 24h: {len([e for e in executions[-10:]])}")
        
        print("\nRecent Executions:")
        for exec_record in executions[-5:]:
            status_icon = "✅" if exec_record.get('success', False) else "❌"
            timestamp = exec_record.get('timestamp', '')[:16]
            exec_type = exec_record.get('type', 'unknown')
            feature_id = exec_record.get('feature_id', '')
            
            if feature_id:
                print(f"  {status_icon} {timestamp} - {exec_type} ({feature_id})")
            else:
                print(f"  {status_icon} {timestamp} - {exec_type}")
        
        print()
    
    def render_features(self, features):
        """Render available features section."""
        print("🎯 AVAILABLE FEATURES")
        print("-" * 40)
        
        if not features:
            print("No features found in feature_matrix.yaml")
            print()
            return
        
        # Group by status
        by_status = {}
        for feature in features:
            status = feature.get('status', 'unknown')
            if status not in by_status:
                by_status[status] = []
            by_status[status].append(feature)
        
        for status, status_features in by_status.items():
            print(f"{status.upper()}: {len(status_features)} features")
        
        print("\nReady to Implement (planned):")
        planned = by_status.get('planned', [])
        for feature in planned[:5]:  # Show first 5
            priority = feature.get('priority', 'P?')
            print(f"  [{priority}] {feature.get('id', 'unknown')} - {feature.get('title', 'No title')}")
        
        if len(planned) > 5:
            print(f"  ... and {len(planned) - 5} more")
        
        print()
    
    def render_menu(self):
        """Render interactive menu."""
        print("🎮 ACTIONS")
        print("-" * 40)
        print("1. Run health check")
        print("2. Implement feature")
        print("3. View full metrics")
        print("4. Open troubleshooting guide")
        print("5. Refresh dashboard")
        print("0. Exit")
        print()
    
    def handle_menu_choice(self, choice):
        """Handle menu selection."""
        if choice == "1":
            self.run_health_check()
        elif choice == "2":
            self.implement_feature()
        elif choice == "3":
            self.view_full_metrics()
        elif choice == "4":
            self.open_troubleshooting()
        elif choice == "5":
            pass  # Will refresh automatically
        elif choice == "0":
            self.running = False
        else:
            print("Invalid choice. Press Enter to continue...")
            input()
    
    def run_health_check(self):
        """Run interactive health check."""
        self.clear_screen()
        print("🔍 Running Health Check...")
        print()
        
        try:
            result = subprocess.run([
                sys.executable, 
                str(ROOT / "scripts" / "automation_monitor.py"), 
                "check"
            ], cwd=ROOT)
            
            print("\nHealth check completed.")
        except Exception as e:
            print(f"Error running health check: {e}")
        
        print("\nPress Enter to continue...")
        input()
    
    def implement_feature(self):
        """Interactive feature implementation."""
        self.clear_screen()
        print("🚀 Feature Implementation")
        print()
        
        # Load features
        features = self.load_feature_matrix()
        planned = [f for f in features if f.get('status') == 'planned']
        
        if not planned:
            print("No planned features available for implementation.")
            print("Press Enter to continue...")
            input()
            return
        
        print("Available features:")
        for i, feature in enumerate(planned[:10], 1):
            priority = feature.get('priority', 'P?')
            print(f"{i:2d}. [{priority}] {feature.get('id', 'unknown')} - {feature.get('title', 'No title')}")
        
        print("\nEnter feature number or ID (0 to cancel): ", end="")
        choice = input().strip()
        
        if choice == "0":
            return
        
        feature_id = None
        if choice.isdigit() and 1 <= int(choice) <= len(planned):
            feature_id = planned[int(choice) - 1].get('id')
        else:
            # Try as direct ID
            feature_id = choice
        
        if not feature_id:
            print("Invalid selection.")
            print("Press Enter to continue...")
            input()
            return
        
        print(f"\n🚀 Implementing feature: {feature_id}")
        print("This will create a new branch and scaffold the feature...")
        print("Continue? (y/N): ", end="")
        
        if input().strip().lower() != 'y':
            return
        
        try:
            subprocess.run([
                sys.executable,
                str(ROOT / "scripts" / "auto_implement_feature.py"),
                feature_id
            ], cwd=ROOT)
            
            print(f"\n✅ Feature {feature_id} implementation started!")
        except Exception as e:
            print(f"\n❌ Error implementing feature: {e}")
        
        print("Press Enter to continue...")
        input()
    
    def view_full_metrics(self):
        """View detailed metrics."""
        self.clear_screen()
        print("📊 Detailed Metrics")
        print()
        
        try:
            subprocess.run([
                sys.executable,
                str(ROOT / "scripts" / "automation_monitor.py"),
                "metrics"
            ], cwd=ROOT)
        except Exception as e:
            print(f"Error getting metrics: {e}")
        
        print("\nPress Enter to continue...")
        input()
    
    def open_troubleshooting(self):
        """Open troubleshooting guide."""
        guide_path = ROOT / "docs" / "automation-troubleshooting.md"
        
        if guide_path.exists():
            print("📚 Opening troubleshooting guide...")
            
            if sys.platform == 'win32':
                subprocess.run(['notepad', str(guide_path)])
            elif sys.platform == 'darwin':
                subprocess.run(['open', str(guide_path)])
            else:
                subprocess.run(['xdg-open', str(guide_path)])
        else:
            print("Troubleshooting guide not found.")
            print("Press Enter to continue...")
            input()
    
    def run(self):
        """Run the interactive dashboard."""
        try:
            while self.running:
                self.clear_screen()
                
                # Get current data
                status = self.get_system_status()
                metrics = self.get_metrics()
                features = self.load_feature_matrix()
                
                # Render dashboard
                self.render_header()
                self.render_system_status(status)
                self.render_metrics(metrics)
                self.render_features(features)
                self.render_menu()
                
                # Get user input
                try:
                    choice = input("Select action: ").strip()
                    self.handle_menu_choice(choice)
                except KeyboardInterrupt:
                    self.running = False
                except EOFError:
                    self.running = False
        
        except Exception as e:
            print(f"Dashboard error: {e}")
        finally:
            print("\n👋 Thanks for using AshTrail Automation Dashboard!")


if __name__ == "__main__":
    dashboard = AutomationDashboard()
    dashboard.run()
