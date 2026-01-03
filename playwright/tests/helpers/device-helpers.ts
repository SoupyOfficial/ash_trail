import { Page } from '@playwright/test';

/**
 * Device Helper Utilities
 * 
 * Provides cross-platform utilities for handling differences between
 * mobile and desktop interactions in Playwright tests
 */

export interface DeviceInfo {
  isMobile: boolean;
  isTouch: boolean;
  viewportWidth: number;
  viewportHeight: number;
  userAgent: string;
}

/**
 * Detects if the current page is running on a mobile device
 */
export async function isMobileDevice(page: Page): Promise<boolean> {
  const viewport = page.viewportSize();
  if (!viewport) return false;
  
  // Consider mobile if width is less than 768px (common breakpoint)
  const isMobileViewport = viewport.width < 768;
  
  // Check user agent for mobile indicators
  const userAgent = await page.evaluate(() => navigator.userAgent);
  const isMobileUA = /Mobile|Android|iPhone|iPad|iPod/i.test(userAgent);
  
  return isMobileViewport || isMobileUA;
}

/**
 * Get comprehensive device information
 */
export async function getDeviceInfo(page: Page): Promise<DeviceInfo> {
  const viewport = page.viewportSize();
  const userAgent = await page.evaluate(() => navigator.userAgent);
  const isMobile = await isMobileDevice(page);
  
  return {
    isMobile,
    isTouch: isMobile,
    viewportWidth: viewport?.width || 0,
    viewportHeight: viewport?.height || 0,
    userAgent,
  };
}

/**
 * Cross-platform click/tap handler
 * Uses touch events for mobile and mouse events for desktop
 */
export async function clickElement(
  page: Page,
  selector: string,
  options: { timeout?: number } = {}
): Promise<void> {
  const isMobile = await isMobileDevice(page);
  const element = page.locator(selector).first();
  
  await element.waitFor({ state: 'visible', timeout: options.timeout || 10000 });
  
  if (isMobile) {
    // Use tap on mobile
    await element.tap();
  } else {
    // Use click on desktop
    await element.click();
  }
}

/**
 * Cross-platform long press/hold handler
 * Uses touch events for mobile and mouse events for desktop
 */
export async function longPress(
  page: Page,
  selector: string,
  duration: number = 600,
  options: { timeout?: number } = {}
): Promise<void> {
  const isMobile = await isMobileDevice(page);
  const element = page.locator(selector).first();
  
  await element.waitFor({ state: 'visible', timeout: options.timeout || 10000 });
  
  const box = await element.boundingBox();
  if (!box) throw new Error(`Element ${selector} not found or not visible`);
  
  const x = box.x + box.width / 2;
  const y = box.y + box.height / 2;
  
  if (isMobile) {
    // Use touch events for mobile
    await page.touchscreen.tap(x, y);
    await page.waitForTimeout(duration);
    // Note: Playwright doesn't have a direct way to hold touch,
    // so we simulate by using the element's long press
    await element.press();
  } else {
    // Use mouse events for desktop
    await page.mouse.move(x, y);
    await page.mouse.down();
    await page.waitForTimeout(duration);
  }
}

/**
 * Release a long press
 */
export async function releaseLongPress(page: Page): Promise<void> {
  const isMobile = await isMobileDevice(page);
  
  if (!isMobile) {
    // Only mouse needs explicit release
    await page.mouse.up();
  }
}

/**
 * Perform a long press and hold for a specific duration, then release
 */
export async function holdAndRelease(
  page: Page,
  selector: string,
  holdDuration: number,
  options: { timeout?: number } = {}
): Promise<void> {
  const isMobile = await isMobileDevice(page);
  const element = page.locator(selector).first();
  
  await element.waitFor({ state: 'visible', timeout: options.timeout || 10000 });
  
  const box = await element.boundingBox();
  if (!box) throw new Error(`Element ${selector} not found or not visible`);
  
  const x = box.x + box.width / 2;
  const y = box.y + box.height / 2;
  
  if (isMobile) {
    // For mobile, use touchscreen API
    await page.touchscreen.tap(x, y);
    // Simulate the hold by keeping the touch active
    // Note: This is a workaround as Playwright's touch API is limited
    await page.evaluate(
      ({ x, y, duration }: { x: number; y: number; duration: number }) => {
        return new Promise<void>((resolve) => {
          const touch = new Touch({
            identifier: Date.now(),
            target: document.elementFromPoint(x, y) as Element,
            clientX: x,
            clientY: y,
            screenX: x,
            screenY: y,
          });
          
          const touchStartEvent = new TouchEvent('touchstart', {
            cancelable: true,
            bubbles: true,
            touches: [touch],
            targetTouches: [touch],
            changedTouches: [touch],
          });
          
          const element = document.elementFromPoint(x, y);
          element?.dispatchEvent(touchStartEvent);
          
          setTimeout(() => {
            const touchEndEvent = new TouchEvent('touchend', {
              cancelable: true,
              bubbles: true,
              touches: [],
              targetTouches: [],
              changedTouches: [touch],
            });
            element?.dispatchEvent(touchEndEvent);
            resolve();
          }, duration);
        });
      },
      { x, y, duration: holdDuration }
    );
  } else {
    // For desktop, use mouse events
    await page.mouse.move(x, y);
    await page.mouse.down();
    await page.waitForTimeout(holdDuration);
    await page.mouse.up();
  }
}

/**
 * Cross-platform scroll handler
 */
export async function scrollElement(
  page: Page,
  selector: string,
  options: { direction?: 'up' | 'down', distance?: number } = {}
): Promise<void> {
  const isMobile = await isMobileDevice(page);
  const element = page.locator(selector).first();
  
  const direction = options.direction || 'down';
  const distance = options.distance || 300;
  
  if (isMobile) {
    // Use touch-based scrolling for mobile
    const box = await element.boundingBox();
    if (!box) throw new Error(`Element ${selector} not found`);
    
    const startY = box.y + box.height / 2;
    const endY = direction === 'down' ? startY - distance : startY + distance;
    
    await page.touchscreen.tap(box.x + box.width / 2, startY);
    await page.mouse.move(box.x + box.width / 2, endY);
  } else {
    // Use wheel event for desktop
    await element.evaluate(
      (el: HTMLElement, dist: number) => {
        el.scrollBy({ top: dist, behavior: 'smooth' });
      },
      direction === 'down' ? distance : -distance
    );
  }
}

/**
 * Wait for element with mobile-friendly timeout
 */
export async function waitForElement(
  page: Page,
  selector: string,
  options: { timeout?: number; state?: 'visible' | 'hidden' | 'attached' } = {}
): Promise<void> {
  const isMobile = await isMobileDevice(page);
  
  // Mobile devices might be slower, so increase timeout
  const timeout = options.timeout || (isMobile ? 15000 : 10000);
  
  await page.locator(selector).first().waitFor({
    state: options.state || 'visible',
    timeout,
  });
}

/**
 * Fill input with cross-platform support
 */
export async function fillInput(
  page: Page,
  selector: string,
  value: string,
  options: { timeout?: number } = {}
): Promise<void> {
  const isMobile = await isMobileDevice(page);
  const element = page.locator(selector).first();
  
  await element.waitFor({ state: 'visible', timeout: options.timeout || 10000 });
  
  if (isMobile) {
    // On mobile, tap first to focus, then fill
    await element.tap();
    await page.waitForTimeout(200); // Wait for keyboard to appear
    await element.fill(value);
  } else {
    // On desktop, just fill
    await element.fill(value);
  }
}

/**
 * Select option with cross-platform support
 */
export async function selectOption(
  page: Page,
  selector: string,
  value: string,
  options: { timeout?: number } = {}
): Promise<void> {
  const isMobile = await isMobileDevice(page);
  const element = page.locator(selector).first();
  
  await element.waitFor({ state: 'visible', timeout: options.timeout || 10000 });
  
  if (isMobile) {
    // On mobile, tap to open dropdown
    await element.tap();
    await page.waitForTimeout(300);
    
    // Try to select the option
    await element.selectOption(value).catch(async () => {
      // Fallback: look for option in the opened dropdown
      await page.locator(`text=${value}`).first().tap();
    });
  } else {
    // On desktop, use standard select
    await element.selectOption(value);
  }
}

/**
 * Swipe gesture for mobile (useful for canceling hold-to-record)
 */
export async function swipe(
  page: Page,
  options: {
    startX: number;
    startY: number;
    endX: number;
    endY: number;
    duration?: number;
  }
): Promise<void> {
  const isMobile = await isMobileDevice(page);
  
  if (!isMobile) {
    // On desktop, just simulate with mouse drag
    await page.mouse.move(options.startX, options.startY);
    await page.mouse.down();
    await page.mouse.move(options.endX, options.endY);
    await page.mouse.up();
    return;
  }
  
  // On mobile, use touch events
  const duration = options.duration || 300;
  
  await page.evaluate(
    ({ startX, startY, endX, endY, duration }: { 
      startX: number; 
      startY: number; 
      endX: number; 
      endY: number; 
      duration: number;
    }) => {
      return new Promise<void>((resolve) => {
        const element = document.elementFromPoint(startX, startY);
        if (!element) {
          resolve();
          return;
        }
        
        const touch = new Touch({
          identifier: Date.now(),
          target: element,
          clientX: startX,
          clientY: startY,
          screenX: startX,
          screenY: startY,
        });
        
        const touchStartEvent = new TouchEvent('touchstart', {
          cancelable: true,
          bubbles: true,
          touches: [touch],
          targetTouches: [touch],
          changedTouches: [touch],
        });
        
        element.dispatchEvent(touchStartEvent);
        
        // Simulate move
        setTimeout(() => {
          const moveTouch = new Touch({
            identifier: touch.identifier,
            target: element,
            clientX: endX,
            clientY: endY,
            screenX: endX,
            screenY: endY,
          });
          
          const touchMoveEvent = new TouchEvent('touchmove', {
            cancelable: true,
            bubbles: true,
            touches: [moveTouch],
            targetTouches: [moveTouch],
            changedTouches: [moveTouch],
          });
          
          element.dispatchEvent(touchMoveEvent);
          
          const touchEndEvent = new TouchEvent('touchend', {
            cancelable: true,
            bubbles: true,
            touches: [],
            targetTouches: [],
            changedTouches: [moveTouch],
          });
          
          element.dispatchEvent(touchEndEvent);
          resolve();
        }, duration);
      });
    },
    { startX: options.startX, startY: options.startY, endX: options.endX, endY: options.endY, duration }
  );
}

/**
 * Check if an element is visible with mobile-friendly waiting
 */
export async function isElementVisible(
  page: Page,
  selector: string,
  options: { timeout?: number } = {}
): Promise<boolean> {
  const isMobile = await isMobileDevice(page);
  const timeout = options.timeout || (isMobile ? 8000 : 5000);
  
  try {
    await page.locator(selector).first().waitFor({ state: 'visible', timeout });
    return true;
  } catch {
    return false;
  }
}

/**
 * Wait for Flutter app to be fully loaded and interactive
 */
export async function waitForFlutterReady(page: Page, timeout: number = 30000): Promise<boolean> {
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

/**
 * Enable Flutter Web accessibility mode
 * This is required for semantic elements to be available in the DOM
 */
export async function enableFlutterAccessibility(page: Page): Promise<void> {
  // Look for the "Enable accessibility" button that Flutter Web shows
  const accessibilityButton = page.locator('[aria-label="Enable accessibility"]');
  
  // Wait for it to be available
  const isPresent = await accessibilityButton.count() > 0;
  
  if (isPresent) {
    // The button is outside viewport, use force click or JavaScript
    try {
      await accessibilityButton.click({ force: true, timeout: 5000 });
      console.log('Clicked Enable accessibility button (force)');
    } catch {
      // Fallback: Use JavaScript to trigger click
      await page.evaluate(() => {
        const btn = document.querySelector('[aria-label="Enable accessibility"]') as HTMLElement;
        if (btn) btn.click();
      });
      console.log('Clicked Enable accessibility button (JS)');
    }
    
    // Wait for semantics tree to be created
    await page.waitForTimeout(2000);
    
    // Verify semantics are now available
    const hasChildren = await page.evaluate(() => {
      const host = document.querySelector('flt-semantics-host');
      return host ? host.children.length > 0 : false;
    });
    
    if (!hasChildren) {
      // Try Tab key to trigger semantics
      await page.keyboard.press('Tab');
      await page.waitForTimeout(1000);
    }
  }
}

/**
 * Setup anonymous account and navigate to home screen
 * Handles the WelcomeScreen flow that appears on first launch
 */
export async function setupAnonymousAccount(page: Page): Promise<void> {
  await page.goto('/');
  await waitForFlutterReady(page);
  
  // Enable accessibility to make Flutter elements accessible
  await enableFlutterAccessibility(page);
  
  // Wait a bit more for the semantics tree
  await page.waitForTimeout(2000);
  
  // Check if we're on the Welcome screen (has "Continue Without Account" button)
  const onWelcomeScreen = await isElementVisible(page, 'text=Continue Without Account', { timeout: 5000 });
  
  if (onWelcomeScreen) {
    // Click to continue without account (creates anonymous account)
    await clickElement(page, 'text=Continue Without Account', { timeout: 10000 });
    
    // Wait for the home screen to load
    await page.waitForTimeout(3000);
  }
  
  // Verify we're on the home screen - use OR selector pattern
  const homeScreen = page.locator('text=Ash Trail').or(
    page.locator('text=Analytics')
  ).or(
    page.locator('text=Recent Entries')
  ).or(
    page.locator('[key="add-log-button"]')
  );
  
  await homeScreen.first().waitFor({ state: 'visible', timeout: 15000 });
}

/**
 * Navigate to a specific screen from the home screen
 */
export async function navigateToScreen(page: Page, screenName: 'History' | 'Analytics' | 'Export' | 'Profile'): Promise<void> {
  // First ensure we're on the home screen
  const screenButton = page.locator(`text=${screenName}`).first();
  
  try {
    await screenButton.waitFor({ state: 'visible', timeout: 5000 });
    await clickElement(page, `text=${screenName}`, { timeout: 5000 });
    await page.waitForTimeout(1000); // Wait for navigation animation
  } catch {
    // If the direct button isn't visible, try looking for it in a different location
    // Some screens might be accessed via app bar icons
    const appBarIcon = page.locator(`[key="${screenName.toLowerCase()}-button"], button:has-text("${screenName}")`).first();
    await appBarIcon.click();
    await page.waitForTimeout(1000);
  }
}
