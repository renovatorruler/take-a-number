@module("svelte") external onMount: (unit => option<unit => unit>) => unit = "onMount"

@module("../BrowserId") external getBrowserId: unit => string = "get"

type writable<'a> = Svelte.store<'a>

@module("svelte/store") external writable: 'a => writable<'a> = "writable"

@send external set: (writable<'a>, 'a) => unit = "set"

let initNumberManager = (locationId) => {
  let numberStore = writable(None)
  let reservedNumberStore = writable(None)
  let browserId = getBrowserId()

  // Subscribe to current number changes immediately
  switch Db.numbers {
  | Some(numbers) => {
      numbers
      ->Gun.get(locationId)
      ->Gun.get("current")
      ->Gun.on(value => {
        let number = Js.Nullable.toOption(value)
        switch number {
        | Some(n) => 
            Belt.Int.fromString(n)
            ->Belt.Option.map(num => numberStore->set(Some(num)))
            ->ignore
        | None => ()
        }
      })
      ->ignore

      // Also check for existing reservation
      numbers
      ->Gun.get(locationId)
      ->Gun.get("reservations")
      ->Gun.get(browserId)
      ->Gun.on(value => {
        let number = Js.Nullable.toOption(value)
        switch number {
        | Some(n) => {
            Belt.Int.fromString(n)
            ->Belt.Option.map(num => {
              if num > 0 {
                reservedNumberStore->set(Some(num))
              }
            })
            ->ignore
          }
        | None => ()
        }
      })
      ->ignore
    }
  | None => ()
  }

  let takeNumber = () => {
    Js.Console.log("Taking number...")
    
    switch Db.numbers {
    | Some(numbers) => {
        // Get current number
        numbers
        ->Gun.get(locationId)
        ->Gun.get("current")
        ->Gun.once(value => {
          let currentNumber = switch Js.Nullable.toOption(value) {
          | Some(n) => Belt.Int.fromString(n)->Belt.Option.getWithDefault(0)
          | None => 0
          }
          
          let nextNumber = currentNumber + 1
          Js.Console.log2("Next number:", nextNumber)

          // First, reserve the current number for this user
          numbers
          ->Gun.get(locationId)
          ->Gun.get("reservations")
          ->Gun.get(browserId)
          ->Gun.put(Belt.Int.toString(currentNumber))
          ->ignore

          // Update local store with current number
          reservedNumberStore->set(Some(currentNumber))

          // Then increment the current number for next user
          numbers
          ->Gun.get(locationId)
          ->Gun.get("current")
          ->Gun.put(Belt.Int.toString(nextNumber))
          ->ignore
        })
        ->ignore
      }
    | None => Js.Console.log("No Gun instance available")
    }
  }

  let relinquishNumber = () => {
    switch Db.numbers {
    | Some(numbers) => {
        numbers
        ->Gun.get(locationId)
        ->Gun.get("reservations")
        ->Gun.get(browserId)
        ->Gun.put("")
        ->ignore
        
        reservedNumberStore->set(None)
      }
    | None => ()
    }
  }

  (numberStore, reservedNumberStore, takeNumber, relinquishNumber)
}