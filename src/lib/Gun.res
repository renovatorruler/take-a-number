type t

@send external get: (t, string) => t = "get"
@send external put: (t, string) => t = "put"
@send external on: (t, Js.Nullable.t<string> => unit) => t = "on"
@send external once: (t, Js.Nullable.t<string> => unit) => t = "once"

// Add logging wrappers
let get = (gun, key) => {
  Js.Console.log2("Gun.get called with key:", key)
  get(gun, key)
}

let put = (gun, value) => {
  Js.Console.log2("Gun.put called with value:", value)
  put(gun, value)
}

let once = (gun, callback) => {
  Js.Console.log("Gun.once called")
  once(gun, value => {
    Js.Console.log2("Gun.once received value:", Js.Nullable.toOption(value))
    callback(value)
  })
}

let on = (gun, callback) => {
  Js.Console.log("Gun.on called")
  on(gun, value => {
    Js.Console.log2("Gun.on received value:", Js.Nullable.toOption(value))
    callback(value)
  })
} 