---
name: deploy-hosting
description: Put a website live — free hosting (GitHub Pages, Netlify, Vercel), domains, deploys. Use when user says "make it live", "deploy", "go online", "upload the website", or wants a public link.
---

# Deploy & Hosting Skill

## Choose a path (based on the user's scenario)

### 1. Netlify Drop (EASIEST — for static sites, no account needed)
- Drag-and-drop the site folder at https://app.netlify.com/drop
- Instant live link (.netlify.app)
- Works on a phone too — straight from the browser
- Tell the user: zip the folder and drop it, or select the files

### 2. GitHub Pages (free, permanent, if you know git)
- Create a repo → push the site files → Settings → Pages → select branch
- Link: `username.github.io/repo-name`
- On Termux: `git init`, push — see the git-workflow skill in zyvo
- If 404: use relative paths (`./style.css`, `/repo-name/` base tag)

### 3. Vercel (best for React/Next.js apps)
- `npm i -g vercel` → run `vercel` → link account → deploy
- Preview + production automatic — every push updates it

### 4. Direct from Termux (local test)
- `python3 -m http.server 8080` → open `localhost:8080` in the phone's browser

## Rules
- Verify BEFORE deploying: index.html at the root, relative paths, all assets local
- Never push the user's personal keys/tokens to a repo or public site
- On a free subdomain, say: a custom domain costs money but is not required
- Custom domain wanted: .com ~1,000-1,500৳/year (Namecheap/Cloudflare), help with DNS setup

## Deliver format
- Give the live link
- Say it can be shared — it works for everyone
- One line on how to update (drop again / git push / vercel)