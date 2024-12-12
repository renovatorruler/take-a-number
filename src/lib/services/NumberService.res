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
  dispatch: numberManagerAction => promise<result<unit, numberManagerError>>,
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
      ->Gun.once(async reservationValue => {
        let keyPair: SeaService.keyPair = await BrowserId.getKeyPair()

        let existingReservation = await (
          switch Js.Nullable.toOption(reservationValue) {
          | None => Promise.resolve(None)
          | Some(jsonString) =>
            // Parse the JSON string
            switch Js.Json.parseExn(jsonString) {
            | exception _ => Promise.resolve(None)
            | parsed => {
                let dict = Js.Json.decodeObject(parsed)
                switch dict {
                | None => Promise.resolve(None)
                | Some(dict) => {
                    let number = Js.Dict.get(dict, "number")
                    let signature = Js.Dict.get(dict, "signature")
                    switch (number, signature) {
                    | (Some(number), Some(signature)) => {
                        let verified = await SeaService.verifyData(
                          ~signedData=Js.Json.decodeString(signature)->Belt.Option.getExn,
                          ~publicKey=keyPair.pub,
                        )

                        Promise.resolve(
                          switch Js.Nullable.toOption(verified) {
                          | None => None
                          | Some(_) =>
                            Js.Json.decodeString(number)
                            ->Belt.Option.flatMap(Belt.Int.fromString)
                            ->Belt.Option.map(n => NumberValue(n))
                          },
                        )
                      }
                    | _ => Promise.resolve(None)
                    }
                  }
                }
              }
            }
          }
        )

        // Then get current number
        numbers
        ->Gun.get(locationId)
        ->Gun.get("current")
        ->Gun.once(async value => {
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
              ()
            }
          | Some(current) => {
              store->set(
                Ready({
                  currentNumber: NumberValue(current),
                  reservation: existingReservation,
                }),
              )
              ()
            }
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
      let dispatch = async action => {
        switch (action, store->Svelte.get) {
        | (TakeNumber, Ready({reservation: Some(_)})) => Error(AlreadyHasNumber)
        | (TakeNumber, Ready({currentNumber: NumberValue(current)})) => {
            let keyPair: SeaService.keyPair = await BrowserId.getKeyPair()

            // Sign the number with the user's private key
            let signedNumber = await SeaService.signData(
              ~data=Belt.Int.toString(current),
              ~privateKey=keyPair.priv,
            )

            // Only proceed if we got a valid signed number
            if signedNumber !== "" {
              let data = Js.Dict.empty()
              Js.Dict.set(data, "number", Belt.Int.toString(current))
              Js.Dict.set(data, "signature", signedNumber)
              let jsonData = Js.Json.stringify(Obj.magic(data))

              (
                await Promise.all2((
                  Promise.resolve({
                    let ref = numbers->Gun.get(locationId)->Gun.get("current")
                    ref->Gun.put(Belt.Int.toString(current + 1))->ignore
                  }),
                  Promise.resolve({
                    let ref =
                      numbers->Gun.get(locationId)->Gun.get("reservations")->Gun.get(browserId)
                    ref->Gun.put(jsonData)->ignore
                  }),
                ))
              )->ignore

              store->set(
                Ready({
                  currentNumber: NumberValue(current + 1),
                  reservation: Some(NumberValue(current)),
                }),
              )

              Ok()
            } else {
              Error(DatabaseError)
            }
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
      dispatch: _ => Promise.resolve(Error(DatabaseError)),
    }
  }
}
