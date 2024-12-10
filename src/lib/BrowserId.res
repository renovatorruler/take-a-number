let storageKey = "browser_id"

let generateId = () => {
  let timestamp = Js.Date.now()->Belt.Float.toString
  let random = Js.Math.random_int(0, 1000000)->Belt.Int.toString
  timestamp ++ "-" ++ random
}

let get = () => {
  switch Dom.Storage2.localStorage->Dom.Storage2.getItem(storageKey) {
  | None => {
      let newId = generateId()
      Dom.Storage2.localStorage->Dom.Storage2.setItem(storageKey, newId)
      newId
    }
  | Some(id) => id
  }
}