#!/bin/bash
# Status line script for Claude Code
# Displays model name, context usage, and session cost

# Read JSON input from stdin and process with Python
python3 -c '
import sys, json

try:
    data = json.load(sys.stdin)
    model = data.get("model", {}).get("display_name", "Claude")
    used_percent = data.get("context_window", {}).get("used_percentage")
    cwd = data.get("workspace", {}).get("current_dir", "")

    # Get session cost
    cost = data.get("cost", {}).get("total_cost_usd")

    # Get directory name if available
    dir_name = ""
    if cwd:
        import os
        dir_name = os.path.basename(cwd)

    # Build status line
    parts = [f"[{model}]"]
    if dir_name:
        parts.append(dir_name)
    if used_percent is not None:
        parts.append(f"Ctx: {used_percent:.1f}%")
    if cost is not None:
        parts.append(f"${cost:.3f}")

    print(" • ".join(parts))
except Exception as e:
    print("[Claude]")
'
