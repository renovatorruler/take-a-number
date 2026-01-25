// Pow_test.res - Unit tests for Proof-of-Work wrapper

open TestHelpers

// ============================================
// POW TESTS
// ============================================

// Note: PoW functions require GunDB SEA library which may not be available in test environment
// These tests verify the ReScript logic and type safety

let testHasKeypairReturnsBoolean = makeTestCase("hasKeypair returns boolean", () => {
  let result = Pow.hasKeypair()
  assertTrue(~message="hasKeypair should return a boolean", result == true || result == false)
})

let testGetStoredKeypairReturnsOption = makeTestCase("getStoredKeypair returns option", () => {
  let result = Pow.getStoredKeypair()
  switch result {
  | Some(_) => Pass
  | None => Pass
  }
})

let testHasKeypairMatchesStorageModule = makeTestCase("hasKeypair matches Storage.hasKeypair", () => {
  let powResult = Pow.hasKeypair()
  let storageResult = Storage.hasKeypair()
  assertEqual(
    ~message="Pow.hasKeypair should match Storage.hasKeypair",
    powResult,
    storageResult,
  )
})

let testGetStoredKeypairMatchesStorageModule = makeTestCase("getStoredKeypair matches Storage.getKeypair", () => {
  let powResult = Pow.getStoredKeypair()
  let storageResult = Storage.getKeypair()
  switch (powResult, storageResult) {
  | (Some(powKp), Some(storageKp)) =>
    assertEqual(~message="Keypair pub keys should match", powKp.pub, storageKp.pub)
  | (None, None) => Pass
  | _ => Fail("Pow and Storage keypair results don't match")
  }
})

// Module exports verification (compile-time type checks)
// These tests verify that the module exports exist with correct types
// Note: Optional params use `~param: Type=?` not `~param: option<Type>=?`

let testGenerateKeyPairExists = makeTestCase("generateKeyPair function exists", () => {
  let _: unit => promise<Types.keypair> = Pow.generateKeyPair
  Pass
})

let testGetDeviceIdExists = makeTestCase("getDeviceId function exists", () => {
  let _: (~keypair: Types.keypair=?) => promise<string> = Pow.getDeviceId
  Pass
})

let testDoProofOfWorkExists = makeTestCase("doProofOfWork function exists", () => {
  let _: ('a, ~keypair: Types.keypair=?) => promise<string> = Pow.doProofOfWork
  Pass
})

let testVerifyWorkExists = makeTestCase("verifyWork function exists", () => {
  let _: ('a, string, Types.keypair) => promise<bool> = Pow.verifyWork
  Pass
})

let testSignDataExists = makeTestCase("signData function exists", () => {
  let _: ('a, ~keypair: Types.keypair=?) => promise<string> = Pow.signData
  Pass
})

let testVerifySignatureExists = makeTestCase("verifySignature function exists", () => {
  let _: (string, string) => promise<option<'a>> = Pow.verifySignature
  Pass
})

let testExposeExists = makeTestCase("expose function exists", () => {
  let _: unit => unit = Pow.expose
  Pass
})

// Test suite
let suite = makeTestSuite(
  "Pow",
  [
    testHasKeypairReturnsBoolean,
    testGetStoredKeypairReturnsOption,
    testHasKeypairMatchesStorageModule,
    testGetStoredKeypairMatchesStorageModule,
    testGenerateKeyPairExists,
    testGetDeviceIdExists,
    testDoProofOfWorkExists,
    testVerifyWorkExists,
    testSignDataExists,
    testVerifySignatureExists,
    testExposeExists,
  ],
)

let runAllTests = () => runSuite(suite)
