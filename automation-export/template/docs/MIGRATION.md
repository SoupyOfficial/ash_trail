# Migration Guide: From ash_trail to Dev Automation Template

This guide provides detailed mapping of ash_trail automation components to the framework-agnostic template.

## 🗺️ Component Mapping

### Core Scripts

| ash_trail Path | Template Path | Changes Made |
|---|---|---|
| `scripts/dev_assistant.py` (1914 lines) | `scripts/automation.py` | Simplified to core commands, removed Flutter-specific logic |
| `scripts/setup_dev_env.py` | `scripts/bootstrap.sh/.ps1` | Split into cross-platform scripts with language detection |
| `scripts/quality_gate.sh/.bat` | `scripts/lint.sh/.ps1` + `scripts/test.sh/.ps1` | Split quality gate into focused lint and test scripts |
| `scripts/dev_generate.sh/.bat` | `scripts/build.sh/.ps1` | Generalized from Flutter code generation to multi-language build |
| `scripts/precommit.sh/.bat` | `scripts/precommit.sh/.ps1` | Simplified and made language-agnostic |
| `scripts/automation_monitor.py` | `scripts/monitor.py` | Streamlined monitoring without Flutter-specific assumptions |
| `scripts/automation_dashboard.py` | Optional feature | Interactive dashboard moved to optional component |

### Configuration Files

| ash_trail Path | Template Path | Migration Notes |
|---|---|---|
| `feature_matrix.yaml` | `automation.config.yaml` | Completely redesigned as language-agnostic configuration |
| `.pre-commit-config.yaml` | `hooks/pre-commit-config.yaml` | Generalized hooks without Flutter dependencies |
| `codecov.yml` | `config/codecov.yml` | Simplified coverage configuration |
| `analysis_options.yaml` | `templates/analysis_options.yaml.example` | Moved to language-specific example |

### CI/CD Workflows

| ash_trail Path | Template Path | Migration Strategy |
|---|---|---|
| `.github/workflows/ci.yml` | `ci/github/workflows/automation.yml` | **Major redesign**: Matrix build with language detection |
| `.github/workflows/feature-matrix.yml` | Integrated into main workflow | Feature validation logic integrated into automation.yml |
| `.github/workflows/coverage.yml` | Integrated into main workflow | Coverage jobs merged into automation.yml |
| `.github/workflows/nightly-coverage.yml` | Integrated into main workflow | Scheduled runs in automation.yml |
| `.github/workflows/pr-linter.yml` | Integrated into main workflow | PR validation in automation.yml lint job |
| `.github/workflows/automation-governance.yml` | Optional governance workflow | Standalone governance checks |
| `.github/workflows/monitor.yml` | Integrated into main workflow | Monitoring integrated as health checks |

### VS Code Integration

| ash_trail Path | Template Path | Changes |
|---|---|---|
| `.vscode/tasks.json` (70+ tasks) | `templates/.vscode/tasks.json.example` | Generalized task templates for any language |
| `.vscode/launch.json` | `templates/.vscode/launch.json.example` | Language-agnostic debug configurations |
| `.vscode/extensions.json` | `templates/.vscode/extensions.json.example` | Per-language extension recommendations |

## 🔄 Step-by-Step Migration

### 1. From Existing ash_trail Project

If you're migrating an existing ash_trail project:

```bash
# 1. Backup your current automation
mkdir backup-automation
cp -r scripts .github .vscode backup-automation/

# 2. Copy template files
cp -r automation-export/template/* .

# 3. Preserve your project-specific configs
# Keep: pubspec.yaml, lib/, test/, android/, ios/, etc.
# Update: Replace automation files with template versions

# 4. Run bootstrap
./scripts/bootstrap.sh

# 5. Validate
./scripts/doctor.sh
```

### 2. To New Project Type

When adapting the template to a different language:

```bash
# 1. Copy template to your project
cp -r automation-export/template/* your-project/

# 2. Update automation.config.yaml if needed
# (Usually automatic language detection works)

# 3. Bootstrap environment
cd your-project
./scripts/bootstrap.sh

# 4. Verify detection
./scripts/doctor.sh
```

## 🎯 Language-Specific Migrations

### From Flutter to Python

**Files to Update:**
- Remove: `pubspec.yaml`, `lib/`, `android/`, `ios/`
- Add: `pyproject.toml` or `requirements.txt`
- Update: Test directory structure

**Command Changes:**
```bash
# OLD (Flutter)
flutter pub get
flutter analyze  
flutter test --coverage
flutter build apk

# NEW (Python)  
pip install -r requirements.txt
ruff check . && black --check .
pytest --cov=. --cov-report=lcov
python -m build
```

### From Flutter to Java/Spring

**Files to Update:**
- Remove: `pubspec.yaml`, Flutter directories
- Add: `pom.xml` or `build.gradle`
- Update: `src/main/java/`, `src/test/java/`

**Command Changes:**
```bash
# OLD (Flutter)
flutter pub get
flutter analyze
flutter test --coverage  
flutter build apk

# NEW (Java Maven)
mvn dependency:resolve
mvn spotless:check
mvn test jacoco:report
mvn package
```

### From Flutter to Node.js

**Files to Update:**
- Remove: `pubspec.yaml`, Flutter directories
- Add: `package.json`
- Update: `src/`, `test/` or `tests/`

**Command Changes:**
```bash
# OLD (Flutter)
flutter pub get
flutter analyze
flutter test --coverage
flutter build web

# NEW (Node.js)
npm install
npm run lint
npm run test:coverage  
npm run build
```

## 🔧 Configuration Migration

### feature_matrix.yaml → automation.config.yaml

The Flutter-specific feature matrix is replaced with language-agnostic automation config:

**OLD (ash_trail feature_matrix.yaml):**
```yaml
features:
  - id: logging_smoke_log
    epic: logging
    name: "Smoke Log Entry"
    status: done
    priority: 1
```

**NEW (automation.config.yaml):**
```yaml
detect:
  python: ["pyproject.toml", "requirements.txt"]
  java: ["pom.xml", "build.gradle"]

tasks:
  lint:
    python: "ruff check . && black --check ."
    java: "mvn spotless:check"
```

### VS Code Tasks Migration

**OLD (Flutter-specific tasks):**
```json
{
  "label": "Dev Assistant: Status",
  "command": "python",
  "args": ["scripts/dev_assistant.py", "status"]
}
```

**NEW (Language-agnostic tasks):**
```json
{
  "label": "Doctor - Health Check",
  "command": "${workspaceFolder}/scripts/doctor.sh",
  "windows": {
    "command": "${workspaceFolder}\\scripts\\doctor.ps1"
  }
}
```

## 🚨 Breaking Changes

### Removed Components

These ash_trail components are **not** included in the template:

1. **Feature Matrix System** - Highly Flutter-specific, replaced with generic config
2. **GitHub Issues Sync** - Project-specific automation  
3. **Complex Coverage Analysis** - Simplified to standard LCOV reporting
4. **Flutter Code Generation** - Replaced with generic build process
5. **Sophisticated Monitoring** - Simplified to basic health checks

### Changed Interfaces

| Old Command | New Command | Notes |
|---|---|---|
| `python scripts/dev_assistant.py status` | `./scripts/doctor.sh` | Simplified health check |
| `python scripts/dev_assistant.py dev-cycle` | `./scripts/lint.sh && ./scripts/test.sh --coverage` | Split into focused commands |
| `scripts/quality_gate.sh` | `./scripts/lint.sh && ./scripts/test.sh` | Separated concerns |
| `flutter pub run build_runner build` | `./scripts/build.sh` | Generic build process |

## 🔍 Validation Checklist

After migration, verify these work correctly:

- [ ] **Language Detection**: `./scripts/doctor.sh` shows correct language
- [ ] **Environment Setup**: `./scripts/bootstrap.sh` installs appropriate tools
- [ ] **Linting**: `./scripts/lint.sh` runs language-appropriate linting
- [ ] **Testing**: `./scripts/test.sh --coverage` executes tests with coverage
- [ ] **Building**: `./scripts/build.sh` produces expected artifacts
- [ ] **CI/CD**: GitHub Actions workflow detects language and runs matrix builds
- [ ] **Coverage**: Coverage reports generate in LCOV format
- [ ] **Cross-Platform**: PowerShell scripts work on Windows

## 💡 Tips for Smooth Migration

### 1. Preserve Project Structure
Keep your existing project files and only replace automation:
```bash
# Safe files to replace
scripts/
.github/workflows/
.vscode/tasks.json
.pre-commit-config.yaml

# Keep your project files
src/ lib/ tests/ package.json pyproject.toml etc.
```

### 2. Gradual Migration  
Migrate one component at a time:
1. Start with `bootstrap` and `doctor` scripts
2. Add `lint` and `test` scripts  
3. Update CI/CD workflows last

### 3. Test Thoroughly
After each migration step:
```bash
./scripts/doctor.sh           # Validate environment
./scripts/lint.sh            # Check linting works  
./scripts/test.sh --coverage # Verify tests run
./scripts/build.sh           # Confirm builds work
```

### 4. Update Documentation
Update your project's README to reference the new automation commands and remove Flutter-specific instructions.

## 🆘 Common Issues

### "Unknown project type"
- **Cause**: Missing language detection files
- **Solution**: Ensure you have `package.json`, `pyproject.toml`, `pom.xml`, etc.

### "Command not found"  
- **Cause**: Language tools not installed
- **Solution**: Run `./scripts/bootstrap.sh` to install dependencies

### "Coverage threshold not met"
- **Cause**: Different coverage calculation than ash_trail
- **Solution**: Check `automation.config.yaml` thresholds, adjust as needed

### Cross-platform script issues
- **Cause**: Path differences between Unix/Windows
- **Solution**: Use provided PowerShell scripts on Windows

## 📞 Support

For migration issues:
1. Check the [CUSTOMIZATION.md](CUSTOMIZATION.md) guide
2. Review sample projects in `samples/` directory  
3. Compare working ash_trail automation with template
4. File issue with specific error messages and environment details