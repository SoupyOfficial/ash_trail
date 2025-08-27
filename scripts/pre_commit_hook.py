#!/usr/bin/env python3
"""
Enhanced pre-commit hook for AshTrail development.

This hook:
1. Validates feature_matrix.yaml schema
2. Runs code generation if needed
3. Ensures generated files are up to date
4. Runs basic linting and formatting
5. Provides helpful feedback for GitHub Copilot context
"""

import subprocess
import sys
import os
from pathlib import Path

def run_command(cmd, description=""):
    """Run command and return success status."""
    print(f"🔄 {description or cmd}")
    try:
        result = subprocess.run(
            cmd, shell=True, check=True, 
            capture_output=True, text=True
        )
        return True, result.stdout
    except subprocess.CalledProcessError as e:
        return False, e.stderr

def check_feature_matrix_changes():
    """Check if feature_matrix.yaml was modified."""
    try:
        result = subprocess.run(
            ["git", "diff", "--cached", "--name-only"],
            capture_output=True, text=True, check=True
        )
        changed_files = result.stdout.strip().split('\n')
        return "feature_matrix.yaml" in changed_files
    except subprocess.CalledProcessError:
        return False

def validate_feature_matrix():
    """Validate feature_matrix.yaml schema."""
    print("🔍 Validating feature matrix schema...")
    schema_file = Path("tool/json_schema/feature_matrix.schema.json")
    if not schema_file.exists():
        print("⚠️  Schema file not found, skipping validation")
        return True
    
    success, output = run_command(
        'python -c "import json,yaml,jsonschema,pathlib;'
        'd=yaml.safe_load(pathlib.Path(\'feature_matrix.yaml\').read_text());'
        's=json.loads(pathlib.Path(\'tool/json_schema/feature_matrix.schema.json\').read_text());'
        'jsonschema.validate(d,s);print(\'✅ Schema validation passed\')"',
        "Validating feature matrix schema"
    )
    
    if success:
        print(output.strip())
    else:
        print(f"❌ Schema validation failed: {output}")
    
    return success

def run_code_generation():
    """Run code generation pipeline."""
    print("⚙️  Running code generation...")
    
    # Generate from feature matrix
    success, output = run_command(
        "python scripts/generate_from_feature_matrix.py",
        "Generating from feature matrix"
    )
    if not success:
        print(f"❌ Feature matrix generation failed: {output}")
        return False
    
    # Run build_runner for Freezed/JSON
    success, output = run_command(
        "flutter pub run build_runner build --delete-conflicting-outputs",
        "Running build_runner"
    )
    if not success:
        print(f"❌ Build runner failed: {output}")
        return False
    
    return True

def check_for_uncommitted_generated_files():
    """Check if generated files need to be staged."""
    generated_paths = [
        "lib/domain/models",
        "lib/domain/indexes",
        "lib/telemetry",
        "tool/feature_flags.g.dart",
        "test/acceptance"
    ]
    
    try:
        # Check for unstaged changes in generated paths
        for path in generated_paths:
            if Path(path).exists():
                result = subprocess.run(
                    ["git", "diff", "--name-only", path],
                    capture_output=True, text=True, check=True
                )
                if result.stdout.strip():
                    print(f"📝 Generated files modified in {path}")
                    subprocess.run(["git", "add", path], check=True)
                    print(f"✅ Staged generated files in {path}")
        
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Error staging generated files: {e}")
        return False

def run_quick_analysis():
    """Run quick analysis to catch obvious issues."""
    print("🔍 Running quick analysis...")
    
    success, output = run_command(
        "flutter analyze --no-fatal-infos",
        "Running Flutter analyze"
    )
    
    if not success:
        print(f"❌ Analysis found issues:\n{output}")
        print("\n💡 Consider fixing these issues before committing.")
        print("💡 Use GitHub Copilot Chat to help resolve them:")
        print("   @github #file:analyze Fix the analysis issues in this file")
        return False
    
    print("✅ Analysis passed")
    return True

def provide_copilot_context():
    """Provide helpful context for GitHub Copilot."""
    try:
        # Get staged files
        result = subprocess.run(
            ["git", "diff", "--cached", "--name-only"],
            capture_output=True, text=True, check=True
        )
        staged_files = result.stdout.strip().split('\n')
        
        if not staged_files or staged_files == ['']:
            return
        
        print("\n🤖 GitHub Copilot Context:")
        print("=" * 40)
        
        # Categorize files
        feature_files = [f for f in staged_files if f.startswith('lib/features/')]
        model_files = [f for f in staged_files if f.startswith('lib/domain/models/')]
        test_files = [f for f in staged_files if f.startswith('test/')]
        
        if feature_files:
            print("📁 Feature files changed:")
            for f in feature_files:
                print(f"   • {f}")
            print("💡 Copilot tip: Use '@github #file:feature Implement tests for this feature'")
        
        if model_files:
            print("📊 Model files changed:")
            for f in model_files:
                print(f"   • {f}")
            print("💡 Copilot tip: Generated models - no manual changes needed")
        
        if test_files:
            print("🧪 Test files changed:")
            for f in test_files:
                print(f"   • {f}")
            print("💡 Copilot tip: Use '@github #file:test Add more test cases for edge cases'")
        
        print("\n💡 Quick Copilot commands:")
        print("   • '@github #file:current Explain this code'")
        print("   • '@github #file:current Add comprehensive tests'")
        print("   • '@github #file:current Follow AshTrail architecture'")
        print("   • '@github #workspace What features should I implement next?'")
        
    except subprocess.CalledProcessError:
        pass

def main():
    """Main pre-commit function."""
    print("🚀 AshTrail Pre-commit Hook")
    print("=" * 30)
    
    os.chdir(Path(__file__).parent.parent)
    
    # Check if feature matrix changed
    matrix_changed = check_feature_matrix_changes()
    
    # Always validate feature matrix if it exists
    if Path("feature_matrix.yaml").exists():
        if not validate_feature_matrix():
            print("❌ Pre-commit failed: feature matrix validation")
            sys.exit(1)
    
    # Run code generation if matrix changed or generated files are missing
    needs_generation = matrix_changed or not Path("lib/domain/models").exists()
    
    if needs_generation:
        if not run_code_generation():
            print("❌ Pre-commit failed: code generation")
            sys.exit(1)
        
        # Stage generated files
        if not check_for_uncommitted_generated_files():
            print("❌ Pre-commit failed: staging generated files")
            sys.exit(1)
    
    # Run quick analysis
    if not run_quick_analysis():
        print("\n⚠️  Analysis issues found, but allowing commit.")
        print("💡 Consider fixing these before pushing.")
    
    # Provide Copilot context
    provide_copilot_context()
    
    print("\n✅ Pre-commit hook completed successfully!")
    print("🚀 Ready to commit. Use Copilot Chat for help with next steps!")

if __name__ == "__main__":
    main()
