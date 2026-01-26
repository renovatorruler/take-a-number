// GunHelpers.res - GunDB connection and CRUD helpers

// Gun instance (singleton)
let gunInstance: ref<option<Gun.gun>> = ref(None)

// Default peers (multiple for redundancy)
let defaultPeers = [
  "https://relay.peer.ooo/gun",
  "https://gun-manhattan.herokuapp.com/gun",  // backup, often down
]

// Initialize Gun connection
let initGun = (~peers: option<array<string>>=?): Gun.gun => {
  switch gunInstance.contents {
  | Some(gun) => gun
  | None => {
      if !Gun.isGunAvailable() {
        Err.throw("Gun is not loaded. Include gun.js before using this module.")
      }

      let p = peers->Option.getOr(defaultPeers)
      let gun = Gun.gunConstructor(Some(p))
      gunInstance := Some(gun)
      gun
    }
  }
}

// Get Gun instance (must call initGun first)
let getGun = (): Gun.gun => {
  switch gunInstance.contents {
  | Some(gun) => gun
  | None => Err.throw("Gun not initialized. Call initGun() first.")
  }
}

// Reset Gun instance (for testing)
let resetGun = (): unit => {
  gunInstance := None
}

// Generate a UUID
let generateId = Browser.Crypto.generateUUID

// Sanitize string for XSS prevention
let sanitizeName = (name: string): string => {
  name
  ->String.replaceAll("&", "&amp;")
  ->String.replaceAll("<", "&lt;")
  ->String.replaceAll(">", "&gt;")
  ->String.replaceAll("\"", "&quot;")
  ->String.replaceAll("'", "&#039;")
}

// Create a new store
let createStore = async (name: string, ~options: option<{..}>=?): Types.createStoreResult => {
  let trimmedName = name->String.trim

  if trimmedName->String.length < 1 || trimmedName->String.length > 50 {
    Err.throw("Store name must be 1-50 characters")
  }

  // XSS sanitization
  let sanitizedName = sanitizeName(trimmedName)

  let gun = getGun()
  let storeId = generateId()
  let adminId = generateId()
  let timestamp = Browser.DateUtils.now()

  let expiryHours = options->Option.flatMap(o => o["expiryHours"])->Option.getOr(24)
  let expiryAfterServed = options->Option.flatMap(o => o["expiryAfterServed"])->Option.getOr(10)

  let store: Types.store = {
    id: storeId,
    name: sanitizedName,
    createdAt: timestamp,
    adminId: adminId,
    settings: {
      expiryHours: expiryHours,
      expiryAfterServed: expiryAfterServed,
    },
    currentNumber: 0,
    nowServing: 0,
    servedToday: 0,
    servedLastHour: 0,
    version: "1.0",
  }

  await Promise.make((resolve, reject) => {
    let ref = gun->Gun.get("stores")->Gun.getRef(storeId)
    ref->Gun.putWithAck(store, ack => {
      switch Nullable.toOption(ack.err) {
      | Some(err) => reject(Err.make(err))
      | None =>
        resolve({
          Types.storeId: storeId,
          adminId: adminId,
          store: store,
        })
      }
    })
  })
}

// Get store by ID
let getStore = async (storeId: string, ~timeout: int=5000): option<Types.store> => {
  let gun = getGun()

  await Promise.make((resolve, _reject) => {
    let resolved = ref(false)
    let timeoutId = ref(None)
    let ref_ = gun->Gun.get("stores")->Gun.getRef(storeId)

    // Listener callback
    let handleData = (data: Nullable.t<Types.store>, _key: string) => {
      switch Nullable.toOption(data) {
      | Some(store) if !resolved.contents && store.id != "" => {
          resolved := true
          switch timeoutId.contents {
          | Some(id) => clearTimeout(id)
          | None => ()
          }
          ref_->Gun.off
          resolve(Some(store))
        }
      | _ => ()
      }
    }

    // Subscribe to data
    ref_->Gun.on(handleData)
    ref_->Gun.once(handleData)

    // Timeout
    timeoutId :=
      Some(
        setTimeout(
          () => {
            if !resolved.contents {
              resolved := true
              ref_->Gun.off
              resolve(None)
            }
          },
          timeout,
        ),
      )
  })
}

// Get store by admin ID
let getStoreByAdminId = async (adminId: string): option<Types.store> => {
  let gun = getGun()

  await Promise.make((resolve, _reject) => {
    let found = ref(false)
    let ref_ = gun->Gun.get("stores")

    ref_->Gun.map->Gun.once((store: Nullable.t<Types.store>, _key) => {
      switch Nullable.toOption(store) {
      | Some(s) if !found.contents && s.adminId == adminId => {
          found := true
          resolve(Some(s))
        }
      | _ => ()
      }
    })

    // Give time to scan stores
    let _ = setTimeout(
      () => {
        if !found.contents {
          resolve(None)
        }
      },
      2000,
    )
  })
}

// Update store data
let updateStore = async (storeId: string, updates: {..}): Types.store => {
  let gun = getGun()

  let _ = await Promise.make((resolve, reject) => {
    let ref_ = gun->Gun.get("stores")->Gun.getRef(storeId)
    ref_->Gun.putWithAck(updates, ack => {
      switch Nullable.toOption(ack.err) {
      | Some(err) => reject(Err.make(err))
      | None => resolve()
      }
    })
  })

  // Return updated store
  let store = await getStore(storeId)
  switch store {
  | Some(s) => s
  | None => Err.throw("Failed to get updated store")
  }
}

// Subscribe to store updates
let subscribeToStore = (storeId: string, callback: Types.store => unit): (unit => unit) => {
  let gun = getGun()
  let ref_ = gun->Gun.get("stores")->Gun.getRef(storeId)

  ref_->Gun.on((data: Nullable.t<Types.store>, _key) => {
    switch Nullable.toOption(data) {
    | Some(store) if store.id != "" => callback(store)
    | _ => ()
    }
  })

  // Return unsubscribe function
  () => ref_->Gun.off
}

// Create a new ticket
let createTicket = async (storeId: string, deviceId: string): Types.ticket => {
  let gun = getGun()

  // Get current store to determine next number
  let storeOpt = await getStore(storeId)
  let store = switch storeOpt {
  | Some(s) => s
  | None => Err.throw("Store not found")
  }

  let nextNumber = store.currentNumber + 1
  let timestamp = Browser.DateUtils.now()

  let ticket: Types.ticket = {
    number: nextNumber,
    deviceId: deviceId,
    issuedAt: timestamp,
    status: "waiting",
    servedAt: Nullable.null,
    servedBy: Nullable.null,
  }

  await Promise.make((resolve, reject) => {
    // First update the store's current number
    let storeRef = gun->Gun.get("stores")->Gun.getRef(storeId)
    storeRef->Gun.putWithAck({"currentNumber": nextNumber}, ack => {
      switch Nullable.toOption(ack.err) {
      | Some(err) => reject(Err.make(err))
      | None => {
          // Then create the ticket
          let ticketRef =
            gun
            ->Gun.get("stores")
            ->Gun.getRef(storeId)
            ->Gun.getRef("tickets")
            ->Gun.getRef(Int.toString(nextNumber))
          ticketRef->Gun.putWithAck(ticket, ack2 => {
            switch Nullable.toOption(ack2.err) {
            | Some(err) => reject(Err.make(err))
            | None => resolve(ticket)
            }
          })
        }
      }
    })
  })
}

// Get a specific ticket
let getTicket = async (storeId: string, ticketNumber: int): option<Types.ticket> => {
  let gun = getGun()

  await Promise.make((resolve, _reject) => {
    let ref_ =
      gun
      ->Gun.get("stores")
      ->Gun.getRef(storeId)
      ->Gun.getRef("tickets")
      ->Gun.getRef(Int.toString(ticketNumber))

    ref_->Gun.once((data: Nullable.t<Types.ticket>, _key) => {
      switch Nullable.toOption(data) {
      | Some(ticket) if ticket.number > 0 => resolve(Some(ticket))
      | _ => resolve(None)
      }
    })
  })
}

// Get ticket by device ID
let getTicketByDeviceId = async (storeId: string, deviceId: string): option<Types.ticket> => {
  let gun = getGun()

  await Promise.make((resolve, _reject) => {
    let found = ref(false)
    let ref_ = gun->Gun.get("stores")->Gun.getRef(storeId)->Gun.getRef("tickets")

    ref_->Gun.map->Gun.once((ticket: Nullable.t<Types.ticket>, _key) => {
      switch Nullable.toOption(ticket) {
      | Some(t) if !found.contents && t.deviceId == deviceId && t.status == "waiting" => {
          found := true
          resolve(Some(t))
        }
      | _ => ()
      }
    })

    // Give time for tickets to be scanned
    let _ = setTimeout(
      () => {
        if !found.contents {
          resolve(None)
        }
      },
      2000,
    )
  })
}

// Get all tickets for a store
let getTickets = async (storeId: string, ~status: option<string>=?): array<Types.ticket> => {
  let gun = getGun()
  let tickets = ref([])

  let _ = await Promise.make((resolve, _reject) => {
    let ref_ = gun->Gun.get("stores")->Gun.getRef(storeId)->Gun.getRef("tickets")

    ref_->Gun.map->Gun.once((ticket: Nullable.t<Types.ticket>, _key) => {
      switch Nullable.toOption(ticket) {
      | Some(t) if t.number > 0 => {
          // Apply status filter
          let shouldInclude = switch status {
          | Some(s) => t.status == s
          | None => true
          }
          if shouldInclude {
            tickets := tickets.contents->Array.concat([t])
          }
        }
      | _ => ()
      }
    })

    // Give time for all tickets to be collected
    let _ = setTimeout(() => resolve(), 500)
  })

  // Sort by number
  tickets.contents->Array.toSorted((a, b) => Float.fromInt(a.number - b.number))
}

// Update a ticket
let updateTicket = async (storeId: string, ticketNumber: int, updates: {..}): Types.ticket => {
  let gun = getGun()

  let _ = await Promise.make((resolve, reject) => {
    let ref_ =
      gun
      ->Gun.get("stores")
      ->Gun.getRef(storeId)
      ->Gun.getRef("tickets")
      ->Gun.getRef(Int.toString(ticketNumber))
    ref_->Gun.putWithAck(updates, ack => {
      switch Nullable.toOption(ack.err) {
      | Some(err) => reject(Err.make(err))
      | None => resolve()
      }
    })
  })

  // Return updated ticket
  let ticketOpt = await getTicket(storeId, ticketNumber)
  switch ticketOpt {
  | Some(t) => t
  | None => Err.throw("Failed to get updated ticket")
  }
}

// Mark a ticket as served
let markTicketServed = async (
  storeId: string,
  ticketNumber: int,
  ~servedBy: Types.servedBy=Self,
): Types.ticket => {
  let timestamp = Browser.DateUtils.now()
  let servedByStr = Types.servedByToString(servedBy)

  // Update ticket status
  let ticket = await updateTicket(
    storeId,
    ticketNumber,
    {
      "status": "served",
      "servedAt": timestamp,
      "servedBy": servedByStr,
    },
  )

  // Update store stats and nowServing
  let storeOpt = await getStore(storeId)
  switch storeOpt {
  | Some(store) => {
      let newNowServing = Math.Int.max(store.nowServing, ticketNumber)
      let _ = await updateStore(
        storeId,
        {
          "nowServing": newNowServing,
          "servedToday": store.servedToday + 1,
          "servedLastHour": store.servedLastHour + 1,
        },
      )
    }
  | None => ()
  }

  ticket
}

// Subscribe to ticket updates for a store
let subscribeToTickets = (storeId: string, callback: Types.ticket => unit): (unit => unit) => {
  let gun = getGun()
  let ref_ = gun->Gun.get("stores")->Gun.getRef(storeId)->Gun.getRef("tickets")

  ref_->Gun.map->Gun.on((ticket: Nullable.t<Types.ticket>, _key) => {
    switch Nullable.toOption(ticket) {
    | Some(t) if t.number > 0 => callback(t)
    | _ => ()
    }
  })

  // Return unsubscribe function
  () => ref_->Gun.map->Gun.off
}

// Export for browser global access
let expose = (): unit => {
  Preact.setWindowProperty(
    "GunHelpers",
    {
      "initGun": initGun,
      "getGun": getGun,
      "resetGun": resetGun,
      "generateId": generateId,
      "createStore": createStore,
      "getStore": getStore,
      "getStoreByAdminId": getStoreByAdminId,
      "updateStore": updateStore,
      "subscribeToStore": subscribeToStore,
      "createTicket": createTicket,
      "getTicket": getTicket,
      "getTicketByDeviceId": getTicketByDeviceId,
      "getTickets": getTickets,
      "updateTicket": updateTicket,
      "markTicketServed": markTicketServed,
      "subscribeToTickets": subscribeToTickets,
    },
  )
}
