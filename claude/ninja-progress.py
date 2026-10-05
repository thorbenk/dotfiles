#!/usr/bin/env python3
"""Ninja wrapper that publishes build progress for the Claude Code status line.

Invoked via bin/ninja, the PATH shim that shadows the real ninja. That covers a
bare `ninja`, and also `cmake --build` for any build dir configured with
CMAKE_MAKE_PROGRAM set to the bare name "ninja" (CMake then resolves it from
PATH at build time rather than baking in /usr/bin/ninja).

Why at the ninja process boundary rather than the shell's: agents routinely
filter build output, e.g.

    cmake --build build/rdb --target foo 2>&1 | grep -E "error:|FAILED" | head

precisely to keep thousands of progress lines out of their context. grep eats
ninja's status lines before anything downstream can read them, so a wrapper
around the whole shell command sees nothing. Here we parse our own child's
output and write the state file ourselves, which makes the rest of the pipeline
irrelevant.

Progress is published to a per-session state file that claude/statusline.py
sums -- the two must agree on this path and these keys:
    /run/user/<uid>/claude-ninja/<session>/<pid>.json

Outside a Claude Code session, and for CMake's own probing invocations
(--version and friends), this exec's the real ninja unchanged -- so an
interactive build keeps ninja's live single-line terminal progress rather than
one line per edge.
"""

import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

MARKER = "__CC_NINJA__"
# finished : total : running : queued (ninja's %f %t %r %u)
NINJA_STATUS = MARKER + ":%f:%t:%r:%u "
STATUS_RE = re.compile(MARKER + r":(\d+):(\d+):(\d+):(\d+) ")

# Invocations that are not a build: CMake probes the make program at configure
# time, and `-t`/`-n` are tool/dry-run modes whose output we must not touch.
PROBE_FLAGS = {"--version", "--help", "-h", "-t", "-n"}


def real_ninja() -> str:
    """The actual ninja binary, never this script."""
    override = os.environ.get("NINJA_REAL")
    if override:
        return override

    me = Path(__file__).resolve()
    for candidate in ("/usr/bin/ninja", shutil.which("ninja")):
        if candidate and Path(candidate).resolve() != me:
            return candidate
    return "/usr/bin/ninja"


def state_paths(session_id: str) -> tuple[Path, Path]:
    """Create the session's state dir and return (state_file, tmp_file).

    Derived from uid alone, deliberately not from XDG_RUNTIME_DIR: the status
    line resolves this path in a separate process and the two must not disagree.
    """
    base = Path(f"/run/user/{os.getuid()}")
    if not base.is_dir():
        base = Path(f"/tmp/claude-{os.getuid()}")

    directory = base / "claude-ninja" / session_id
    directory.mkdir(parents=True, exist_ok=True)
    return directory / f"{os.getpid()}.json", directory / f".{os.getpid()}.tmp"


def publish(state_file: Path, tmp_file: Path, state: dict) -> None:
    """Write state atomically; never let progress reporting break a build."""
    try:
        tmp_file.write_text(json.dumps(state))
        os.replace(tmp_file, state_file)
    except Exception:
        pass


def relay(args: list[str], state_file: Path, tmp_file: Path) -> int:
    """Run ninja, publishing progress as it goes. Returns its exit code."""
    process = subprocess.Popen(
        [real_ninja(), *args],
        env=dict(os.environ, NINJA_STATUS=NINJA_STATUS),
        stdout=subprocess.PIPE,
        # One merged stream, so compiler diagnostics stay next to the edge that
        # produced them instead of racing ninja's progress on a separate fd.
        stderr=subprocess.STDOUT,
        text=True,
        errors="replace",
        bufsize=1,
    )

    # Once downstream closes the pipe (a `head` in the pipeline, say) we stop
    # forwarding but keep reading: a ninja that can no longer write to its own
    # stdout blocks forever, and the caller is waiting on its exit code.
    forwarding = True
    try:
        assert process.stdout is not None
        for line in process.stdout:
            match = STATUS_RE.match(line)
            if match:
                finished, total, running, queued = map(int, match.groups())
                publish(
                    state_file,
                    tmp_file,
                    {
                        "pid": os.getpid(),
                        "finished": finished,
                        "total": total,
                        "running": running,
                        "queued": queued,
                    },
                )
                # Restore ninja's normal prefix, so build output that does
                # reach a human or an agent looks untouched.
                line = f"[{finished}/{total}] {line[match.end():]}"

            if not forwarding:
                continue
            try:
                sys.stdout.write(line)
                sys.stdout.flush()
            except Exception:
                # Point stdout at /dev/null so the interpreter's final flush
                # cannot raise either.
                forwarding = False
                try:
                    devnull = os.open(os.devnull, os.O_WRONLY)
                    os.dup2(devnull, sys.stdout.fileno())
                    os.close(devnull)
                except Exception:
                    pass

        return process.wait()
    finally:
        for path in (tmp_file, state_file):
            try:
                path.unlink()
            except OSError:
                pass


def main() -> None:
    args = sys.argv[1:]


    # Anything that goes wrong before ninja starts is safe to shrug off: exec'ing
    # the real binary is exactly what an uninstrumented build would have done.
    try:
        session_id = os.environ.get("CLAUDE_CODE_SESSION_ID")
        tracked = bool(session_id) and not (PROBE_FLAGS & set(args))
        paths = state_paths(session_id) if tracked else None
    except Exception:
        paths = None


    if paths is None:
        os.execv(real_ninja(), [real_ninja(), *args])

    sys.exit(relay(args, *paths))


if __name__ == "__main__":
    main()
