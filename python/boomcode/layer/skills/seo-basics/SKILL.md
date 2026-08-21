---
name: seo-basics
description: Rank higher on Google — meta tags, SEO setup, site speed, sitemap. Use when user asks "will it show on Google", "do SEO", "boost ranking", or wants search visibility for any website.
---

# SEO Basics Skill

## On every page (check before delivering)
```html
<title>Page purpose — Brand name | 50-60 character</title>
<meta name="description" content="Page summary in 150-160 characters">
<link rel="canonical" href="https://site.com/page">
<!-- Open Graph (Facebook/WhatsApp share card) -->
<meta property="og:title" content="...">
<meta property="og:description" content="...">
<meta property="og:image" content="cover.jpg">
<meta name="viewport" content="width=device-width, initial-scale=1">
```

## Content SEO (most important — ~80% of Google's weight here)
- Real, useful content — answers the user's question
- Heading hierarchy: one h1 (the page's main topic), then h2/h3 sections
- Natural keywords — no keyword stuffing
- Descriptive image alt text
- Fresh content regularly

## Technical SEO
- `robots.txt` at the root (let search bots in)
- `sitemap.xml` at the root — list all pages, submit in Google Search Console
- Mobile-friendly (Google indexes mobile-first — bad on phone = lost rank)
- Speed: compressed images (<200KB each, lazy load), minimal blocking JS
- HTTPS (free hosts do this automatically)

## For local businesses
- Set up a Google Business Profile — shows on Maps, gets reviews
- On the page: business name + address + phone (NAP) consistent
- Local keywords: city, area name, service + location

## Verify checklist
- [ ] Unique title + description on every page
- [ ] og:image present (WhatsApp share preview)
- [ ] sitemap.xml + robots.txt present
- [ ] Mobile test passes
- [ ] Gave instructions for Search Console setup (free, needs a Google account)