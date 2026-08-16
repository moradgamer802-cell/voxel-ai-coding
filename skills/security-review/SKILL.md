---
name: security-review
description: Dangerous command/data er age double-check — auto-approve ON thakleo AI nije guard hoy. Use before destructive, network, or sensitive operations.
---

# Security Review Skill (Full-Power)

## Context: ZYVO te permission NAI
`permission: allow` mane AI j kichu chalate pare — tai **AI nije guard**.
Ei skill ta sei guard. Every risky operation er age ei checklist mental run koro.

## Gate 1 — Destructive commands
- `rm -rf` / `rm -r`: exact path bair koro echo diye, variable empty na,
  `/` `$HOME` `$PREFIX` kokhono target na
- `mv A B` jokhon B ache = overwrite — age check
- `dd`, `mkfs`, disk wipe: user er explicit instruction chara na
- `truncate`/`>` boro file e: age backup (`cp x x.bak`)
- Bulk delete: age dry-run list dekhao (`find ... -print`), tarpor delete

## Gate 2 — Network
- `curl ... | sh/bash`: script ta AGE poro (download kore `less`/`head`),
  tarpor chalao — blind pipe na
- User er file upload/bhejte dewa: explicit permission chara na
- `git push` public repo e: secrets diff check age (Gate 3)
- Onno server e data POST: user jane + HTTPS

## Gate 3 — Secrets
- API key/token/password: code e hardcode NA — `.env` + `.env.example` pattern
- Echo/log/commit e secret print na; accidental thakle turant delete + rotate
- `.gitignore` e `.env` ache kina notun repo te check
- User er diye dewa key repo push hoy — fjell porle abar new key nao (rotate)

## Gate 4 — System
- `chmod 777` na (755 file, 700 dir)
- `sudo`/root: Termux e nai; proot e avoid — user-level solve try koro
- System config edit (`/etc/`, `$PREFIX/etc/`): age backup, age bolo

## Workflow risky kaj peye gele
1. Banglish e 2-3 line e bolo: ki korbe, ki risk, reversible kina
2. Irreversible + user absent? Koro NA — note rekhe dao
3. Safe alternative khujо: dry-run flag, temp copy, `-i` interactive
4. Auto-approve thakleo: destructive + irreversible hole user ke PROSHON koro

## Website/app deliver korar somoy check
- Form input sanitize (XSS) — user content HTML e directly inject na
- API key frontend e expose na (public hole bolo)
- SQL: parameterized query — string concat na
- `target="_blank"` e `rel="noopener"` 
