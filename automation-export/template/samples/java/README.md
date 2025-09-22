# Hello World Java Sample

Simple Java application for testing the automation template.

## Structure

- `src/main/java/com/example/helloworld/HelloWorld.java` - Main application class
- `src/test/java/com/example/helloworld/HelloWorldTest.java` - JUnit 5 test suite
- `pom.xml` - Maven project configuration

## Features

- Java 17 with Maven build system
- Comprehensive error handling
- Full test coverage with JUnit 5
- Code formatting with Spotless (Google Java Format)
- Coverage reporting with JaCoCo

## Usage

```bash
# Compile project
mvn compile

# Run application
mvn exec:java -Dexec.mainClass="com.example.helloworld.HelloWorld"

# Run tests
mvn test

# Run with coverage
mvn test jacoco:report

# Check code formatting
mvn spotless:check

# Apply code formatting
mvn spotless:apply

# Full build
mvn clean package
```

## Testing Template Integration

This sample validates:
- ✅ Language detection (Java)
- ✅ Dependency management (Maven/pom.xml)
- ✅ Testing framework integration (JUnit 5)
- ✅ Coverage reporting (JaCoCo)
- ✅ Code formatting (Spotless)
- ✅ Build system (Maven)

## Coverage Target

Maintains >90% test coverage to validate automation thresholds.
