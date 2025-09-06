# AshTrail Development Assistant - Quick Reference

## 🚀 Essential Commands

### Daily Workflow
```bash
# Morning health check
python scripts/dev_assistant.py health

# Check project status
python scripts/dev_assistant.py status

# Run complete development cycle (test + coverage + upload)
python scripts/dev_assistant.py dev-cycle
```

### Coverage & Testing
```bash
# Generate and analyze coverage
python scripts/dev_assistant.py test-coverage

# Test Codecov integration
python scripts/dev_assistant.py test-codecov

# Upload coverage to Codecov
python scripts/dev_assistant.py upload-codecov
```

### Setup & Configuration
```bash
# Setup Codecov token (one-time)
python scripts/dev_assistant.py setup-token

# Comprehensive environment check
python scripts/dev_assistant.py full-check

# View feature matrix status
python scripts/dev_assistant.py features
```

## 📊 Coverage Targets

| Component | Target | Status |
|-----------|--------|--------|
| Overall Project | 80% | 🎯 Enforced |
| Domain Layer | 90% | 🎯 Enforced |
| Core Features | 85% | 📊 Tracked |
| New Code | 85% | 🔍 Monitored |

## 🔧 Setup Checklist

- [ ] Flutter SDK installed and in PATH
- [ ] Python 3.11+ installed
- [ ] Codecov CLI installed (`npm install -g codecov`)
- [ ] CODECOV_TOKEN environment variable set (optional)
- [ ] Repository cloned and dependencies installed

## ⚡ Quick Troubleshooting

| Issue | Solution |
|-------|----------|
| "Flutter not found" | Add Flutter to PATH or reinstall |
| "Codecov CLI not found" | Run `npm install -g codecov` |
| "Coverage file missing" | Run `flutter test --coverage` first |
| "Upload failed" | Check token with `setup-token` command |
| "Tests failing" | Run `flutter analyze` and fix issues |

## 🎯 AI Development Triggers

Use in commit messages to trigger AI assistance:

```bash
#github-pull-request_copilot-coding-agent

Title: [FEATURE] Your Feature Name
Epic: Epic Name
Priority: P0|P1|P2|P3
```

## 📈 Performance Tips

- Use `health` for quick checks (2-5s)
- Use `dev-cycle` for comprehensive validation (60-120s)
- Run `full-check` before major commits
- Cache Flutter dependencies for faster testing

## 🔗 Key Files

- `scripts/dev_assistant.py` - Main automation script
- `docs/local-automation-guide.md` - Detailed documentation
- `.github/instructions/development-workflow.md` - AI workflow guide
- `codecov.yml` - Coverage configuration
- `feature_matrix.yaml` - Feature definitions
