// Generated by ReScript, PLEASE EDIT WITH CARE

import Gun from "gun";
import * as Config from "./Config.mjs";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as Environment from "$app/environment";

var gun;

if (Environment.browser) {
  console.log("Initializing GunDB in browser");
  var gunInstance = new Gun({
        peers: ["https://gun-manhattan.herokuapp.com/gun"],
        localStorage: false,
        radisk: false,
        file: false
      });
  console.log("GunDB initialized:", gunInstance);
  gun = Caml_option.some(gunInstance);
} else {
  console.log("Not in browser, skipping GunDB init");
  gun = undefined;
}

var numbers;

if (gun !== undefined) {
  console.log("Creating numbers reference");
  var nums = Caml_option.valFromOption(gun).get(Config.dbRoot);
  console.log("Numbers instance:", nums);
  numbers = Caml_option.some(nums);
} else {
  console.log("No gun instance available");
  numbers = undefined;
}

export {
  gun ,
  numbers ,
}
/* gun Not a pure module */
