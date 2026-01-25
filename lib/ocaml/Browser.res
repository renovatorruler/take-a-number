// Browser.res - DOM and Browser API bindings

// DOM Element type
type element

// LocalStorage
module LocalStorage = {
  @val @scope(("window", "localStorage"))
  external setItem: (string, string) => unit = "setItem"

  @val @scope(("window", "localStorage")) @return(nullable)
  external getItem: string => option<string> = "getItem"

  @val @scope(("window", "localStorage"))
  external removeItem: string => unit = "removeItem"

  // Test if localStorage is available
  let isAvailable = (): bool => {
    try {
      let test = "__storage_test__"
      setItem(test, test)
      removeItem(test)
      true
    } catch {
    | _ => false
    }
  }
}

// Location
module Location = {
  @val @scope(("window", "location"))
  external hash: string = "hash"

  @val @scope(("window", "location"))
  external setHash: string => unit = "hash"

  @val @scope(("window", "location"))
  external origin: string = "origin"

  @val @scope(("window", "location"))
  external pathname: string = "pathname"
}

// Crypto
module Crypto = {
  @val @scope(("window", "crypto")) @return(nullable)
  external randomUUID: option<unit => string> = "randomUUID"

  let generateUUID = (): string => {
    switch randomUUID {
    | Some(fn) => fn()
    | None =>
      // Fallback for older browsers
      let s4 = () => {
        let n = Math.random() *. 65536.0
        Float.toInt(n)->Int.toString(~radix=16)->String.padStart(4, "0")
      }
      `${s4()}${s4()}-${s4()}-4${s4()->String.slice(~start=1, ~end=4)}-${s4()}-${s4()}${s4()}${s4()}`
    }
  }
}

// Window
module Window = {
  @val @scope("window")
  external addEventListener: (string, 'event => unit) => unit = "addEventListener"

  @val @scope("window")
  external removeEventListener: (string, 'event => unit) => unit = "removeEventListener"
}

// Date
module DateUtils = {
  @val @scope("Date")
  external now: unit => float = "now"
}

// Console
module Console = {
  @val @scope("console")
  external log: 'a => unit = "log"

  @val @scope("console")
  external error: 'a => unit = "error"

  @val @scope("console")
  external warn: 'a => unit = "warn"
}

// Clipboard
module Clipboard = {
  @val @scope(("navigator", "clipboard"))
  external writeText: string => promise<unit> = "writeText"
}

// Document
module Document = {
  @val @scope("document") @return(nullable)
  external getElementById: string => option<element> = "getElementById"

  @val @scope("document")
  external createElement: string => element = "createElement"

  @val @scope(("document", "body"))
  external appendChild: element => unit = "appendChild"

  @val @scope(("document", "body"))
  external removeChild: element => unit = "removeChild"
}

// Element
module Element = {
  @set external setHref: (element, string) => unit = "href"
  @set external setDownload: (element, string) => unit = "download"
  @send external click: element => unit = "click"
}
