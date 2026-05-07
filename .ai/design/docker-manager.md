# Docker Management

> Status: active | Max lines: 150

## Overview

Docker management via the global SSH connection pool. Orbita does not install a
server agent; all data and actions are performed by `docker` / `docker compose`
CLI commands on the remote server. List APIs use `--format '{{json .}}'` and
`docker inspect` output, then parse into app models.

The bottom Docker tab uses browser-like server tabs. The default new tab shows
the shared server picker; selecting a server renames the active tab and embeds
`DockerManagerPage` without its own AppBar. The tab strip hides on upward
scroll, and closing the last server tab replaces it with a new tab.

## Prerequisites Detection

On first connect, detect Docker availability:
```bash
command -v docker && docker info --format '{{json .}}' 2>/dev/null
```
If unavailable, show Docker not installed. Permission errors are shown as a
dedicated state. Compose defaults to `docker compose` and falls back to
`docker-compose` when v2 is unavailable.

The one-click Docker install action is only shown in the missing-Docker state;
the manager AppBar keeps refresh as the only global action.

Overview metadata combines `docker info --format '{{json .}}'`, `docker version`,
and a flat `docker info --format` fallback so Docker CLI output differences do
not leave version, storage driver, root directory, architecture, CPU, or memory
blank.

## Container Operations

| Operation | Command |
|-----------|---------|
| List all | `docker ps -a --format '{{json .}}'` |
| Start | `docker start <id>` |
| Stop | `docker stop <id>` |
| Restart | `docker restart <id>` |
| Remove | `docker rm <id>` (confirm if running: `docker rm -f`) |
| Logs | `docker logs --tail 200 -f <id>` |
| Stats | `docker stats --no-stream --format '{{json .}}'` |
| Inspect | `docker inspect <id>` |
| Exec | Open terminal with `docker exec -it <id> <bash|sh|ash>` |
| Top | `docker top <id>` |

Start/stop actions are mutually exclusive: running containers show stop/restart,
while stopped or exited containers show start/delete.

## Image Operations

| Operation | Command |
|-----------|---------|
| List | `docker images --format '{{json .}}'` |
| Remove | `docker rmi <repo:tag>` |
| Pull/update | `docker pull <repo:tag>` |
| Prune unused | `docker image prune -f` |

If an image has linked running containers, updating prompts first and only pulls
the new image. Orbita does not rebuild or replace running containers
automatically.

## Docker Compose

| Operation | Command |
|-----------|---------|
| Detect projects | Compose labels + common compose file scan |
| Status | `docker compose -f <file> ps --format '{{json .}}'` |
| Up | `docker compose -f <file> up -d` |
| Stop | `docker compose -f <file> stop` |
| Restart | `docker compose -f <file> restart` |
| Down | `docker compose -f <file> down` |
| Delete | Remove compose file after confirmation |
| Create | Write `compose.yaml` to a remote directory, optionally `up -d` |

YAML editing reuses the file text editor. Deleting a compose project removes the
compose file only after confirmation; volume cleanup remains explicit in the
Volumes section.

## Volumes

| Operation | Command |
|-----------|---------|
| List | `docker volume ls --format '{{json .}}'` |
| Inspect | `docker volume inspect $(docker volume ls -q)` |
| Remove | `docker volume rm <name>` |

Volumes show linked containers from inspect mount metadata. Deletion is blocked
when a linked running container is found.

## UI Components

### Manager Sections
- Overview: Docker/Compose version, counts, root dir, storage driver, CPU/memory
- Containers: lifecycle actions, inspect, streaming logs, exec shell
- Compose: create, start, stop, restart, down, delete, YAML edit, linked containers
- Images: pull/update, delete, linked containers
- Volumes: inspect, guarded delete, linked containers

The section switcher is horizontally scrollable and compact on mobile/tablet.

## Real-time Logs

Stream `docker logs -f` output to a terminal-like view with:
- Stop stream
- Refresh stream
- Copy output

## Changelog
- 2026-05-05: Add scroll-hiding Docker tabs with close-last recovery
- 2026-05-05: Add Docker overview metadata fallbacks for version and info fields
- 2026-05-05: Limit Docker install entrypoint to the missing-Docker state
- 2026-05-04: Implement SSH-based Docker manager, Compose, image, volume, logs, and exec flows
- 2026-04-15: Initial creation
