# Automation Workflow Troubleshooting Guide

This document addresses common issues with AshTrail's automated development workflows and provides solutions.

## 🚨 Recent Critical Issues (December 2025)

### HTTP 403 Workflow Trigger Error

**Problem**: 
```
could not create workflow dispatch event: HTTP 403: Resource not accessible by integration
```

**Root Cause**: 
The `GITHUB_TOKEN` has limited permissions and cannot trigger other workflows due to GitHub's security restrictions.

**Solutions Implemented**:
1. **Enhanced Error Handling**: Workflows now catch 403 errors and fall back to direct implementation
2. **PAT Token Support**: Use `secrets.PAT_TOKEN` (if configured) for broader permissions
3. **Direct Implementation Fallback**: Automatic fallback when workflow triggering fails

**Quick Fix**:
Set up PAT token:
1. GitHub → Settings → Developer settings → Personal access tokens
2. Create token with `repo` and `actions:write` scopes  
3. Add as repository secret: `PAT_TOKEN`

### Python Indentation Error in Coverage Check

**Problem**:
```
IndentationError: unexpected indent
```

**Solution**: Created dedicated `scripts/check_coverage_issues.py` script to replace problematic inline Python in YAML.

---

## 🤖 AI-Assisted Automation Issue Resolution Guide

This guide provides AI-powered diagnostics and solutions for common automation issues in AshTrail.

# Linux/Mac  
./scripts/health_check.sh

# Direct Python
python scripts/automation_monitor.py check
```

## 🔍 Common Issues & AI Solutions

### Environment Setup Issues

**❌ Python not found**
```bash
# AI Diagnosis: Python environment not configured
# Solution: Install Python 3.8+ and add to PATH
python --version
# If fails: Download from python.org and reinstall
```

**❌ Flutter not found**
```bash
# AI Diagnosis: Flutter SDK not installed or not in PATH  
# Solution: Install Flutter SDK
flutter doctor
# Follow Flutter installation guide for your platform
```

**❌ Git not found**
```bash
# AI Diagnosis: Git not installed or not configured
# Solution: Install Git and configure
git --version
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Feature Matrix Issues

**❌ Invalid YAML in feature_matrix.yaml**
```bash
# AI Diagnosis: YAML syntax error in feature matrix
# Solution: Validate and fix YAML syntax
python -c "import yaml; yaml.safe_load(open('feature_matrix.yaml'))"
# Use online YAML validator if needed
```

**⚠️ Feature missing required fields**
```yaml
# AI Solution: Ensure all features have required fields
features:
  - id: "my.feature"           # ✅ Required
    title: "My Feature"        # ✅ Required  
    epic: "Core Features"      # ✅ Required
    status: "planned"          # ✅ Required (planned/in_progress/done/parked)
    priority: "P1"             # ✅ Required (P0/P1/P2/P3)
    description: "..."         # Optional but recommended
    acceptance_criteria: [...] # Optional but recommended
```

**❌ Duplicate feature IDs**
```bash
# AI Diagnosis: Multiple features have the same ID
# Solution: Make all feature IDs unique
python scripts/automation_monitor.py check
# Will list duplicate IDs found
```

### Git Repository Issues

**⚠️ Uncommitted changes in repository**
```bash
# AI Diagnosis: Working directory has uncommitted changes
# Solution: Commit or stash changes before automation
git status
git add .
git commit -m "chore: save work before automation"
# Or stash: git stash push -m "temp work"
```

**⚠️ Not on main branch**
```bash
# AI Diagnosis: Automation should run from main branch
# Solution: Switch to main branch
git checkout main
git pull origin main
```

**⚠️ Unpushed commits detected**
```bash
# AI Diagnosis: Local commits not pushed to remote
# Solution: Push commits or create automation from clean state
git push origin main
# Or reset: git reset --hard origin/main (CAREFUL: loses commits)
```

### Automation Execution Issues

**❌ Feature not found in feature_matrix.yaml**
```bash
# AI Diagnosis: Specified feature ID doesn't exist
# Solution: Check available feature IDs
python scripts/automation_monitor.py check
grep -r "id:" feature_matrix.yaml
```

**❌ Code generation failed**
```bash
# AI Diagnosis: build_runner failed during code generation
# Solution: Clean and regenerate
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

**❌ Tests failing during automation**
```bash
# AI Diagnosis: Generated code doesn't pass tests
# Solution: Check test output and fix issues
flutter test --reporter=verbose
# Common fix: Update golden files
flutter test --update-goldens
```

## 🧠 AI Diagnostic Commands

### Comprehensive Health Check
```bash
python scripts/automation_monitor.py check
# Returns: Environment status, feature matrix validation, git status
# AI provides specific recommendations for each issue
```

### Monitor Feature Implementation
```bash
python scripts/automation_monitor.py monitor --feature-id ui.app_shell
# Real-time monitoring of automation execution
# AI detects and suggests fixes for failures
```

### View Automation Metrics
```bash
python scripts/automation_monitor.py metrics
# Historical success rates, common failures, performance trends
# AI identifies patterns and suggests improvements
```

### JSON Output for Programmatic Use
```bash
python scripts/automation_monitor.py check --json
# Machine-readable output for CI/CD integration
```

## 🎯 AI-Powered Recovery Scenarios

### Scenario 1: Complete Environment Reset
```bash
# AI Guide: Starting fresh after environment issues
git status
git stash push -m "backup before reset"
git checkout main
git pull origin main
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
python scripts/automation_monitor.py check
```

### Scenario 2: Feature Matrix Corruption Recovery
```bash
# AI Guide: Recover from invalid feature matrix
git checkout HEAD -- feature_matrix.yaml  # Reset to last commit
# Or restore from backup
cp feature_matrix.yaml.backup feature_matrix.yaml
python scripts/automation_monitor.py check
```

### Scenario 3: Failed Automation Cleanup
```bash
# AI Guide: Clean up after failed automation
git status
git checkout main  # Abandon feature branch
git branch -D feature/failed-feature-name  # Delete failed branch
git clean -fd  # Remove untracked files (CAREFUL)
python scripts/automation_monitor.py check
```

## 📊 Automation Performance Monitoring

### Real-time Metrics
The AI monitor tracks:
- ✅ Success/failure rates
- ⏱️ Execution duration trends  
- 🔍 Common failure patterns
- 🎯 Performance bottlenecks

### Performance Thresholds
- **Feature Creation**: < 30 seconds (target)
- **Code Generation**: < 15 seconds (target)
- **Test Execution**: < 60 seconds (target)
- **Success Rate**: > 95% (target)

### AI Alerts
The system alerts when:
- Success rate drops below 90%
- Execution time exceeds 2x normal
- Critical environment issues detected
- Repository state becomes inconsistent

## 🔧 Maintenance Commands

### Daily Health Check
```bash
# Run every morning before development
python scripts/automation_monitor.py check
```

### Weekly Deep Check
```bash
# Comprehensive validation and cleanup
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter test
python scripts/automation_monitor.py metrics
```

### Monthly Maintenance
```bash
# Performance optimization and cleanup
git gc  # Cleanup git repository
flutter pub deps  # Check dependency health  
python scripts/automation_monitor.py metrics --json > automation_report.json
```

## 🆘 Emergency Recovery

If automation is completely broken:

1. **Stop all automation**: Cancel any running GitHub Actions
2. **Check environment**: `python scripts/automation_monitor.py check`
3. **Reset to known good state**: `git checkout main && git pull`
4. **Clean rebuild**: `flutter clean && flutter pub get`
5. **Validate**: Run health check again
6. **Gradual restart**: Test with simple feature first

## 💡 AI Tips for Success

1. **Always run health check first**: Catch issues before they cause failures
2. **Keep feature matrix clean**: Regular validation prevents cascading issues
3. **Monitor metrics**: Track trends to identify potential problems early
4. **Use AI diagnostics**: Let the system guide you to solutions
5. **Document custom fixes**: Add to this guide for future reference

## 📞 Getting Help

1. Run `python scripts/automation_monitor.py check` for instant AI diagnosis
2. Check the automation logs in `automation_monitor.log`
3. Use `--json` flag for detailed programmatic output
4. Review the execution metrics for patterns

The AI system learns from each execution and improves its diagnostics over time.
