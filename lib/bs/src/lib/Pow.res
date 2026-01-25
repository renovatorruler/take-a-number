// Pow.res - Proof-of-Work wrapper using GunDB SEA

// Internal helper to get device ID
let getDeviceIdInternal = async (keypair: Types.keypair): string => {
  await Sea.work(keypair.pub, Nullable.null, Nullable.null, {name: "SHA-256"})
}

// Generate a new SEA keypair with proof-of-work
// This takes ~2-3 seconds due to the computational work involved
let generateKeyPair = async (): Types.keypair => {
  if !Sea.isSeaAvailable() {
    Err.throw("GunDB SEA is not loaded")
  }

  // Check if we already have a keypair stored
  switch Storage.getKeypair() {
  | Some(existing) if existing.pub != "" && existing.priv != "" => existing
  | _ => {
      // Generate new keypair (this includes PoW)
      let keypair = await Sea.pair()

      // Store keypair for future use
      let _ = Storage.storeKeypair(keypair)

      // Also store device ID
      let deviceId = await getDeviceIdInternal(keypair)
      let _ = Storage.storeDeviceId(deviceId)

      keypair
    }
  }
}

// Get or generate device ID
let getDeviceId = async (~keypair: option<Types.keypair>=?): string => {
  if !Sea.isSeaAvailable() {
    Err.throw("GunDB SEA is not loaded")
  }

  // Check stored device ID first
  switch Storage.getDeviceId() {
  | Some(stored) => stored
  | None => {
      // Get or generate keypair
      let pair = switch keypair {
      | Some(kp) => kp
      | None =>
        switch Storage.getKeypair() {
        | Some(kp) => kp
        | None => await generateKeyPair()
        }
      }

      // Hash the public key to create device ID
      await Sea.work(pair.pub, Nullable.null, Nullable.null, {name: "SHA-256"})
    }
  }
}

// Perform proof-of-work on some data
let doProofOfWork = async (data: 'a, ~keypair: option<Types.keypair>=?): string => {
  if !Sea.isSeaAvailable() {
    Err.throw("GunDB SEA is not loaded")
  }

  // Get keypair
  let pair = switch keypair {
  | Some(kp) => kp
  | None =>
    switch Storage.getKeypair() {
    | Some(kp) => kp
    | None => await generateKeyPair()
    }
  }

  // Perform work
  await Sea.workWithKey(data, pair)
}

// Verify proof-of-work
let verifyWork = async (data: 'a, proof: string, keypair: Types.keypair): bool => {
  if !Sea.isSeaAvailable() {
    Err.throw("GunDB SEA is not loaded")
  }

  let expectedWork = await Sea.workWithKey(data, keypair)
  proof == expectedWork
}

// Sign data with keypair
let signData = async (data: 'a, ~keypair: option<Types.keypair>=?): string => {
  if !Sea.isSeaAvailable() {
    Err.throw("GunDB SEA is not loaded")
  }

  let pair = switch keypair {
  | Some(kp) => kp
  | None =>
    switch Storage.getKeypair() {
    | Some(kp) => kp
    | None => Err.throw("No keypair available for signing")
    }
  }

  await Sea.sign(data, pair)
}

// Verify signed data
let verifySignature = async (signedData: string, publicKey: string): option<'a> => {
  if !Sea.isSeaAvailable() {
    Err.throw("GunDB SEA is not loaded")
  }

  let result = await Sea.verify(signedData, publicKey)
  Nullable.toOption(result)
}

// Check if keypair exists
let hasKeypair = Storage.hasKeypair

// Get stored keypair
let getStoredKeypair = Storage.getKeypair

// Export for browser global access
let expose = (): unit => {
  Preact.setWindowProperty(
    "PoW",
    {
      "generateKeyPair": generateKeyPair,
      "getDeviceId": getDeviceId,
      "doProofOfWork": doProofOfWork,
      "verifyWork": verifyWork,
      "signData": signData,
      "verifySignature": verifySignature,
      "hasKeypair": hasKeypair,
      "getStoredKeypair": getStoredKeypair,
    },
  )
}
