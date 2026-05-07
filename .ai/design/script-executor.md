# Script Execution

> Status: active | Max lines: 120

## Overview

Execute predefined shell scripts on remote servers via SSH. Scripts are sent as
inline commands and streamed through a shared output dialog; no server agent or
file upload is required.

## Script Types

### Predefined Scripts (Built-in)
- Install archive tools: `zip`, `unzip`, `7z`
- Change package mirror: select a common mirror and rewrite supported Linux
  package manager repositories with version-aware logic
- Install Docker: package-manager install plus best-effort service enable/start
- Install tmux: package-manager install for terminal session reuse

### Custom Scripts
- User-created scripts stored in shared preferences until encrypted DB lands
- Support for Orbita script syntax (select prompts plus variable substitution)
- Script tagging and categorization
- Import/export scripts as JSON

## Execution Flow

1. User opens a script detail page
2. App asks for one target server when Run is tapped
3. App resolves Orbita script syntax prompts, such as mirror selection
4. App resolves SSH key/password through existing server settings
5. `RemoteScriptService` opens a pooled SSH exec channel
6. Output streams into `RemoteScriptOutputDialog`
7. Dialog shows final success or failure state

The same output dialog is reused by file archive tool installation, terminal
tmux installation, Docker installation, and the Settings script list.

## Script Editor

- System scripts are read-only; user scripts can be created and edited
- Select placeholders: `{{VAR_NAME}}` inserts the selected value with shell quoting
- Select syntax:
  `# orbita:select name=MIRROR title="Select Mirror"`
  `# orbita:option name=MIRROR label="TUNA" value="https://..."`
- Test run button (dry-run with `echo` prefix)
- Max script size: 64KB

## UI Components

### Script List
- Settings > Scripts separates system scripts and user scripts
- Tapping a script opens the script detail/editor page
- Run keeps the existing server selection and live output flow
- System scripts can be viewed and run, but not edited
- User scripts can be added, edited, deleted, viewed, and run

### Mirror Switching
- Mirror presets: TUNA, USTC, Aliyun, Tencent Cloud, Huawei Cloud
- Supported families: Ubuntu, Debian, CentOS, Rocky, AlmaLinux, Fedora,
  openEuler, Alpine, Arch, openSUSE/SLES
- Version-aware behavior covers Debian security/component differences,
  CentOS 7 vs CentOS 8 vault vs CentOS Stream, and openSUSE Leap vs Tumbleweed
- Existing repository files are backed up with an `orbita` timestamp suffix or
  moved into an `orbita-backup-*` directory before rewrite

### Context Install Entrypoints
- File manager installs missing archive tools before preview/compress/extract
- Terminal tmux mode prompts installation when tmux is missing
- Docker manager exposes an install button beside refresh
- Docker unavailable state also offers the install button

## Batch Execution

- Select multiple servers → run same script on all
- Show per-server status: running / success / failed
- Aggregate output view with server labels

## Execution History

- Store last 50 executions per server
- Fields: timestamp, script name, exit code, output (truncated to 4KB)
- Tap to view full output

## Changelog
- 2026-05-04: Split system/user scripts and add editable user scripts with Orbita select syntax
- 2026-05-04: Add one-click Linux package mirror switching with preset selection
- 2026-05-04: Add built-in archive, Docker, and tmux install scripts with shared live output
- 2026-04-15: Initial creation
