// Display.res - TV display screen with real-time sync

@react.component
let make = (~storeId: string) => {
  let (store, setStore) = React.useState(() => None)
  let (isLoading, setIsLoading) = React.useState(() => true)
  let (error, setError) = React.useState(() => None)

  // Unsubscribe function ref
  let unsubscribeRef = React.useRef(None)

  // Load store function
  let loadStore = async () => {
    try {
      let storeData = await GunHelpers.getStore(storeId)
      switch storeData {
      | None => setError(_ => Some("Queue not found"))
      | Some(s) => setStore(_ => Some(s))
      }
    } catch {
    | JsExn(err) => {
        Browser.Console.error(err)
        setError(_ => Some("Failed to load queue"))
      }
    }
    setIsLoading(_ => false)
  }

  // Initialize on mount
  React.useEffect0(() => {
    // Initialize Gun
    let _ = GunHelpers.initGun()

    // Load store data
    loadStore()->ignore

    Some(
      () => {
        // Cleanup subscription
        switch unsubscribeRef.current {
        | Some(unsub) => unsub()
        | None => ()
        }
      },
    )
  })

  // Subscribe to store updates when store is loaded
  React.useEffect1(() => {
    switch store {
    | Some(_) => {
        let unsub = GunHelpers.subscribeToStore(storeId, updatedStore => {
          setStore(_ => Some(updatedStore))
        })
        unsubscribeRef.current = Some(unsub)

        Some(
          () => {
            unsub()
            unsubscribeRef.current = None
          },
        )
      }
    | None => None
    }
  }, [store->Option.isSome])

  // Loading state
  if isLoading {
    <div className="page display-page" dataTestId="display-page">
      <div className="loading"> {React.string("Loading...")} </div>
    </div>
  } else {
    switch (error, store) {
    // Error state
    | (Some(errMsg), None) =>
      <div className="page display-page" dataTestId="display-page">
        <div className="page-header">
          <h1 className="page-title"> {React.string("Display")} </h1>
        </div>
        <div className="container">
          <div className="error" dataTestId="display-error">
            <p> {React.string(errMsg)} </p>
          </div>
        </div>
      </div>

    // Store loaded - show display
    | (_, Some(s)) =>
      <div className="page display-page" dataTestId="display-page">
        <div className="page-header">
          <h1 className="page-title" dataTestId="store-name"> {React.string(s.name)} </h1>
        </div>
        <div className="container">
          <div className="display-now-serving" dataTestId="now-serving-display">
            <div className="display-label">
              {React.string(s.nowServing > 0 ? "Now Serving" : "Waiting for first customer")}
            </div>
            {s.nowServing > 0
              ? <div className="display-number" dataTestId="now-serving-number">
                  {React.string(`#${Int.toString(s.nowServing)}`)}
                </div>
              : React.null}
          </div>
          <div className="display-stats mt-4">
            <div className="stat-item">
              <span className="stat-label"> {React.string("Next Number")} </span>
              <span className="stat-value" dataTestId="next-number">
                {React.string(`#${Int.toString(s.currentNumber + 1)}`)}
              </span>
            </div>
            <div className="stat-item">
              <span className="stat-label"> {React.string("Served Today")} </span>
              <span className="stat-value" dataTestId="served-today">
                {React.string(Int.toString(s.servedToday))}
              </span>
            </div>
          </div>
        </div>
      </div>

    // Fallback
    | _ =>
      <div className="page display-page" dataTestId="display-page">
        <div className="loading"> {React.string("Loading...")} </div>
      </div>
    }
  }
}

// Expose to window for HTM usage
let expose = () => {
  Preact.setWindowProperty("Display", make)
}
