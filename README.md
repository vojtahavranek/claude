# Claude Config

Shared [Claude Code](https://claude.ai/claude-code) configuration — roles, skills, and global instructions.

## What's included

| Path | Description |
|------|-------------|
| `CLAUDE.md` | Global instructions (role system, skills, workflows) |
| `roles/` | Role definitions (architect, developer, PM, PO, reviewer) |
| `skills/` | Skill workflows (discovery, planning, implementation) |
| `statusline.sh` | Custom status line script |

## Setup

### 1. Clone the repo

```bash
git clone <your-repo-url> ~/claude-config
```

Clone it anywhere you like — the sync script copies files to `~/.claude/`.

### 2. Configure environment

```bash
cp .env.example .env
```

Edit `.env` to match your device. The `.env` file is gitignored so it stays local.

### 3. Run sync

```bash
./sync.sh
```

This will:
1. Back up any existing files in `~/.claude/` that would be overwritten
2. Copy all shared config files to `~/.claude/`
3. Replace `{{PROJECTS_DIR}}` with the actual path

### 4. After pulling updates

```bash
git pull
./sync.sh
```

That's it. Backups are timestamped so you never lose local changes.

## Placeholders

| Placeholder | Default | Description |
|-------------|---------|-------------|
| `{{PROJECTS_DIR}}` | `$HOME/projects` | Root directory where your project repos live |

To add more placeholders, add them to `.env.example` (with defaults) and to the `PLACEHOLDERS` array in `sync.sh`.

## What's NOT included

These stay local per device (managed by Claude Code itself):

- `settings.json` — permissions, device-specific paths
- `projects/` — auto-memory tied to local project paths
- `history.jsonl` — conversation history
- `tasks/`, `todos/` — session task data
- `cache/`, `debug/`, `backups/` — runtime data
- `.credentials.json` — auth tokens
