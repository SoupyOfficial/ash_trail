# Documentation Review & Validation

This directory contains tools and logs for maintaining documentation quality and consistency in the AshTrail project.

## Files

### Review Logs
- **`2025-12-30-documentation-consistency-review.md`** - Comprehensive findings from initial review
- **`PHASE1-COMPLETE.md`** - Summary of Phase 1 work (section numbering & heading depth)
- **`TODO.md`** - Roadmap of remaining work

### Validation Tools
- **`validate_docs.py`** - Python script to validate documentation against standards
- **`validation-rules.md`** - Complete documentation of all validation rules
- **`README.md`** - This file

---

## Quick Start

### Run Validation
```bash
# From project root:
python docs/plan-review/validate_docs.py

# Or from this directory:
python validate_docs.py
```

### Common Options
```bash
# Verbose output (see what's being checked)
python validate_docs.py --verbose

# Check only specific rules
python validate_docs.py --rules heading-depth,section-numbering

# Exclude certain files
python validate_docs.py --exclude "combined.md,temp*.md"
```

### Exit Codes
- `0` = All checks passed ✅
- `1` = Validation failures found ❌
- `2` = Script error 💥

---

## Validation Rules

The validator currently enforces these rules:

1. **`heading-depth`** (Error) - No headings deeper than H4
2. **`section-numbering`** (Error) - Sections must use X.Y.Z format with doc number prefix
3. **`standard-sections`** (Info) - Recommends standard sections (Overview, Assumptions, etc.)
4. **`table-formatting`** (Warning) - Consistent table separator formatting
5. **`trailing-whitespace`** (Info) - No trailing spaces on lines

See [`validation-rules.md`](./validation-rules.md) for complete details.

---

## CI Integration

### GitHub Actions Example
```yaml
name: Documentation Validation

on:
  pull_request:
    paths:
      - 'docs/plan/*.md'

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      - name: Validate Documentation
        run: python docs/plan-review/validate_docs.py
```

### Pre-commit Hook
```bash
# .git/hooks/pre-commit
#!/bin/bash
python docs/plan-review/validate_docs.py --rules heading-depth,section-numbering
if [ $? -ne 0 ]; then
    echo "Documentation validation failed. Please fix issues before committing."
    exit 1
fi
```

---

## Review Process

### For New Documents
1. Write document following conventions in [Doc 26](../plan/26.%20Documentation%20Conventions.md)
2. Run validator: `python validate_docs.py`
3. Fix any errors or warnings
4. Re-run until all checks pass

### For Existing Documents
1. Make changes to documentation
2. Run validator to ensure no regressions
3. Address any new issues introduced
4. Commit changes with passing validation

### Periodic Reviews
- Monthly: Run full validation on all docs
- Quarterly: Review TODO.md and plan next phase
- As needed: Update validation rules to match evolving standards

---

## Extending the Validator

### Adding a New Rule

1. **Create validation method** in `validate_docs.py`:
   ```python
   def _check_my_rule(self, file_path: Path, lines: List[str]):
       """Rule: Description."""
       # Your validation logic here
       pass
   ```

2. **Register in `_validate_file`**:
   ```python
   if 'my-rule' in rules:
       self._check_my_rule(file_path, lines)
   ```

3. **Add to default rules list** in `main()`

4. **Document in `validation-rules.md`**

5. **Test manually**:
   ```bash
   python validate_docs.py --rules my-rule --verbose
   ```

### Future Enhancements

Planned improvements (see TODO.md for priority):
- [ ] Configuration file support (YAML)
- [ ] Auto-fix capability for simple issues
- [ ] Cross-reference validation (check internal links)
- [ ] Terminology consistency checker
- [ ] Integration with VS Code extension
- [ ] HTML report generation
- [ ] Diff-aware validation (only check changed files)

---

## Troubleshooting

### Script Not Found
```bash
# Make script executable
chmod +x docs/plan-review/validate_docs.py

# Run with explicit python
python3 docs/plan-review/validate_docs.py
```

### Path Issues
```bash
# Specify path explicitly
python validate_docs.py --path /full/path/to/docs/plan
```

### False Positives
If validation flags something incorrectly:
1. Check if rule interpretation is correct
2. Consider if rule needs refinement
3. Open issue or update rule definition
4. Use `--exclude` for special cases

---

## Maintenance

### When to Update This Directory

**Update validation rules when**:
- New documentation standards are adopted
- False positives are consistently found
- New categories of issues are discovered

**Update review logs when**:
- Completing a new review phase
- Making significant documentation changes
- Resolving critical inconsistencies

**Update TODO.md when**:
- Starting new phase of work
- Discovering new issues to address
- Completing planned work

---

## Questions or Issues?

- See [`validation-rules.md`](./validation-rules.md) for rule details
- See [`TODO.md`](./TODO.md) for planned work
- See [Doc 26](../plan/26.%20Documentation%20Conventions.md) for standards

For issues with the validator itself, check:
1. Python version (3.8+ required)
2. File permissions
3. Path configuration
4. Rule conflicts
