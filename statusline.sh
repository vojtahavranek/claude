#!/bin/bash
# Status line script for Claude Code
#   Opus 5.5 | ████░░░░░░ 42% ⧗ 12 min | 73%↑ 1:48 | skyvest ⎇ fix-x #131 ✓
# Segments (each hidden when it has no data):
#   model | context bar + % | prompt-cache countdown | plan limit + reset |
#   repo + branch (🌿 in a worktree) + PR of the branch

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

def git_info(cwd):
    # One git call: repo root, git dirs (to spot a linked worktree), branch.
    try:
        out = subprocess.run(
            ["git", "-C", cwd, "rev-parse", "--show-toplevel", "--absolute-git-dir",
             "--git-common-dir", "--abbrev-ref", "HEAD"],
            capture_output=True, text=True, timeout=1,
        ).stdout.split("\n")
    except Exception:
        return None
    if len(out) < 4 or not out[0]:
        return None
    top, git_dir, common, branch = out[:4]
    common = os.path.realpath(os.path.join(cwd, common))
    is_worktree = os.path.realpath(git_dir) != common
    # Name the repo after the main checkout, also when inside a worktree.
    repo = os.path.basename(os.path.dirname(common)) if is_worktree and os.path.basename(common) == ".git" else os.path.basename(top)
    return repo, branch, is_worktree

def repo_segment(data):
    # repo + branch of the folder Claude is working in (follows cd), plus the branch PR.
    cwd = (data.get("workspace") or {}).get("current_dir") or os.getcwd()
    info = git_info(cwd)
    wt = data.get("worktree") or {}
    if not info and not wt:
        return None
    repo, branch, is_worktree = info or ("", "", False)
    if wt:
        branch = wt.get("branch") or wt.get("name") or branch
        is_worktree = True
    icon = chr(0x1F33F) if is_worktree else f"{DIM}{chr(0x2387)}{R}"
    out = " ".join(x for x in (repo, icon, branch) if x)
    pr = data.get("pr") or {}
    if pr.get("number"):
        state = pr.get("review_state")
        mark = {"approved": f" {GREEN}{chr(0x2713)}{R}", "changes_requested": f" {RED}{chr(0x2717)}{R}"}.get(state, "")
        num = pr.get("number")
        out += f" #{num}{mark}"
    return out

try:
    data = json.load(sys.stdin)
    now = time.time()
    model = (data.get("model") or {}).get("display_name", "Claude")
    ctx = context_segment(data)
    cache = cache_segment(data, now)
    if ctx and cache:
        ctx = f"{ctx} {cache}"
    parts = [model, ctx or cache, limit_segment(data, now), repo_segment(data)]
    print(SEP.join(p for p in parts if p))
except Exception:
    print("Claude")
'
