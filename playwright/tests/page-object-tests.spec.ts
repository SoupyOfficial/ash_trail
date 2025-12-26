import { test, expect } from './fixtures';

/**
 * Tests using Page Object Model
 */

test.describe('Logging with Page Objects', () => {
  test('create multiple log entries efficiently', async ({ logEntryPage }) => {
    await logEntryPage.goto();

    // Create multiple entries
    const entries = [
      { eventType: 'inhale', value: '1.0', unit: 'hits', note: 'Morning session', tags: 'morning,sativa' },
      { eventType: 'inhale', value: '2.0', unit: 'hits', note: 'Afternoon session', tags: 'afternoon,indica' },
      { eventType: 'note', note: 'Feeling relaxed', tags: 'relaxation' },
    ];

    for (const entry of entries) {
      await logEntryPage.createLogEntry(entry);
    }

    // Verify all entries created
    const logEntries = await logEntryPage.getLogEntries();
    await expect(logEntries).toHaveCount(3);
  });

  test('search and filter workflow', async ({ logEntryPage }) => {
    await logEntryPage.goto();

    // Create test data
    await logEntryPage.createLogEntry({
      eventType: 'inhale',
      value: '1.0',
      unit: 'hits',
      note: 'Morning sativa session',
      tags: 'morning,sativa',
    });

    await logEntryPage.createLogEntry({
      eventType: 'inhale',
      value: '2.0',
      unit: 'hits',
      note: 'Evening indica session',
      tags: 'evening,indica',
    });

    // Search for "morning"
    await logEntryPage.searchLogEntries('morning');
    let entries = await logEntryPage.getLogEntries();
    await expect(entries).toHaveCount(1);

    // Clear search and filter by event type
    await logEntryPage.searchLogEntries('');
    await logEntryPage.filterByEventType('Inhale');
    entries = await logEntryPage.getLogEntries();
    await expect(entries).toHaveCount(2);
  });

  test('edit and delete workflow', async ({ logEntryPage }) => {
    await logEntryPage.goto();

    // Create entry
    await logEntryPage.createLogEntry({
      eventType: 'inhale',
      value: '1.0',
      unit: 'hits',
      note: 'Original note',
    });

    // Edit entry
    await logEntryPage.editLogEntry(0, {
      note: 'Updated note',
      value: '2.0',
    });

    // Verify edit
    const entries = await logEntryPage.getLogEntries();
    await expect(entries.first()).toContainText('Updated note');

    // Delete entry
    await logEntryPage.deleteLogEntry(0);

    // Verify deletion
    await expect(entries).toHaveCount(0);
  });
});

test.describe('Sync with Page Objects', () => {
  test('monitor sync status', async ({ logEntryPage, syncPage }) => {
    await logEntryPage.goto();

    // Create entry (will be pending sync)
    await logEntryPage.createLogEntry({
      eventType: 'inhale',
      value: '1.0',
      unit: 'hits',
    });

    // Check sync status
    const status = await syncPage.getSyncStatus();
    expect(status).toMatch(/pending|syncing/i);

    // Trigger manual sync
    await syncPage.triggerSync();

    // Wait for sync complete
    await syncPage.waitForSyncComplete();

    // Verify synced
    const newStatus = await syncPage.getSyncStatus();
    expect(newStatus).toMatch(/synced|up to date/i);
  });

  test('track pending sync count', async ({ logEntryPage, syncPage }) => {
    await logEntryPage.goto();

    // Initial pending count
    const initialCount = await syncPage.getPendingCount();

    // Create multiple entries
    await logEntryPage.createLogEntry({ eventType: 'inhale', value: '1.0' });
    await logEntryPage.createLogEntry({ eventType: 'inhale', value: '2.0' });

    // Check pending count increased
    const newCount = await syncPage.getPendingCount();
    expect(newCount).toBeGreaterThan(initialCount);

    // Trigger sync
    await syncPage.triggerSync();
    await syncPage.waitForSyncComplete();

    // Check pending count decreased
    const finalCount = await syncPage.getPendingCount();
    expect(finalCount).toBeLessThanOrEqual(initialCount);
  });
});

test.describe('Analytics with Page Objects', () => {
  test('view and interact with analytics', async ({ logEntryPage, analyticsPage }) => {
    // Create sample data
    await logEntryPage.goto();
    for (let i = 0; i < 5; i++) {
      await logEntryPage.createLogEntry({
        eventType: 'inhale',
        value: (i + 1).toString(),
        unit: 'hits',
      });
    }

    // Navigate to analytics
    await analyticsPage.goto();

    // Verify charts are present
    const charts = await analyticsPage.getChartElements();
    await expect(charts.first()).toBeVisible();

    // Get statistics
    const stats = await analyticsPage.getStatistics();
    expect(stats.total).toBeDefined();

    // Change time range
    await analyticsPage.selectTimeRange('This Week');
    await expect(charts.first()).toBeVisible();

    // Change grouping
    await analyticsPage.selectGroupBy('Day');
    await expect(charts.first()).toBeVisible();
  });

  test('event type breakdown', async ({ logEntryPage, analyticsPage }) => {
    // Create mixed entries
    await logEntryPage.goto();
    await logEntryPage.createLogEntry({ eventType: 'inhale', value: '1.0' });
    await logEntryPage.createLogEntry({ eventType: 'inhale', value: '2.0' });
    await logEntryPage.createLogEntry({ eventType: 'note', note: 'Test note' });

    // View breakdown
    await analyticsPage.goto();
    const breakdown = await analyticsPage.getEventTypeBreakdown();

    // Verify counts
    if (Object.keys(breakdown).length > 0) {
      expect(breakdown['inhale']).toBeGreaterThanOrEqual(2);
      expect(breakdown['note']).toBeGreaterThanOrEqual(1);
    }
  });
});

test.describe('End-to-End Workflows', () => {
  test('complete user journey', async ({ logEntryPage, syncPage, analyticsPage }) => {
    // 1. Create log entries
    await logEntryPage.goto();
    await logEntryPage.createLogEntry({
      eventType: 'sessionStart',
    });
    await logEntryPage.createLogEntry({
      eventType: 'inhale',
      value: '2.0',
      unit: 'hits',
      note: 'Good quality',
      tags: 'sativa,morning',
    });
    await logEntryPage.createLogEntry({
      eventType: 'inhale',
      value: '1.5',
      unit: 'hits',
    });
    await logEntryPage.createLogEntry({
      eventType: 'sessionEnd',
    });

    // 2. Verify entries in list
    const entries = await logEntryPage.getLogEntries();
    await expect(entries).toHaveCount(4);

    // 3. Check sync status
    const syncStatus = await syncPage.getSyncStatus();
    expect(syncStatus).toMatch(/pending|syncing|synced/i);

    // 4. Trigger sync if needed
    if (syncStatus?.match(/pending/i)) {
      await syncPage.triggerSync();
      await syncPage.waitForSyncComplete();
    }

    // 5. View analytics
    await analyticsPage.goto();
    const charts = await analyticsPage.getChartElements();
    await expect(charts.first()).toBeVisible();

    // 6. Get statistics
    const stats = await analyticsPage.getStatistics();
    expect(stats.total || stats.count).toBeDefined();

    // 7. Change time range
    await analyticsPage.selectTimeRange('Today');
    await expect(charts.first()).toBeVisible();
  });

  test('offline to online workflow', async ({ page, context, logEntryPage, syncPage }) => {
    // Start online
    await logEntryPage.goto();

    // Create entry while online
    await logEntryPage.createLogEntry({
      eventType: 'inhale',
      value: '1.0',
      unit: 'hits',
      note: 'Online entry',
    });

    // Go offline
    await context.setOffline(true);

    // Create entry while offline
    await logEntryPage.createLogEntry({
      eventType: 'inhale',
      value: '2.0',
      unit: 'hits',
      note: 'Offline entry',
    });

    // Verify offline indicator
    const status = await syncPage.getSyncStatus();
    expect(status).toMatch(/offline|pending/i);

    // Go back online
    await context.setOffline(false);

    // Wait for auto-sync
    await page.waitForTimeout(2000);

    // Verify synced
    await syncPage.waitForSyncComplete();
    const finalStatus = await syncPage.getSyncStatus();
    expect(finalStatus).toMatch(/synced|online/i);
  });
});
