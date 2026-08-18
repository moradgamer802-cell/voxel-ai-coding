---
name: git-workflow
description: Clean, safe git — create repos, commit, branch, push, resolve conflicts, upload to GitHub. Use for any git/GitHub task.
---

# Git Workflow Skill (Full-Power)

## Termux setup (first time)
```sh
git config --global user.name "Name"
git config --global user.email "email@example.com"
```
- Pushing needs a GitHub PAT (fine-grained, repo access only) — help the user
  set it up; never save or log the key in any file

## Safety rules
- No commit/push unless the user asked for it
- Before committing: check `git status` + `git diff` — stage only intended files
- Secret check: `.env`, `*.key`, tokens — if they appear in the diff, stop
  - Put `.env` in `.gitignore` from the start
- Never `git push --force` (only if the user explicitly asks, with a warning)
- Never rewrite history (rebase -i, amending pushed commits) — fix forward

## Daily flows
```sh
# new work
git checkout -b feature/login
# ... work ...
git add <files> && git commit -m "login page add"

# pull updates
git pull --ff-only

# undo last commit (soft — changes stay)
git reset --soft HEAD~1

# save local mess for later
git stash        # ...do other work...
git stash pop

# discard a file's changes (before committing)
git checkout -- <file>
```

## Commit message style
- Short + present tense: `add login page`, `fix navbar overflow on mobile`
- Why the change happened (2-3 lines in the body for big changes)

## Conflict resolve
1. `git status` — which files conflict
2. Read the file — the `<<<<<<<` markers show both sides
3. Merge based on BOTH sides' intention — never blindly pick one side
4. Delete the markers, `git add`, commit

## Uploading a new project to GitHub
```sh
git init && git add . && git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/<user>/<repo>.git
git push -u origin main
```
- Files over 50MB won't go to GitHub — use Git LFS or a media cloud link
- Confirm with the user whether the repo should be public or private