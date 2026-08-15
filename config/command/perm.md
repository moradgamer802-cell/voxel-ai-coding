---
description: "Permission menu — kono prompt ashbe na, ba kivabe ashbe."
agent: build
---

Permission options dekhao. $ARGUMENTS

1. `echo "$OPENCODE_CONFIG"` chalale dekho auto-allow on kina.
2. Tarpor ei menu ta dekhao (exact format):

```
PERMISSION MODE
1) Auto-allow (DEFAULT)  — zyvo normal mode: kono prompt nai, sob allow
2) Prompt mode          — zyvo --safe: Allow once / Always allow / Reject
3) Always allow (sob session e) — oc-settings perm allow
4) Deny bash (readonly) — oc-settings perm deny
```

3. User jeita chay sei onujayi step koro:
   - 2 chaile bolo: zyvo band kore `zyvo --safe` diye chalao.
   - 3 chaile: `oc-settings perm allow` chalale koro, bolo restart lagbe.
   - 4 chaile: `oc-settings perm deny` chalale koro.
4. Ek line e sesh — onno kono explanation na.
