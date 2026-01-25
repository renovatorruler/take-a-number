# CLAUDE.md — Worker Rules

> You are a Claude Code worker operating in a Ralph Wiggum loop.
> You have ONE task. Complete it autonomously. Do not ask for help.

---

## ABSOLUTE RULE: NO JAVASCRIPT

**All code is ReScript (.res files). No exceptions.**

- JavaScript exists ONLY as compiler output
- If you create a .js or .ts source file, DELETE IT IMMEDIATELY
- This is non-negotiable

Why: LLMs make bugs. Types catch bugs. ReScript has types. JavaScript doesn't.

---

## PROJECT CONTEXT

**Take a Number** — Zero-friction queue management system.

Read `PRD.md` for full requirements.

---

## TECH STACK

### Language & Build
```bash
# ReScript compiler
npx rescript build -with-deps
```

### Dependencies
- `rescript` — Compiler
- `@rescript/react` — React bindings
- `@rescript/core` — Standard library

### Project Structure
```
src/
├── App.res           # Main app, router
├── bindings/
│   ├── Gun.res       # GunDB bindings
│   ├── Sea.res       # GunDB SEA bindings
│   └── QRCode.res    # QR code bindings
├── lib/
│   ├── Store.res     # GunDB store operations
│   ├── Pow.res       # Proof-of-work
│   └── Storage.res   # localStorage
├── components/
│   ├── Landing.res
│   ├── Queue.res
│   ├── Dispenser.res
│   ├── Ticket.res
│   └── ServedScreen.res
└── Types.res         # Shared types
```

### ReScript Patterns

```rescript
// Types first
type ticket = {
  number: int,
  deviceId: string,
  status: [#waiting | #served | #expired],
  issuedAt: float,
}

// Exhaustive pattern matching
let statusToString = status =>
  switch status {
  | #waiting => "Waiting"
  | #served => "Served"
  | #expired => "Expired"
  }

// React component
@react.component
let make = (~storeName: string) => {
  let (tickets, setTickets) = React.useState(() => [])
  
  <div className="queue">
    <h1>{React.string(storeName)}</h1>
  </div>
}
```

### External Bindings Example

```rescript
// Gun.res - GunDB bindings
type gun
type gunRef

@module("gun") @new
external create: array<string> => gun = "default"

@send external get: (gun, string) => gunRef = "get"
@send external put: (gunRef, 'a) => unit = "put"
@send external on: (gunRef, ('a, string) => unit) => unit = "on"
```

---

## HARD RULES

### 1. ReScript Type Manifesto
- Types are mandatory, not optional
- Exhaustive pattern matching (no catch-all `_` unless justified)
- No `any` or `unknown` types
- No stringly-typed code
- Encode states in types (variant types for status, not strings)

### 2. Never Ask the Human
Run commands yourself. Verify yourself. Fix problems yourself.

### 3. Verify Before Complete
```bash
# Must all pass
npx rescript build          # No compiler errors
npm test                    # Unit tests pass
npm run test:e2e            # E2E tests pass
```

### 4. Delete JavaScript Source
If you accidentally create .js/.ts source files:
```bash
rm src/**/*.js src/**/*.ts  # Delete immediately
```

Only `lib/js/` (compiler output) should contain .js files.

---

## Task Lifecycle

```
1. READ task + PRD.md
2. IMPLEMENT in ReScript
3. COMPILE: npx rescript build
4. FIX any compiler errors (the compiler is your friend)
5. VERIFY in browser
6. FIX any runtime issues
7. RUN tests
8. Only COMPLETE when everything passes
```

---

## Remember

1. NO JAVASCRIPT SOURCE FILES. EVER.
2. The compiler catches bugs. Trust it.
3. If it compiles and tests pass, it probably works.
4. If stuck 10+ times on same issue, escalate with context.
