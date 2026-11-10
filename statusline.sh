#!/bin/bash
# Status line script for Claude Code
#   Opus 5.5 | ██████░░░░ 42% ⧗ 12 min | 73%↑ 1:48 | 🌿 rule-fixes
# Segments (each hidden when it has no data):
#   model | context bar + % | prompt-cache countdown | plan limit + reset | worktree

python3 -c '
import json, os, subprocess, sys, time

R = "\033[0m"; DIM = "\033[2m"
GREEN = "\033[32m"; YELLOW = "\033[33m"; RED = "\033[31m"
SEP = f" {DIM}|{R} "

def level_color(pct):
    return GREEN if pct < 50 else YELLOW if pct < 80 else RED

def context_segment(data):
    pct = (data.get("context_window") or {}).get("used_percentage")
    if pct is None:
        return None
    width = 10
    filled = min(width, max(0, round(pct / 100 * width)))
    color = level_color(pct)
    bar = f"{color}{chr(0x2588) * filled}{R}{DIM}{chr(0x2591) * (width - filled)}{R}"
    return f"{bar} {color}{pct:.0f}%{R}"

def cache_segment(data, now):
    # Shown only while a warm cache exists; once it expires the next
    # message re-writes the whole prompt and costs several times more.
    pc = data.get("prompt_cache") or {}
    exp = pc.get("expires_at")
    if not pc.get("warm") or not exp or exp <= now:
        return None
    mins = max(1, round((exp - now) / 60))
    color = RED if mins <= 1 else YELLOW
    return f"{color}{chr(0x29D7)} {mins} min{R}"

WINDOWS = {"five_hour": 5 * 3600, "seven_day": 7 * 86400}

def fmt_reset(secs):
    secs = max(0, int(secs))
    d, rem = divmod(secs, 86400)
    h, m = divmod(rem // 60, 60)
    return f"{d}d {h}h" if d else f"{h}:{m:02d}"

def limit_segment(data, now):
    # The window closest to its limit; ↑ = usage running ahead of elapsed time.
    rl = data.get("rate_limits") or {}
    best = None
    for name, length in WINDOWS.items():
        w = rl.get(name) or {}
        pct, reset = w.get("used_percentage"), w.get("resets_at")
        if pct is None:
            continue
        if best is None or pct > best[0]:
            best = (pct, reset, length)
    if best is None:
        return None
    pct, reset, length = best
    out = f"{level_color(pct)}{pct:.0f}%"
    if reset:
        elapsed_pct = 100 * (length - (reset - now)) / length
        if pct > elapsed_pct:
            out += chr(0x2191)
        out += f"{R} {fmt_reset(reset - now)}"
    return out + R

def worktree_segment(data):
    wt = data.get("worktree") or {}
    name = wt.get("branch") or wt.get("name")
    if not name:
        # Fallback: a linked git worktree not created by Claude Code.
        cwd = (data.get("workspace") or {}).get("current_dir") or os.getcwd()
        try:
            out = subprocess.run(
                ["git", "-C", cwd, "rev-parse", "--absolute-git-dir", "--git-common-dir", "--abbrev-ref", "HEAD"],
                capture_output=True, text=True, timeout=1,
            ).stdout.split()
            if len(out) == 3:
                git_dir, common, branch = out
                common = os.path.realpath(os.path.join(cwd, common))
                if os.path.realpath(git_dir) != common:
                    name = branch
        except Exception:
            pass
    return f"{chr(0x1F33F)} {name}" if name else None

try:
    data = json.load(sys.stdin)
    now = time.time()
    model = (data.get("model") or {}).get("display_name", "Claude")
    ctx = context_segment(data)
    cache = cache_segment(data, now)
    if ctx and cache:
        ctx = f"{ctx} {cache}"
    parts = [model, ctx or cache, limit_segment(data, now), worktree_segment(data)]
    print(SEP.join(p for p in parts if p))
except Exception:
    print("Claude")
'
