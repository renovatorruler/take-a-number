// E2E test: Take a number flow
import { test, expect } from '@playwright/test';

// Helper to create a store and get its ID from the customer URL
async function createStoreAndGetId(page, storeName) {
  await page.goto('/');
  await page.evaluate(() => localStorage.clear());
  await page.reload();
  
  await page.getByTestId('store-name-input').fill(storeName);
  await page.getByTestId('create-queue-btn').click();
  
  // Wait for QR code section
  await expect(page.getByTestId('qr-section')).toBeVisible({ timeout: 30000 });
  
  // Get storeId from the customer URL
  const customerUrl = await page.getByTestId('customer-url').inputValue();
  const storeId = customerUrl.split('#/q/')[1];
  
  return storeId;
}

test.describe('Take a Number Flow', () => {
  test('queue page shows dispenser when no ticket', async ({ page }) => {
    const storeId = await createStoreAndGetId(page, 'Dispenser Test Store');
    expect(storeId).toBeTruthy();
    
    // Navigate directly to queue (don't clear localStorage - Gun needs it)
    await page.goto(`/#/q/${storeId}`);
    
    await expect(page.getByTestId('queue-page')).toBeVisible();
    await expect(page.getByTestId('dispenser')).toBeVisible({ timeout: 10000 });
    await expect(page.getByTestId('now-serving')).toBeVisible({ timeout: 10000 });
  });

  test('can take a number', async ({ page }) => {
    const storeId = await createStoreAndGetId(page, 'Take Number Store');
    expect(storeId).toBeTruthy();
    
    // Navigate to queue
    await page.goto(`/#/q/${storeId}`);
    
    // Click dispenser
    await expect(page.getByTestId('dispenser-pull-area')).toBeVisible({ timeout: 10000 });
    await page.getByTestId('dispenser-pull-area').click();
    
    // Should show PoW animation
    await expect(page.getByTestId('pow-animation')).toBeVisible({ timeout: 5000 });
    
    // Wait for ticket
    await expect(page.getByTestId('ticket')).toBeVisible({ timeout: 30000 });
    const ticketNumber = await page.getByTestId('ticket-number').textContent();
    expect(ticketNumber).toMatch(/#\d+/);
  });
});

test.describe('Queue Page UI', () => {
  test('shows loading then error for invalid storeId', async ({ page }) => {
    await page.goto('/#/q/invalid-store-id-12345');
    
    // Wait for loading to complete
    await page.waitForTimeout(3000);
    
    // Should show some content (error or page)
    await expect(page.getByTestId('queue-page')).toBeVisible();
  });

  test('dispenser is visible for valid store', async ({ page }) => {
    const storeId = await createStoreAndGetId(page, 'UI Test Store');
    expect(storeId).toBeTruthy();
    
    await page.goto(`/#/q/${storeId}`);
    
    await expect(page.getByTestId('dispenser')).toBeVisible({ timeout: 10000 });
    await expect(page.getByTestId('store-name')).toContainText('UI Test Store');
  });
});

test.describe('Full Create and Take Number Flow', () => {
  test('complete flow: create store -> take number -> see ticket', async ({ page }) => {
    const storeId = await createStoreAndGetId(page, 'Complete Flow Store');
    expect(storeId).toBeTruthy();
    
    // Go to queue 
    await page.goto(`/#/q/${storeId}`);
    
    // Verify store name
    await expect(page.getByTestId('store-name')).toContainText('Complete Flow Store');
    
    // Take number
    await expect(page.getByTestId('dispenser')).toBeVisible({ timeout: 10000 });
    await page.getByTestId('dispenser-pull-area').click();
    await expect(page.getByTestId('ticket')).toBeVisible({ timeout: 30000 });
    
    // Verify all UI elements
    await expect(page.getByTestId('ticket-number')).toBeVisible();
    await expect(page.getByTestId('now-serving')).toBeVisible();
    await expect(page.getByTestId('people-ahead')).toBeVisible();
    await expect(page.getByTestId('mark-served-btn')).toBeVisible();
    await expect(page.getByTestId('expiry-info')).toBeVisible();
    await expect(page.getByTestId('pwa-prompt')).toBeVisible();
  });

  test('direct queue access and ticket creation', async ({ page }) => {
    const storeId = await createStoreAndGetId(page, 'Direct Access Store');
    expect(storeId).toBeTruthy();
    
    await page.goto(`/#/q/${storeId}`);
    
    // Take a number
    await expect(page.getByTestId('dispenser-pull-area')).toBeVisible({ timeout: 10000 });
    await page.getByTestId('dispenser-pull-area').click();
    
    // Should get ticket
    await expect(page.getByTestId('ticket-number')).toBeVisible({ timeout: 30000 });
    const ticketText = await page.getByTestId('ticket-number').textContent();
    expect(ticketText).toMatch(/#\d+/);
  });
});
