---
name: api-integration
description: Work with APIs — fetch data, connect third-party services, live data for weather/payment/news sites. Use when user wants live data, API calls, or information from the internet.
---

# API Integration Skill

## Rules (strict)
- **Never hardcode API keys in code** — keep them in a `.env` file,
  provide an `.env.example` template, and gitignore `.env`
- A sensitive key in frontend code is PUBLIC — everyone can see it.
  For paid/secret keys, say it: a backend/serverless layer is needed
- Check free APIs first (websearch) — current status, rate limits

## Fetch pattern (vanilla JS — modern)
```js
async function loadData() {
  try {
    const res = await fetch('https://api.example.com/data');
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const data = await res.json();
    render(data);
  } catch (err) {
    showMsg('There was a problem loading the data — check your internet'); // user-facing
    console.error(err); // for debugging
  }
}
```
- Loading state is MANDATORY (spinner/skeleton) — a blank screen stops beginner users
- Human error messages — not "404" for a beginner, but "Data could not be loaded"

## CORS (common blocker)
- Direct browser call fails + CORS error in console → the API does not allow
  the browser. Solutions: (1) the API's official CORS-enabled endpoint,
  (2) your own server proxy, (3) a different API
- Public sites with API keys: use AllOrigins/corsproxy-type public proxies
  (free, but NEVER with sensitive keys)

## Useful free APIs
- Weather: Open-Meteo (no key needed, uses lat/lon)
- Prayer times: Aladhan API (by city)
- Currency rates: exchangerate / frankfurter
- News/search: whatever service the user has — read its docs first

## Workflow
1. Read the API docs (webfetch) — endpoint, params, auth, rate limit
2. Small test: one call, look at the response structure
3. Bind data in the UI + loading + error + empty states
4. Respect rate limits — cache every call (localStorage with expiry)
