---
name: debugging-fixes
description: Systematic debugging — error fix, crash solve, kaj na korar karon ber kora. Use when user reports any problem, error, crash, or unexpected behavior.
---

# Debugging Skill (Full-Power)

## Golden rule
Error message ta PURA poro. Asol karon error er last 3-5 line e thake.
Guess kore fix korar cheye pora 10 second beshi valo.

## Systematic method (order e — jump na)
1. **REPRODUCE** — error ta abar hoy kina dekho (run koro)
2. **READ** — error + stack trace pura poro. Kon file, kon line? `file:line` mark koro
3. **ISOLATE** — choto test case banao ba related file poro (read tool).
   Choto kore problem zone ber na korar por touch na
4. **ROOT CAUSE** — symptom na, karon fix koro. "Eta delete korle error chai"
   mane delete ta hiding, fixing na
5. **FIX** — choto, targeted change. Puro file rewrite na. Surgical edit,
   age `cp x x.bak` backup jodi risky lage
6. **VERIFY** — abar chalao. Kaj korle regression check: ager working feature
   break hoilo kina dekho
7. **EXPLAIN** — user ke Banglish e 2-3 line: ki bhenge chilo, ki fix korle,
   restart/reinstall lagle exact command ta bolo

## Tool tricks
- `sh -n script.sh` — shell syntax check, `node --check f.js`, `python3 -m py_compile f.py`
- Log nei? `console.log` / `print` boshao isolate korar jonjo — fix er por remove
- Web e: browser console errors user ke copy korte bolo
- Dependency error: version mismatch common — `npm ls`, lock file, changelog dekho

## Common quick wins (BD user der common scene)
- `command not found` → package missing / PATH e nai
- Node `ERR_MODULE_NOT_FOUND` → relative import e `.js` extension / path bhul
- Python `ModuleNotFoundError` → `pip install <mod>`
- Website blank/kaj korena → file path **case-sensitive** (Linux!), cache hard-refresh
- Port in use → onno port ba `kill $(lsof -t -i:PORT)`
- CORS error → API side e CORS lagbe ba same-origin proxy
- Termux e build tool fail → glibc dependency — proot Ubuntu ba alternative package

## Stuck hole (2 attempt er por)
- Exact error string diye websearch koro
- Version migration notes dekho — upgrade e API change hoy
- Step back: choto banao — minimum working example e aste aste feature add koro
- User ke 3 ta jineish pobol: ki korte giyechilo / ki asha korcilo / ki hocche
