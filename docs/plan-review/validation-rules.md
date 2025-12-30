# Documentation Validation Rules

This document describes all validation rules enforced by `validate_docs.py`.

## Active Rules

### 1. `heading-depth`
**Severity**: Error  
**Description**: Headings should not exceed depth H4 (####)

**Rationale**: 
- Maintains readability
- Prevents navigation issues in Obsidian/markdown viewers
- Follows conventions defined in Document 26

**Examples**:
```markdown
# ❌ INVALID
##### This is H5 - too deep
###### This is H6 - too deep

# ✅ VALID
#### This is H4 - maximum depth
**Use bold text for deeper subsections**
```

**How to Fix**:
- Convert H5/H6 to H4 if it's a structural section
- Convert to **bold text** if it's a content subsection (e.g., "Overview", "Responsibilities")
- Use bullet lists for detailed breakdowns

---

### 2. `section-numbering`
**Severity**: Error  
**Description**: Section numbers must follow X.Y.Z format with document number as prefix

**Rationale**:
- Provides clear document-level context
- Enables unambiguous cross-referencing
- Prevents confusion between documents

**Examples**:
```markdown
# For Document 7 (Data Persistence):

# ❌ INVALID
### 1.1 Local Database    # Wrong prefix
### 7.A Subsection        # Non-numeric

# ✅ VALID
### 7.1 Local Database
### 7.2 Remote Database
#### 7.2.1 Firestore
```

**How to Fix**:
- Ensure all H3 sections start with document number (e.g., `### 7.1`)
- Ensure all H4 sections continue the hierarchy (e.g., `#### 7.1.1`)

---

### 3. `standard-sections`
**Severity**: Info  
**Description**: Documents should include standard sections where applicable

**Expected Sections**:
- Overview (recommended for all docs)
- Responsibilities (recommended for technical docs)
- Assumptions & Open Questions (recommended for all docs)
- Future Extensions (optional but recommended)

**Rationale**:
- Ensures consistency across documentation
- Helps readers know what to expect
- Follows conventions defined in Document 26

**How to Fix**:
- Add missing sections if they apply to your document
- This is informational - not all docs need all sections

---

### 4. `table-formatting`
**Severity**: Warning  
**Description**: Table separators should use consistent formatting within each document

**Examples**:
```markdown
# ❌ INCONSISTENT
| Column 1 | Column 2 |
|---|---|                    ← single dash

| Column 1 | Column 2 |
|-----|------|              ← multiple dashes

# ✅ CONSISTENT
| Column 1 | Column 2 |
|---|---|

| Column 1 | Column 2 |
|---|---|
```

**How to Fix**:
- Pick one style (single dash recommended)
- Apply consistently throughout the document

---

### 5. `trailing-whitespace`
**Severity**: Info  
**Description**: Lines should not have trailing whitespace

**Rationale**:
- Cleaner git diffs
- Prevents accidental formatting issues
- Standard markdown best practice

**How to Fix**:
- Configure your editor to strip trailing whitespace on save
- Run: `sed -i '' 's/[[:space:]]*$//' filename.md` (macOS)

---

## Future Rules (Planned)

### `cross-references`
**Status**: Not yet implemented  
**Description**: Validate that internal document links are not broken

**Examples**:
```markdown
# Check that these resolve:
[[4. Domain Model]]
See [Document 7](7. Data Persistence.md)
```

---

### `code-block-language`
**Status**: Not yet implemented  
**Description**: Code blocks should specify language for syntax highlighting

**Examples**:
```markdown
# ❌ INVALID
```
code here
```

# ✅ VALID
```dart
code here
```
```

---

### `consistent-terminology`
**Status**: Not yet implemented  
**Description**: Ensure consistent use of key terms (e.g., "Hive" vs "Isar", "log entry" vs "log record")

---

### `toc-sync`
**Status**: Not yet implemented  
**Description**: Verify Table of Contents includes all documents and is in correct order

---

## Running Validation

### Validate All Rules (Default)
```bash
python docs/plan-review/validate_docs.py
```

### Validate Specific Rules
```bash
# Only check heading depth and section numbering
python docs/plan-review/validate_docs.py --rules heading-depth,section-numbering
```

### Verbose Output
```bash
python docs/plan-review/validate_docs.py --verbose
```

### Exclude Files
```bash
# Exclude combined.md and test files
python docs/plan-review/validate_docs.py --exclude "combined.md,*test*.md"
```

---

## Exit Codes

- `0` - All validations passed ✅
- `1` - Validation failures found ❌
- `2` - Script error 💥

---

## Adding New Rules

To add a new validation rule:

1. **Add validation method** to `DocumentValidator` class:
   ```python
   def _check_new_rule(self, file_path: Path, lines: List[str]):
       """Rule: Description of what this checks."""
       for line_num, line in enumerate(lines, 1):
           if condition_violated:
               self.add_issue(ValidationIssue(
                   file=file_path.name,
                   line=line_num,
                   rule='new-rule',
                   severity='error',  # or 'warning', 'info'
                   message='What went wrong',
                   suggestion='How to fix it'
               ))
   ```

2. **Register rule** in `_validate_file` method:
   ```python
   if 'new-rule' in rules:
       self._check_new_rule(file_path, lines)
   ```

3. **Add to default rules** in `main()`:
   ```python
   rules = [
       'heading-depth',
       'section-numbering',
       # ... existing rules ...
       'new-rule',  # Add here
   ]
   ```

4. **Document the rule** in this file (`validation-rules.md`)

5. **Add tests** (if test suite exists)

---

## Configuration (Future)

For future extensibility, rules could be configured via `validation-config.yml`:

```yaml
rules:
  heading-depth:
    enabled: true
    severity: error
    max-depth: 4
  
  section-numbering:
    enabled: true
    severity: error
    
  table-formatting:
    enabled: true
    severity: warning
    preferred-style: single-dash
    
exclude:
  - combined.md
  - "*test*.md"
```

This would allow project-specific customization without modifying the script.
