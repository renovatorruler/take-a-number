type props = {
  isOpen: bool,
  onToggle: unit => unit,
}

@module("./HamburgerMenu.svelte")
external make: props => Svelte.component = "default" 