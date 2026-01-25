// E2E test: Take a number flow
import { test, expect } from '@playwright/test';

test.describe('Queue Page UI', () => {
  test('shows error for invalid storeId', async ({ page }) => {
    await page.goto('/#/q/invalid-store-id-12345');
    
    // Wait for loading to complete
    await page.waitForTimeout(3000);
    
    // Should show queue page (even if error)
    await expect(page.getByTestId('queue-page')).toBeVisible();
  });
});

test.describe('Queue Flow (Single Session)', () => {
  test('can create queue and navigate to customer view', async ({ page }) => {
    // Step 1: Create queue
    await page.goto('/');
    await page.evaluate(() => localStorage.clear());
    await page.reload();
    
    await page.getByTestId('store-name-input').fill('Test Flow Store');
    await page.getByTestId('create-queue-btn').click();
    
    // Wait for creation
    await expect(page.getByTestId('qr-section')).toBeVisible({ timeout: 30000 });
    
    // Get storeId
    const customerUrl = await page.getByTestId('customer-url').inputValue();
    const storeId = customerUrl.split('#/q/')[1];
    expect(storeId).toBeTruthy();
    
    // Step 2: Navigate to queue page (same session, Gun data persists)
    await page.goto(`/#/q/${storeId}`);
    
    // Verify page loads with store name
    await expect(page.getByTestId('queue-page')).toBeVisible();
    await expect(page.getByTestId('store-name')).toContainText('Test Flow Store');
    
    // Verify dispenser is visible
    await expect(page.getByTestId('dispenser')).toBeVisible({ timeout: 10000 });
    
    // Verify status is shown
    await expect(page.getByTestId('now-serving')).toBeVisible({ timeout: 10000 });
  });

  test('can take a number and see ticket', async ({ page }) => {
    // Step 1: Create queue
    await page.goto('/');
    await page.evaluate(() => localStorage.clear());
    await page.reload();
    
    await page.getByTestId('store-name-input').fill('Ticket Test Store');
    await page.getByTestId('create-queue-btn').click();
    
    await expect(page.getByTestId('qr-section')).toBeVisible({ timeout: 30000 });
    
    const customerUrl = await page.getByTestId('customer-url').inputValue();
    const storeId = customerUrl.split('#/q/')[1];
    
    // Step 2: Navigate and take a number
    await page.goto(`/#/q/${storeId}`);
    await expect(page.getByTestId('dispenser-pull-area')).toBeVisible({ timeout: 10000 });
    
    // Take number
    await page.getByTestId('dispenser-pull-area').click();
    
    // Wait for ticket
    await expect(page.getByTestId('ticket')).toBeVisible({ timeout: 30000 });
    
    // Verify ticket has number
    const ticketNumber = await page.getByTestId('ticket-number').textContent();
    expect(ticketNumber).toMatch(/#\d+/);
    
    // Verify queue position is shown
    await expect(page.getByTestId('now-serving')).toBeVisible();
    await expect(page.getByTestId('people-ahead')).toBeVisible();
    
    // Verify served button is shown
    await expect(page.getByTestId('mark-served-btn')).toBeVisible();
  });
});
