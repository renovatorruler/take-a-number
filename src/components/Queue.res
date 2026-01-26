// Queue.res - Customer queue page with ticket dispenser

// Confirmation dialog component
module ConfirmDialog = {
  @react.component
  let make = (~onConfirm: unit => unit, ~onCancel: unit => unit) => {
    <div className="confirm-dialog-overlay" dataTestId="confirm-dialog">
      <div className="confirm-dialog">
        <h3> {React.string("Mark as Served?")} </h3>
        <p> {React.string("This will remove you from the queue.")} </p>
        <div className="confirm-dialog-buttons">
          <button
            className="btn btn-outline"
            onClick={_ => onCancel()}
            dataTestId="cancel-btn">
            {React.string("Cancel")}
          </button>
          <button
            className="btn btn-primary"
            onClick={_ => onConfirm()}
            dataTestId="confirm-btn">
            {React.string("Yes, I'm Done")}
          </button>
        </div>
      </div>
    </div>
  }
}

@react.component
let make = (~storeId: string) => {
  let (store, setStore) = React.useState(() => None)
  let (ticket, setTicket) = React.useState(() => None)
  let (isLoading, setIsLoading) = React.useState(() => true)
  let (error, setError) = React.useState(() => None)
  let (isTakingNumber, setIsTakingNumber) = React.useState(() => false)
  let (showServedScreen, setShowServedScreen) = React.useState(() => false)
  let (showConfirmDialog, setShowConfirmDialog) = React.useState(() => false)
  let (isIncognito, setIsIncognito) = React.useState(() => false)

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

  // Check for existing ticket
  let checkExistingTicket = () => {
    if Storage.hasTicket(storeId) {
      switch Storage.getTicket(storeId) {
      | Some(storedTicket) if storedTicket.status == "waiting" =>
        setTicket(_ => Some(storedTicket))
      | Some(storedTicket) if storedTicket.status == "served" =>
        setShowServedScreen(_ => true)
      | _ => ()
      }
    }
  }

  // Initialize on mount
  React.useEffect0(() => {
    // Check for incognito mode
    if Storage.isIncognito() {
      setIsIncognito(_ => true)
      setIsLoading(_ => false)
    } else {
      // Initialize Gun
      let _ = GunHelpers.initGun()

      // Load store data
      loadStore()->ignore

      // Check for existing ticket
      checkExistingTicket()
    }

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

  // Handle take number
  let handleTakeNumber = async () => {
    if !isTakingNumber {
      setIsTakingNumber(_ => true)
      setError(_ => None)

      try {
        // Generate keypair (includes PoW - takes ~2-3 seconds)
        let keypair = await Pow.generateKeyPair()
        let deviceId = await Pow.getDeviceId(~keypair=keypair)

        // Check if device already has a ticket
        let existingTicket = await GunHelpers.getTicketByDeviceId(storeId, deviceId)
        switch existingTicket {
        | Some(existing) if existing.status == "waiting" => {
            setTicket(_ => Some(existing))
            let _ = Storage.storeTicket(storeId, existing)
          }
        | _ => {
            // Create new ticket
            let newTicket = await GunHelpers.createTicket(storeId, deviceId)
            setTicket(_ => Some(newTicket))
            let _ = Storage.storeTicket(storeId, newTicket)
          }
        }
      } catch {
      | JsExn(err) => {
          Browser.Console.error(err)
          let msg = JsExn.message(err)->Option.getOr("Failed to get ticket. Please try again.")
          setError(_ => Some(msg))
        }
      }

      setIsTakingNumber(_ => false)
    }
  }

  // Handle mark served
  let handleMarkServed = () => {
    switch ticket {
    | Some(_) => setShowConfirmDialog(_ => true)
    | None => ()
    }
  }

  // Handle confirm served
  let handleConfirmServed = async () => {
    setShowConfirmDialog(_ => false)

    switch ticket {
    | Some(t) =>
      try {
        let _ = await GunHelpers.markTicketServed(storeId, t.number, ~servedBy=Types.Self)

        // Update local ticket
        let updatedTicket = {...t, status: "served"}
        setTicket(_ => Some(updatedTicket))
        let _ = Storage.storeTicket(storeId, updatedTicket)

        setShowServedScreen(_ => true)
      } catch {
      | JsExn(err) => {
          Browser.Console.error(err)
          setError(_ => Some("Failed to mark as served. Please try again."))
        }
      }
    | None => ()
    }
  }

  // Handle cancel served
  let handleCancelServed = () => {
    setShowConfirmDialog(_ => false)
  }

  // Handle take another
  let handleTakeAnother = () => {
    Storage.clearTicket(storeId)
    setTicket(_ => None)
    setShowServedScreen(_ => false)
  }

  // Calculate position in queue
  let getPosition = (): int => {
    switch (ticket, store) {
    | (Some(t), Some(s)) => {
        let nowServing = s.nowServing
        let position = t.number - nowServing
        Math.Int.max(0, position)
      }
    | _ => 0
    }
  }

  // Format expiry time (24 hours from issue)
  let getExpiryTime = (): option<string> => {
    switch ticket {
    | Some(t) => {
        let expiryTime = t.issuedAt +. 24.0 *. 60.0 *. 60.0 *. 1000.0
        let now = Browser.DateUtils.now()
        let remaining = expiryTime -. now

        if remaining <= 0.0 {
          Some("Expired")
        } else {
          let hours = Float.toInt(remaining /. (60.0 *. 60.0 *. 1000.0))
          let minutes = Float.toInt(Float.mod(remaining, 60.0 *. 60.0 *. 1000.0) /. (60.0 *. 1000.0))
          Some(`${Int.toString(hours)}h ${Int.toString(minutes)}m`)
        }
      }
    | None => None
    }
  }

  // Incognito mode blocked screen
  if isIncognito {
    <div className="page" dataTestId="queue-page">
      <div className="page-header">
        <h1 className="page-title"> {React.string("🔒 Private Mode")} </h1>
      </div>
      <div className="container">
        <div className="incognito-warning" dataTestId="incognito-warning">
          <p> {React.string("Please open this page in a regular browser window.")} </p>
          <p>
            {React.string(
              "Private/Incognito mode is not supported because we need to remember your ticket.",
            )}
          </p>
        </div>
      </div>
    </div>
  } else if isLoading {
    // Loading state
    <div className="page" dataTestId="queue-page">
      <div className="loading"> {React.string("Loading...")} </div>
    </div>
  } else {
    switch (error, store) {
    // Error state - store not found
    | (Some(errMsg), None) =>
      <div className="page" dataTestId="queue-page">
        <div className="page-header">
          <h1 className="page-title"> {React.string("Queue Not Found")} </h1>
        </div>
        <div className="container">
          <div className="error" dataTestId="queue-error">
            <p> {React.string(errMsg)} </p>
            <p> {React.string("Please check the QR code and try again.")} </p>
          </div>
        </div>
      </div>

    | (_, Some(s)) =>
      // Served screen
      if showServedScreen {
        <ServedScreen storeName=s.name onTakeAnother=handleTakeAnother />
      } else {
        switch ticket {
        // Has ticket - show ticket and queue position
        | Some(t) if t.status == "waiting" => {
            let position = getPosition()
            let expiryTime = getExpiryTime()

            <div className="page" dataTestId="queue-page">
              {showConfirmDialog
                ? <ConfirmDialog
                    onConfirm={() => handleConfirmServed()->ignore} onCancel=handleCancelServed
                  />
                : React.null}
              <div className="page-header">
                <h1 className="page-title" dataTestId="store-name"> {React.string(s.name)} </h1>
              </div>
              <div className="container">
                <Ticket number=t.number storeName=s.name isRevealing=true />
                <div className="queue-status mt-3" dataTestId="queue-status">
                  {position == 0
                    ? // User is being served - they ARE the "now serving"
                      <div className="status-item">
                        <span className="status-label"> {React.string("Your Number")} </span>
                        <span className="status-value" dataTestId="now-serving">
                          {React.string(`#${Int.toString(t.number)}`)}
                        </span>
                      </div>
                    : // User is waiting - show who was recently served
                      <>
                        <div className="status-item">
                          <span className="status-label">
                            {React.string(s.nowServing > 0 ? "Recently Served" : "Queue Status")}
                          </span>
                          <span className="status-value" dataTestId="now-serving">
                            {React.string(
                              s.nowServing > 0
                                ? `#${Int.toString(s.nowServing)}`
                                : "No one yet",
                            )}
                          </span>
                        </div>
                        <div className="status-item">
                          <span className="status-label"> {React.string("Ahead of You")} </span>
                          <span className="status-value" dataTestId="people-ahead">
                            {React.string(
                              `${Int.toString(position)} ${position == 1 ? "person" : "people"}`,
                            )}
                          </span>
                        </div>
                      </>}
                </div>
                {position == 0
                  ? <div className="your-turn-alert" dataTestId="your-turn">
                      {React.string("It's your turn!")}
                    </div>
                  : React.null}
                <button
                  className="btn btn-primary btn-full mt-3"
                  onClick={_ => handleMarkServed()}
                  dataTestId="mark-served-btn">
                  {React.string("I've Been Served ✓")}
                </button>
                {switch expiryTime {
                | Some(expiry) =>
                  <div className="expiry-info mt-2" dataTestId="expiry-info">
                    {React.string(`⏰ Expires in ${expiry}`)}
                  </div>
                | None => React.null
                }}
                {switch error {
                | Some(errMsg) =>
                  <div className="error-message mt-2"> {React.string(errMsg)} </div>
                | None => React.null
                }}
                <div className="pwa-prompt mt-4" dataTestId="pwa-prompt">
                  <p> {React.string("📱 Add to Home Screen for notifications")} </p>
                </div>
              </div>
            </div>
          }

        // No ticket - show dispenser
        | _ =>
          <div className="page" dataTestId="queue-page">
            <div className="page-header">
              <h1 className="page-title" dataTestId="store-name"> {React.string(s.name)} </h1>
            </div>
            <div className="container">
              <div className="next-number-preview" dataTestId="next-number-preview">
                <span className="preview-label"> {React.string("Next number:")} </span>
                <span className="preview-number">
                  {React.string(`#${Int.toString(s.currentNumber + 1)}`)}
                </span>
              </div>
              <Dispenser onPull={() => handleTakeNumber()->ignore} isDisabled=isTakingNumber />
              {isTakingNumber
                ? <div className="taking-number-animation" dataTestId="taking-number">
                    <div className="ticket-spinner"> {React.string("🎫")} </div>
                    <p> {React.string("Getting your number...")} </p>
                  </div>
                : React.null}
              {switch error {
              | Some(errMsg) =>
                <div className="error-message mt-2" dataTestId="error-message">
                  {React.string(errMsg)}
                </div>
              | None => React.null
              }}
              <div className="current-status mt-4">
                <div className="status">
                  <span className="status-label">
                    {React.string(s.nowServing > 0 ? "Recently Served" : "Queue Status")}
                  </span>
                  <span className="status-value" dataTestId="now-serving">
                    {React.string(
                      s.nowServing > 0 ? `#${Int.toString(s.nowServing)}` : "No one yet",
                    )}
                  </span>
                </div>
              </div>
            </div>
          </div>
        }
      }

    // Fallback
    | _ =>
      <div className="page" dataTestId="queue-page">
        <div className="loading"> {React.string("Loading...")} </div>
      </div>
    }
  }
}

// Expose to window for HTM usage
let expose = () => {
  Preact.setWindowProperty("Queue", make)
}
