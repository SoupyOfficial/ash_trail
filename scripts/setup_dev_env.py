#!/usr/bin/env python3
"""
AshTrail Development Environment Setup

Sets up the development environment for GitHub Copilot enhanced development.
Installs dependencies, runs initial code generation, and validates setup.
"""

import os
import sys
import subprocess
import platform
from pathlib import Path

def run_command(cmd, description="", cwd=None):
    """Run a command and handle errors gracefully."""
    print(f"🔄 {description or cmd}")
    try:
        result = subprocess.run(
            cmd.split() if isinstance(cmd, str) else cmd,
            cwd=cwd,
            check=True,
            capture_output=True,
            text=True
        )
        if result.stdout.strip():
            print(f"✅ {result.stdout.strip()}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Error: {e}")
        if e.stderr:
            print(f"   {e.stderr.strip()}")
        return False

def check_prerequisites():
    """Check if required tools are installed."""
    print("🔍 Checking prerequisites...")
    
    tools = [
        ("flutter", "Flutter SDK"),
        ("python", "Python 3.x"),
        ("git", "Git")
    ]
    
    missing = []
    for tool, name in tools:
        try:
            subprocess.run([tool, "--version"], 
                         capture_output=True, check=True)
            print(f"✅ {name} found")
        except (subprocess.CalledProcessError, FileNotFoundError):
            missing.append(name)
            print(f"❌ {name} not found")
    
    if missing:
        print(f"\n❌ Missing tools: {', '.join(missing)}")
        print("Please install missing tools and try again.")
        return False
    
    return True

def setup_flutter():
    """Set up Flutter dependencies."""
    print("\n🔧 Setting up Flutter...")
    
    # Check Flutter doctor
    if not run_command("flutter doctor", "Checking Flutter installation"):
        print("⚠️  Flutter doctor reported issues. Please resolve them.")
    
    # Get dependencies
    if not run_command("flutter pub get", "Installing Flutter dependencies"):
        return False
    
    return True

def setup_python():
    """Set up Python dependencies."""
    print("\n🐍 Setting up Python dependencies...")
    
    # Install requirements if file exists
    if Path("requirements.txt").exists():
        if not run_command("pip install -r requirements.txt", 
                          "Installing Python requirements"):
            return False
    else:
        # Install minimal required packages
        packages = ["pyyaml", "jsonschema"]
        for pkg in packages:
            if not run_command(f"pip install {pkg}", f"Installing {pkg}"):
                return False
    
    return True

def run_code_generation():
    """Run initial code generation."""
    print("\n⚙️  Running code generation...")
    
    # Run feature matrix generator
    if not run_command("python scripts/generate_from_feature_matrix.py",
                      "Generating from feature matrix"):
        return False
    
    # Run build_runner for Freezed/JSON serialization
    if not run_command("flutter pub run build_runner build --delete-conflicting-outputs",
                      "Running build_runner"):
        return False
    
    return True

def validate_setup():
    """Validate the setup by running tests and analysis."""
    print("\n✅ Validating setup...")
    
    # Run analysis
    if not run_command("flutter analyze", "Running static analysis"):
        print("⚠️  Analysis found issues. Please review.")
    
    # Run tests if they exist
    test_dir = Path("test")
    if test_dir.exists() and any(test_dir.iterdir()):
        if not run_command("flutter test", "Running tests"):
            print("⚠️  Tests failed. Please review.")
    else:
        print("ℹ️  No tests found to run")
    
    return True

def setup_git_hooks():
    """Set up optional git hooks for automated regeneration."""
    print("\n🪝 Setting up git hooks (optional)...")
    
    try:
        # Check if pre-commit is available
        subprocess.run(["pre-commit", "--version"], 
                      capture_output=True, check=True)
        
        if run_command("pre-commit install", "Installing pre-commit hooks"):
            print("✅ Pre-commit hooks installed")
        else:
            print("⚠️  Failed to install pre-commit hooks")
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("ℹ️  pre-commit not found. Install with: pip install pre-commit")

def create_vscode_settings():
    """Create VS Code settings for optimal Copilot experience."""
    print("\n⚙️  Setting up VS Code configuration...")
    
    vscode_dir = Path(".vscode")
    vscode_dir.mkdir(exist_ok=True)
    
    settings = {
        "dart.flutterSdkPath": None,
        "editor.formatOnSave": True,
        "editor.codeActionsOnSave": {
            "source.fixAll": True
        },
        "dart.lineLength": 80,
        "files.associations": {
            "*.yaml": "yaml",
            "*.yml": "yaml"
        },
        "github.copilot.enable": {
            "*": True,
            "yaml": True,
            "plaintext": False,
            "markdown": True
        },
        "github.copilot.advanced": {},
        "dart.previewFlutterUiGuides": True,
        "dart.previewFlutterUiGuidesCustomTracking": True
    }
    
    import json
    settings_file = vscode_dir / "settings.json"
    with open(settings_file, "w") as f:
        json.dump(settings, f, indent=2)
    
    print(f"✅ Created {settings_file}")
    
    # Create extensions recommendations
    extensions = {
        "recommendations": [
            "Dart-Code.dart-code",
            "Dart-Code.flutter",
            "GitHub.copilot",
            "GitHub.copilot-chat",
            "ms-python.python",
            "redhat.vscode-yaml"
        ]
    }
    
    extensions_file = vscode_dir / "extensions.json"
    with open(extensions_file, "w") as f:
        json.dump(extensions, f, indent=2)
    
    print(f"✅ Created {extensions_file}")

def main():
    """Main setup function."""
    print("🚀 AshTrail Development Environment Setup")
    print("=========================================\n")
    
    # Change to project root
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    os.chdir(project_root)
    
    print(f"📁 Working directory: {project_root}")
    
    # Run setup steps
    steps = [
        ("Prerequisites", check_prerequisites),
        ("Python Dependencies", setup_python),
        ("Flutter Setup", setup_flutter),
        ("Code Generation", run_code_generation),
        ("Validation", validate_setup),
        ("Git Hooks", setup_git_hooks),
        ("VS Code Settings", create_vscode_settings),
    ]
    
    failed_steps = []
    for step_name, step_func in steps:
        if not step_func():
            failed_steps.append(step_name)
    
    print("\n" + "="*50)
    if failed_steps:
        print(f"⚠️  Setup completed with issues in: {', '.join(failed_steps)}")
        print("Please review the errors above and resolve them.")
        sys.exit(1)
    else:
        print("✅ Development environment setup complete!")
        print("\n📝 Next steps:")
        print("1. Open the project in VS Code")
        print("2. Install recommended extensions when prompted")
        print("3. Review .github/copilot-instructions.md for Copilot usage")
        print("4. Check feature_matrix.yaml for current development priorities")
        print("5. Run 'flutter run' to start the app")

if __name__ == "__main__":
    main()
