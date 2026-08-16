---
name: git-workflow
description: Clean, safe git — repo banao, commit, branch, push, conflict resolve, GitHub e upload. Use for any git/GitHub task.
---

# Git Workflow Skill (Full-Power)

## Termux setup (first time)
```sh
git config --global user.name "Name"
git config --global user.email "email@example.com"
```
- Push er jonno GitHub PAT lagbe (fine-grained, sirf repo access) — user ke
  setup e help koro; key kokhono file e save kore rakhna/log korona

## Safety rules
- User na chaile commit/push na
- Commit er age: `git status` + `git diff` dekho — sirf intended file stage
- Secrets check: `.env`, `*.key`, token — diff e thakle rokhe jao
  - `.gitignore` e `.env` boshao age thekei
- `git push --force` kokhono na (user explicitly chaile warning soho)
- History rewrite na (rebase -i, amend pushed commit) — fix-forward koro

## Daily flows
```sh
# notun kaj
git checkout -b feature/login
# ... kaj ...
git add <files> && git commit -m "login page add"

# update niye ese
git pull --ff-only

# bhul commit undo (soft — change thake)
git reset --soft HEAD~1

# local mess thekao
git stash        # ...porer kaj... 
git stash pop

# kono file er change feliye dao (commit korar age)
git checkout -- <file>
```

## Commit message style
- Choto + present tense: `add login page`, `fix navbar overflow on mobile`
- Keno change holo (big hole body te 2-3 line)

## Conflict resolve
1. `git status` — kon file conflict
2. File poro — `<<<<<<<` marker duita side e
3. Due side er INTENTION bujhe merge koro — ek side blind choose na
4. Marker delete, `git add`, commit

## GitHub e notun project upload (common BD user request)
```sh
git init && git add . && git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/<user>/<repo>.git
git push -u origin main
```
- Boro file (50MB+) GitHub e jay na — Git LFS ba media cloud link
- Repo public/private user ke confirm kore nio
