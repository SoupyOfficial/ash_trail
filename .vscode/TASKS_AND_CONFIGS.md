# VS Code Tasks and Run Configurations

This document provides a comprehensive guide to all the VS Code tasks and debug configurations available for the AshTrail project.

## Quick Access

- **Tasks**: `Ctrl+Shift+P` → "Tasks: Run Task" → Select from list
- **Debug Configurations**: `F5` or `Ctrl+Shift+D` → Select configuration → Start debugging
- **Command Palette**: `Ctrl+Shift+P` → Type task/command name

## Development Assistant (dev_assistant.py) Tasks

The main development automation script provides these commands:

### Core Status & Health
- **Dev Assistant: Status** - Overall project status with health, git info, features, and coverage
- **Dev Assistant: Status (JSON)** - Same as above but in JSON format
- **Dev Assistant: Health Check** - Check Flutter, Git, Codecov tools and coverage file existence
- **Dev Assistant: Features** - List next features to implement (default limit 10)
- **Dev Assistant: Features (Limit 20)** - List next 20 features to implement

### Testing & Coverage
- **Dev Assistant: Test Coverage** - Run Flutter tests with coverage generation
- **Dev Assistant: Test Codecov** - Test Codecov CLI availability
- **Dev Assistant: Upload Codecov** - Upload coverage results to Codecov
- **Analyze Coverage** - Detailed coverage analysis with improvement recommendations

### Development Workflow
- **Dev Assistant: Dev Cycle** - Complete development cycle (test + coverage)
- **Dev Assistant: Dev Cycle (Upload)** - Dev cycle with automatic Codecov upload
- **Dev Assistant: Dev Cycle (Skip Tests)** - Fast dev cycle without running tests
- **Dev Assistant: Full Check** - Comprehensive health and coverage check

### Feature Management
- **Dev Assistant: Start Next Feature** - Start working on the next planned feature
- **Dev Assistant: Start Next Feature (Dry Run)** - Preview what starting next feature would do
- **Dev Assistant: Start Next Feature (Auto Commit)** - Start feature and auto-commit scaffold
- **Dev Assistant: Start Next Feature (Auto Commit & Push)** - Start, commit, and push to remote
- **Dev Assistant: Finalize Feature** - Complete current feature development
- **Dev Assistant: Finalize Feature (Dry Run)** - Preview feature finalization

### Utilities
- **Dev Assistant: Cache Features** - Cache feature matrix for faster access
- **Dev Assistant: ADR Index** - Regenerate Architecture Decision Records index

## Feature Detection & Analysis Tasks

### Feature Status Detection
- **Detect Feature Status: Suggest Next** - Get suggestion for next feature to implement
- **Detect Feature Status: Analyze All** - Analyze status of all features
- **Detect Feature Status: Check Gaps** - Check for gaps between matrix and implementation
- **Detect Feature Status: Check Blocked** - Find features blocked by dependencies
- **Detect Feature Status: Top 5** - Show top 5 next features to implement

## Quality & Coverage Tasks

### Coverage Analysis
- **Patch Coverage Check** - Check coverage of changed lines vs default branch
- **Patch Coverage Check (vs main)** - Explicitly compare against main branch
- **Flutter Test with Coverage** - Run Flutter tests with coverage generation

### Code Quality
- **Pre-commit Hook** - Run pre-commit checks (linting, formatting, tests)
- **License Check** - Verify license compliance
- **Docs Integrity Check** - Check documentation consistency
- **Branch Policy Check** - Verify branch naming and policies
- **Instruction Hash Guard** - Verify instruction file integrity

## Project Setup & Maintenance Tasks

### Environment Setup
- **Setup Development Environment** - Initialize development environment
- **Generate Development Scripts** - Run dev_generate.bat (Windows batch script)
- **Generate From Feature Matrix** - Generate code from feature matrix definitions

### Flutter Tasks
- **Flutter Clean** - Clean Flutter build artifacts
- **Flutter Pub Get** - Install Flutter dependencies  
- **Flutter Build Runner** - Run code generation with build_runner

### Project Health
- **Health Check** - Run health_check.bat (comprehensive system check)
- **Quality Gate** - Run quality_gate.bat (quality checks before commit)
- **Pre-commit** - Run precommit.bat (pre-commit hook script)

## Feature Scaffolding

### Manual Feature Creation
- **Simple Feature Scaffold** - Create basic feature structure (prompts for feature name)

## Debug Configurations

All Python scripts can be debugged using the debug configurations. Key debug configs include:

### Flutter Debugging
- **Flutter: Run App** - Launch Flutter app in debug mode
- **Flutter: Debug Tests** - Debug Flutter tests

### Development Assistant Debugging
- **Python: Dev Assistant Status** - Debug status command
- **Python: Dev Assistant Health** - Debug health check
- **Python: Dev Assistant Test Coverage** - Debug coverage generation
- **Python: Dev Assistant Dev Cycle** - Debug full development cycle
- **Python: Start Next Feature** - Debug feature start process
- **Python: Finalize Feature** - Debug feature finalization

### Analysis & Detection Debugging
- **Python: Analyze Coverage** - Debug coverage analysis
- **Python: Detect Feature Status - Suggest Next** - Debug feature suggestion
- **Python: Detect Feature Status - Analyze All** - Debug feature analysis
- **Python: Patch Coverage Check** - Debug patch coverage checking

## Environment Variables

The following environment variables can be configured in `.env` or VS Code settings:

- `DEV_ASSISTANT_SKIP_TOOL_CHECKS=0` - Set to 1 to skip tool availability checks
- `COVERAGE_MIN=80` - Minimum required coverage percentage (default: 80%)
- `PATCH_COVERAGE_MIN=85` - Minimum required patch coverage percentage (default: 85%)

## Common Workflows

### Starting New Feature Development
1. Run **Dev Assistant: Status** to check current state
2. Run **Dev Assistant: Start Next Feature (Dry Run)** to preview
3. Run **Dev Assistant: Start Next Feature** to begin
4. Develop feature following the generated AI_IMPLEMENTATION_GUIDE.md
5. Run **Dev Assistant: Finalize Feature (Dry Run)** to validate
6. Run **Dev Assistant: Finalize Feature** when ready

### Daily Development Cycle  
1. Run **Dev Assistant: Health Check** at start of day
2. Make code changes
3. Run **Dev Assistant: Dev Cycle** to test and check coverage
4. Run **Pre-commit Hook** before committing
5. Run **Dev Assistant: Upload Codecov** if needed

### Coverage Analysis Workflow
1. Run **Flutter Test with Coverage** to generate coverage
2. Run **Analyze Coverage** for detailed analysis
3. Run **Patch Coverage Check** to check changed lines coverage
4. Address coverage gaps identified in the analysis

### Quality Assurance Workflow
1. Run **Quality Gate** before major commits
2. Run **License Check** and **Docs Integrity Check** periodically  
3. Run **Branch Policy Check** to verify branch compliance
4. Run **Instruction Hash Guard** to verify instruction integrity

## Tips

- Use `Ctrl+Shift+P` and start typing the task name for quick access
- Most Python scripts support `--json` flag for machine-readable output
- Use dry-run options to preview actions before executing
- Debug configurations include environment file loading from `.env`
- Tasks are organized by groups (build, test) for better categorization
- Terminal output is preserved and can be scrolled/searched

## Troubleshooting

- If Python tasks fail, check `python --version` in terminal
- If Flutter tasks fail, check `flutter doctor` in terminal  
- Coverage tasks require running tests first to generate `coverage/lcov.info`
- Some tasks may require specific tools (codecov CLI, git, etc.)
- Check the terminal output for detailed error messages
- Use debug configurations to step through scripts when troubleshooting