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
