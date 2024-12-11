// Add binding for Svelte's browser check
@module("$app/environment") external browser: bool = "browser"

// Define gun types
type gun
type gunInstance

@module("gun") @new 
external createGun: {..} => gunInstance = "default"

// Create a nullable gun instance
let gun: option<gunInstance> = if browser {
  Js.Console.log("Initializing GunDB in browser")
  let gunInstance = createGun({
    "peers": ["https://gun-manhattan.herokuapp.com/gun"],
    "localStorage": false,
    "radisk": false,
    "file": false
  })
  Js.Console.log2("GunDB initialized:", gunInstance)
  Some(gunInstance)
} else {
  Js.Console.log("Not in browser, skipping GunDB init")
  None
}

@send
external get: (gunInstance, string) => Gun.t = "get"

// Create numbers reference
let numbers: option<Gun.t> = switch gun {
  | Some(instance) => {
      Js.Console.log("Creating numbers reference")
      let Config.DbRootKey(dbRootKey) = Config.dbRoot
      let nums = get(instance, dbRootKey)
      Js.Console.log2("Numbers instance:", nums)
      Some(nums)
    }
  | None => {
      Js.Console.log("No gun instance available")
      None
    }
}
