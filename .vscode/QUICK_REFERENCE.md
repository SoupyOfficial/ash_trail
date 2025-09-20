# AshTrail Development - Quick Reference

## 🎯 Essential Keyboard Shortcuts

| Shortcut | Task | Description |
|----------|------|-------------|
| `Ctrl+Alt+S` | Status | Project status overview |
| `Ctrl+Alt+H` | Health | System health check |
| `Ctrl+Alt+T` | Test Coverage | Run tests with coverage |
| `Ctrl+Alt+D` | Dev Cycle | Full development cycle |
| `Ctrl+Alt+F` | Full Check | Comprehensive project check |
| `Ctrl+Alt+N` | Start Next Feature | Begin next planned feature |
| `Ctrl+Alt+Shift+N` | Start Feature (Dry) | Preview starting next feature |
| `Ctrl+Alt+Shift+F` | Finalize (Dry) | Preview feature finalization |
| `Ctrl+Alt+C` | Analyze Coverage | Detailed coverage analysis |
| `Ctrl+Alt+P` | Patch Coverage | Check coverage of changes |
| `F6` | Flutter Test | Run Flutter tests with coverage |
| `Ctrl+F6` | Flutter Clean | Clean build artifacts |
| `Shift+F6` | Flutter Pub Get | Install dependencies |
| `Ctrl+Alt+Q` | Quality Gate | Pre-commit quality checks |

## 🚀 Common Task Sequences

### Starting New Feature
```
Ctrl+Alt+S (Status) → Ctrl+Alt+Shift+N (Preview) → Ctrl+Alt+N (Start)
```

### Development Cycle
```
Code Changes → Ctrl+Alt+D (Dev Cycle) → Ctrl+Alt+Q (Quality Gate)
```

### Coverage Analysis
```
F6 (Test) → Ctrl+Alt+C (Analyze) → Ctrl+Alt+P (Patch Check)
```

### Feature Completion
```
Ctrl+Alt+Shift+F (Preview) → Finalize Feature Task → Commit
```

## 📋 Task Categories

### 🏥 **Health & Status**
- Dev Assistant: Status
- Dev Assistant: Health Check
- Dev Assistant: Full Check

### 🧪 **Testing & Coverage**  
- Dev Assistant: Test Coverage
- Analyze Coverage
- Patch Coverage Check
- Flutter Test with Coverage

### ⚡ **Development Workflow**
- Dev Assistant: Dev Cycle
- Dev Assistant: Dev Cycle (Upload)
- Dev Assistant: Dev Cycle (Skip Tests)

### 🎯 **Feature Management**
- Dev Assistant: Start Next Feature
- Dev Assistant: Finalize Feature
- Detect Feature Status: Suggest Next
- Detect Feature Status: Top 5

### 🛠️ **Build & Setup**
- Flutter Clean / Pub Get / Build Runner
- Generate Development Scripts
- Setup Development Environment

### ✅ **Quality Assurance**
- Quality Gate
- Pre-commit Hook
- License Check
- Docs Integrity Check

## 🐛 Debug Configurations

Access via `F5` or Debug panel:
- **Flutter: Run App** - Debug Flutter application
- **Python: Dev Assistant (Command)** - Debug any dev assistant command
- **Python: Analyze Coverage** - Debug coverage analysis
- **Python: Detect Feature Status** - Debug feature detection

## 💡 Pro Tips

1. **Quick Task Access**: `Ctrl+Shift+P` → "Tasks: Run Task"
2. **Recent Tasks**: `Ctrl+Shift+P` → "Tasks: Rerun Last Task"
3. **Terminal History**: Use up/down arrows in terminal for command history
4. **JSON Output**: Add `--json` to most Python scripts for machine-readable output
5. **Dry Run**: Always available for major operations (use `--dry-run`)
6. **Environment**: Check `.env` file for environment variable configuration

## 🔧 Troubleshooting

| Issue | Solution |
|-------|----------|
| Python task fails | Check `python --version` in terminal |
| Flutter task fails | Run `flutter doctor` to diagnose |
| Coverage missing | Run tests first with `F6` |
| Tool not found | Set `DEV_ASSISTANT_SKIP_TOOL_CHECKS=1` in .env |
| Task not found | Reload VS Code window (`Ctrl+Shift+P` → "Reload Window") |

## 📂 Key Files

- `.vscode/tasks.json` - All task definitions
- `.vscode/launch.json` - Debug configurations  
- `.vscode/settings.json` - VS Code workspace settings
- `.vscode/keybindings.json` - Custom keyboard shortcuts
- `.env` - Environment variables (create if missing)

## 🌐 Resources

- **Feature Matrix**: `feature_matrix.yaml` - Source of truth for all features
- **Scripts Directory**: `scripts/` - All automation scripts
- **Coverage Reports**: `coverage/` - Generated test coverage data
- **Automation Sessions**: `automation_sessions/` - Development session logs