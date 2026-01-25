// TestRunner.res - Main Test Runner
// Executes all unit tests and reports results

let runAllTestSuites = () => {
  Console.log("===========================================")
  Console.log("   Take-a-Number ReScript Test Runner")
  Console.log("===========================================\n")

  let totalPassed = ref(0)
  let totalFailed = ref(0)
  let allFailures: ref<array<string>> = ref([])

  // Run Storage tests
  Console.log("Running Storage tests...")
  let (storagePassed, storageFailed, storageFailures) = Storage_test.runAllTests()
  totalPassed := totalPassed.contents + storagePassed
  totalFailed := totalFailed.contents + storageFailed
  allFailures := Array.concat(allFailures.contents, storageFailures)
  Console.log(
    `  Storage: ${storagePassed->Int.toString} passed, ${storageFailed->Int.toString} failed\n`,
  )

  // Run GunHelpers tests
  Console.log("Running GunHelpers tests...")
  let (gunPassed, gunFailed, gunFailures) = GunHelpers_test.runAllTests()
  totalPassed := totalPassed.contents + gunPassed
  totalFailed := totalFailed.contents + gunFailed
  allFailures := Array.concat(allFailures.contents, gunFailures)
  Console.log(
    `  GunHelpers: ${gunPassed->Int.toString} passed, ${gunFailed->Int.toString} failed\n`,
  )

  // Run Pow tests
  Console.log("Running Pow tests...")
  let (powPassed, powFailed, powFailures) = Pow_test.runAllTests()
  totalPassed := totalPassed.contents + powPassed
  totalFailed := totalFailed.contents + powFailed
  allFailures := Array.concat(allFailures.contents, powFailures)
  Console.log(
    `  Pow: ${powPassed->Int.toString} passed, ${powFailed->Int.toString} failed\n`,
  )

  // Run QRUtils tests
  Console.log("Running QRUtils tests...")
  let (qrPassed, qrFailed, qrFailures) = QRUtils_test.runAllTests()
  totalPassed := totalPassed.contents + qrPassed
  totalFailed := totalFailed.contents + qrFailed
  allFailures := Array.concat(allFailures.contents, qrFailures)
  Console.log(
    `  QRUtils: ${qrPassed->Int.toString} passed, ${qrFailed->Int.toString} failed\n`,
  )

  // Print summary
  Console.log("===========================================")
  Console.log("                 SUMMARY")
  Console.log("===========================================")
  Console.log(`Total Passed: ${totalPassed.contents->Int.toString}`)
  Console.log(`Total Failed: ${totalFailed.contents->Int.toString}`)

  if totalFailed.contents > 0 {
    Console.log("\nFailures:")
    allFailures.contents->Array.forEach(failure => {
      Console.log(`  ❌ ${failure}`)
    })
  } else {
    Console.log("\n✅ All tests passed!")
  }

  Console.log("===========================================\n")

  // Return exit code
  totalFailed.contents
}

// Execute tests
let exitCode = runAllTestSuites()

// Return exit code through process.exit
@val @scope("process") external exit: int => unit = "exit"

if exitCode > 0 {
  exit(1)
}
