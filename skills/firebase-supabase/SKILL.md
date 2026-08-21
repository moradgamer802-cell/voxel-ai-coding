---
name: firebase-supabase
description: Backend without your own server — Firebase and Supabase: auth, database, storage, hosting. Use when user wants a backend, login system, realtime data, or "server-less" storage for an app.
---

# Firebase + Supabase Skill (Backend Without a Server)

## Choose the platform
- **Supabase** — PostgreSQL, SQL, generous **free tier**, more transparent pricing.
  Best default for new projects
- **Firebase** — Google, realtime database + very easy auth, great for quick apps;
  free tier is small and billing surprises are common. Use when the user prefers Google
- Both give: database, auth, file storage, hosting — no server to manage

## Supabase quick start
```sh
npm i @supabase/supabase-js
```
```js
import { createClient } from '@supabase/supabase-js';
const supabase = createClient(import.meta.env.VITE_SUPABASE_URL,
                               import.meta.env.VITE_SUPABASE_ANON_KEY);
// fetch rows
const { data, error } = await supabase.from('todos').select('*').order('created_at');
// insert
const { error: err2 } = await supabase.from('todos').insert({ title: 'Buy milk' });
```
- Keys in `.env` (Vite: `VITE_` prefix) — the **anon key is public by design**;
  real security comes from **RLS (Row Level Security)** policies — enable them!

## Firebase quick start
```js
import { initializeApp } from 'firebase/app';
import { getFirestore, collection, addDoc, getDocs } from 'firebase/firestore';
const app = initializeApp({ /* config from Firebase console */ });
const db = getFirestore(app);
await addDoc(collection(db, 'todos'), { title: 'Buy milk', done: false });
```
- Firestore security rules: use `match /todos/{id}` + `allow read, write: if request.auth != null` — default "open" is dangerous

## Security rules (MUST — both platforms)
- **Never trust the client.** The anon key / config is public — the database rules
  are the real lock
- Default = deny; allow the minimum (`if request.auth != null`, ownership checks:
  `request.auth.uid == resource.data.user_id`)
- Test the rules from a second browser/incognito to prove they block

## Auth patterns
- Email+password easiest; Google sign-in great UX (needs OAuth client config)
- Store the user id (`auth.uid`) on every row so ownership checks work
- Never store passwords yourself — let the platform handle auth

## Hosting
- **Supabase**: static hosting via Netlify/Vercel + the Supabase backend (see deploy-hosting skill)
- **Firebase Hosting**: `npm i -g firebase-tools` → `firebase deploy` (only from PC
  realistically — Termux has issues; Netlify/Vercel work fine from the browser)

## Deliver
- The app + working demo instructions
- Explain the free-tier limits honestly (Supabase: 500 MB DB, Firestore: 1 GiB / day free)
- Remind: enable RLS / security rules — say it is not optional