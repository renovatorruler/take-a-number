open Types

type props = {
  locationId: locationId,
  currentNumber: option<numberValue>,
  onTakeNumber: unit => unit,
}

type returnType = {
  numberStore: Svelte.store<option<numberValue>>,
  reservedNumberStore: Svelte.store<option<numberValue>>,
  handleTakeNumber: unit => unit,
  handleRelinquishNumber: unit => unit,
}

let make = (~locationId: locationId) => {
  Js.Console.log2("NumberManager.res locationId:", locationId)
  open Svelte
  let numberStore = writable(None)
  let reservedNumberStore = writable(None)
  let takeNumberRef = ref(None)
  let relinquishNumberRef = ref(None)

  let convertState = state =>
    switch state {
    | NumberService.Loading => None
    | NumberService.Ready({currentNumber}) => Some(currentNumber)
    }

  let convertReservation = state =>
    switch state {
    | NumberService.Loading => None
    | NumberService.Ready({reservation}) => reservation
    }

  onMount(() => {
    let {state: numberStoreGun, dispatch} = NumberService.initNumberManager(~locationId)
    takeNumberRef := Some(() => dispatch(TakeNumber))
    relinquishNumberRef := Some(() => dispatch(RelinquishNumber))
    let unsub1 =
      numberStoreGun->Svelte.Store.subscribe(n => numberStore->Svelte.Store.set(convertState(n)))
    let unsub2 =
      numberStoreGun->Svelte.Store.subscribe(n =>
        reservedNumberStore->Svelte.Store.set(convertReservation(n))
      )
    Some(
      () => {
        unsub1()
        unsub2()
      },
    )
  })

  let handleTakeNumber = () => {
    Js.Console.log("handleTakeNumber called")
    switch takeNumberRef.contents {
    | Some(take) => {
        Js.Console.log("Calling take()")
        take()->ignore
      }
    | None => {
        Js.Console.log("takeNumberRef is None")
        Error(NumberService.DatabaseError)->ignore
      }
    }
  }

  let handleRelinquishNumber = () => {
    switch relinquishNumberRef.contents {
    | Some(relinquish) => {
        reservedNumberStore->Svelte.Store.set(None)
        relinquish()->ignore
      }
    | None => Error(NumberService.DatabaseError)->ignore
    }
  }

  {
    numberStore,
    reservedNumberStore,
    handleTakeNumber,
    handleRelinquishNumber,
  }
}

let numberManagerComponent = make
