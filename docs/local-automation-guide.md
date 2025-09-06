# Option 2: Enhanced Local Automation Instructions

## Overview
This guide provides comprehensive instructions for using the enhanced local development automation features in AshTrail. These tools complement the automated GitHub Actions coverage uploads and provide developers with powerful local workflow capabilities.

## Prerequisites

### 1. Environment Setup
Ensure your development environment is properly configured:

```bash
# Verify Flutter installation
flutter --version

# Verify Python installation (3.11+ recommended)
python --version

# Install Codecov CLI (if not already installed)
npm install -g codecov
```

### 2. (Optional) Codecov Token Setup

If you want authenticated uploads (not required for local gating), set the environment variable manually:

```bash
# Windows (cmd)
set CODECOV_TOKEN=your_token_here
# PowerShell
$Env:CODECOV_TOKEN="your_token_here"
# Linux / macOS
export CODECOV_TOKEN=your_token_here
```

Retrieve token from your repository page on Codecov (Settings > General).

## Available Commands

### Core Development Commands

#### 1. Health Check
```bash
python scripts/dev_assistant.py health
```
**Purpose:** Comprehensive environment validation
**Checks:**
- Flutter SDK installation and version
- Python environment and dependencies
- Git repository status
- Required tools availability
- Configuration files validity

#### 2. Coverage Analysis
```bash
python scripts/dev_assistant.py test-coverage
```
**Purpose:** Generate and analyze test coverage
**Features:**
- Runs `flutter test --coverage`
- Parses coverage data with detailed metrics
- Shows coverage percentages by component
- Provides improvement recommendations
- Validates against project targets (80% overall, 90% domain)

#### 3. Codecov Integration Testing
```bash
python scripts/dev_assistant.py test-codecov
```
**Purpose:** Validate Codecov integration
**Checks:**
- Codecov CLI availability and version
- Coverage file existence and validity
- Token configuration status
- Upload readiness verification

#### 4. Coverage Upload
```bash
python scripts/dev_assistant.py upload-codecov
```
**Purpose:** Upload coverage to Codecov
**Features:**
- Authenticated upload (if token configured)
- Upload progress tracking
- Error handling and retry logic
- Success/failure reporting

### Advanced Automation Commands

#### 5. Full Development Check
```bash
python scripts/dev_assistant.py full-check
```
**Purpose:** Comprehensive development environment audit
**Includes:**
- Complete health check
- Coverage analysis with recommendations
- Codecov integration verification
- Environment setup validation
- Summary report with actionable items

#### 6. Complete Development Cycle
```bash
python scripts/dev_assistant.py dev-cycle
```
**Purpose:** Full automated development workflow
**Process:**
1. Runs all tests with coverage generation
2. Analyzes coverage metrics and trends
3. Uploads coverage to Codecov (if configured)
4. Provides comprehensive success/failure report
5. Suggests next steps based on results

### Status and Monitoring Commands

#### 7. Project Status
```bash
python scripts/dev_assistant.py status
```
**Purpose:** Quick project overview
**Shows:**
- Recent development activity
- Current feature status
- Test and coverage summaries
- Pending tasks and issues

#### 8. Feature Overview
```bash
python scripts/dev_assistant.py features
```
**Purpose:** Feature matrix status report
**Displays:**
- Feature implementation status
- Priority classifications (P0, P1, P2, P3)
- Component completeness
- Next recommended features

## Recommended Workflows

### Daily Development Workflow

1. **Start of Day Check:**
   ```bash
   python scripts/dev_assistant.py health
   ```

2. **Pre-Development Validation:**
   ```bash
   python scripts/dev_assistant.py status
   ```

3. **Post-Development Testing:**
   ```bash
   python scripts/dev_assistant.py dev-cycle
   ```

### Feature Development Workflow

1. **Pre-Feature Planning:**
   ```bash
   python scripts/dev_assistant.py features
   python scripts/dev_assistant.py full-check
   ```

2. **During Development:**
   ```bash
   # After making changes
   python scripts/dev_assistant.py test-coverage
   ```

3. **Pre-Commit Validation:**
   ```bash
   python scripts/dev_assistant.py dev-cycle
   ```

### CI/CD Integration Workflow

1. **Local Pre-Push Validation:**
   ```bash
   python scripts/dev_assistant.py full-check
   ```

2. **Coverage Upload (if CI fails):**
   ```bash
   python scripts/dev_assistant.py upload-codecov
   ```

## Advanced Configuration

### Environment Variables

- `CODECOV_TOKEN`: Repository upload token for authenticated uploads (optional)
- `COVERAGE_MIN`: Minimum global coverage percentage (default: 80)
- `FLUTTER_VERSION`: Preferred Flutter version for consistency

### Customization Options

#### Coverage Targets
Edit `codecov.yml` to adjust coverage targets:
```yaml
coverage:
  status:
    project:
      default:
        target: 80%
    patch:
      default:
        target: 85%
```

#### Development Assistant Configuration
The assistant reads from several sources:
- `feature_matrix.yaml` - Feature definitions and status
- `pubspec.yaml` - Project dependencies and metadata
- `.github/instructions/` - AI development guidelines
- `codecov.yml` - Coverage configuration

## Troubleshooting

### Common Issues

1. **"Flutter not found"**
   ```bash
   # Add Flutter to PATH or specify full path
   export PATH="$PATH:/path/to/flutter/bin"
   ```

2. **"Codecov CLI not found"**
   ```bash
   # Install globally via npm
   npm install -g codecov
   ```

3. **"Coverage file not found"**
   ```bash
   # Generate coverage first
   flutter test --coverage
   ```

4. **"Upload failed"**
   - Verify `CODECOV_TOKEN` (if using private/auth uploads) and network connectivity.

### Debug Mode

For detailed debugging information:
```bash
# Enable verbose output for any command
python scripts/dev_assistant.py <command> --verbose
```

### Log Files

Check these locations for detailed logs:
- `automation_monitor.log` - General automation logs
- `coverage/lcov.info` - Raw coverage data
- Build output in terminal for detailed error messages

## Integration with AI Development

### Trigger Patterns

Use these patterns in commits/PRs to trigger AI-assisted development:

```bash
# Feature implementation
git commit -m "feat: implement smoke log entry form

#github-pull-request_copilot-coding-agent

Title: [FEATURE] Smoke Log Entry Form
Epic: Core Logging
Priority: P0"
```

### Development Standards

The local automation enforces these standards:
- Minimum 80% overall coverage
- 90% coverage for domain layer
- All tests must pass before upload
- Code analysis warnings addressed
- Feature matrix consistency

### Quality Gates

Before using AI assistance, ensure:
1. `python scripts/dev_assistant.py full-check` passes
2. All local tests pass with good coverage
3. No outstanding health check issues
4. Feature matrix is up to date

## Performance Optimization

### Command Performance

- **Fastest:** `health`, `status` (~2-5 seconds)
- **Medium:** `test-codecov`, `upload-codecov` (~10-15 seconds)
- **Slowest:** `dev-cycle`, `full-check` (~60-120 seconds)

### Optimization Tips

1. **Use specific commands** for targeted checks
2. **Run full-check** only before major commits
3. **Cache Flutter dependencies** to speed up testing
4. **Use dev-cycle** for comprehensive validation before push

## Future Enhancements

Planned improvements include:
- Interactive mode for guided workflows
- Integration with VS Code extension
- Automated dependency updates
- Performance benchmarking
- Custom workflow templates

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review logs in `automation_monitor.log`
3. Run `python scripts/dev_assistant.py health` for diagnostics
4. Consult `.github/instructions/development-workflow.md` for AI assistance
