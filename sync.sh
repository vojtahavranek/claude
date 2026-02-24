#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Claude Config Sync Script
# Copies shared config files to ~/.claude/ with placeholder replacement.
# Run this after cloning or pulling new changes.
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
BACKUP_DIR="$CLAUDE_DIR/backups/config-sync-$(date +%Y%m%d-%H%M%S)"

# --- Load .env ---------------------------------------------------------------
ENV_FILE="$SCRIPT_DIR/.env"
if [[ -f "$ENV_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$ENV_FILE"
    echo "Loaded config from .env"
else
    echo "No .env found — using defaults. Copy .env.example to .env to customize."
fi

# --- Configuration -----------------------------------------------------------
PROJECTS_DIR="${PROJECTS_DIR:-$HOME/projects}"

# Map of placeholders -> values
declare -A PLACEHOLDERS=(
    ["{{PROJECTS_DIR}}"]="$PROJECTS_DIR"
)

# Files and directories to sync (relative to repo root)
SYNC_ITEMS=(
    "CLAUDE.md"
    "roles"
    "skills"
    "statusline.sh"
)

# --- Functions ---------------------------------------------------------------

backup_item() {
    local target="$1"
    if [[ -e "$target" || -L "$target" ]]; then
        mkdir -p "$BACKUP_DIR"
        cp -rL "$target" "$BACKUP_DIR/$(basename "$target")"
        echo "  Backed up: $(basename "$target")"
    fi
}

replace_placeholders() {
    local file="$1"
    for placeholder in "${!PLACEHOLDERS[@]}"; do
        sed -i "s|${placeholder}|${PLACEHOLDERS[$placeholder]}|g" "$file"
    done
}

sync_item() {
    local item="$1"
    local source="$SCRIPT_DIR/$item"
    local target="$CLAUDE_DIR/$item"

    if [[ ! -e "$source" ]]; then
        echo "  SKIP: $item (not found in repo)"
        return
    fi

    # Backup existing
    backup_item "$target"

    # Remove old target (file or directory)
    rm -rf "$target"

    # Copy
    cp -r "$source" "$target"

    # Replace placeholders in all .md and .sh files
    if [[ -d "$target" ]]; then
        find "$target" -type f \( -name '*.md' -o -name '*.sh' \) | while read -r f; do
            replace_placeholders "$f"
        done
    elif [[ -f "$target" ]]; then
        replace_placeholders "$target"
    fi

    echo "  Synced: $item"
}

# --- Main --------------------------------------------------------------------

echo "Claude Config Sync"
echo "=================="
echo ""
echo "Source:       $SCRIPT_DIR"
echo "Target:       $CLAUDE_DIR"
echo "PROJECTS_DIR: $PROJECTS_DIR"
echo ""

# Ensure ~/.claude exists
mkdir -p "$CLAUDE_DIR"

echo "Syncing files..."
for item in "${SYNC_ITEMS[@]}"; do
    sync_item "$item"
done

echo ""
if [[ -d "$BACKUP_DIR" ]]; then
    echo "Backups saved to: $BACKUP_DIR"
else
    echo "No existing files to back up (fresh install)."
fi
echo ""
echo "Done! Config synced to $CLAUDE_DIR"
