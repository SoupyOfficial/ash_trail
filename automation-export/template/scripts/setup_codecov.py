#!/usr/bin/env python3
"""Automated Codecov Setup Script

Automates the setup of Codecov integration for projects using the dev assistant template.
Handles project creation, token generation, and configuration setup.

Usage:
    python scripts/setup_codecov.py --repo owner/repo
    python scripts/setup_codecov.py --repo owner/repo --dry-run
    python scripts/setup_codecov.py --interactive
"""

import argparse
import json
import os
import sys
import subprocess
import webbrowser
from pathlib import Path
from typing import Dict, List, Optional, Tuple
import urllib.request
import urllib.parse
import urllib.error

def detect_project_root() -> Path:
    """Detect project root directory."""
    current = Path.cwd()
    indicators = ['.git', 'automation.config.yaml', 'pyproject.toml', 'package.json']

    for path in [current] + list(current.parents):
        for indicator in indicators:
            if (path / indicator).exists():
                return path
    return current

def run_command(cmd: List[str], cwd: Optional[Path] = None, timeout: int = 30) -> Tuple[bool, str]:
    """Run a shell command and return success status and output."""
    try:
        result = subprocess.run(
            cmd,
            cwd=cwd,
            capture_output=True,
            text=True,
            timeout=timeout
        )
        return result.returncode == 0, result.stdout + result.stderr
    except subprocess.TimeoutExpired:
        return False, f"Command timed out after {timeout} seconds"
    except Exception as e:
        return False, str(e)

def detect_git_remote() -> Optional[str]:
    """Detect GitHub repository from git remote."""
    success, output = run_command(["git", "remote", "get-url", "origin"])
    if not success:
        return None

    url = output.strip()
    # Handle different remote URL formats
    if url.startswith("git@github.com:"):
        repo = url[15:].replace(".git", "")
    elif url.startswith("https://github.com/"):
        repo = url[19:].replace(".git", "")
    else:
        return None

    return repo

def check_codecov_cli() -> bool:
    """Check if Codecov CLI is installed."""
    success, _ = run_command(["codecov", "--help"])
    return success

def install_codecov_cli() -> bool:
    """Install Codecov CLI."""
    print("📦 Installing Codecov CLI...")
    success, output = run_command([sys.executable, "-m", "pip", "install", "codecov"], timeout=120)
    if success:
        print("✅ Codecov CLI installed successfully")
    else:
        print(f"❌ Failed to install Codecov CLI: {output}")
    return success

def check_github_cli() -> bool:
    """Check if GitHub CLI is available."""
    success, _ = run_command(["gh", "--version"])
    return success

def get_github_token() -> Optional[str]:
    """Get GitHub token from environment or gh CLI."""
    # Try environment variable first
    token = os.environ.get('GITHUB_TOKEN')
    if token:
        return token

    # Try gh CLI
    if check_github_cli():
        success, output = run_command(["gh", "auth", "token"])
        if success:
            return output.strip()

    return None

def create_env_file(project_root: Path, codecov_token: str = "", dry_run: bool = False) -> bool:
    """Create or update .env file with Codecov configuration."""
    env_file = project_root / ".env"
    env_example = project_root / ".env.example"

    # Read existing .env.example as template
    env_content = []
    if env_example.exists():
        with open(env_example, 'r') as f:
            env_content = f.readlines()

    # Add Codecov configuration if not present
    has_codecov = any("CODECOV_TOKEN" in line for line in env_content)
    if not has_codecov:
        env_content.append("\n# Codecov Configuration\n")
        env_content.append(f"CODECOV_TOKEN={codecov_token}\n")
        env_content.append("CODECOV_URL=https://codecov.io\n")
        env_content.append("CODECOV_SLUG=  # Optional: owner/repo for private repos\n")

    if dry_run:
        print(f"Would create/update {env_file}")
        return True

    try:
        with open(env_file, 'w') as f:
            f.writelines(env_content)
        print(f"✅ Created/updated {env_file}")
        return True
    except Exception as e:
        print(f"❌ Failed to create {env_file}: {e}")
        return False

def setup_github_secret(repo: str, token_name: str = "CODECOV_TOKEN", dry_run: bool = False) -> bool:
    """Set up GitHub secret for Codecov token."""
    if not check_github_cli():
        print("⚠️  GitHub CLI not available. Please manually add CODECOV_TOKEN secret in GitHub.")
        print(f"   Go to: https://github.com/{repo}/settings/secrets/actions")
        return False

    if dry_run:
        print(f"Would set up GitHub secret {token_name} for {repo}")
        return True

    print("🔐 Setting up GitHub secret...")
    print("Please enter your Codecov token when prompted:")

    success, output = run_command([
        "gh", "secret", "set", token_name,
        "--repo", repo
    ], timeout=60)

    if success:
        print(f"✅ GitHub secret {token_name} set successfully")
        return True
    else:
        print(f"❌ Failed to set GitHub secret: {output}")
        return False

def validate_codecov_config(project_root: Path) -> Dict[str, bool]:
    """Validate Codecov configuration files."""
    results = {}

    # Check codecov.yml
    codecov_yml = project_root / "codecov.yml"
    results["codecov_yml"] = codecov_yml.exists()

    # Check automation.config.yaml has Codecov settings
    automation_config = project_root / "automation.config.yaml"
    if automation_config.exists():
        try:
            import yaml
            with open(automation_config, 'r') as f:
                config = yaml.safe_load(f)
            results["automation_config"] = "codecov" in config
        except Exception:
            results["automation_config"] = False
    else:
        results["automation_config"] = False

    # Check dev assistant has upload-coverage command
    dev_assistant = project_root / "scripts" / "dev_assistant.py"
    if dev_assistant.exists():
        try:
            with open(dev_assistant, 'r') as f:
                content = f.read()
            results["dev_assistant"] = "upload-coverage" in content
        except Exception:
            results["dev_assistant"] = False
    else:
        results["dev_assistant"] = False

    # Check CI workflow has Codecov integration
    ci_workflow = project_root / ".github" / "workflows" / "automation.yml"
    if not ci_workflow.exists():
        ci_workflow = project_root / "ci" / "github" / "workflows" / "automation.yml"

    if ci_workflow.exists():
        try:
            with open(ci_workflow, 'r') as f:
                content = f.read()
            results["ci_workflow"] = "codecov" in content.lower()
        except Exception:
            results["ci_workflow"] = False
    else:
        results["ci_workflow"] = False

    return results

def setup_codecov_interactive() -> Dict[str, str]:
    """Interactive setup for Codecov configuration."""
    config = {}

    print("🚀 Interactive Codecov Setup")
    print("=" * 40)

    # Repository detection
    repo = detect_git_remote()
    if repo:
        print(f"📁 Detected repository: {repo}")
        use_detected = input("Use detected repository? (Y/n): ").strip().lower()
        if use_detected not in ['n', 'no']:
            config['repo'] = repo
        else:
            config['repo'] = input("Enter repository (owner/repo): ").strip()
    else:
        config['repo'] = input("Enter repository (owner/repo): ").strip()

    # Codecov project setup
    print(f"\n📊 Setting up Codecov for {config['repo']}")
    print("1. Go to https://codecov.io")
    print("2. Sign in with GitHub")
    print("3. Add your repository")
    print("4. Copy the repository upload token")

    open_codecov = input("\nOpen Codecov in browser? (Y/n): ").strip().lower()
    if open_codecov not in ['n', 'no']:
        webbrowser.open(f"https://app.codecov.io/gh/{config['repo']}")

    config['token'] = input("\nEnter Codecov token (or press Enter to skip): ").strip()

    # GitHub secret setup
    if config['token']:
        setup_secret = input("Set up GitHub secret automatically? (Y/n): ").strip().lower()
        config['setup_secret'] = setup_secret not in ['n', 'no']
    else:
        config['setup_secret'] = False

    return config

def main():
    """Main setup function."""
    parser = argparse.ArgumentParser(
        description="Automated Codecov setup for development projects",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python scripts/setup_codecov.py --interactive
  python scripts/setup_codecov.py --repo owner/repo
  python scripts/setup_codecov.py --repo owner/repo --dry-run
  python scripts/setup_codecov.py --validate
"""
    )

    parser.add_argument('--repo', help='GitHub repository (owner/repo format)')
    parser.add_argument('--token', help='Codecov token')
    parser.add_argument('--interactive', '-i', action='store_true', help='Interactive setup')
    parser.add_argument('--validate', action='store_true', help='Validate existing configuration')
    parser.add_argument('--dry-run', action='store_true', help='Show what would be done without making changes')

    args = parser.parse_args()

    project_root = detect_project_root()
    print(f"🏠 Project root: {project_root}")

    # Validation mode
    if args.validate:
        print("\n🔍 Validating Codecov configuration...")
        results = validate_codecov_config(project_root)

        for check, passed in results.items():
            status = "✅" if passed else "❌"
            print(f"  {status} {check.replace('_', ' ').title()}")

        all_passed = all(results.values())
        if all_passed:
            print("\n🎉 All Codecov configuration checks passed!")
        else:
            print("\n⚠️  Some configuration issues found. Run setup to fix.")
            sys.exit(1)
        return

    # Interactive mode
    if args.interactive:
        config = setup_codecov_interactive()
        repo = config.get('repo')
        token = config.get('token')
        setup_secret = config.get('setup_secret', False)
    else:
        repo = args.repo or detect_git_remote()
        token = args.token
        setup_secret = bool(token)

    if not repo:
        print("❌ Repository not specified and cannot be auto-detected")
        print("   Use --repo owner/repo or run from a Git repository")
        sys.exit(1)

    print(f"\n🚀 Setting up Codecov for {repo}")

    # Check/install Codecov CLI
    if not check_codecov_cli():
        if not args.dry_run:
            if not install_codecov_cli():
                print("❌ Failed to install Codecov CLI")
                sys.exit(1)
        else:
            print("📦 Would install Codecov CLI")

    # Create/update .env file
    create_env_file(project_root, token or "", args.dry_run)

    # Set up GitHub secret
    if token and setup_secret:
        setup_github_secret(repo, "CODECOV_TOKEN", args.dry_run)
    elif not token:
        print("\n⚠️  No Codecov token provided.")
        print("   You can:")
        print("   1. Get token from https://app.codecov.io/gh/" + repo)
        print("   2. Add CODECOV_TOKEN to your GitHub secrets")
        print("   3. Set CODECOV_TOKEN in your .env file")

    # Validate configuration
    if not args.dry_run:
        print("\n🔍 Validating setup...")
        results = validate_codecov_config(project_root)

        for check, passed in results.items():
            status = "✅" if passed else "❌"
            print(f"  {status} {check.replace('_', ' ').title()}")

        if all(results.values()):
            print("\n🎉 Codecov setup completed successfully!")
            print("\nNext steps:")
            print("1. Commit and push your changes")
            print("2. Create a pull request to test coverage reporting")
            print("3. Check Codecov dashboard at https://app.codecov.io/gh/" + repo)

            # Test upload if token is available
            if token and not args.dry_run:
                test_upload = input("\nTest coverage upload now? (y/N): ").strip().lower()
                if test_upload in ['y', 'yes']:
                    print("🧪 Testing coverage upload...")
                    os.environ['CODECOV_TOKEN'] = token
                    success, output = run_command([
                        sys.executable, "scripts/dev_assistant.py", "upload-coverage", "--dry-run"
                    ], cwd=project_root)
                    if success:
                        print("✅ Coverage upload test successful")
                    else:
                        print(f"⚠️  Coverage upload test failed: {output}")
        else:
            print("\n⚠️  Setup completed with some issues. Check the validation results above.")

    print(f"\n📚 Documentation: {project_root}/docs/codecov-integration.md")

if __name__ == '__main__':
    main()
