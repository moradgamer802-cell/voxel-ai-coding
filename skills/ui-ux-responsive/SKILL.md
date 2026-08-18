---
name: ui-ux-responsive
description: Beautiful UI, good UX, fully responsive design — visual polish and mobile-first quality. Use for any frontend visual work, styling, layout, or design improvement.
---

# UI/UX Responsive Skill (Full-Power)

## Design taste — 2026 modern look
- Clean, airy layout — breathing space (8/16/24/32 spacing rhythm)
- One clear visual hierarchy: large → medium → small (type scale 1.25x)
- Color: 1 brand color + 1 accent + neutral grays. No rainbows.
- Typography: modern font (Inter / Hind Siliguri for Bangla), line-height 1.5-1.7
- Subtle depth: soft shadows (shadow-sm/md), rounded-xl corners, glassmorphism
  works on heroes — but not everywhere
- Micro-interactions: hover scale/lift, button press feedback, 150-250ms
  ease transitions. Respect `prefers-reduced-motion`

## Mobile-first (90% of users are on phones)
- Write the mobile layout FIRST, then add `sm: md: lg: xl:`
- Breakpoints: 640 / 768 / 1024 / 1280
- Touch targets min 44px — buttons, links, inputs
- Font: body 16px+, never smaller
- Horizontal scroll = bug. Fix it.
- Sticky bottom CTA on phones (for conversion scenes)
- Safe-area insets for notched phones (`env(safe-area-inset-*)`)

## Accessibility (no bypassing)
- Contrast: text 4.5:1, large text 3:1
- `alt` on every image, ARIA label on icon-only buttons
- Visible focus — never hide outline without replacement
- Heading order: h1 → h2 → h3, no skipping

## Tailwind patterns
- Layout: `max-w-6xl mx-auto px-4`, sections `py-16 md:py-24`
- Cards: `rounded-2xl shadow-md hover:shadow-xl transition`
- Buttons: `px-6 py-3 rounded-xl font-semibold active:scale-95 transition`
- Dark mode: `dark:` classes — keep the toggle in localStorage
- Gradient hero: `bg-gradient-to-br from-X to-Y` — use text-white, overlay

## UX flow (for beginner users)
- Empty state: helpful message + action button when no data
- Loading state: spinner/skeleton — never a blank screen
- Forms: inline validation, clear error messages
- Destructive actions: always confirm (delete, reset)
- Success feedback: toast / inline check — the user knows it worked

## Checklist (before delivering)
- [ ] Looks professional on a phone (test at 384px width)
- [ ] Dark mode (where it fits)
- [ ] All touch targets 44px+
- [ ] Contrast passes
- [ ] Hover/focus/active states present
- [ ] No horizontal scroll anywhere
