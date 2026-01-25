// E2E test: Create queue flow
import { test, expect } from '@playwright/test';

test.describe('Create Queue Flow', () => {
  test.beforeEach(async ({ page }) => {
    // Clear localStorage before each test
    await page.goto('/');
    await page.evaluate(() => localStorage.clear());
    await page.reload();
  });

  test('should display landing page with form', async ({ page }) => {
    await page.goto('/');
    
    // Check page elements
    await expect(page.getByTestId('landing-page')).toBeVisible();
    await expect(page.getByTestId('store-name-input')).toBeVisible();
    await expect(page.getByTestId('create-queue-btn')).toBeVisible();
  });

  test('create button disabled when store name is empty', async ({ page }) => {
    await page.goto('/');
    
    // Button should be disabled when input is empty
    await expect(page.getByTestId('create-queue-btn')).toBeDisabled();
    
    // Type something
    await page.getByTestId('store-name-input').fill('Test');
    await expect(page.getByTestId('create-queue-btn')).toBeEnabled();
    
    // Clear it
    await page.getByTestId('store-name-input').fill('');
    await expect(page.getByTestId('create-queue-btn')).toBeDisabled();
  });

  test('input limits store name to 50 characters', async ({ page }) => {
    await page.goto('/');
    
    // Enter name longer than 50 chars - input should truncate
    const longName = 'A'.repeat(60);
    await page.getByTestId('store-name-input').fill(longName);
    
    // Input value should be truncated to 50 chars
    const value = await page.getByTestId('store-name-input').inputValue();
    expect(value.length).toBe(50);
  });

  test('should show loading animation during queue creation', async ({ page }) => {
    await page.goto('/');
    
    // Enter store name
    await page.getByTestId('store-name-input').fill('Test Bakery');
    await page.getByTestId('create-queue-btn').click();
    
    // Should show loading animation
    await expect(page.getByTestId('loading-animation')).toBeVisible();
  });

  test('should create queue and display QR code', async ({ page }) => {
    await page.goto('/');
    
    // Enter store name
    await page.getByTestId('store-name-input').fill('Test Bakery');
    await page.getByTestId('create-queue-btn').click();
    
    // Wait for creation (PoW takes a few seconds)
    await expect(page.getByTestId('qr-section')).toBeVisible({ timeout: 30000 });
    
    // Verify QR code is displayed
    await expect(page.getByTestId('qr-code')).toBeVisible();
    
    // Verify admin URL is shown
    await expect(page.getByTestId('admin-url')).toBeVisible();
    const adminUrl = await page.getByTestId('admin-url').inputValue();
    expect(adminUrl).toContain('#/admin/');
  });

  test('should have working download QR button', async ({ page }) => {
    await page.goto('/');
    
    // Create queue
    await page.getByTestId('store-name-input').fill('Download Test');
    await page.getByTestId('create-queue-btn').click();
    
    // Wait for creation
    await expect(page.getByTestId('qr-section')).toBeVisible({ timeout: 30000 });
    
    // Download button should be visible and clickable
    await expect(page.getByTestId('download-qr')).toBeVisible();
    await expect(page.getByTestId('download-qr')).toBeEnabled();
  });

  test('should have working copy admin URL button', async ({ page }) => {
    await page.goto('/');
    
    // Create queue
    await page.getByTestId('store-name-input').fill('Copy Test');
    await page.getByTestId('create-queue-btn').click();
    
    // Wait for creation
    await expect(page.getByTestId('qr-section')).toBeVisible({ timeout: 30000 });
    
    // Copy button should be visible
    await expect(page.getByTestId('copy-admin-url')).toBeVisible();
  });

  test('should navigate to admin panel from success screen', async ({ page }) => {
    await page.goto('/');
    
    // Create queue
    await page.getByTestId('store-name-input').fill('Admin Nav Test');
    await page.getByTestId('create-queue-btn').click();
    
    // Wait for creation
    await expect(page.getByTestId('go-to-admin')).toBeVisible({ timeout: 30000 });
    
    // Click admin link
    await page.getByTestId('go-to-admin').click();
    
    // Should navigate to admin page
    await expect(page.getByTestId('admin-page')).toBeVisible();
  });
});
