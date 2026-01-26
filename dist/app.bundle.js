var TakeANumber = (() => {
  var __create = Object.create;
  var __defProp = Object.defineProperty;
  var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
  var __getOwnPropNames = Object.getOwnPropertyNames;
  var __getProtoOf = Object.getPrototypeOf;
  var __hasOwnProp = Object.prototype.hasOwnProperty;
  var __commonJS = (cb, mod) => function __require() {
    return mod || (0, cb[__getOwnPropNames(cb)[0]])((mod = { exports: {} }).exports, mod), mod.exports;
  };
  var __export = (target, all) => {
    for (var name2 in all)
      __defProp(target, name2, { get: all[name2], enumerable: true });
  };
  var __copyProps = (to, from, except, desc) => {
    if (from && typeof from === "object" || typeof from === "function") {
      for (let key of __getOwnPropNames(from))
        if (!__hasOwnProp.call(to, key) && key !== except)
          __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
    }
    return to;
  };
  var __toESM = (mod, isNodeMode, target) => (target = mod != null ? __create(__getProtoOf(mod)) : {}, __copyProps(
    // If the importer is in node compatibility mode or this is not an ESM
    // file that has been converted to a CommonJS file using a Babel-
    // compatible transform (i.e. "__esModule" has not been set), then set
    // "default" to the CommonJS "module.exports" for node compatibility.
    isNodeMode || !mod || !mod.__esModule ? __defProp(target, "default", { value: mod, enumerable: true }) : target,
    mod
  ));
  var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);

  // preact-shim:react/jsx-runtime
  var require_jsx_runtime = __commonJS({
    "preact-shim:react/jsx-runtime"(exports, module) {
      var preact = window.preact;
      module.exports = {
        jsx: preact.h,
        jsxs: preact.h,
        jsxDEV: preact.h,
        Fragment: preact.Fragment
      };
    }
  });

  // preact-shim:react
  var require_react = __commonJS({
    "preact-shim:react"(exports, module) {
      var preact = window.preact;
      var hooks = window.preactHooks;
      module.exports = {
        createElement: preact.h,
        Fragment: preact.Fragment,
        Component: preact.Component,
        createContext: preact.createContext,
        createRef: preact.createRef,
        useState: hooks.useState,
        useEffect: hooks.useEffect,
        useRef: hooks.useRef,
        useCallback: hooks.useCallback,
        useMemo: hooks.useMemo,
        useContext: hooks.useContext,
        useReducer: hooks.useReducer,
        render: preact.render,
        hydrate: preact.hydrate
      };
    }
  });

  // lib/es6/src/App.js
  var App_exports = {};
  __export(App_exports, {
    App: () => App,
    Router: () => Router,
    init: () => init,
    parseRoute: () => parseRoute
  });

  // lib/es6/src/bindings/Err.js
  var $$throw = (function(msg) {
    throw new Error(msg);
  });
  var make = (function(msg) {
    return new Error(msg);
  });

  // node_modules/@rescript/runtime/lib/es6/Primitive_option.js
  function some(x) {
    if (x === void 0) {
      return {
        BS_PRIVATE_NESTED_SOME_NONE: 0
      };
    } else if (x !== null && x.BS_PRIVATE_NESTED_SOME_NONE !== void 0) {
      return {
        BS_PRIVATE_NESTED_SOME_NONE: x.BS_PRIVATE_NESTED_SOME_NONE + 1 | 0
      };
    } else {
      return x;
    }
  }
  function fromNullable(x) {
    if (x == null) {
      return;
    } else {
      return some(x);
    }
  }
  function valFromOption(x) {
    if (x === null || x.BS_PRIVATE_NESTED_SOME_NONE === void 0) {
      return x;
    }
    let depth = x.BS_PRIVATE_NESTED_SOME_NONE;
    if (depth === 0) {
      return;
    } else {
      return {
        BS_PRIVATE_NESTED_SOME_NONE: depth - 1 | 0
      };
    }
  }

  // node_modules/@rescript/runtime/lib/es6/Stdlib_Option.js
  function flatMap(opt, f) {
    if (opt !== void 0) {
      return f(valFromOption(opt));
    }
  }
  function getOr(opt, $$default) {
    if (opt !== void 0) {
      return valFromOption(opt);
    } else {
      return $$default;
    }
  }
  function isSome(x) {
    return x !== void 0;
  }

  // lib/es6/src/bindings/Sea.js
  function isSeaAvailable() {
    return isSome(fromNullable(window.SEA));
  }

  // lib/es6/src/bindings/Preact.js
  var setWindowProperty = (function(name2, value) {
    window[name2] = value;
  });

  // lib/es6/src/bindings/Browser.js
  function isAvailable() {
    try {
      let test = "__storage_test__";
      window.localStorage.setItem(test, test);
      window.localStorage.removeItem(test);
      return true;
    } catch (exn) {
      return false;
    }
  }
  var LocalStorage = {
    isAvailable
  };
  function generateUUID() {
    let fn = window.crypto.randomUUID;
    if (!(fn == null)) {
      return fn();
    }
    let s4 = () => {
      let n = Math.random() * 65536;
      return (n | 0).toString(16).padStart(4, "0");
    };
    return s4() + s4() + `-` + s4() + `-4` + s4().slice(1, 4) + `-` + s4() + `-` + s4() + s4() + s4();
  }
  var Crypto = {
    generateUUID
  };

  // lib/es6/src/lib/Storage.js
  var keypairKey = "tan_keypair";
  var deviceIdKey = "tan_device_id";
  var ticketPrefix = "tan_ticket_";
  var isStorageAvailable = LocalStorage.isAvailable;
  function isIncognito() {
    return !isStorageAvailable();
  }
  function storeKeypair(keypair) {
    if (!isStorageAvailable()) {
      return {
        TAG: "Error",
        _0: "localStorage is not available"
      };
    }
    let json = getOr(JSON.stringify(keypair), "{}");
    window.localStorage.setItem(keypairKey, json);
    return {
      TAG: "Ok",
      _0: void 0
    };
  }
  function getKeypair() {
    if (!isStorageAvailable()) {
      return;
    }
    let stored = window.localStorage.getItem(keypairKey);
    if (stored == null) {
      return;
    }
    try {
      return JSON.parse(stored);
    } catch (exn) {
      return;
    }
  }
  function hasKeypair() {
    return isSome(getKeypair());
  }
  function clearKeypair() {
    if (isStorageAvailable()) {
      window.localStorage.removeItem(keypairKey);
      return;
    }
  }
  function storeDeviceId(deviceId) {
    if (isStorageAvailable()) {
      window.localStorage.setItem(deviceIdKey, deviceId);
      return {
        TAG: "Ok",
        _0: void 0
      };
    } else {
      return {
        TAG: "Error",
        _0: "localStorage is not available"
      };
    }
  }
  function getDeviceId() {
    if (isStorageAvailable()) {
      return fromNullable(window.localStorage.getItem(deviceIdKey));
    }
  }
  function storeTicket(storeId, ticket) {
    if (!isStorageAvailable()) {
      return {
        TAG: "Error",
        _0: "localStorage is not available"
      };
    }
    let json = getOr(JSON.stringify(ticket), "{}");
    window.localStorage.setItem(ticketPrefix + storeId, json);
    return {
      TAG: "Ok",
      _0: void 0
    };
  }
  function getTicket(storeId) {
    if (!isStorageAvailable()) {
      return;
    }
    let stored = window.localStorage.getItem(ticketPrefix + storeId);
    if (stored == null) {
      return;
    }
    try {
      return JSON.parse(stored);
    } catch (exn) {
      return;
    }
  }
  function hasTicket(storeId) {
    return isSome(getTicket(storeId));
  }
  function clearTicket(storeId) {
    if (isStorageAvailable()) {
      window.localStorage.removeItem(ticketPrefix + storeId);
      return;
    }
  }
  function clearAll() {
    if (isStorageAvailable()) {
      window.localStorage.removeItem(keypairKey);
      window.localStorage.removeItem(deviceIdKey);
      return;
    }
  }
  function expose() {
    setWindowProperty("Storage", {
      isStorageAvailable,
      isIncognito,
      storeKeypair,
      getKeypair,
      hasKeypair,
      clearKeypair,
      storeDeviceId,
      getDeviceId,
      storeTicket,
      getTicket,
      hasTicket,
      clearTicket,
      clearAll
    });
  }

  // lib/es6/src/lib/Pow.js
  async function getDeviceIdInternal(keypair) {
    return await window.SEA.work(keypair.pub, null, null, {
      name: "SHA-256"
    });
  }
  async function generateKeyPair() {
    if (!isSeaAvailable()) {
      $$throw("GunDB SEA is not loaded");
    }
    let existing = getKeypair();
    if (existing !== void 0 && existing.pub !== "" && existing.priv !== "") {
      return existing;
    }
    let keypair = await window.SEA.pair();
    storeKeypair(keypair);
    let deviceId = await getDeviceIdInternal(keypair);
    storeDeviceId(deviceId);
    return keypair;
  }
  async function getDeviceId2(keypair) {
    if (!isSeaAvailable()) {
      $$throw("GunDB SEA is not loaded");
    }
    let stored = getDeviceId();
    if (stored !== void 0) {
      return stored;
    }
    let pair;
    if (keypair !== void 0) {
      pair = keypair;
    } else {
      let kp = getKeypair();
      pair = kp !== void 0 ? kp : await generateKeyPair();
    }
    return await window.SEA.work(pair.pub, null, null, {
      name: "SHA-256"
    });
  }
  async function doProofOfWork(data, keypair) {
    if (!isSeaAvailable()) {
      $$throw("GunDB SEA is not loaded");
    }
    let pair;
    if (keypair !== void 0) {
      pair = keypair;
    } else {
      let kp = getKeypair();
      pair = kp !== void 0 ? kp : await generateKeyPair();
    }
    return await window.SEA.work(data, pair);
  }
  async function verifyWork(data, proof, keypair) {
    if (!isSeaAvailable()) {
      $$throw("GunDB SEA is not loaded");
    }
    let expectedWork = await window.SEA.work(data, keypair);
    return proof === expectedWork;
  }
  async function signData(data, keypair) {
    if (!isSeaAvailable()) {
      $$throw("GunDB SEA is not loaded");
    }
    let pair;
    if (keypair !== void 0) {
      pair = keypair;
    } else {
      let kp = getKeypair();
      pair = kp !== void 0 ? kp : $$throw("No keypair available for signing");
    }
    return await window.SEA.sign(data, pair);
  }
  async function verifySignature(signedData, publicKey) {
    if (!isSeaAvailable()) {
      $$throw("GunDB SEA is not loaded");
    }
    return fromNullable(await window.SEA.verify(signedData, publicKey));
  }
  function expose2() {
    setWindowProperty("PoW", {
      generateKeyPair,
      getDeviceId: getDeviceId2,
      doProofOfWork,
      verifyWork,
      signData,
      verifySignature,
      hasKeypair,
      getStoredKeypair: getKeypair
    });
  }

  // lib/es6/src/components/Admin.js
  var JsxRuntime = __toESM(require_jsx_runtime(), 1);
  function Admin(props) {
    return JsxRuntime.jsxs("div", {
      children: [
        JsxRuntime.jsxs("div", {
          children: [
            JsxRuntime.jsx("h1", {
              children: "Admin Panel",
              className: "page-title"
            }),
            JsxRuntime.jsx("p", {
              children: `Admin: ` + props.adminId,
              className: "page-subtitle"
            })
          ],
          className: "page-header"
        }),
        JsxRuntime.jsx("div", {
          children: JsxRuntime.jsx("p", {
            children: "Admin panel - coming soon",
            className: "text-center"
          }),
          className: "container"
        })
      ],
      className: "page",
      "data-testid": "admin-page"
    });
  }
  function expose3() {
    setWindowProperty("Admin", Admin);
  }
  var make2 = Admin;

  // lib/es6/src/components/Queue.js
  var React3 = __toESM(require_react(), 1);

  // lib/es6/src/components/Ticket.js
  var React = __toESM(require_react(), 1);
  var JsxRuntime2 = __toESM(require_jsx_runtime(), 1);
  var makeStyle = (function(s) {
    return s;
  });
  function Ticket(props) {
    let __isRevealing = props.isRevealing;
    let storeName = props.storeName;
    let isRevealing = __isRevealing !== void 0 ? __isRevealing : false;
    let match = React.useState(() => !isRevealing);
    let setRevealed = match[1];
    let revealed = match[0];
    React.useEffect(() => {
      if (!isRevealing) {
        return;
      }
      let timerId = setTimeout(() => setRevealed((param) => true), 100);
      return () => {
        clearTimeout(timerId);
      };
    }, [isRevealing]);
    let style = makeStyle({
      opacity: revealed ? "1" : "0",
      transform: revealed ? "scale(1)" : "scale(0.9)",
      transition: "all 0.3s ease-out"
    });
    return JsxRuntime2.jsxs("div", {
      children: [
        storeName !== void 0 ? JsxRuntime2.jsx("div", {
          children: storeName,
          className: "ticket-store-name",
          "data-testid": "ticket-store-name"
        }) : null,
        JsxRuntime2.jsx("div", {
          children: `#` + props.number.toString(),
          className: "ticket-number-display",
          "data-testid": "ticket-number"
        }),
        JsxRuntime2.jsx("div", {
          children: "Your Number",
          className: "ticket-your-number"
        })
      ],
      className: `paper-ticket ` + (revealed ? "revealed" : ""),
      "data-testid": "ticket",
      style
    });
  }
  function expose4() {
    setWindowProperty("Ticket", Ticket);
  }
  var make3 = Ticket;

  // lib/es6/src/components/Dispenser.js
  var React2 = __toESM(require_react(), 1);
  var JsxRuntime3 = __toESM(require_jsx_runtime(), 1);
  var makeStyle2 = (function(s) {
    return s;
  });
  function getTouchClientY(event) {
    let touches = event.touches;
    let touch = touches[0];
    if (touch !== void 0) {
      return valFromOption(touch).clientY;
    } else {
      return 0;
    }
  }
  var addWindowListeners = (function(onMouseMove, onTouchMove, onEnd) {
    window.addEventListener("mousemove", onMouseMove);
    window.addEventListener("mouseup", onEnd);
    window.addEventListener("touchmove", onTouchMove, { passive: true });
    window.addEventListener("touchend", onEnd);
  });
  var removeWindowListeners = (function(onMouseMove, onTouchMove, onEnd) {
    window.removeEventListener("mousemove", onMouseMove);
    window.removeEventListener("mouseup", onEnd);
    window.removeEventListener("touchmove", onTouchMove);
    window.removeEventListener("touchend", onEnd);
  });
  function Dispenser(props) {
    let __isDisabled = props.isDisabled;
    let onPull = props.onPull;
    let isDisabled = __isDisabled !== void 0 ? __isDisabled : false;
    let match = React2.useState(() => false);
    let setIsDragging = match[1];
    let isDragging = match[0];
    let match$1 = React2.useState(() => 0);
    let setDragProgress = match$1[1];
    let dragProgress = match$1[0];
    let startYRef = React2.useRef(0);
    let handleStart = (clientY) => {
      if (!isDisabled) {
        setIsDragging((param) => true);
        startYRef.current = clientY;
        return;
      }
    };
    let handleMouseDown = (e) => {
      e.preventDefault();
      handleStart(e.clientY);
    };
    let handleTouchStart = (e) => handleStart(getTouchClientY(e));
    let handleMove = (clientY) => {
      if (!(isDragging && !isDisabled)) {
        return;
      }
      let deltaY = clientY - startYRef.current;
      let progress = Math.min(Math.max(deltaY, 0), 80);
      setDragProgress((param) => progress);
    };
    let handleEnd = () => {
      if (isDragging && !isDisabled) {
        setIsDragging((param) => false);
        if (dragProgress >= 80 && onPull !== void 0) {
          onPull();
        }
        return setDragProgress((param) => 0);
      }
    };
    let handleClick = (_e) => {
      if (!isDisabled && !isDragging && dragProgress <= 5 && onPull !== void 0) {
        return onPull();
      }
    };
    React2.useEffect(() => {
      if (!isDragging) {
        return;
      }
      let handleGlobalMouseMove = (e) => handleMove(e.clientY);
      let handleGlobalTouchMove = (e) => {
        let touches = e.touches;
        let touch = touches[0];
        if (touch !== void 0) {
          return handleMove(valFromOption(touch).clientY);
        }
      };
      let handleGlobalEnd = (param) => handleEnd();
      addWindowListeners(handleGlobalMouseMove, handleGlobalTouchMove, handleGlobalEnd);
      return () => removeWindowListeners(handleGlobalMouseMove, handleGlobalTouchMove, handleGlobalEnd);
    }, [
      isDragging,
      dragProgress
    ]);
    let progressPercent = dragProgress / 80 * 100;
    let ticketOffset = Math.min(dragProgress * 0.5, 40);
    let dispenserStyle = makeStyle2({
      cursor: isDisabled ? "not-allowed" : "grab",
      opacity: isDisabled ? "0.7" : "1"
    });
    let ticketStyle = makeStyle2({
      transform: `translateY(` + ticketOffset.toString() + `px)`,
      opacity: (progressPercent / 100).toString()
    });
    let innerTicketStyle = makeStyle2({
      padding: "0.75rem"
    });
    let innerContentStyle = makeStyle2({
      fontSize: "2rem",
      fontWeight: "900",
      textAlign: "center"
    });
    let pullIndicatorStyle = makeStyle2({
      position: "absolute",
      bottom: "-30px",
      left: "50%",
      transform: "translateX(-50%)",
      fontSize: "0.75rem",
      color: "var(--color-gray)"
    });
    return JsxRuntime3.jsxs("div", {
      children: [
        JsxRuntime3.jsxs("div", {
          children: [
            JsxRuntime3.jsx("div", {
              children: "Take a Number",
              className: "dispenser-label"
            }),
            JsxRuntime3.jsx("div", {
              children: isDisabled ? "Please wait..." : "\u2193 Tap or drag down \u2193",
              className: "dispenser-hint"
            }),
            JsxRuntime3.jsx("div", {
              className: "dispenser-slot"
            })
          ],
          className: `dispenser ` + (isDisabled ? "disabled" : ""),
          "data-testid": "dispenser-pull-area",
          style: dispenserStyle,
          onClick: handleClick,
          onMouseDown: handleMouseDown,
          onTouchStart: handleTouchStart
        }),
        JsxRuntime3.jsx("div", {
          children: JsxRuntime3.jsx("div", {
            children: JsxRuntime3.jsx("div", {
              children: "?",
              style: innerContentStyle
            }),
            className: "paper-ticket",
            style: innerTicketStyle
          }),
          className: `ticket-emerging ` + (dragProgress > 0 ? "pulling" : ""),
          "data-testid": "ticket-preview",
          style: ticketStyle
        }),
        isDragging ? JsxRuntime3.jsx("div", {
          children: progressPercent >= 100 ? "Release!" : `Pull... ` + (Math.round(progressPercent) | 0).toString() + `%`,
          className: "pull-indicator",
          style: pullIndicatorStyle
        }) : null
      ],
      className: "dispenser-container",
      "data-testid": "dispenser"
    });
  }
  function expose5() {
    setWindowProperty("Dispenser", Dispenser);
  }
  var make4 = Dispenser;

  // lib/es6/src/bindings/Gun.js
  function isGunAvailable() {
    return isSome(fromNullable(window.Gun));
  }

  // lib/es6/src/Types.js
  function servedByToString(servedBy) {
    if (servedBy === "Self") {
      return "self";
    } else {
      return "operator";
    }
  }

  // lib/es6/src/lib/GunHelpers.js
  var gunInstance = {
    contents: void 0
  };
  var defaultPeers = [
    "https://relay.peer.ooo/gun",
    "https://gun-manhattan.herokuapp.com/gun"
  ];
  function initGun(peers) {
    let gun = gunInstance.contents;
    if (gun !== void 0) {
      return valFromOption(gun);
    }
    if (!isGunAvailable()) {
      $$throw("Gun is not loaded. Include gun.js before using this module.");
    }
    let p = getOr(peers, defaultPeers);
    let gun$1 = window.Gun(p);
    gunInstance.contents = some(gun$1);
    return gun$1;
  }
  function getGun() {
    let gun = gunInstance.contents;
    if (gun !== void 0) {
      return valFromOption(gun);
    } else {
      return $$throw("Gun not initialized. Call initGun() first.");
    }
  }
  function resetGun() {
    gunInstance.contents = void 0;
  }
  var generateId = Crypto.generateUUID;
  function sanitizeName(name2) {
    return name2.replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll('"', "&quot;").replaceAll("'", "&#039;");
  }
  async function createStore(name2, options) {
    let trimmedName = name2.trim();
    if (trimmedName.length < 1 || trimmedName.length > 50) {
      $$throw("Store name must be 1-50 characters");
    }
    let sanitizedName = sanitizeName(trimmedName);
    let gun = getGun();
    let storeId = generateId();
    let adminId = generateId();
    let timestamp = Date.now();
    let expiryHours = getOr(flatMap(options, (o) => o.expiryHours), 24);
    let expiryAfterServed = getOr(flatMap(options, (o) => o.expiryAfterServed), 10);
    let store_settings = {
      expiryHours,
      expiryAfterServed
    };
    let store = {
      id: storeId,
      name: sanitizedName,
      createdAt: timestamp,
      adminId,
      settings: store_settings,
      currentNumber: 0,
      nowServing: 0,
      servedToday: 0,
      servedLastHour: 0,
      version: "1.0"
    };
    return await new Promise((resolve, reject) => {
      let ref = gun.get("stores").get(storeId);
      ref.put(store, (ack) => {
        let err = ack.err;
        if (err == null) {
          return resolve({
            storeId,
            adminId,
            store
          });
        } else {
          return reject(make(err));
        }
      });
    });
  }
  async function getStore(storeId, timeoutOpt) {
    let timeout = timeoutOpt !== void 0 ? timeoutOpt : 5e3;
    let gun = getGun();
    return await new Promise((resolve, _reject) => {
      let resolved = {
        contents: false
      };
      let timeoutId = {
        contents: void 0
      };
      let ref_ = gun.get("stores").get(storeId);
      let handleData = (data, _key) => {
        if (data == null) {
          return;
        }
        if (resolved.contents || data.id === "") {
          return;
        }
        resolved.contents = true;
        let id = timeoutId.contents;
        if (id !== void 0) {
          clearTimeout(valFromOption(id));
        }
        ref_.off();
        resolve(data);
      };
      ref_.on(handleData);
      ref_.once(handleData);
      timeoutId.contents = some(setTimeout(() => {
        if (!resolved.contents) {
          resolved.contents = true;
          ref_.off();
          return resolve(void 0);
        }
      }, timeout));
    });
  }
  async function getStoreByAdminId(adminId) {
    let gun = getGun();
    return await new Promise((resolve, _reject) => {
      let found = {
        contents: false
      };
      let ref_ = gun.get("stores");
      ref_.map().once((store, _key) => {
        if (!(store == null) && !found.contents && store.adminId === adminId) {
          found.contents = true;
          return resolve(store);
        }
      });
      setTimeout(() => {
        if (!found.contents) {
          return resolve(void 0);
        }
      }, 2e3);
    });
  }
  async function updateStore(storeId, updates) {
    let gun = getGun();
    await new Promise((resolve, reject) => {
      let ref_ = gun.get("stores").get(storeId);
      ref_.put(updates, (ack) => {
        let err = ack.err;
        if (err == null) {
          return resolve();
        } else {
          return reject(make(err));
        }
      });
    });
    let store = await getStore(storeId, void 0);
    if (store !== void 0) {
      return store;
    } else {
      return $$throw("Failed to get updated store");
    }
  }
  function subscribeToStore(storeId, callback) {
    let gun = getGun();
    let ref_ = gun.get("stores").get(storeId);
    ref_.on((data, _key) => {
      if (!(data == null) && data.id !== "") {
        return callback(data);
      }
    });
    return () => {
      ref_.off();
    };
  }
  async function createTicket(storeId, deviceId) {
    let gun = getGun();
    let storeOpt = await getStore(storeId, void 0);
    let store = storeOpt !== void 0 ? storeOpt : $$throw("Store not found");
    let nextNumber = store.currentNumber + 1 | 0;
    let timestamp = Date.now();
    let ticket_servedAt = null;
    let ticket_servedBy = null;
    let ticket = {
      number: nextNumber,
      deviceId,
      issuedAt: timestamp,
      status: "waiting",
      servedAt: ticket_servedAt,
      servedBy: ticket_servedBy
    };
    return await new Promise((resolve, reject) => {
      let storeRef = gun.get("stores").get(storeId);
      storeRef.put({
        currentNumber: nextNumber
      }, (ack) => {
        let err = ack.err;
        if (!(err == null)) {
          return reject(make(err));
        }
        let ticketRef = gun.get("stores").get(storeId).get("tickets").get(nextNumber.toString());
        ticketRef.put(ticket, (ack2) => {
          let err2 = ack2.err;
          if (err2 == null) {
            return resolve(ticket);
          } else {
            return reject(make(err2));
          }
        });
      });
    });
  }
  async function getTicket2(storeId, ticketNumber) {
    let gun = getGun();
    return await new Promise((resolve, _reject) => {
      let ref_ = gun.get("stores").get(storeId).get("tickets").get(ticketNumber.toString());
      ref_.once((data, _key) => {
        if (!(data == null) && data.number > 0) {
          return resolve(data);
        } else {
          return resolve(void 0);
        }
      });
    });
  }
  async function getTicketByDeviceId(storeId, deviceId) {
    let gun = getGun();
    return await new Promise((resolve, _reject) => {
      let found = {
        contents: false
      };
      let ref_ = gun.get("stores").get(storeId).get("tickets");
      ref_.map().once((ticket, _key) => {
        if (!(ticket == null) && !found.contents && ticket.deviceId === deviceId && ticket.status === "waiting") {
          found.contents = true;
          return resolve(ticket);
        }
      });
      setTimeout(() => {
        if (!found.contents) {
          return resolve(void 0);
        }
      }, 2e3);
    });
  }
  async function getTickets(storeId, status) {
    let gun = getGun();
    let tickets = {
      contents: []
    };
    await new Promise((resolve, _reject) => {
      let ref_ = gun.get("stores").get(storeId).get("tickets");
      ref_.map().once((ticket, _key) => {
        if (ticket == null) {
          return;
        }
        if (ticket.number <= 0) {
          return;
        }
        let shouldInclude = status !== void 0 ? ticket.status === status : true;
        if (shouldInclude) {
          tickets.contents = tickets.contents.concat([ticket]);
          return;
        }
      });
      setTimeout(() => resolve(), 500);
    });
    return tickets.contents.toSorted((a, b) => a.number - b.number | 0);
  }
  async function updateTicket(storeId, ticketNumber, updates) {
    let gun = getGun();
    await new Promise((resolve, reject) => {
      let ref_ = gun.get("stores").get(storeId).get("tickets").get(ticketNumber.toString());
      ref_.put(updates, (ack) => {
        let err = ack.err;
        if (err == null) {
          return resolve();
        } else {
          return reject(make(err));
        }
      });
    });
    let ticketOpt = await getTicket2(storeId, ticketNumber);
    if (ticketOpt !== void 0) {
      return ticketOpt;
    } else {
      return $$throw("Failed to get updated ticket");
    }
  }
  async function markTicketServed(storeId, ticketNumber, servedByOpt) {
    let servedBy = servedByOpt !== void 0 ? servedByOpt : "Self";
    let timestamp = Date.now();
    let servedByStr = servedByToString(servedBy);
    let ticket = await updateTicket(storeId, ticketNumber, {
      status: "served",
      servedAt: timestamp,
      servedBy: servedByStr
    });
    let storeOpt = await getStore(storeId, void 0);
    if (storeOpt !== void 0) {
      let newNowServing = Math.max(storeOpt.nowServing, ticketNumber);
      await updateStore(storeId, {
        nowServing: newNowServing,
        servedToday: storeOpt.servedToday + 1 | 0,
        servedLastHour: storeOpt.servedLastHour + 1 | 0
      });
    }
    return ticket;
  }
  function subscribeToTickets(storeId, callback) {
    let gun = getGun();
    let ref_ = gun.get("stores").get(storeId).get("tickets");
    ref_.map().on((ticket, _key) => {
      if (!(ticket == null) && ticket.number > 0) {
        return callback(ticket);
      }
    });
    return () => {
      ref_.map().off();
    };
  }
  function expose6() {
    setWindowProperty("GunHelpers", {
      initGun,
      getGun,
      resetGun,
      generateId,
      createStore,
      getStore,
      getStoreByAdminId,
      updateStore,
      subscribeToStore,
      createTicket,
      getTicket: getTicket2,
      getTicketByDeviceId,
      getTickets,
      updateTicket,
      markTicketServed,
      subscribeToTickets
    });
  }

  // lib/es6/src/components/ServedScreen.js
  var JsxRuntime4 = __toESM(require_jsx_runtime(), 1);
  function ServedScreen(props) {
    let onTakeAnother = props.onTakeAnother;
    let twitterHandle = "@storename";
    let displayName = getOr(props.storeName, "us");
    let handleTakeAnother = (_e) => {
      if (onTakeAnother !== void 0) {
        return onTakeAnother();
      }
    };
    return JsxRuntime4.jsxs("div", {
      children: [
        JsxRuntime4.jsx("div", {
          children: "\u2713",
          className: "served-checkmark"
        }),
        JsxRuntime4.jsx("h1", {
          children: "Thanks for visiting!",
          className: "served-title"
        }),
        JsxRuntime4.jsx("p", {
          children: "We hope to see you again soon.",
          className: "served-message"
        }),
        JsxRuntime4.jsxs("div", {
          children: [
            JsxRuntime4.jsx("h3", {
              children: `Follow ` + displayName
            }),
            JsxRuntime4.jsx("p", {
              children: twitterHandle,
              className: "social-handle"
            }),
            JsxRuntime4.jsx("a", {
              children: "\u{1F426} Follow on Twitter",
              className: "social-link",
              "data-testid": "twitter-link",
              href: `https://twitter.com/` + twitterHandle.slice(1, 100),
              rel: "noopener noreferrer",
              target: "_blank"
            })
          ],
          className: "social-prompt",
          "data-testid": "social-prompt"
        }),
        JsxRuntime4.jsx("button", {
          children: "Take Another Number",
          className: "btn btn-secondary",
          "data-testid": "take-another-btn",
          onClick: handleTakeAnother
        })
      ],
      className: "served-screen",
      "data-testid": "served-screen"
    });
  }
  function expose7() {
    setWindowProperty("ServedScreen", ServedScreen);
  }
  var make5 = ServedScreen;

  // node_modules/@rescript/runtime/lib/es6/Stdlib_JsExn.js
  var getOrUndefined = ((fieldName) => (t) => t && typeof t[fieldName] === "string" ? t[fieldName] : void 0);
  var stack = getOrUndefined("stack");
  var message = getOrUndefined("message");
  var name = getOrUndefined("name");
  var fileName = getOrUndefined("fileName");

  // lib/es6/src/components/Queue.js
  var JsxRuntime5 = __toESM(require_jsx_runtime(), 1);

  // node_modules/@rescript/runtime/lib/es6/Primitive_exceptions.js
  function isExtension(e) {
    if (e == null) {
      return false;
    } else {
      return typeof e.RE_EXN_ID === "string";
    }
  }
  function internalToException(e) {
    if (isExtension(e)) {
      return e;
    } else {
      return {
        RE_EXN_ID: "JsExn",
        _1: e
      };
    }
  }

  // lib/es6/src/components/Queue.js
  function Queue$ConfirmDialog(props) {
    let onCancel = props.onCancel;
    let onConfirm = props.onConfirm;
    return JsxRuntime5.jsx("div", {
      children: JsxRuntime5.jsxs("div", {
        children: [
          JsxRuntime5.jsx("h3", {
            children: "Mark as Served?"
          }),
          JsxRuntime5.jsx("p", {
            children: "This will remove you from the queue."
          }),
          JsxRuntime5.jsxs("div", {
            children: [
              JsxRuntime5.jsx("button", {
                children: "Cancel",
                className: "btn btn-outline",
                "data-testid": "cancel-btn",
                onClick: (param) => onCancel()
              }),
              JsxRuntime5.jsx("button", {
                children: "Yes, I'm Done",
                className: "btn btn-primary",
                "data-testid": "confirm-btn",
                onClick: (param) => onConfirm()
              })
            ],
            className: "confirm-dialog-buttons"
          })
        ],
        className: "confirm-dialog"
      }),
      className: "confirm-dialog-overlay",
      "data-testid": "confirm-dialog"
    });
  }
  function Queue(props) {
    let storeId = props.storeId;
    let match = React3.useState(() => {
    });
    let setStore = match[1];
    let store = match[0];
    let match$1 = React3.useState(() => {
    });
    let setTicket = match$1[1];
    let ticket = match$1[0];
    let match$2 = React3.useState(() => true);
    let setIsLoading = match$2[1];
    let match$3 = React3.useState(() => {
    });
    let setError = match$3[1];
    let error = match$3[0];
    let match$4 = React3.useState(() => false);
    let setIsTakingNumber = match$4[1];
    let isTakingNumber = match$4[0];
    let match$5 = React3.useState(() => false);
    let setShowServedScreen = match$5[1];
    let match$6 = React3.useState(() => false);
    let setShowConfirmDialog = match$6[1];
    let match$7 = React3.useState(() => false);
    let setIsIncognito = match$7[1];
    let unsubscribeRef = React3.useRef(void 0);
    let loadStore = async () => {
      try {
        let storeData = await getStore(storeId, void 0);
        if (storeData !== void 0) {
          setStore((param) => storeData);
        } else {
          setError((param) => "Queue not found");
        }
      } catch (raw_err) {
        let err = internalToException(raw_err);
        if (err.RE_EXN_ID === "JsExn") {
          console.error(err._1);
          setError((param) => "Failed to load queue");
        } else {
          throw err;
        }
      }
      return setIsLoading((param) => false);
    };
    let checkExistingTicket = () => {
      if (!hasTicket(storeId)) {
        return;
      }
      let storedTicket = getTicket(storeId);
      if (storedTicket !== void 0) {
        if (storedTicket.status === "waiting") {
          return setTicket((param) => storedTicket);
        } else if (storedTicket.status === "served") {
          return setShowServedScreen((param) => true);
        } else {
          return;
        }
      }
    };
    React3.useEffect(() => {
      if (isIncognito()) {
        setIsIncognito((param) => true);
        setIsLoading((param) => false);
      } else {
        initGun(void 0);
        loadStore();
        checkExistingTicket();
      }
      return () => {
        let unsub = unsubscribeRef.current;
        if (unsub !== void 0) {
          return unsub();
        }
      };
    }, []);
    React3.useEffect(() => {
      if (store === void 0) {
        return;
      }
      let unsub = subscribeToStore(storeId, (updatedStore) => setStore((param) => updatedStore));
      unsubscribeRef.current = unsub;
      return () => {
        unsub();
        unsubscribeRef.current = void 0;
      };
    }, [isSome(store)]);
    let handleTakeNumber = async () => {
      if (isTakingNumber) {
        return;
      }
      setIsTakingNumber((param) => true);
      setError((param) => {
      });
      try {
        let keypair = await generateKeyPair();
        let deviceId = await getDeviceId2(keypair);
        let existingTicket = await getTicketByDeviceId(storeId, deviceId);
        let exit2 = 0;
        if (existingTicket !== void 0 && existingTicket.status === "waiting") {
          setTicket((param) => existingTicket);
          storeTicket(storeId, existingTicket);
        } else {
          exit2 = 1;
        }
        if (exit2 === 1) {
          let newTicket = await createTicket(storeId, deviceId);
          setTicket((param) => newTicket);
          storeTicket(storeId, newTicket);
        }
      } catch (raw_err) {
        let err = internalToException(raw_err);
        if (err.RE_EXN_ID === "JsExn") {
          let err$1 = err._1;
          console.error(err$1);
          let msg = getOr(message(err$1), "Failed to get ticket. Please try again.");
          setError((param) => msg);
        } else {
          throw err;
        }
      }
      return setIsTakingNumber((param) => false);
    };
    let handleMarkServed = () => {
      if (ticket !== void 0) {
        return setShowConfirmDialog((param) => true);
      }
    };
    let handleConfirmServed = async () => {
      setShowConfirmDialog((param) => false);
      if (ticket === void 0) {
        return;
      }
      try {
        await markTicketServed(storeId, ticket.number, "Self");
        let updatedTicket_number = ticket.number;
        let updatedTicket_deviceId = ticket.deviceId;
        let updatedTicket_issuedAt = ticket.issuedAt;
        let updatedTicket_servedAt = ticket.servedAt;
        let updatedTicket_servedBy = ticket.servedBy;
        let updatedTicket = {
          number: updatedTicket_number,
          deviceId: updatedTicket_deviceId,
          issuedAt: updatedTicket_issuedAt,
          status: "served",
          servedAt: updatedTicket_servedAt,
          servedBy: updatedTicket_servedBy
        };
        setTicket((param) => updatedTicket);
        storeTicket(storeId, updatedTicket);
        return setShowServedScreen((param) => true);
      } catch (raw_err) {
        let err = internalToException(raw_err);
        if (err.RE_EXN_ID === "JsExn") {
          console.error(err._1);
          return setError((param) => "Failed to mark as served. Please try again.");
        }
        throw err;
      }
    };
    let handleCancelServed = () => setShowConfirmDialog((param) => false);
    let handleTakeAnother = () => {
      clearTicket(storeId);
      setTicket((param) => {
      });
      setShowServedScreen((param) => false);
    };
    let getPosition = () => {
      if (ticket === void 0) {
        return 0;
      }
      if (store === void 0) {
        return 0;
      }
      let nowServing = store.nowServing;
      let position = ticket.number - nowServing | 0;
      return Math.max(0, position);
    };
    let getExpiryTime = () => {
      if (ticket === void 0) {
        return;
      }
      let expiryTime = ticket.issuedAt + 24 * 60 * 60 * 1e3;
      let now = Date.now();
      let remaining = expiryTime - now;
      if (remaining <= 0) {
        return "Expired";
      }
      let hours = remaining / (60 * 60 * 1e3) | 0;
      let minutes = remaining % (60 * 60 * 1e3) / (60 * 1e3) | 0;
      return hours.toString() + `h ` + minutes.toString() + `m`;
    };
    if (match$7[0]) {
      return JsxRuntime5.jsxs("div", {
        children: [
          JsxRuntime5.jsx("div", {
            children: JsxRuntime5.jsx("h1", {
              children: "\u{1F512} Private Mode",
              className: "page-title"
            }),
            className: "page-header"
          }),
          JsxRuntime5.jsx("div", {
            children: JsxRuntime5.jsxs("div", {
              children: [
                JsxRuntime5.jsx("p", {
                  children: "Please open this page in a regular browser window."
                }),
                JsxRuntime5.jsx("p", {
                  children: "Private/Incognito mode is not supported because we need to remember your ticket."
                })
              ],
              className: "incognito-warning",
              "data-testid": "incognito-warning"
            }),
            className: "container"
          })
        ],
        className: "page",
        "data-testid": "queue-page"
      });
    }
    if (match$2[0]) {
      return JsxRuntime5.jsx("div", {
        children: JsxRuntime5.jsx("div", {
          children: "Loading...",
          className: "loading"
        }),
        className: "page",
        "data-testid": "queue-page"
      });
    }
    let exit = 0;
    if (error !== void 0) {
      if (store === void 0) {
        return JsxRuntime5.jsxs("div", {
          children: [
            JsxRuntime5.jsx("div", {
              children: JsxRuntime5.jsx("h1", {
                children: "Queue Not Found",
                className: "page-title"
              }),
              className: "page-header"
            }),
            JsxRuntime5.jsx("div", {
              children: JsxRuntime5.jsxs("div", {
                children: [
                  JsxRuntime5.jsx("p", {
                    children: error
                  }),
                  JsxRuntime5.jsx("p", {
                    children: "Please check the QR code and try again."
                  })
                ],
                className: "error",
                "data-testid": "queue-error"
              }),
              className: "container"
            })
          ],
          className: "page",
          "data-testid": "queue-page"
        });
      }
      exit = 1;
    } else {
      exit = 1;
    }
    if (exit === 1) {
      if (store === void 0) {
        return JsxRuntime5.jsx("div", {
          children: JsxRuntime5.jsx("div", {
            children: "Loading...",
            className: "loading"
          }),
          className: "page",
          "data-testid": "queue-page"
        });
      }
      if (match$5[0]) {
        return JsxRuntime5.jsx(make5, {
          storeName: store.name,
          onTakeAnother: handleTakeAnother
        });
      }
      let exit$1 = 0;
      if (ticket !== void 0) {
        if (ticket.status === "waiting") {
          let position = getPosition();
          let expiryTime = getExpiryTime();
          return JsxRuntime5.jsxs("div", {
            children: [
              match$6[0] ? JsxRuntime5.jsx(Queue$ConfirmDialog, {
                onConfirm: () => {
                  handleConfirmServed();
                },
                onCancel: handleCancelServed
              }) : null,
              JsxRuntime5.jsx("div", {
                children: JsxRuntime5.jsx("h1", {
                  children: store.name,
                  className: "page-title",
                  "data-testid": "store-name"
                }),
                className: "page-header"
              }),
              JsxRuntime5.jsxs("div", {
                children: [
                  JsxRuntime5.jsx(make3, {
                    number: ticket.number,
                    storeName: store.name,
                    isRevealing: true
                  }),
                  JsxRuntime5.jsxs("div", {
                    children: [
                      JsxRuntime5.jsxs("div", {
                        children: [
                          JsxRuntime5.jsx("span", {
                            children: "Now Serving",
                            className: "status-label"
                          }),
                          JsxRuntime5.jsx("span", {
                            children: `#` + store.nowServing.toString(),
                            className: "status-value",
                            "data-testid": "now-serving"
                          })
                        ],
                        className: "status-item"
                      }),
                      JsxRuntime5.jsxs("div", {
                        children: [
                          JsxRuntime5.jsx("span", {
                            children: "Ahead of You",
                            className: "status-label"
                          }),
                          JsxRuntime5.jsx("span", {
                            children: position.toString() + ` ` + (position === 1 ? "person" : "people"),
                            className: "status-value",
                            "data-testid": "people-ahead"
                          })
                        ],
                        className: "status-item"
                      })
                    ],
                    className: "queue-status mt-3",
                    "data-testid": "queue-status"
                  }),
                  position === 0 ? JsxRuntime5.jsx("div", {
                    children: "\u{1F514} It's your turn!",
                    className: "your-turn-alert",
                    "data-testid": "your-turn"
                  }) : null,
                  JsxRuntime5.jsx("button", {
                    children: "I've Been Served \u2713",
                    className: "btn btn-primary btn-full mt-3",
                    "data-testid": "mark-served-btn",
                    onClick: (param) => handleMarkServed()
                  }),
                  expiryTime !== void 0 ? JsxRuntime5.jsx("div", {
                    children: `\u23F0 Expires in ` + expiryTime,
                    className: "expiry-info mt-2",
                    "data-testid": "expiry-info"
                  }) : null,
                  error !== void 0 ? JsxRuntime5.jsx("div", {
                    children: error,
                    className: "error-message mt-2"
                  }) : null,
                  JsxRuntime5.jsx("div", {
                    children: JsxRuntime5.jsx("p", {
                      children: "\u{1F4F1} Add to Home Screen for notifications"
                    }),
                    className: "pwa-prompt mt-4",
                    "data-testid": "pwa-prompt"
                  })
                ],
                className: "container"
              })
            ],
            className: "page",
            "data-testid": "queue-page"
          });
        }
        exit$1 = 2;
      } else {
        exit$1 = 2;
      }
      if (exit$1 === 2) {
        return JsxRuntime5.jsxs("div", {
          children: [
            JsxRuntime5.jsx("div", {
              children: JsxRuntime5.jsx("h1", {
                children: store.name,
                className: "page-title",
                "data-testid": "store-name"
              }),
              className: "page-header"
            }),
            JsxRuntime5.jsxs("div", {
              children: [
                JsxRuntime5.jsx(make4, {
                  onPull: () => {
                    handleTakeNumber();
                  },
                  isDisabled: isTakingNumber
                }),
                isTakingNumber ? JsxRuntime5.jsxs("div", {
                  children: [
                    JsxRuntime5.jsx("div", {
                      children: "\u{1F3AB}",
                      className: "ticket-spinner"
                    }),
                    JsxRuntime5.jsx("p", {
                      children: "Getting your number..."
                    })
                  ],
                  className: "taking-number-animation",
                  "data-testid": "taking-number"
                }) : null,
                error !== void 0 ? JsxRuntime5.jsx("div", {
                  children: error,
                  className: "error-message mt-2",
                  "data-testid": "error-message"
                }) : null,
                JsxRuntime5.jsx("div", {
                  children: JsxRuntime5.jsxs("div", {
                    children: [
                      JsxRuntime5.jsx("span", {
                        children: "Now Serving",
                        className: "status-label"
                      }),
                      JsxRuntime5.jsx("span", {
                        children: `#` + store.nowServing.toString(),
                        className: "status-value",
                        "data-testid": "now-serving"
                      })
                    ],
                    className: "status"
                  }),
                  className: "current-status mt-4"
                })
              ],
              className: "container"
            })
          ],
          className: "page",
          "data-testid": "queue-page"
        });
      }
    }
  }
  function expose8() {
    setWindowProperty("Queue", Queue);
  }
  var make6 = Queue;

  // lib/es6/src/App.js
  var React5 = __toESM(require_react(), 1);

  // lib/es6/src/components/Display.js
  var JsxRuntime6 = __toESM(require_jsx_runtime(), 1);
  function Display(props) {
    return JsxRuntime6.jsxs("div", {
      children: [
        JsxRuntime6.jsxs("div", {
          children: [
            JsxRuntime6.jsx("h1", {
              children: "Display",
              className: "page-title"
            }),
            JsxRuntime6.jsx("p", {
              children: `Store: ` + props.storeId,
              className: "page-subtitle"
            })
          ],
          className: "page-header"
        }),
        JsxRuntime6.jsx("div", {
          children: JsxRuntime6.jsx("p", {
            children: "Display screen - coming soon",
            className: "text-center"
          }),
          className: "container"
        })
      ],
      className: "page",
      "data-testid": "display-page"
    });
  }
  function expose9() {
    setWindowProperty("Display", Display);
  }
  var make7 = Display;

  // lib/es6/src/components/Landing.js
  var React4 = __toESM(require_react(), 1);

  // lib/es6/src/bindings/QRCode.js
  var defaultOptions = {
    width: 256,
    height: 256,
    margin: 2,
    color: {
      dark: "#212121",
      light: "#FFFFFF"
    },
    errorCorrectionLevel: "M"
  };
  function isQRCodeAvailable() {
    return isSome(fromNullable(window.QRCode));
  }
  function generateQRCode(text, options) {
    let opts = getOr(options, defaultOptions);
    return new Promise((resolve, reject) => {
      window.QRCode.toDataURL(text, opts, (error, url) => {
        if (error == null) {
          return resolve(url);
        } else {
          return reject(error);
        }
      });
    });
  }

  // lib/es6/src/lib/QRUtils.js
  async function generateQRCode2(text, options) {
    if (!isQRCodeAvailable()) {
      $$throw("QRCode library is not loaded");
    }
    return await generateQRCode(text, options);
  }
  function downloadQRCode(dataUrl, filenameOpt) {
    let filename = filenameOpt !== void 0 ? filenameOpt : "qrcode.png";
    let link = document.createElement("a");
    link.download = filename;
    link.href = dataUrl;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  }
  function generateCustomerURL(storeId) {
    let baseUrl = window.location.origin + window.location.pathname;
    return baseUrl + `#/q/` + storeId;
  }
  function generateAdminURL(adminId) {
    let baseUrl = window.location.origin + window.location.pathname;
    return baseUrl + `#/admin/` + adminId;
  }
  function generateDisplayURL(storeId) {
    let baseUrl = window.location.origin + window.location.pathname;
    return baseUrl + `#/display/` + storeId;
  }
  function expose10() {
    setWindowProperty("QRUtils", {
      generateQRCode: generateQRCode2,
      downloadQRCode,
      generateCustomerURL,
      generateAdminURL,
      generateDisplayURL
    });
  }

  // node_modules/@rescript/runtime/lib/es6/Stdlib_Promise.js
  function $$catch(promise, callback) {
    return promise.catch((err) => callback(internalToException(err)));
  }

  // lib/es6/src/components/Landing.js
  var JsxRuntime7 = __toESM(require_jsx_runtime(), 1);
  function validateStoreName(name2) {
    let trimmed = name2.trim();
    if (trimmed.length < 1) {
      return "Store name is required";
    } else if (trimmed.length > 50) {
      return "Store name must be 50 characters or less";
    } else if (/<script|javascript:|on\w+=/i.test(trimmed)) {
      return "Invalid characters in store name";
    } else {
      return;
    }
  }
  function Landing$LoadingAnimation(props) {
    return JsxRuntime7.jsxs("div", {
      children: [
        JsxRuntime7.jsx("div", {
          children: JsxRuntime7.jsx("div", {
            children: JsxRuntime7.jsx("div", {
              children: "\u{1F3AB}",
              className: "ticket-front"
            }),
            className: "ticket-spinner"
          }),
          className: "spinner-container"
        }),
        JsxRuntime7.jsx("p", {
          children: "Creating your queue...",
          className: "loading-text"
        }),
        JsxRuntime7.jsx("p", {
          children: "Generating secure keys (this takes a few seconds)",
          className: "loading-subtext"
        })
      ],
      className: "loading-animation",
      "data-testid": "loading-animation"
    });
  }
  function Landing(props) {
    let match = React4.useState(() => "");
    let setStoreName = match[1];
    let storeName = match[0];
    let match$1 = React4.useState(() => {
    });
    let setError = match$1[1];
    let error = match$1[0];
    let match$2 = React4.useState(() => false);
    let setIsLoading = match$2[1];
    let isLoading = match$2[0];
    let match$3 = React4.useState(() => {
    });
    let setCreatedStore = match$3[1];
    let createdStore = match$3[0];
    let match$4 = React4.useState(() => "");
    let setQrCodeUrl = match$4[1];
    let qrCodeUrl = match$4[0];
    let handleCreateStore = async (e) => {
      e.preventDefault();
      let validationError = validateStoreName(storeName);
      if (validationError !== void 0) {
        return setError((param) => validationError);
      }
      setError((param) => {
      });
      setIsLoading((param) => true);
      try {
        initGun(void 0);
        await generateKeyPair();
        let result = await createStore(storeName.trim(), void 0);
        let customerUrl = generateCustomerURL(result.storeId);
        let qrDataUrl = await generateQRCode2(customerUrl, void 0);
        setQrCodeUrl((param) => qrDataUrl);
        setCreatedStore((param) => ({
          storeId: result.storeId,
          adminId: result.adminId,
          store: result.store,
          customerUrl,
          adminUrl: generateAdminURL(result.adminId)
        }));
      } catch (raw_err) {
        let err = internalToException(raw_err);
        if (err.RE_EXN_ID === "JsExn") {
          let err$1 = err._1;
          console.error(err$1);
          let msg = getOr(message(err$1), "Failed to create queue. Please try again.");
          setError((param) => msg);
        } else {
          throw err;
        }
      }
      return setIsLoading((param) => false);
    };
    let handleDownloadQR = (_e) => {
      if (createdStore === void 0) {
        return;
      }
      let safeName = createdStore.store.name.replace(/[^a-zA-Z0-9]/g, "-");
      downloadQRCode(qrCodeUrl, safeName + `-qrcode.png`);
    };
    let copyAdminUrl = (_e) => {
      if (createdStore !== void 0) {
        $$catch(navigator.clipboard.writeText(createdStore.adminUrl), (param) => {
          console.error("Failed to copy");
          return Promise.resolve();
        });
        return;
      }
    };
    if (createdStore !== void 0) {
      return JsxRuntime7.jsxs("div", {
        children: [
          JsxRuntime7.jsxs("div", {
            children: [
              JsxRuntime7.jsx("h1", {
                children: "\u{1F389} Queue Created!",
                className: "page-title"
              }),
              JsxRuntime7.jsx("p", {
                children: createdStore.store.name,
                className: "page-subtitle"
              })
            ],
            className: "page-header"
          }),
          JsxRuntime7.jsxs("div", {
            children: [
              JsxRuntime7.jsx("input", {
                "data-testid": "customer-url",
                type: "hidden",
                value: createdStore.customerUrl
              }),
              JsxRuntime7.jsxs("div", {
                children: [
                  JsxRuntime7.jsx("h2", {
                    children: "Customer QR Code"
                  }),
                  JsxRuntime7.jsx("p", {
                    children: "Print this and display at your counter",
                    className: "text-muted"
                  }),
                  JsxRuntime7.jsx("div", {
                    children: JsxRuntime7.jsx("a", {
                      children: "\u{1F517} Open Queue Page",
                      className: "customer-url-link",
                      "data-testid": "customer-url-link",
                      href: createdStore.customerUrl,
                      target: "_blank"
                    }),
                    className: "customer-url-container mt-2 mb-2"
                  }),
                  JsxRuntime7.jsx("div", {
                    children: JsxRuntime7.jsx("img", {
                      className: "qr-code-image",
                      "data-testid": "qr-code",
                      alt: "Queue QR Code",
                      src: qrCodeUrl
                    }),
                    className: "qr-code-container"
                  }),
                  JsxRuntime7.jsx("button", {
                    children: "\u{1F4E5} Download QR Code",
                    className: "btn btn-primary mt-2",
                    "data-testid": "download-qr",
                    onClick: handleDownloadQR
                  })
                ],
                className: "qr-section",
                "data-testid": "qr-section"
              }),
              JsxRuntime7.jsxs("div", {
                children: [
                  JsxRuntime7.jsx("h2", {
                    children: "Admin URL"
                  }),
                  JsxRuntime7.jsx("p", {
                    children: "Save this link to manage your queue",
                    className: "text-muted"
                  }),
                  JsxRuntime7.jsxs("div", {
                    children: [
                      JsxRuntime7.jsx("input", {
                        className: "admin-url-input",
                        "data-testid": "admin-url",
                        readOnly: true,
                        type: "text",
                        value: createdStore.adminUrl
                      }),
                      JsxRuntime7.jsx("button", {
                        children: "\u{1F4CB} Copy",
                        className: "btn btn-secondary",
                        "data-testid": "copy-admin-url",
                        onClick: copyAdminUrl
                      })
                    ],
                    className: "admin-url-container"
                  }),
                  JsxRuntime7.jsx("p", {
                    children: "\u26A0\uFE0F Save this URL! It's the only way to access your admin panel.",
                    className: "warning-text mt-2"
                  })
                ],
                className: "admin-section mt-4"
              }),
              JsxRuntime7.jsxs("div", {
                children: [
                  JsxRuntime7.jsx("h3", {
                    children: "Next Steps"
                  }),
                  JsxRuntime7.jsxs("ol", {
                    children: [
                      JsxRuntime7.jsx("li", {
                        children: "Print the QR code and display it at your counter"
                      }),
                      JsxRuntime7.jsx("li", {
                        children: "Bookmark the admin URL to manage your queue"
                      }),
                      JsxRuntime7.jsx("li", {
                        children: "Customers scan the QR code to take a number"
                      })
                    ]
                  })
                ],
                className: "next-steps mt-4"
              }),
              JsxRuntime7.jsx("div", {
                children: JsxRuntime7.jsx("a", {
                  children: "Go to Admin Panel \u2192",
                  className: "btn btn-primary",
                  "data-testid": "go-to-admin",
                  href: createdStore.adminUrl
                }),
                className: "actions mt-4"
              })
            ],
            className: "container"
          })
        ],
        className: "page",
        "data-testid": "landing-page",
        id: `store-` + createdStore.storeId
      });
    } else {
      return JsxRuntime7.jsxs("div", {
        children: [
          JsxRuntime7.jsxs("div", {
            children: [
              JsxRuntime7.jsx("h1", {
                children: "\u{1F3AB} Take a Number",
                className: "page-title"
              }),
              JsxRuntime7.jsx("p", {
                children: "Queue management for your store. No app needed.",
                className: "page-subtitle"
              })
            ],
            className: "page-header"
          }),
          JsxRuntime7.jsxs("div", {
            children: [
              isLoading ? JsxRuntime7.jsx(Landing$LoadingAnimation, {}) : JsxRuntime7.jsxs("form", {
                children: [
                  JsxRuntime7.jsxs("div", {
                    children: [
                      JsxRuntime7.jsx("label", {
                        children: "Store Name",
                        className: "form-label",
                        htmlFor: "storeName"
                      }),
                      JsxRuntime7.jsx("input", {
                        className: "form-input",
                        "data-testid": "store-name-input",
                        id: "storeName",
                        disabled: isLoading,
                        maxLength: 50,
                        placeholder: "e.g., Joe's Bakery",
                        type: "text",
                        value: storeName,
                        onInput: (e) => setStoreName((param) => e.target.value)
                      }),
                      JsxRuntime7.jsx("p", {
                        children: storeName.length.toString() + `/50 characters`,
                        className: "form-hint"
                      })
                    ],
                    className: "form-group"
                  }),
                  error !== void 0 ? JsxRuntime7.jsx("div", {
                    children: error,
                    className: "error-message",
                    "data-testid": "error-message"
                  }) : null,
                  JsxRuntime7.jsx("button", {
                    children: "Create My Queue",
                    className: "btn btn-primary btn-full",
                    "data-testid": "create-queue-btn",
                    disabled: isLoading || storeName.trim().length === 0,
                    type: "submit"
                  })
                ],
                className: "create-form",
                onSubmit: (e) => {
                  handleCreateStore(e);
                }
              }),
              isLoading ? null : JsxRuntime7.jsxs("div", {
                children: [
                  JsxRuntime7.jsx("h3", {
                    children: "How it works"
                  }),
                  JsxRuntime7.jsxs("ul", {
                    children: [
                      JsxRuntime7.jsx("li", {
                        children: "\u2728 Create your queue in seconds"
                      }),
                      JsxRuntime7.jsx("li", {
                        children: "\u{1F4F1} Customers scan QR code to take a number"
                      }),
                      JsxRuntime7.jsx("li", {
                        children: "\u{1F514} Real-time updates for everyone"
                      }),
                      JsxRuntime7.jsx("li", {
                        children: "\u{1F6AB} No app download required"
                      })
                    ],
                    className: "feature-list"
                  })
                ],
                className: "features mt-4"
              })
            ],
            className: "container"
          })
        ],
        className: "page",
        "data-testid": "landing-page"
      });
    }
  }
  function expose11() {
    setWindowProperty("Landing", Landing);
  }
  var make8 = Landing;

  // lib/es6/src/App.js
  var JsxRuntime8 = __toESM(require_jsx_runtime(), 1);
  function parseRoute(hash) {
    let h = hash === "" ? "#/" : hash;
    if (h.startsWith("#/q/")) {
      let storeId = h.slice(4, 100);
      return {
        TAG: "CustomerQueue",
        _0: storeId
      };
    }
    if (h.startsWith("#/admin/")) {
      let adminId = h.slice(8, 100);
      return {
        TAG: "AdminPanel",
        _0: adminId
      };
    }
    if (!h.startsWith("#/display/")) {
      return "Landing";
    }
    let storeId$1 = h.slice(10, 100);
    return {
      TAG: "DisplayScreen",
      _0: storeId$1
    };
  }
  function App$Router(props) {
    let match = React5.useState(() => parseRoute(window.location.hash));
    let setRoute = match[1];
    let route = match[0];
    React5.useEffect(() => {
      let onHashChange = (param) => setRoute((param2) => parseRoute(window.location.hash));
      window.addEventListener("hashchange", onHashChange);
      return () => {
        window.removeEventListener("hashchange", onHashChange);
      };
    }, []);
    if (typeof route !== "object") {
      return JsxRuntime8.jsx(make8, {});
    }
    switch (route.TAG) {
      case "CustomerQueue":
        return JsxRuntime8.jsx(make6, {
          storeId: route._0
        });
      case "AdminPanel":
        return JsxRuntime8.jsx(make2, {
          adminId: route._0
        });
      case "DisplayScreen":
        return JsxRuntime8.jsx(make7, {
          storeId: route._0
        });
    }
  }
  var Router = {
    make: App$Router
  };
  function App$App(props) {
    return JsxRuntime8.jsx(App$Router, {});
  }
  var App = {
    make: App$App
  };
  function init() {
    expose();
    expose2();
    expose6();
    expose10();
    expose4();
    expose5();
    expose7();
    expose11();
    expose8();
    expose3();
    expose9();
    let mountApp = (function(container2) {
      var h = window.preact.h;
      var render = window.preact.render;
      var useState6 = window.preactHooks.useState;
      var useEffect5 = window.preactHooks.useEffect;
      var html = window.htm.bind(h);
      window.html = html;
      function Router2() {
        var routeState = useState6(window.location.hash || "#/");
        var route = routeState[0];
        var setRoute = routeState[1];
        useEffect5(function() {
          var onHashChange = function() {
            setRoute(window.location.hash || "#/");
          };
          window.addEventListener("hashchange", onHashChange);
          return function() {
            window.removeEventListener("hashchange", onHashChange);
          };
        }, []);
        if (route.startsWith("#/q/")) {
          var storeId = route.slice(4);
          return h(window.Queue, { storeId });
        }
        if (route.startsWith("#/admin/")) {
          var adminId = route.slice(8);
          return h(window.Admin, { adminId });
        }
        if (route.startsWith("#/display/")) {
          var storeId = route.slice(10);
          return h(window.Display, { storeId });
        }
        return h(window.Landing, {});
      }
      render(h(Router2, {}), container2);
    });
    let container = document.getElementById("app");
    if (container == null) {
      console.error("Could not find #app element");
    } else {
      mountApp(container);
      console.log("Take a Number app initialized");
    }
  }
  init();
  return __toCommonJS(App_exports);
})();
//# sourceMappingURL=app.bundle.js.map
