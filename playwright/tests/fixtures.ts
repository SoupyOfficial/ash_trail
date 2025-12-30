import { test as base } from '@playwright/test';
import type { Page } from '@playwright/test';
import {
  clickElement,
  fillInput,
  selectOption,
  waitForElement,
} from './helpers/device-helpers';

/**
 * Page Object Model for AshTrail Logging System
 * 
 * Provides reusable methods for interacting with the app on both web and mobile
 */

export class LogEntryPage {
  constructor(private page: Page) {}

  async goto() {
    await this.page.goto('/');
    await this.page.waitForLoadState('networkidle');
  }

  async clickAddButton() {
    await clickElement(this.page, '[data-testid="add-log-button"]', {}).catch(async () => {
      await clickElement(this.page, 'button[aria-label*="add"]', {});
    });
  }

  async fillLogEntry(data: {
    eventType?: string;
    value?: string;
    unit?: string;
    note?: string;
    tags?: string;
  }) {
    if (data.eventType) {
      await selectOption(this.page, 'select[name="eventType"]', data.eventType, {}).catch(async () => {
        await clickElement(this.page, 'text=Event Type', {});
        await clickElement(this.page, `text=${data.eventType}`, {});
      });
    }

    if (data.value) {
      await fillInput(this.page, 'input[name="value"]', data.value);
    }

    if (data.unit) {
      await selectOption(this.page, 'select[name="unit"]', data.unit, {}).catch(async () => {
        await clickElement(this.page, 'text=Unit', {});
        await clickElement(this.page, `text=${data.unit}`, {});
      });
    }

    if (data.note) {
      await fillInput(this.page, 'input[name="note"], textarea[name="note"]', data.note);
    }

    if (data.tags) {
      await fillInput(this.page, 'input[name="tags"]', data.tags);
    }
  }

  async saveLogEntry() {
    await clickElement(this.page, 'button:has-text("Save"), button:has-text("Create")', {});
    await this.page.waitForTimeout(500);
  }

  async createLogEntry(data: Parameters<typeof this.fillLogEntry>[0]) {
    await this.clickAddButton();
    await this.fillLogEntry(data);
    await this.saveLogEntry();
  }

  async getLogEntries() {
    return this.page.locator('[data-testid="log-entry-tile"]');
  }

  async clickLogEntry(index: number = 0) {
    const entries = await this.getLogEntries();
    await entries.nth(index).click();
  }

  async deleteLogEntry(index: number = 0) {
    await this.clickLogEntry(index);
    await clickElement(this.page, 'button:has-text("Delete")', {});
    await clickElement(this.page, 'button:has-text("Confirm"), button:has-text("Yes")', {});
  }

  async editLogEntry(index: number, data: Parameters<typeof this.fillLogEntry>[0]) {
    await this.clickLogEntry(index);
    await clickElement(this.page, 'button:has-text("Edit")', {});
    await this.fillLogEntry(data);
    await clickElement(this.page, 'button:has-text("Save"), button:has-text("Update")', {});
  }

  async searchLogEntries(query: string) {
    await fillInput(this.page, 'input[placeholder*="Search"]', query);
    await this.page.waitForTimeout(500);
  }

  async filterByEventType(eventType: string) {
    await clickElement(this.page, '[data-testid="filter-button"]', {}).catch(async () => {
      await clickElement(this.page, 'button:has-text("Filter")', {});
    });
    await clickElement(this.page, `text=${eventType}`, {});
    await clickElement(this.page, 'button:has-text("Apply")', {});
  }
}

export class SyncPage {
  constructor(private page: Page) {}

  async getSyncStatus() {
    const status = await this.page.locator('[data-testid="sync-status"]').catch(() => {
      return this.page.locator('text=/synced|pending|error/i');
    });
    return status.textContent();
  }

  async triggerSync() {
    await clickElement(this.page, '[data-testid="sync-button"]', {}).catch(async () => {
      await clickElement(this.page, 'button:has-text("Sync")', {});
    });
  }

  async waitForSyncComplete(timeout: number = 10000) {
    await waitForElement(this.page, 'text=/synced|up to date/i', { timeout });
  }

  async getPendingCount() {
    const pending = await this.page.locator('[data-testid="pending-count"]').catch(() => {
      return this.page.locator('text=/pending/i');
    });
    const text = await pending.textContent();
    const match = text?.match(/\d+/);
    return match ? parseInt(match[0]) : 0;
  }
}

export class AnalyticsPage {
  constructor(private page: Page) {}

  async goto() {
    await this.page.goto('/');
    await clickElement(this.page, 'text=Analytics', {}).catch(async () => {
      await clickElement(this.page, '[data-testid="analytics-tab"]', {});
    });
    await waitForElement(this.page, 'canvas, svg', { timeout: 10000 });
  }

  async selectTimeRange(range: string) {
    await clickElement(this.page, '[data-testid="range-selector"]', {}).catch(async () => {
      await clickElement(this.page, 'text=Today, text=This Week', {});
    });
    await clickElement(this.page, `text=${range}`, {});
    await this.page.waitForTimeout(1000);
  }

  async selectGroupBy(groupBy: string) {
    await clickElement(this.page, '[data-testid="group-by-selector"]', {}).catch(async () => {
      await clickElement(this.page, 'text=Group By', {});
    });
    await clickElement(this.page, `text=${groupBy}`, {});
    await this.page.waitForTimeout(1000);
  }

  async getChartElements() {
    return this.page.locator('canvas, svg');
  }

  async getStatistics() {
    const stats: Record<string, string> = {};
    
    const total = await this.page.locator('text=/total/i').textContent();
    if (total) stats.total = total;

    const average = await this.page.locator('text=/average/i').textContent();
    if (average) stats.average = average;

    const count = await this.page.locator('text=/count/i').textContent();
    if (count) stats.count = count;

    return stats;
  }

  async getEventTypeBreakdown() {
    const breakdown: Record<string, number> = {};
    
    const items = await this.page.locator('[data-testid="event-type-item"]').all();
    for (const item of items) {
      const text = await item.textContent();
      const match = text?.match(/(\\w+):\\s*(\\d+)/);
      if (match) {
        breakdown[match[1]] = parseInt(match[2]);
      }
    }

    return breakdown;
  }
}

// Extend base test with page objects
export const test = base.extend<{
  logEntryPage: LogEntryPage;
  syncPage: SyncPage;
  analyticsPage: AnalyticsPage;
}>({
  logEntryPage: async ({ page }, use) => {
    await use(new LogEntryPage(page));
  },
  syncPage: async ({ page }, use) => {
    await use(new SyncPage(page));
  },
  analyticsPage: async ({ page }, use) => {
    await use(new AnalyticsPage(page));
  },
});

export { expect } from '@playwright/test';
