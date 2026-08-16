---
name: clean-code-performance
description: Code ke clean, readable, maintainable + fast banano. Use when writing or refactoring any code in any language.
---

# Clean Code + Performance Skill (Full-Power)

## Clean code — non-negotiable
- Naam bole kaj: `fetchUserData()` valo, `proc2()` kharap
- Function ekta kaj kore, 30-40 line er beshi hole bhango
- DRY — 3rd bar copy-paste korle function banao
- Nesting 3 level er beshi = early return boshao
- Comment: KENO likhho, KI korche na (code e dekha jay)
- Deliver er age: unused code, console.log/debug print, dead flag SODO
- Consistent style: existing code follow koro — nijer preference na

## Error handling — beginner user er jonno critical
- Har external kaj (fetch, file, db) = try/catch + user-facing Banglish message
- "Something went wrong" na — ki bhangle + ki korle valo hobe
- Empty state handle: data na ashle crash na, friendly message
- Console e technical error (debug), screen e human message

## Performance — phone user der jonno (real impact order e)
1. **Network**: har request e loading state; debounce search input (300ms);
   cache (memory/localStorage + expiry); parallel where possible (`Promise.all`)
2. **Bundle**: choto site e framework na (vanilla enough); code-split boro app e;
   unused dependency remove
3. **Render**: list e `key`; memo shudhu measured slow component e; event
   delegation dynamic list e
4. **Media**: `loading="lazy"`, width/height set, webp, hero image eager bakilazy
5. **Compute**: loop er bhitore DOM read/write mix na (batch koro);
   O(n²) nested loop data boro hole map use koro

## Refactor method
1. Age test/run kore current behavior note koro
2. Choto step e refactor (rename → extract function → move) — ek somoy e ekta
3. Pratyek step er por abar chalao — bhangle sathe sathe dhora jay
4. Behavior change + refactor eksathe kokhono na

## Checklist (deliver er age)
- [ ] Sob function naam self-explanatory
- [ ] Error + empty + loading state ache
- [ ] Unused code/print remove kora
- [ ] Obvious perf issue nai (N+1, har render e heavy kaj)
- [ ] Ekbar run/test kora hoyeche
