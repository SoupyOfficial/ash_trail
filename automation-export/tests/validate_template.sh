#!/usr/bin/env bash
set -euo pipefail

# Template validation test script
echo "🧪 Testing Automation Template"
echo "==============================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/../template"
SAMPLES_DIR="$SCRIPT_DIR/../samples"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${CYAN}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

test_template_structure() {
    log_info "Testing template structure..."
    
    local required_files=(
        "automation.config.yaml"
        "scripts/bootstrap.sh"
        "scripts/bootstrap.ps1"
        "scripts/doctor.sh"
        "scripts/doctor.ps1"
        "scripts/lint.sh"
        "scripts/lint.ps1"
        "scripts/test.sh"
        "scripts/test.ps1"
        "scripts/build.sh"
        "scripts/build.ps1"
        "ci/github/workflows/automation.yml"
        "docs/README.md"
        "docs/MIGRATION.md"
    )
    
    for file in "${required_files[@]}"; do
        if [ -f "$TEMPLATE_DIR/$file" ]; then
            log_success "Found $file"
        else
            log_error "Missing required file: $file"
            return 1
        fi
    done
    
    # Check script permissions
    for script in "$TEMPLATE_DIR"/scripts/*.sh; do
        if [ -x "$script" ]; then
            log_success "$(basename "$script") is executable"
        else
            log_error "$(basename "$script") is not executable"
            return 1
        fi
    done
    
    return 0
}

test_python_sample() {
    log_info "Testing Python sample project..."
    
    local python_sample="$SAMPLES_DIR/python"
    if [ ! -d "$python_sample" ]; then
        log_error "Python sample directory not found"
        return 1
    fi
    
    cd "$python_sample"
    
    # Check Python project files
    if [ -f "pyproject.toml" ]; then
        log_success "Python project configuration found"
    else
        log_error "Missing pyproject.toml"
        return 1
    fi
    
    if [ -d "src/sample_project" ]; then
        log_success "Source code directory found"
    else
        log_error "Missing source code"
        return 1
    fi
    
    if [ -d "tests" ]; then
        log_success "Tests directory found"
    else
        log_error "Missing tests directory"
        return 1
    fi
    
    # Copy template scripts to sample for testing
    cp -r "$TEMPLATE_DIR/scripts" .
    cp "$TEMPLATE_DIR/automation.config.yaml" .
    
    # Test language detection
    if command -v python3 >/dev/null 2>&1; then
        log_info "Testing language detection with doctor script..."
        if ./scripts/doctor.sh 2>&1 | grep -q "python"; then
            log_success "Language detection works (detected Python)"
        else
            log_warning "Language detection may not work properly"
        fi
    else
        log_warning "Python3 not available for testing"
    fi
    
    return 0
}

test_config_parsing() {
    log_info "Testing automation config parsing..."
    
    local config_file="$TEMPLATE_DIR/automation.config.yaml"
    
    # Basic YAML validation (if yq is available)
    if command -v python3 >/dev/null 2>&1; then
        python3 -c "
import yaml
try:
    with open('$config_file', 'r') as f:
        config = yaml.safe_load(f)
    
    # Check required sections
    required_sections = ['detect', 'tasks', 'coverage']
    for section in required_sections:
        if section not in config:
            print(f'Missing section: {section}')
            exit(1)
    
    # Check language support
    languages = ['python', 'java', 'node', 'go', 'flutter', 'rust', 'csharp']
    for lang in languages:
        if lang not in config['detect']:
            print(f'Missing language detection: {lang}')
            exit(1)
        if lang not in config['tasks']['lint']:
            print(f'Missing lint task for: {lang}')
            exit(1)
    
    print('✅ Configuration is valid')
except Exception as e:
    print(f'❌ Configuration error: {e}')
    exit(1)
"
        if [ $? -eq 0 ]; then
            log_success "Configuration is valid"
        else
            log_error "Configuration validation failed"
            return 1
        fi
    else
        log_warning "Cannot validate config - Python3 not available"
    fi
    
    return 0
}

test_cross_platform_scripts() {
    log_info "Testing cross-platform script pairs..."
    
    local script_pairs=(
        "bootstrap"
        "doctor"
        "lint"
        "test"
        "build"
    )
    
    for script in "${script_pairs[@]}"; do
        local sh_script="$TEMPLATE_DIR/scripts/$script.sh"
        local ps1_script="$TEMPLATE_DIR/scripts/$script.ps1"
        
        if [ -f "$sh_script" ] && [ -f "$ps1_script" ]; then
            log_success "Found script pair: $script (.sh/.ps1)"
            
            # Check that both scripts have help options
            if grep -q "help\|Help" "$sh_script" && grep -q "Help" "$ps1_script"; then
                log_success "$script scripts have help options"
            else
                log_warning "$script scripts may be missing help options"
            fi
        else
            log_error "Missing script pair: $script"
            return 1
        fi
    done
    
    return 0
}

run_all_tests() {
    log_info "Starting template validation tests..."
    echo ""
    
    local tests=(
        "test_template_structure"
        "test_config_parsing"
        "test_cross_platform_scripts"
        "test_python_sample"
    )
    
    local passed=0
    local total=${#tests[@]}
    
    for test in "${tests[@]}"; do
        echo ""
        if $test; then
            ((passed++))
        fi
    done
    
    echo ""
    echo "==============================="
    log_info "Test Results: $passed/$total tests passed"
    
    if [ $passed -eq $total ]; then
        log_success "All tests passed! Template is ready for use."
        echo ""
        log_info "💡 Next steps:"
        echo "   1. Copy template to your project: cp -r template/* your-project/"
        echo "   2. Run bootstrap: ./scripts/bootstrap.sh"
        echo "   3. Validate with doctor: ./scripts/doctor.sh"
        return 0
    else
        log_error "Some tests failed. Please review the issues above."
        return 1
    fi
}

# Handle help
if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    echo "Template Validation Test Script"
    echo ""
    echo "Usage: $0"
    echo ""
    echo "Tests:"
    echo "  ✓ Template file structure and permissions"
    echo "  ✓ Configuration file validity"
    echo "  ✓ Cross-platform script pairs"
    echo "  ✓ Sample project structure"
    echo "  ✓ Language detection functionality"
    exit 0
fi

# Run tests
run_all_tests