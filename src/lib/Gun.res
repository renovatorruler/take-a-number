type t

@send external get: (t, string) => t = "get"
@send external put: (t, string) => unit = "put"
@send external on: (t, option<string> => unit) => unit = "on"
@send external once: (t, option<string> => unit) => unit = "once" 