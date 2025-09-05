#!/usr/bin/env python3
"""
Auto-implementation script that creates a full feature implementation pull request.

This script:
1. Takes a feature ID from feature_matrix.yaml
2. Creates a new branch
3. Generates feature scaffold
4. Creates implementation plan
5. Commits changes
6. Opens pull request with GitHub Copilot coding agent
"""

import argparse
import subprocess
import yaml
from pathlib import Path
import sys
import os

ROOT = Path(__file__).resolve().parent.parent

def load_feature_matrix():
    """Load the feature matrix."""
    with open(ROOT / "feature_matrix.yaml", 'r') as f:
        return yaml.safe_load(f)

def find_feature(feature_id, matrix):
    """Find a feature by ID."""
    for feature in matrix.get('features', []):
        if feature.get('id') == feature_id:
            return feature
    return None

def create_feature_branch(feature_id):
    """Create and checkout a new feature branch."""
    branch_name = f"feature/{feature_id.replace('.', '-')}"
    try:
        # Create and checkout branch
        subprocess.run(['git', 'checkout', '-b', branch_name], 
                      cwd=ROOT, check=True, capture_output=True)
        return branch_name
    except subprocess.CalledProcessError as e:
        print(f"Failed to create branch: {e}")
        return None

def generate_feature_scaffold(feature_id, epic):
    """Generate feature scaffold."""
    feature_name = feature_id.split('.')[-1]  # e.g., 'app_shell' from 'ui.app_shell'
    
    try:
        subprocess.run([
            'python', 'scripts/simple_feature_scaffold.py', 
            feature_name, '--epic', epic
        ], cwd=ROOT, check=True)
        return True
    except subprocess.CalledProcessError as e:
        print(f"Failed to generate scaffold: {e}")
        return False

def run_code_generation():
    """Run code generation pipeline."""
    try:
        # Run the development generate script
        if os.name == 'nt':  # Windows
            subprocess.run(['scripts\\dev_generate.bat'], cwd=ROOT, check=True, shell=True)
        else:  # Unix-like (Linux/macOS)
            # Use bash to run the script to avoid permission issues
            subprocess.run(['bash', 'scripts/dev_generate.sh'], cwd=ROOT, check=True)
        return True
    except subprocess.CalledProcessError as e:
        print(f"Code generation failed: {e}")
        return False

def create_implementation_plan(feature):
    """Create detailed implementation plan."""
    feature_id = feature['id']
    title = feature['title']
    epic = feature['epic']
    acceptance = feature.get('acceptance', [])
    
    plan = f"""# Implementation Plan: {title}

## Feature Details
- **ID**: {feature_id}
- **Epic**: {epic}  
- **Status**: {feature.get('status', 'planned')}
- **Priority**: {feature.get('priority', 'P1')}

## Acceptance Criteria
"""
    
    for criteria in acceptance:
        plan += f"- {criteria}\n"
    
    plan += f"""

## Implementation Tasks

### 1. Architecture Setup
- [ ] Review generated scaffold structure
- [ ] Implement repository interfaces
- [ ] Create domain entities (if not generated)
- [ ] Set up Riverpod providers

### 2. Data Layer
- [ ] Implement local data source (Isar)
- [ ] Implement remote data source (Firestore/API)
- [ ] Add offline-first sync logic
- [ ] Handle error cases and conflicts

### 3. Business Logic
- [ ] Implement use cases
- [ ] Add validation logic
- [ ] Handle business rules
- [ ] Add proper error handling

### 4. Presentation Layer
- [ ] Create main screens/widgets
- [ ] Implement forms and interactions
- [ ] Add loading/error states
- [ ] Ensure accessibility

### 5. Testing
- [ ] Unit tests for use cases
- [ ] Widget tests for UI components
- [ ] Integration tests for flows
- [ ] Golden tests for visual validation

### 6. Documentation
- [ ] Update feature README
- [ ] Add code comments
- [ ] Update architectural decisions if needed

## GitHub Copilot Prompts

Use these to accelerate implementation:

```
@github #file:lib/features/{feature_id.split('.')[-1]} Complete this feature following Clean Architecture
@github #workspace Implement {title} with offline-first patterns
@github #file:current Add comprehensive error handling and validation
@github #file:current Create proper tests with high coverage
```

## Ready for GitHub Copilot Coding Agent

This feature is ready for automated implementation using the GitHub Copilot coding agent.
The scaffold provides the structure, and the acceptance criteria define the requirements.
"""
    
    return plan

def commit_changes(feature_id, feature_title):
    """Commit all changes."""
    try:
        # Add all changes
        subprocess.run(['git', 'add', '.'], cwd=ROOT, check=True)
        
        # Commit with conventional commit format
        commit_msg = f"feat: add {feature_id} scaffold\n\nGenerated scaffold for '{feature_title}' feature ready for implementation."
        subprocess.run(['git', 'commit', '-m', commit_msg], cwd=ROOT, check=True)
        
        return True
    except subprocess.CalledProcessError as e:
        print(f"Failed to commit: {e}")
        return False

def main():
    parser = argparse.ArgumentParser(description='Auto-implement a feature from feature matrix')
    parser.add_argument('feature_id', help='Feature ID from feature_matrix.yaml (e.g., ui.app_shell)')
    parser.add_argument('--push', action='store_true', help='Push branch and create PR')
    
    args = parser.parse_args()
    
    # Load feature matrix
    matrix = load_feature_matrix()
    feature = find_feature(args.feature_id, matrix)
    
    if not feature:
        print(f"Feature '{args.feature_id}' not found in feature_matrix.yaml")
        sys.exit(1)
    
    print(f"🚀 Auto-implementing feature: {feature['title']}")
    
    # Create feature branch
    branch_name = create_feature_branch(args.feature_id)
    if not branch_name:
        sys.exit(1)
    
    print(f"📁 Created branch: {branch_name}")
    
    # Generate scaffold
    epic = feature.get('epic', 'general')
    if not generate_feature_scaffold(args.feature_id, epic):
        sys.exit(1)
    
    print(f"🏗️ Generated feature scaffold")
    
    # Run code generation
    if not run_code_generation():
        print("⚠️ Code generation failed, but continuing...")
    
    # Create implementation plan
    plan = create_implementation_plan(feature)
    plan_file = ROOT / f"IMPLEMENTATION_PLAN_{args.feature_id}.md"
    plan_file.write_text(plan)
    
    print(f"📋 Created implementation plan: {plan_file}")
    
    # Commit changes
    if commit_changes(args.feature_id, feature['title']):
        print(f"✅ Committed changes")
    else:
        sys.exit(1)
    
    if args.push:
        try:
            # Push branch
            subprocess.run(['git', 'push', '-u', 'origin', branch_name], cwd=ROOT, check=True)
            print(f"🚀 Pushed branch to origin")
            
            # TODO: Create PR using GitHub CLI or API
            print(f"🔄 Ready to create PR - use GitHub web interface or:")
            print(f"gh pr create --title 'feat: implement {feature['title']}' --body-file {plan_file}")
            
        except subprocess.CalledProcessError as e:
            print(f"Failed to push: {e}")
            sys.exit(1)
    
    print(f"\n🎯 Feature {args.feature_id} is ready for implementation!")
    print(f"Next steps:")
    print(f"1. Review the generated scaffold in lib/features/{args.feature_id.split('.')[-1]}/")
    print(f"2. Use GitHub Copilot to implement the feature")
    print(f"3. Run tests: flutter test")
    print(f"4. Create PR when ready")

if __name__ == "__main__":
    main()
