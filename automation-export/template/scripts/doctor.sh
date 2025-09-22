#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${GREEN}🔍 Development Environment Health Check${NC}"
echo -e "${GREEN}=======================================${NC}"

# Change to project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

# Global status tracking
OVERALL_STATUS=0
WARNINGS=0
ERRORS=0

# Utility functions
log_info() { echo -e "${CYAN}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; ((WARNINGS++)); }
log_error() { echo -e "${RED}❌ $1${NC}"; ((ERRORS++)); OVERALL_STATUS=1; }

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect project language (same as bootstrap)
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

# Check basic system tools
check_system_tools() {
    log_info "Checking system tools..."

    local tools=("git" "curl" "python3")
    for tool in "${tools[@]}"; do
        if command_exists "$tool"; then
            local version
            case "$tool" in
                git) version=$(git --version | cut -d' ' -f3) ;;
                curl) version=$(curl --version | head -1 | cut -d' ' -f2) ;;
                python3) version=$(python3 --version | cut -d' ' -f2) ;;
            esac
            log_success "$tool $version"
        else
            log_error "$tool not found"
        fi
    done
}

# Check static analysis tools
check_static_analysis_tools() {
    log_info "Checking static analysis tools..."

    # Universal tools
    local universal_tools=("pre-commit" "yamllint" "markdownlint-cli")
    for tool in "${universal_tools[@]}"; do
        if command_exists "$tool"; then
            log_success "$tool available"
        else
            log_warning "$tool not installed (recommended for quality checks)"
        fi
    done

    # Gitleaks for secret scanning
    if command_exists "gitleaks"; then
        local gitleaks_version
        gitleaks_version=$(gitleaks version 2>/dev/null | head -1 || echo "unknown")
        log_success "gitleaks $gitleaks_version"
    else
        log_warning "gitleaks not installed (recommended for security scanning)"
    fi

    # Shellcheck for shell scripts
    if command_exists "shellcheck"; then
        log_success "shellcheck available"
    else
        log_warning "shellcheck not installed (recommended for shell script quality)"
    fi
}

# Check git configuration
check_git_config() {
    log_info "Checking Git configuration..."

    if command_exists git && [ -d ".git" ]; then
        local user_name user_email
        user_name=$(git config user.name 2>/dev/null || echo "")
        user_email=$(git config user.email 2>/dev/null || echo "")

        if [ -n "$user_name" ] && [ -n "$user_email" ]; then
            log_success "Git user configured: $user_name <$user_email>"
        else
            log_warning "Git user not configured. Run: git config --global user.name 'Your Name' && git config --global user.email 'your.email@example.com'"
        fi

        # Check if pre-commit is installed and configured
        if command_exists pre-commit; then
            if [ -f ".pre-commit-config.yaml" ]; then
                if pre-commit validate-config >/dev/null 2>&1; then
                    log_success "Pre-commit configuration valid"
                else
                    log_warning "Pre-commit configuration invalid"
                fi
            else
                log_warning "No .pre-commit-config.yaml found"
            fi
        else
            log_warning "pre-commit not installed"
        fi
    else
        log_warning "Not a Git repository or Git not available"
    fi
}

# Check language-specific tools
check_language_tools() {
    local language="$1"
    log_info "Checking $language tools..."

    case "$language" in
        python)
            if command_exists python3; then
                local python_version
                python_version=$(python3 --version | cut -d' ' -f2)
                log_success "Python $python_version"

                # Check pip
                if python3 -m pip --version >/dev/null 2>&1; then
                    local pip_version
                    pip_version=$(python3 -m pip --version | cut -d' ' -f2)
                    log_success "pip $pip_version"
                else
                    log_error "pip not available"
                fi

                # Check common dev tools
                local dev_tools=("ruff" "black" "pytest")
                for tool in "${dev_tools[@]}"; do
                    if python3 -c "import $tool" 2>/dev/null || command_exists "$tool"; then
                        log_success "$tool available"
                    else
                        log_warning "$tool not installed (install with: pip install $tool)"
                    fi
                done

                # Check project dependencies
                if [ -f "requirements.txt" ]; then
                    if python3 -m pip check >/dev/null 2>&1; then
                        log_success "Dependencies satisfied"
                    else
                        log_warning "Dependency conflicts detected. Run: pip install -r requirements.txt"
                    fi
                fi
            else
                log_error "Python 3 not found"
            fi
            ;;

        java)
            local java_found=false
            if command_exists java; then
                local java_version
                java_version=$(java -version 2>&1 | head -1 | cut -d'"' -f2)
                log_success "Java $java_version"
                java_found=true
            fi

            if command_exists mvn; then
                local mvn_version
                mvn_version=$(mvn --version | head -1 | cut -d' ' -f3)
                log_success "Maven $mvn_version"
                java_found=true
            elif command_exists gradle; then
                local gradle_version
                gradle_version=$(gradle --version | grep "Gradle" | cut -d' ' -f2)
                log_success "Gradle $gradle_version"
                java_found=true
            fi

            if [ "$java_found" = false ]; then
                log_error "Java development tools not found"
            fi
            ;;

        node)
            if command_exists node; then
                local node_version npm_version
                node_version=$(node --version)
                log_success "Node.js $node_version"

                if command_exists npm; then
                    npm_version=$(npm --version)
                    log_success "npm $npm_version"

                    # Check if node_modules exists
                    if [ -d "node_modules" ]; then
                        log_success "Dependencies installed"
                    else
                        log_warning "No node_modules found. Run: npm install"
                    fi
                else
                    log_error "npm not found"
                fi
            else
                log_error "Node.js not found"
            fi
            ;;

        go)
            if command_exists go; then
                local go_version
                go_version=$(go version | cut -d' ' -f3)
                log_success "Go $go_version"

                # Check if go.mod exists and is valid
                if [ -f "go.mod" ]; then
                    if go list -m >/dev/null 2>&1; then
                        log_success "Go module valid"
                    else
                        log_warning "Go module issues. Run: go mod tidy"
                    fi
                fi

                # Check golangci-lint
                if command_exists golangci-lint; then
                    log_success "golangci-lint available"
                else
                    log_warning "golangci-lint not installed"
                fi
            else
                log_error "Go not found"
            fi
            ;;

        flutter)
            if command_exists flutter; then
                local flutter_version
                flutter_version=$(flutter --version | head -1 | cut -d' ' -f2)
                log_success "Flutter $flutter_version"

                # Run flutter doctor
                log_info "Running flutter doctor..."
                if flutter doctor >/dev/null 2>&1; then
                    log_success "Flutter doctor passed"
                else
                    log_warning "Flutter doctor found issues. Run: flutter doctor"
                fi
            else
                log_error "Flutter not found"
            fi
            ;;

        rust)
            if command_exists rustc && command_exists cargo; then
                local rust_version cargo_version
                rust_version=$(rustc --version | cut -d' ' -f2)
                cargo_version=$(cargo --version | cut -d' ' -f2)
                log_success "Rust $rust_version, Cargo $cargo_version"

                if [ -f "Cargo.toml" ]; then
                    if cargo check --quiet >/dev/null 2>&1; then
                        log_success "Cargo project valid"
                    else
                        log_warning "Cargo project issues. Run: cargo check"
                    fi
                fi
            else
                log_error "Rust toolchain not found"
            fi
            ;;

        csharp)
            if command_exists dotnet; then
                local dotnet_version
                dotnet_version=$(dotnet --version)
                log_success ".NET SDK $dotnet_version"

                # Check if solution/project files exist
                if find . -maxdepth 2 -name "*.csproj" -o -name "*.sln" -o -name "*.fsproj" | head -1 | grep -q .; then
                    if dotnet restore --verbosity quiet >/dev/null 2>&1; then
                        log_success "Project dependencies restored"
                    else
                        log_warning "Project issues. Run: dotnet restore"
                    fi
                fi
            else
                log_error ".NET SDK not found"
            fi
            ;;

        unknown)
            log_warning "Unknown project type - skipping language-specific checks"
            ;;
    esac
}

# Check project structure
check_project_structure() {
    log_info "Checking project structure..."

    local required_dirs=("coverage" "build" ".vscode")
    for dir in "${required_dirs[@]}"; do
        if [ -d "$dir" ]; then
            log_success "Directory $dir exists"
        else
            log_warning "Directory $dir missing (will be created automatically)"
        fi
    done

    # Check automation config
    if [ -f "automation.config.yaml" ]; then
        log_success "Automation config found"
    else
        log_warning "automation.config.yaml not found"
    fi
}

# Check file permissions
check_permissions() {
    log_info "Checking script permissions..."

    local scripts_dir="scripts"
    if [ -d "$scripts_dir" ]; then
        local script_count=0
        local executable_count=0

        for script in "$scripts_dir"/*.sh; do
            if [ -f "$script" ]; then
                ((script_count++))
                if [ -x "$script" ]; then
                    ((executable_count++))
                fi
            fi
        done

        if [ $script_count -eq $executable_count ]; then
            log_success "All $script_count shell scripts are executable"
        else
            log_warning "$((script_count - executable_count)) scripts need execute permission. Run: chmod +x scripts/*.sh"
        fi
    fi
}

# Main health check
main() {
    local language
    language=$(detect_language)

    log_info "Project root: $PROJECT_ROOT"
    log_info "Detected language: $language"
    echo ""

    check_system_tools
    echo ""
    check_static_analysis_tools
    echo ""
    check_git_config
    echo ""
    check_language_tools "$language"
    echo ""
    check_project_structure
    echo ""
    check_permissions
    echo ""

    # Summary
    echo -e "${BLUE}📊 Health Check Summary${NC}"
    echo "========================"

    if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
        log_success "All checks passed! Your development environment is ready."
    elif [ $ERRORS -eq 0 ]; then
        echo -e "${YELLOW}⚠️  $WARNINGS warning(s) found, but no critical errors.${NC}"
        echo -e "${CYAN}💡 Your environment should work, but consider addressing the warnings.${NC}"
    else
        echo -e "${RED}❌ $ERRORS error(s) and $WARNINGS warning(s) found.${NC}"
        echo -e "${CYAN}💡 Please resolve the errors before proceeding.${NC}"
    fi

    echo ""
    if [ "$OVERALL_STATUS" -eq 0 ]; then
        echo -e "${GREEN}🚀 Ready to start development!${NC}"
        echo -e "${CYAN}💡 Next steps:${NC}"
        echo "   1. Run './scripts/lint.sh' to check code quality"
        echo "   2. Run './scripts/test.sh' to run tests"
        echo "   3. Run './scripts/build.sh' to build the project"
    else
        echo -e "${YELLOW}⚡ Run './scripts/bootstrap.sh' to set up missing tools${NC}"
    fi
}

# Handle help flag
if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    echo "Development Environment Health Check"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo ""
    echo "This script checks:"
    echo "  ✓ System tools (git, curl, python3)"
    echo "  ✓ Git configuration and hooks"
    echo "  ✓ Language-specific tools and dependencies"
    echo "  ✓ Project structure and permissions"
    echo "  ✓ Automation configuration"
    exit 0
fi

main
exit $OVERALL_STATUS
