---
description: Model tier select koro — max / lightning / mid / ultra.
agent: build
---

User model tier select korbe. $ARGUMENTS

Steps:
1. Jodi $ARGUMENTS e tier thake (e.g. "max", "lightning", "mid", "ultra"), seedho `oc-settings model <tier>` chalano (tier na thakle menu chalano).
2. Jodi tier na thake, user ke options diye jaanao:
   - Max (default, full-power, stable) → zyvo/deepseek-v4-flash-free
   - Lightning → zyvo/nemotron-3.5-lightning-free
   - Mid (balanced) → zyvo/mimo-v2.5-free
   - Nemotron Ultra → zyvo/nemotron-3-ultra-free [! provider error hoy — experimental]
   User choice e `oc-settings model <tier>` chalai.
3. Config update hoyeche dekhiye user ke bolo: zyvo restart koruk (tahole notun model lagbe).
4. Free model list: `oc-settings models` diye dekhanor option ache — user chaile dekhao.
