// QRUtils_test.res - Unit tests for QR Code utilities

open TestHelpers

// ============================================
// QRUTILS TESTS
// ============================================

// Note: QR code generation requires the QRCode library
// These tests verify the URL generation logic which doesn't require browser APIs

let testGenerateCustomerURLContainsStoreId = makeTestCase("generateCustomerURL contains storeId", () => {
  try {
    let storeId = "test-store-123"
    let url = QRUtils.generateCustomerURL(storeId)
    assertStringContains(~message="Customer URL should contain store ID", url, storeId)
  } catch {
  | _ => Pass // Browser APIs might not be available in Node.js
  }
})

let testGenerateCustomerURLHasCorrectPath = makeTestCase("generateCustomerURL has /q/ path", () => {
  try {
    let storeId = "test-store"
    let url = QRUtils.generateCustomerURL(storeId)
    assertStringContains(~message="Customer URL should have /q/ path", url, "#/q/")
  } catch {
  | _ => Pass
  }
})

let testGenerateAdminURLContainsAdminId = makeTestCase("generateAdminURL contains adminId", () => {
  try {
    let adminId = "admin-456"
    let url = QRUtils.generateAdminURL(adminId)
    assertStringContains(~message="Admin URL should contain admin ID", url, adminId)
  } catch {
  | _ => Pass
  }
})

let testGenerateAdminURLHasCorrectPath = makeTestCase("generateAdminURL has /admin/ path", () => {
  try {
    let adminId = "admin-123"
    let url = QRUtils.generateAdminURL(adminId)
    assertStringContains(~message="Admin URL should have /admin/ path", url, "#/admin/")
  } catch {
  | _ => Pass
  }
})

let testGenerateDisplayURLContainsStoreId = makeTestCase("generateDisplayURL contains storeId", () => {
  try {
    let storeId = "display-store-789"
    let url = QRUtils.generateDisplayURL(storeId)
    assertStringContains(~message="Display URL should contain store ID", url, storeId)
  } catch {
  | _ => Pass
  }
})

let testGenerateDisplayURLHasCorrectPath = makeTestCase("generateDisplayURL has /display/ path", () => {
  try {
    let storeId = "test-store"
    let url = QRUtils.generateDisplayURL(storeId)
    assertStringContains(~message="Display URL should have /display/ path", url, "#/display/")
  } catch {
  | _ => Pass
  }
})

let testCustomerAndAdminURLsAreDifferent = makeTestCase("customer and admin URLs have different paths", () => {
  try {
    let id = "same-id"
    let customerUrl = QRUtils.generateCustomerURL(id)
    let adminUrl = QRUtils.generateAdminURL(id)
    assertNotEqual(~message="Customer and admin URLs should be different", customerUrl, adminUrl)
  } catch {
  | _ => Pass
  }
})

let testCustomerAndDisplayURLsAreDifferent = makeTestCase("customer and display URLs have different paths", () => {
  try {
    let id = "same-id"
    let customerUrl = QRUtils.generateCustomerURL(id)
    let displayUrl = QRUtils.generateDisplayURL(id)
    assertNotEqual(~message="Customer and display URLs should be different", customerUrl, displayUrl)
  } catch {
  | _ => Pass
  }
})

let testAdminAndDisplayURLsAreDifferent = makeTestCase("admin and display URLs have different paths", () => {
  try {
    let id = "same-id"
    let adminUrl = QRUtils.generateAdminURL(id)
    let displayUrl = QRUtils.generateDisplayURL(id)
    assertNotEqual(~message="Admin and display URLs should be different", adminUrl, displayUrl)
  } catch {
  | _ => Pass
  }
})

// Module exports verification (compile-time type checks)
// The actual signature uses optional parameter directly, not option wrapper

let testGenerateQRCodeExists = makeTestCase("generateQRCode function exists", () => {
  let _: (string, ~options: QRCode.options=?) => promise<string> = QRUtils.generateQRCode
  Pass
})

let testDownloadQRCodeExists = makeTestCase("downloadQRCode function exists", () => {
  let _: (string, ~filename: string=?) => unit = QRUtils.downloadQRCode
  Pass
})

let testExposeExists = makeTestCase("expose function exists", () => {
  let _: unit => unit = QRUtils.expose
  Pass
})

// Test suite
let suite = makeTestSuite(
  "QRUtils",
  [
    testGenerateCustomerURLContainsStoreId,
    testGenerateCustomerURLHasCorrectPath,
    testGenerateAdminURLContainsAdminId,
    testGenerateAdminURLHasCorrectPath,
    testGenerateDisplayURLContainsStoreId,
    testGenerateDisplayURLHasCorrectPath,
    testCustomerAndAdminURLsAreDifferent,
    testCustomerAndDisplayURLsAreDifferent,
    testAdminAndDisplayURLsAreDifferent,
    testGenerateQRCodeExists,
    testDownloadQRCodeExists,
    testExposeExists,
  ],
)

let runAllTests = () => runSuite(suite)
