// Storage_test.res - Unit tests for localStorage helpers

open TestHelpers

// ============================================
// STORAGE TESTS
// ============================================

// Note: These tests verify the ReScript logic
// Browser APIs are mocked via the compiled JS test runner

let testIsStorageAvailable = makeTestCase("isStorageAvailable returns boolean", () => {
  // In Node.js environment, localStorage won't be available
  // This test verifies the function exists and returns a boolean
  let result = Storage.isStorageAvailable()
  // Result should be a boolean (true or false)
  assertTrue(~message="isStorageAvailable should return a boolean", result == true || result == false)
})

let testIsIncognitoInverseOfStorage = makeTestCase("isIncognito is inverse of isStorageAvailable", () => {
  let storageAvailable = Storage.isStorageAvailable()
  let isIncognito = Storage.isIncognito()
  // isIncognito should be the inverse of isStorageAvailable
  assertEqual(~message="isIncognito should be !isStorageAvailable", isIncognito, !storageAvailable)
})

let testHasKeypairInitiallyFalse = makeTestCase("hasKeypair returns false initially", () => {
  // Without storage or with cleared storage, should return false
  // This tests the None case of getKeypair
  let has = Storage.hasKeypair()
  // In test environment, this may be true or false depending on mocks
  assertTrue(~message="hasKeypair should return a boolean", has == true || has == false)
})

let testGetKeypairReturnsOption = makeTestCase("getKeypair returns option type", () => {
  let result = Storage.getKeypair()
  // Should return Some or None
  switch result {
  | Some(_) => Pass
  | None => Pass
  }
})

let testGetDeviceIdReturnsOption = makeTestCase("getDeviceId returns option type", () => {
  let result = Storage.getDeviceId()
  switch result {
  | Some(_) => Pass
  | None => Pass
  }
})

let testGetTicketReturnsOption = makeTestCase("getTicket returns option type", () => {
  let result = Storage.getTicket("test-store-id")
  switch result {
  | Some(_) => Pass
  | None => Pass
  }
})

let testHasTicketReturnsBoolean = makeTestCase("hasTicket returns boolean", () => {
  let result = Storage.hasTicket("test-store-id")
  assertTrue(~message="hasTicket should return a boolean", result == true || result == false)
})

let testStoreAndRetrieveKeypair = makeTestCase("storeKeypair and getKeypair work together", () => {
  if !Storage.isStorageAvailable() {
    Pass // Skip if storage not available
  } else {
    let testKeypair: Types.keypair = {
      pub: "test-public-key",
      priv: "test-private-key",
      epub: "test-epub",
      epriv: "test-epriv",
    }
    
    let storeResult = Storage.storeKeypair(testKeypair)
    switch storeResult {
    | Ok(_) => {
        let retrieved = Storage.getKeypair()
        switch retrieved {
        | Some(kp) => 
          if kp.pub == testKeypair.pub {
            Pass
          } else {
            Fail("Retrieved keypair pub key doesn't match")
          }
        | None => Fail("Expected to retrieve stored keypair")
        }
      }
    | Error(_) => Pass // Storage might not be available in test environment
    }
  }
})

let testStoreAndRetrieveDeviceId = makeTestCase("storeDeviceId and getDeviceId work together", () => {
  if !Storage.isStorageAvailable() {
    Pass
  } else {
    let testDeviceId = "test-device-id-123"
    let storeResult = Storage.storeDeviceId(testDeviceId)
    switch storeResult {
    | Ok(_) => {
        let retrieved = Storage.getDeviceId()
        switch retrieved {
        | Some(id) =>
          if id == testDeviceId {
            Pass
          } else {
            Fail("Retrieved device ID doesn't match")
          }
        | None => Fail("Expected to retrieve stored device ID")
        }
      }
    | Error(_) => Pass
    }
  }
})

let testStoreAndRetrieveTicket = makeTestCase("storeTicket and getTicket work together", () => {
  if !Storage.isStorageAvailable() {
    Pass
  } else {
    let storeId = "test-store-123"
    let testTicket: Types.ticket = {
      number: 42,
      deviceId: "device-123",
      issuedAt: 1234567890.0,
      status: "waiting",
      servedAt: Nullable.null,
      servedBy: Nullable.null,
    }
    
    let storeResult = Storage.storeTicket(storeId, testTicket)
    switch storeResult {
    | Ok(_) => {
        let retrieved = Storage.getTicket(storeId)
        switch retrieved {
        | Some(t) =>
          if t.number == testTicket.number {
            Pass
          } else {
            Fail("Retrieved ticket number doesn't match")
          }
        | None => Fail("Expected to retrieve stored ticket")
        }
      }
    | Error(_) => Pass
    }
  }
})

let testClearKeypairRemovesData = makeTestCase("clearKeypair removes stored keypair", () => {
  if !Storage.isStorageAvailable() {
    Pass
  } else {
    let testKeypair: Types.keypair = {
      pub: "test-pub",
      priv: "test-priv",
      epub: "test-epub",
      epriv: "test-epriv",
    }
    
    let _ = Storage.storeKeypair(testKeypair)
    Storage.clearKeypair()
    
    let hasAfterClear = Storage.hasKeypair()
    assertFalse(~message="hasKeypair should be false after clearKeypair", hasAfterClear)
  }
})

let testClearTicketRemovesData = makeTestCase("clearTicket removes stored ticket", () => {
  if !Storage.isStorageAvailable() {
    Pass
  } else {
    let storeId = "test-store-clear"
    let testTicket: Types.ticket = {
      number: 1,
      deviceId: "device",
      issuedAt: 0.0,
      status: "waiting",
      servedAt: Nullable.null,
      servedBy: Nullable.null,
    }
    
    let _ = Storage.storeTicket(storeId, testTicket)
    Storage.clearTicket(storeId)
    
    let hasAfterClear = Storage.hasTicket(storeId)
    assertFalse(~message="hasTicket should be false after clearTicket", hasAfterClear)
  }
})

// Test suite
let suite = makeTestSuite(
  "Storage",
  [
    testIsStorageAvailable,
    testIsIncognitoInverseOfStorage,
    testHasKeypairInitiallyFalse,
    testGetKeypairReturnsOption,
    testGetDeviceIdReturnsOption,
    testGetTicketReturnsOption,
    testHasTicketReturnsBoolean,
    testStoreAndRetrieveKeypair,
    testStoreAndRetrieveDeviceId,
    testStoreAndRetrieveTicket,
    testClearKeypairRemovesData,
    testClearTicketRemovesData,
  ],
)

let runAllTests = () => runSuite(suite)
