# Contributing to AshTrail

This file explains quick, practical steps for contributors and maintainers to use the repository's automation and GitHub Actions.

## Quick links
- Actions: GitHub -> Actions
- Feature matrix: `feature_matrix.yaml`
- Copilot instructions: `.github/copilot-instructions.md`

## Key Actions and how to use them

### Automated (scheduled)
- **CI** (`flutter-ci`): runs on every PR/push with analysis, tests, coverage, and artifact validation
- **Feature Matrix** (`Generate Artifacts`): validates feature matrix schema and regenerates code
- **Nightly Coverage** (`Nightly Coverage`): runs daily at 04:00 UTC, uploads coverage to Codecov
- **Automation Monitor** (`Automation Monitor`): daily health checks at 03:17 UTC, files issues on critical problems
- **Issue Sync** (`Sync Feature Issues`): syncs GitHub issues from feature matrix daily at 02:17 UTC

### Manual dispatch
- **Trigger Nightly Coverage**: manually triggers the nightly coverage workflow
- **Sync Labels**: synchronizes repository labels from `.github/labels.yml`
- **Codecov Status Report**: fetches and displays Codecov summary for latest commit
- **Auto Implement Feature**: scaffolds and implements features using GitHub Copilot agent
- **PR Body Linter**: validates PRs have proper Copilot/AI disclosure

## PR rules
- Use the PR template when creating PRs - it includes required checklists and Copilot disclosure
- If PR contains Copilot/AI-assisted changes: check the disclosure box OR add label `copilot-assisted`
- CI must pass (analysis, tests, coverage ≥80%, no artifact drift) before merging
- Docs-only PRs can skip Copilot disclosure by including "docs only" in description

## Local development setup
1. **Install Flutter**: version 3.29.2 (pinned for CI consistency)
2. **Install Python**: 3.11+ with dependencies:
   ```bash
   pip install -r requirements.txt
   # Or manually: pip install pyyaml requests jsonschema
   ```
3. **Get Flutter deps**: `flutter pub get`
4. **Verify environment**: `flutter doctor` and `python scripts/automation_monitor.py check`

## Before opening a PR
1. **Regenerate code** if you changed `feature_matrix.yaml`:
   - Windows: `scripts\dev_generate.bat`
   - macOS/Linux: `./scripts/dev_generate.sh`
2. **Run tests**: `flutter test --coverage`
3. **Check analysis**: `dart analyze`
4. **Verify no drift**: `git status` should show only intended changes

## Troubleshooting
- **CI failures**: Check artifact `automation-monitor-result` in failed runs for diagnostics
- **Coverage issues**: Run `Trigger Nightly Coverage` then `Codecov Status Report` to verify upload
- **Generated code drift**: Run `scripts\dev_generate.bat` (Windows) or `./scripts/dev_generate.sh` (macOS/Linux)
- **Monitor issues**: Check automation monitor issues (labeled `automation-monitor`) and linked artifacts
- **Copilot errors**: Ensure PR has disclosure checkbox checked or `copilot-assisted` label

## Automation monitoring
The automation monitor (`scripts/automation_monitor.py`) can be run locally:
```bash
# Health check
python scripts/automation_monitor.py check

# Get metrics  
python scripts/automation_monitor.py metrics

# Interactive dashboard
python scripts/automation_dashboard.py
```

## Maintainer notes
- **Label management**: Edit `.github/labels.yml` and push to sync labels automatically
- **Branch protection**: Ensure required status checks include `flutter-ci` and `codecov/project`
- **Secrets**: `CODECOV_TOKEN` and `GITHUB_TOKEN` are required; avoid embedding tokens in files
- **Workflow naming**: Keep display names in workflows consistent with CONTRIBUTING.md descriptions

## Getting help
- Review `.github/copilot-instructions.md` for AI-assisted development guidance
- Check `docs/` for architecture decisions and data model documentation
- Use `@github #workspace` in Copilot Chat for project-specific questions

Thank you for contributing!
