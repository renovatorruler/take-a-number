type props = {
  number: option<int>,
  onRelinquish: unit => unit,
}

@module("./ReservedNumber.svelte")
external make: props => Svelte.component = "default" 