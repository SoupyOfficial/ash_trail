# Workflow Optimization Plan

## Issues Identified

### 1. Workflow Duplication
- `ci.yaml` vs `ci.yml` - Two CI workflows doing similar things
- `feature_diff.yml` vs `feature-matrix.yml` diff job - Duplicate PR diff functionality  
- `generate.yml` vs `ci.yml` generation steps - Duplicate artifact generation

### 2. Coverage Inconsistency
- `ci.yaml` uses 80% threshold with Dart script
- `ci.yml` uses 70% threshold with shell script
- Both upload to codecov but different implementations

### 3. Missing Codecov Integration
- `auto-implement-feature.yml` doesn't include coverage upload
- No codecov configuration file for proper settings

## Optimization Strategy

### Phase 1: Consolidate CI Workflows
1. **Keep**: `ci.yml` (more comprehensive)
2. **Remove**: `ci.yaml` (simpler, older version)
3. **Update**: Standardize coverage threshold to 80%

### Phase 2: Remove Duplicate Workflows  
1. **Remove**: `feature_diff.yml` (functionality exists in `feature-matrix.yml`)
2. **Remove**: `generate.yml` (functionality exists in `ci.yml`)

### Phase 3: Enhance Automation Workflow
1. **Add**: Coverage collection to `auto-implement-feature.yml`
2. **Add**: Codecov upload for automation-generated code
3. **Add**: Coverage gate validation

### Phase 4: Create Codecov Configuration
1. **Add**: `codecov.yml` for consistent coverage settings
2. **Configure**: Coverage thresholds, ignore patterns, comment templates

## Implementation Plan

### Step 1: Create Codecov Configuration
- Set consistent 80% coverage threshold
- Configure ignore patterns for generated code
- Set up PR comment templates

### Step 2: Update Automation Monitor
- Add codecov results integration
- Track coverage trends in metrics
- Alert on coverage regressions

### Step 3: Consolidate Workflows
- Remove deprecated/duplicate workflows
- Update remaining workflows with consistent settings
- Add coverage tracking to automation workflow

### Step 4: Enhanced Monitoring
- Monitor codecov API for coverage data
- Track coverage trends over time
- Alert on coverage drops in automation
