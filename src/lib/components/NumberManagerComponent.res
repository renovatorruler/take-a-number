// Svelte component props type
type props = {
  currentNumber: int,
  onTakeNumber: unit => unit
}

// Component implementation
type returnType = {
  numberStore: Svelte.store<int>,
  handleTakeNumber: unit => unit,
}

let make = () => {
    open Svelte
  let numberStore = writable(0)
  let takeNumberRef = ref(None)

  Svelte.onMount(() => {
    let (store, take) = NumberManager.initNumberManager()
    takeNumberRef := Some(take)
    
    // Return unsubscribe function
    Some(store->Svelte.Store.subscribe(n => numberStore->Store.set(n)))
  })

  let handleTakeNumber = () => {
    switch takeNumberRef.contents {
    | Some(take) => take()
    | None => ()
    }
  }

  let result: returnType = {
    numberStore,
    handleTakeNumber
  }
  result
}

// Add this export
let numberManagerComponent = make 