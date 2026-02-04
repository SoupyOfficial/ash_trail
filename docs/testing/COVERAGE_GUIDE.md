# Test Coverage Guide

How to collect and view test coverage for AshTrail’s Flutter unit/widget tests, Playwright (web E2E), and Patrol (native E2E).

---

## 1. Flutter (unit & widget tests)

Flutter’s built-in coverage works for everything under `test/` (unit tests, widget tests, flow tests).

### Collect coverage

```bash
flutter test --coverage
```

- Runs all tests in `test/`.
- Writes **LCOV** to `coverage/lcov.info`.

### Coverage gate (85% line coverage)

Use the repo’s coverage gate script locally or in CI:

```bash
MIN_COVERAGE=85 bash scripts/coverage/check_coverage.sh
```

- Filters generated files (e.g., `*.g.dart`, `*.freezed.dart`, `firebase_options.dart`).
- Fails the run if line coverage is below the threshold.

### View coverage locally

**Option A – HTML report (recommended)**

```bash
# Install lcov if needed (macOS: brew install lcov)
lcov --summary coverage/lcov.info
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

**Option B – Summary only**

```bash
lcov --summary coverage/lcov.info
```

### CI (e.g. Codecov)

Your existing pattern in docs (e.g. `WIDGET_TEST_DOCUMENTATION.md`) is correct:

```yaml
- run: flutter test --coverage
- uses: codecov/codecov-action@v3
  with:
    files: ./coverage/lcov.info
```

### Notes

- `coverage/` is usually in `.gitignore`; only upload the report in CI.
- To exclude generated files: `flutter test --coverage --coverage-path=coverage/lcov.info` and/or use `lcov --remove` when generating reports.

---

## 2. Playwright (web E2E)

Playwright does **not** have a built-in coverage reporter. Coverage is **Chromium-only** and must be wired with the Coverage API (and optionally Istanbul).

### Option A – Manual Coverage API (Chromium)

Use `page.coverage` in tests:

1. Use Chromium (or a Chromium-based project).
2. Before actions: `await page.coverage.startJSCoverage()` (and optionally `startCSSCoverage()`).
3. After the test: `await page.coverage.stopJSCoverage()` (and `stopCSSCoverage()`).
4. Convert V8 output to Istanbul with `v8-to-istanbul`, then merge and report (e.g. `nyc report` or `istanbul`).

### Option B – Helper package

Use a community helper that wraps the Coverage API, for example:

- [playwright-test-coverage](https://github.com/mxschmitt/playwright-test-coverage) (or similar)

Then run your Playwright tests as usual; the helper collects coverage and can output Istanbul/LCOV.

### Option C – “Which code did E2E touch?” (no instrumentation)

- Rely on **Playwright’s HTML report** and **trace/screenshots** to see what was executed.
- No line/statement coverage numbers, but useful to see which flows ran.

### Suggested Playwright coverage flow for this project

1. Add a Chromium-only project or run with `--project=chromium` when collecting coverage.
2. Add `v8-to-istanbul` (and optionally `nyc` or `istanbul-lib-report`) to `playwright/package.json`.
3. In a shared fixture or `beforeEach`, call `page.coverage.startJSCoverage()` for the Chromium project; in `afterEach` call `stopJSCoverage()`, merge, convert to Istanbul, then write LCOV/HTML.
4. Optionally add an npm script, e.g. `"test:coverage": "playwright test --project=chromium"` and document that this run produces coverage artifacts.

---

## 3. Patrol (native E2E – iOS/Android)

Patrol can emit **LCOV** for native E2E runs.

### Collect coverage

```bash
patrol test --coverage
```

- LCOV is written to **`coverage/patrol_lcov.info`** (path relative to project root).
- You can exclude files with globs:

```bash
patrol test --coverage --coverage-ignore="**/*.g.dart"
```

### Limitation

- **Coverage is not supported on macOS** (i.e. when the Patrol CLI runs on a Mac, coverage collection may be disabled or unsupported; run on Linux/CI for Android, or check Patrol docs for current iOS support).

### View coverage

Same as Flutter: use `lcov` and `genhtml` on `coverage/patrol_lcov.info`:

```bash
lcov --summary coverage/patrol_lcov.info
genhtml coverage/patrol_lcov.info -o coverage/patrol_html
open coverage/patrol_html/index.html
```

### Merging with Flutter coverage (optional)

To get one report that includes both unit and Patrol E2E coverage:

```bash
lcov --add coverage/lcov.info --add coverage/patrol_lcov.info --output coverage/merged_lcov.info
genhtml coverage/merged_lcov.info -o coverage/merged_html
```

---

## Summary

| Layer        | Command / approach                    | Output / artifact              |
|-------------|----------------------------------------|---------------------------------|
| **Flutter** | `flutter test --coverage`              | `coverage/lcov.info`           |
| **Playwright** | Coverage API + v8-to-istanbul (Chromium) or helper package | Istanbul/LCOV (custom path) |
| **Patrol**  | `patrol test --coverage`               | `coverage/patrol_lcov.info` (not on macOS) |

For a single number or “coverage gate” in CI, start with **Flutter** (`flutter test --coverage` + `lcov.info`). Add Playwright and Patrol coverage when you’re ready to invest in the extra setup and (for Patrol) non-macOS runners.
