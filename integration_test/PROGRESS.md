# Integration Test Restructure — Progress

## Architecture
Component-style (Page Object Model) integration tests using Patrol.
See `.github/prompts/plan-solidIntegrationTestRestructure.prompt.md` for full plan.

## Status

| # | Task | Status |
|---|------|--------|
| 1 | Move old tests to `bak/` | ✅ Done |
| 2 | Create `helpers/pump.dart` | ✅ Done |
| 3 | Create `helpers/config.dart` | ✅ Done |
| 4 | Create `components/app.dart` | ✅ Done |
| 5 | Create `components/welcome.dart` | ✅ Done |
| 6 | Create `components/login.dart` | ✅ Done |
| 7 | Create `components/home.dart` | ✅ Done |
| 8 | Create `components/nav_bar.dart` | ✅ Done |
| 9 | Create `components/history.dart` | ✅ Done |
| 10 | Create `components/analytics.dart` | ✅ Done |
| 11 | Create `components/logging.dart` | ✅ Done |
| 12 | Create `components/accounts.dart` | ✅ Done |
| 13 | Create `flows/login_flow.dart` | ✅ Done |
| 14 | Rewrite `login_flow_test.dart` | ✅ Done |
| 15 | Write `auth_test.dart` | ✅ Done |
| 16 | Write `navigation_test.dart` | ✅ Done |
| 17 | Write `home_screen_test.dart` | ✅ Done |
| 18 | Write `history_test.dart` | ✅ Done |
| 19 | Write `accounts_test.dart` | ✅ Done |
| 20 | Write `analytics_test.dart` | ✅ Done |
| 21 | Write `logging_test.dart` | ✅ Done |

## Verification

All new files pass static analysis (0 errors). Old files in `bak/` have expected broken imports.

### Next: Run on simulator

```bash
patrol test --target integration_test/login_flow_test.dart --device "iPhone 16 Pro Max"
```

Then incrementally test each file.

## Files Moved to `bak/`

- `app_e2e_test.dart`
- `multi_account_test.dart`
- `accounts_screen_test.dart`
- `comprehensive_e2e_test.dart`
- `figma_screenshot_capture.dart`
- `logging_flow_test.dart`
- `location_collection_test.dart`
- `auth_provider_integration_test.dart`
- `validation_service_integration_test.dart`
- `e2e_helpers.dart`

## Run Results
_(will be logged after each test run)_
