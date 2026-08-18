---
name: database
description: Work with databases — SQLite, MySQL, PostgreSQL — design, query, connect from apps, CRUD. Use when user wants to store data, build a database, or connect an app to a database.
---

# Database Skill

## Choose the right one (based on the user's scenario)
- **SQLite** — best for Termux/phone apps and small projects (single file, zero setup)
- **MySQL** — classic web backend (shared hosting, PHP, Laravel)
- **PostgreSQL** — modern, powerful, best for real production apps
- No database server needed for simple scripts? Use JSON files or SQLite — keep it light

## SQLite (Termux-friendly — recommended for phone projects)
```sh
pkg install sqlite
sqlite3 app.db          # open the database interactively
```
```sql
-- create + insert + query
CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, email TEXT UNIQUE);
INSERT INTO users (name, email) VALUES ('Rahim', 'rahim@example.com');
SELECT * FROM users WHERE name LIKE 'Ra%';
```

## Connecting from Python (stdlib — no pip needed for SQLite)
```python
import sqlite3
conn = sqlite3.connect("app.db")          # file is created if missing
conn.execute("CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, name TEXT)")
conn.execute("INSERT INTO users (name) VALUES (?)", ("Karim",))   # NEVER f-strings
conn.commit()
for row in conn.execute("SELECT * FROM users"):
    print(row)
```

## Rules (strict)
- **Parameterized queries ALWAYS** — `?` placeholders (SQLite) or `%s` (MySQL/PG).
  Never build SQL by string concatenation — that is SQL injection
- **Backup before destructive changes**: `sqlite3 app.db ".backup app.db.bak"` or `mysqldump`
- **Indexes** on columns used in WHERE/JOIN once data grows
- **Transactions** for multi-step writes: `BEGIN` ... `COMMIT` / `ROLLBACK`
- Keep the DB file OUT of git — `.gitignore` it; seed data via a `schema.sql` + `seed.py`
- MySQL/PG passwords: `.env` file, never hardcoded

## Schema design (quick path)
1. Start with a simple table + the ONE main query you need
2. Normalize only when you see real duplication (don't over-engineer)
3. Add `created_at` timestamps — always useful later
4. Foreign keys ON — prevents orphan rows

## Common Termux scene
- User wants a data-collection app (inventory, attendance, notes) → SQLite + Python
- Web app needs storage → MySQL (shared hosting) or SQLite (small/single-user)
- User has an "app.db" that won't open → check it is a real SQLite file:
  `file app.db` and `sqlite3 app.db ".tables"`