#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Claude Config Validation Script
# Checks that all shared config files are correctly placed in ~/.claude/
# and that no unresolved placeholders remain.
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
ERRORS=0
WARNINGS=0

# Colors (disable if not a terminal)
if [[ -t 1 ]]; then
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    YELLOW='\033[0;33m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    GREEN='' RED='' YELLOW='' BOLD='' RESET=''
fi

pass()    { echo -e "  ${GREEN}PASS${RESET}  $1"; }
fail()    { echo -e "  ${RED}FAIL${RESET}  $1"; ((ERRORS++)); }
warn()    { echo -e "  ${YELLOW}WARN${RESET}  $1"; ((WARNINGS++)); }
header()  { echo -e "\n${BOLD}$1${RESET}"; }

# ============================================================================
header "1. Directory structure"
# ============================================================================

if [[ -d "$CLAUDE_DIR" ]]; then
    pass "~/.claude/ exists"
else
    fail "~/.claude/ does not exist — run sync.sh first"
    echo -e "\nValidation aborted. Run ./sync.sh first."
    exit 1
fi

# ============================================================================
header "2. Required files"
# ============================================================================

# Files that must exist after sync
REQUIRED_FILES=(
    "CLAUDE.md"
    "statusline.sh"
    "roles/product-owner.md"
    "roles/product-manager.md"
    "roles/software-architect.md"
    "roles/software-developer.md"
    "roles/code-reviewer.md"
    "skills/README.md"
    "skills/task-preparation/SKILL.md"
    "skills/task-implementation/SKILL.md"
    "skills/product-discovery/SKILL.md"
    "skills/complex-task-implementation/SKILL.md"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [[ -f "$CLAUDE_DIR/$file" ]]; then
        pass "$file"
    else
        fail "$file is missing"
    fi
done

# ============================================================================
header "3. Unresolved placeholders"
# ============================================================================

PLACEHOLDER_HITS=$(grep -r '{{[A-Z_]*}}' "$CLAUDE_DIR/CLAUDE.md" "$CLAUDE_DIR/roles/" "$CLAUDE_DIR/skills/" "$CLAUDE_DIR/statusline.sh" 2>/dev/null || true)

if [[ -z "$PLACEHOLDER_HITS" ]]; then
    pass "No unresolved {{...}} placeholders found"
else
    fail "Unresolved placeholders found:"
    echo "$PLACEHOLDER_HITS" | while read -r line; do
        echo "         $line"
    done
fi

# ============================================================================
header "4. Content integrity"
# ============================================================================

# Check that TASKS.md path was resolved (contains an actual path, not placeholder)
if grep -q 'TASKS\.md' "$CLAUDE_DIR/CLAUDE.md" 2>/dev/null; then
    TASKS_PATH=$(grep -oP '`[^`]*TASKS\.md`' "$CLAUDE_DIR/CLAUDE.md" | head -1 | tr -d '`')
    if [[ -n "$TASKS_PATH" && "$TASKS_PATH" != *"{{"* ]]; then
        pass "TASKS.md path resolved to: $TASKS_PATH"
        if [[ -f "$TASKS_PATH" ]]; then
            pass "TASKS.md file exists at that path"
        else
            warn "TASKS.md not found at $TASKS_PATH (will be created on first use)"
        fi
    else
        fail "TASKS.md path contains unresolved placeholder"
    fi
fi

# Check role files are non-empty
for role in "$CLAUDE_DIR"/roles/*.md; do
    name=$(basename "$role")
    if [[ -s "$role" ]]; then
        pass "roles/$name is non-empty ($(wc -l < "$role") lines)"
    else
        fail "roles/$name is empty"
    fi
done

# Check skill files are non-empty
for skill_dir in "$CLAUDE_DIR"/skills/*/; do
    name=$(basename "$skill_dir")
    skill_file="$skill_dir/SKILL.md"
    if [[ -f "$skill_file" && -s "$skill_file" ]]; then
        pass "skills/$name/SKILL.md is non-empty ($(wc -l < "$skill_file") lines)"
    else
        fail "skills/$name/SKILL.md is missing or empty"
    fi
done

# ============================================================================
header "5. Repo config"
# ============================================================================

# Check .env exists in repo
if [[ -f "$SCRIPT_DIR/.env" ]]; then
    pass ".env file exists in repo"
else
    warn ".env not found — sync.sh will use defaults. Run: cp .env.example .env"
fi

# Check .env.example exists
if [[ -f "$SCRIPT_DIR/.env.example" ]]; then
    pass ".env.example exists in repo"
else
    fail ".env.example is missing from repo"
fi

# Check .env is gitignored
if git -C "$SCRIPT_DIR" check-ignore -q "$SCRIPT_DIR/.env" 2>/dev/null; then
    pass ".env is gitignored"
else
    warn ".env may not be gitignored — check .gitignore"
fi

# ============================================================================
# Summary
# ============================================================================

echo ""
echo "=============================="
if [[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]; then
    echo -e "${GREEN}${BOLD}All checks passed!${RESET}"
elif [[ $ERRORS -eq 0 ]]; then
    echo -e "${YELLOW}${BOLD}Passed with $WARNINGS warning(s)${RESET}"
else
    echo -e "${RED}${BOLD}$ERRORS error(s), $WARNINGS warning(s)${RESET}"
fi
echo "=============================="

exit $ERRORS
