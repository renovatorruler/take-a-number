open Types

// Generic unbox function for any unboxed type
type svelteNumber = {_0: int}

let unboxInt = v => {
  switch v {
  | Some(NumberValue(n)) => Some(({_0: n}: svelteNumber))
  | None => None
  }
}

// Helper for Svelte store subscriptions
@module("$lib/utils/UnboxedUtils.js")
external unboxStore: Svelte.store<option<numberValue>> => Svelte.store<option<svelteNumber>> =
  "unboxStore"
