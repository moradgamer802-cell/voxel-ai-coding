---
name: clean-code-performance
description: Make code clean, readable, maintainable + fast. Use when writing or refactoring any code in any language.
---

# Clean Code + Performance Skill (Full-Power)

## Clean code — non-negotiable
- Names say what they do: `fetchUserData()` good, `proc2()` bad
- One function does one thing; split it when it passes 30-40 lines
- DRY — if you copy-paste a third time, make a function
- Nesting beyond 3 levels = add early returns
- Comments: write WHY, not WHAT (the code already shows what)
- Before delivering: remove unused code, console.log/debug prints, dead flags
- Consistent style: follow the existing code — not your own preference

## Error handling — critical for beginner users
- Every external operation (fetch, file, db) = try/catch + user-facing message
- Not just "Something went wrong" — what broke + what to do about it
- Handle empty states: no crash when data is missing, friendly message instead
- Technical errors in console (debug), human messages on screen

## Performance — for phone users (in real impact order)
1. **Network**: loading state on every request; debounce search input (300ms);
   cache (memory/localStorage + expiry); parallel where possible (`Promise.all`)
2. **Bundle**: no framework for small sites (vanilla is enough); code-split big apps;
   remove unused dependencies
3. **Render**: `key` on list items; memo only on measured slow components; event
   delegation on dynamic lists
4. **Media**: `loading="lazy"`, set width/height, webp; hero image eager instead of lazy
5. **Compute**: no DOM read/write mix inside loops (batch it);
   for large data use a map instead of O(n²) nested loops

## Refactor method
1. Test/run first and note the current behavior
2. Refactor in small steps (rename → extract function → move) — one at a time
3. Run again after every step — breaks get caught immediately
4. Never combine behavior changes with refactoring

## Checklist (before delivering)
- [ ] All function names self-explanatory
- [ ] Error + empty + loading states present
- [ ] Unused code/prints removed
- [ ] No obvious perf issues (N+1, heavy work on every render)
- [ ] Ran/tested at least once
