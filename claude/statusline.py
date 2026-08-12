#!/usr/bin/env python3
"""Claude Code status line (global)."""

import hashlib
import json
import os
import subprocess
import sys
import time

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
ICON_CONTEXT = "\uf2db"
ICON_BUILD = "\uf085"


def runtime_base():
    """Private per-user runtime dir, falling back to /tmp with no user session."""
    base = f"/run/user/{os.getuid()}"
    if not os.path.isdir(base):
        base = f"/tmp/claude-{os.getuid()}"
    return base


def git_cache_file():
    """Cache path keyed by cwd.

    Keyed rather than global because parallel sessions in different worktrees
    would otherwise overwrite each other's branch and diffstat. Digested, not
    hash()ed: str hashing is salted per process, so a hash() key would never
    hit. cwd is the key because that is where the git commands below run.
    """
    key = hashlib.sha1(os.getcwd().encode()).hexdigest()[:12]
    directory = os.path.join(runtime_base(), "claude-statusline")
    try:
        os.makedirs(directory, mode=0o700, exist_ok=True)
    except OSError:
        return None
    return os.path.join(directory, f"git-{key}")


def get_git_info():
    """Get git branch and unstaged diffstat, with caching."""
    cache_file = git_cache_file()

    try:
        if (
            cache_file
            and os.path.exists(cache_file)
            and time.time() - os.path.getmtime(cache_file) < CACHE_MAX_AGE
        ):
            with open(cache_file) as f:
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
        if cache_file:
            with open(cache_file, "w") as f:
                json.dump(info, f)
    except OSError:
        pass

    return info


def get_build_progress(session_id):
    """Sum live ninja builds published by shell-progress.py for this session.

    Pruning is by /proc liveness, so a wrapper killed before it could clean up
    after itself does not leave a phantom build on the status line.
    """
    if not session_id:
        return None

    directory = os.path.join(runtime_base(), "claude-ninja", session_id)

    try:
        names = os.listdir(directory)
    except OSError:
        return None

    states = []
    for name in names:
        if not name.endswith(".json"):
            continue
        path = os.path.join(directory, name)
        try:
            with open(path) as f:
                state = json.load(f)
            if not os.path.exists(f"/proc/{state['pid']}"):
                os.unlink(path)
                continue
            states.append(state)
        except (OSError, ValueError, KeyError):
            continue

    if not states:
        return None

    return {
        "builds": len(states),
        "finished": sum(s["finished"] for s in states),
        "total": sum(s["total"] for s in states),
        "running": sum(s["running"] for s in states),
    }


def main():
    data = json.load(sys.stdin)

    directory = os.path.basename(
        data.get("workspace", {}).get("current_dir", data.get("cwd", ""))
    )
    pct = int(data.get("context_window", {}).get("used_percentage", 0) or 0)
    git = get_git_info()

    parts = [f"{DIM}{ICON_FOLDER} {directory}{RESET}"]
    if git["branch"]:
        parts.append(f"{CYAN}{ICON_BRANCH} {git['branch']}{RESET}")
    if git["files_changed"] > 0:
        parts.append(f"{GREEN}+{git['added']}{RESET} {RED}-{git['removed']}{RESET}")

    # A status line that raises prints nothing at all, so never let a build
    # segment take the whole line down with it.
    try:
        build = get_build_progress(data.get("session_id"))
    except Exception:
        build = None

    if build:
        total = build["total"]
        build_pct = round(100 * build["finished"] / total) if total else 0
        label = f"{build['builds']} builds " if build["builds"] > 1 else ""
        parts.append(
            f"{YELLOW}{ICON_BUILD} {label}{build['finished']}/{total}"
            f" ({build_pct}%){RESET} {DIM}{build['running']} running{RESET}"
        )

    model = data.get("model", {}).get("display_name", "")
    if model:
        parts.append(model.replace(" context", ""))

    permission_mode = data.get("permissionMode", "")
    if permission_mode:
        mode_label = permission_mode.capitalize()
        parts.append(f"{DIM}{mode_label}{RESET}")

    bar_color = RED if pct >= 90 else YELLOW if pct >= 70 else GREEN
    filled = pct * 10 // 100
    bar = "\u2593" * filled + "\u2591" * (10 - filled)
    parts.append(f"{ICON_CONTEXT} {bar_color}{bar}{RESET} {pct}%")

    print(" | ".join(parts))


if __name__ == "__main__":
    main()
