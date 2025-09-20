#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${GREEN}🔒 Security & Compliance Checks${NC}"
echo -e "${GREEN}===============================${NC}"

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

# Vulnerability scanning
run_vulnerability_scan() {
    local language="$1"
    log_info "Running vulnerability scan for $language..."
    
    case "$language" in
        python)
            if command -v safety >/dev/null 2>&1; then
                log_info "Running Safety scan..."
                if safety check; then
                    log_success "No known vulnerabilities found"
                else
                    log_warning "Vulnerabilities detected by Safety"
                    return 1
                fi
            elif command -v pip-audit >/dev/null 2>&1; then
                log_info "Running pip-audit scan..."
                if pip-audit; then
                    log_success "No known vulnerabilities found"
                else
                    log_warning "Vulnerabilities detected by pip-audit"
                    return 1
                fi
            else
                log_warning "No Python vulnerability scanner found (install: pip install safety pip-audit)"
            fi
            ;;
            
        java)
            if command -v mvn >/dev/null 2>&1; then
                log_info "Running OWASP dependency check with Maven..."
                if mvn dependency-check:check >/dev/null 2>&1; then
                    log_success "Maven dependency check passed"
                else
                    log_warning "Maven dependency check found issues"
                fi
            elif command -v gradle >/dev/null 2>&1; then
                log_info "Running OWASP dependency check with Gradle..."
                if gradle dependencyCheckAnalyze >/dev/null 2>&1; then
                    log_success "Gradle dependency check passed"
                else
                    log_warning "Gradle dependency check found issues"
                fi
            fi
            ;;
            
        node)
            log_info "Running npm audit..."
            if npm audit --audit-level=moderate >/dev/null 2>&1; then
                log_success "No moderate or high vulnerabilities found"
            else
                log_warning "npm audit found vulnerabilities"
                return 1
            fi
            ;;
            
        go)
            if command -v govulncheck >/dev/null 2>&1; then
                log_info "Running govulncheck..."
                if govulncheck ./...; then
                    log_success "No vulnerabilities found in Go dependencies"
                else
                    log_warning "Vulnerabilities found in Go dependencies"
                    return 1
                fi
            else
                log_warning "govulncheck not found (install: go install golang.org/x/vuln/cmd/govulncheck@latest)"
            fi
            ;;
            
        rust)
            if command -v cargo-audit >/dev/null 2>&1; then
                log_info "Running cargo audit..."
                if cargo audit; then
                    log_success "No vulnerabilities found in Rust dependencies"
                else
                    log_warning "Vulnerabilities found in Rust dependencies"
                    return 1
                fi
            else
                log_warning "cargo-audit not found (install: cargo install cargo-audit)"
            fi
            ;;
            
        csharp)
            log_info "Running .NET vulnerability scan..."
            if dotnet list package --vulnerable >/dev/null 2>&1; then
                log_success "No vulnerable packages found"
            else
                log_warning "Vulnerable packages detected"
                return 1
            fi
            ;;
            
        flutter)
            if [ -f "pubspec.yaml" ]; then
                log_info "Checking Flutter dependencies..."
                # Flutter doesn't have built-in vulnerability scanning yet
                log_warning "Flutter vulnerability scanning not available - manual review recommended"
            fi
            ;;
            
        unknown)
            log_warning "Unknown project type - no vulnerability scanning available"
            ;;
    esac
    
    return 0
}

# License compliance check
run_license_check() {
    local language="$1"
    log_info "Running license compliance check for $language..."
    
    case "$language" in
        python)
            if command -v pip-licenses >/dev/null 2>&1; then
                log_info "Generating Python license report..."
                pip-licenses --format=json --output-file=licenses.json >/dev/null 2>&1 || true
                log_success "Python license report generated: licenses.json"
            else
                log_warning "pip-licenses not found (install: pip install pip-licenses)"
            fi
            ;;
            
        java)
            if command -v mvn >/dev/null 2>&1; then
                log_info "Generating Maven license report..."
                mvn license:aggregate-third-party-report >/dev/null 2>&1 || true
                log_success "Maven license report generated"
            elif command -v gradle >/dev/null 2>&1; then
                log_info "Generating Gradle license report..."
                gradle generateLicenseReport >/dev/null 2>&1 || true
                log_success "Gradle license report generated"
            fi
            ;;
            
        node)
            if command -v license-checker >/dev/null 2>&1; then
                log_info "Checking Node.js licenses..."
                if license-checker --onlyAllow 'MIT;Apache-2.0;BSD-3-Clause;ISC;BSD-2-Clause' >/dev/null 2>&1; then
                    log_success "All licenses are approved"
                else
                    log_warning "Some licenses may need review"
                fi
            else
                log_warning "license-checker not found (install: npm install -g license-checker)"
            fi
            ;;
            
        go)
            if command -v go-licenses >/dev/null 2>&1; then
                log_info "Generating Go license report..."
                go-licenses csv ./... > licenses.csv 2>/dev/null || true
                log_success "Go license report generated: licenses.csv"
            else
                log_warning "go-licenses not found (install: go install github.com/google/go-licenses@latest)"
            fi
            ;;
            
        rust)
            if command -v cargo-license >/dev/null 2>&1; then
                log_info "Generating Rust license report..."
                cargo-license --json > licenses.json 2>/dev/null || true
                log_success "Rust license report generated: licenses.json"
            else
                log_warning "cargo-license not found (install: cargo install cargo-license)"
            fi
            ;;
            
        csharp)
            log_info "Generating .NET package list..."
            dotnet list package --include-transitive > packages.txt 2>/dev/null || true
            log_success ".NET package list generated: packages.txt"
            ;;
    esac
}

# Generate Software Bill of Materials (SBOM)
generate_sbom() {
    local language="$1"
    log_info "Generating Software Bill of Materials (SBOM)..."
    
    # Ensure build directory exists
    mkdir -p build
    
    case "$language" in
        python)
            log_info "Creating Python SBOM..."
            if command -v cyclone-dx >/dev/null 2>&1; then
                cyclone-x py -o build/sbom.json >/dev/null 2>&1 || true
                log_success "SBOM generated: build/sbom.json"
            else
                # Simple fallback SBOM
                cat > build/sbom.json << EOF
{
  "bomFormat": "CycloneDX",
  "specVersion": "1.4",
  "serialNumber": "urn:uuid:$(uuidgen 2>/dev/null || date +%s)",
  "version": 1,
  "metadata": {
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)",
    "tools": [{"name": "automation-template", "version": "1.0.0"}]
  },
  "components": []
}
EOF
                log_warning "Basic SBOM generated (install cyclone-dx for full SBOM)"
            fi
            ;;
            
        node)
            if command -v cyclone-dx >/dev/null 2>&1; then
                log_info "Creating Node.js SBOM..."
                cyclone-dx npm -o build/sbom.json >/dev/null 2>&1 || true
                log_success "SBOM generated: build/sbom.json"
            else
                log_warning "cyclone-dx not found for Node.js SBOM generation"
            fi
            ;;
            
        *)
            log_info "Creating basic SBOM for $language..."
            cat > build/sbom.json << EOF
{
  "bomFormat": "CycloneDX",
  "specVersion": "1.4",
  "serialNumber": "urn:uuid:$(uuidgen 2>/dev/null || date +%s)",
  "version": 1,
  "metadata": {
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)",
    "tools": [{"name": "automation-template", "version": "1.0.0"}],
    "component": {
      "type": "application",
      "name": "$(basename "$PWD")",
      "version": "1.0.0"
    }
  },
  "components": []
}
EOF
            log_success "Basic SBOM generated: build/sbom.json"
            ;;
    esac
}

# Check secrets in repository
check_secrets() {
    log_info "Checking for secrets in repository..."
    
    # List of common secret patterns
    local secret_patterns=(
        "password\s*=\s*['\"][^'\"]+['\"]"
        "api[_-]?key\s*=\s*['\"][^'\"]+['\"]"
        "secret\s*=\s*['\"][^'\"]+['\"]"
        "token\s*=\s*['\"][^'\"]+['\"]"
        "private[_-]?key"
        "AKIA[0-9A-Z]{16}"  # AWS Access Key
        "-----BEGIN.*PRIVATE KEY-----"
    )
    
    local secrets_found=false
    
    for pattern in "${secret_patterns[@]}"; do
        if git ls-files | xargs grep -l -i -E "$pattern" 2>/dev/null | head -5; then
            secrets_found=true
        fi
    done
    
    if [ "$secrets_found" = true ]; then
        log_warning "Potential secrets found in repository - please review"
        log_info "💡 Use .env files and .gitignore for sensitive data"
        return 1
    else
        log_success "No obvious secrets detected in tracked files"
    fi
    
    return 0
}

# Main execution
main() {
    local language
    local check_vulns=true
    local check_licenses=true
    local generate_sbom_flag=true
    local check_secrets_flag=true
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --no-vulns)
                check_vulns=false
                shift
                ;;
            --no-licenses)
                check_licenses=false
                shift
                ;;
            --no-sbom)
                generate_sbom_flag=false
                shift
                ;;
            --no-secrets)
                check_secrets_flag=false
                shift
                ;;
            --help|-h)
                echo "Security & Compliance Checks Script"
                echo ""
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --no-vulns      Skip vulnerability scanning"
                echo "  --no-licenses   Skip license compliance check"
                echo "  --no-sbom       Skip SBOM generation"
                echo "  --no-secrets    Skip secrets detection"
                echo "  -h, --help      Show this help message"
                echo ""
                echo "This script will:"
                echo "  ✓ Scan for known vulnerabilities"
                echo "  ✓ Check license compliance"
                echo "  ✓ Generate Software Bill of Materials (SBOM)"
                echo "  ✓ Detect potential secrets in code"
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
    
    echo ""
    
    local overall_status=0
    
    # Run vulnerability scan
    if [ "$check_vulns" = true ]; then
        if ! run_vulnerability_scan "$language"; then
            overall_status=1
        fi
        echo ""
    fi
    
    # Run license check
    if [ "$check_licenses" = true ]; then
        run_license_check "$language"
        echo ""
    fi
    
    # Generate SBOM
    if [ "$generate_sbom_flag" = true ]; then
        generate_sbom "$language"
        echo ""
    fi
    
    # Check for secrets
    if [ "$check_secrets_flag" = true ]; then
        if ! check_secrets; then
            overall_status=1
        fi
        echo ""
    fi
    
    # Summary
    if [ $overall_status -eq 0 ]; then
        log_success "All security and compliance checks passed!"
        echo ""
        log_info "💡 Generated files:"
        echo "   - licenses.json/csv - License compliance report"
        echo "   - build/sbom.json - Software Bill of Materials"
        echo "   - packages.txt - Dependency list (if applicable)"
    else
        log_warning "Some security or compliance issues found!"
        log_info "💡 Review the warnings above and take appropriate action"
    fi
    
    return $overall_status
}

main "$@"