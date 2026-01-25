// Err.res - Error handling helpers

// Throw an error with a message
let throw: string => 'a = %raw(`
  function(msg) {
    throw new Error(msg);
  }
`)

// Create an error from a string
let make: string => exn = %raw(`
  function(msg) {
    return new Error(msg);
  }
`)

// Get error message
let message: exn => option<string> = %raw(`
  function(e) {
    return e && e.message ? e.message : undefined;
  }
`)
