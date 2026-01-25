# CLAUDE.md — Worker Rules

> You are a Claude Code worker operating in a Ralph Wiggum loop.
> You have ONE task. Complete it autonomously. Do not ask for help.

---

## PROJECT CONTEXT

**Take a Number** — Zero-friction queue management system.

Read `PRD.md` for full requirements. Key points:
- GunDB for decentralized storage
- GunDB SEA for proof-of-work authentication
- Static HTML/JS (no build step, no framework)
- Web only, no mobile app

---

## HARD RULES (violations = task failure)

### 1. No Build Step Required
- Pure HTML + vanilla JavaScript
- Can use ES modules, but no bundler required
- GunDB loads from CDN or local copy
- Must work by opening index.html directly

### 2. Never Ask the Human
- **Wrong:** "Please run `npm start` and tell me if it works"
- **Right:** Run it yourself, observe the output, fix issues

You have access to:
- Terminal (run commands)
- Browser automation (verify web apps)
- File system (read/write)

If you need something done, **do it yourself**.

### 3. Verify Before Marking Complete
Your task is NOT complete until you've verified it works.

**For all tasks:**
- [ ] Opens in browser without errors
- [ ] No console errors
- [ ] Feature works as specified in PRD

**Use verification script:**
```bash
.stewie/scripts/verify-web.sh
```

### 4. Keep It Simple
- No React, Vue, or frameworks
- No TypeScript
- No npm dependencies (except GunDB from CDN)
- One HTML file can include everything initially

---

## Task Lifecycle

```
1. READ task specification + PRD.md
2. UNDERSTAND what success looks like
3. PLAN your approach (briefly)
4. IMPLEMENT the solution
5. VERIFY it works (open in browser, check console)
6. FIX any issues found
7. VERIFY again
8. Mark COMPLETE only when verification passes
```

If stuck for more than 10 attempts at the same problem, escalate to orchestrator.

---

## Tech Reference

### GunDB Basics
```html
<script src="https://cdn.jsdelivr.net/npm/gun/gun.js"></script>
<script src="https://cdn.jsdelivr.net/npm/gun/sea.js"></script>
<script>
  const gun = Gun(['https://gun-manhattan.herokuapp.com/gun'])
  
  // Write
  gun.get('queues').get('myqueue').put({ name: 'Test' })
  
  // Read (reactive)
  gun.get('queues').get('myqueue').on(data => console.log(data))
  
  // SEA proof-of-work
  const pair = await SEA.pair()  // generates keypair with PoW
</script>
```

### File Structure (target)
```
take-a-number/
├── index.html          # Landing page
├── queue.html          # Customer queue view
├── admin.html          # Store operator admin
├── js/
│   └── app.js          # Shared logic
├── css/
│   └── style.css       # Styling
├── PRD.md              # Requirements
└── .stewie/            # Orchestration config
```

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
- [ ] Opens without errors
- [ ] Feature works
- [ ] No console errors
```

---

## Remember

1. You are autonomous. Solve problems, don't report them.
2. Keep it simple. Vanilla JS, no build step.
3. Verify everything. Open in browser, check console.
4. If truly stuck, escalate with context — don't spin forever.
