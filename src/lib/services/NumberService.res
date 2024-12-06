type gun
type numbers
type writable<'a> = Svelte.store<'a>

@module("../db") external gun: gun = "gun"
@module("../db") external numbers: Gun.t = "numbers"
@module("svelte/store") external writable: 'a => writable<'a> = "writable"

@send external set: (writable<'a>, 'a) => unit = "set"
@send external subscribe: (writable<'a>, 'a => unit) => (unit => unit) = "subscribe"

let initNumberManager = (locationId) => {
  Js.Console.log2("Initializing with locationId:", locationId)
  let numberStore = writable(0)

  // Initialize location data
  numbers
  ->Gun.get(locationId)
  ->Gun.get("current")
  ->Gun.once(number => {
    Js.Console.log2("Initial data for location:", number)
    switch number {
    | None => {
        Js.Console.log("No data found, initializing with 0")
        numbers->Gun.get(locationId)->Gun.get("current")->Gun.put("0")
      }
    | Some(_) => ()
    }
  })

  // Subscribe to changes
  numbers
  ->Gun.get(locationId)
  ->Gun.get("current")
  ->Gun.on(number => {
    switch number {
    | Some(n) => numberStore->set(Belt.Int.fromString(n)->Belt.Option.getWithDefault(0))
    | None => numberStore->set(0)
    }
  })

  let takeNumber = () => {
    numbers
    ->Gun.get(locationId)
    ->Gun.get("current")
    ->Gun.once(number => {
      switch number {
      | Some(n) => {
          let nextNumber = Belt.Int.fromString(n)->Belt.Option.getWithDefault(0) + 1
          numbers->Gun.get(locationId)->Gun.get("current")->Gun.put(Belt.Int.toString(nextNumber))
        }
      | None => numbers->Gun.get(locationId)->Gun.get("current")->Gun.put("1")
      }
    })
  }

  (numberStore, takeNumber)
}