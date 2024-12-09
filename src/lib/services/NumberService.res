@module("../BrowserId") external getBrowserId: unit => string = "get"

type gun
type numbers
type writable<'a> = Svelte.store<'a>

@module("../db") external gun: gun = "gun"
@module("../db") external numbers: Gun.t = "numbers"
@module("svelte/store") external writable: 'a => writable<'a> = "writable"

@send external set: (writable<'a>, 'a) => unit = "set"
@send external subscribe: (writable<'a>, 'a => unit) => (unit => unit) = "subscribe"

let initNumberManager = (locationId) => {
  let numberStore = writable(0)
  let reservedNumberStore = writable(None)
  let browserId = getBrowserId()

  // Initialize location data
  numbers
  ->Gun.get(locationId)
  ->Gun.get("current")
  ->Gun.once(number => {
    switch number {
    | None => numbers->Gun.get(locationId)->Gun.get("current")->Gun.put("0")
    | Some(_) => ()
    }
  })

  // Check for existing reservation
  numbers
  ->Gun.get(locationId)
  ->Gun.get("reservations")
  ->Gun.get(browserId)
  ->Gun.once(reservation => {
    switch reservation {
    | Some(number) => 
        let num = Belt.Int.fromString(number)->Belt.Option.getWithDefault(0)
        if num > 0 {
          reservedNumberStore->set(Some(num))
        }
    | None => ()
    }
  })

  // Subscribe to current number changes
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
          // Update current number
          numbers->Gun.get(locationId)->Gun.get("current")->Gun.put(Belt.Int.toString(nextNumber))
          // Store reservation
          numbers
          ->Gun.get(locationId)
          ->Gun.get("reservations")
          ->Gun.get(browserId)
          ->Gun.put(Belt.Int.toString(nextNumber))
          // Update local store
          reservedNumberStore->set(Some(nextNumber))
        }
      | None => ()
      }
    })
  }

  let relinquishNumber = () => {
    // Remove reservation from GunDB
    numbers
    ->Gun.get(locationId)
    ->Gun.get("reservations")
    ->Gun.get(browserId)
    ->Gun.put("")
    // Clear local store
    reservedNumberStore->set(None)
  }

  (numberStore, reservedNumberStore, takeNumber, relinquishNumber)
}