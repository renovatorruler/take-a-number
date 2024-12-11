open Types

type props = {
  number: option<numberValue>,
  onRelinquish: unit => unit,
}

@module("./ReservedNumber.svelte")
external make: props => Svelte.component = "default"
