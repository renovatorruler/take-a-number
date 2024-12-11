@module("svelte") external onMount: (unit => option<unit => unit>) => unit = "onMount"

@module("../BrowserId") external getBrowserId: unit => string = "get"

type writable<'a> = Svelte.store<'a>

@module("svelte/store") external writable: 'a => writable<'a> = "writable"

@send external set: (writable<'a>, 'a) => unit = "set"

open Types

// Define all possible states a number manager can be in
type numberManagerState =
  | Loading
  | Ready({currentNumber: numberValue, reservation: option<numberValue>})

// Define actions that can be performed
type numberManagerAction =
  | TakeNumber
  | RelinquishNumber

// Define errors that can occur
type numberManagerError =
  | AlreadyHasNumber
  | NoNumberToRelinquish
  | DatabaseError

// Define our store type that guarantees valid states
type numberManagerStore = {
  state: writable<numberManagerState>,
  dispatch: numberManagerAction => result<unit, numberManagerError>,
}

let initNumberManager = (~locationId as LocationId(locationId)) => {
  let store = writable(Loading)
  let browserId = getBrowserId()

  switch Db.numbers {
  | Some(numbers) => {
      // First check for existing reservation
      numbers
      ->Gun.get(locationId)
      ->Gun.get("reservations")
      ->Gun.get(browserId)
      ->Gun.once(reservationValue => {
        let existingReservation =
          Js.Nullable.toOption(reservationValue)
          ->Belt.Option.flatMap(Belt.Int.fromString)
          ->Belt.Option.map(n => NumberValue(n))

        // Then get current number
        numbers
        ->Gun.get(locationId)
        ->Gun.get("current")
        ->Gun.once(value => {
          switch Js.Nullable.toOption(value)->Belt.Option.flatMap(Belt.Int.fromString) {
          | None => {
              numbers
              ->Gun.get(locationId)
              ->Gun.get("current")
              ->Gun.put("0")
              ->ignore

              store->set(
                Ready({
                  currentNumber: NumberValue(0),
                  reservation: existingReservation,
                }),
              )
            }
          | Some(current) =>
            store->set(
              Ready({
                currentNumber: NumberValue(current),
                reservation: existingReservation,
              }),
            )
          }
        })
        ->ignore
      })
      ->ignore

      // Subscribe to changes
      numbers
      ->Gun.get(locationId)
      ->Gun.get("current")
      ->Gun.on(value => {
        switch store->Svelte.get {
        | Loading => ()
        | Ready(state) =>
          switch Js.Nullable.toOption(value)->Belt.Option.flatMap(Belt.Int.fromString) {
          | Some(current) =>
            store->set(
              Ready({
                ...state,
                currentNumber: NumberValue(current),
              }),
            )
          | None => ()
          }
        }
      })
      ->ignore

      // Handle dispatch actions
      let dispatch = action => {
        switch (action, store->Svelte.get) {
        | (TakeNumber, Ready({reservation: Some(_)})) => Error(AlreadyHasNumber)
        | (TakeNumber, Ready({currentNumber: NumberValue(current)})) => {
            numbers
            ->Gun.get(locationId)
            ->Gun.get("current")
            ->Gun.put(Belt.Int.toString(current + 1))
            ->ignore

            numbers
            ->Gun.get(locationId)
            ->Gun.get("reservations")
            ->Gun.get(browserId)
            ->Gun.put(Belt.Int.toString(current))
            ->ignore

            store->set(
              Ready({
                currentNumber: NumberValue(current + 1),
                reservation: Some(NumberValue(current)),
              }),
            )

            Ok()
          }
        | (RelinquishNumber, Ready({reservation: None})) => Error(NoNumberToRelinquish)
        | (RelinquishNumber, Ready(state)) => {
            numbers
            ->Gun.get(locationId)
            ->Gun.get("reservations")
            ->Gun.get(browserId)
            ->Gun.put("")
            ->ignore

            store->set(Ready({...state, reservation: None}))
            Ok()
          }
        | (_, Loading) => Error(DatabaseError)
        }
      }

      {state: store, dispatch}
    }
  | None => {
      state: store,
      dispatch: _ => Error(DatabaseError),
    }
  }
}
