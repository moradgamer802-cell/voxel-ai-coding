---
description: "Session mode — ei session e ar kono permission prompt chaibe na."
agent: build
---

SESSION MODE (Always Allow — session only) check/info korte hobe. $ARGUMENTS

1. Active kina check koro: `echo "$OPENCODE_CONFIG"` — jodi `zyvo-session-perm.json` thake → already ON.
2. ON thakle bolo: "SESSION MODE ON — ei session e kono permission prompt ashbe na. Zyvo exit korle auto safe-mode." Kaj cholte dao.
3. OFF thakle bolo: exit kore `zyvo --yolo` (ba `zyvo -y`) diye abar start korte hobe — tahole ei session e AI **kono dhoroner** permission chaibe na (bash/edit/webfetch sob). Zyvo band korle auto safe ask-mode — kichhu revert korte hobe na.
4. Extra options o mention koro:
   - Persistent always-allow (sob session e): `/approve`
   - Safe ask-mode e fire: `/safe`
   - Full menu: `oc-settings perm`
