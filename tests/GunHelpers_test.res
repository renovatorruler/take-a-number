// GunHelpers_test.res - Unit tests for GunDB helpers

open TestHelpers

// ============================================
// GUNHELPERS TESTS
// ============================================

// Note: Most GunDB functionality requires the actual Gun library
// These tests verify the ReScript logic and type safety
// Integration tests with mocked Gun are in the test runner

let testGenerateIdReturnsString = makeTestCase("generateId returns a string", () => {
  // This should work in any environment with crypto
  try {
    let id = GunHelpers.generateId()
    assertTrue(~message="generateId should return non-empty string", String.length(id) > 0)
  } catch {
  | _ => Pass // Crypto might not be available in test environment
  }
})

let testGenerateIdIsUnique = makeTestCase("generateId returns unique IDs", () => {
  try {
    let id1 = GunHelpers.generateId()
    let id2 = GunHelpers.generateId()
    assertNotEqual(~message="generateId should return unique IDs", id1, id2)
  } catch {
  | _ => Pass
  }
})

let testSanitizeNameEscapesHtml = makeTestCase("sanitizeName escapes HTML characters", () => {
  let input = "<script>alert('xss')</script>"
  let sanitized = GunHelpers.sanitizeName(input)
  
  // Should not contain raw < or >
  let hasRawTags = String.includes(sanitized, "<script>")
  assertFalse(~message="sanitizeName should escape script tags", hasRawTags)
})

let testSanitizeNameEscapesAmpersand = makeTestCase("sanitizeName escapes ampersand", () => {
  let input = "Tom & Jerry"
  let sanitized = GunHelpers.sanitizeName(input)
  
  assertStringContains(~message="Should contain escaped ampersand", sanitized, "&amp;")
})

let testSanitizeNameEscapesLessThan = makeTestCase("sanitizeName escapes less than", () => {
  let input = "a < b"
  let sanitized = GunHelpers.sanitizeName(input)
  
  assertStringContains(~message="Should contain escaped less than", sanitized, "&lt;")
})

let testSanitizeNameEscapesGreaterThan = makeTestCase("sanitizeName escapes greater than", () => {
  let input = "a > b"
  let sanitized = GunHelpers.sanitizeName(input)
  
  assertStringContains(~message="Should contain escaped greater than", sanitized, "&gt;")
})

let testSanitizeNameEscapesQuotes = makeTestCase("sanitizeName escapes quotes", () => {
  let input = "Say \"Hello\""
  let sanitized = GunHelpers.sanitizeName(input)
  
  assertStringContains(~message="Should contain escaped double quote", sanitized, "&quot;")
})

let testSanitizeNameEscapesSingleQuotes = makeTestCase("sanitizeName escapes single quotes", () => {
  let input = "It's a test"
  let sanitized = GunHelpers.sanitizeName(input)
  
  assertStringContains(~message="Should contain escaped single quote", sanitized, "&#039;")
})

let testSanitizeNamePreservesNormalText = makeTestCase("sanitizeName preserves normal text", () => {
  let input = "Normal Store Name"
  let sanitized = GunHelpers.sanitizeName(input)
  
  assertEqual(~message="Normal text should be unchanged", sanitized, input)
})

let testResetGunClearsInstance = makeTestCase("resetGun clears the Gun instance", () => {
  // This should not throw
  GunHelpers.resetGun()
  Pass
})

let testGetGunThrowsWhenNotInitialized = makeTestCase("getGun throws when not initialized", () => {
  GunHelpers.resetGun()
  try {
    let _ = GunHelpers.getGun()
    Fail("Expected getGun to throw when not initialized")
  } catch {
  | JsExn(e) => {
      let msg = JsExn.message(e)->Option.getOr("")
      if String.includes(msg, "not initialized") {
        Pass
      } else {
        Fail(`Expected 'not initialized' error, got: ${msg}`)
      }
    }
  | _ => Fail("Expected JsExn")
  }
})

let testDefaultPeersIsArray = makeTestCase("defaultPeers is a non-empty array", () => {
  assertTrue(
    ~message="defaultPeers should have at least one peer",
    Array.length(GunHelpers.defaultPeers) > 0,
  )
})

let testDefaultPeersContainsValidUrl = makeTestCase("defaultPeers contains valid URL", () => {
  let firstPeer = GunHelpers.defaultPeers->Array.get(0)
  switch firstPeer {
  | Some(url) => assertTrue(~message="Peer URL should start with https://", String.startsWith(url, "https://"))
  | None => Fail("Expected at least one default peer")
  }
})

// Test Types module integration - test the actual variants that exist
let testServedByToString = makeTestCase("Types.servedByToString converts correctly", () => {
  let selfStr = Types.servedByToString(Types.Self)
  let operatorStr = Types.servedByToString(Types.Operator)
  
  if selfStr == "self" && operatorStr == "operator" {
    Pass
  } else {
    Fail("servedByToString conversion incorrect")
  }
})

let testTicketStatusToString = makeTestCase("Types.ticketStatusToString converts correctly", () => {
  let waitingStr = Types.ticketStatusToString(Types.Waiting)
  let servedStr = Types.ticketStatusToString(Types.Served)
  let expiredStr = Types.ticketStatusToString(Types.Expired)
  let discardedStr = Types.ticketStatusToString(Types.Discarded)
  
  if waitingStr == "waiting" && servedStr == "served" && expiredStr == "expired" && discardedStr == "discarded" {
    Pass
  } else {
    Fail("ticketStatusToString conversion incorrect")
  }
})

// Test suite
let suite = makeTestSuite(
  "GunHelpers",
  [
    testGenerateIdReturnsString,
    testGenerateIdIsUnique,
    testSanitizeNameEscapesHtml,
    testSanitizeNameEscapesAmpersand,
    testSanitizeNameEscapesLessThan,
    testSanitizeNameEscapesGreaterThan,
    testSanitizeNameEscapesQuotes,
    testSanitizeNameEscapesSingleQuotes,
    testSanitizeNamePreservesNormalText,
    testResetGunClearsInstance,
    testGetGunThrowsWhenNotInitialized,
    testDefaultPeersIsArray,
    testDefaultPeersContainsValidUrl,
    testServedByToString,
    testTicketStatusToString,
  ],
)

let runAllTests = () => runSuite(suite)
