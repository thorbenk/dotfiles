#!/usr/bin/env python3
"""Claude Code status line (global)."""

import json
import os
import subprocess
import sys
import time

CACHE_FILE = "/tmp/claude-statusline-git-cache"
CACHE_MAX_AGE = 5  # seconds

# ANSI colors
CYAN = "\033[36m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
RED = "\033[31m"
DIM = "\033[2m"
RESET = "\033[0m"

# Font Awesome / Nerd Font icons
ICON_FOLDER = "\uf07b"
ICON_BRANCH = "\uf126"
ICON_CLOCK = "\uf017"
ICON_CONTEXT = "\uf2db"


def get_git_info():
    """Get git branch and unstaged diffstat, with caching."""
    try:
        if (
            os.path.exists(CACHE_FILE)
            and time.time() - os.path.getmtime(CACHE_FILE) < CACHE_MAX_AGE
        ):
            with open(CACHE_FILE) as f:
                return json.load(f)
    except (OSError, json.JSONDecodeError):
        pass

    branch = ""
    added = 0
    removed = 0
    files_changed = 0

    try:
        subprocess.check_output(
            ["git", "rev-parse", "--git-dir"], stderr=subprocess.DEVNULL
        )
        branch = subprocess.check_output(
            ["git", "branch", "--show-current"],
            text=True,
            stderr=subprocess.DEVNULL,
        ).strip()

        numstat = subprocess.check_output(
            ["git", "diff", "--numstat"], text=True, stderr=subprocess.DEVNULL
        ).strip()

        if numstat:
            for line in numstat.split("\n"):
                parts = line.split("\t")
                if len(parts) >= 2:
                    files_changed += 1
                    a = parts[0] if parts[0] != "-" else "0"
                    d = parts[1] if parts[1] != "-" else "0"
                    added += int(a)
                    removed += int(d)
    except (subprocess.CalledProcessError, FileNotFoundError):
        pass

    info = {
        "branch": branch,
        "added": added,
        "removed": removed,
        "files_changed": files_changed,
    }

    try:
        with open(CACHE_FILE, "w") as f:
            json.dump(info, f)
    except OSError:
        pass

    return info


def main():
    data = json.load(sys.stdin)

    directory = os.path.basename(
        data.get("workspace", {}).get("current_dir", data.get("cwd", ""))
    )
    pct = int(data.get("context_window", {}).get("used_percentage", 0) or 0)
    duration_ms = data.get("cost", {}).get("total_duration_ms", 0) or 0
    git = get_git_info()

    parts = [f"{DIM}{ICON_FOLDER} {directory}{RESET}"]
    if git["branch"]:
        parts.append(f"{CYAN}{ICON_BRANCH} {git['branch']}{RESET}")
    if git["files_changed"] > 0:
        parts.append(
            f"{GREEN}+{git['added']}{RESET} "
            f"{RED}-{git['removed']}{RESET} "
            f"{YELLOW}~{git['files_changed']}{RESET}"
        )

    model = data.get("model", {}).get("display_name", "")
    if model:
        parts.append(model)

    bar_color = RED if pct >= 90 else YELLOW if pct >= 70 else GREEN
    filled = pct * 10 // 100
    bar = "\u2593" * filled + "\u2591" * (10 - filled)
    parts.append(f"{ICON_CONTEXT} {bar_color}{bar}{RESET} {pct}%")

    mins = duration_ms // 60000
    secs = (duration_ms % 60000) // 1000
    parts.append(f"{ICON_CLOCK} {mins}m{secs:02d}s")

    print(" | ".join(parts))


if __name__ == "__main__":
    main()
