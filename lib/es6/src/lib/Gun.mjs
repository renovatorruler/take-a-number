// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Caml_option from "rescript/lib/es6/caml_option.js";

function get(gun, key) {
  console.log("Gun.get called with key:", key);
  return gun.get(key);
}

function put(gun, value) {
  console.log("Gun.put called with value:", value);
  return gun.put(value);
}

function once(gun, callback) {
  console.log("Gun.once called");
  return gun.once(function (value) {
              console.log("Gun.once received value:", (value == null) ? undefined : Caml_option.some(value));
              callback(value);
            });
}

function on(gun, callback) {
  console.log("Gun.on called");
  return gun.on(function (value) {
              console.log("Gun.on received value:", (value == null) ? undefined : Caml_option.some(value));
              callback(value);
            });
}

export {
  get ,
  put ,
  once ,
  on ,
}
/* No side effect */
