// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Db from "../Db.mjs";
import * as Gun from "../Gun.mjs";
import * as Belt_Int from "rescript/lib/es6/belt_Int.js";
import * as Belt_Option from "rescript/lib/es6/belt_Option.js";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as BrowserId from "../BrowserId";
import * as Store from "svelte/store";

function getBrowserId(prim) {
  return BrowserId.get();
}

function initNumberManager(locationId) {
  var numberStore = Store.writable(undefined);
  var reservedNumberStore = Store.writable(undefined);
  var browserId = BrowserId.get();
  if (Db.numbers !== undefined) {
    var numbers = Caml_option.valFromOption(Db.numbers);
    Gun.on(Gun.get(Gun.get(numbers, locationId), "current"), (function (value) {
            if (!(value == null)) {
              Belt_Option.map(Belt_Int.fromString(value), (function (num) {
                      numberStore.set(num);
                    }));
              return ;
            }
            
          }));
    Gun.on(Gun.get(Gun.get(Gun.get(numbers, locationId), "reservations"), browserId), (function (value) {
            if (!(value == null)) {
              Belt_Option.map(Belt_Int.fromString(value), (function (num) {
                      if (num > 0) {
                        reservedNumberStore.set(num);
                        return ;
                      }
                      
                    }));
              return ;
            }
            
          }));
  }
  var takeNumber = function () {
    console.log("Taking number...");
    if (Db.numbers !== undefined) {
      var numbers = Caml_option.valFromOption(Db.numbers);
      Gun.once(Gun.get(Gun.get(numbers, locationId), "current"), (function (value) {
              var currentNumber = !(value == null) ? Belt_Option.getWithDefault(Belt_Int.fromString(value), 0) : 0;
              var nextNumber = currentNumber + 1 | 0;
              console.log("Next number:", nextNumber);
              Gun.put(Gun.get(Gun.get(Gun.get(numbers, locationId), "reservations"), browserId), String(currentNumber));
              reservedNumberStore.set(currentNumber);
              Gun.put(Gun.get(Gun.get(numbers, locationId), "current"), String(nextNumber));
            }));
      return ;
    }
    console.log("No Gun instance available");
  };
  var relinquishNumber = function () {
    if (Db.numbers !== undefined) {
      Gun.put(Gun.get(Gun.get(Gun.get(Caml_option.valFromOption(Db.numbers), locationId), "reservations"), browserId), "");
      reservedNumberStore.set(undefined);
      return ;
    }
    
  };
  return [
          numberStore,
          reservedNumberStore,
          takeNumber,
          relinquishNumber
        ];
}

export {
  getBrowserId ,
  initNumberManager ,
}
/* Db Not a pure module */
