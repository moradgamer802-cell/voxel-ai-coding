---
name: project-structure
description: Clean, scalable project folder structure — notun project shuru korar age. Use when starting any new project or organizing existing one.
---

# Project Structure Skill (Full-Power)

## Decision tree (age ei thako — user ke cross-question na)
- 1-3 page simple site → **Flat HTML** (chotobelo!)
- Multi-page site, kono build tool na → **HTML + css/ + js/**
- Interactive app → **React + Vite**
- SEO-critical + full app → **Next.js**

## Simple Website (HTML + CSS + JS)
```
project/
├── index.html
├── about.html / contact.html ...
├── css/style.css        # EKTA file — 3 ta css na
├── js/main.js           # EKTA file
├── assets/images/
└── README.md            # kivabe chalabe (ek line)
```

## React + Vite
```
project/
├── public/              # static (favicon, images)
├── src/
│   ├── components/      # choto reusable (Navbar, Card)
│   ├── pages/           # route-level
│   ├── hooks/           # custom logic
│   ├── lib/             # api calls, utils
│   ├── App.jsx
│   └── main.jsx
├── index.html
├── package.json
└── .gitignore           # node_modules, .env, dist
```

## Next.js (App Router)
```
project/
├── app/
│   ├── layout.tsx       # root layout + fonts + metadata
│   ├── page.tsx
│   ├── globals.css
│   └── (dashboard)/     # route groups
├── components/
├── lib/                 # db, api, auth
├── public/
├── types/
├── .env.local           # secrets (gitignored!)
├── .env.example         # template — commit koro
└── package.json
```

## Python project
```
project/
├── main.py
├── requirements.txt     # pip freeze > requirements.txt
├── .env                 # secrets (gitignored)
├── utils/
└── README.md
```

## Rules
- Structure AGE banao — file banate giye folder bhabna na
- `.` er modde file pile up na — related guloke folder e
- Naam: lowercase-kebab (`user-profile/`) ba component PascalCase — ekta style
- Har project e README (ek line: kivabe chalabe) + `.gitignore`
- Data/output file source theke alada: `data/`, `output/` (gitignore output)
- Deep nesting (4+ level) = structure signal bhenge — flatten koro
