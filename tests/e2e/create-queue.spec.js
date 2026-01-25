// create-queue.spec.js - E2E tests for store creation flow
import { test, expect } from '@playwright/test';

test.describe('Create Queue Flow', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
  });
  
  test('landing page shows create queue form', async ({ page }) => {
    await expect(page.getByTestId('landing-page')).toBeVisible();
    await expect(page.getByTestId('store-name-input')).toBeVisible();
    await expect(page.getByTestId('create-queue-btn')).toBeVisible();
  });
  
  test('create button is disabled when store name is empty', async ({ page }) => {
    const createBtn = page.getByTestId('create-queue-btn');
    await expect(createBtn).toBeDisabled();
  });
  
  test('create button is enabled when store name is entered', async ({ page }) => {
    await page.getByTestId('store-name-input').fill('Test Store');
    const createBtn = page.getByTestId('create-queue-btn');
    await expect(createBtn).toBeEnabled();
  });
  
  test('shows error for empty store name on submit', async ({ page }) => {
    // Fill and clear to trigger validation
    await page.getByTestId('store-name-input').fill('a');
    await page.getByTestId('store-name-input').fill('');
    
    // Button should be disabled
    const createBtn = page.getByTestId('create-queue-btn');
    await expect(createBtn).toBeDisabled();
  });
  
  test('shows loading animation during creation', async ({ page }) => {
    await page.getByTestId('store-name-input').fill('Test Store');
    await page.getByTestId('create-queue-btn').click();
    
    // Should show loading animation
    await expect(page.getByTestId('loading-animation')).toBeVisible();
  });
  
  test('creates queue and shows QR code', async ({ page }) => {
    // Fill in store name
    await page.getByTestId('store-name-input').fill('Test Bakery');
    
    // Click create
    await page.getByTestId('create-queue-btn').click();
    
    // Wait for loading to complete (PoW takes ~2-3 seconds)
    await expect(page.getByTestId('qr-section')).toBeVisible({ timeout: 15000 });
    
    // Should show QR code
    await expect(page.getByTestId('qr-code')).toBeVisible();
    
    // Should show admin URL
    await expect(page.getByTestId('admin-url')).toBeVisible();
    
    // Should show download button
    await expect(page.getByTestId('download-qr')).toBeVisible();
    
    // Should show go to admin button
    await expect(page.getByTestId('go-to-admin')).toBeVisible();
  });
  
  test('admin URL contains correct hash route', async ({ page }) => {
    await page.getByTestId('store-name-input').fill('URL Test Store');
    await page.getByTestId('create-queue-btn').click();
    
    await expect(page.getByTestId('admin-url')).toBeVisible({ timeout: 15000 });
    
    const adminUrl = await page.getByTestId('admin-url').inputValue();
    expect(adminUrl).toMatch(/#\/admin\/[a-f0-9-]+/);
  });
  
  test('copy admin URL button works', async ({ page, context }) => {
    // Grant clipboard permission
    await context.grantPermissions(['clipboard-write', 'clipboard-read']);
    
    await page.getByTestId('store-name-input').fill('Copy Test Store');
    await page.getByTestId('create-queue-btn').click();
    
    await expect(page.getByTestId('copy-admin-url')).toBeVisible({ timeout: 15000 });
    
    await page.getByTestId('copy-admin-url').click();
    
    // Verify clipboard contains the URL
    const clipboardText = await page.evaluate(() => navigator.clipboard.readText());
    expect(clipboardText).toMatch(/#\/admin\/[a-f0-9-]+/);
  });
  
  test('input limits store name to 50 characters', async ({ page }) => {
    // Enter a name that's 50+ chars (input has maxlength=50)
    const longName = 'a'.repeat(60);
    await page.getByTestId('store-name-input').fill(longName);
    
    // Input should be truncated to 50 chars
    const value = await page.getByTestId('store-name-input').inputValue();
    expect(value.length).toBe(50);
  });
});

test.describe('Create Queue - Mobile View', () => {
  test.use({ viewport: { width: 375, height: 667 } });
  
  test('form is usable on mobile', async ({ page }) => {
    await page.goto('/');
    
    await expect(page.getByTestId('store-name-input')).toBeVisible();
    await expect(page.getByTestId('create-queue-btn')).toBeVisible();
    
    // Fill and submit
    await page.getByTestId('store-name-input').fill('Mobile Store');
    await page.getByTestId('create-queue-btn').click();
    
    // Should complete successfully
    await expect(page.getByTestId('qr-section')).toBeVisible({ timeout: 15000 });
  });
});
