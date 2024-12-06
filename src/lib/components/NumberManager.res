type props = {
  locationId: string,
  currentNumber: int,
  onTakeNumber: unit => unit
}

type returnType = {
  numberStore: Svelte.store<int>,
  handleTakeNumber: unit => unit,
}

let make = (~locationId: string) => {
  Js.Console.log2("NumberManager.res locationId:", locationId)
  open Svelte
  let numberStore = writable(0)
  let takeNumberRef = ref(None)

  Svelte.onMount(() => {
    let (store, take) = NumberService.initNumberManager(locationId)
    takeNumberRef := Some(take)
    Some(store->Svelte.Store.subscribe(n => numberStore->Store.set(n)))
  })

  let handleTakeNumber = () => {
    switch takeNumberRef.contents {
    | Some(take) => take()
    | None => ()
    }
  }

  {
    numberStore,
    handleTakeNumber
  }
}

let numberManagerComponent = make 