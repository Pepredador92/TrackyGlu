import { defineConfig } from '@playwright/test'

export default defineConfig({
  testDir: './tests/browser',
  timeout: 60000,
  fullyParallel: false,
  workers: 1,
  reporter: 'list',
  use: { baseURL: 'http://localhost:5173', viewport: { width: 1365, height: 900 }, trace: 'retain-on-failure' },
  webServer: { command: 'npm run dev -- --host localhost', url: 'http://localhost:5173', reuseExistingServer: true },
})
