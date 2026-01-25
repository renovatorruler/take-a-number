# CLAUDE.md — Worker Rules

> You are a Claude Code worker operating in a Ralph Wiggum loop.
> You have ONE task. Complete it autonomously. Do not ask for help.

---

## PROJECT CONTEXT

**Take a Number** — Zero-friction queue management system.

Read `PRD.md` for full requirements. Key points:
- Preact for reactive UI (loaded from CDN, no build step)
- GunDB for decentralized real-time data
- GunDB SEA for proof-of-work authentication
- Single `index.html` with hash-based routing
- GitHub Pages hosting

---

## TECH STACK

### CDN Dependencies (load in index.html)

```html
<!-- Preact + HTM (JSX-like without build) -->
<script src="https://unpkg.com/preact@10/dist/preact.umd.js"></script>
<script src="https://unpkg.com/preact@10/hooks/dist/hooks.umd.js"></script>
<script src="https://unpkg.com/htm@3/dist/htm.umd.js"></script>

<!-- GunDB -->
<script src="https://cdn.jsdelivr.net/npm/gun/gun.js"></script>
<script src="https://cdn.jsdelivr.net/npm/gun/sea.js"></script>

<!-- QR Code -->
<script src="https://cdn.jsdelivr.net/npm/qrcode@1/build/qrcode.min.js"></script>
```

### Preact + HTM Pattern

```javascript
// All components use this pattern
const { h, render, Component } = preact;
const { useState, useEffect, useRef } = preactHooks;
const html = htm.bind(h);

// Example component
function MyComponent({ prop }) {
  const [state, setState] = useState(null);
  
  useEffect(() => {
    // Side effects here
  }, []);
  
  return html`
    <div class="my-component">
      <h1>${prop}</h1>
      <button onClick=${() => setState('clicked')}>
        Click me
      </button>
    </div>
  `;
}
```

### GunDB Pattern

```javascript
// Initialize Gun (public relay for MVP)
const gun = Gun(['https://gun-manhattan.herokuapp.com/gun']);

// Subscribe to data (reactive)
gun.get('stores').get(storeId).on((data, key) => {
  console.log('Store updated:', data);
});

// Write data
gun.get('stores').get(storeId).put({
  name: 'Store Name',
  nowServing: 1
});

// SEA proof-of-work
const pair = await SEA.pair(); // ~2-3 seconds of PoW
```

### Hash Routing Pattern

```javascript
function Router() {
  const [route, setRoute] = useState(window.location.hash);
  
  useEffect(() => {
    const onHashChange = () => setRoute(window.location.hash);
    window.addEventListener('hashchange', onHashChange);
    return () => window.removeEventListener('hashchange', onHashChange);
  }, []);
  
  // Parse route
  if (route.startsWith('#/q/')) {
    const storeId = route.slice(4);
    return html`<${Queue} storeId=${storeId} />`;
  }
  if (route.startsWith('#/admin/')) {
    const adminId = route.slice(8);
    return html`<${Admin} adminId=${adminId} />`;
  }
  // Default: landing
  return html`<${Landing} />`;
}
```

---

## HARD RULES (violations = task failure)

### 1. No Build Step
- All JS loaded from CDN or local files
- Use HTM for JSX-like syntax (no transpilation)
- Must work by opening index.html directly
- Test by: `open index.html` or `python -m http.server`

### 2. Never Ask the Human
- **Wrong:** "Please test this and tell me if it works"
- **Right:** Run it yourself, check browser console, fix issues

You have access to:
- Terminal (run commands, start local server)
- Browser automation (verify the app works)
- File system (read/write)

### 3. Verify Before Marking Complete

**For all tasks:**
- [ ] Page loads without errors
- [ ] No console errors
- [ ] Feature works as specified in PRD
- [ ] Works on mobile viewport (responsive)

**Verification steps:**
```bash
# Start local server
cd /Users/ren/dev/take-a-number
python3 -m http.server 8080

# Then use browser tool to verify at http://localhost:8080
```

### 4. File Organization

```
js/
├── app.js              # Entry point, routing, render
├── components/         # Preact components (one per file)
│   └── ComponentName.js
├── lib/                # Utilities and helpers
│   └── gun.js
└── utils/              # Pure functions
    └── helpers.js
```

Each component file should be self-contained with its own state logic.

### 5. Styling

- Use CSS classes, not inline styles
- Mobile-first (min-width media queries)
- Follow the deli counter aesthetic from PRD
- Red ticket: `#D32F2F`, Cream background: `#FFF8E1`

---

## Task Lifecycle

```
1. READ task specification + PRD.md
2. UNDERSTAND what success looks like
3. PLAN your approach (briefly)
4. IMPLEMENT the solution
5. START local server and VERIFY in browser
6. CHECK console for errors
7. FIX any issues found
8. VERIFY again (including mobile viewport)
9. Mark COMPLETE only when verification passes
```

If stuck for more than 10 attempts at the same problem, escalate to orchestrator.

---

## Output Format

When reporting status, use:

```
STATUS: IN_PROGRESS | COMPLETE | BLOCKED | FAILED

SUMMARY: One line describing current state

DETAILS:
- What was done
- What's remaining (if any)
- Blockers (if BLOCKED)
- Error details (if FAILED)

VERIFICATION:
- [ ] Page loads
- [ ] No console errors
- [ ] Feature works
- [ ] Mobile responsive
```

---

## Remember

1. You are autonomous. Solve problems, don't report them.
2. No build step. CDN + local files only.
3. Verify everything. Open in browser, check console, test mobile.
4. If truly stuck, escalate with context — don't spin forever.
