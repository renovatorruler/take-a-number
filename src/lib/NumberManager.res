type gun
type numbers
type writable<'a>

@module("./db") external gun: gun = "gun"
@module("./db") external numbers: Gun.t = "numbers"
@module("svelte/store") external writable: 'a => writable<'a> = "writable"

@send external set: (writable<'a>, 'a) => unit = "set"
@send external subscribe: (writable<'a>, 'a => unit) => (unit => unit) = "subscribe"

let numberStore = writable(0)

let initNumberManager = () => {
  numbers
  ->Gun.get("current")
  ->Gun.on(number => {
    switch number {
    | Some(n) => numberStore->set(Belt.Int.fromString(n)->Belt.Option.getWithDefault(0))
    | None => ()
    }
  })

  let takeNumber = () => {
    numbers
    ->Gun.get("current")
    ->Gun.once(number => {
      switch number {
      | Some(n) => {
          let nextNumber = Belt.Int.fromString(n)->Belt.Option.getWithDefault(0) + 1
          numbers->Gun.get("current")->Gun.put(Belt.Int.toString(nextNumber))
        }
      | None => ()
      }
    })
  }

  (numberStore, takeNumber)
}