---
name: react-next-best-practices
description: React / Next.js — clean, scalable, performant apps with modern best practices. Use for any React or Next.js task.
---

# React + Next.js Best Practices (Full-Power)

## Component rules
- Functional components + hooks only — no class components
- Keep them small: one component does one thing; 150+ lines = split it
- Separate logic from UI: extract custom hooks (`useUserData`)
- Prop drilling beyond 3 levels = Context or a state lib (zustand is light and good)
- Early return pattern:
```jsx
if (!user) return <Login />;
return <Dashboard user={user} />;
```

## State discipline
- Server data = a library (TanStack Query) — not your own useState+useEffect
- Local UI state in useState; keep global state minimal
- Don't store derived values in state — compute them in render
- useEffect: only for sync (with external systems). Never for data fetching.

## Next.js (App Router)
- Server Components by default — `"use client"` only where interactivity lives
- Data fetching: await directly in an async Server Component — no API route needed
- Mutations: Server Actions
- `next/image` (with width/height), `next/font`, `next/link`
- Metadata: `export const metadata` in layout — per-page override
- Loading/error UI: `loading.tsx`, `error.tsx` files — never a blank screen for the user

## Forms + validation
- Controlled inputs + inline validation (before submit)
- Zod-type schema validation on submit — same schema on the server side

## Performance (phone users — take this seriously)
- Lists: stable `key` (not index, especially dynamic lists)
- Lazy-load big routes: `next/dynamic`, `React.lazy`
- Images: next/image + proper sizes — lazy everything except the hero
- Bundle: analyze after `npm run build` — check dependencies if it's big
- Re-renders: keep props stable (useCallback only on measured problems —
  not everywhere)

## TypeScript
- `any` is a red flag — use `unknown` + narrowing when needed
- Types co-located or in `types/`; export shared prop types
- API response types defined separately — no inline duplication

## Common bugs guard
- Index as `key` (ghost bugs when reordering)
- Missing effect cleanup (event listener leaks — memory hits on phones)
- Conditional hook calls (rules of hooks)
- Stale closures in `useEffect` — keep dependencies right