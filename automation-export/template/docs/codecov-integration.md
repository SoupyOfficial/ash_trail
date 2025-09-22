# Codecov Integration Guide

This guide covers the complete setup and usage of Codecov integration in your development project using the dev assistant template.

## Overview

Codecov provides code coverage reporting and visualization for your projects. This template includes comprehensive Codecov integration with:

- **Automated uploads** via dev assistant command
- **Multi-language support** (Python, Java, Node.js, Go, Rust, C#, Flutter)
- **CI/CD integration** with GitHub Actions
- **Coverage thresholds** and quality gates
- **Pull request comments** with coverage reports

## Quick Setup

### Automated Setup (Recommended)

```bash
# Interactive setup with guided prompts
python scripts/setup_codecov.py --interactive

# Direct setup if you know your repository
python scripts/setup_codecov.py --repo owner/repo

# Dry run to see what would be done
python scripts/setup_codecov.py --repo owner/repo --dry-run
```

### Manual Setup

1. **Sign up for Codecov**
   - Go to [codecov.io](https://codecov.io)
   - Sign in with GitHub
   - Add your repository

2. **Get your upload token**
   - Navigate to your repository settings in Codecov
   - Copy the "Repository Upload Token"

3. **Configure environment**
   ```bash
   # Add to .env file
   CODECOV_TOKEN=your_token_here
   
   # Or set as environment variable
   export CODECOV_TOKEN=your_token_here
   ```

4. **Set up GitHub secret**
   ```bash
   # Using GitHub CLI
   gh secret set CODECOV_TOKEN --repo owner/repo
   
   # Or manually in GitHub:
   # Go to Settings > Secrets and variables > Actions
   # Add new secret named CODECOV_TOKEN
   ```

## Usage

### Dev Assistant Commands

```bash
# Upload coverage after running tests
python scripts/dev_assistant.py upload-coverage

# Upload with specific flags
python scripts/dev_assistant.py upload-coverage --flags unit integration

# Upload with custom token
python scripts/dev_assistant.py upload-coverage --token YOUR_TOKEN

# Dry run to see what would be uploaded
python scripts/dev_assistant.py upload-coverage --dry-run
```

### Manual Upload

```bash
# Using Codecov CLI directly
codecov -t $CODECOV_TOKEN -f coverage/lcov.info

# With flags
codecov -t $CODECOV_TOKEN -f coverage/lcov.info -F unittests -F python
```

### CI/CD Integration

The GitHub Actions workflow automatically:

1. **Runs tests with coverage** across multiple OS and language versions
2. **Uploads coverage data** to Codecov with appropriate flags
3. **Comments on pull requests** with coverage reports
4. **Validates coverage thresholds** (80% global, 85% patch by default)

## Configuration

### codecov.yml

The template includes a comprehensive `codecov.yml` configuration:

```yaml
# Coverage requirements
coverage:
  status:
    project:
      default:
        target: 80%          # Global coverage target
        threshold: 2%        # Allow 2% drop
    patch:
      default:
        target: 85%          # New code coverage target
        
# Language-specific flags
flags:
  python:
    paths: ["src/", "lib/", "app/"]
  javascript:
    paths: ["src/", "lib/", "app/"]
  # ... more languages
```

### automation.config.yaml

Codecov settings in the automation configuration:

```yaml
codecov:
  upload:
    fail_on_error: true
    auto_retry: true
    retry_count: 3
    timeout: 120
    
  flags:
    python: ["python", "unit"]
    java: ["java", "unit"]
    # ... more languages
    
  coverage_files:
    python: ["coverage/lcov.info", ".coverage", "coverage.xml"]
    # ... more languages
```

## Multi-Language Support

### Python
```bash
# Generate coverage
pytest --cov=. --cov-report=lcov:coverage/lcov.info

# Upload
python scripts/dev_assistant.py upload-coverage --flags python unit
```

### JavaScript/Node.js
```bash
# Generate coverage
npm run test:coverage  # or nyc npm test

# Upload
python scripts/dev_assistant.py upload-coverage --flags javascript unit
```

### Java
```bash
# Generate coverage (Maven)
mvn test jacoco:report

# Generate coverage (Gradle)
gradle test jacocoTestReport

# Upload
python scripts/dev_assistant.py upload-coverage --flags java unit
```

### Go
```bash
# Generate coverage
go test -coverprofile=coverage.out ./...

# Upload
python scripts/dev_assistant.py upload-coverage --flags go unit
```

### Flutter/Dart
```bash
# Generate coverage
flutter test --coverage

# Upload
python scripts/dev_assistant.py upload-coverage --flags dart flutter unit
```

### Rust
```bash
# Generate coverage (using tarpaulin)
cargo tarpaulin --out lcov --output-dir coverage

# Upload
python scripts/dev_assistant.py upload-coverage --flags rust unit
```

### C#/.NET
```bash
# Generate coverage
dotnet test --collect:"XPlat Code Coverage"

# Upload
python scripts/dev_assistant.py upload-coverage --flags csharp unit
```

## Coverage Thresholds

### Global Configuration

Set in `automation.config.yaml`:

```yaml
coverage:
  global_threshold: 80    # Minimum overall coverage
  patch_threshold: 85     # Minimum coverage for new/changed code
```

### Per-Language Thresholds

Configure in `codecov.yml`:

```yaml
coverage:
  status:
    project:
      python:
        target: 85%
        flags: [python]
      javascript:
        target: 80%
        flags: [javascript]
```

## Flags and Organization

### Default Flags

- `unittests` - Unit test coverage
- `integration` - Integration test coverage
- `e2e` - End-to-end test coverage
- `{language}` - Language-specific flag (python, java, etc.)
- `{os}` - Operating system (ubuntu-latest, windows-latest)

### Custom Flags

```bash
# Feature-specific flags
python scripts/dev_assistant.py upload-coverage --flags feature-auth unit

# Component flags
python scripts/dev_assistant.py upload-coverage --flags backend api unit
```

## CI/CD Workflows

### GitHub Actions Integration

The template includes automatic Codecov integration:

```yaml
- name: Upload Coverage to Codecov
  uses: codecov/codecov-action@v4
  with:
    token: ${{ secrets.CODECOV_TOKEN }}
    files: coverage/lcov.info,coverage.xml
    flags: ${{ matrix.language }},unittests
    fail_ci_if_error: false
```

### Other CI Systems

#### GitLab CI

```yaml
coverage:
  script:
    - python scripts/dev_assistant.py upload-coverage
  coverage: '/TOTAL.*\s+(\d+%)$/'
```

#### Azure DevOps

```yaml
- script: python scripts/dev_assistant.py upload-coverage
  env:
    CODECOV_TOKEN: $(CODECOV_TOKEN)
  displayName: 'Upload Coverage'
```

## Troubleshooting

### Common Issues

#### 1. No Coverage Files Found

**Problem**: `No coverage files found. Run tests with coverage first.`

**Solution**:
```bash
# Make sure you've run tests with coverage
python scripts/dev_assistant.py coverage  # Generate coverage first
python scripts/dev_assistant.py upload-coverage
```

#### 2. Missing Codecov Token

**Problem**: `CODECOV_TOKEN environment variable not set`

**Solution**:
```bash
# Set environment variable
export CODECOV_TOKEN=your_token_here

# Or pass token directly
python scripts/dev_assistant.py upload-coverage --token YOUR_TOKEN
```

#### 3. Upload Fails

**Problem**: `Codecov upload failed`

**Solutions**:
```bash
# Check network connectivity
curl -f https://codecov.io/

# Validate token
codecov -t $CODECOV_TOKEN --dry-run

# Try with verbose output
codecov -t $CODECOV_TOKEN -v
```

#### 4. Coverage Not Showing

**Problem**: Coverage data uploaded but not visible in Codecov

**Checks**:
- Verify repository is public or you have Codecov Pro
- Check that coverage files contain actual coverage data
- Ensure commit SHA matches between local and CI
- Verify flags are correctly set

### Debug Commands

```bash
# Validate configuration
python scripts/setup_codecov.py --validate

# Test upload (dry run)
python scripts/dev_assistant.py upload-coverage --dry-run

# Check coverage file contents
head -20 coverage/lcov.info

# Verify Codecov CLI installation
codecov --help
```

### Log Analysis

Check CI logs for:
```
✅ Coverage uploaded successfully to Codecov
❌ Codecov upload failed: [error message]
🎉 Coverage data sent to Codecov successfully
```

## Advanced Configuration

### Custom Coverage Patterns

Add to `automation.config.yaml`:

```yaml
codecov:
  coverage_files:
    custom:
      - "reports/coverage.xml"
      - "output/jacoco.xml"
      - "custom-coverage/*.json"
```

### Branch-Specific Settings

Configure in `codecov.yml`:

```yaml
coverage:
  status:
    project:
      develop:
        target: 75%
        branches: [develop]
      main:
        target: 85%
        branches: [main, master]
```

### Ignore Patterns

```yaml
ignore:
  - "tests/"
  - "**/__pycache__/**"
  - "**/node_modules/**"
  - "target/**"
  - "build/**"
  - "vendor/**"
```

## Best Practices

### 1. Coverage Targets

- **Global coverage**: 80%+ for production code
- **Patch coverage**: 85%+ for new changes
- **Critical paths**: 95%+ for core functionality

### 2. Flag Strategy

```bash
# Separate by test type
--flags unit integration e2e

# Separate by component
--flags backend frontend api

# Separate by language in monorepos
--flags python javascript java
```

### 3. CI Integration

- Upload coverage from **one job** per matrix to avoid duplicates
- Use **consistent commit SHAs** between jobs
- Set **fail_ci_if_error: false** to avoid blocking on Codecov issues
- Include **fallback upload** using dev assistant command

### 4. Monitoring

- Set up **Codecov notifications** for coverage drops
- Review **coverage trends** regularly
- Use **pull request integration** for code review
- Monitor **Codecov status checks**

## Security Considerations

### Token Security

- **Never commit** Codecov tokens to version control
- Use **GitHub secrets** or environment variables
- Consider **scoped tokens** for specific repositories
- Rotate tokens **periodically**

### Public vs Private

- **Public repositories**: Basic Codecov features are free
- **Private repositories**: Requires Codecov Pro subscription
- **Forked PRs**: May need special configuration for token access

## Resources

### Documentation
- [Codecov Documentation](https://docs.codecov.io/)
- [Coverage.py Documentation](https://coverage.readthedocs.io/)
- [GitHub Actions Codecov Action](https://github.com/codecov/codecov-action)

### Tools
- [Codecov CLI](https://github.com/codecov/codecov-cli)
- [Coverage Gutters](https://marketplace.visualstudio.com/items?itemName=ryanluker.vscode-coverage-gutters) (VS Code extension)

### Support
- [Codecov Support](https://codecov.io/support)
- [GitHub Discussions](https://github.com/codecov/codecov-action/discussions)
- Template Issues - For template-specific problems, check your project's issue tracker

## Example Workflows

### Development Workflow

```bash
# 1. Write tests and code
git checkout -b feature/new-feature

# 2. Run tests with coverage
python scripts/dev_assistant.py coverage

# 3. Check coverage locally
open coverage/html/index.html

# 4. Upload coverage to Codecov
python scripts/dev_assistant.py upload-coverage

# 5. Push and create PR
git push origin feature/new-feature
# Coverage will be automatically uploaded by CI
```

### Release Workflow

```bash
# 1. Ensure coverage meets requirements
python scripts/dev_assistant.py coverage
# Check: ✅ Coverage: 85.2% (threshold: 80%)

# 2. Upload final coverage
python scripts/dev_assistant.py upload-coverage --flags release

# 3. Tag and release
git tag v1.0.0
git push origin v1.0.0
```

This documentation covers comprehensive Codecov integration for the dev assistant template. For template-specific issues or questions, please check your project's issue tracker or documentation.
