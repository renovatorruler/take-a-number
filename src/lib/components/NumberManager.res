type props = {
  locationId: string,
  currentNumber: option<int>,
  onTakeNumber: unit => unit
}

type returnType = {
  numberStore: Svelte.store<option<int>>,
  reservedNumberStore: Svelte.store<option<int>>,
  handleTakeNumber: unit => unit,
  handleRelinquishNumber: unit => unit,
}

let make = (~locationId: string) => {
  Js.Console.log2("NumberManager.res locationId:", locationId)
  open Svelte
  let numberStore = writable(None)
  let reservedNumberStore = writable(None)
  let takeNumberRef = ref(None)
  let relinquishNumberRef = ref(None)

  onMount(() => {
    let (numberStoreGun, reservedStoreGun, take, relinquish) = NumberService.initNumberManager(locationId)
    takeNumberRef := Some(take)
    relinquishNumberRef := Some(relinquish)
    let unsub1 = numberStoreGun->Svelte.Store.subscribe(n => numberStore->Svelte.Store.set(n))
    let unsub2 = reservedStoreGun->Svelte.Store.subscribe(n => reservedNumberStore->Svelte.Store.set(n))
    Some(() => {
      unsub1()
      unsub2()
    })
  })

  let handleTakeNumber = () => {
    Js.Console.log("handleTakeNumber called")
    switch takeNumberRef.contents {
    | Some(take) => {
        Js.Console.log("Calling take()")
        take()
      }
    | None => Js.Console.log("takeNumberRef is None")
    }
  }

  let handleRelinquishNumber = () => {
    switch relinquishNumberRef.contents {
    | Some(relinquish) => {
        reservedNumberStore->Svelte.Store.set(None)
        relinquish()
      }
    | None => ()
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