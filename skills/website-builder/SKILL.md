---
name: website-builder
description: Modern, professional, responsive website / landing page / portfolio / multi-page site. Use when user asks to create, redesign, or improve any website or frontend project. ALWAYS finish with a preview/deploy instruction.
---

# Website Builder Skill (Full-Power)

## Quality bar — must pass before saying "done"
- Looks professional on mobile (90% of users are on phones)
- Loads fast even on slow (3G) networks — lazy images, light HTML
- Zero broken links, zero missing images, zero placeholder content
- Content is REAL — written for the user's business/project context

## Preferred Stack
- Default: HTML + Tailwind CSS (CDN is fine for small sites) + Vanilla JS
- Multi-page: shared header/footer pattern, one shared css/js
- Framework if wanted: React + Vite + Tailwind
- Full app: Next.js + Tailwind + TypeScript

## Process (step by step — no skipping)
1. Fully understand the requirement — pages, sections, style, content
2. Plan: keep a file list + section list in mind first
3. Structure: semantic HTML5 (header/nav/main/section/footer, h1→h2 hierarchy)
4. Content first: put the real text in — before styling
5. Style: Tailwind — spacing rhythm, 1-2 brand colors + neutrals, dark mode where it fits
6. Interactivity: small vanilla JS — mobile menu, smooth scroll, form validation
7. Responsive: write mobile-first, then `sm:/md:/lg:` (see ui-ux-responsive skill)
8. Media: `loading="lazy"`, set width/height, webp if the source exists
9. SEO basics: title, meta description, OG tags (see seo-basics skill)
10. Verify: all files exist, paths correct, title/meta set — check yourself
11. Deliver: summary + how to view it (open index.html in a file manager)
    or a live link (deploy-hosting skill)

## Common site patterns
- **Business site**: hero + services + gallery + reviews + contact
  (WhatsApp button A MUST: `https://wa.me/<number>`) + Google Maps embed + hours
- **Portfolio**: hero + skills + projects + CV download + contact
- **Landing page**: one goal, one CTA repeated, social proof, deadline/offer
- Bangla font: Hind Siliguri / Noto Sans Bengali (Google Fonts)

## Anti-patterns (never)
- Delivering Lorem ipsum / "coming soon" sections
- Everything crammed into one file (except small single-pagers)
- `alert()` everywhere — use inline messages / toasts
- Hardcoded `http://` assets
- Fixed px fonts — use rem
- 10 fonts 10 colors — restraint is beauty