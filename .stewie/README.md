# .stewie — Project Configuration

This directory contains the Stewie autonomous development configuration for this project.

## Files

- **CLAUDE.md** — Instructions for Claude Code workers
- **config.json** — Services, verification, and rule settings
- **DESIGN.md** — Architecture decisions and checkpoint document
- **scripts/** — Verification and worker management scripts
- **src/** — ReScript coordination logic (optional, for customization)

## Quick Commands

```bash
# Spawn a worker for a task
.stewie/scripts/spawn-worker.sh "Implement feature X"

# Verify web build
.stewie/scripts/verify-web.sh

# Verify mobile builds
.stewie/scripts/verify-mobile.sh
```

## Configuration

Edit `config.json` to:
- Enable/disable services (Linear, Neon, Vercel, CodeRabbit)
- Set verification options
- Configure worker limits

## Customization

- Edit `CLAUDE.md` to add project-specific worker instructions
- Edit `DESIGN.md` to document architecture decisions
- Modify `src/*.res` if you need custom orchestration logic

## Related

- [Stewie Framework](https://github.com/renovatorruler/stewie)
- [ReScript Manifesto Skill](https://github.com/renovatorruler/rescript-manifesto)
