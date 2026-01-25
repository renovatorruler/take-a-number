// Storage.res - localStorage helpers

let keypairKey = "tan_keypair"
let deviceIdKey = "tan_device_id"
let ticketPrefix = "tan_ticket_"

// Check if localStorage is available
let isStorageAvailable = Browser.LocalStorage.isAvailable

// Check if running in incognito/private mode
let isIncognito = (): bool => {
  !isStorageAvailable()
}

// Store keypair
let storeKeypair = (keypair: Types.keypair): result<unit, string> => {
  if !isStorageAvailable() {
    Error("localStorage is not available")
  } else {
    let json = JSON.stringifyAny(keypair)->Option.getOr("{}")
    Browser.LocalStorage.setItem(keypairKey, json)
    Ok()
  }
}

// Get keypair from localStorage
let getKeypair = (): option<Types.keypair> => {
  if !isStorageAvailable() {
    None
  } else {
    switch Browser.LocalStorage.getItem(keypairKey) {
    | Some(stored) =>
      try {
        JSON.parseOrThrow(stored)->Obj.magic->Some
      } catch {
      | _ => None
      }
    | None => None
    }
  }
}

// Check if keypair exists
let hasKeypair = (): bool => {
  getKeypair()->Option.isSome
}

// Clear keypair
let clearKeypair = (): unit => {
  if isStorageAvailable() {
    Browser.LocalStorage.removeItem(keypairKey)
  }
}

// Store device ID
let storeDeviceId = (deviceId: string): result<unit, string> => {
  if !isStorageAvailable() {
    Error("localStorage is not available")
  } else {
    Browser.LocalStorage.setItem(deviceIdKey, deviceId)
    Ok()
  }
}

// Get device ID
let getDeviceId = (): option<string> => {
  if !isStorageAvailable() {
    None
  } else {
    Browser.LocalStorage.getItem(deviceIdKey)
  }
}

// Store ticket for a store
let storeTicket = (storeId: string, ticket: Types.ticket): result<unit, string> => {
  if !isStorageAvailable() {
    Error("localStorage is not available")
  } else {
    let json = JSON.stringifyAny(ticket)->Option.getOr("{}")
    Browser.LocalStorage.setItem(ticketPrefix ++ storeId, json)
    Ok()
  }
}

// Get ticket for a store
let getTicket = (storeId: string): option<Types.ticket> => {
  if !isStorageAvailable() {
    None
  } else {
    switch Browser.LocalStorage.getItem(ticketPrefix ++ storeId) {
    | Some(stored) =>
      try {
        JSON.parseOrThrow(stored)->Obj.magic->Some
      } catch {
      | _ => None
      }
    | None => None
    }
  }
}

// Check if ticket exists
let hasTicket = (storeId: string): bool => {
  getTicket(storeId)->Option.isSome
}

// Clear ticket
let clearTicket = (storeId: string): unit => {
  if isStorageAvailable() {
    Browser.LocalStorage.removeItem(ticketPrefix ++ storeId)
  }
}

// Clear all stored data
let clearAll = (): unit => {
  if isStorageAvailable() {
    Browser.LocalStorage.removeItem(keypairKey)
    Browser.LocalStorage.removeItem(deviceIdKey)
    // Note: Cannot iterate localStorage keys easily in ReScript
    // Would need additional bindings for full implementation
  }
}

// Export for browser global access
let expose = (): unit => {
  Preact.setWindowProperty(
    "Storage",
    {
      "isStorageAvailable": isStorageAvailable,
      "isIncognito": isIncognito,
      "storeKeypair": storeKeypair,
      "getKeypair": getKeypair,
      "hasKeypair": hasKeypair,
      "clearKeypair": clearKeypair,
      "storeDeviceId": storeDeviceId,
      "getDeviceId": getDeviceId,
      "storeTicket": storeTicket,
      "getTicket": getTicket,
      "hasTicket": hasTicket,
      "clearTicket": clearTicket,
      "clearAll": clearAll,
    },
  )
}
