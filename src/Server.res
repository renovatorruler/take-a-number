// Express types and bindings
type express
type expressApp
type server
type request
type response
type handler = (request, response) => unit

@module("express") @val
external express: unit => expressApp = "default"

@send external use: (expressApp, handler) => unit = "use"
@send external listen: (expressApp, int, unit => unit) => server = "listen"

// Gun types and bindings (extending what we have in Db.res)
@module("gun") @val
external gunServe: handler = "serve"

// Import the SvelteKit handler
@module("./build/handler") @val
external svelteHandler: handler = "handler"

// Create Express app
let app = express()
let port = switch NodeJs.Process.process->NodeJs.Process.env->Js.Dict.get("PORT") {
| Some(p) => Belt.Int.fromString(p)->Belt.Option.getWithDefault(8765)
| None => 8765
}

// Use Gun middleware
app->use(gunServe)

// Use SvelteKit handler
app->use(svelteHandler)

// Start the server
let server = app->listen(port, () => {
  Js.Console.log(`Server running on port ${Belt.Int.toString(port)}`)
})

// Create Gun instance with server
let gun = Db.createGun({
  "web": server,
  "file": "data"
})
