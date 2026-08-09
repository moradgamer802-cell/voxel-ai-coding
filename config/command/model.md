---
description: Model tier select koro — default / medium / max / tiny (popup menu).
agent: bangla
---

User model tier select korbe. $ARGUMENTS

Steps:
1. Jodi $ARGUMENTS e tier thake (e.g. "max", "mid", "default", "tiny"), seedho `oc-settings model <tier>` chalano (tier nahole ektitira shaalao koro).
2. Jodi tier na thake, user ke menu ektu question/options diye jaanao:
   - Default (fast)  → opencode/deepseek-v4-flash-free
   - Medium (balanced) → opencode/mimo-v2.5-free
   - Max (strong) → opencode/nemotron-3-ultra-free
   - Tiny (smallest) → opencode/ling-3.0-tiny-free
   User choice e `oc-settings model <no>` chalai.
3. Config update hoyeche dekhale user ke bolo: opencode restart koruk (tahole notun model lagbe).
4. Free model list: `oc-settings models` diye dekhanor option ache — user chaile dekhao.