---
name: project-structure
description: Clean, scalable project folder structure — before starting a new project. Use when starting any new project or organizing an existing one.
---

# Project Structure Skill (Full-Power)

## Decision tree (decide this first — don't cross-question the user)
- 1-3 page simple site → **Flat HTML** (fastest!)
- Multi-page site, no build tool → **HTML + css/ + js/**
- Interactive app → **React + Vite**
- SEO-critical + full app → **Next.js**

## Simple Website (HTML + CSS + JS)
```
project/
├── index.html
├── about.html / contact.html ...
├── css/style.css        # ONE file — not 3 css files
├── js/main.js           # ONE file
├── assets/images/
└── README.md            # how to run it (one line)
```

## React + Vite
```
project/
├── public/              # static (favicon, images)
├── src/
│   ├── components/      # small reusable (Navbar, Card)
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
├── .env.example         # template — commit this
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
- Set up the structure FIRST — don't invent folders while creating files
- Don't pile files in `.` — group related files into folders
- Names: lowercase-kebab (`user-profile/`) or PascalCase components — pick one style
- Every project needs a README (one line: how to run) + `.gitignore`
- Keep data/output separate from source: `data/`, `output/` (gitignore output)
- Deep nesting (4+ levels) breaks structure signals — flatten it