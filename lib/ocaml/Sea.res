// Sea.res - GunDB SEA (Security, Encryption, Authorization) bindings

// SEA keypair type - using Types.keypair
type keypair = Types.keypair

// Work options
type workOptions = {name: string}

// Check if SEA is available
@val @scope("window") @return(nullable)
external seaAvailable: option<'a> = "SEA"

let isSeaAvailable = (): bool => {
  seaAvailable->Option.isSome
}

// Generate keypair (includes proof-of-work, takes ~2-3 seconds)
@val @scope(("window", "SEA"))
external pair: unit => promise<keypair> = "pair"

// Perform work (proof-of-work)
@val @scope(("window", "SEA"))
external work: ('data, Nullable.t<keypair>, Nullable.t<'a>, workOptions) => promise<string> = "work"

// Work with keypair
@val @scope(("window", "SEA"))
external workWithKey: ('data, keypair) => promise<string> = "work"

// Sign data
@val @scope(("window", "SEA"))
external sign: ('data, keypair) => promise<string> = "sign"

// Verify signed data
@val @scope(("window", "SEA"))
external verify: (string, string) => promise<Nullable.t<'data>> = "verify"
