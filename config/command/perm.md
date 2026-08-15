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
2) Always Allow         — bash/edit/webfetch SOB permanent allow (oc-settings perm allow)
3) Deny                 — TUI prompt e reject chapo (ekbar)
   Deny bash (readonly) — AI shell command cholbe na (oc-settings perm deny)
4) Always Allow session — exit kore: zyvo --yolo  → ei session e ar KONO prompt ashbe na
```

3. User jeita chay sei onujayi step koro:
   - 2 chaile: `oc-settings perm allow` chalale koro, bolo zyvo restart lagbe.
   - Deny-bash chaile: `oc-settings perm deny` chalale koro.
   - 4 chaile: `/session` er instruction dekhalao (zyvo --yolo diye restart).
4. Session-allow e khoto diye bolo: exit korle auto safe-mode — kono kaj nite hobe na.
