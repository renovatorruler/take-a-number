// Placeholder E2E test file - ensures playwright can run
import { test, expect } from '@playwright/test';

test('app loads', async ({ page }) => {
  await page.goto('/');
  await expect(page.locator('[data-testid="landing-page"]')).toBeVisible();
});

test('queue route works', async ({ page }) => {
  await page.goto('/#/q/test');
  await expect(page.locator('[data-testid="queue-page"]')).toBeVisible();
});

test('admin route works', async ({ page }) => {
  await page.goto('/#/admin/test');
  await expect(page.locator('[data-testid="admin-page"]')).toBeVisible();
});
