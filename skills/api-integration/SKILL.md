---
name: api-integration
description: API diye kaj — fetch data, third-party service jora, weather/payment/news site e data. Use when user wants live data, API call, or "internet theke information ano".
---

# API Integration Skill

## Rules (strict)
- **API key kokhono code e hardcode na** — `.env` file e rakhho,
  `.env.example` template dao, `.env` gitignore e
- Frontend e sensitive key rakhle seta PUBLIC — sobai dekhte pare.
  Paid/secret key lagbe hole bolo: backend/serverless lagbe
- Free API age check koro (websearch) — current status, rate limit

## Fetch pattern (vanilla JS — modern)
```js
async function loadData() {
  try {
    const res = await fetch('https://api.example.com/data');
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const data = await res.json();
    render(data);
  } catch (err) {
    showMsg('Data ashte problem hocche — internet check koro'); // user-facing
    console.error(err); // debug er jonno
  }
}
```
- Loading state MUST (spinner/skeleton) — blank screen beginner user ke daray
- Error hole human message — beginner user ke "404" na, "Data pawa jayni"

## CORS (common blocker)
- Browser e direct call fail + console e CORS error → API ta browser allow
  kore na. Solutions: (1) API er official CORS-enabled endpoint, (2) nijer
  server proxy, (3) onno API
- API key wala public site e: AllOrigins/corsproxy type public proxy use koro
  (free, kintu sensitive key er sathe NA)

## Useful free API scene (BD context)
- Weather: Open-Meteo (key lagbe na, lat/lon diye)
- Prayer time: Aladhan API (city diye)
- Currency rate: exchangerate/frankfurter
- News/search: user er jei service, docs poro age

## Workflow
1. API docs poro (webfetch) — endpoint, params, auth, rate limit
2. Choto test: ek call, response structure dekho
3. UI te data bind + loading + error + empty state
4. Rate limit respect koro — har call e cache (localStorage expire time soho)
