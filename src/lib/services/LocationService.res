type location = {
  id: string,
  name: string,
  createdAt: float,
}

let storageKey = "created_locations"

// Get locations from localStorage
let getLocations = () => {
  switch Dom.Storage2.getItem(Dom.Storage2.localStorage, storageKey) {
  | None => []->Belt.List.fromArray
  | Some(locationsJson) =>
    switch Js.Json.parseExn(locationsJson) {
    | exception _ => []->Belt.List.fromArray
    | parsed =>
      switch Js.Json.decodeArray(parsed) {
      | None => []->Belt.List.fromArray
      | Some(array) =>
        array
        ->Belt.Array.keepMap(item =>
          switch Js.Json.decodeObject(item) {
          | None => None
          | Some(obj) => {
              let id = Js.Dict.get(obj, "id")->Belt.Option.flatMap(Js.Json.decodeString)
              let name = Js.Dict.get(obj, "name")->Belt.Option.flatMap(Js.Json.decodeString)
              let createdAt =
                Js.Dict.get(obj, "createdAt")->Belt.Option.flatMap(Js.Json.decodeNumber)

              switch (id, name, createdAt) {
              | (Some(id), Some(name), Some(createdAt)) => Some({id, name, createdAt})
              | _ => None
              }
            }
          }
        )
        ->Belt.List.fromArray
      }
    }
  }
}

// Add a new location
let addLocation = (~id: string, ~name: string) => {
  let locations = getLocations()
  let newLocation = {
    id,
    name,
    createdAt: Js.Date.now(),
  }

  let newLocations = list{newLocation, ...locations}

  let jsonArray =
    newLocations
    ->Belt.List.toArray
    ->Belt.Array.map(loc => {
      let dict = Js.Dict.empty()
      Js.Dict.set(dict, "id", Js.Json.string(loc.id))
      Js.Dict.set(dict, "name", Js.Json.string(loc.name))
      Js.Dict.set(dict, "createdAt", Js.Json.number(loc.createdAt))
      Js.Json.object_(dict)
    })
    ->Js.Json.array

  Dom.Storage2.localStorage->Dom.Storage2.setItem(storageKey, Js.Json.stringify(jsonArray))
  newLocation
}

// Remove a location
let removeLocation = (id: string) => {
  let locations = getLocations()
  let filteredLocations = locations->Belt.List.keep(loc => loc.id !== id)

  let jsonArray =
    filteredLocations
    ->Belt.List.toArray
    ->Belt.Array.map(loc => {
      let dict = Js.Dict.empty()
      Js.Dict.set(dict, "id", Js.Json.string(loc.id))
      Js.Dict.set(dict, "name", Js.Json.string(loc.name))
      Js.Dict.set(dict, "createdAt", Js.Json.number(loc.createdAt))
      Js.Json.object_(dict)
    })
    ->Js.Json.array

  Dom.Storage2.localStorage->Dom.Storage2.setItem(storageKey, Js.Json.stringify(jsonArray))
}
