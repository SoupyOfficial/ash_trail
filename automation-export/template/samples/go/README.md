# Hello World Go Sample

Simple Go application for testing the automation template.

## Structure

- `main.go` - Main application with hello world functionality
- `main_test.go` - Comprehensive test suite with benchmarks and examples
- `go.mod` - Go module configuration

## Features

- Go 1.21 with modules
- Comprehensive error handling with custom error types
- Full test coverage with table-driven tests
- Benchmark tests for performance validation
- Example tests for documentation
- Panic-safe and panic-unsafe variants

## Usage

```bash
# Run application
go run main.go

# Run tests
go test

# Run tests with coverage
go test -cover

# Run tests with detailed coverage
go test -coverprofile=coverage.out
go tool cover -html=coverage.out

# Run benchmarks
go test -bench=.

# Run specific test
go test -run TestHelloWorld

# Build executable
go build -o hello-world

# Format code
go fmt

# Vet code
go vet

# Get dependencies
go mod tidy
```

## Testing Template Integration

This sample validates:
- ✅ Language detection (Go)
- ✅ Dependency management (go.mod)
- ✅ Testing framework integration (go test)
- ✅ Coverage reporting (go test -cover)
- ✅ Code formatting (go fmt)
- ✅ Static analysis (go vet)
- ✅ Build system (go build)

## Coverage Target

Maintains >90% test coverage with comprehensive test scenarios including error cases and edge conditions.
