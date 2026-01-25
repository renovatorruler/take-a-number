# Take a Number — Product Requirements Document

> Zero-friction queue management. No signup. No app. Just scan and wait.

**Version:** 1.0
**Last Updated:** 2026-01-25
**Status:** Draft

---

## Overview

**Take a Number** is a self-service queue management system for physical stores. Customers scan a QR code, get a ticket number, and track their position — all without downloading an app or creating an account.

### Core Principles

1. **Zero friction** — No signup, no email, no app download
2. **Self-service** — Customers manage themselves; store operators don't need to intervene
3. **Spam-resistant** — Proof-of-work prevents abuse without requiring personal data
4. **Decentralized** — GunDB for storage; no central server dependency
5. **Privacy-first** — Device ID only; no data collection

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
- Optionally wants to notify customers or manage queue

---

## User Flows

### Flow 1: Customer Takes a Number

```
1. Customer sees printed QR code at store
2. Scans with phone camera → opens web page
3. Page shows: "Getting your number..." (proof-of-work runs)
4. Page shows: "You are #17 — 4 people ahead of you"
5. Number is tied to device ID (persists if they refresh)
6. Customer waits / leaves / checks back later
```

### Flow 2: Customer Marks Themselves Served

```
1. Customer returns to same URL (or keeps tab open)
2. When served, taps "I've been served"
3. System marks them complete → queue advances
4. Optional: "How was your wait?" (simple feedback, not required)
```

### Flow 3: Store Operator Creates a Queue

```
1. Operator visits take-a-number.com (or self-hosted)
2. Clicks "Create a Queue"
3. Proof-of-work runs (spam prevention for queue creation too)
4. Receives:
   - Unique queue URL
   - QR code image (downloadable/printable)
   - Admin link (tied to device, or SEA keypair)
5. Prints QR code, sticks it at counter
```

### Flow 4: Store Operator Admin Panel

```
1. Operator opens admin link (bookmarked or saved)
2. Sees:
   - Current queue size
   - List of waiting numbers
   - "Now Serving" indicator
3. Can manually:
   - Advance to next customer (optional)
   - Clear expired tickets
   - Adjust settings
```

---

## Features

### MVP (v1.0)

| Feature | Priority | Description |
|---------|----------|-------------|
| Queue creation | P0 | Create queue (name required), get QR code |
| Take a number | P0 | Customer scans, gets ticket via PoW (2-3s) |
| View position | P0 | Customer sees queue position |
| Self-serve completion | P0 | Customer marks themselves served |
| Device persistence | P0 | Same device = same ticket (no duplicates) |
| QR code generation | P0 | Downloadable PNG for printing |
| Two operating modes | P0 | Self-service OR operator-managed |
| Operator mode | P1 | Owner tags "served #N", all customers notified |
| Expiry: time-based | P1 | Ticket expires after N hours (default: 24h) |
| Expiry: position-based | P1 | Ticket expires after N people served (configurable) |
| Admin panel | P1 | View queue, basic controls |

### Operating Modes

**Self-Service Mode (default):**
- No store operator intervention needed
- Customers mark themselves as served when done
- "Now Serving" advances automatically based on customer actions

**Operator-Managed Mode:**
- Store owner takes control of queue
- Can tag "just served ticket #36" → all customers notified
- Can mark tickets as served/discarded
- Customers can still self-mark if they leave early
- "Now Serving" controlled by operator actions

### Queue Number Behavior
- Numbers increment forever (1, 2, 3... 99999)
- Reset to 1 after 99999 (5 digits max)

### Future (v2.0+)

| Feature | Description |
|---------|-------------|
| Notifications | Browser push when "you're next" |
| Estimated wait time | Based on average service time |
| Multiple queues | One store, multiple service types |
| Analytics | Wait times, peak hours, no-shows |
| Custom branding | Store logo on queue page |
| SMS fallback | Optional phone number for alerts |

---

## Technical Architecture

### Stack

| Component | Technology | Rationale |
|-----------|------------|-----------|
| Frontend | Static HTML/JS | No build step, maximum compatibility |
| Database | GunDB | Decentralized, real-time, offline-capable |
| Auth/PoW | GunDB SEA | Proof-of-work without accounts |
| Hosting | Any static host | Vercel, Netlify, GitHub Pages, self-hosted |

### Data Model (GunDB)

```javascript
// Queue
gun.get('queues').get(queueId).put({
  id: 'abc123',
  name: 'Joe's Bakery',
  createdAt: timestamp,
  settings: {
    expiryHours: 24,
    expiryAfterServed: 10,  // expire after 10 people served
  },
  currentNumber: 42,  // last issued
  nowServing: 38,     // display number
})

// Ticket
gun.get('queues').get(queueId).get('tickets').get(ticketId).put({
  id: 'ticket-xyz',
  number: 17,
  deviceId: 'device-hash',
  issuedAt: timestamp,
  status: 'waiting' | 'served' | 'expired',
  servedAt: timestamp | null,
})
```

### Proof-of-Work Flow

```javascript
// On "Take a Number" click:
1. Generate SEA keypair (GunDB built-in)
2. PoW runs client-side (prevents spam)
3. Once complete, ticket is issued
4. Keypair tied to device localStorage
5. Same device requesting again → returns existing ticket
```

### Device Identification

- Primary: SEA keypair stored in localStorage
- Fallback: fingerprint hash (canvas, screen, etc.) — used only to detect "same device"
- No tracking, no cookies, no personal data

### Versioning Strategy

```javascript
// Each queue stores schema version
queue.version = '1.0'

// Client checks compatibility
if (queue.version > clientVersion) {
  // Show "Please refresh" or graceful degradation
}
```

---

## Screens

### 1. Landing Page (take-a-number.com)

```
┌─────────────────────────────────┐
│                                 │
│      🎫 Take a Number          │
│                                 │
│   Queue management without     │
│   the hassle. No app needed.   │
│                                 │
│   [Create a Queue]             │
│                                 │
│   Already have a queue?        │
│   Scan the QR code or enter    │
│   your queue link.             │
│                                 │
└─────────────────────────────────┘
```

### 2. Customer Queue Page

```
┌─────────────────────────────────┐
│   Joe's Bakery                  │
│                                 │
│   Your Number                   │
│       ┌─────────┐               │
│       │   17    │               │
│       └─────────┘               │
│                                 │
│   4 people ahead of you         │
│   Now serving: #13              │
│                                 │
│   [I've Been Served]            │
│                                 │
│   ─────────────────────────     │
│   Ticket expires in 23h 14m     │
│   or after 10 more served       │
└─────────────────────────────────┘
```

### 3. Admin Panel

```
┌─────────────────────────────────┐
│   Joe's Bakery — Admin          │
│                                 │
│   Now Serving: #13              │
│   In Queue: 7 people            │
│                                 │
│   [Download QR Code]            │
│                                 │
│   Settings                      │
│   ├─ Expiry: 24 hours           │
│   └─ Expire after: 10 served    │
│                                 │
│   Queue                         │
│   #13 — waiting (2h ago)        │
│   #14 — waiting (1h ago)        │
│   #15 — waiting (45m ago)       │
│   ...                           │
│                                 │
│   [Clear Expired] [Reset Queue] │
└─────────────────────────────────┘
```

---

## Edge Cases

| Scenario | Handling |
|----------|----------|
| Customer scans twice (same device) | Return existing ticket |
| Customer clears browser data | Gets new ticket (old one orphaned, expires naturally) |
| Two customers share device | They share a ticket (acceptable trade-off) |
| Store operator loses admin link | Can regenerate via SEA keypair recovery (if saved) |
| Queue gets very long | Consider "queue full" cap (future feature) |
| Spam attack | PoW makes it expensive; rate limiting as backup |
| Offline | GunDB syncs when back online |

---

## Success Metrics

| Metric | Target |
|--------|--------|
| Time to first ticket | < 5 seconds (including PoW) |
| Page load (3G) | < 3 seconds |
| Queue creation | < 10 seconds |
| Zero customer support | Self-explanatory UI |

---

## Open Questions

- [x] PoW difficulty: **2-3 seconds** ✓
- [ ] Should store operators need PoW too, or just customers?
- [ ] Domain: take-a-number.com? tan.app? queueme.io?
- [ ] Self-hosting: Provide Docker image or just static files?

---

## Milestones

### M1: Core Flow (Week 1-2)
- [ ] Queue creation + QR code
- [ ] Customer takes a number
- [ ] View queue position
- [ ] Mark as served

### M2: Expiry & Admin (Week 3)
- [ ] Time-based expiry
- [ ] Position-based expiry
- [ ] Basic admin panel

### M3: Polish (Week 4)
- [ ] Mobile-optimized UI
- [ ] Error handling
- [ ] Offline resilience
- [ ] Documentation

---

## Appendix: GunDB SEA Primer

SEA (Security, Encryption, Authorization) provides:
- **Keypair generation** — Public/private key per device
- **Proof of work** — Computational challenge to prevent spam
- **Signatures** — Verify data authenticity without central server
- **Encryption** — Optional, for private data

```javascript
// Generate keypair (includes PoW)
const pair = await SEA.pair()

// Sign data
const signed = await SEA.sign(data, pair)

// Verify
const verified = await SEA.verify(signed, pair.pub)
```

No accounts. No passwords. Just math.

---

*Victory shall be mine.* 🧒🔫
