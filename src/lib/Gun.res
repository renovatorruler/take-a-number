type t

@send external get: (t, string) => t = "get"
@send external put: (t, string) => t = "put"
@send external on: (t, Js.Nullable.t<string> => unit) => t = "on"
@send external once: (t, Js.Nullable.t<string> => unit) => t = "once"
