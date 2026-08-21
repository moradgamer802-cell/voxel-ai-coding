---
name: debugging-fixes
description: Systematic debugging — fix errors, solve crashes, find why something is not working. Use when user reports any problem, error, crash, or unexpected behavior.
---

# Debugging Skill (Full-Power)

## Golden rule
Read the ENTIRE error message. The real cause is usually in the last 3-5 lines of the error.
Reading it for 10 seconds beats guessing a fix.

## Systematic method (in order — no skipping)
1. **REPRODUCE** — check whether the error happens again (run it)
2. **READ** — read the whole error + stack trace. Which file, which line? Mark `file:line`
3. **ISOLATE** — make a small test case or read the related file (read tool).
   Do not touch anything until you have narrowed down the problem zone
4. **ROOT CAUSE** — fix the cause, not the symptom. "Deleting this makes the error go
   away" means the deletion is hiding the problem, not fixing it
5. **FIX** — small, targeted change. No full-file rewrites. Surgical edit,
   `cp x x.bak` backup first if it feels risky
6. **VERIFY** — run again. If it works, regression check: make sure previously
   working features did not break
7. **EXPLAIN** — tell the user in 2-3 lines: what was broken, what was fixed,
   and the exact command if a restart/reinstall is needed

## Tool tricks
- `sh -n script.sh` — shell syntax check, `node --check f.js`, `python3 -m py_compile f.py`
- No logs? Add `console.log` / `print` to isolate — remove them after the fix
- Web: ask the user to copy the browser console errors
- Dependency errors: version mismatch is common — check `npm ls`, the lock file, changelogs

## Common quick wins
- `command not found` → package missing / not on PATH
- Node `ERR_MODULE_NOT_FOUND` → missing `.js` extension on relative import / wrong path
- Python `ModuleNotFoundError` → `pip install <mod>`
- Blank/not working website → file paths are **case-sensitive** (Linux!), hard-refresh the cache
- Port in use → different port or `kill $(lsof -t -i:PORT)`
- CORS error → the API side needs CORS, or use a same-origin proxy
- Termux build tool fails → glibc dependency — use proot Ubuntu or an alternative package

## If stuck (after 2 attempts)
- Websearch the exact error string
- Check version migration notes — APIs change between upgrades
- Step back: make it smaller — start from a minimum working example and add features gradually
- Ask the user 3 things: what they were trying to do / what they expected / what actually happens
