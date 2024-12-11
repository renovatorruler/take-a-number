// Add binding for Svelte's browser check
@module("$app/environment") external browser: bool = "browser"

// Define gun types
type gun
type gunInstance

@module("gun") @new
external createGun: {..} => gunInstance = "default"

// Create a nullable gun instance
let gun: option<gunInstance> = if browser {
  let gunInstance = createGun({
    "peers": ["https://gun-manhattan.herokuapp.com/gun"],
    "localStorage": false,
    "radisk": false,
    "file": false,
  })
  Some(gunInstance)
} else {
  None
}

@send
external get: (gunInstance, string) => Gun.t = "get"

// Create numbers reference
let numbers: option<Gun.t> = switch gun {
| Some(instance) => {
    let Config.DbRootKey(dbRootKey) = Config.dbRoot
    let nums = get(instance, dbRootKey)
    Some(nums)
  }
| None => None
}
