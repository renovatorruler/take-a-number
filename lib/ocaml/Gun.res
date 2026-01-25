// Gun.res - GunDB bindings

// Gun reference types
type gun
type gunRef

// External Gun constructor - expects global Gun to be loaded from CDN
@val @scope("window")
external gunConstructor: option<array<string>> => gun = "Gun"

// Gun instance methods
@send external get: (gun, string) => gunRef = "get"
@send external getRef: (gunRef, string) => gunRef = "get"

// Put data with optional callback
type ack = {err: Nullable.t<string>}

@send external put: (gunRef, 'a) => unit = "put"
@send external putWithAck: (gunRef, 'a, ack => unit) => unit = "put"

// Subscribe to data
@send external on: (gunRef, ('data, string) => unit) => unit = "on"
@send external once: (gunRef, ('data, string) => unit) => unit = "once"
@send external off: gunRef => unit = "off"

// Map over collection
@send external map: gunRef => gunRef = "map"

// Check if Gun is available
@val @scope("window") @return(nullable)
external gunAvailable: option<'a> = "Gun"

let isGunAvailable = (): bool => {
  gunAvailable->Option.isSome
}
