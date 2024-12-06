type store<'a>
type unsubscribe = unit => unit

@module("svelte") external onMount: (unit => option<unsubscribe>) => unit = "onMount"
@module("svelte/store") external writable: 'a => store<'a> = "writable"

module Store = {
  @send external subscribe: (store<'a>, 'a => unit) => unsubscribe = "subscribe"
  @send external set: (store<'a>, 'a) => unit = "set"
} 