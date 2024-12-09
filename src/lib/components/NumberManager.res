type props = {
  locationId: string,
  currentNumber: int,
  onTakeNumber: unit => unit
}

type returnType = {
  numberStore: Svelte.store<int>,
  reservedNumberStore: Svelte.store<option<int>>,
  handleTakeNumber: unit => unit,
  handleRelinquishNumber: unit => unit,
}

let make = (~locationId: string) => {
  Js.Console.log2("NumberManager.res locationId:", locationId)
  open Svelte
  let numberStore = writable(0)
  let reservedNumberStore = writable(None)
  let takeNumberRef = ref(None)
  let relinquishNumberRef = ref(None)

  Svelte.onMount(() => {
    let (gunNumberStore, gunReservedStore, take, relinquish) = NumberService.initNumberManager(locationId)
    takeNumberRef := Some(take)
    relinquishNumberRef := Some(relinquish)
    let unsub1 = gunNumberStore->Svelte.Store.subscribe(n => numberStore->Store.set(n))
    let unsub2 = gunReservedStore->Svelte.Store.subscribe(n => reservedNumberStore->Store.set(n))
    Some(() => {
      unsub1()
      unsub2()
    })
  })

  let handleTakeNumber = () => {
    switch takeNumberRef.contents {
    | Some(take) => {
        let currentNumber = Svelte.get(numberStore)
        reservedNumberStore->Svelte.Store.set(Some(currentNumber))
        take()
      }
    | None => ()
    }
  }

  let handleRelinquishNumber = () => {
    switch relinquishNumberRef.contents {
    | Some(relinquish) => {
        reservedNumberStore->Store.set(None)
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