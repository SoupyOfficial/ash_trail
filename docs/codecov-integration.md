# Codecov Integration for AshTrail

## Overview

Codecov provides comprehensive coverage analysis and reporting for AshTrail, helping maintain code quality through detailed metrics and component-based tracking.

## Configuration

### Component-Based Coverage
Our Codecov configuration tracks coverage across multiple dimensions:

#### Architecture Layers
- **Core Infrastructure**: 85% target (critical foundation code)
- **Domain Logic**: 90% target (business logic must be thoroughly tested)
- **Data Layer**: 85% target (data operations and persistence)
- **Presentation Layer**: 70% target (UI components, more challenging to test)
- **Use Cases**: 95% target (critical business workflows)

#### Feature Components
- **Logging Feature**: 80% target
- **Accounts Feature**: 80% target  
- **App Shell & Navigation**: 75% target
- **Telemetry**: 70% target (more lenient for observability code)

### Coverage Standards
- **Project Overall**: 80% target
- **New Code (Patch)**: 75% target
- **Precision**: 2 decimal places
- **Threshold**: 1-3% depending on component criticality

## Local Coverage Workflow

### Generate Coverage Report
```bash
# Run tests with coverage
flutter test --coverage

# Generate HTML report (optional)
genhtml coverage/lcov.info -o coverage/html

# Open report in browser
start coverage/html/index.html  # Windows
open coverage/html/index.html   # macOS
```

### Coverage Analysis
```bash
# Check coverage using our development assistant
python scripts/dev_assistant.py coverage

# Upload to Codecov (if CODECOV_TOKEN available)
codecov -f coverage/lcov.info
```

## CI/CD Integration

### Automated Upload
Coverage is automatically uploaded to Codecov in CI/CD pipelines:
```yaml
- name: Upload coverage to Codecov
  uses: codecov/codecov-action@v3
  with:
    file: coverage/lcov.info
    flags: flutter_tests
    name: codecov-umbrella
    fail_ci_if_error: true
```

### PR Comments
Codecov automatically comments on PRs with:
- Coverage diff for changed files
- Component-level coverage status
- Overall project impact
- Sunburst visualization links

## Quality Gates

### PR Requirements
- [ ] Overall coverage must not decrease below threshold
- [ ] New code must meet patch coverage targets
- [ ] Component-specific targets must be maintained
- [ ] Critical components (domain, core) have stricter requirements

### Component Standards
- **Domain Layer** (90%): Business logic requires comprehensive testing
- **Core Infrastructure** (85%): Foundation code must be reliable
- **Data Layer** (85%): Persistence and sync operations are critical
- **Use Cases** (95%): User workflows must be thoroughly validated
- **Presentation** (70%): UI components, balanced with testing complexity

## Monitoring & Reporting

### Codecov Dashboard
Access detailed reports at: https://codecov.io/gh/SoupyOfficial/ash_trail

### Key Metrics
- **Coverage Trends**: Track coverage over time
- **Component Health**: Monitor individual component coverage
- **Hot Spots**: Identify untested critical code
- **File Impact**: See which files need attention

### Sunburst Visualization
Interactive visualization showing:
- Directory structure with coverage overlay
- File-level coverage percentages
- Visual identification of coverage gaps

## Development Workflow Integration

### Before Committing
```bash
# Run coverage check
flutter test --coverage

# Verify coverage meets standards
python scripts/dev_assistant.py coverage

# Fix any coverage gaps
# Commit only when coverage standards are met
```

### During Code Review
1. Check Codecov PR comment for coverage impact
2. Review coverage diff for changed files
3. Ensure component targets are maintained
4. Verify critical paths are tested

### After Merge
1. Monitor coverage trends on Codecov dashboard
2. Address any long-term coverage degradation
3. Update coverage targets if architecture changes

## Troubleshooting

### Common Issues

**Coverage not uploaded**
- Check CODECOV_TOKEN is configured
- Verify lcov.info file exists and has content
- Check network connectivity in CI environment

**Low coverage warnings**
- Identify untested files with `python scripts/dev_assistant.py coverage`
- Focus on critical components first (domain, core)
- Add unit tests for business logic
- Add widget tests for UI components

**False coverage gaps**
- Check ignore patterns in codecov.yml
- Verify generated files are properly excluded
- Update component paths if needed

### Coverage Improvement Strategies

**For Domain Layer**:
- Test all use case scenarios (happy path + edge cases)
- Mock external dependencies properly
- Test error handling paths

**For Data Layer**:
- Test repository implementations with fake data
- Test offline/online scenarios
- Test sync operations and conflict resolution

**For Presentation Layer**:
- Focus on key user interactions
- Test state management scenarios
- Use golden tests for visual components

## Integration with AI Development

### Coverage in Feature Requests
When requesting features with the AI trigger:
```
#github-pull-request_copilot-coding-agent

Technical Requirements:
- Achieve component-specific coverage targets
- Include comprehensive test suite (unit + widget + integration)
- Verify coverage before submitting PR
```

### AI Implementation Standards
- AI must write tests that meet coverage requirements
- Tests should focus on critical business logic first
- UI tests should cover key interactions and error states
- Coverage reports guide test completeness

### Quality Feedback Loop
1. AI implements feature with tests
2. Coverage report identifies gaps
3. AI adds additional tests to meet targets
4. Codecov validates final coverage before merge

---

This Codecov integration ensures consistent code quality while providing actionable insights for continuous improvement.
