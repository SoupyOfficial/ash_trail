# AshTrail E2E Testing with Playwright

This directory contains end-to-end tests for the AshTrail logging system using [Playwright](https://playwright.dev/).

## 📁 Structure

```
playwright/
├── package.json              # Node dependencies
├── playwright.config.ts      # Playwright configuration
├── tests/
│   ├── fixtures.ts          # Page Object Model definitions
│   ├── logging-flow.spec.ts # Main logging flow tests
│   ├── page-object-tests.spec.ts # Tests using POM
│   └── visual-regression.spec.ts # Visual regression tests
└── README.md                # This file
```

## 🚀 Setup

### Prerequisites

- Node.js 18+ installed
- Flutter app running or able to build for web

### Installation

```bash
cd playwright
npm install
npx playwright install
```

This will install Playwright and all required browser binaries (Chromium, Firefox, WebKit).

## 🧪 Running Tests

### Run all tests

```bash
npm test
```

### Run tests in headed mode (see browser)

```bash
npm run test:headed
```

### Run tests in UI mode (interactive)

```bash
npm run test:ui
```

### Run specific test file

```bash
npx playwright test logging-flow.spec.ts
```

### Run tests in specific browser

```bash
npx playwright test --project=chromium
npx playwright test --project=firefox
npx playwright test --project=webkit
```

### Debug tests

```bash
npm run test:debug
```

This opens Playwright Inspector where you can step through tests.

## 📊 Test Reports

After running tests, view the HTML report:

```bash
npm run report
```

This opens an interactive report showing:
- Test results
- Screenshots on failure
- Video recordings on failure
- Performance traces

## 📝 Test Suites

### 1. Logging Flow Tests (`logging-flow.spec.ts`)

Comprehensive tests covering:
- ✅ Creating log entries via UI
- ✅ Viewing log entry details
- ✅ Editing existing entries
- ✅ Deleting entries
- ✅ Quick log buttons
- ✅ Filtering by event type
- ✅ Searching entries
- ✅ Date range filtering
- ✅ Sync status monitoring
- ✅ Offline support
- ✅ Performance benchmarks

### 2. Visual Regression Tests (`visual-regression.spec.ts`)

Screenshot comparison tests for:
- ✅ Home screen appearance
- ✅ Create log dialog
- ✅ Analytics screen
- ✅ Sync status widget
- ✅ Log entry list
- ✅ Mobile viewport
- ✅ Tablet viewport
- ✅ Dark mode
- ✅ Component states (empty, loading, error)
- ✅ Interaction states (hover, focus, disabled)

### 3. Page Object Tests (`page-object-tests.spec.ts`)

Tests using Page Object Model for:
- ✅ Creating multiple entries efficiently
- ✅ Search and filter workflows
- ✅ Edit and delete workflows
- ✅ Sync status monitoring
- ✅ Analytics interactions
- ✅ Complete user journeys
- ✅ Offline to online workflows

## 🎯 Page Object Model

The `fixtures.ts` file provides reusable page objects:

### LogEntryPage

```typescript
// Navigate to app
await logEntryPage.goto();

// Create a log entry
await logEntryPage.createLogEntry({
  eventType: 'inhale',
  value: '2.0',
  unit: 'hits',
  note: 'Test entry',
  tags: 'morning,sativa'
});

// Search entries
await logEntryPage.searchLogEntries('morning');

// Filter by event type
await logEntryPage.filterByEventType('Inhale');

// Edit entry
await logEntryPage.editLogEntry(0, { note: 'Updated' });

// Delete entry
await logEntryPage.deleteLogEntry(0);
```

### SyncPage

```typescript
// Get sync status
const status = await syncPage.getSyncStatus();

// Trigger manual sync
await syncPage.triggerSync();

// Wait for sync complete
await syncPage.waitForSyncComplete();

// Get pending count
const pending = await syncPage.getPendingCount();
```

### AnalyticsPage

```typescript
// Navigate to analytics
await analyticsPage.goto();

// Select time range
await analyticsPage.selectTimeRange('This Week');

// Select grouping
await analyticsPage.selectGroupBy('Day');

// Get statistics
const stats = await analyticsPage.getStatistics();

// Get event type breakdown
const breakdown = await analyticsPage.getEventTypeBreakdown();
```

## 🔧 Configuration

### Playwright Config (`playwright.config.ts`)

Key settings:
- **Base URL**: `http://localhost:8080`
- **Browsers**: Chromium, Firefox, WebKit, Mobile Chrome, Mobile Safari
- **Retries**: 2 on CI, 0 locally
- **Reporters**: HTML, List, JSON
- **Trace**: On first retry
- **Screenshot**: On failure
- **Video**: On failure

### Web Server

Playwright automatically starts the Flutter web server:

```typescript
webServer: {
  command: 'flutter run -d chrome --web-port=8080',
  url: 'http://localhost:8080',
  reuseExistingServer: !process.env.CI,
  timeout: 120000,
}
```

## 📸 Visual Regression

### Baseline Images

First run creates baseline screenshots:

```bash
npx playwright test visual-regression.spec.ts
```

Baseline images are stored in `tests/**/*.spec.ts-snapshots/`.

### Updating Baselines

If UI changes are intentional, update baselines:

```bash
npx playwright test visual-regression.spec.ts --update-snapshots
```

### Comparing Diffs

When tests fail, view visual diffs in the HTML report:

```bash
npm run report
```

## 🌐 Testing Across Devices

Tests run on multiple devices:
- **Desktop**: Chrome, Firefox, Safari
- **Mobile**: Pixel 5, iPhone 12

To run only mobile tests:

```bash
npx playwright test --project="Mobile Chrome"
npx playwright test --project="Mobile Safari"
```

## 🐛 Debugging Tips

### 1. Use UI Mode

Best for debugging:
```bash
npm run test:ui
```

### 2. Use Headed Mode

See the browser:
```bash
npm run test:headed
```

### 3. Use Inspector

Step through test:
```bash
npm run test:debug
```

### 4. Add Pauses

In your test:
```typescript
await page.pause(); // Opens inspector
```

### 5. Slow Motion

In config:
```typescript
use: {
  launchOptions: {
    slowMo: 1000, // 1 second between actions
  }
}
```

## 📋 Best Practices

### Test Data IDs

Use `data-testid` attributes in Flutter widgets:

```dart
Container(
  key: Key('add-log-button'),
  // In Flutter web, this becomes data-testid
)
```

### Waiting Strategies

```typescript
// Wait for element
await page.waitForSelector('[data-testid="log-entry"]');

// Wait for network
await page.waitForLoadState('networkidle');

// Wait for timeout (last resort)
await page.waitForTimeout(1000);
```

### Error Handling

```typescript
// Try primary selector, fallback to secondary
await page.click('[data-testid="button"]').catch(async () => {
  await page.click('button:has-text("Submit")');
});
```

## 🔄 CI/CD Integration

### GitHub Actions Example

```yaml
name: E2E Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 18
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.7.0'
      
      - name: Install dependencies
        run: |
          flutter pub get
          cd playwright && npm install
      
      - name: Install Playwright browsers
        run: cd playwright && npx playwright install --with-deps
      
      - name: Run E2E tests
        run: cd playwright && npm test
      
      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: playwright-report
          path: playwright/playwright-report/
```

## 📚 Resources

- [Playwright Documentation](https://playwright.dev/)
- [Playwright Best Practices](https://playwright.dev/docs/best-practices)
- [Flutter Web Testing](https://docs.flutter.dev/testing/integration-tests)
- [Page Object Model](https://playwright.dev/docs/pom)

## 🤝 Contributing

When adding new features:
1. Add test data IDs to widgets
2. Create tests in appropriate spec file
3. Add page object methods if reusable
4. Update this README if needed
5. Run tests before committing

## 📞 Support

For issues or questions:
- Check [Playwright documentation](https://playwright.dev/)
- Review existing tests for examples
- Open an issue in the project repository
