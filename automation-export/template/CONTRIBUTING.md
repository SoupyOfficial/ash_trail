# Contributing to Automation Template

Thank you for your interest in contributing to the Automation Template! This guide outlines the process for contributing safely and effectively.

## 🔒 Security Guidelines

### Secrets and Sensitive Data

**NEVER commit secrets, API keys, passwords, or sensitive data to the repository.**

- ✅ Use `.env.example` as a template for environment variables
- ✅ Add sensitive files to `.gitignore`
- ✅ Use placeholder values in configuration examples
- ✅ Validate with `gitleaks` before committing

```bash
# Check for secrets before committing
./scripts/security.sh
```

### Dependency Security

- **Pin dependency versions** in lockfiles (package-lock.json, go.sum, Cargo.lock)
- **Scan for vulnerabilities** before adding new dependencies
- **Update dependencies regularly** but test thoroughly
- **Review dependency licenses** for compatibility

```bash
# Language-specific security scans
npm audit                    # Node.js
pip-audit                   # Python  
mvn dependency-check:check  # Java
go mod tidy && govulncheck ./... # Go
cargo audit                 # Rust
```

### CI/CD Security

- **Pin GitHub Actions** to commit SHAs, not version tags
- **Use minimal permissions** in workflow files
- **Validate inputs** in custom actions and scripts
- **Store secrets** in GitHub Secrets, not in code

```yaml
# ✅ Good - pinned to commit SHA
- uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11

# ❌ Bad - mutable tag
- uses: actions/checkout@v4
```

## 📋 Development Process

### Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally
3. **Create a feature branch** from `main`
4. **Set up development environment**

```bash
git clone https://github.com/YOUR-USERNAME/automation-template.git
cd automation-template
git checkout -b feature/your-feature-name

# Set up environment
./scripts/doctor.sh    # or .\scripts\doctor.ps1 on Windows
```

### Code Standards

#### Cross-Platform Compatibility

- **Provide both Bash (.sh) and PowerShell (.ps1)** script versions
- **Test on multiple operating systems** (Linux, macOS, Windows)
- **Use portable file paths** and avoid hardcoded separators
- **Handle different line endings** (.gitattributes configured)

#### Error Handling

```bash
# Bash - Use proper error handling
set -euo pipefail
trap 'echo "Error on line $LINENO"' ERR
```

```powershell
# PowerShell - Use proper error handling
$ErrorActionPreference = 'Stop'
try {
    # Your code here
} catch {
    Write-Error "Error: $_"
    exit 1
}
```

#### Configuration-Driven

- **Use `automation.config.yaml`** for all configurable behavior
- **Validate configuration** before script execution
- **Provide sensible defaults** with override capability
- **Document configuration options** clearly

### Testing Requirements

#### Unit Tests

- **Minimum 80% line coverage** for new code
- **Test error conditions** and edge cases
- **Use appropriate testing frameworks** per language
- **Mock external dependencies** appropriately

#### Integration Tests

- **Test script execution** on different platforms
- **Validate CI pipeline** changes in branches
- **Test configuration variations** 
- **Verify cross-language compatibility**

#### Security Tests

```bash
# Run security validation
./scripts/security.sh

# Check for hardcoded secrets
gitleaks detect --source . --verbose

# Validate CI configuration
yamllint .github/workflows/*.yml
yamllint .gitlab-ci.yml
```

## 🚀 Contribution Workflow

### 1. Code Changes

```bash
# Make your changes
git add .
git commit -m "feat: add support for Rust language detection"

# Run validation
./scripts/dev_assistant.py health
./scripts/security.sh
```

### 2. Testing

```bash
# Test your changes
./scripts/test.sh --coverage

# Test cross-platform (if applicable)
# Linux/macOS
./scripts/doctor.sh && ./scripts/lint.sh && ./scripts/test.sh

# Windows
.\scripts\doctor.ps1 && .\scripts\lint.ps1 && .\scripts\test.ps1
```

### 3. Documentation

- **Update README.md** if adding new features
- **Add configuration examples** for new options
- **Update TROUBLESHOOTING.md** for new error conditions
- **Include samples** for new languages/frameworks

### 4. Pull Request

1. **Push to your fork**
2. **Create pull request** against `main` branch
3. **Fill out PR template** completely
4. **Address review feedback** promptly

```bash
git push origin feature/your-feature-name
# Then create PR via GitHub interface
```

## 🔍 Review Process

### Automated Checks

All PRs must pass:
- ✅ **CI pipeline** (GitHub Actions + GitLab CI)
- ✅ **Security scanning** (gitleaks, dependency audit)
- ✅ **Code quality** (linting, formatting)
- ✅ **Test coverage** (≥80% line coverage)
- ✅ **Cross-platform compatibility**

### Manual Review

Reviewers will check:
- **Security implications** of changes
- **Breaking changes** and backwards compatibility  
- **Documentation completeness**
- **Code maintainability** and clarity
- **Performance impact** of changes

## 🐛 Issue Reporting

### Security Vulnerabilities

**DO NOT open public issues for security vulnerabilities.**

Email security@example.com with:
- Description of the vulnerability
- Steps to reproduce
- Potential impact assessment
- Suggested mitigation (if any)

### Bug Reports

Include:
- **Operating system** and version
- **Language/framework** version
- **Automation template** version/commit
- **Complete error logs** (sanitized)
- **Steps to reproduce**
- **Expected vs actual behavior**

### Feature Requests

Include:
- **Use case description** and justification
- **Proposed implementation** approach
- **Impact on existing functionality**
- **Testing strategy**

## 📚 Additional Resources

### Development Tools

- **VS Code Extensions**: YAML, PowerShell, markdownlint
- **Git Hooks**: Use `.pre-commit-config.yaml`
- **Testing**: Language-specific test runners
- **Security**: gitleaks, dependency scanners

### Documentation

- [Architecture Decision Records](docs/adr/)
- [Troubleshooting Guide](docs/TROUBLESHOOTING.md)  
- [Customization Guide](docs/CUSTOMIZATION.md)
- [Migration Guide](docs/MIGRATION.md)

### Communication

- **GitHub Discussions**: For general questions
- **Issues**: For bugs and feature requests
- **Pull Requests**: For code contributions
- **Email**: For security-related concerns

---

## Code of Conduct

This project follows a professional code of conduct:

- **Be respectful** and inclusive
- **Focus on technical merit** of contributions
- **Provide constructive feedback** 
- **Maintain confidentiality** for security issues
- **Follow established processes** for contributions

By contributing, you agree to abide by these guidelines and help maintain a positive community environment.

**Thank you for contributing to making automation more reliable and secure! 🎉**
