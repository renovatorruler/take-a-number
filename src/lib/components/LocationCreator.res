type props = unit

type state = {
  locationName: string,
  isSubmitting: bool,
  error: string,
}

type returnType = {
  state: Svelte.store<state>,
  handleSubmit: unit => promise<unit>,
}

let generateGuid = () => {
  let timestamp = Js.Date.now()->Belt.Float.toString
  let random = Js.Math.random_int(0, 1000000)->Belt.Int.toString
  timestamp ++ "-" ++ random
}

let make = (): returnType => {
  open Svelte
  let state = writable({locationName: "", isSubmitting: false, error: ""})

  let handleSubmit = async () => {
    let currentState = state->get
    if currentState.locationName->Js.String2.trim == "" {
      state->Store.set({...currentState, error: "Please enter a location name"})
    } else {
      state->Store.set({...currentState, isSubmitting: true, error: ""})
      try {
        let locationId = generateGuid()
        LocationService.addLocation(~id=locationId, ~name=currentState.locationName)->ignore
        await Navigation.goto(`/location/${locationId}`)
      } catch {
      | _ =>
        state->Store.set({
          ...currentState,
          error: "Failed to create location",
          isSubmitting: false,
        })
      }
    }
  }

  ({state, handleSubmit}: returnType)
}
