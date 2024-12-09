// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Js_math from "rescript/lib/es6/js_math.js";

var storageKey = "browser_id";

function generateId() {
  var timestamp = String(Date.now());
  var random = String(Js_math.random_int(0, 1000000));
  return timestamp + "-" + random;
}

function get() {
  var id = localStorage.getItem(storageKey);
  if (id !== null) {
    return id;
  }
  var newId = generateId();
  localStorage.setItem(storageKey, newId);
  return newId;
}

export {
  storageKey ,
  generateId ,
  get ,
}
/* No side effect */