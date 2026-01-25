# Take a Number — Product Requirements Document

> Zero-friction queue management. No signup. No app. Just scan and wait.

**Version:** 1.1
**Last Updated:** 2026-01-25
**Status:** Spec Complete — Ready for Development

---

## Overview

**Take a Number** is a self-service queue management system for physical stores. Customers scan a QR code, get a ticket number, and track their position — all without downloading an app or creating an account.

### Core Principles

1. **Zero friction** — No signup, no email, no app download
2. **Self-service** — Customers manage themselves; store operators don't need to intervene
3. **Spam-resistant** — Proof-of-work prevents abuse without requiring personal data
4. **Decentralized** — GunDB for storage; no central server dependency
5. **Privacy-first** — Device ID only; no data collection
6. **Offline-first** — Works with GunDB peer discovery when relay is down
7. **Local data** — Each store's data stays local; customers don't carry other stores' data

---

## User Personas

### Customer
- Walks into a store, sees a "Take a Number" QR code
- Scans with phone camera (no app needed)
- Wants to know their position and when to expect service
- May leave and come back

### Store Operator
- Small business owner (bakery, deli, barbershop, DMV-style service)
- Wants queue management without staff overhead
- Needs to print one QR code and forget about it
- Optionally wants to actively manage queue and notify customers

---

## User Flows

### Flow 1: Customer Takes a Number

```
1. Customer sees printed QR code at store
2. Scans with phone camera → opens web page
3. Sees ticket dispenser graphic
4. Drags down (or taps) to pull ticket
5. Fun animation plays while PoW runs (~2-3 seconds)
6. Red paper ticket reveals: "Your number: #17"
7. Shows: "4 people ahead of you | Now serving: #13"
8. Number tied to device (localStorage)
9. Prompt: "Add to Home Screen for notifications"
```

### Flow 2: Customer Marks Themselves Served

```
1. Customer returns to same URL (or keeps tab open)
2. When served, taps "I've been served"
3. System marks them complete → queue advances
4. Shows: "Thanks! Follow us on Twitter @storename"
```

### Flow 3: Store Operator Creates a Queue

```
1. Operator visits site
2. Enters store name (required)
3. Clicks "Create Queue"
4. PoW runs (~2-3 seconds, spam prevention)
5. Receives:
   - Customer QR code (queue URL)
   - Admin URL (secret, unguessable)
6. Prints customer QR code, sticks at counter
7. Bookmarks admin URL
```

### Flow 4: Store Operator Admin Panel

```
1. Operator opens admin URL (bookmarked)
2. Sees:
   - Now Serving: #13
   - People served today: 47
   - People served last hour: 12
   - Waiting list
3. Can:
   - Mark tickets as served (requires PoW)
   - Download/print QR code
   - View display screen URL
   - Adjust settings
```

### Flow 5: Display Screen (for store TV/monitor)

```
1. Operator opens display URL on store computer/TV
2. Desktop-optimized view shows:
   - Store name
   - NOW SERVING: #42 (large)
   - Served today: 156
   - Served last hour: 23
3. Updates in real-time via GunDB
4. Deli-counter bell sound on number change
```

---

## Features

### MVP (v1.0)

| Feature | Priority | Description |
|---------|----------|-------------|
| Queue creation | P0 | Create queue (name required), get QR code, PoW required |
| Take a number | P0 | Drag/tap ticket dispenser, PoW (~2-3s), red paper ticket UI |
| View position | P0 | Queue position + now serving, real-time updates |
| Self-serve completion | P0 | Mark yourself served → social follow prompt |
| Device persistence | P0 | Same device = same ticket (localStorage) |
| QR code generation | P0 | Downloadable PNG with store URL |
| Incognito detection | P0 | Block with message: "Open in regular browser" |
| Display screen | P1 | Desktop-optimized "Now Serving" for store TVs |
| Operator marking | P1 | Admin can mark tickets served (PoW required) |
| Browser notifications | P1 | "You're next!" with deli counter bell sound |
| PWA prompt | P1 | "Add to Home Screen" for better experience |
| Expiry: time-based | P1 | Ticket expires after 24 hours |
| Expiry: position-based | P1 | Ticket expires after N people served |
| Basic analytics | P2 | Served today, served last hour (operator only) |

### Operating Modes

**Self-Service Mode (default):**
- No store operator intervention needed
- Customers mark themselves as served when done
- "Now Serving" advances automatically
- Unserved tickets auto-expire

**Operator-Managed Mode:**
- Operator has admin URL
- Can mark tickets as served (requires PoW each time)
- All customers notified when their number is called
- Customers can still self-mark if they leave early

Note: These aren't "modes" to switch between — it's simply whether someone with admin access is actively managing or not.

### Queue Number Behavior
- Numbers increment: 1, 2, 3... up to 99999
- Reset to 1 after 99999
- No rate limiting beyond PoW (spam at your own computational expense)

### Future (v2.0+)

| Feature | Description |
|---------|-------------|
| Estimated wait time | Based on average service time |
| Multiple queues | One store, multiple service types |
| Store logo | Custom branding |
| i18n | Multiple languages |
| SMS fallback | Optional phone number for alerts |

---

## Technical Architecture

### Stack

| Component | Technology | Rationale |
|-----------|------------|-----------|
| Frontend | Preact (CDN) | React-like, ~3kb, reactive UI, no build step |
| Styling | CSS (single file) | Simple, no preprocessor needed |
| Database | GunDB (CDN) | Decentralized, real-time, offline-capable, peer discovery |
| Auth/PoW | GunDB SEA (CDN) | Proof-of-work without accounts |
| Hosting | GitHub Pages | Free, simple, default domain for MVP |
| QR Codes | qrcode.js (CDN) | Client-side generation |
| Routing | Hash-based (#/) | Works with static hosting, no server config |

### CDN Dependencies

```html
<!-- Preact -->
<script src="https://unpkg.com/preact@10/dist/preact.umd.js"></script>
<script src="https://unpkg.com/preact@10/hooks/dist/hooks.umd.js"></script>
<script src="https://unpkg.com/htm@3/dist/htm.umd.js"></script>

<!-- GunDB -->
<script src="https://cdn.jsdelivr.net/npm/gun/gun.js"></script>
<script src="https://cdn.jsdelivr.net/npm/gun/sea.js"></script>

<!-- QR Code -->
<script src="https://cdn.jsdelivr.net/npm/qrcode@1/build/qrcode.min.js"></script>
```

### Testing Stack

| Type | Tool | Rationale |
|------|------|-----------|
| Unit Tests | Vitest | Fast, ESM-native, works with Preact |
| E2E Tests | Playwright | Browser automation, already in .stewie scripts |
| Test Runner | Node | Run tests via `npm test` |

```bash
# Directory structure
tests/
├── unit/
│   ├── gun.test.js       # GunDB helpers
│   ├── pow.test.js       # PoW wrapper
│   └── components/       # Component tests
└── e2e/
    ├── create-queue.spec.js
    ├── take-number.spec.js
    └── mark-served.spec.js
```

**Note:** While the app runs without a build step (CDN), tests use Node for convenience. This is acceptable since tests are dev-only.

### Why Preact + HTM (no build step)

```javascript
// HTM lets us write JSX-like syntax without a build step
const { h, render } = preact;
const { useState, useEffect } = preactHooks;
const html = htm.bind(h);

function App() {
  const [count, setCount] = useState(0);
  return html`<button onClick=${() => setCount(count + 1)}>
    Count: ${count}
  </button>`;
}

render(html`<${App} />`, document.body);
```

### GunDB Configuration

```javascript
// Use public relay for MVP (or deploy own later)
const gun = Gun(['https://gun-manhattan.herokuapp.com/gun'])

// Each store = separate "room" for data locality
gun.get('stores').get(storeId)  // only syncs within this store
```

### Data Model

```javascript
// Store
gun.get('stores').get(storeId).put({
  id: 'uuid-unguessable',
  name: 'Joe's Bakery',
  createdAt: timestamp,
  adminId: 'uuid-unguessable-admin',  // secret admin URL ID
  settings: {
    expiryHours: 24,
    expiryAfterServed: 10,
  },
  currentNumber: 42,      // last issued
  nowServing: 38,         // current
  servedToday: 156,       // counter
  servedLastHour: 23,     // rolling
  version: '1.0'
})

// Ticket
gun.get('stores').get(storeId).get('tickets').get(ticketNumber).put({
  number: 17,
  deviceId: 'sea-public-key-hash',
  issuedAt: timestamp,
  status: 'waiting' | 'served' | 'expired' | 'discarded',
  servedAt: timestamp | null,
  servedBy: 'self' | 'operator'
})
```

### URL Structure

```
https://username.github.io/take-a-number/
├── /                     # Landing page (create queue)
├── /q/{storeId}          # Customer queue page
├── /admin/{adminId}      # Operator admin panel
└── /display/{storeId}    # Display screen for TV
```

- `storeId`: UUID, unguessable, shared via QR code
- `adminId`: Separate UUID, secret, only operator knows

### Proof-of-Work Requirements

| Action | PoW Required | Duration |
|--------|--------------|----------|
| Take a number | Yes | ~2-3 seconds |
| Mark self served | No | Instant |
| Create store | Yes | ~2-3 seconds |
| Operator mark served | Yes | ~2-3 seconds |

### Device Identification

- SEA keypair stored in localStorage
- Same keypair = same device = same ticket
- Incognito mode: Detect and block with message
- Multiple tabs: Same ticket shown
- Multiple devices: Multiple tickets (acceptable)

### Offline Behavior

- GunDB peer discovery for local sync
- If relay down, nearby devices sync directly
- Data persists locally, syncs when connectivity returns

### Data Retention

- Purge served/expired tickets after 1 year
- GunDB garbage collection consideration

---

## UI/UX Specifications

### Design Language

- **Style**: Clean, minimal, old-school deli counter aesthetic
- **Ticket**: Classic red paper ticket look (tear-off style)
- **Interaction**: Drag down to pull ticket from dispenser, or tap
- **Animation**: Fun "work being done" animation during PoW (not loading spinner)
- **Sound**: Deli counter bell on notifications
- **Mobile-first**: Optimized for phone screens

### Color Palette (suggested)

```
Primary:    #D32F2F (deli red)
Background: #FFF8E1 (cream/off-white)
Text:       #212121 (near black)
Accent:     #1976D2 (blue for CTAs)
```

### Key Screens

#### 1. Landing Page
```
┌─────────────────────────────────┐
│                                 │
│   🎫 TAKE A NUMBER             │
│                                 │
│   Queue management for your    │
│   store. No app needed.        │
│                                 │
│   Store Name: [____________]   │
│                                 │
│   [Create My Queue]            │
│                                 │
└─────────────────────────────────┘
```

#### 2. Customer Queue Page (Mobile)
```
┌─────────────────────────────────┐
│   JOE'S BAKERY                  │
│                                 │
│   ┌─────────────────────────┐   │
│   │   ▼ PULL FOR TICKET ▼   │   │
│   │  ┌───────────────────┐  │   │
│   │  │                   │  │   │
│   │  │       #17         │  │   │
│   │  │                   │  │   │
│   │  │   YOUR NUMBER     │  │   │
│   │  └───────────────────┘  │   │
│   └─────────────────────────┘   │
│                                 │
│   Now Serving: #13              │
│   4 people ahead of you         │
│                                 │
│   [I'VE BEEN SERVED]            │
│                                 │
│   ───────────────────────────   │
│   ⏰ Expires in 23h 14m         │
│                                 │
│   📱 Add to Home Screen         │
└─────────────────────────────────┘
```

#### 3. Display Screen (Desktop/TV)
```
┌─────────────────────────────────────────────────┐
│                                                 │
│              JOE'S BAKERY                       │
│                                                 │
│           ╔═══════════════════╗                 │
│           ║                   ║                 │
│           ║   NOW SERVING     ║                 │
│           ║                   ║                 │
│           ║       #42         ║                 │
│           ║                   ║                 │
│           ╚═══════════════════╝                 │
│                                                 │
│   Served today: 156    |    Last hour: 23      │
│                                                 │
└─────────────────────────────────────────────────┘
```

#### 4. Admin Panel
```
┌─────────────────────────────────┐
│   JOE'S BAKERY — ADMIN          │
│                                 │
│   Now Serving: #42              │
│   Served today: 156             │
│   Served last hour: 23          │
│                                 │
│   [View Display Screen]         │
│   [Download QR Code]            │
│                                 │
│   Waiting:                      │
│   #43 — 2 min ago  [Mark Served]│
│   #44 — 1 min ago  [Mark Served]│
│   #45 — just now   [Mark Served]│
│                                 │
│   Settings                      │
│   Expiry: [24] hours            │
│   Expire after: [10] served     │
│                                 │
└─────────────────────────────────┘
```

#### 5. Post-Served Screen
```
┌─────────────────────────────────┐
│                                 │
│   ✓ Thanks for visiting!        │
│                                 │
│   Follow Joe's Bakery           │
│   🐦 @joesbakery                │
│                                 │
│   [Take Another Number]         │
│                                 │
└─────────────────────────────────┘
```

---

## Edge Cases

| Scenario | Handling |
|----------|----------|
| Same device scans twice | Return existing ticket |
| Incognito mode | Block: "Please open in regular browser" |
| Multiple tabs | Same ticket shown |
| Multiple devices | Multiple tickets (acceptable) |
| Customer clears data | New ticket (old expires naturally) |
| Relay server down | Peer discovery, local-first |
| Spam attack | PoW makes it computationally expensive |
| Very long queue | No cap for MVP; numbers keep incrementing |

---

## File Structure

```
take-a-number/
├── index.html              # Single HTML entry point
├── css/
│   └── style.css           # All styles (deli counter aesthetic)
├── js/
│   ├── app.js              # Main app, routing, Preact setup
│   ├── components/
│   │   ├── Landing.js      # Create queue page
│   │   ├── Queue.js        # Customer queue page
│   │   ├── Admin.js        # Operator admin panel
│   │   ├── Display.js      # TV display screen
│   │   ├── Ticket.js       # Red paper ticket component
│   │   └── Dispenser.js    # Drag-to-pull dispenser
│   ├── lib/
│   │   ├── gun.js          # GunDB helpers
│   │   ├── pow.js          # Proof-of-work wrapper
│   │   └── storage.js      # localStorage helpers
│   └── utils/
│       └── qr.js           # QR code generation
├── tests/
│   ├── unit/
│   │   ├── gun.test.js     # GunDB helper tests
│   │   ├── pow.test.js     # PoW wrapper tests
│   │   └── storage.test.js # Storage helper tests
│   └── e2e/
│       ├── create-queue.spec.js
│       ├── take-number.spec.js
│       └── full-flow.spec.js
├── assets/
│   ├── bell.mp3            # Deli counter bell sound
│   └── ticket.svg          # Red ticket graphic
├── package.json            # Dev dependencies (test tools only)
├── vitest.config.js        # Unit test config
├── playwright.config.js    # E2E test config
├── PRD.md
├── README.md
└── .stewie/
```

### Routing (Hash-based)

```
#/              → Landing (create queue)
#/q/{storeId}   → Customer queue page
#/admin/{id}    → Operator admin panel  
#/display/{id}  → TV display screen
```

Single `index.html` handles all routes via hash changes.

---

## Success Metrics

| Metric | Target |
|--------|--------|
| Time to first ticket | < 5 seconds (including PoW) |
| Page load (3G) | < 2 seconds |
| Queue creation | < 5 seconds |
| Zero customer support | Self-explanatory UI |

---

## Milestones

### M1: Core Flow
- [ ] Project scaffold + test setup (Vitest + Playwright)
- [ ] Landing page with store creation (PoW)
- [ ] QR code generation
- [ ] Customer queue page with ticket dispenser UI
- [ ] Take a number (drag/tap + PoW)
- [ ] View position (real-time via GunDB)
- [ ] Mark as served → social follow prompt
- [ ] **Unit tests for all lib/ functions**
- [ ] **E2E test: create queue → take number → mark served**

### M2: Operator Features  
- [ ] Admin panel (view queue, mark served with PoW)
- [ ] Display screen for TV
- [ ] Browser notifications + sound
- [ ] **E2E test: operator marks ticket served**

### M3: Polish
- [ ] Time-based expiry
- [ ] Position-based expiry
- [ ] PWA manifest + Add to Home Screen
- [ ] Incognito detection
- [ ] Offline handling
- [ ] Analytics (served today/hour)
- [ ] **E2E test: expiry scenarios**

---

## Open Questions (Resolved)

- [x] PoW difficulty: **2-3 seconds** ✓
- [x] Operators need PoW: **Yes, for creation + marking served** ✓
- [x] Hosting: **GitHub Pages** ✓
- [x] Domain: **Default GitHub domain for MVP** ✓

---

## Appendix: GunDB SEA Primer

```javascript
// Generate keypair (includes PoW)
const pair = await SEA.pair()

// Work/PoW (standalone)
const work = await SEA.work(data, pair)

// Sign data
const signed = await SEA.sign(data, pair)

// Verify
const verified = await SEA.verify(signed, pair.pub)
```

No accounts. No passwords. Just math.

---

*Victory shall be mine.* 🧒🔫
