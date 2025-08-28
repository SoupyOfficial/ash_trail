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
    
    def _load_feature_matrix(self) -> Dict:
        """Load feature matrix from YAML."""
        try:
            with open(ROOT / "feature_matrix.yaml", 'r', encoding='utf-8') as f:
                return yaml.safe_load(f)
        except Exception as e:
            print(f"❌ Error loading feature matrix: {e}")
            return {}
    
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
    
    def suggest_next_feature(self) -> Optional[Dict]:
        """Suggest the next feature to implement based on priority and dependencies."""
        analysis = self.analyze_all_features()
        
        # Get features that are not started or scaffolded
        candidates = []
        for feature in analysis["details"]:
            if feature["implementation_status"] in ["not_started", "scaffolded"]:
                if feature["matrix_status"] == "planned":  # Only suggest planned features
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
