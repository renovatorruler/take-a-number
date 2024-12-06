type gun
type gunInstance

@module("gun") @new
external createGun: {..} => gunInstance = "default"

@send
external get: (gunInstance, string) => gun = "get"

let gun = createGun({"peers": ["http://localhost:8765/gun"]})

// Use the config constant
let numbers = get(gun, Config.dbRoot)
