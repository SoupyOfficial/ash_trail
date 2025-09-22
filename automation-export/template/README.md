# Development Automation Template

**Framework-Agnostic Development Assistant Extracted from AshTrail Project**

This template provides comprehensive development workflow automation including the primary features from AshTrail's dev assistant: **start-next-feature**, **finalize-feature**, and **critical coverage analysis** capabilities.

## 🚀 Quick Start

1. **Copy template to your project**:
   ```bash
   cp -r automation-export/template/* your-project/
   ```

2. **Configure your project**:
   ```bash
   # Edit feature matrix to define your features
   vim feature_matrix.yaml
   
   # Adjust automation settings
   vim automation.config.yaml
   ```

3. **Initialize development workflow**:
   ```bash
   # Check project health
   python scripts/dev_assistant.py health
   
   # Start developing the next planned feature
   python scripts/dev_assistant.py start-next-feature
   ```

## 📁 Template Structure

```
template/
├── scripts/
│   ├── dev_assistant.py          # 🔧 Main workflow coordinator
│   ├── analyze_coverage.py       # 📊 Multi-format coverage analysis  
│   └── scaffold_feature.py       # 🏗️ Language-specific scaffolding
├── .vscode/
│   ├── tasks.json                # 🎯 VS Code task integration
│   ├── settings.json             # ⚙️ Editor configuration
│   └── keybindings.json          # ⌨️ Keyboard shortcuts
├── docs/
│   └── workflow-guide.md         # 📖 Comprehensive usage guide
├── automation.config.yaml        # 🔧 Project configuration
└── feature_matrix.yaml          # 📋 Feature roadmap template
```

## 🎯 Core Features (Extracted from AshTrail)

### 1. **Start Next Feature** 
```bash
python scripts/dev_assistant.py start-next-feature
```
- ✅ Auto-selects highest priority planned feature
- ✅ Creates feature branch (`feature/feature-name`)
- ✅ Scaffolds language-specific file structure
- ✅ Updates feature status to "in_progress"
- ✅ Commits initial scaffold

### 2. **Finalize Feature**
```bash
python scripts/dev_assistant.py finalize-feature
```
- ✅ Validates coverage thresholds (≥80% global, ≥85% patch)
- ✅ Runs all quality gates (tests, linting, security)
- ✅ Checks acceptance criteria completion
- ✅ Updates feature status to "done"
- ✅ Optionally merges and cleans branches

### 3. **Coverage Analysis** (Critical Component)
```bash
python scripts/analyze_coverage.py --html --trends
```
- ✅ **Multi-format support**: LCOV, JSON (NYC/Istanbul), XML (JaCoCo/Cobertura), Go, Rust
- ✅ **HTML reporting** with file-level breakdown
- ✅ **Trend analysis** and historical tracking
- ✅ **CI integration** with threshold validation
- ✅ **Language detection** for automatic format selection

## 🌍 Language Support

| Language    | Test Framework | Coverage Format | Scaffolding |
|-------------|----------------|-----------------|-------------|
| **Python**     | pytest         | LCOV            | ✅          |
| **JavaScript** | Jest           | NYC/JSON        | ✅          |
| **TypeScript** | Jest           | NYC/JSON        | ✅          |
| **Java**       | JUnit/Maven    | JaCoCo XML      | ✅          |
| **Go**         | go test        | coverage.out    | ✅          |
| **Rust**       | cargo test     | Tarpaulin LCOV  | ✅          |

## 📊 Dev Assistant Commands

### Status & Health
```bash
python scripts/dev_assistant.py status        # Project overview
python scripts/dev_assistant.py health        # Environment validation
python scripts/dev_assistant.py features      # Feature listing
```

### Development Workflow  
```bash
python scripts/dev_assistant.py dev-cycle     # Full development cycle
python scripts/dev_assistant.py coverage      # Coverage analysis
python scripts/dev_assistant.py upload-coverage # Upload to Codecov
python scripts/dev_assistant.py full-check    # Comprehensive validation
```

### Feature Management
```bash
python scripts/scaffold_feature.py python user_auth --epic core
python scripts/dev_assistant.py start-next-feature --feature user_auth
python scripts/dev_assistant.py finalize-feature
```

## 🎯 VS Code Integration

### Tasks (Ctrl+Shift+P → "Tasks: Run Task")
- **Dev Assistant: Start Next Feature** - Begin next planned feature
- **Dev Assistant: Finalize Feature** - Complete current feature
- **Dev Assistant: Coverage Analysis** - Generate coverage reports
- **Dev Assistant: Dev Cycle** - Full development validation

### Keyboard Shortcuts
- **Ctrl+Shift+D S** - Status overview
- **Ctrl+Shift+D N** - Start next feature  
- **Ctrl+Shift+D F** - Finalize feature
- **Ctrl+Shift+C A** - Coverage analysis
- **F6** - Dev cycle
- **F7** - Tests with coverage

## 📋 Feature Matrix System

Define your project roadmap in `feature_matrix.yaml`:

```yaml
features:
  user_authentication:
    name: "User Authentication"
    epic: "core"
    status: "planned"          # → "in_progress" → "done"
    priority: 1
    dependencies: []
    acceptance_criteria:
      - "Users can register and login"
      - "Session management works"
    test_coverage:
      target: 90
      current: 0
```

## 📈 Coverage Analysis Features

### Multi-Format Support
```bash
# Auto-detect and analyze any format
python scripts/analyze_coverage.py

# Specific format analysis
python scripts/analyze_coverage.py --format lcov --file coverage/lcov.info
python scripts/analyze_coverage.py --format json --file coverage/coverage-final.json
python scripts/analyze_coverage.py --format xml --file target/site/jacoco/jacoco.xml
```

### CI Integration
```bash
# Validate thresholds (exits with error if below)
python scripts/analyze_coverage.py --ci --threshold 80 --patch-threshold 85

# Generate reports for CI artifacts
python scripts/analyze_coverage.py --html --json-output --save-history
```

### Trending & History
```bash
# Track coverage over time
python scripts/analyze_coverage.py --trends --save-history

# Generate comprehensive HTML report
python scripts/analyze_coverage.py --html
# Opens: coverage/html/index.html
```

## 🔧 Configuration

### automation.config.yaml
```yaml
# Dev assistant commands
dev_assistant:
  commands:
    start_next_feature:
      enabled: true
      create_branch: true
      branch_prefix: "feature/"
    
    finalize_feature:
      enabled: true
      checks: ["coverage_threshold", "tests_passing", "linting_clean"]

# Coverage thresholds  
coverage:
  global_threshold: 80
  patch_threshold: 85
```

### Language Detection
Automatically detects project type from:
- `package.json` → Node.js/JavaScript
- `pyproject.toml`/`requirements.txt` → Python  
- `pom.xml`/`build.gradle` → Java
- `go.mod` → Go
- `Cargo.toml` → Rust

## 🏗️ Feature Scaffolding

Generate language-specific feature structure:

```bash
# Python feature
python scripts/scaffold_feature.py python user_auth --epic core

# JavaScript/React feature
python scripts/scaffold_feature.py javascript dashboard --epic ui

# Java feature  
python scripts/scaffold_feature.py java notification-service --epic integration
```

Creates complete feature structure with:
- ✅ Models/entities
- ✅ Services/business logic
- ✅ Views/components (language-appropriate)
- ✅ Unit tests
- ✅ Integration tests
- ✅ Feature matrix entry

## 🚦 Quality Gates

All features must pass quality gates during finalization:

1. **Tests Passing** - All unit and integration tests pass
2. **Coverage Threshold** - Meets configured coverage requirements  
3. **Linting Clean** - Code formatting and style compliance
4. **Dependencies Resolved** - No missing or conflicting dependencies
5. **Security Check** - Basic vulnerability scanning

## 📚 Documentation

- **[Workflow Guide](docs/workflow-guide.md)** - Complete usage documentation
- **[Codecov Integration](docs/codecov-integration.md)** - Coverage reporting setup
- **[AI Assistance Guide](docs/ai-assistance-guide.md)** - Comprehensive AI prompts and examples
- **[AI Quick Prompts](docs/ai-quick-prompts.md)** - Ready-to-use prompt templates
- **[AI Prompt Templates](docs/ai-prompt-templates.md)** - Copy-paste templates for documentation generation
- **Feature Matrix** - In-code examples and patterns
- **Automation Config** - Configuration reference with examples

## 🤖 AI Agent Integration

Generate comprehensive project documentation using AI assistance:

### Quick Start with AI
```bash
# Use provided prompts to generate your feature matrix
# Copy templates from docs/ai-prompt-templates.md
# Customize for your project domain and technology stack
```

### AI-Generated Documentation
- ✅ **Feature Matrix** - Complete project roadmap with realistic estimates
- ✅ **API Documentation** - OpenAPI/GraphQL specs with examples
- ✅ **Domain Models** - Entity definitions with relationships and validation
- ✅ **Design Documents** - UI/UX and system architecture specifications
- ✅ **Migration Plans** - Legacy system modernization strategies

### Available AI Templates
- **Web Applications** - React, Vue, Angular with backend APIs
- **Mobile Apps** - React Native, Flutter, native iOS/Android
- **API Services** - REST, GraphQL, microservices architectures
- **E-commerce Platforms** - Full-featured online store systems
- **Healthcare Systems** - HIPAA-compliant medical applications
- **Legacy Migration** - Modernization planning and execution

See **[AI Prompt Templates](docs/ai-prompt-templates.md)** for copy-paste ready prompts.

## 📊 Codecov Integration

Automated coverage reporting with comprehensive multi-language support:

### Quick Setup
```bash
# Interactive setup (recommended)
python scripts/setup_codecov.py --interactive

# Direct setup
python scripts/setup_codecov.py --repo owner/repo
```

### Usage
```bash
# Upload coverage after tests
python scripts/dev_assistant.py upload-coverage

# Upload with custom flags
python scripts/dev_assistant.py upload-coverage --flags python unit

# Validate configuration
python scripts/setup_codecov.py --validate
```

### Features
- ✅ **Multi-language support** - Python, Java, Node.js, Go, Rust, C#, Flutter
- ✅ **Automatic CI integration** - GitHub Actions workflow with coverage upload
- ✅ **Pull request comments** - Coverage reports on PRs
- ✅ **Quality gates** - 80% global, 85% patch coverage thresholds
- ✅ **Comprehensive configuration** - `codecov.yml` with language-specific flags

See **[Codecov Integration Guide](docs/codecov-integration.md)** for complete setup and usage documentation.

## 🎯 Key Differentiators

### From AshTrail Extraction
- **Battle-tested** - Extracted from production Flutter project with 80%+ coverage
- **Feature-driven** - Built around feature matrix workflow management
- **Multi-language** - Generalized from Flutter-specific to framework-agnostic
- **Quality-focused** - Enforces coverage thresholds and quality gates

### Advanced Coverage Analysis
- **Multi-format parsing** - LCOV, JSON, XML, Go, Rust coverage formats
- **Historical tracking** - Coverage trends over time
- **CI-ready** - Exit codes and JSON output for automation
- **Visual reporting** - HTML reports with file-level breakdown

### VS Code Integration  
- **Complete task integration** - All dev assistant commands as VS Code tasks
- **Keyboard shortcuts** - Efficient workflow navigation
- **Language detection** - Auto-configures based on project type
- **Problem matchers** - Integrated error reporting

## 🔄 Typical Workflow

1. **Define features** in `feature_matrix.yaml`
2. **Start development**: `python scripts/dev_assistant.py start-next-feature`
3. **Write code** using scaffolded structure
4. **Continuous validation**: `python scripts/dev_assistant.py dev-cycle`
5. **Coverage analysis**: `python scripts/analyze_coverage.py --html`  
6. **Complete feature**: `python scripts/dev_assistant.py finalize-feature`
7. **Repeat** for next feature

## 📄 License

Same as AshTrail project. See template files for implementation details.

---

**This template includes the primary dev assistant features (start-next-feature, finalize-feature) and critical coverage analysis exactly as requested, generalized for multi-language use.**
