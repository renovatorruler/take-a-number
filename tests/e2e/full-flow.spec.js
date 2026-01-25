// E2E test: Full flow - create queue → take number → mark served
import { test, expect } from '@playwright/test';

test.describe('Full Customer Journey', () => {
  test('complete flow: create queue → take number → mark served → see thanks', async ({ page }) => {
    // Step 1: Create queue
    await page.goto('/');
    await page.evaluate(() => localStorage.clear());
    await page.reload();
    
    await page.getByTestId('store-name-input').fill('Full Journey Store');
    await page.getByTestId('create-queue-btn').click();
    
    // Wait for queue creation
    await expect(page.getByTestId('qr-section')).toBeVisible({ timeout: 30000 });
    
    // Get storeId
    const customerUrl = await page.getByTestId('customer-url').inputValue();
    const storeId = customerUrl.split('#/q/')[1];
    expect(storeId).toBeTruthy();
    
    // Step 2: Navigate to queue and take number
    await page.goto(`/#/q/${storeId}`);
    await expect(page.getByTestId('queue-page')).toBeVisible();
    await expect(page.getByTestId('store-name')).toContainText('Full Journey Store');
    
    await expect(page.getByTestId('dispenser')).toBeVisible({ timeout: 10000 });
    await page.getByTestId('dispenser-pull-area').click();
    
    // Wait for ticket
    await expect(page.getByTestId('ticket')).toBeVisible({ timeout: 30000 });
    const ticketNumber = await page.getByTestId('ticket-number').textContent();
    expect(ticketNumber).toMatch(/#\d+/);
    
    // Step 3: Mark as served
    await expect(page.getByTestId('mark-served-btn')).toBeVisible();
    await page.getByTestId('mark-served-btn').click();
    
    // Confirm dialog
    await expect(page.getByTestId('confirm-dialog')).toBeVisible();
    await page.getByTestId('confirm-btn').click();
    
    // Step 4: See served screen
    await expect(page.getByTestId('served-screen')).toBeVisible({ timeout: 10000 });
    await expect(page.getByTestId('social-prompt')).toBeVisible();
    await expect(page.getByTestId('twitter-link')).toBeVisible();
    await expect(page.getByTestId('take-another-btn')).toBeVisible();
  });

  test('can cancel marking as served', async ({ page }) => {
    // Create queue
    await page.goto('/');
    await page.evaluate(() => localStorage.clear());
    await page.reload();
    
    await page.getByTestId('store-name-input').fill('Cancel Test Store');
    await page.getByTestId('create-queue-btn').click();
    
    await expect(page.getByTestId('qr-section')).toBeVisible({ timeout: 30000 });
    
    const customerUrl = await page.getByTestId('customer-url').inputValue();
    const storeId = customerUrl.split('#/q/')[1];
    
    // Take number
    await page.goto(`/#/q/${storeId}`);
    await expect(page.getByTestId('dispenser-pull-area')).toBeVisible({ timeout: 10000 });
    await page.getByTestId('dispenser-pull-area').click();
    await expect(page.getByTestId('ticket')).toBeVisible({ timeout: 30000 });
    
    // Try to mark served
    await page.getByTestId('mark-served-btn').click();
    await expect(page.getByTestId('confirm-dialog')).toBeVisible();
    
    // Cancel
    await page.getByTestId('cancel-btn').click();
    
    // Dialog should close, ticket remains
    await expect(page.getByTestId('confirm-dialog')).not.toBeVisible();
    await expect(page.getByTestId('ticket')).toBeVisible();
  });

  test('can take another number after being served', async ({ page }) => {
    // Create queue
    await page.goto('/');
    await page.evaluate(() => localStorage.clear());
    await page.reload();
    
    await page.getByTestId('store-name-input').fill('Another Test Store');
    await page.getByTestId('create-queue-btn').click();
    
    await expect(page.getByTestId('qr-section')).toBeVisible({ timeout: 30000 });
    
    const customerUrl = await page.getByTestId('customer-url').inputValue();
    const storeId = customerUrl.split('#/q/')[1];
    
    // Take first number
    await page.goto(`/#/q/${storeId}`);
    await expect(page.getByTestId('dispenser-pull-area')).toBeVisible({ timeout: 10000 });
    await page.getByTestId('dispenser-pull-area').click();
    await expect(page.getByTestId('ticket-number')).toBeVisible({ timeout: 30000 });
    const firstTicket = await page.getByTestId('ticket-number').textContent();
    
    // Mark served
    await page.getByTestId('mark-served-btn').click();
    await page.getByTestId('confirm-btn').click();
    await expect(page.getByTestId('served-screen')).toBeVisible({ timeout: 10000 });
    
    // Take another
    await page.getByTestId('take-another-btn').click();
    await expect(page.getByTestId('dispenser')).toBeVisible({ timeout: 10000 });
    
    // Get new ticket
    await page.getByTestId('dispenser-pull-area').click();
    await expect(page.getByTestId('ticket-number')).toBeVisible({ timeout: 30000 });
    const secondTicket = await page.getByTestId('ticket-number').textContent();
    
    // Should be different (higher) number
    expect(secondTicket).not.toBe(firstTicket);
    const firstNum = parseInt(firstTicket.replace('#', ''));
    const secondNum = parseInt(secondTicket.replace('#', ''));
    expect(secondNum).toBeGreaterThan(firstNum);
  });
});
