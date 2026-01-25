// Preact.res - Preact bindings
// Since we're using CDN-loaded Preact with HTM, we need custom bindings

// createElement and render
@module("preact") @val
external h: ('tag, 'props, array<React.element>) => React.element = "h"

@module("preact") @val
external render: (React.element, Browser.element) => unit = "render"

// Get global preact
@val @scope("window")
external preactH: ('tag, 'props, array<React.element>) => React.element = "preact.h"

@val @scope("window")
external preactRender: (React.element, Browser.element) => unit = "preact.render"

// HTM template literal binding - binds to preact's h
@val @scope("window")
external html: 'a = "html"

// Helper to set window property
let setWindowProperty: (string, 'a) => unit = %raw(`
  function(name, value) {
    window[name] = value;
  }
`)
