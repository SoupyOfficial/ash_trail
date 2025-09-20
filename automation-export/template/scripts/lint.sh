#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${GREEN}🔍 Code Quality & Linting${NC}"
echo -e "${GREEN}=========================${NC}"

# Change to project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

# Check if automation config exists and parse it
CONFIG_FILE="automation.config.yaml"
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}❌ $CONFIG_FILE not found. Run ./scripts/bootstrap.sh first${NC}"
    exit 1
fi

# Utility functions
log_info() { echo -e "${CYAN}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

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

# Run language-specific linting
run_lint() {
    local language="$1"
    local fix_mode="$2"
    
    log_info "Running $language linting (fix mode: $fix_mode)..."
    
    case "$language" in
        python)
            if [ "$fix_mode" = "true" ]; then
                log_info "Fixing Python code formatting and linting issues..."
                if command -v ruff >/dev/null 2>&1; then
                    ruff check --fix . || true
                fi
                if command -v black >/dev/null 2>&1; then
                    black .
                fi
            else
                local lint_failed=false
                log_info "Checking Python code with ruff..."
                if command -v ruff >/dev/null 2>&1; then
                    if ! ruff check .; then
                        lint_failed=true
                    fi
                else
                    log_warning "ruff not found, skipping lint check"
                fi
                
                log_info "Checking Python formatting with black..."
                if command -v black >/dev/null 2>&1; then
                    if ! black --check .; then
                        log_error "Code formatting issues found. Run: ./scripts/lint.sh --fix"
                        lint_failed=true
                    fi
                else
                    log_warning "black not found, skipping format check"
                fi
                
                if [ "$lint_failed" = true ]; then
                    return 1
                fi
            fi
            ;;
            
        java)
            if command -v mvn >/dev/null 2>&1; then
                if [ "$fix_mode" = "true" ]; then
                    log_info "Applying Java code formatting..."
                    mvn spotless:apply
                else
                    log_info "Checking Java code formatting..."
                    if ! mvn spotless:check -q; then
                        log_error "Java formatting issues found. Run: ./scripts/lint.sh --fix"
                        return 1
                    fi
                fi
            elif command -v gradle >/dev/null 2>&1; then
                if [ "$fix_mode" = "true" ]; then
                    log_info "Applying Java code formatting..."
                    gradle spotlessApply
                else
                    log_info "Checking Java code formatting..."
                    if ! gradle spotlessCheck; then
                        log_error "Java formatting issues found. Run: ./scripts/lint.sh --fix"
                        return 1
                    fi
                fi
            else
                log_error "Neither Maven nor Gradle found"
                return 1
            fi
            ;;
            
        node)
            if [ -f "package.json" ] && grep -q '"lint"' package.json; then
                if [ "$fix_mode" = "true" ]; then
                    log_info "Fixing JavaScript/TypeScript code..."
                    if grep -q '"lint:fix"' package.json; then
                        npm run lint:fix
                    else
                        npx eslint --fix . || true
                    fi
                else
                    log_info "Linting JavaScript/TypeScript code..."
                    npm run lint
                fi
            else
                log_info "Running ESLint directly..."
                if command -v npx >/dev/null 2>&1; then
                    if [ "$fix_mode" = "true" ]; then
                        npx eslint --fix . || true
                    else
                        if ! npx eslint .; then
                            log_error "ESLint issues found. Run: ./scripts/lint.sh --fix"
                            return 1
                        fi
                    fi
                else
                    log_warning "npx not found, skipping lint"
                fi
            fi
            ;;
            
        go)
            local lint_failed=false
            
            log_info "Running go vet..."
            if ! go vet ./...; then
                lint_failed=true
            fi
            
            if [ "$fix_mode" = "true" ]; then
                log_info "Formatting Go code..."
                go fmt ./...
                if command -v golangci-lint >/dev/null 2>&1; then
                    golangci-lint run --fix || true
                fi
            else
                log_info "Checking Go code formatting..."
                if [ -n "$(go fmt ./...)" ]; then
                    log_error "Go formatting issues found. Run: ./scripts/lint.sh --fix"
                    lint_failed=true
                fi
                
                if command -v golangci-lint >/dev/null 2>&1; then
                    log_info "Running golangci-lint..."
                    if ! golangci-lint run; then
                        lint_failed=true
                    fi
                else
                    log_warning "golangci-lint not found, skipping advanced linting"
                fi
            fi
            
            if [ "$lint_failed" = true ]; then
                return 1
            fi
            ;;
            
        flutter)
            if [ "$fix_mode" = "true" ]; then
                log_info "Formatting Dart code..."
                dart format .
            else
                local lint_failed=false
                
                log_info "Checking Dart formatting..."
                if ! dart format --set-exit-if-changed .; then
                    log_error "Dart formatting issues found. Run: ./scripts/lint.sh --fix"
                    lint_failed=true
                fi
                
                log_info "Running Flutter analyzer..."
                if ! flutter analyze; then
                    lint_failed=true
                fi
                
                if [ "$lint_failed" = true ]; then
                    return 1
                fi
            fi
            ;;
            
        rust)
            if [ "$fix_mode" = "true" ]; then
                log_info "Formatting Rust code..."
                cargo fmt
                if command -v cargo-clippy >/dev/null 2>&1; then
                    cargo clippy --fix --allow-dirty || true
                fi
            else
                local lint_failed=false
                
                log_info "Checking Rust formatting..."
                if ! cargo fmt --check; then
                    log_error "Rust formatting issues found. Run: ./scripts/lint.sh --fix"
                    lint_failed=true
                fi
                
                log_info "Running Clippy..."
                if ! cargo clippy -- -D warnings; then
                    lint_failed=true
                fi
                
                if [ "$lint_failed" = true ]; then
                    return 1
                fi
            fi
            ;;
            
        csharp)
            if [ "$fix_mode" = "true" ]; then
                log_info "Formatting C# code..."
                dotnet format
            else
                log_info "Checking C# formatting..."
                if ! dotnet format --verify-no-changes; then
                    log_error "C# formatting issues found. Run: ./scripts/lint.sh --fix"
                    return 1
                fi
            fi
            ;;
            
        unknown)
            log_warning "Unknown project type - no language-specific linting available"
            ;;
    esac
    
    return 0
}

# Generic file checks
run_generic_checks() {
    local fix_mode="$1"
    log_info "Running generic file checks..."
    
    # Check for trailing whitespace
    if [ "$fix_mode" = "true" ]; then
        log_info "Removing trailing whitespace..."
        find . -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.java" -o -name "*.go" -o -name "*.dart" -o -name "*.rs" -o -name "*.cs" \) -exec sed -i 's/[[:space:]]*$//' {} \; 2>/dev/null || true
    else
        if grep -r '[[:space:]]$' --include="*.py" --include="*.js" --include="*.ts" --include="*.java" --include="*.go" --include="*.dart" --include="*.rs" --include="*.cs" . >/dev/null 2>&1; then
            log_error "Trailing whitespace found. Run: ./scripts/lint.sh --fix"
            return 1
        fi
    fi
    
    # Check for missing newlines at end of files
    if [ "$fix_mode" = "true" ]; then
        log_info "Adding newlines to end of files..."
        find . -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.java" -o -name "*.go" -o -name "*.dart" -o -name "*.rs" -o -name "*.cs" \) -exec sh -c 'test "$(tail -c1 "$1")" && printf "\n" >> "$1"' _ {} \; 2>/dev/null || true
    fi
    
    return 0
}

# Main execution
main() {
    local language
    local fix_mode=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --fix)
                fix_mode=true
                shift
                ;;
            --help|-h)
                echo "Code Quality & Linting Script"
                echo ""
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --fix      Fix issues automatically where possible"
                echo "  -h, --help Show this help message"
                echo ""
                echo "This script will:"
                echo "  ✓ Detect project language automatically"
                echo "  ✓ Run language-specific linting tools"
                echo "  ✓ Check code formatting"
                echo "  ✓ Perform generic file quality checks"
                echo ""
                echo "Supported languages: python, java, node, go, flutter, rust, csharp"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
    
    language=$(detect_language)
    log_info "Project root: $PROJECT_ROOT"
    log_info "Detected language: $language"
    
    if [ "$fix_mode" = "true" ]; then
        log_info "Running in fix mode - will attempt to fix issues"
    else
        log_info "Running in check mode - will report issues only"
    fi
    
    echo ""
    
    # Run language-specific linting
    local lint_status=0
    if ! run_lint "$language" "$fix_mode"; then
        lint_status=1
    fi
    
    # Run generic checks
    if ! run_generic_checks "$fix_mode"; then
        lint_status=1
    fi
    
    echo ""
    
    # Summary
    if [ $lint_status -eq 0 ]; then
        if [ "$fix_mode" = "true" ]; then
            log_success "All issues have been fixed!"
        else
            log_success "All linting checks passed!"
        fi
        echo ""
        log_info "💡 Next steps:"
        echo "   1. Run './scripts/test.sh' to run tests"
        echo "   2. Run './scripts/build.sh' to build the project"
    else
        if [ "$fix_mode" = "true" ]; then
            log_warning "Some issues could not be automatically fixed"
            log_info "💡 Manual intervention may be required"
        else
            log_error "Linting issues found!"
            log_info "💡 Run './scripts/lint.sh --fix' to attempt automatic fixes"
        fi
    fi
    
    return $lint_status
}

main "$@"