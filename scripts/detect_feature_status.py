#!/usr/bin/env python3
"""
Feature Implementation Status Detection

Analyzes the codebase to detect which features have been implemented
and suggests the next feature to work on based on priority and dependencies.
"""

import json
import subprocess
import sys
import yaml
from pathlib import Path
from typing import Dict, List, Optional, Tuple

ROOT = Path(__file__).resolve().parent.parent

class FeatureStatusDetector:
    """Detects implementation status of features."""
    
    def __init__(self):
        self.feature_matrix = self._load_feature_matrix()
        self.features = self.feature_matrix.get('features', [])
        self.dependencies = self._parse_dependencies()
    
    def _load_feature_matrix(self) -> Dict:
        """Load feature matrix from YAML."""
        try:
            with open(ROOT / "feature_matrix.yaml", 'r', encoding='utf-8') as f:
                return yaml.safe_load(f)
        except Exception as e:
            print(f"❌ Error loading feature matrix: {e}")
            return {}
    
    def _parse_dependencies(self) -> Dict[str, List[str]]:
        """Parse feature dependencies from the matrix."""
        dependencies = {}
        deps_section = self.feature_matrix.get('dependencies', [])
        
        for dep_entry in deps_section:
            if isinstance(dep_entry, dict):
                # Handle format like {'charts_time_series depends_on': ['data.indexing_perf', 'data.schema_v1']}
                for key, deps_list in dep_entry.items():
                    if 'depends_on' in key:
                        feature_id = key.replace(' depends_on', '').strip()
                        dependencies[feature_id] = deps_list
            elif isinstance(dep_entry, str) and 'depends_on:' in dep_entry:
                # Handle string format (backup)
                parts = dep_entry.split(' depends_on: ')
                if len(parts) == 2:
                    feature_id = parts[0].strip()
                    deps_str = parts[1].strip()
                    if deps_str.startswith('[') and deps_str.endswith(']'):
                        deps_str = deps_str[1:-1]
                    deps_list = [dep.strip() for dep in deps_str.split(',')]
                    dependencies[feature_id] = deps_list
        
        return dependencies
    
    def detect_implementation_status(self, feature_id: str) -> Dict:
        """Detect implementation status of a specific feature."""
        feature_snake = feature_id.split('.')[-1]  # Extract last part
        feature_dir = ROOT / "lib" / "features" / feature_snake
        
        status = {
            "feature_id": feature_id,
            "feature_name": feature_snake,
            "directory_exists": feature_dir.exists(),
            "has_domain": False,
            "has_data": False,
            "has_presentation": False,
            "has_tests": False,
            "completeness_score": 0,
            "implementation_status": "not_started",
            "missing_files": [],
            "present_files": []
        }
        
        if not status["directory_exists"]:
            status["implementation_status"] = "not_started"
            return status
        
        # Check domain layer
        domain_dir = feature_dir / "domain"
        if domain_dir.exists():
            status["has_domain"] = True
            domain_files = list(domain_dir.rglob("*.dart"))
            status["present_files"].extend([str(f.relative_to(ROOT)) for f in domain_files])
        else:
            status["missing_files"].append(f"lib/features/{feature_snake}/domain/")
        
        # Check data layer
        data_dir = feature_dir / "data"
        if data_dir.exists():
            status["has_data"] = True
            data_files = list(data_dir.rglob("*.dart"))
            status["present_files"].extend([str(f.relative_to(ROOT)) for f in data_files])
        else:
            status["missing_files"].append(f"lib/features/{feature_snake}/data/")
        
        # Check presentation layer
        presentation_dir = feature_dir / "presentation"
        if presentation_dir.exists():
            status["has_presentation"] = True
            presentation_files = list(presentation_dir.rglob("*.dart"))
            status["present_files"].extend([str(f.relative_to(ROOT)) for f in presentation_files])
        else:
            status["missing_files"].append(f"lib/features/{feature_snake}/presentation/")
        
        # Check tests
        test_dir = ROOT / "test" / "features" / feature_snake
        if test_dir.exists():
            status["has_tests"] = True
            test_files = list(test_dir.rglob("*.dart"))
            status["present_files"].extend([str(f.relative_to(ROOT)) for f in test_files])
        else:
            status["missing_files"].append(f"test/features/{feature_snake}/")
        
        # Calculate completeness score
        layers = ["has_domain", "has_data", "has_presentation", "has_tests"]
        status["completeness_score"] = sum(status[layer] for layer in layers) / len(layers)
        
        # Determine implementation status
        if status["completeness_score"] == 0:
            status["implementation_status"] = "not_started"
        elif status["completeness_score"] < 0.5:
            status["implementation_status"] = "scaffolded"
        elif status["completeness_score"] < 1.0:
            status["implementation_status"] = "in_progress"
        else:
            status["implementation_status"] = "complete"
        
        return status
    
    def analyze_all_features(self) -> Dict:
        """Analyze implementation status of all features."""
        results = {
            "total_features": len(self.features),
            "by_status": {
                "not_started": [],
                "scaffolded": [],
                "in_progress": [],
                "complete": []
            },
            "by_matrix_status": {
                "planned": [],
                "in_progress": [],
                "done": [],
                "parked": []
            },
            "details": []
        }
        
        for feature in self.features:
            feature_id = feature.get('id', '')
            matrix_status = feature.get('status', 'planned')
            priority = feature.get('priority', 'P3')
            
            implementation_status = self.detect_implementation_status(feature_id)
            implementation_status["matrix_status"] = matrix_status
            implementation_status["priority"] = priority
            implementation_status["title"] = feature.get('title', '')
            implementation_status["epic"] = feature.get('epic', '')
            
            results["details"].append(implementation_status)
            results["by_status"][implementation_status["implementation_status"]].append(implementation_status)
            results["by_matrix_status"][matrix_status].append(implementation_status)
        
        return results
    
    def _are_dependencies_satisfied(self, feature_id: str) -> Tuple[bool, List[str]]:
        """Check if all dependencies for a feature are satisfied."""
        if feature_id not in self.dependencies:
            return True, []  # No dependencies = satisfied
        
        required_deps = self.dependencies[feature_id]
        unsatisfied_deps = []
        
        for dep_id in required_deps:
            dep_status = self.detect_implementation_status(dep_id)
            if dep_status["implementation_status"] not in ["complete", "in_progress"]:
                unsatisfied_deps.append(dep_id)
        
        return len(unsatisfied_deps) == 0, unsatisfied_deps
    
    def suggest_next_feature(self) -> Optional[Dict]:
        """Suggest the next feature to implement based on priority and dependencies."""
        analysis = self.analyze_all_features()
        
        # Get features that are not started or scaffolded
        candidates = []
        for feature in analysis["details"]:
            if feature["implementation_status"] in ["not_started", "scaffolded"]:
                if feature["matrix_status"] == "planned":  # Only suggest planned features
                    # Check if dependencies are satisfied
                    deps_satisfied, unsatisfied_deps = self._are_dependencies_satisfied(feature["feature_id"])
                    feature["dependencies_satisfied"] = deps_satisfied
                    feature["unsatisfied_dependencies"] = unsatisfied_deps
                    
                    if deps_satisfied:
                        candidates.append(feature)
        
        if not candidates:
            return None
        
        # Sort by priority (P0 > P1 > P2 > P3)
        priority_order = {"P0": 0, "P1": 1, "P2": 2, "P3": 3}
        candidates.sort(key=lambda x: (
            priority_order.get(x["priority"], 4),  # Priority first
            x["epic"],  # Then by epic to group related features
            x["feature_id"]  # Finally by ID for consistency
        ))
        
        return candidates[0] if candidates else None
    
    def get_blocked_features(self) -> Dict:
        """Get features that are blocked by unsatisfied dependencies."""
        blocked_features = []
        
        for feature in self.features:
            feature_id = feature.get('id', '')
            if feature.get('status') == 'planned':
                deps_satisfied, unsatisfied_deps = self._are_dependencies_satisfied(feature_id)
                if not deps_satisfied:
                    blocked_info = {
                        "feature_id": feature_id,
                        "title": feature.get('title', ''),
                        "priority": feature.get('priority', 'P3'),
                        "epic": feature.get('epic', ''),
                        "unsatisfied_dependencies": unsatisfied_deps,
                        "dependency_status": {}
                    }
                    
                    # Get status of each unsatisfied dependency
                    for dep_id in unsatisfied_deps:
                        dep_status = self.detect_implementation_status(dep_id)
                        blocked_info["dependency_status"][dep_id] = {
                            "status": dep_status["implementation_status"],
                            "completeness": dep_status["completeness_score"]
                        }
                    
                    blocked_features.append(blocked_info)
        
        return {
            "blocked_count": len(blocked_features),
            "blocked_features": blocked_features
        }

    def get_implementation_gaps(self) -> Dict:
        """Identify gaps between matrix status and actual implementation."""
        analysis = self.analyze_all_features()
        gaps = {
            "matrix_says_done_but_not_implemented": [],
            "matrix_says_planned_but_implemented": [],
            "matrix_says_in_progress_but_complete": [],
            "matrix_says_complete_but_incomplete": []
        }
        
        for feature in analysis["details"]:
            matrix_status = feature["matrix_status"]
            impl_status = feature["implementation_status"]
            
            if matrix_status == "done" and impl_status != "complete":
                gaps["matrix_says_done_but_not_implemented"].append(feature)
            elif matrix_status == "planned" and impl_status == "complete":
                gaps["matrix_says_planned_but_implemented"].append(feature)
            elif matrix_status == "in_progress" and impl_status == "complete":
                gaps["matrix_says_in_progress_but_complete"].append(feature)
            elif matrix_status == "done" and impl_status != "complete":
                gaps["matrix_says_complete_but_incomplete"].append(feature)
        
        return gaps


def main():
    """Main entry point."""
    import argparse
    
    parser = argparse.ArgumentParser(description="Detect feature implementation status")
    parser.add_argument("--feature-id", help="Analyze specific feature")
    parser.add_argument("--suggest-next", action="store_true", help="Suggest next feature to implement")
    parser.add_argument("--analyze-all", action="store_true", help="Analyze all features")
    parser.add_argument("--check-gaps", action="store_true", help="Check for gaps between matrix and implementation")
    parser.add_argument("--check-blocked", action="store_true", help="Check for features blocked by dependencies")
    parser.add_argument("--json", action="store_true", help="Output as JSON")
    parser.add_argument("--workflow-output", action="store_true", help="Output in GitHub Actions workflow format")
    
    args = parser.parse_args()
    detector = FeatureStatusDetector()
    
    try:
        if args.feature_id:
            result = detector.detect_implementation_status(args.feature_id)
            if args.json:
                print(json.dumps(result, indent=2))
            else:
                print(f"Feature: {result['feature_id']}")
                print(f"Status: {result['implementation_status']}")
                print(f"Completeness: {result['completeness_score']:.0%}")
                if result['missing_files']:
                    print(f"Missing: {', '.join(result['missing_files'])}")
        
        elif args.suggest_next:
            suggestion = detector.suggest_next_feature()
            if suggestion:
                if args.workflow_output:
                    print(f"next_feature_id={suggestion['feature_id']}")
                    print(f"next_feature_title={suggestion['title']}")
                    print(f"next_feature_priority={suggestion['priority']}")
                    print(f"next_feature_epic={suggestion['epic']}")
                elif args.json:
                    print(json.dumps(suggestion, indent=2))
                else:
                    print(f"🎯 Next suggested feature: {suggestion['feature_id']}")
                    print(f"   Title: {suggestion['title']}")
                    print(f"   Priority: {suggestion['priority']}")
                    print(f"   Epic: {suggestion['epic']}")
                    print(f"   Current Status: {suggestion['implementation_status']}")
                    if suggestion.get('unsatisfied_dependencies'):
                        print(f"   Dependencies: {', '.join(suggestion['unsatisfied_dependencies'])}")
                    else:
                        print("   Dependencies: All satisfied ✓")
            else:
                if args.workflow_output:
                    print("next_feature_id=")
                    print("next_feature_title=No features available")
                else:
                    print("🎉 No more features to implement!")
        
        elif args.analyze_all:
            analysis = detector.analyze_all_features()
            if args.json:
                print(json.dumps(analysis, indent=2))
            else:
                print(f"📊 Feature Implementation Analysis")
                print(f"Total Features: {analysis['total_features']}")
                print()
                print("Implementation Status:")
                for status, features in analysis["by_status"].items():
                    print(f"  {status.replace('_', ' ').title()}: {len(features)}")
                print()
                print("Matrix Status:")
                for status, features in analysis["by_matrix_status"].items():
                    print(f"  {status.title()}: {len(features)}")
        
        elif args.check_gaps:
            gaps = detector.get_implementation_gaps()
            if args.json:
                print(json.dumps(gaps, indent=2))
            else:
                print("🔍 Implementation Gaps Analysis")
                for gap_type, features in gaps.items():
                    if features:
                        print(f"\n{gap_type.replace('_', ' ').title()}:")
                        for feature in features:
                            print(f"  - {feature['feature_id']} ({feature['title']})")
        
        elif args.check_blocked:
            blocked = detector.get_blocked_features()
            if args.json:
                print(json.dumps(blocked, indent=2))
            else:
                print("🚫 Features Blocked by Dependencies")
                if blocked["blocked_count"] == 0:
                    print("No features are currently blocked by dependencies!")
                else:
                    print(f"Found {blocked['blocked_count']} blocked features:")
                    for feature in blocked["blocked_features"]:
                        print(f"\n• {feature['feature_id']} - {feature['title']} ({feature['priority']})")
                        print(f"  Blocked by: {', '.join(feature['unsatisfied_dependencies'])}")
                        for dep_id, dep_info in feature["dependency_status"].items():
                            print(f"    - {dep_id}: {dep_info['status']} ({dep_info['completeness']:.0%})")
        
        else:
            # Default: show summary
            analysis = detector.analyze_all_features()
            suggestion = detector.suggest_next_feature()
            
            if args.json:
                result = {
                    "summary": analysis,
                    "next_suggestion": suggestion
                }
                print(json.dumps(result, indent=2))
            else:
                print("🚀 AshTrail Feature Status")
                print("=" * 50)
                print(f"Total Features: {analysis['total_features']}")
                print()
                for status, features in analysis["by_status"].items():
                    count = len(features)
                    if count > 0:
                        print(f"{status.replace('_', ' ').title()}: {count}")
                
                if suggestion:
                    print(f"\n🎯 Next Suggested: {suggestion['feature_id']}")
                    print(f"   {suggestion['title']} ({suggestion['priority']})")
                else:
                    print("\n🎉 All features complete!")
    
    except Exception as e:
        if args.json:
            print(json.dumps({"error": str(e)}, indent=2))
        else:
            print(f"❌ Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
