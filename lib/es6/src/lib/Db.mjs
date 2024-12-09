// Generated by ReScript, PLEASE EDIT WITH CARE

import Gun from "gun";
import * as Config from "./Config.mjs";

var gun = new Gun({
      peers: ["https://gun-manhattan.herokuapp.com/gun"],
      localStorage: false,
      radisk: false
    });

var numbers = gun.get(Config.dbRoot);

export {
  gun ,
  numbers ,
}
/* gun Not a pure module */
