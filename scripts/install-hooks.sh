#!/bin/bash
# Install Git hooks for Flutter project
# This script copies the hooks from scripts/git-hooks to .git/hooks

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="$SCRIPT_DIR/git-hooks"
GIT_HOOKS_DIR="$SCRIPT_DIR/../.git/hooks"

echo "📦 Installing Git hooks..."

# Check if .git directory exists
if [ ! -d "$GIT_HOOKS_DIR" ]; then
    echo "❌ .git/hooks directory not found. Are you in a Git repository?"
    exit 1
fi

# Copy and make hooks executable
for hook in "$HOOKS_DIR"/*; do
    hook_name=$(basename "$hook")
    echo "Installing $hook_name..."
    cp "$hook" "$GIT_HOOKS_DIR/$hook_name"
    chmod +x "$GIT_HOOKS_DIR/$hook_name"
done

echo "✅ Git hooks installed successfully!"
echo ""
echo "Installed hooks:"
echo "  - pre-commit: Runs flutter analyze and flutter test"
echo "  - pre-push: Runs flutter build ios (for main/mvp branches)"
echo ""
echo "To skip hooks temporarily, use: git commit --no-verify"
