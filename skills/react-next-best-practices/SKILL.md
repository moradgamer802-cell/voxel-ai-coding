---
name: react-next-best-practices
description: React / Next.js — modern best practices diye clean, scalable, performant app. Use for any React or Next.js task.
---

# React + Next.js Best Practices (Full-Power)

## Component rules
- Functional component + hooks only — class component na
- Choto rakho: ek component ek kaj; 150+ line = bhago
- Logic UI theke alaga: custom hook (`useUserData`) e nikolo
- Prop drilling 3 level beshi = Context ba state lib (zustand halka valo)
- Early return pattern:
```jsx
if (!user) return <Login />;
return <Dashboard user={user} />;
```

## State discipline
- Server data = library (TanStack Query) — nijer useState+useEffect na
- Local UI state sokol useState; global minimum rakho
- Derived value state e rakhba na — calculate koro render e
- useEffect: sirf sync (external system er sathe). Data fetch effect e na.

## Next.js (App Router)
- Server Component default — `"use client"` sirf jekhane interactivity
- Data fetch: async Server Component e direct await — API route na lage
- Mutation: Server Actions
- `next/image` (width/height soho), `next/font`, `next/link`
- Metadata: layout e `export const metadata` — per page override
- Loading/error UI: `loading.tsx`, `error.tsx` file — user ke blank screen na

## Forms + validation
- Controlled input + inline validation (submit er agei)
- Zod-type schema validation submit e — server side o same schema

## Performance (phone user — eita seriously nao)
- List: stable `key` (index na, dynamic list e)
- Boro route lazy: `next/dynamic`, `React.lazy`
- Image: next/image + proper size — hero chara sob lazy
- Bundle: `npm run build` er por analyze — beshi hole dependency check
- Re-render: props stable rakho (useCallback sirf measured problem e —
  everywhere na)

## TypeScript
- `any` laal flag — chaile `unknown` + narrow
- Types co-locate ba `types/`; shared props type export koro
- API response type alaga define — inline duplinate na

## Common bugs guard
- `key` er moddhe index (reorder hole ghost bug)
- Effect er cleanup na (event listener leak — phone e memory hit)
- Conditional hook call (rules of hooks)
- `useEffect` e stale closure — dependency thik rakho
