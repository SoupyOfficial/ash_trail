# Git Hooks for Ash Trail

This directory contains Git hooks to ensure code quality and catch build issues early.

## Available Hooks

### pre-commit
Runs before each commit:
- ✅ `flutter analyze` - Catches linting and static analysis issues
- ✅ `flutter test` - Ensures all tests pass

### pre-push
Runs before pushing to `main` or `mvp` branches:
- ✅ `flutter build ios --release --no-codesign` - Verifies iOS build succeeds

This catches issues like:
- iOS deployment target mismatches
- Missing iOS dependencies
- Platform-specific compilation errors
- Code signing configuration issues (without requiring certificates)

## Installation

Run from the project root:

```bash
bash scripts/install-hooks.sh
```

Or install manually:

```bash
cp scripts/git-hooks/* .git/hooks/
chmod +x .git/hooks/*
```

## Skipping Hooks

If you need to skip hooks temporarily (not recommended):

```bash
git commit --no-verify
git push --no-verify
```

## Why These Hooks?

### Pre-commit Benefits
- Catches simple errors before they're committed
- Keeps git history clean with passing tests
- Fast feedback loop (usually < 30 seconds)

### Pre-push Benefits
- Catches iOS build issues before CI/CD
- Prevents failed TestFlight deployments
- Saves CI/CD minutes and time waiting for build failures
- Takes 2-5 minutes but runs less frequently than commits

## Customization

You can modify the hooks in `scripts/git-hooks/` and reinstall them with:

```bash
bash scripts/install-hooks.sh
```

## Troubleshooting

**Hook not running?**
- Ensure hooks are executable: `chmod +x .git/hooks/*`
- Check hook is in `.git/hooks/` directory
- Verify hook file has no extension

**iOS build too slow?**
- Consider removing iOS build from pre-push for faster iteration
- Or only enable on main branch pushes

**Tests failing?**
- Fix the tests! Hooks are protecting you from bad commits
- Or use `--no-verify` if you know what you're doing
