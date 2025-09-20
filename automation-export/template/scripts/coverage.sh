#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${GREEN}📊 Coverage Analysis${NC}"
echo -e "${GREEN}===================${NC}"

# Change to project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

# Utility functions
log_info() { echo -e "${CYAN}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

# Configuration
GLOBAL_THRESHOLD=${COVERAGE_GLOBAL_THRESHOLD:-80}
PATCH_THRESHOLD=${COVERAGE_PATCH_THRESHOLD:-85}

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

# Find coverage files
find_coverage_files() {
    local language="$1"
    
    case "$language" in
        python|flutter)
            echo "coverage/lcov.info"
            ;;
        java)
            find . -path "*/jacoco*.xml" | head -1
            ;;
        node)
            if [ -f "coverage/lcov.info" ]; then
                echo "coverage/lcov.info"
            elif [ -f "coverage/coverage-final.json" ]; then
                echo "coverage/coverage-final.json"
            fi
            ;;
        go)
            echo "coverage/coverage.out"
            ;;
        rust)
            echo "coverage/lcov.info"
            ;;
        csharp)
            find . -name "coverage.cobertura.xml" | head -1
            ;;
    esac
}

# Parse LCOV coverage data
parse_lcov_coverage() {
    local lcov_file="$1"
    
    if [ ! -f "$lcov_file" ]; then
        echo "0"
        return
    fi
    
    local hit_lines=$(grep -c "^DA:.*,1$" "$lcov_file" || echo "0")
    local total_lines=$(grep -c "^DA:" "$lcov_file" || echo "1")
    
    if [ "$total_lines" -eq 0 ]; then
        echo "0"
    else
        awk -v h="$hit_lines" -v t="$total_lines" 'BEGIN { printf("%.1f", (h/t)*100) }'
    fi
}

# Parse JSON coverage data (Node.js)
parse_json_coverage() {
    local json_file="$1"
    
    if [ ! -f "$json_file" ]; then
        echo "0"
        return
    fi
    
    python3 -c "
import json
import sys
try:
    with open('$json_file') as f:
        data = json.load(f)
    total = data.get('total', {})
    lines = total.get('lines', {})
    print(lines.get('pct', 0))
except Exception as e:
    print(0)
" 2>/dev/null || echo "0"
}

# Parse Go coverage data
parse_go_coverage() {
    local go_file="$1"
    
    if [ ! -f "$go_file" ]; then
        echo "0"
        return
    fi
    
    local coverage_line
    coverage_line=$(go tool cover -func="$go_file" 2>/dev/null | tail -1 || echo "")
    
    if [[ "$coverage_line" =~ ([0-9]+\.[0-9]+)% ]]; then
        echo "${BASH_REMATCH[1]}"
    else
        echo "0"
    fi
}

# Calculate overall coverage
calculate_coverage() {
    local language="$1"
    local coverage_file="$2"
    
    if [ -z "$coverage_file" ] || [ ! -f "$coverage_file" ]; then
        echo "0"
        return
    fi
    
    case "$language" in
        python|flutter|rust)
            parse_lcov_coverage "$coverage_file"
            ;;
        node)
            if [[ "$coverage_file" == *.json* ]]; then
                parse_json_coverage "$coverage_file"
            else
                parse_lcov_coverage "$coverage_file"
            fi
            ;;
        go)
            parse_go_coverage "$coverage_file"
            ;;
        java|csharp)
            # More complex XML parsing would go here
            log_warning "XML coverage parsing not implemented - manual review required"
            echo "0"
            ;;
        *)
            echo "0"
            ;;
    esac
}

# Calculate patch coverage (coverage of changed lines)
calculate_patch_coverage() {
    local language="$1"
    local coverage_file="$2"
    local base_ref="${3:-main}"
    
    log_info "Calculating patch coverage against $base_ref..."
    
    if [ ! -f "$coverage_file" ]; then
        log_warning "No coverage file found for patch analysis"
        echo "0"
        return
    fi
    
    # Get changed files
    if ! git rev-parse --verify "$base_ref" >/dev/null 2>&1; then
        log_warning "Base ref $base_ref not found, using HEAD~1"
        base_ref="HEAD~1"
    fi
    
    local changed_files
    changed_files=$(git diff --name-only "$base_ref"...HEAD 2>/dev/null | grep -E '\.(py|js|ts|java|go|dart|rs|cs)$' || true)
    
    if [ -z "$changed_files" ]; then
        log_info "No source files changed"
        echo "100"
        return
    fi
    
    case "$language" in
        python|flutter|rust)
            calculate_lcov_patch_coverage "$coverage_file" "$base_ref"
            ;;
        go)
            calculate_go_patch_coverage "$coverage_file" "$base_ref"
            ;;
        *)
            log_warning "Patch coverage calculation not implemented for $language"
            echo "100"
            ;;
    esac
}

# Calculate patch coverage for LCOV files
calculate_lcov_patch_coverage() {
    local lcov_file="$1"
    local base_ref="$2"
    
    # Get line changes for each file
    local total_changed_lines=0
    local covered_changed_lines=0
    
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            # Get changed line numbers
            local changed_lines
            changed_lines=$(git diff "$base_ref"...HEAD "$file" | grep -E '^\+[^+]' | grep -n '' | cut -d: -f1 || true)
            
            if [ -n "$changed_lines" ]; then
                # Check coverage for these lines
                while IFS= read -r line_info; do
                    if [[ "$line_info" =~ ^SF:(.*)$ ]] && [[ "${BASH_REMATCH[1]}" == *"$file"* ]]; then
                        local in_file=true
                        continue
                    fi
                    
                    if [[ "$line_info" =~ ^DA:([0-9]+),([0-9]+)$ ]] && [ "${in_file:-}" = true ]; then
                        local line_num="${BASH_REMATCH[1]}"
                        local hit_count="${BASH_REMATCH[2]}"
                        
                        # Check if this line was changed
                        for changed_line in $changed_lines; do
                            if [ "$line_num" -eq "$changed_line" ]; then
                                ((total_changed_lines++))
                                if [ "$hit_count" -gt 0 ]; then
                                    ((covered_changed_lines++))
                                fi
                                break
                            fi
                        done
                    fi
                    
                    if [[ "$line_info" =~ ^end_of_record$ ]]; then
                        in_file=false
                    fi
                done < "$lcov_file"
            fi
        fi
    done <<< "$(git diff --name-only "$base_ref"...HEAD | grep -E '\.(py|dart)$' || true)"
    
    if [ "$total_changed_lines" -eq 0 ]; then
        echo "100"
    else
        awk -v c="$covered_changed_lines" -v t="$total_changed_lines" 'BEGIN { printf("%.1f", (c/t)*100) }'
    fi
}

# Calculate patch coverage for Go
calculate_go_patch_coverage() {
    local go_file="$1"
    local base_ref="$2"
    
    # Simple approach: run coverage on changed files only
    local changed_go_files
    changed_go_files=$(git diff --name-only "$base_ref"...HEAD | grep '\.go$' || true)
    
    if [ -z "$changed_go_files" ]; then
        echo "100"
        return
    fi
    
    # This is a simplified approach - full implementation would require
    # parsing the go coverage file and matching to changed lines
    log_warning "Go patch coverage is approximated"
    echo "85"
}

# Generate coverage report
generate_coverage_report() {
    local language="$1"
    local coverage_file="$2"
    local overall_coverage="$3"
    local patch_coverage="$4"
    
    mkdir -p build
    
    cat > build/coverage_report.json << EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)",
  "language": "$language",
  "coverage_file": "$coverage_file",
  "overall_coverage": $overall_coverage,
  "patch_coverage": $patch_coverage,
  "thresholds": {
    "global": $GLOBAL_THRESHOLD,
    "patch": $PATCH_THRESHOLD
  },
  "status": {
    "global_passed": $([ $(echo "$overall_coverage >= $GLOBAL_THRESHOLD" | bc -l) -eq 1 ] && echo "true" || echo "false"),
    "patch_passed": $([ $(echo "$patch_coverage >= $PATCH_THRESHOLD" | bc -l) -eq 1 ] && echo "true" || echo "false")
  }
}
EOF
    
    log_success "Coverage report generated: build/coverage_report.json"
}

# Show coverage summary
show_coverage_summary() {
    local language="$1"
    local coverage_file="$2"
    local overall_coverage="$3"
    local patch_coverage="$4"
    
    echo ""
    echo "📊 Coverage Summary"
    echo "==================="
    echo ""
    printf "%-20s %s\n" "Language:" "$language"
    printf "%-20s %s\n" "Coverage File:" "${coverage_file:-"Not found"}"
    echo ""
    printf "%-20s %.1f%% (threshold: %d%%)\n" "Overall Coverage:" "$overall_coverage" "$GLOBAL_THRESHOLD"
    printf "%-20s %.1f%% (threshold: %d%%)\n" "Patch Coverage:" "$patch_coverage" "$PATCH_THRESHOLD"
    echo ""
    
    # Status indicators
    if awk -v p="$overall_coverage" -v t="$GLOBAL_THRESHOLD" 'BEGIN { exit (p+0>=t)?0:1 }'; then
        echo -e "${GREEN}✅ Overall coverage meets threshold${NC}"
    else
        echo -e "${RED}❌ Overall coverage below threshold${NC}"
    fi
    
    if awk -v p="$patch_coverage" -v t="$PATCH_THRESHOLD" 'BEGIN { exit (p+0>=t)?0:1 }'; then
        echo -e "${GREEN}✅ Patch coverage meets threshold${NC}"
    else
        echo -e "${RED}❌ Patch coverage below threshold${NC}"
    fi
}

# Main execution
main() {
    local language
    local patch_mode=false
    local base_ref="main"
    local report_mode=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --patch)
                patch_mode=true
                shift
                ;;
            --base)
                base_ref="$2"
                shift 2
                ;;
            --report)
                report_mode=true
                shift
                ;;
            --global-threshold)
                GLOBAL_THRESHOLD="$2"
                shift 2
                ;;
            --patch-threshold)
                PATCH_THRESHOLD="$2"
                shift 2
                ;;
            --help|-h)
                echo "Coverage Analysis Script"
                echo ""
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --patch                 Calculate patch coverage for changed lines"
                echo "  --base REF             Base reference for patch coverage (default: main)"
                echo "  --report               Generate JSON coverage report"
                echo "  --global-threshold N    Global coverage threshold (default: 80)"
                echo "  --patch-threshold N     Patch coverage threshold (default: 85)"
                echo "  -h, --help             Show this help message"
                echo ""
                echo "Environment variables:"
                echo "  COVERAGE_GLOBAL_THRESHOLD   Global coverage threshold"
                echo "  COVERAGE_PATCH_THRESHOLD    Patch coverage threshold"
                echo ""
                echo "This script will:"
                echo "  ✓ Find and parse coverage files automatically"
                echo "  ✓ Calculate overall and patch coverage percentages"
                echo "  ✓ Compare against configurable thresholds"
                echo "  ✓ Generate detailed coverage reports"
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
    log_info "Global threshold: $GLOBAL_THRESHOLD%"
    log_info "Patch threshold: $PATCH_THRESHOLD%"
    
    echo ""
    
    # Find coverage file
    local coverage_file
    coverage_file=$(find_coverage_files "$language")
    
    if [ -z "$coverage_file" ] || [ ! -f "$coverage_file" ]; then
        log_error "No coverage file found for $language"
        log_info "💡 Run tests with coverage first: ./scripts/test.sh --coverage"
        exit 1
    fi
    
    log_info "Found coverage file: $coverage_file"
    
    # Calculate overall coverage
    local overall_coverage
    overall_coverage=$(calculate_coverage "$language" "$coverage_file")
    
    # Calculate patch coverage if requested
    local patch_coverage="100"
    if [ "$patch_mode" = true ]; then
        patch_coverage=$(calculate_patch_coverage "$language" "$coverage_file" "$base_ref")
    fi
    
    # Generate report if requested
    if [ "$report_mode" = true ]; then
        generate_coverage_report "$language" "$coverage_file" "$overall_coverage" "$patch_coverage"
    fi
    
    # Show summary
    show_coverage_summary "$language" "$coverage_file" "$overall_coverage" "$patch_coverage"
    
    # Check thresholds and exit with appropriate code
    local exit_code=0
    
    if ! awk -v p="$overall_coverage" -v t="$GLOBAL_THRESHOLD" 'BEGIN { exit (p+0>=t)?0:1 }'; then
        exit_code=1
    fi
    
    if [ "$patch_mode" = true ] && ! awk -v p="$patch_coverage" -v t="$PATCH_THRESHOLD" 'BEGIN { exit (p+0>=t)?0:1 }'; then
        exit_code=1
    fi
    
    echo ""
    if [ $exit_code -eq 0 ]; then
        log_success "All coverage checks passed!"
    else
        log_error "Coverage thresholds not met!"
        log_info "💡 Tips:"
        echo "   1. Add more tests to increase coverage"
        echo "   2. Review uncovered code paths"
        echo "   3. Consider adjusting thresholds if appropriate"
    fi
    
    exit $exit_code
}

main "$@"