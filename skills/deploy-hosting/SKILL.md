---
name: deploy-hosting
description: Website live kora — free hosting (GitHub Pages, Netlify, Vercel), domain, deploy er jonno. Use when user says "live koro", "deploy koro", "online e chao", "website upload", or wants a public link.
---

# Deploy & Hosting Skill

## Path choose koro (user er scenario onujayi)

### 1. Netlify Drop (SOHOJ — static site er jonno, account o lagbe na)
- https://app.netlify.com/drop e site folder drag-drop
- Instant live link (.netlify.app)
- Phone e o cholbe — browser e
- User ke bolo: folder ta zip kore drop koro, ba files select koro

### 2. GitHub Pages (free, permanent, git jante parle)
- Repo banao → site files push → Settings → Pages → branch select
- Link: `username.github.io/repo-name`
- Termux e: `git init`, push — zyvo te git-workflow skill dekho
- 404 asle: relative path use koro (`./style.css`, `/repo-name/` base tag)

### 3. Vercel (React/Next.js app er jonno best)
- `npm i -g vercel` → `vercel` command → account link → deploy
- Preview + production auto — push korlei update

### 4. Termux theke direct (local test)
- `python3 -m http.server 8080` → phone er browser e `localhost:8080`

## Rules
- Deploy er AGE verify: index.html root e ache, path relative, sob asset local
- User er personal key/token kokhono repo/public site e push na
- Free subdomain e thakle bolo: custom domain pocket kintu lagbe na
- Custom domain chaile: .com domain ~1,000-1,500৳/year (Namecheap/Cloudflare),
  DNS setup e help koro

## Deliver format (Banglish)
- Live link dao
- "Link diye share korte paro — sobar e cholbe"
- Update korar niyom ek line e (abar drop / git push / vercel)
