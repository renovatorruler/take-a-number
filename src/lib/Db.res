// First, let's create the type and binding for Gun
type gun
type gunInstance

@module("gun") @new
external createGun: {..} => gunInstance = "default"

// Binding for the get method
@send
external get: (gunInstance, string) => gun = "get"

// Create our gun instance
let gun = createGun({"peers": ["http://localhost:8765/gun"]})

// Create our numbers namespace
let numbers = get(gun, "take-a-number")
