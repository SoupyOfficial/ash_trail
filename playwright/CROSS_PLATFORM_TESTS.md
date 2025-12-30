# Cross-Platform Playwright Tests - Migration Guide

This document describes the changes made to enable Playwright tests to work on both web (desktop) and mobile platforms.

## Overview

The Playwright test suite has been updated to handle differences between desktop and mobile interactions, including:
- Mouse events vs. touch events
- Different viewport sizes
- Mobile-specific UI patterns
- Scroll behaviors

## Changes Made

### 1. Device Helper Utilities (`tests/helpers/device-helpers.ts`)

A new helper library was created that provides cross-platform abstractions:

#### Key Functions:

- **`isMobileDevice(page)`** - Detects if the current page is running on a mobile device
- **`clickElement(page, selector, options)`** - Uses touch events for mobile, mouse clicks for desktop
- **`longPress(page, selector, duration, options)`** - Simulates long press with appropriate events
- **`holdAndRelease(page, selector, duration, options)`** - Complete hold-and-release gesture
- **`fillInput(page, selector, value, options)`** - Handles mobile keyboard behavior
- **`selectOption(page, selector, value, options)`** - Works with mobile dropdowns
- **`scrollElement(page, selector, options)`** - Touch-based vs wheel-based scrolling
- **`swipe(page, options)`** - Mobile swipe gestures
- **`waitForElement(page, selector, options)`** - Mobile-friendly timeouts

### 2. Updated Test Files

#### `hold-to-record.spec.ts`
- All mouse-based interactions replaced with `holdAndRelease()` helper
- Touch events automatically used on mobile devices
- Tests now verify functionality across all device types

**Example change:**
```typescript
// Before:
await page.mouse.move(x, y);
await page.mouse.down();
await page.waitForTimeout(3000);
await page.mouse.up();

// After:
await holdAndRelease(page, 'button:has-text("Quick Log")', 3000);
```

#### `logging-flow.spec.ts`
- Click actions replaced with `clickElement()`
- Form fills replaced with `fillInput()`
- Dropdown selections replaced with `selectOption()`
- Wait conditions replaced with `waitForElement()`

**Example change:**
```typescript
// Before:
await page.click('[data-testid="add-log-button"]');
await page.fill('input[name="value"]', '2.0');

// After:
await clickElement(page, '[data-testid="add-log-button"]', {});
await fillInput(page, 'input[name="value"]', '2.0');
```

#### `fixtures.ts`
- All Page Object Model methods updated to use device helpers
- LogEntryPage, SyncPage, and AnalyticsPage classes now work seamlessly on mobile

### 3. Playwright Configuration (`playwright.config.ts`)

Enhanced mobile device configurations:

```typescript
{
  name: 'Mobile Chrome',
  use: { 
    ...devices['Pixel 5'],
    hasTouch: true,
    isMobile: true,
  },
}
```

Added new test configurations:
- **Mobile Chrome Landscape** - Tests horizontal orientation
- **Tablet** (iPad Pro) - Tests larger mobile viewports

## How It Works

### Device Detection

The helper utilities detect mobile devices using two methods:
1. **Viewport size** - Width < 768px is considered mobile
2. **User agent** - Checks for mobile indicators in the UA string

### Event Handling

On mobile:
- Uses `page.touchscreen.tap()` for clicks
- Dispatches native TouchEvent objects for gestures
- Adjusts timeouts for slower mobile performance

On desktop:
- Uses `page.mouse.click()` for clicks
- Uses mouse down/up for hold gestures
- Standard timeouts

### Example: Long Press Implementation

```typescript
if (isMobile) {
  // Dispatch TouchEvent sequence
  const touch = new Touch({ ... });
  element.dispatchEvent(new TouchEvent('touchstart', ...));
  // ... hold duration ...
  element.dispatchEvent(new TouchEvent('touchend', ...));
} else {
  // Use mouse events
  await page.mouse.move(x, y);
  await page.mouse.down();
  await page.waitForTimeout(duration);
  await page.mouse.up();
}
```

## Running Tests

### Run all tests across all devices:
```bash
npm run test
# or
npx playwright test
```

### Run tests on specific device:
```bash
npx playwright test --project="Mobile Chrome"
npx playwright test --project="Mobile Safari"
npx playwright test --project="Tablet"
npx playwright test --project="chromium"
```

### Run specific test file:
```bash
npx playwright test hold-to-record.spec.ts --project="Mobile Chrome"
npx playwright test logging-flow.spec.ts --project="Mobile Safari"
```

### Debug mode:
```bash
npx playwright test --debug --project="Mobile Chrome"
```

## Best Practices

### When writing new tests:

1. **Always use device helpers** instead of direct Playwright APIs:
   ```typescript
   // Good
   await clickElement(page, '.my-button', {});
   
   // Bad
   await page.click('.my-button');
   ```

2. **Import helpers at the top of test files:**
   ```typescript
   import {
     clickElement,
     fillInput,
     holdAndRelease,
     waitForElement,
   } from './helpers/device-helpers';
   ```

3. **Use mobile-friendly timeouts:**
   ```typescript
   // Helper automatically adjusts timeout for mobile
   await waitForElement(page, '.selector', { timeout: 10000 });
   ```

4. **Test across multiple devices:**
   - Desktop (chromium, firefox, webkit)
   - Mobile phone (Mobile Chrome, Mobile Safari)
   - Tablet (iPad Pro)
   - Different orientations (landscape vs portrait)

## Troubleshooting

### Touch events not working?

Ensure the Playwright config has `hasTouch: true` and `isMobile: true`:
```typescript
use: { 
  ...devices['Pixel 5'],
  hasTouch: true,
  isMobile: true,
}
```

### Elements not clickable on mobile?

Use `waitForElement()` before interacting:
```typescript
await waitForElement(page, '.my-element', { timeout: 10000 });
await clickElement(page, '.my-element', {});
```

### Long press not triggering?

Adjust the duration based on your app's threshold:
```typescript
// If your app needs 600ms to detect long press
await holdAndRelease(page, '.button', 700); // Add 100ms buffer
```

### Mobile keyboard covering input?

The `fillInput()` helper handles this automatically by tapping first, then filling.

## Future Improvements

Potential enhancements for consideration:

1. **Swipe gestures** - Add more swipe-based navigation tests
2. **Pinch/zoom** - Test multi-touch gestures if needed
3. **Orientation changes** - Test rotation between portrait/landscape
4. **Performance testing** - Add mobile-specific performance assertions
5. **Network conditions** - Simulate slow 3G/4G for mobile tests

## Migration Checklist

When updating existing tests:

- [ ] Replace `page.click()` with `clickElement()`
- [ ] Replace `page.fill()` with `fillInput()`
- [ ] Replace `page.selectOption()` with `selectOption()`
- [ ] Replace `page.waitForSelector()` with `waitForElement()`
- [ ] Replace mouse event sequences with `holdAndRelease()`
- [ ] Update Page Object Model methods to use helpers
- [ ] Test on both desktop and mobile projects
- [ ] Update test descriptions to mention "web and mobile"

## Summary

The test suite now supports:
- ✅ Desktop browsers (Chrome, Firefox, Safari)
- ✅ Mobile browsers (Chrome on Android, Safari on iOS)
- ✅ Tablets (iPad Pro)
- ✅ Touch and mouse interactions
- ✅ Different viewport sizes
- ✅ Mobile-specific UI patterns
- ✅ Cross-platform gestures (tap, long press, swipe)

All tests automatically adapt to the device they're running on, providing comprehensive coverage for the AshTrail application across all platforms.
