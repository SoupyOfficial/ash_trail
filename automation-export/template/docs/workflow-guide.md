# Development Workflow Guide

This guide covers the complete feature development workflow using the dev assistant tools extracted from the AshTrail project.

## Table of Contents

- [Quick Start](#quick-start)
- [Dev Assistant Overview](#dev-assistant-overview)
- [Feature Development Workflow](#feature-development-workflow)
- [Coverage Analysis](#coverage-analysis)
- [Command Reference](#command-reference)
- [Language-Specific Notes](#language-specific-notes)
- [Troubleshooting](#troubleshooting)

## Quick Start

1. **Initialize your project**:
   ```bash
   # Copy template files to your project
   cp automation.config.yaml your-project/
   cp feature_matrix.yaml your-project/
   cp scripts/dev_assistant.py your-project/scripts/
   cp scripts/analyze_coverage.py your-project/scripts/
   ```

2. **Configure your feature matrix**:
   ```bash
   # Edit feature_matrix.yaml to define your features
   vim feature_matrix.yaml
   ```

3. **Check project health**:
   ```bash
   python scripts/dev_assistant.py health
   ```

4. **Start developing features**:
   ```bash
   python scripts/dev_assistant.py start-next-feature
   ```

## Dev Assistant Overview

The dev assistant provides automated workflow management for feature-driven development. It integrates with your feature matrix, Git workflow, and testing infrastructure to provide:

- **Feature Management**: Track feature status, dependencies, and progress
- **Automated Workflows**: Start and finalize features with validation
- **Coverage Analysis**: Multi-format coverage reporting and trending
- **Health Monitoring**: Environment and dependency validation
- **Quality Gates**: Automated testing, linting, and coverage enforcement

### Key Components

1. **`dev_assistant.py`** - Main automation coordinator
2. **`analyze_coverage.py`** - Advanced coverage analysis
3. **`feature_matrix.yaml`** - Feature definitions and roadmap
4. **`automation.config.yaml`** - Project configuration

## Feature Development Workflow

### 1. Planning Phase

Features are defined in `feature_matrix.yaml` with:

```yaml
features:
  user_authentication:
    name: "User Authentication"
    epic: "core"
    status: "planned"
    priority: 1
    dependencies: []
    acceptance_criteria:
      - "Users can register with email and password"
      - "Users can login and logout"
    test_coverage:
      target: 90
```

### 2. Starting Development

Use the dev assistant to automatically start the next feature:

```bash
# Start the highest-priority planned feature
python scripts/dev_assistant.py start-next-feature

# Start a specific feature
python scripts/dev_assistant.py start-next-feature --feature user_authentication
```

This command:
- Creates a feature branch (`feature/user-authentication`)
- Updates feature status to "in_progress"
- Creates initial file structure based on language templates
- Commits the scaffold with a proper commit message

### 3. Development Process

During development, use these commands for continuous validation:

```bash
# Check overall project status
python scripts/dev_assistant.py status

# Run development cycle (lint, test, coverage)
python scripts/dev_assistant.py dev-cycle

# Analyze test coverage
python scripts/dev_assistant.py coverage --html

# Health check environment
python scripts/dev_assistant.py health
```

### 4. Finalizing Features

When development is complete:

```bash
# Validate and finalize current feature
python scripts/dev_assistant.py finalize-feature
```

This command:
- Runs all quality gates (tests, coverage, linting)
- Validates acceptance criteria completion
- Updates feature status to "done"
- Optionally merges and cleans up branches

## Coverage Analysis

The coverage analysis system supports multiple formats and provides comprehensive reporting:

### Supported Formats

- **LCOV** (`lcov.info`) - Used by Jest, pytest-cov, Flutter
- **JSON** (NYC/Istanbul format) - Node.js projects
- **XML** (JaCoCo, Cobertura) - Java/C# projects
- **Go** (`coverage.out`) - Go projects
- **Rust** (Tarpaulin) - Rust projects

### Usage Examples

```bash
# Basic coverage analysis
python scripts/analyze_coverage.py

# Generate HTML report
python scripts/analyze_coverage.py --html

# Check against thresholds (CI mode)
python scripts/analyze_coverage.py --ci --threshold 80

# Analyze trends over time
python scripts/analyze_coverage.py --trends --save-history

# Output JSON for tooling integration
python scripts/analyze_coverage.py --json-output
```

### Coverage Thresholds

Configure thresholds in `automation.config.yaml`:

```yaml
coverage:
  global_threshold: 80    # Overall project coverage
  patch_threshold: 85     # Coverage for changed lines
```

## Command Reference

### Dev Assistant Commands

#### `status`
Shows project overview including:
- Current feature status
- Git branch information
- Recent commits
- Coverage summary

```bash
python scripts/dev_assistant.py status [--json]
```

#### `health`
Comprehensive environment check:
- Language runtime versions
- Dependency availability
- Git repository status
- Coverage tool availability

```bash
python scripts/dev_assistant.py health
```

#### `coverage`
Multi-format coverage analysis:
- Auto-detects coverage files
- Generates reports and trends
- Validates thresholds

```bash
python scripts/dev_assistant.py coverage [--html] [--trends]
```

#### `start-next-feature`
Automated feature development startup:
- Selects next planned feature by priority
- Creates feature branch
- Scaffolds initial files
- Updates feature status

```bash
python scripts/dev_assistant.py start-next-feature [--feature NAME] [--auto-commit]
```

#### `finalize-feature`
Feature completion validation:
- Runs all quality gates
- Validates coverage thresholds
- Updates feature status
- Optionally merges branches

```bash
python scripts/dev_assistant.py finalize-feature [--auto-merge]
```

#### `dev-cycle`
Complete development cycle:
- Code formatting and linting
- Test execution with coverage
- Security scanning
- Build validation

```bash
python scripts/dev_assistant.py dev-cycle [--upload] [--skip-tests]
```

#### `features`
Feature management:
- List all features by status
- Filter by epic, priority, or status
- Show feature dependencies

```bash
python scripts/dev_assistant.py features [--limit N] [--status planned]
```

### Coverage Analysis Commands

#### Basic Analysis
```bash
python scripts/analyze_coverage.py
```

#### Format-Specific Analysis
```bash
python scripts/analyze_coverage.py --format lcov --file coverage/lcov.info
```

#### HTML Report Generation
```bash
python scripts/analyze_coverage.py --html
```

#### CI Integration
```bash
python scripts/analyze_coverage.py --ci --threshold 80 --patch-threshold 85
```

#### Trend Analysis
```bash
python scripts/analyze_coverage.py --trends --save-history
```

## Language-Specific Notes

### Python Projects

**Setup**:
```bash
pip install pytest pytest-cov black ruff safety pip-audit
```

**Coverage**: Uses LCOV format via pytest-cov:
```bash
pytest --cov=src --cov-report=lcov:coverage/lcov.info
```

**File Structure**:
```
src/features/user_auth/
├── __init__.py
├── models.py
├── views.py
└── serializers.py
tests/test_user_auth.py
```

### JavaScript/TypeScript Projects

**Setup**:
```bash
npm install --save-dev jest @testing-library/react eslint prettier
```

**Coverage**: Uses NYC/Istanbul format:
```bash
npm run test:coverage  # outputs coverage/coverage-final.json
```

**File Structure**:
```
src/features/user-auth/
├── index.ts
├── components/
├── hooks/
└── __tests__/
```

### Java Projects

**Setup**:
```xml
<!-- Maven: pom.xml -->
<plugin>
  <groupId>org.jacoco</groupId>
  <artifactId>jacoco-maven-plugin</artifactId>
</plugin>
```

**Coverage**: Uses JaCoCo XML format:
```bash
mvn test jacoco:report  # outputs target/site/jacoco/jacoco.xml
```

### Go Projects

**Coverage**: Uses native Go coverage:
```bash
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out -o coverage.html
```

### Rust Projects

**Setup**:
```bash
cargo install cargo-tarpaulin
```

**Coverage**: Uses Tarpaulin:
```bash
cargo tarpaulin --out lcov --output-dir coverage
```

## VS Code Integration

The template includes VS Code tasks for common operations:

### Tasks (`tasks.json`)
```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Dev Assistant: Status",
      "type": "shell",
      "command": "python",
      "args": ["scripts/dev_assistant.py", "status"],
      "group": "build"
    },
    {
      "label": "Dev Assistant: Start Next Feature",
      "type": "shell", 
      "command": "python",
      "args": ["scripts/dev_assistant.py", "start-next-feature"],
      "group": "build"
    }
  ]
}
```

### Keyboard Shortcuts
- **Ctrl+Shift+P** → "Tasks: Run Task" → "Dev Assistant: Status"
- **F5** → Custom task binding for feature development

## Troubleshooting

### Common Issues

#### 1. "No coverage files found"
```bash
# Check coverage file locations
python scripts/analyze_coverage.py --format auto
ls coverage/

# Run tests with coverage first
npm run test:coverage  # Node.js
pytest --cov=src       # Python
go test -coverprofile=coverage.out ./...  # Go
```

#### 2. "Feature matrix not found"
```bash
# Ensure feature_matrix.yaml exists in project root
ls feature_matrix.yaml

# Check configuration
python scripts/dev_assistant.py status
```

#### 3. "Git repository not found"
```bash
# Initialize Git repository
git init
git remote add origin <your-repo-url>
```

#### 4. "Language detection failed"
```bash
# Check for language indicator files
ls package.json pyproject.toml go.mod Cargo.toml

# Override language detection
export PROJECT_LANGUAGE=python
python scripts/dev_assistant.py health
```

### Debug Mode

Enable debug logging:
```bash
export DEBUG=1
python scripts/dev_assistant.py status
```

### Coverage Debug

Analyze coverage files manually:
```bash
# Python
python -m coverage report

# Node.js
npx nyc report

# Go
go tool cover -func=coverage.out

# Java
mvn jacoco:report
```

## Advanced Usage

### Custom Feature Templates

Create language-specific templates in `automation.config.yaml`:

```yaml
templates:
  python:
    feature_structure:
      - "src/{feature_name}/"
      - "src/{feature_name}/__init__.py"
      - "tests/test_{feature_name}.py"
```

### CI Integration

Example GitHub Actions workflow:
```yaml
name: Dev Cycle
on: [push, pull_request]

jobs:
  dev-cycle:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.10'
      - name: Run dev cycle
        run: python scripts/dev_assistant.py dev-cycle --upload
      - name: Coverage analysis
        run: python scripts/analyze_coverage.py --ci --html
```

### Custom Quality Gates

Add custom validation in `finalize-feature` command:

```python
def custom_quality_gate():
    """Add your custom validation logic here"""
    # Example: API documentation check
    # Example: Performance benchmark validation
    # Example: Security scan results
    pass
```

This workflow system provides a comprehensive, language-agnostic approach to feature-driven development with strong emphasis on quality, coverage, and automation.
