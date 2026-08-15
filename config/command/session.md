---
description: "Session permission check — ekhon prompt ashe kina."
agent: build
---

Session permission check korte hobe. $ARGUMENTS

1. `echo "$OPENCODE_CONFIG"` chalale koro.
2. Jodi `zyvo-session-perm.json` thake → bolo (ek line):
   "Auto-allow ON ✓ — kono permission prompt ashbe na. Zyvo band korleo porer session default ei thakbe."
3. Na thakle (mane `zyvo --safe` mode e cholo) → bolo (ek line):
   "Ekhon safe mode e — Allow once / Always allow / Reject prompt ashbe. Auto-allow e firte normal `zyvo` diye chalao."
4. Onno kono explanation bolo na.
