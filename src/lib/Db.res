type gun
type gunInstance

@module("gun") @new
external createGun: {..} => gunInstance = "default"

@send
external get: (gunInstance, string) => gun = "get"

let gun = createGun({
  "peers": ["https://gun-manhattan.herokuapp.com/gun"],
  "localStorage": false,
  "radisk": false
})

let numbers = get(gun, Config.dbRoot)
