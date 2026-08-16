---
name: ui-ux-responsive
description: Beautiful UI, good UX, fully responsive design — visual polish ar mobile-first quality. Use for any frontend visual work, styling, layout, or design improvement.
---

# UI/UX Responsive Skill (Full-Power)

## Design taste — 2026 modern look
- Clean, airy layout — breathing space (8/16/24/32 spacing rhythm)
- Ek clear visual hierarchy: boro → medium → choto (type scale 1.25x)
- Color: 1 brand color + 1 accent + neutral grays. Rainbow na.
- Typography: modern font (Inter / Hind Siliguri for Bangla), line-height 1.5-1.7
- Subtle depth: soft shadows (shadow-sm/md), rounded-xl corners, glassmorphism
  hero te jome — kintu sob jaygay na
- Micro-interactions: hover scale/lift, button press feedback, 150-250ms
  ease transitions. Reduced-motion respect (`prefers-reduced-motion`)

## Mobile-first (user der 90% phone e)
- Mobile layout AGE likho, tarpor `sm: md: lg: xl:` add koro
- Breakpoints: 640 / 768 / 1024 / 1280
- Touch target min 44px — button, link, input sob
- Font: body 16px+, choto kora jabe na
- Horizontal scroll = bug. Fix koro.
- Sticky bottom CTA phone e (conversion scene e)
- Safe-area insets notch phone e (`env(safe-area-inset-*)`)

## Accessibility (bypass na)
- Contrast: text 4.5:1, boro text 3:1
- `alt` sob image e, ARIA label icon-only button e
- Focus visible — outline none kore flee na
- Heading order: h1 → h2 → h3, skip na

## Tailwind patterns
- Layout: `max-w-6xl mx-auto px-4`, sections `py-16 md:py-24`
- Cards: `rounded-2xl shadow-md hover:shadow-xl transition`
- Buttons: `px-6 py-3 rounded-xl font-semibold active:scale-95 transition`
- Dark mode: `dark:` classes — toggle localStorage e rakhho
- Gradient hero: `bg-gradient-to-br from-X to-Y` — text-white, overlay use koro

## UX flow (beginner user er jonno)
- Empty state: data na thakle helpful message + action button
- Loading state: spinner/skeleton — blank screen na
- Form: inline validation, clear error message Banglish e jodi user BD hole
- Destructive action: confirm nao (delete, reset)
- Success feedback: toast / inline check — user bujhe kaj hoyeche

## Checklist (deliver er age)
- [ ] Phone e professional dekhay (384px width test)
- [ ] Dark mode (jei site e jome)
- [ ] Touch sob 44px+
- [ ] Contrast pass
- [ ] Hover/focus/active states ache
- [ ] Kono horizontal scroll nai
