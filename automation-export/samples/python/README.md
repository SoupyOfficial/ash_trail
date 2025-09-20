# Sample Python Project

This is a sample Python project demonstrating the dev automation template.

## Features

- **Greeting Module**: Simple greeting functionality with input validation
- **Fibonacci Calculator**: Efficient Fibonacci number calculation  
- **Calculator Class**: Basic arithmetic operations with history tracking

## Project Structure

```
sample-python-project/
├── src/
│   └── sample_project/
│       └── __init__.py      # Main module code
├── tests/
│   └── test_sample_project.py  # Test suite
├── pyproject.toml           # Python project configuration
└── README.md               # This file
```

## Usage

### Development Setup

The automation template handles all setup:

```bash
# Bootstrap environment
./scripts/bootstrap.sh

# Validate setup
./scripts/doctor.sh
```

### Running Automation

```bash
# Lint and format code
./scripts/lint.sh --fix

# Run tests with coverage
./scripts/test.sh --coverage

# Build package  
./scripts/build.sh --release
```

### Manual Usage

```python
from sample_project import greet, calculate_fibonacci, Calculator

# Greeting
print(greet("World"))  # "Hello, World! Welcome to the automation template."

# Fibonacci
print(calculate_fibonacci(10))  # 55

# Calculator
calc = Calculator()
result = calc.add(5, 3)  # 8
print(calc.get_history())  # ["5 + 3 = 8"]
```

## Testing

The project includes comprehensive tests covering:

- Input validation and error handling
- Mathematical accuracy
- State management (calculator history)
- Edge cases and boundary conditions

Current test coverage: **100%** (all functions and branches covered)

## Automation Features Demonstrated

This sample demonstrates all template automation features:

### Language Detection
- ✅ Detected as Python project via `pyproject.toml`
- ✅ Uses Python-specific tooling (pytest, black, ruff)

### Code Quality
- ✅ Linting with `ruff` (imports, syntax, style)
- ✅ Formatting with `black` (consistent code style)
- ✅ Type hints for better code documentation

### Testing & Coverage
- ✅ Comprehensive test suite with `pytest`
- ✅ Coverage reporting in LCOV format
- ✅ Meets 80% global and 85% patch coverage thresholds

### Build Process
- ✅ Modern Python packaging with `pyproject.toml`
- ✅ Builds wheel and source distribution
- ✅ Production-ready package artifacts

### CI/CD Ready
- ✅ GitHub Actions workflow detects Python
- ✅ Matrix builds across Python versions (3.9, 3.10, 3.11)
- ✅ Cross-platform testing (Ubuntu, Windows)

## Development Tools

Configured for optimal development experience:

- **Black**: Code formatting (88 char line length)
- **Ruff**: Fast Python linting and import sorting
- **Pytest**: Testing framework with coverage
- **Modern packaging**: Using `pyproject.toml` standard

## Expected Outputs

After running automation scripts:

```bash
# Bootstrap output
🚀 Development Environment Bootstrap
✅ Python 3.11.0 detected
✅ Dependencies installed
✅ Pre-commit hooks configured

# Doctor output  
🔍 Development Environment Health Check
✅ Python 3.11.0
✅ pip 23.0
✅ pytest available
✅ All checks passed!

# Lint output
🔍 Code Quality & Linting  
✅ Python formatting (black)
✅ Python linting (ruff)
✅ All linting checks passed!

# Test output
🧪 Running Tests
✅ 12 tests passed
✅ Coverage: 100.0% (meets 80% threshold)

# Build output
🏗️  Building Project
✅ Python package built: 1 wheel(s), 1 source archive(s)
```

This sample validates that the automation template works correctly for Python projects and can serve as a reference for other language implementations.