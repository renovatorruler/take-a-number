// E2E test: Full flow - create queue → take number → mark served
import { test, expect } from '@playwright/test';

// Helper to create a store and get its ID from customer URL
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

test.describe('Full Flow', () => {
  test('complete flow: create queue → take number → mark served', async ({ page }) => {
    // Create store
    const storeId = await createStoreAndGetId(page, 'Full Flow Store');
    expect(storeId).toBeTruthy();
    
    // Navigate to queue
    await page.goto(`/#/q/${storeId}`);
    
    // Wait for page and verify store name
    await expect(page.getByTestId('queue-page')).toBeVisible();
    await expect(page.getByTestId('store-name')).toContainText('Full Flow Store');
    
    // Take a number
    await expect(page.getByTestId('dispenser')).toBeVisible({ timeout: 10000 });
    await page.getByTestId('dispenser-pull-area').click();
    
    // Wait for ticket
    await expect(page.getByTestId('ticket')).toBeVisible({ timeout: 30000 });
    const ticketNumber = await page.getByTestId('ticket-number').textContent();
    expect(ticketNumber).toMatch(/#\d+/);
    
    // Verify queue position info
    await expect(page.getByTestId('now-serving')).toBeVisible();
    await expect(page.getByTestId('people-ahead')).toBeVisible();
    
    // Mark as served
    await expect(page.getByTestId('mark-served-btn')).toBeVisible();
    await page.getByTestId('mark-served-btn').click();
    
    // Confirm dialog should appear
    await expect(page.getByTestId('confirm-dialog')).toBeVisible();
    await page.getByTestId('confirm-btn').click();
    
    // Verify served screen
    await expect(page.getByTestId('served-screen')).toBeVisible({ timeout: 10000 });
    await expect(page.getByTestId('social-prompt')).toBeVisible();
    await expect(page.getByTestId('twitter-link')).toBeVisible();
    await expect(page.getByTestId('take-another-btn')).toBeVisible();
  });

  test('can cancel mark as served', async ({ page }) => {
    // Create store
    const storeId = await createStoreAndGetId(page, 'Cancel Flow Store');
    expect(storeId).toBeTruthy();
    
    await page.goto(`/#/q/${storeId}`);
    
    // Take a number
    await expect(page.getByTestId('dispenser-pull-area')).toBeVisible({ timeout: 10000 });
    await page.getByTestId('dispenser-pull-area').click();
    await expect(page.getByTestId('ticket')).toBeVisible({ timeout: 30000 });
    
    // Click mark served
    await page.getByTestId('mark-served-btn').click();
    await expect(page.getByTestId('confirm-dialog')).toBeVisible();
    
    // Cancel
    await page.getByTestId('cancel-btn').click();
    
    // Dialog should close, ticket should remain
    await expect(page.getByTestId('confirm-dialog')).not.toBeVisible();
    await expect(page.getByTestId('ticket')).toBeVisible();
  });

  test('can take another number after being served', async ({ page }) => {
    // Create store
    const storeId = await createStoreAndGetId(page, 'Another Number Store');
    expect(storeId).toBeTruthy();
    
    await page.goto(`/#/q/${storeId}`);
    
    // Take first number
    await expect(page.getByTestId('dispenser-pull-area')).toBeVisible({ timeout: 10000 });
    await page.getByTestId('dispenser-pull-area').click();
    await expect(page.getByTestId('ticket-number')).toBeVisible({ timeout: 30000 });
    const firstTicket = await page.getByTestId('ticket-number').textContent();
    
    // Mark as served
    await page.getByTestId('mark-served-btn').click();
    await page.getByTestId('confirm-btn').click();
    await expect(page.getByTestId('served-screen')).toBeVisible({ timeout: 10000 });
    
    // Take another
    await page.getByTestId('take-another-btn').click();
    
    // Should show dispenser
    await expect(page.getByTestId('dispenser')).toBeVisible({ timeout: 10000 });
    
    // Take new number
    await page.getByTestId('dispenser-pull-area').click();
    await expect(page.getByTestId('ticket-number')).toBeVisible({ timeout: 30000 });
    const secondTicket = await page.getByTestId('ticket-number').textContent();
    
    // Should be different number
    expect(secondTicket).not.toBe(firstTicket);
    const firstNum = parseInt(firstTicket.replace('#', ''));
    const secondNum = parseInt(secondTicket.replace('#', ''));
    expect(secondNum).toBeGreaterThan(firstNum);
  });
});
