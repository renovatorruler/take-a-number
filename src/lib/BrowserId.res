open Types

let storageKey = "browser_id"
let keyPairKey = "key_pair"

let generateId = () => {
  let timestamp = Js.Date.now()->Belt.Float.toString
  let random = Js.Math.random_int(0, 1000000)->Belt.Int.toString
  BrowserId(timestamp ++ "-" ++ random)
}

// Get or create key pair
let getKeyPair = async () => {
  switch Dom.Storage2.localStorage->Dom.Storage2.getItem(keyPairKey) {
  | None => {
      let keyPair = await SeaService.generateKeyPair()
      let keyPairString = Js.Json.stringifyAny(keyPair)->Belt.Option.getWithDefault("{}")
      Dom.Storage2.localStorage->Dom.Storage2.setItem(keyPairKey, keyPairString)
      keyPair
    }
  | Some(keyPairString) =>
    switch Js.Json.parseExn(keyPairString) {
    | exception _ => await SeaService.generateKeyPair()
    | parsed => parsed->Obj.magic
    }
  }
}

let get = () => {
  switch Dom.Storage2.localStorage->Dom.Storage2.getItem(storageKey) {
  | None => {
      let BrowserId(newId) = generateId()
      Dom.Storage2.localStorage->Dom.Storage2.setItem(storageKey, newId)
      newId
    }
  | Some(id) => id
  }
}
