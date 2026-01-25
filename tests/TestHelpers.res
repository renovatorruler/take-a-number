// ============================================
// TEST HELPERS MODULE
// Provides utilities for testing ReScript code
// ============================================

// Test result type
type testResult =
  | Pass
  | Fail(string)

// Assertion helpers
let assertEqual = (~message="", a, b): testResult =>
  if a == b {
    Pass
  } else {
    Fail(message == "" ? "Expected values to be equal" : message)
  }

let assertNotEqual = (~message="", a, b): testResult =>
  if a != b {
    Pass
  } else {
    Fail(message == "" ? "Expected values to be not equal" : message)
  }

let assertTrue = (~message="", condition): testResult =>
  if condition {
    Pass
  } else {
    Fail(message == "" ? "Expected true" : message)
  }

let assertFalse = (~message="", condition): testResult =>
  if !condition {
    Pass
  } else {
    Fail(message == "" ? "Expected false" : message)
  }

let assertSome = (~message="", option): testResult =>
  switch option {
  | Some(_) => Pass
  | None => Fail(message == "" ? "Expected Some, got None" : message)
  }

let assertNone = (~message="", option): testResult =>
  switch option {
  | None => Pass
  | Some(_) => Fail(message == "" ? "Expected None, got Some" : message)
  }

let assertOk = (~message="", result): testResult =>
  switch result {
  | Ok(_) => Pass
  | Error(_) => Fail(message == "" ? "Expected Ok, got Error" : message)
  }

let assertError = (~message="", result): testResult =>
  switch result {
  | Error(_) => Pass
  | Ok(_) => Fail(message == "" ? "Expected Error, got Ok" : message)
  }

let assertStringContains = (~message="", haystack, needle): testResult =>
  if String.includes(haystack, needle) {
    Pass
  } else {
    Fail(message == "" ? `Expected "${haystack}" to contain "${needle}"` : message)
  }

let assertStringNotContains = (~message="", haystack, needle): testResult =>
  if !String.includes(haystack, needle) {
    Pass
  } else {
    Fail(message == "" ? `Expected "${haystack}" to not contain "${needle}"` : message)
  }

let assertGte = (~message="", a, b): testResult =>
  if a >= b {
    Pass
  } else {
    Fail(message == "" ? "Expected >= comparison" : message)
  }

let assertLte = (~message="", a, b): testResult =>
  if a <= b {
    Pass
  } else {
    Fail(message == "" ? "Expected <= comparison" : message)
  }

let assertGt = (~message="", a, b): testResult =>
  if a > b {
    Pass
  } else {
    Fail(message == "" ? "Expected > comparison" : message)
  }

let assertLt = (~message="", a, b): testResult =>
  if a < b {
    Pass
  } else {
    Fail(message == "" ? "Expected < comparison" : message)
  }

// Test suite runner
type testCase = {
  name: string,
  run: unit => testResult,
}

type testSuite = {
  name: string,
  tests: array<testCase>,
}

let makeTestCase = (name: string, run: unit => testResult): testCase => {name, run}

let makeTestSuite = (name: string, tests: array<testCase>): testSuite => {name, tests}

// Result tracking
let runTest = (test: testCase): (string, bool) => {
  try {
    let result = test.run()
    switch result {
    | Pass => (test.name, true)
    | Fail(msg) => (`${test.name}: ${msg}`, false)
    }
  } catch {
  | JsExn(e) => (`${test.name}: Exception - ${JsExn.message(e)->Option.getOr("unknown")}`, false)
  | _ => (`${test.name}: Unknown exception`, false)
  }
}

let runSuite = (suite: testSuite): (int, int, array<string>) => {
  let passed = ref(0)
  let failed = ref(0)
  let failures = ref([])

  suite.tests->Array.forEach(test => {
    let (message, success) = runTest(test)
    if success {
      passed := passed.contents + 1
    } else {
      failed := failed.contents + 1
      failures := failures.contents->Array.concat([message])
    }
  })

  (passed.contents, failed.contents, failures.contents)
}
