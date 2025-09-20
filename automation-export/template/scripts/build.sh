#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${GREEN}🏗️  Building Project${NC}"
echo -e "${GREEN}==================${NC}"

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

# Run language-specific build
run_build() {
    local language="$1"
    local release_mode="$2"
    local clean_first="$3"
    
    log_info "Building $language project (release: $release_mode, clean: $clean_first)..."
    
    # Ensure build directory exists
    mkdir -p build
    
    case "$language" in
        python)
            if [ "$clean_first" = "true" ]; then
                log_info "Cleaning Python build artifacts..."
                rm -rf build/ dist/ *.egg-info/ __pycache__/ .pytest_cache/ || true
                find . -type f -name "*.pyc" -delete || true
                find . -type d -name "__pycache__" -exec rm -rf {} + || true
            fi
            
            log_info "Building Python package..."
            if [ -f "pyproject.toml" ]; then
                if command -v python3 >/dev/null 2>&1; then
                    python3 -m build
                else
                    python -m build
                fi
            elif [ -f "setup.py" ]; then
                if command -v python3 >/dev/null 2>&1; then
                    python3 setup.py sdist bdist_wheel
                else
                    python setup.py sdist bdist_wheel
                fi
            else
                log_warning "No build configuration found (pyproject.toml or setup.py)"
                log_info "Creating basic package structure..."
                if command -v python3 >/dev/null 2>&1; then
                    python3 -c "import py_compile; import glob; [py_compile.compile(f, doraise=True) for f in glob.glob('**/*.py', recursive=True)]"
                else
                    python -c "import py_compile; import glob; [py_compile.compile(f, doraise=True) for f in glob.glob('**/*.py', recursive=True)]"
                fi
            fi
            ;;
            
        java)
            if command -v mvn >/dev/null 2>&1; then
                log_info "Building Java project with Maven..."
                local mvn_args=()
                
                if [ "$clean_first" = "true" ]; then
                    mvn_args+=("clean")
                fi
                
                if [ "$release_mode" = "true" ]; then
                    mvn_args+=("package" "-Dmaven.test.skip=true")
                else
                    mvn_args+=("compile")
                fi
                
                mvn "${mvn_args[@]}"
                
            elif command -v gradle >/dev/null 2>&1; then
                log_info "Building Java project with Gradle..."
                local gradle_args=()
                
                if [ "$clean_first" = "true" ]; then
                    gradle_args+=("clean")
                fi
                
                if [ "$release_mode" = "true" ]; then
                    gradle_args+=("build" "-x" "test")
                else
                    gradle_args+=("compileJava")
                fi
                
                gradle "${gradle_args[@]}"
            else
                log_error "Neither Maven nor Gradle found"
                return 1
            fi
            ;;
            
        node)
            if [ "$clean_first" = "true" ]; then
                log_info "Cleaning Node.js build artifacts..."
                rm -rf node_modules/.cache build/ dist/ || true
            fi
            
            log_info "Installing Node.js dependencies..."
            npm ci --prefer-offline || npm install
            
            if [ -f "package.json" ] && grep -q '"build"' package.json; then
                log_info "Running Node.js build script..."
                if [ "$release_mode" = "true" ]; then
                    if grep -q '"build:prod"' package.json; then
                        npm run build:prod
                    else
                        NODE_ENV=production npm run build
                    fi
                else
                    npm run build
                fi
            else
                log_warning "No build script found in package.json"
            fi
            ;;
            
        go)
            if [ "$clean_first" = "true" ]; then
                log_info "Cleaning Go build artifacts..."
                go clean -cache -modcache -testcache || true
                rm -rf build/ || true
            fi
            
            log_info "Building Go project..."
            local go_args=("build")
            
            if [ "$release_mode" = "true" ]; then
                go_args+=("-ldflags" "-s -w")  # Strip debug info
            fi
            
            # Build to build directory
            go_args+=("-o" "build/")
            go_args+=("./...")
            
            go "${go_args[@]}"
            ;;
            
        flutter)
            if [ "$clean_first" = "true" ]; then
                log_info "Cleaning Flutter build artifacts..."
                flutter clean
            fi
            
            log_info "Getting Flutter dependencies..."
            flutter pub get
            
            # Run code generation if needed
            if grep -q "build_runner" pubspec.yaml; then
                log_info "Running code generation..."
                flutter packages pub run build_runner build --delete-conflicting-outputs
            fi
            
            log_info "Building Flutter app..."
            if [ "$release_mode" = "true" ]; then
                flutter build apk --release
            else
                flutter build apk --debug
            fi
            ;;
            
        rust)
            if [ "$clean_first" = "true" ]; then
                log_info "Cleaning Rust build artifacts..."
                cargo clean
            fi
            
            log_info "Building Rust project..."
            local cargo_args=("build")
            
            if [ "$release_mode" = "true" ]; then
                cargo_args+=("--release")
            fi
            
            cargo "${cargo_args[@]}"
            ;;
            
        csharp)
            if [ "$clean_first" = "true" ]; then
                log_info "Cleaning .NET build artifacts..."
                dotnet clean
            fi
            
            log_info "Restoring .NET dependencies..."
            dotnet restore
            
            log_info "Building .NET project..."
            local dotnet_args=("build")
            
            if [ "$release_mode" = "true" ]; then
                dotnet_args+=("--configuration" "Release")
            fi
            
            dotnet "${dotnet_args[@]}"
            ;;
            
        unknown)
            log_error "Unknown project type - cannot build"
            return 1
            ;;
    esac
    
    return 0
}

# Check build outputs
check_build_outputs() {
    local language="$1"
    
    log_info "Checking build outputs..."
    
    case "$language" in
        python)
            if [ -d "dist" ]; then
                local wheel_count=$(ls dist/*.whl 2>/dev/null | wc -l)
                local tar_count=$(ls dist/*.tar.gz 2>/dev/null | wc -l)
                log_success "Python package built: $wheel_count wheel(s), $tar_count source archive(s)"
            fi
            ;;
            
        java)
            if [ -f "target/"*.jar ] 2>/dev/null; then
                log_success "Maven JAR built: $(ls target/*.jar)"
            elif [ -f "build/libs/"*.jar ] 2>/dev/null; then
                log_success "Gradle JAR built: $(ls build/libs/*.jar)"
            fi
            ;;
            
        node)
            if [ -d "build" ] || [ -d "dist" ]; then
                log_success "Node.js build outputs created"
            fi
            ;;
            
        go)
            if [ -d "build" ]; then
                local binary_count=$(ls build/* 2>/dev/null | wc -l)
                log_success "Go binaries built: $binary_count executable(s)"
            fi
            ;;
            
        flutter)
            if [ -f "build/app/outputs/flutter-apk/app-debug.apk" ] || [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
                log_success "Flutter APK built"
            fi
            ;;
            
        rust)
            if [ -f "target/debug/"* ] || [ -f "target/release/"* ]; then
                log_success "Rust binary built"
            fi
            ;;
            
        csharp)
            if find . -path "*/bin/*" -name "*.dll" -o -name "*.exe" | grep -q .; then
                log_success ".NET assemblies built"
            fi
            ;;
    esac
}

# Main execution
main() {
    local language
    local release_mode=false
    local clean_first=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --release)
                release_mode=true
                shift
                ;;
            --clean)
                clean_first=true
                shift
                ;;
            --help|-h)
                echo "Build Script"
                echo ""
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --release    Build in release/production mode"
                echo "  --clean      Clean build artifacts before building"
                echo "  -h, --help   Show this help message"
                echo ""
                echo "This script will:"
                echo "  ✓ Detect project language automatically"
                echo "  ✓ Run language-specific build process"
                echo "  ✓ Generate optimized builds (if --release specified)"
                echo "  ✓ Verify build outputs"
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
    
    if [ "$release_mode" = "true" ]; then
        log_info "Building in RELEASE mode"
    else
        log_info "Building in DEBUG mode"
    fi
    
    if [ "$clean_first" = "true" ]; then
        log_info "Will clean before building"
    fi
    
    echo ""
    
    # Run build
    local build_status=0
    if ! run_build "$language" "$release_mode" "$clean_first"; then
        build_status=1
    fi
    
    # Check outputs if build succeeded
    if [ $build_status -eq 0 ]; then
        echo ""
        check_build_outputs "$language"
    fi
    
    echo ""
    
    # Summary
    if [ $build_status -eq 0 ]; then
        log_success "Build completed successfully!"
        echo ""
        log_info "💡 Next steps:"
        echo "   1. Test your build artifacts"
        echo "   2. Deploy or distribute your application"
        if [ "$release_mode" != "true" ]; then
            echo "   3. Consider building with --release for production"
        fi
    else
        log_error "Build failed!"
        log_info "💡 Tips:"
        echo "   1. Check build output above for specific errors"
        echo "   2. Ensure all dependencies are installed"
        echo "   3. Run './scripts/doctor.sh' to check environment"
        echo "   4. Try building with --clean to start fresh"
    fi
    
    return $build_status
}

main "$@"