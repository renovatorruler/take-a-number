# Take a Number — Design Document

> Checkpoint file — updated as decisions are made. Preserves context across sessions.

**Project:** Take a Number
**Last updated:** 2026-01-25
**Status:** PRD Complete, Ready for Development

---

## Overview

Zero-friction queue management system. Customers scan QR code, get a ticket number via proof-of-work, track their position, and self-serve when done.

---

## Architecture Decisions

### 2026-01-25 — Tech Stack
**Context:** Need decentralized, no-signup, spam-resistant solution
**Decision:** 
- GunDB for real-time decentralized storage
- GunDB SEA for proof-of-work authentication
- Static HTML/JS frontend (no build step)
- No backend server needed

**Consequences:** 
- Can host anywhere (Vercel, Netlify, GitHub Pages)
- No user accounts to manage
- Spam prevented by PoW computational cost

### 2026-01-25 — Device Identification
**Context:** Need to prevent duplicate tickets without collecting personal data
**Decision:** SEA keypair in localStorage = device identity
**Consequences:** 
- Same device always gets same ticket
- Clearing browser data = new ticket (old expires naturally)
- Privacy preserved

---

## Active Constraints

- [x] No mobile app — web only
- [x] No signup/email — device ID only
- [x] No backend server — GunDB handles everything
- [x] Spam prevention via proof-of-work, not captcha

---

## Services Configuration

| Service | Status | Notes |
|---------|--------|-------|
| GunDB | 🟡 To configure | Primary data store |
| Hosting | ⬜ TBD | Vercel or static |

---

## Open Questions

- [ ] PoW difficulty level?
- [ ] Domain name?

---

## Changelog

### 2026-01-25
- PRD completed
- .stewie initialized
- Ready for M1 development
