#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${GREEN}🧪 Running Tests${NC}"
echo -e "${GREEN}===============${NC}"

# Change to project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

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

# Run language-specific tests
run_tests() {
    local language="$1"
    local coverage_mode="$2"
    local verbose_mode="$3"
    
    log_info "Running $language tests (coverage: $coverage_mode, verbose: $verbose_mode)..."
    
    # Ensure coverage directory exists
    mkdir -p coverage
    
    case "$language" in
        python)
            if [ "$coverage_mode" = "true" ]; then
                log_info "Running Python tests with coverage..."
                if command -v pytest >/dev/null 2>&1; then
                    local pytest_args=("--cov=." "--cov-report=lcov:coverage/lcov.info" "--cov-report=term")
                    if [ "$verbose_mode" = "true" ]; then
                        pytest_args+=("-v")
                    else
                        pytest_args+=("-q")
                    fi
                    pytest "${pytest_args[@]}"
                else
                    log_warning "pytest not found, falling back to unittest"
                    if command -v coverage >/dev/null 2>&1; then
                        coverage run -m unittest discover
                        coverage lcov -o coverage/lcov.info
                        coverage report
                    else
                        python -m unittest discover
                    fi
                fi
            else
                log_info "Running Python tests..."
                if command -v pytest >/dev/null 2>&1; then
                    if [ "$verbose_mode" = "true" ]; then
                        pytest -v
                    else
                        pytest -q
                    fi
                else
                    python -m unittest discover
                fi
            fi
            ;;
            
        java)
            if command -v mvn >/dev/null 2>&1; then
                log_info "Running Java tests with Maven..."
                local mvn_args=("test")
                if [ "$coverage_mode" = "true" ]; then
                    mvn_args+=("jacoco:report")
                fi
                if [ "$verbose_mode" != "true" ]; then
                    mvn_args=("-q" "${mvn_args[@]}")
                fi
                mvn "${mvn_args[@]}"
            elif command -v gradle >/dev/null 2>&1; then
                log_info "Running Java tests with Gradle..."
                local gradle_args=("test")
                if [ "$coverage_mode" = "true" ]; then
                    gradle_args+=("jacocoTestReport")
                fi
                if [ "$verbose_mode" != "true" ]; then
                    gradle_args=("--quiet" "${gradle_args[@]}")
                fi
                gradle "${gradle_args[@]}"
            else
                log_error "Neither Maven nor Gradle found"
                return 1
            fi
            ;;
            
        node)
            if [ -f "package.json" ]; then
                if [ "$coverage_mode" = "true" ]; then
                    if grep -q '"test:coverage"' package.json; then
                        log_info "Running Node.js tests with coverage..."
                        npm run test:coverage
                    elif command -v nyc >/dev/null 2>&1; then
                        log_info "Running Node.js tests with nyc coverage..."
                        nyc npm test
                    else
                        log_warning "No coverage tool found, running tests without coverage"
                        npm test
                    fi
                else
                    log_info "Running Node.js tests..."
                    if [ "$verbose_mode" = "true" ]; then
                        npm test -- --verbose
                    else
                        npm test
                    fi
                fi
            else
                log_error "package.json not found"
                return 1
            fi
            ;;
            
        go)
            log_info "Running Go tests..."
            local go_args=("test" "./...")
            
            if [ "$coverage_mode" = "true" ]; then
                go_args+=("-coverprofile=coverage/coverage.out")
            fi
            
            if [ "$verbose_mode" = "true" ]; then
                go_args+=("-v")
            fi
            
            go "${go_args[@]}"
            
            if [ "$coverage_mode" = "true" ] && [ -f "coverage/coverage.out" ]; then
                log_info "Generating coverage report..."
                go tool cover -func=coverage/coverage.out
                # Convert to lcov format if gcov2lcov is available
                if command -v gcov2lcov >/dev/null 2>&1; then
                    gcov2lcov -infile coverage/coverage.out -outfile coverage/lcov.info
                fi
            fi
            ;;
            
        flutter)
            log_info "Running Flutter tests..."
            local flutter_args=("test")
            
            if [ "$coverage_mode" = "true" ]; then
                flutter_args+=("--coverage")
            fi
            
            if [ "$verbose_mode" != "true" ]; then
                flutter_args+=("--reporter" "compact")
            fi
            
            flutter "${flutter_args[@]}"
            ;;
            
        rust)
            log_info "Running Rust tests..."
            local cargo_args=("test")
            
            if [ "$verbose_mode" = "true" ]; then
                cargo_args+=("--verbose")
            fi
            
            if [ "$coverage_mode" = "true" ]; then
                if command -v cargo-tarpaulin >/dev/null 2>&1; then
                    log_info "Running tests with coverage using tarpaulin..."
                    cargo tarpaulin --out lcov --output-dir coverage
                else
                    log_warning "cargo-tarpaulin not found, running tests without coverage"
                    cargo "${cargo_args[@]}"
                fi
            else
                cargo "${cargo_args[@]}"
            fi
            ;;
            
        csharp)
            log_info "Running .NET tests..."
            local dotnet_args=("test")
            
            if [ "$coverage_mode" = "true" ]; then
                dotnet_args+=("--collect:XPlat Code Coverage")
            fi
            
            if [ "$verbose_mode" != "true" ]; then
                dotnet_args+=("--verbosity" "quiet")
            fi
            
            dotnet "${dotnet_args[@]}"
            ;;
            
        unknown)
            log_error "Unknown project type - cannot run tests"
            return 1
            ;;
    esac
    
    return 0
}

# Check coverage thresholds
check_coverage() {
    local language="$1"
    
    log_info "Checking coverage thresholds..."
    
    local coverage_file=""
    local threshold=80  # Default threshold
    
    # Find coverage file based on language
    case "$language" in
        python|flutter)
            coverage_file="coverage/lcov.info"
            ;;
        java)
            coverage_file=$(find . -path "*/jacoco*.xml" | head -1)
            ;;
        node)
            if [ -f "coverage/lcov.info" ]; then
                coverage_file="coverage/lcov.info"
            elif [ -f "coverage/coverage-final.json" ]; then
                coverage_file="coverage/coverage-final.json"
            fi
            ;;
        go)
            coverage_file="coverage/coverage.out"
            ;;
        rust)
            coverage_file="coverage/lcov.info"
            ;;
        csharp)
            coverage_file=$(find . -name "coverage.cobertura.xml" | head -1)
            ;;
    esac
    
    if [ -n "$coverage_file" ] && [ -f "$coverage_file" ]; then
        log_info "Found coverage file: $coverage_file"
        
        # Calculate coverage percentage based on file type
        local coverage_pct=0
        
        if [[ "$coverage_file" == *.lcov* ]]; then
            # LCOV format
            local hit_lines=$(grep -c "^DA:.*,1$" "$coverage_file" || echo "0")
            local total_lines=$(grep -c "^DA:" "$coverage_file" || echo "1")
            coverage_pct=$(awk -v h="$hit_lines" -v t="$total_lines" 'BEGIN { printf("%.1f", (h/t)*100) }')
        elif [[ "$coverage_file" == *.json* ]]; then
            # JSON format (Node.js)
            coverage_pct=$(python3 -c "
import json
with open('$coverage_file') as f:
    data = json.load(f)
    total = data.get('total', {})
    lines = total.get('lines', {})
    print(lines.get('pct', 0))
" 2>/dev/null || echo "0")
        elif [[ "$coverage_file" == *.out* ]]; then
            # Go coverage format
            coverage_pct=$(go tool cover -func="$coverage_file" | tail -1 | awk '{print substr($3, 1, length($3)-1)}')
        fi
        
        log_info "Coverage: ${coverage_pct}%"
        
        # Check threshold
        if awk -v p="$coverage_pct" -v t="$threshold" 'BEGIN { exit (p+0>=t)?0:1 }'; then
            log_success "Coverage ${coverage_pct}% meets threshold of ${threshold}%"
        else
            log_warning "Coverage ${coverage_pct}% below threshold of ${threshold}%"
            return 1
        fi
    else
        log_warning "No coverage file found, skipping threshold check"
    fi
    
    return 0
}

# Main execution
main() {
    local language
    local coverage_mode=false
    local verbose_mode=false
    local check_coverage_flag=true
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --coverage)
                coverage_mode=true
                shift
                ;;
            --verbose|-v)
                verbose_mode=true
                shift
                ;;
            --no-coverage-check)
                check_coverage_flag=false
                shift
                ;;
            --help|-h)
                echo "Test Runner Script"
                echo ""
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --coverage           Run tests with coverage reporting"
                echo "  --verbose, -v        Run tests in verbose mode"
                echo "  --no-coverage-check  Skip coverage threshold checking"
                echo "  -h, --help          Show this help message"
                echo ""
                echo "This script will:"
                echo "  ✓ Detect project language automatically"
                echo "  ✓ Run language-specific test suites"
                echo "  ✓ Generate coverage reports (if requested)"
                echo "  ✓ Check coverage thresholds"
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
    
    if [ "$coverage_mode" = "true" ]; then
        log_info "Coverage reporting enabled"
    fi
    
    if [ "$verbose_mode" = "true" ]; then
        log_info "Verbose mode enabled"
    fi
    
    echo ""
    
    # Run tests
    local test_status=0
    if ! run_tests "$language" "$coverage_mode" "$verbose_mode"; then
        test_status=1
    fi
    
    # Check coverage if enabled and tests passed
    if [ $test_status -eq 0 ] && [ "$coverage_mode" = "true" ] && [ "$check_coverage_flag" = "true" ]; then
        echo ""
        if ! check_coverage "$language"; then
            test_status=1
        fi
    fi
    
    echo ""
    
    # Summary
    if [ $test_status -eq 0 ]; then
        log_success "All tests passed!"
        if [ "$coverage_mode" = "true" ]; then
            log_info "💡 Coverage reports generated in coverage/ directory"
        fi
        echo ""
        log_info "💡 Next steps:"
        echo "   1. Run './scripts/build.sh' to build the project"
        echo "   2. Check coverage reports for improvement opportunities"
    else
        log_error "Tests failed!"
        log_info "💡 Tips:"
        echo "   1. Check test output above for specific failures"
        echo "   2. Run with --verbose for more detailed output"
        echo "   3. Fix failing tests before proceeding"
    fi
    
    return $test_status
}

main "$@"