#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Development Environment Bootstrap"
echo "====================================="

# Change to project root (script should be in scripts/ subdirectory)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

echo "📁 Project root: $PROJECT_ROOT"

# Source configuration
CONFIG_FILE="automation.config.yaml"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ automation.config.yaml not found. Creating default..."
    cp scripts/../automation.config.yaml . 2>/dev/null || {
        echo "❌ Could not find automation config template"
        exit 1
    }
fi

# Detect project language
detect_language() {
    if [ -f "pyproject.toml" ] || [ -f "requirements.txt" ] || [ -f "setup.py" ]; then
        echo "python"
    elif [ -f "pom.xml" ] || [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
        echo "java"
    elif [ -f "package.json" ]; then
        echo "node"
    elif [ -f "go.mod" ]; then
        echo "go"
    elif [ -f "pubspec.yaml" ]; then
        echo "flutter"
    elif [ -f "Cargo.toml" ]; then
        echo "rust"
    elif find . -maxdepth 2 -name "*.csproj" -o -name "*.sln" -o -name "*.fsproj" | head -1 | grep -q .; then
        echo "csharp"
    else
        echo "unknown"
    fi
}

LANGUAGE=$(detect_language)
echo "🔍 Detected language: $LANGUAGE"

if [ "$LANGUAGE" = "unknown" ]; then
    echo "⚠️  Could not detect project language. Continuing with generic setup..."
fi

# Install system dependencies based on OS
install_system_deps() {
    echo "📦 Installing system dependencies..."
    
    if command -v apt-get >/dev/null 2>&1; then
        # Ubuntu/Debian
        sudo apt-get update -qq
        sudo apt-get install -y git curl wget python3 python3-pip
    elif command -v yum >/dev/null 2>&1; then
        # RHEL/CentOS
        sudo yum install -y git curl wget python3 python3-pip
    elif command -v brew >/dev/null 2>&1; then
        # macOS with Homebrew
        brew update
        brew install git curl wget python3
    else
        echo "⚠️  Unknown package manager. Please install git, curl, wget, python3 manually."
    fi
}

# Install language-specific tools
install_language_tools() {
    echo "🔧 Installing $LANGUAGE tools..."
    
    case "$LANGUAGE" in
        python)
            python3 -m pip install --upgrade pip
            if [ -f "requirements.txt" ]; then
                pip install -r requirements.txt
            fi
            if [ -f "pyproject.toml" ]; then
                pip install -e .
            fi
            # Common dev tools
            pip install ruff black pytest coverage
            ;;
        java)
            if ! command -v mvn >/dev/null 2>&1 && ! command -v gradle >/dev/null 2>&1; then
                echo "⚠️  Please install Maven or Gradle manually"
            fi
            ;;
        node)
            if ! command -v node >/dev/null 2>&1; then
                echo "⚠️  Please install Node.js manually"
            else
                npm install
            fi
            ;;
        go)
            if ! command -v go >/dev/null 2>&1; then
                echo "⚠️  Please install Go manually"
            else
                go mod tidy 2>/dev/null || echo "No go.mod found"
                go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
            fi
            ;;
        flutter)
            if ! command -v flutter >/dev/null 2>&1; then
                echo "⚠️  Please install Flutter manually"
            else
                flutter pub get
            fi
            ;;
        rust)
            if ! command -v cargo >/dev/null 2>&1; then
                echo "⚠️  Please install Rust manually"
            else
                cargo fetch
            fi
            ;;
        csharp)
            if ! command -v dotnet >/dev/null 2>&1; then
                echo "⚠️  Please install .NET SDK manually"
            else
                dotnet restore
            fi
            ;;
    esac
}

# Setup git hooks
setup_git_hooks() {
    echo "🪝 Setting up git hooks..."
    
    if [ -d ".git" ]; then
        # Install pre-commit if not present
        if ! command -v pre-commit >/dev/null 2>&1; then
            echo "📦 Installing pre-commit..."
            if command -v pip3 >/dev/null 2>&1; then
                pip3 install pre-commit
            elif command -v pip >/dev/null 2>&1; then
                pip install pre-commit
            else
                echo "⚠️  Could not install pre-commit. Please install manually."
                return
            fi
        fi
        
        # Install hooks if config exists
        if [ -f ".pre-commit-config.yaml" ]; then
            pre-commit install
            echo "✅ Pre-commit hooks installed"
        else
            echo "⚠️  No .pre-commit-config.yaml found. Hooks not installed."
        fi
    else
        echo "⚠️  Not a git repository. Skipping hook setup."
    fi
}

# Create necessary directories
create_directories() {
    echo "📁 Creating project directories..."
    mkdir -p coverage build logs .vscode
}

# Main execution
main() {
    echo ""
    echo "Starting bootstrap process..."
    echo ""
    
    # Basic checks
    if ! command -v git >/dev/null 2>&1; then
        echo "Installing system dependencies..."
        install_system_deps
    fi
    
    create_directories
    install_language_tools
    setup_git_hooks
    
    echo ""
    echo "🎉 Bootstrap complete!"
    echo ""
    echo "📝 Next steps:"
    echo "1. Run './scripts/doctor.sh' to validate your setup"
    echo "2. Run './scripts/lint.sh' to check code quality"
    echo "3. Run './scripts/test.sh' to run tests"
    echo ""
    echo "💡 Tip: Use './scripts/doctor.sh --help' to see available commands"
}

# Help message
if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    echo "Development Environment Bootstrap Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  --skip-deps    Skip system dependency installation" 
    echo "  --skip-hooks   Skip git hooks setup"
    echo ""
    echo "This script will:"
    echo "  1. Detect your project language"
    echo "  2. Install necessary system dependencies"
    echo "  3. Install language-specific tools"
    echo "  4. Setup git hooks"
    echo "  5. Create necessary directories"
    exit 0
fi

# Parse arguments
SKIP_DEPS=false
SKIP_HOOKS=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-deps)
            SKIP_DEPS=true
            shift
            ;;
        --skip-hooks)
            SKIP_HOOKS=true
            shift
            ;;
        *)
            echo "❌ Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Run with options
if [ "$SKIP_DEPS" = false ]; then
    main
else
    echo "⚠️  Skipping dependency installation as requested"
    create_directories
    [ "$SKIP_HOOKS" = false ] && setup_git_hooks
    echo "🎉 Bootstrap complete (with skips)!"
fi