---
name: docker
description: Docker for desktop users — containers, images, docker-compose — run and isolate apps. Use when user has a PC/server with Docker and wants to package, run, or keep apps isolated.
---

# Docker Skill (Desktop Users)

## When Docker makes sense
- The user has a PC or VPS (Termux itself can't run Docker natively — no proot needed, it just won't work)
- Multiple apps on one server that must not conflict (different Python/Node versions)
- Reproducible deploys — "works on my machine" disappears
- For a simple single app on a phone — Docker is overkill; skip it

## Basic workflow
```dockerfile
# Dockerfile — small, safe
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["python", "main.py"]
```
```sh
docker build -t myapp .      # build the image
docker run -p 8080:8080 myapp   # run it (host port 8080 → container 8080)
docker ps                    # list running containers
docker stop <id>             # stop one
```

## docker-compose (multiple services — the usual real case)
```yaml
# docker-compose.yml
services:
  web:
    build: .
    ports: ["8080:8080"]
    environment:
      DB_URL: postgres://user:pass@db:5432/app
    depends_on: [db]
  db:
    image: postgres:16
    environment:
      POSTGRES_PASSWORD: change_me
    volumes:
      - pgdata:/var/lib/postgresql/data
volumes:
  pgdata:
```
```sh
docker compose up -d     # start everything in the background
docker compose logs -f   # follow logs
docker compose down      # stop (add -v to delete data volumes — careful!)
```

## Rules (strict)
- **Never put secrets in the Dockerfile** (they end up in image history).
  Use `.env` + `environment:` / compose `env_file:`
- **Don't run as root in the container** — add a non-root user:
  `RUN useradd -m app && USER app`
- Pin versions (`python:3.12-slim`, `postgres:16`) — `latest` breaks builds later
- `.dockerignore` — keep node_modules, .git, .env out of the build context (faster + safer)
- One process per container; data in **volumes**, never inside the container (lost on recreate)
- `docker exec -it <id> sh` to debug inside

## Common fixes
- "port already in use" → `docker ps` shows another container → stop it or change `-p` port
- Container exits instantly → `docker logs <id>` — the app crashed at startup
- Can't reach the app → check `-p HOST:CONTAINER` mapping and the app binds 0.0.0.0 inside
- Build too slow → run again; layers are cached. Put `requirements.txt` BEFORE the code copy

## Deliver
- Dockerfile + compose file + the exact commands to build/run/stop
- One line on how to update: rebuild + `docker compose up -d` again