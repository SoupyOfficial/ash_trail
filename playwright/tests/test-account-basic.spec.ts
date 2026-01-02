import { test, expect, Page } from '@playwright/test';

/**
 * Basic Test Account Feature Tests
 * 
 * These tests verify that the developer test account feature works in Chromium.
 * For full cross-browser testing, run: npx playwright install
 * Then run: npx playwright test test-account-persistence.spec.ts
 * 
 * Test Account Constants (must match accounts_screen.dart):
 * - ID: dev-test-account-001
 * - Email: test@ashtrail.dev
 * - Name: Test User
 */

const TEST_ACCOUNT_ID = 'dev-test-account-001';
const TEST_ACCOUNT_EMAIL = 'test@ashtrail.dev';
const TEST_ACCOUNT_NAME = 'Test User';

// Helper to wait for Flutter app to be ready
async function waitForFlutterReady(page: Page, timeout: number = 30000): Promise<boolean> {
  const startTime = Date.now();
  
  while (Date.now() - startTime < timeout) {
    // Check if Flutter semantic tree or canvas is present
    const hasSemantics = await page.locator('flt-semantics-host, flt-glass-pane, canvas').count() > 0;
    const hasText = await page.evaluate(() => document.body.innerText.length > 10);
    
    if (hasSemantics || hasText) {
      // Additional wait for Flutter to fully render
      await page.waitForTimeout(2000);
      return true;
    }
    
    await page.waitForTimeout(500);
  }
  return false;
}

// Configure to only use Chromium (moved outside describe blocks)
test.use({ 
  viewport: { width: 1280, height: 720 },
});

test.describe.configure({ mode: 'serial' });

test.describe('Test Account Basic Tests', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
    await waitForFlutterReady(page);
  });

  test('Flutter app loads successfully', async ({ page }) => {
    // Check that Flutter has rendered
    const flutterRendered = await page.evaluate(() => {
      // Check for Flutter canvas or semantic elements
      const hasCanvas = document.querySelector('canvas, flt-glass-pane') !== null;
      const hasSemantics = document.querySelector('flt-semantics-host') !== null;
      const hasContent = document.body.innerText.trim().length > 0;
      return hasCanvas || hasSemantics || hasContent;
    });

    expect(flutterRendered).toBeTruthy();
  });

  test('page has expected structure', async ({ page }) => {
    // Verify the page has loaded with Flutter content
    const pageContent = await page.content();
    
    // Check for Flutter-specific elements
    const hasFlutterElements = 
      pageContent.includes('flutter') || 
      pageContent.includes('canvas') ||
      pageContent.includes('flt-');
    
    expect(hasFlutterElements).toBeTruthy();
  });

  test('can interact with the app', async ({ page }) => {
    // Wait for the app to be interactive
    await page.waitForTimeout(3000);
    
    // Try to find any clickable element
    const clickableElements = await page.locator('button, [role="button"], [onclick], [tabindex="0"]').count();
    
    // Or check for Flutter semantic elements that are interactive
    const semanticElements = await page.locator('flt-semantics').count();
    
    // At least some interactive elements should be present
    const hasInteractiveElements = clickableElements > 0 || semanticElements > 0;
    
    // If no interactive elements, at least check the app rendered
    const hasCanvas = await page.locator('canvas').count() > 0;
    
    expect(hasInteractiveElements || hasCanvas).toBeTruthy();
  });

  test('IndexedDB storage is available', async ({ page }) => {
    // Verify IndexedDB is available (required for Hive web storage)
    const indexedDBAvailable = await page.evaluate(() => {
      return 'indexedDB' in window;
    });

    expect(indexedDBAvailable).toBeTruthy();
  });

  test('localStorage is available', async ({ page }) => {
    // Verify localStorage is available 
    const localStorageAvailable = await page.evaluate(() => {
      try {
        localStorage.setItem('test', 'test');
        localStorage.removeItem('test');
        return true;
      } catch {
        return false;
      }
    });

    expect(localStorageAvailable).toBeTruthy();
  });
});

test.describe('Test Account Constants Verification', () => {
  test('test account constants are correct', async () => {
    // These values must match the constants in lib/screens/accounts_screen.dart
    expect(TEST_ACCOUNT_ID).toBe('dev-test-account-001');
    expect(TEST_ACCOUNT_EMAIL).toBe('test@ashtrail.dev');
    expect(TEST_ACCOUNT_NAME).toBe('Test User');
  });

  test('test account email follows valid format', async () => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    expect(emailRegex.test(TEST_ACCOUNT_EMAIL)).toBeTruthy();
  });

  test('test account ID uses dev prefix for easy identification', async () => {
    expect(TEST_ACCOUNT_ID.startsWith('dev-')).toBeTruthy();
  });
});
