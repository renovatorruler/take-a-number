// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Db from "../db";
import * as Belt_Int from "rescript/lib/es6/belt_Int.js";
import * as Belt_Option from "rescript/lib/es6/belt_Option.js";
import * as Store from "svelte/store";

var gun = Db.gun;

var numbers = Db.numbers;

function initNumberManager(locationId) {
  console.log("Initializing with locationId:", locationId);
  var numberStore = Store.writable(0);
  numbers.get(locationId).get("current").once(function (number) {
        console.log("Initial data for location:", number);
        if (number !== undefined) {
          return ;
        } else {
          console.log("No data found, initializing with 0");
          numbers.get(locationId).get("current").put("0");
          return ;
        }
      });
  numbers.get(locationId).get("current").on(function (number) {
        if (number !== undefined) {
          numberStore.set(Belt_Option.getWithDefault(Belt_Int.fromString(number), 0));
        } else {
          numberStore.set(0);
        }
      });
  var takeNumber = function () {
    numbers.get(locationId).get("current").once(function (number) {
          if (number !== undefined) {
            var nextNumber = Belt_Option.getWithDefault(Belt_Int.fromString(number), 0) + 1 | 0;
            numbers.get(locationId).get("current").put(String(nextNumber));
            return ;
          }
          numbers.get(locationId).get("current").put("1");
        });
  };
  var relinquishNumber = function () {
    
  };
  return [
          numberStore,
          takeNumber,
          relinquishNumber
        ];
}

export {
  gun ,
  numbers ,
  initNumberManager ,
}
/* gun Not a pure module */
