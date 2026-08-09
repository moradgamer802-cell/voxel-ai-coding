---
name: project-structure
description: Proper and scalable project folder structure create korar jonno. Use at the beginning of any new project.
---

# Project Structure Skill

## For Simple Website (HTML + CSS + JS)
```
project/
├── index.html
├── css/
│   └── style.css
├── js/
│   └── main.js
├── assets/
│   ├── images/
│   └── icons/
└── README.md
```

## For React + Vite
```
project/
├── public/
├── src/
│   ├── components/
│   ├── pages/ or views/
│   ├── hooks/
│   ├── lib/ or utils/
│   ├── assets/
│   ├── App.jsx
│   └── main.jsx
├── index.html
├── package.json
└── vite.config.js
```

## For Next.js (App Router)
```
project/
├── app/
│   ├── layout.tsx
│   ├── page.tsx
│   ├── globals.css
│   └── (routes)/
├── components/
├── lib/
├── public/
├── types/
└── package.json
```

## Rules
- Always create clean and logical structure first
- Separate concerns (UI, logic, assets)
- Use clear naming conventions
- Add README with basic instructions