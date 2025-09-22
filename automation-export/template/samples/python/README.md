# Hello World Python Sample

Simple Python application for testing the automation template.

## Structure

- `hello_world.py` - Main application module
- `test_hello_world.py` - Test suite with pytest
- `pyproject.toml` - Python project configuration

## Features

- Type hints and validation
- Comprehensive error handling  
- Full test coverage with pytest
- Linting with ruff and black
- Type checking with mypy

## Usage

```bash
# Install dependencies
pip install -e ".[dev]"

# Run application
python hello_world.py

# Run tests
pytest

# Run with coverage
pytest --cov

# Run linting
ruff check .
black --check .

# Run type checking
mypy .
```

## Testing Template Integration

This sample validates:
- ✅ Language detection (Python)
- ✅ Dependency installation (pip/pyproject.toml)
- ✅ Testing framework integration (pytest)
- ✅ Coverage reporting (pytest-cov)
- ✅ Linting integration (ruff, black)
- ✅ Type checking (mypy)
- ✅ Build system (hatchling)

## Coverage Target

Maintains >95% test coverage to validate automation thresholds.
