---
description: "Permission menu — Allow / Always Allow / Deny / Session 4-option guide."
agent: build
---

Permission options dekhao. $ARGUMENTS

1. Age current config dekho: `grep -A4 '"permission"' ~/.config/opencode/opencode.json`
2. Tarpor ei 4-option menu ta dekhao (exact format):

```
PERMISSION OPTIONS
1) Allow (once)         — TUI prompt e allow chapo (shudhu ekbar)
2) Always Allow         — sob session e persistent allow: oc-settings perm allow
3) Deny                 — TUI prompt e reject chapo (ekbar)
   Deny bash (readonly) — AI shell command cholbe na: oc-settings perm deny
4) Always Allow session — in-chat: /auto  (ba /approve) — ei session e ar KONO prompt nai
                           start theke: zyvo --yolo
```

3. User jeita chay sei onujayi step koro:
   - 2 chaile: `oc-settings perm allow` chalale koro, bolo restart lagbe.
   - Deny-bash chaile: `oc-settings perm deny` chalale koro.
   - 4 chaile: `oc-settings session on` chalale koro (in-chat magic — ekhuni ON).
4. Session-allow er khetre ek line e bolo: "✓ Session mode ON — Zyvo band korle auto safe-mode."
