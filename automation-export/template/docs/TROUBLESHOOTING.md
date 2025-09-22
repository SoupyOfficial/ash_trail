# Troubleshooting Guide

This guide helps resolve common issues when using the framework-agnostic development automation template.

## Quick Fixes

### 🔧 Common Commands
```bash
# Check system health
./scripts/doctor.sh        # Linux/macOS
.\scripts\doctor.ps1       # Windows

# Fix common issues
./scripts/lint.sh --fix    # Auto-fix code issues
./scripts/bootstrap.sh     # Get setup instructions
```

## Environment Setup Issues

### Python: `python not found`
**Symptoms**: Scripts fail with "python: command not found"

**Solutions**:
- **Linux/macOS**: `sudo apt install python3` or `brew install python3`
- **Windows**: Download from [python.org](https://python.org) or `winget install Python.Python.3`
- **All platforms**: Ensure `python3` and `pip` are in PATH

### Java: `mvn not found` or `gradle not found`
**Symptoms**: Java projects fail to build

**Solutions**:
- **Maven**: Download from [maven.apache.org](https://maven.apache.org/download.cgi)
- **Gradle**: Download from [gradle.org](https://gradle.org/install/)
- **SDKMAN** (Linux/macOS): `sdk install maven` or `sdk install gradle`
- **Windows**: Use Chocolatey `choco install maven gradle` or winget

### Node.js: `npm audit` failures
**Symptoms**: Security warnings in Node.js projects

**Solutions**:
```bash
npm audit fix              # Auto-fix vulnerabilities
npm audit --audit-level=critical  # Only critical issues
npm install --package-lock-only   # Update lock file
```

### Go: `golangci-lint not found`
**Symptoms**: Go linting fails

**Solutions**:
```bash
# Install golangci-lint
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

# Or use binary install
curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin
```

## Script Execution Issues

### PowerShell: `Execution Policy` errors
**Symptoms**: `.\scripts\*.ps1` fails with execution policy errors

**Solutions**:
```powershell
# Current user only (recommended)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# System-wide (admin required)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned

# Temporary bypass
PowerShell -ExecutionPolicy Bypass -File .\scripts\doctor.ps1
```

### Bash: `Permission denied`
**Symptoms**: `./scripts/*.sh` fails with permission errors

**Solutions**:
```bash
# Make scripts executable
chmod +x scripts/*.sh

# Or run with bash directly
bash scripts/doctor.sh
```

### Windows: `Path not found` errors
**Symptoms**: Scripts can't find tools or files

**Solutions**:
- Ensure tools are in system PATH
- Use full paths in automation.config.yaml
- Check for spaces in directory names
- Use PowerShell instead of Command Prompt

## CI/CD Issues

### GitHub Actions: `Action not found`
**Symptoms**: CI fails with "action 'X' not found"

**Solutions**:
- Actions are pinned to commit SHAs for security
- Update to latest versions if repository moved
- Check `.github/actions/setup-language/action.yml` exists

### Coverage: `No coverage data found`
**Symptoms**: Coverage reporting shows 0% or fails

**Solutions**:
```bash
# Check coverage file exists
ls -la coverage/

# Language-specific fixes
# Python
pip install coverage pytest-cov
pytest --cov=src --cov-report=lcov:coverage/lcov.info

# Node.js  
npm install nyc --save-dev
nyc npm test

# Java
# Maven: ensure jacoco plugin is configured
# Gradle: apply jacoco plugin
```

### CI: `Path filters not working`
**Symptoms**: CI runs on unrelated changes

**Solutions**:
1. Check file patterns in `automation.config.yaml`
2. Verify paths match your project structure
3. Use `.` instead of `./` in patterns
4. Test patterns with: `git ls-files | grep -E "pattern"`

## Language-Specific Issues

### Python: `Import errors` during tests
**Symptoms**: `ModuleNotFoundError` in tests

**Solutions**:
```bash
# Install in development mode
pip install -e .

# Or adjust PYTHONPATH
export PYTHONPATH="${PYTHONPATH}:src"

# Or use pytest with src layout
pytest --cov=src tests/
```

### Java: `OutOfMemoryError` during builds
**Symptoms**: Maven/Gradle builds fail with heap errors

**Solutions**:
```bash
# Maven
export MAVEN_OPTS="-Xmx2g -XX:MaxPermSize=512m"

# Gradle
export GRADLE_OPTS="-Xmx2g -XX:MaxMetaspaceSize=512m"

# Or in gradle.properties
org.gradle.jvmargs=-Xmx2g
```

### Node.js: `ENOSPC` errors
**Symptoms**: File watching fails on Linux

**Solutions**:
```bash
# Increase inotify limits
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Or use polling
npm run test -- --watchAll=false
```

### Go: `Module not found` errors
**Symptoms**: Go modules not resolving

**Solutions**:
```bash
# Update modules
go mod tidy
go mod download

# Clear module cache
go clean -modcache

# Check proxy settings
go env GOPROXY
```

## Tool Installation

### Ubuntu/Debian
```bash
# System update
sudo apt update

# Common tools
sudo apt install -y git curl python3 python3-pip nodejs npm openjdk-17-jdk

# Language-specific tools
pip3 install --user ruff black pytest coverage
npm install -g eslint prettier @typescript-eslint/parser
```

### macOS
```bash
# Using Homebrew
brew update

# Common tools  
brew install git curl python3 node openjdk@17 go rust

# Language-specific tools
pip3 install --user ruff black pytest coverage
npm install -g eslint prettier
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
```

### Windows
```powershell
# Using winget (Windows 10/11)
winget install Git.Git
winget install Python.Python.3  
winget install OpenJS.NodeJS
winget install Microsoft.OpenJDK.17
winget install GoLang.Go

# Using Chocolatey
choco install git python nodejs openjdk17 golang

# Language-specific tools
pip install ruff black pytest coverage
npm install -g eslint prettier
```

## Configuration Issues

### `automation.config.yaml` validation errors
**Symptoms**: Scripts complain about invalid configuration

**Solutions**:
1. Check YAML syntax with: `python -c "import yaml; yaml.safe_load(open('automation.config.yaml'))"`
2. Ensure proper indentation (spaces, not tabs)
3. Quote strings with special characters
4. Validate against schema if available

### Coverage thresholds too strict
**Symptoms**: Builds fail on coverage checks

**Solutions**:
```yaml
# In automation.config.yaml
coverage:
  global_threshold: 70    # Reduce from 80
  patch_threshold: 80     # Reduce from 85
```

### Missing file patterns
**Symptoms**: CI doesn't trigger on relevant changes

**Solutions**:
```yaml
# Add project-specific patterns
filesChanged:
  your-language:
    - "src/**"
    - "lib/**"  
    - "custom-config.yaml"
```

## Performance Issues

### Slow CI builds
**Symptoms**: CI takes longer than 10 minutes

**Solutions**:
1. Enable caching in CI workflows
2. Use language-specific optimizations:
   ```bash
   # Python: cache pip dependencies
   # Java: cache ~/.m2 or ~/.gradle
   # Node.js: cache node_modules
   # Go: cache module downloads
   ```
3. Run tests in parallel where possible
4. Skip slow tests in CI: `SKIP_SLOW_TESTS=true`

### Large coverage reports
**Symptoms**: Coverage processing is slow

**Solutions**:
1. Exclude vendor/node_modules directories
2. Use coverage sampling for large codebases
3. Generate HTML reports only when needed

## Security Issues

### `gitleaks` finds false positives
**Symptoms**: Security scanning blocks commits

**Solutions**:
1. Update `.gitleaksignore` file:
   ```
   # Example patterns
   test/fixtures/fake-secret.json
   docs/examples/*.md
   ```
2. Use more specific patterns in `gitleaks.toml`
3. Temporarily disable: `SKIP_SECURITY_SCAN=true`

### Dependency vulnerabilities
**Symptoms**: Security warnings in dependencies

**Solutions**:
```bash
# Python
pip-audit --fix

# Node.js
npm audit fix

# Java  
mvn dependency-check:check
# Review and update vulnerable dependencies

# Go
govulncheck ./...
go get -u vulnerable/package@fixed-version
```

## Getting Help

### Debug Mode
Enable verbose output in scripts:
```bash
# Bash scripts
DEBUG=1 ./scripts/doctor.sh

# PowerShell scripts
$DebugPreference = "Continue"
.\scripts\doctor.ps1
```

### Log Files
Check these locations for detailed error information:
- `automation.log` (if exists)
- CI build logs in GitHub Actions
- Tool-specific logs (e.g., `npm-debug.log`)

### Common Debug Commands
```bash
# Check tool versions
python --version && pip --version
node --version && npm --version  
java --version && mvn --version
go version

# Check project structure
find . -name "*.py" | head -5      # Python files
find . -name "*.js" | head -5      # JavaScript files  
find . -name "pom.xml" -o -name "build.gradle"  # Java build files

# Check environment variables
env | grep -E "(PATH|PYTHON|NODE|JAVA|GO)"
```

### Still Need Help?

1. **Run health check**: `./scripts/doctor.sh` provides specific guidance
2. **Check examples**: Look at sample projects in the template
3. **Review documentation**: 
   - `docs/README.md` - Usage guide
   - `docs/MIGRATION.md` - Migration from existing systems
   - `docs/CUSTOMIZATION.md` - Extending the template
4. **Search issues**: Common problems have known solutions
5. **Create minimal reproduction**: Isolate the specific problem

Remember: The automation is designed to be boring and reliable. If something seems overly complex, there's likely a simpler approach available.
