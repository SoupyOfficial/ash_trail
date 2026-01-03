import { defineConfig, devices } from '@playwright/test';

/**
 * See https://playwright.dev/docs/test-configuration.
 */
export default defineConfig({
  testDir: './tests',
  /* Run tests in files in parallel */
  fullyParallel: true,
  /* Fail the build on CI if you accidentally left test.only in the source code. */
  forbidOnly: !!process.env.CI,
  /* Retry on CI only */
  retries: process.env.CI ? 2 : 0,
  /* Opt out of parallel tests on CI. */
  workers: process.env.CI ? 1 : undefined,
  /* Reporter to use. See https://playwright.dev/docs/test-reporters */
  reporter: [
    ['html'],
    ['list'],
    ['json', { outputFile: 'test-results/results.json' }]
  ],
  /* Shared settings for all the projects below. See https://playwright.dev/docs/api/class-testoptions. */
  use: {
    /* Base URL to use in actions like `await page.goto('/')`. */
    baseURL: 'http://localhost:8080',
    /* Collect trace when retrying the failed test. See https://playwright.dev/docs/trace-viewer */
    trace: 'on-first-retry',
    /* Screenshot on failure */
    screenshot: 'only-on-failure',
    /* Video on failure */
    video: 'retain-on-failure',
  },

  /* Configure projects for major browsers and mobile devices */
  projects: [
    // Setup project - runs once to authenticate and save state
    {
      name: 'setup',
      testMatch: '**/auth.setup.ts',
    },

    // Authenticated tests - use stored auth state
    {
      name: 'chromium',
      use: { 
        ...devices['Desktop Chrome'],
        // Use authenticated state
        storageState: '.auth/user.json',
      },
      dependencies: ['setup'],
    },

    {
      name: 'firefox',
      use: { 
        ...devices['Desktop Firefox'],
        storageState: '.auth/user.json',
      },
      dependencies: ['setup'],
    },

    {
      name: 'webkit',
      use: { 
        ...devices['Desktop Safari'],
        storageState: '.auth/user.json',
      },
      dependencies: ['setup'],
    },

    /* Test against mobile viewports with touch support */
    {
      name: 'Mobile Chrome',
      use: { 
        ...devices['Pixel 5'],
        // Ensure touch events are properly supported
        hasTouch: true,
        isMobile: true,
        storageState: '.auth/user.json',
      },
      dependencies: ['setup'],
    },
    {
      name: 'Mobile Safari',
      use: { 
        ...devices['iPhone 12'],
        // Ensure touch events are properly supported
        hasTouch: true,
        isMobile: true,
        storageState: '.auth/user.json',
      },
      dependencies: ['setup'],
    },
    /* Additional mobile devices for comprehensive testing */
    {
      name: 'Mobile Chrome Landscape',
      use: {
        ...devices['Pixel 5 landscape'],
        hasTouch: true,
        isMobile: true,
        storageState: '.auth/user.json',
      },
      dependencies: ['setup'],
    },
    {
      name: 'Tablet',
      use: {
        ...devices['iPad Pro'],
        hasTouch: true,
        isMobile: true,
        storageState: '.auth/user.json',
      },
      dependencies: ['setup'],
    },
  ],

  /* Run your local dev server before starting the tests */
  webServer: {
    command: 'npx serve ../build/web -l 8080',
    url: 'http://localhost:8080',
    reuseExistingServer: !process.env.CI,
    timeout: 120 * 1000,
  },
});
