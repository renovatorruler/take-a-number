type location = LocationService.location

type state = {
  locations: array<location>,
  isLoading: bool,
}

type returnType = {
  state: Svelte.store<state>,
  handleDelete: string => unit,
  goToLocation: string => promise<unit>,
  formatDate: float => string,
}

let formatDate = timestamp => {
  Js.Date.fromFloat(timestamp)->Js.Date.toLocaleDateString
}

let make = () => {
  open Svelte
  let state = writable({locations: [], isLoading: true})

  onMount(() => {
    let locations =
      LocationService.getLocations()
      ->Belt.List.toArray
      ->Belt.SortArray.stableSortBy((a, b) => Belt.Float.toInt(b.createdAt -. a.createdAt))
    state->Store.set({locations, isLoading: false})
    None
  })

  let handleDelete = id => {
    if Browser.confirm(Browser.window, "Are you sure you want to delete this location?") {
      LocationService.removeLocation(id)
      let currentState = state->get
      let filteredLocations = currentState.locations->Js.Array2.filter(loc => loc.id != id)
      state->Store.set({...currentState, locations: filteredLocations})
    }
  }

  let goToLocation = id => {
    Navigation.goto(`/location/${id}`)
  }

  ({state, handleDelete, goToLocation, formatDate}: returnType)
}
