# Dev Automation Template

A framework-agnostic development automation template extracted from the [ash_trail](https://github.com/SoupyOfficial/ash_trail) project.

## 🚀 Quick Start

1. **Copy the template to your project:**
   ```bash
   cp -r template/* your-project/
   cd your-project
   ```

2. **Bootstrap your environment:**
   ```bash
   # Unix/macOS
   ./scripts/bootstrap.sh
   
   # Windows
   .\scripts\bootstrap.ps1
   ```

3. **Validate your setup:**
   ```bash
   # Unix/macOS  
   ./scripts/doctor.sh
   
   # Windows
   .\scripts\doctor.ps1
   ```

4. **Run the automation pipeline:**
   ```bash
   # Unix/macOS
   ./scripts/lint.sh
   ./scripts/test.sh --coverage
   ./scripts/build.sh --release
   
   # Windows
   .\scripts\lint.ps1
   .\scripts\test.ps1 -Coverage
   .\scripts\build.ps1 -Release
   ```

## 🎯 Supported Languages

The template automatically detects your project type and applies the appropriate tooling:

| Language | Detection Files | Lint | Test | Build |
|---|---|---|---|---|
| **Python** | `pyproject.toml`, `requirements.txt` | ruff + black | pytest | python -m build |
| **Java** | `pom.xml`, `build.gradle` | spotless | mvn test / gradle test | mvn package |
| **Node.js** | `package.json` | eslint | npm test | npm run build |
| **Go** | `go.mod` | go vet + golangci-lint | go test | go build |
| **Flutter** | `pubspec.yaml` | dart format + flutter analyze | flutter test | flutter build |
| **Rust** | `Cargo.toml` | cargo fmt + clippy | cargo test | cargo build |
| **C#/.NET** | `*.csproj`, `*.sln` | dotnet format | dotnet test | dotnet build |

## 📋 Core Scripts

### `bootstrap` - Environment Setup
```bash
./scripts/bootstrap.sh [--skip-deps] [--skip-hooks]
```
- Detects project language
- Installs system dependencies  
- Sets up language-specific tools
- Configures git hooks
- Creates necessary directories

### `doctor` - Health Check
```bash
./scripts/doctor.sh
```
- Validates system tools (git, curl, language runtimes)
- Checks git configuration
- Verifies language-specific dependencies
- Tests project structure
- Reports environment status

### `lint` - Code Quality
```bash
./scripts/lint.sh [--fix]
```
- Runs language-specific linting tools
- Checks code formatting
- Validates file quality (trailing whitespace, etc.)
- Can auto-fix issues with `--fix` flag

### `test` - Test Execution  
```bash
./scripts/test.sh [--coverage] [--verbose]
```
- Executes language-appropriate test suites
- Generates coverage reports (LCOV format)
- Enforces coverage thresholds (80% global, 85% patch)
- Supports verbose output

### `build` - Project Building
```bash
./scripts/build.sh [--release] [--clean]
```
- Builds project using language-specific tools
- Supports debug and release modes
- Can clean artifacts before building
- Verifies build outputs

## ⚙️ Configuration

The `automation.config.yaml` file drives all automation behavior:

```yaml
# Language detection patterns
detect:
  python: ["pyproject.toml", "requirements.txt"]
  java: ["pom.xml", "build.gradle"]
  node: ["package.json"]

# Commands per language
tasks:
  lint:
    python: "ruff check . && black --check ."
    java: "mvn spotless:check"
    node: "npm run lint"
  
  test:
    python: "pytest -v"
    java: "mvn test"
    node: "npm test"

# Coverage settings
coverage:
  global_threshold: 80
  patch_threshold: 85
```

## 🔄 CI/CD Integration

### GitHub Actions
Copy `ci/github/workflows/automation.yml` to your `.github/workflows/` directory. The workflow provides:

- **Matrix builds** across Ubuntu/Windows with multiple language versions
- **Language detection** with appropriate tool setup
- **Coverage reporting** with Codecov integration  
- **PR comments** with coverage status
- **Build artifacts** upload for release builds
- **Security scanning** per language ecosystem

### GitLab CI
Copy `ci/gitlab/.gitlab-ci.yml` to your project root for GitLab CI integration with equivalent functionality.

## 🎨 VS Code Integration

The template includes VS Code configuration examples:

- **tasks.json** - Pre-configured tasks for all automation scripts
- **launch.json** - Debug configurations per language
- **extensions.json** - Recommended extensions per language
- **settings.json** - Workspace settings for optimal development

## 🔒 Security Features

- **Vulnerability scanning** - Language-specific security tools
- **License compliance** - Automated license checking  
- **Dependency auditing** - Checks for known vulnerabilities
- **Secret detection** - No secrets in repository (uses .env.example)

## 📚 Language-Specific Notes

### Python
- Supports both `pyproject.toml` and `setup.py` projects
- Uses `ruff` for linting, `black` for formatting
- Coverage via `pytest-cov` with LCOV output

### Java  
- Supports both Maven and Gradle
- Uses Spotless for formatting
- JaCoCo for coverage reporting

### Node.js
- Respects `package.json` scripts
- Uses ESLint for linting
- NYC or built-in coverage tools

### Go
- Standard Go tooling (fmt, vet, test)
- Optional golangci-lint for advanced linting
- Built-in coverage support

### Flutter/Dart
- Dart formatter and Flutter analyzer
- Code generation via build_runner
- Built-in test coverage

### Rust
- Cargo formatting and Clippy linting
- Optional Tarpaulin for coverage
- Standard Cargo build/test cycle

### C#/.NET
- dotnet format for code style
- Built-in test and coverage tools
- Support for multi-project solutions

## 🚨 Coverage Thresholds

The template enforces coverage standards:

- **Global coverage**: 80% minimum across entire codebase
- **Patch coverage**: 85% minimum for changed lines
- **Configurable per language** via automation.config.yaml
- **CI integration** with automatic PR status checks

## 🤝 Contributing

When contributing to projects using this template:

1. Run `./scripts/doctor.sh` to ensure your environment is set up
2. Use `./scripts/lint.sh --fix` to format code before committing
3. Run `./scripts/test.sh --coverage` to verify tests and coverage
4. The pre-commit hooks will run automatically if configured

## 🔧 Customization

See [CUSTOMIZATION.md](CUSTOMIZATION.md) for detailed guides on:
- Adding new languages
- Customizing tool configurations
- Extending CI/CD pipelines
- Integrating with other tools

## 📖 Migration Guide

See [MIGRATION.md](MIGRATION.md) for step-by-step instructions on migrating from ash_trail or adapting the template for your specific needs.

## 🛡️ Security

See [SECURITY.md](SECURITY.md) for security best practices and vulnerability reporting.

## 📄 License

This template is released under the same license as the originating ash_trail project.

---

**💡 Tip**: Run `./scripts/doctor.sh --help` to see all available options for any script.