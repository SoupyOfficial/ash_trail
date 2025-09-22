# Customization Guide

This guide explains how to extend and customize the framework-agnostic development automation template for your specific needs.

## 🎯 Quick Customizations

### Change Coverage Thresholds
```yaml
# automation.config.yaml
coverage:
  global_threshold: 85    # Increase from default 80%
  patch_threshold: 90     # Increase from default 85%
```

### Add Custom File Patterns
```yaml
# automation.config.yaml
filesChanged:
  python:
    - "**/*.py"
    - "config/**/*.yaml"    # Add custom patterns
    - "docs/**/*.md"
```

### Override Default Commands
```yaml
# automation.config.yaml
tasks:
  test:
    python: "pytest -v --tb=short --maxfail=1"  # Custom pytest args
    java: "mvn test -Dtest.skip.integration=true"  # Skip integration tests
```

## 🔧 Adding New Languages

### Step 1: Add Language Detection
```yaml
# automation.config.yaml
detect:
  kotlin:  # New language
    - "build.gradle.kts"
    - "*.kts"
    - "src/**/*.kt"
```

### Step 2: Define Task Commands
```yaml
tasks:
  doctor:
    kotlin: "kotlinc -version && gradle --version"
  lint:
    kotlin: "ktlint --format && detekt"
  test:
    kotlin: "gradle test"
  build:
    kotlin: "gradle build"
```

### Step 3: Add CI Support
```yaml
# automation.config.yaml
ci:
  versions:
    kotlin: ["1.8", "1.9"]

filesChanged:
  kotlin:
    - "**/*.kt"
    - "**/*.kts"
    - "build.gradle.kts"
    - "gradle.properties"
```

### Step 4: Update Setup Action
```yaml
# .github/actions/setup-language/action.yml
- name: Setup Kotlin
  if: inputs.language == 'kotlin'
  uses: actions/setup-java@v4  # Kotlin runs on JVM
  with:
    distribution: "temurin"
    java-version: "17"

- name: Install Kotlin tools
  if: inputs.language == 'kotlin'
  shell: bash
  run: |
    # Install ktlint and detekt
    curl -sSLO https://github.com/pinterest/ktlint/releases/latest/download/ktlint
    chmod a+x ktlint
    sudo mv ktlint /usr/local/bin/
```

## 🏗️ Project Structure Customization

### Custom Directory Layout
```yaml
# automation.config.yaml
env:
  SOURCE_DIR: "src/main"      # Custom source directory
  TEST_DIR: "src/test"        # Custom test directory
  BUILD_DIR: "target"         # Custom build directory
  COVERAGE_DIR: "reports/coverage"  # Custom coverage location
```

### Multi-Module Projects
```yaml
# For projects with multiple modules/packages
tasks:
  test:
    java: |
      # Test all modules
      for module in module-a module-b module-c; do
        cd $module && mvn test && cd ..
      done
    
  build:
    python: |
      # Build multiple packages
      for package in packages/*; do
        cd $package && python -m build && cd ../..
      done
```

## 🎨 Customizing Scripts

### Extend Existing Scripts
```bash
# scripts/custom-lint.sh
#!/usr/bin/env bash
set -euo pipefail

# Source the main lint script
source "$(dirname "$0")/lint.sh"

# Add custom checks
echo "Running custom security lints..."
if command -v semgrep >/dev/null 2>&1; then
    semgrep --config=auto .
fi

echo "Checking documentation..."
if command -v vale >/dev/null 2>&1; then
    vale docs/
fi
```

### Add Custom Tasks
```yaml
# automation.config.yaml
tasks:
  # Add new task
  security-scan:
    python: "bandit -r src/ && safety check"
    java: "mvn org.owasp:dependency-check-maven:check"
    node: "npm audit && snyk test"
    go: "gosec ./... && govulncheck ./..."
    default: "echo 'No security scanning configured'"

  # Add performance testing
  perf-test:
    python: "pytest tests/performance/ --benchmark-only"
    java: "mvn test -Dtest=*PerformanceTest"
    node: "npm run test:performance"
    default: "echo 'No performance tests configured'"
```

### Create Script Wrappers
```bash
# scripts/dev.sh - Custom developer workflow
#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Starting development workflow..."

./scripts/doctor.sh || {
    echo "❌ Health check failed"
    exit 1
}

./scripts/lint.sh --fix || {
    echo "❌ Linting failed"
    exit 1
}

./scripts/test.sh --coverage || {
    echo "❌ Tests failed"
    exit 1
}

echo "✅ All checks passed! Ready to commit."
```

## 🔍 Advanced CI Customization

### Custom Matrix Builds
```yaml
# .github/workflows/custom.yml
jobs:
  test:
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        python-version: ["3.9", "3.10", "3.11", "3.12"]
        include:
          # Custom combinations
          - os: ubuntu-latest
            python-version: "3.11"
            extra-args: "--slow-tests"
        exclude:
          # Skip combinations that don't work
          - os: macos-latest
            python-version: "3.9"
```

### Environment-Specific Configs
```yaml
# automation.config.yaml
environments:
  development:
    coverage:
      global_threshold: 70  # Lower threshold for dev
    env:
      SKIP_SLOW_TESTS: "true"
  
  production:
    coverage:
      global_threshold: 85  # Higher threshold for prod
    env:
      ENABLE_SECURITY_SCAN: "true"
```

### Custom Job Dependencies
```yaml
# .github/workflows/custom.yml
jobs:
  lint:
    runs-on: ubuntu-latest
    # ... lint steps

  test:
    needs: lint  # Only run tests if linting passes
    runs-on: ubuntu-latest
    # ... test steps

  integration-test:
    needs: [lint, test]  # Run integration tests after unit tests
    runs-on: ubuntu-latest
    # ... integration test steps
```

## 📊 Monitoring and Observability

### Custom Health Checks
```bash
# scripts/health-check-custom.sh
#!/usr/bin/env bash

# Check database connectivity
if ! curl -f http://localhost:5432 >/dev/null 2>&1; then
    echo "❌ Database not accessible"
    exit 1
fi

# Check external services
if ! curl -f https://api.external-service.com/health >/dev/null 2>&1; then
    echo "⚠️ External service unavailable"
fi

# Check disk space
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt 90 ]; then
    echo "⚠️ Disk usage high: ${DISK_USAGE}%"
fi
```

### Performance Monitoring
```yaml
# automation.config.yaml
tasks:
  monitor:
    python: |
      python -c "
      import time
      import psutil
      print(f'CPU: {psutil.cpu_percent()}%')
      print(f'Memory: {psutil.virtual_memory().percent}%')
      print(f'Load: {psutil.getloadavg()}')
      "
    default: "top -n1 | head -5"
```

## 🔒 Security Customizations

### Custom Security Rules
```toml
# gitleaks.toml - Custom secret detection
[extend]
  # Use default rules
  useDefault = true

[[rules]]
  description = "Custom API Key"
  regex = '''CUSTOM_API_[A-Z0-9]{32}'''
  tags = ["key", "custom"]

[[allowlist]]
  description = "Test fixtures"
  files = ['''.*/test/.*''']
  regexes = ['''CUSTOM_API_.*''']
```

### Dependency Scanning
```yaml
# automation.config.yaml
tasks:
  security:
    python: |
      # Multiple security tools
      safety check
      pip-audit
      bandit -r src/
      semgrep --config=auto src/
    
    java: |
      # OWASP dependency check + SpotBugs
      mvn org.owasp:dependency-check-maven:check
      mvn com.github.spotbugs:spotbugs-maven-plugin:check
```

## 🎯 Language-Specific Customizations

### Python Projects
```yaml
# automation.config.yaml - Python optimizations
tasks:
  lint:
    python: |
      # Comprehensive Python linting
      ruff check .
      black --check .
      mypy src/
      isort --check-only .
      flake8 src/
  
  test:
    python: |
      # Enhanced Python testing
      pytest \
        --cov=src \
        --cov-report=lcov:coverage/lcov.info \
        --cov-report=html:coverage/html \
        --cov-fail-under=80 \
        --junit-xml=reports/pytest.xml \
        -v
```

### Java/Spring Projects
```yaml
tasks:
  build:
    java: |
      # Multi-profile Maven build
      mvn clean compile -P development
      mvn package -P production -DskipTests
      mvn spring-boot:build-info  # Add build info
  
  test:
    java: |
      # Separate unit and integration tests
      mvn test -Dtest=*Test
      mvn failsafe:integration-test -Dtest=*IT
      mvn jacoco:report
```

### Node.js Projects
```yaml
tasks:
  build:
    node: |
      # Production build with optimizations
      npm run build:production
      npm run analyze  # Bundle analysis
      npm run compress-assets
  
  test:
    node: |
      # Comprehensive Node.js testing
      npm run test:unit
      npm run test:integration
      npm run test:e2e
      npm run test:coverage
```

## 📋 VS Code Integration

### Custom Tasks
```json
// .vscode/tasks.json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Dev Workflow",
      "type": "shell",
      "command": "./scripts/dev.sh",
      "group": "build",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": false,
        "panel": "shared"
      },
      "problemMatcher": []
    },
    {
      "label": "Quick Test",
      "type": "shell",
      "command": "./scripts/test.sh",
      "args": ["--fast"],
      "group": "test",
      "presentation": {
        "echo": true,
        "reveal": "always"
      }
    }
  ]
}
```

### Debug Configurations
```json
// .vscode/launch.json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug Tests",
      "type": "python",
      "request": "launch",
      "module": "pytest",
      "args": ["tests/", "-v", "-s"],
      "console": "integratedTerminal",
      "justMyCode": false
    }
  ]
}
```

## 🚀 Deployment Customizations

### Multi-Stage Builds
```yaml
# automation.config.yaml
tasks:
  build-dev:
    python: "python -m build --outdir dist-dev"
    java: "mvn package -P development"
    node: "npm run build:dev"
  
  build-prod:
    python: |
      python -m build --outdir dist-prod
      twine check dist-prod/*
    java: "mvn package -P production -DskipTests"
    node: "npm run build:prod && npm run compress"
```

### Release Automation
```bash
# scripts/release.sh
#!/usr/bin/env bash
set -euo pipefail

VERSION=${1:-patch}

echo "🚀 Starting release process..."

# Run full test suite
./scripts/test.sh --all

# Update version
case "$(detect_language)" in
    python)
        bump2version $VERSION
        ;;
    node)
        npm version $VERSION
        ;;
    java)
        mvn versions:set -DnextSnapshot=false
        ;;
esac

# Build release artifacts
./scripts/build.sh --release

# Create git tag and push
git push --tags
echo "✅ Release complete!"
```

## 📈 Performance Optimization

### Caching Strategies
```yaml
# .github/workflows/automation.yml
- name: Cache Dependencies
  uses: actions/cache@v4
  with:
    path: |
      ~/.cache/pip      # Python
      ~/.cache/maven    # Java
      ~/.cache/go-build # Go
      node_modules      # Node.js
    key: ${{ runner.os }}-deps-${{ hashFiles('**/requirements.txt', '**/pom.xml', '**/package-lock.json', '**/go.sum') }}
    restore-keys: |
      ${{ runner.os }}-deps-
```

### Parallel Execution
```yaml
# automation.config.yaml
tasks:
  test:
    python: "pytest -n auto"  # Parallel pytest
    java: "mvn test -T 1C"    # Parallel Maven (1 thread per CPU core)
    node: "npm run test:parallel"
    go: "go test -parallel 8 ./..."
```

## 🎛️ Configuration Management

### Environment-Specific Settings
```bash
# scripts/load-config.sh
#!/usr/bin/env bash

ENVIRONMENT=${ENVIRONMENT:-development}
CONFIG_FILE="config/${ENVIRONMENT}.yaml"

if [ -f "$CONFIG_FILE" ]; then
    echo "Loading config from $CONFIG_FILE"
    export $(grep -v '^#' "$CONFIG_FILE" | xargs)
fi
```

### Secrets Management
```bash
# scripts/setup-secrets.sh
#!/usr/bin/env bash

# Development secrets (not committed)
if [ -f ".env.local" ]; then
    source .env.local
fi

# CI secrets (from environment)
if [ "$CI" = "true" ]; then
    export CODECOV_TOKEN="${CODECOV_TOKEN}"
    export NPM_TOKEN="${NPM_TOKEN}"
fi
```

## 🔄 Migration Helpers

### Gradual Migration
```bash
# scripts/migrate-gradual.sh - Migrate one component at a time
#!/usr/bin/env bash

COMPONENT=${1:-lint}

case "$COMPONENT" in
    lint)
        echo "Migrating linting..."
        ./scripts/lint.sh --dry-run
        ;;
    test)
        echo "Migrating testing..."
        ./scripts/test.sh --validate-only
        ;;
    ci)
        echo "Migrating CI..."
        # Run CI validation
        ;;
esac
```

### Legacy Support
```yaml
# automation.config.yaml - Support old and new patterns
tasks:
  test:
    python: |
      # Try new approach, fallback to legacy
      if [ -f "pyproject.toml" ]; then
        pytest --cov=src
      elif [ -f "setup.py" ]; then
        python -m pytest tests/
      else
        python -m unittest discover
      fi
```

## 📚 Documentation Integration

### Auto-Generated Docs
```yaml
# automation.config.yaml
tasks:
  docs:
    python: |
      sphinx-apidoc -o docs/api src/
      sphinx-build -b html docs/ docs/_build/html
    
    java: |
      mvn javadoc:javadoc
      mvn site
    
    node: |
      jsdoc -c jsdoc.conf.js
      npm run docs:build
```

### API Documentation
```bash
# scripts/docs-api.sh
#!/usr/bin/env bash

case "$(detect_language)" in
    python)
        pdoc --html --output-dir docs/api src/
        ;;
    java)
        mvn javadoc:aggregate
        ;;
    node)
        typedoc --out docs/api src/
        ;;
esac
```

This customization guide provides patterns for extending the template while maintaining its reliability and simplicity. Choose the customizations that fit your project's needs, and remember that boring, consistent automation is better than complex, fragile systems.
