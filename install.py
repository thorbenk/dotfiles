#!/usr/bin/env -S uv run python

import subprocess
import dataclasses
import contextlib
from typing import Generator
from colorama import Fore
from urllib.parse import urlparse
from typing import Callable
import re
import shutil
import urllib.request
from pathlib import Path
import tarfile
import zipfile
import os
import sys
import tempfile
import platform
import json
import argparse

PWD = Path(__file__).parent
LOCAL_BIN = Path(os.path.expanduser("~/.local/bin"))
LOCAL_BIN.mkdir(parents=True, exist_ok=True)

ARCH = platform.machine()
LOCK_FILE = PWD / "install.lock.json"


@dataclasses.dataclass(frozen=True)
class GitHubRelease:
    repo: str  # e.g., "sharkdp/fd"
    version_pattern: str | None = None  # regex to match version in tag, e.g., r"v(\d+\.\d+\.\d+)"
    asset_pattern: str | None = None  # pattern to match asset name with {version} and {arch} placeholders
    binary_name: str | None = None  # name of the binary in the archive
    extract_dir_pattern: str | None = None  # pattern for directory in archive with {version} and {arch} placeholders


GITHUB_RELEASES = {
    "fd": GitHubRelease(
        repo="sharkdp/fd",
        asset_pattern="fd-v{version}-{arch}-unknown-linux-gnu.tar.gz",
        binary_name="fd",
        extract_dir_pattern="fd-v{version}-{arch}-unknown-linux-gnu",
    ),
    "lazygit": GitHubRelease(
        repo="jesseduffield/lazygit",
        asset_pattern="lazygit_{version}_linux_{arch}.tar.gz",
        binary_name="lazygit",
    ),
    "difftastic": GitHubRelease(
        repo="Wilfred/difftastic",
        asset_pattern="difft-{arch}-unknown-linux-gnu.tar.gz",
        binary_name="difft",
    ),
    "hyperfine": GitHubRelease(
        repo="sharkdp/hyperfine",
        asset_pattern="hyperfine-v{version}-{arch}-unknown-linux-gnu.tar.gz",
        binary_name="hyperfine",
        extract_dir_pattern="hyperfine-v{version}-{arch}-unknown-linux-gnu",
    ),
    "bat": GitHubRelease(
        repo="sharkdp/bat",
        asset_pattern="bat-v{version}-{arch}-unknown-linux-gnu.tar.gz",
        binary_name="bat",
        extract_dir_pattern="bat-v{version}-{arch}-unknown-linux-gnu",
    ),
    "delta": GitHubRelease(
        repo="dandavison/delta",
        asset_pattern="delta-{version}-{arch}-unknown-linux-gnu.tar.gz",
        binary_name="delta",
        extract_dir_pattern="delta-{version}-{arch}-unknown-linux-gnu",
    ),
    "nvim": GitHubRelease(
        repo="neovim/neovim",
        asset_pattern="nvim-linux-{arch_alt}.appimage",
        binary_name="nvim-linux-{arch_alt}.appimage",
    ),
    "firacode": GitHubRelease(
        repo="ryanoasis/nerd-fonts",
        asset_pattern="FiraCode.zip",
    ),
    "difft": GitHubRelease(
        repo="Wilfred/difftastic",
        asset_pattern="difft-{arch}-unknown-linux-gnu.tar.gz",
    ),
}


def get_arch_alt():
    """Convert x86_64 to x86_64, aarch64 to arm64, etc."""
    match ARCH:
        case "x86_64":
            return "x86_64"
        case "aarch64":
            return "arm64"
        case _:
            return ARCH


def fetch_latest_release(repo: str) -> dict:
    """Fetch the latest release info from GitHub API."""
    url = f"https://api.github.com/repos/{repo}/releases/latest"
    print(f"Fetching latest release for {repo}...")

    request = urllib.request.Request(url)
    request.add_header("Accept", "application/vnd.github+json")

    try:
        with urllib.request.urlopen(request) as response:
            return json.loads(response.read().decode())
    except urllib.error.HTTPError as e:
        print(f"Error fetching release for {repo}: {e}")
        raise


def extract_version_from_tag(tag: str, pattern: str | None = None) -> str:
    """Extract version from git tag."""
    if pattern:
        match = re.search(pattern, tag)
        if match:
            return match.group(1)

    # Default: remove leading 'v' if present
    return tag.lstrip('v')


def find_matching_asset(assets: list[dict], pattern: str, version: str) -> str | None:
    """Find asset URL matching the pattern for current architecture."""
    arch_alt = get_arch_alt()

    # Replace placeholders in pattern - try both arch formats
    patterns_to_try = [
        pattern.format(version=version, arch=ARCH, arch_alt=arch_alt),
        pattern.format(version=version, arch=arch_alt, arch_alt=arch_alt),
    ]

    for pattern_filled in patterns_to_try:
        for asset in assets:
            if asset["name"] == pattern_filled:
                return asset["browser_download_url"]

    return None


def update_lock_file():
    """Fetch latest releases and update the lock file."""
    lock_data = {}

    for name, release_info in GITHUB_RELEASES.items():
        try:
            release = fetch_latest_release(release_info.repo)
            tag = release["tag_name"]
            version = extract_version_from_tag(tag, release_info.version_pattern)

            if release_info.asset_pattern:
                url = find_matching_asset(
                    release["assets"],
                    release_info.asset_pattern,
                    version,
                )
                if not url:
                    print(f"Warning: Could not find matching asset for {name}")
                    continue
            else:
                url = release["tarball_url"]

            lock_data[name] = {
                "version": version,
                "tag": tag,
                "url": url,
                "repo": release_info.repo,
            }

            if release_info.binary_name:
                # Fill in arch placeholders in binary name
                binary_name = release_info.binary_name.format(
                    arch=ARCH,
                    arch_alt=get_arch_alt(),
                    version=version,
                )
                lock_data[name]["binary_name"] = binary_name

            if release_info.extract_dir_pattern:
                extract_dir = release_info.extract_dir_pattern.format(
                    version=version,
                    arch=ARCH,
                    arch_alt=get_arch_alt(),
                )
                lock_data[name]["extract_dir"] = extract_dir

            print(f"✓ {name}: {version}")

        except Exception as e:
            print(f"✗ Failed to fetch {name}: {e}")
            continue

    with open(LOCK_FILE, "w") as f:
        json.dump(lock_data, f, indent=2)

    print(f"\nLock file updated: {LOCK_FILE}")


def load_lock_file() -> dict:
    if not LOCK_FILE.exists():
        print(f"Lock file not found. Run with --update-lock to create it.")
        sys.exit(1)

    with open(LOCK_FILE) as f:
        return json.load(f)


def download_with_progress(url, fname):
    def reporthook(block_num, block_size, total_size):
        downloaded = block_num * block_size
        progress = downloaded / total_size * 100 if total_size > 0 else 0
        sys.stdout.write(f"\rDownloading {url}: {progress:.2f}%")
        sys.stdout.flush()

    try:
        urllib.request.urlretrieve(url, fname, reporthook)
    except urllib.error.HTTPError as e:
        print(f"\nDownload failed for {url}")
        raise
    sys.stdout.write("\n")


def mkpath(s: str) -> Path:
    return Path(os.path.expanduser(s))


@contextlib.contextmanager
def extract_and_download(url: str) -> Generator[Path, None, None]:
    with tempfile.TemporaryDirectory(delete=True) as tmpdir:
        fname = tmpdir + "/" + url.split("/")[-1]
        download_with_progress(url, fname)
        if fname.endswith(".tar.gz"):
            with tarfile.open(fname, "r:gz") as tar:
                tar.extractall(path=tmpdir, filter="data")
        elif fname.endswith(".zip"):
            with zipfile.ZipFile(fname, "r") as zip_ref:
                zip_ref.extractall(tmpdir)
        yield Path(tmpdir)


def run(cmd: list[str]):
    try:
        r = subprocess.run(cmd, capture_output=True)
    except FileNotFoundError:
        return ""
    if r.returncode != 0:
        return ""
    return r.stdout.decode("utf-8")


@dataclasses.dataclass
class Check:
    cmd: list[str]
    lines: int = -1
    extract_version: Callable[[str], str] | None = None
    install: Callable[[], None] | None = None


def install_fonts():
    lock = load_lock_file()

    if "firacode" not in lock:
        print("FiraCode not found in lock file")
        return

    url = lock["firacode"]["url"]
    zip_path = "FiraCode.zip"
    local_fonts = Path(os.path.expanduser("~/.local/share/fonts"))
    print(local_fonts)
    local_fonts.mkdir(parents=True, exist_ok=True)

    download_with_progress(url, zip_path)

    with zipfile.ZipFile(zip_path, "r") as zip_ref:
        zip_ref.extractall(local_fonts)

    os.remove(zip_path)

    subprocess.run(["fc-cache", "-f", "-v"], cwd=local_fonts)


def chmod_x(fname: Path):
    current_permissions = os.stat(fname).st_mode
    new_permissions = current_permissions | 0o111
    os.chmod(fname, new_permissions)


def install_from_lock(package_name: str):
    lock = load_lock_file()

    if package_name not in lock:
        print(f"{package_name} not found in lock file")
        return

    package_info = lock[package_name]
    url = package_info["url"]

    # Special case for appimage
    if url.endswith(".appimage"):
        with tempfile.TemporaryDirectory() as tmpdir:
            fname = os.path.basename(urlparse(url).path)
            fpath = os.path.join(tmpdir, fname)
            download_with_progress(url, fpath)

            dest = LOCAL_BIN / fname
            shutil.copy(fpath, dest)
            chmod_x(dest)

            # Create symlink without .appimage extension
            binary_link = LOCAL_BIN / package_name
            ensure_symlink(dest, binary_link)
            chmod_x(binary_link)

        return

    # Regular archive extraction
    with extract_and_download(url) as tmpdir:
        binary_name = package_info.get("binary_name", package_name)

        # Check if there's an extract_dir
        if "extract_dir" in package_info:
            bin_path = tmpdir / package_info["extract_dir"] / binary_name
        else:
            bin_path = tmpdir / binary_name

        if not bin_path.exists():
            # Try to find the binary in tmpdir
            print(f"Binary not found at expected path: {bin_path}")
            print(f"Contents of {tmpdir}:")
            subprocess.call(f"ls -la {tmpdir}", shell=True)

            # Try to find it recursively
            for root, dirs, files in os.walk(tmpdir):
                if binary_name in files:
                    bin_path = Path(root) / binary_name
                    print(f"Found binary at: {bin_path}")
                    break

        if bin_path.exists():
            shutil.copy(bin_path, LOCAL_BIN)
            chmod_x(LOCAL_BIN / binary_name)
        else:
            print(f"Could not find binary {binary_name} for {package_name}")





def nvim_version(version_output: str):
    match = re.search(r"NVIM v(\d+\.\d+\.\d+)", version_output)
    assert match
    return match.group(1)


def fd_version(version_output: str):
    match = re.search(r"(\d+\.\d+\.\d+)", version_output)
    assert match
    return match.group(1)


def bat_version(version_output: str):
    match = re.search(r"bat (\d+\.\d+\.\d+)", version_output)
    assert match
    return match.group(1)


def delta_version(version_output: str):
    match = re.search(r"delta (\d+\.\d+\.\d+)", version_output)
    assert match
    return match.group(1)


def basedpyright_version(version_output: str):
    match = re.search(r"basedpyright (\d+\.\d+\.\d+)", version_output)
    assert match
    return match.group(1)


def hyperfine_version(version_output: str):
    match = re.search(r"(\d+\.\d+\.\d+)", version_output)
    assert match
    return match.group(1)


def lazygit_version(version_output: str):
    match = re.search(r"version=(\d+\.\d+\.\d+)", version_output)
    assert match
    return match.group(1)


def curl_version(version_output: str):
    match = re.search(r"curl (\d+\.\d+\.\d+)", version_output)
    assert match
    return match.group(1)


def difftastic_version(version_output: str):
    match = re.search(r"Difftastic (\d+\.\d+\.\d+)", version_output)
    assert match
    return match.group(1)


def query_fira_code_fonts():
    result = subprocess.run(
        ["fc-list", ":family"], capture_output=True, text=True, check=True
    ).stdout
    fira_code_fonts = [line for line in result.splitlines() if "FiraCode" in line]
    if fira_code_fonts:
        print(Fore.GREEN + "FiraCode fonts found" + Fore.RESET)
        return True
    return False


def ensure_symlink(src: Path, dst: Path):
    if dst.exists() and dst.is_symlink() and dst.resolve() == src:
        print(Fore.GREEN + f"symlink {dst} -> {src} already exists" + Fore.RESET)
    else:
        if dst.exists() or dst.is_symlink():
            print(f"removing existing {dst}")
            dst.unlink()
        print(f"creating symlink {dst} -> {src}")
        dst.symlink_to(src)


def show_lock_file():
    """Display lock file contents in a readable format."""
    if not LOCK_FILE.exists():
        print(f"Lock file not found at {LOCK_FILE}")
        print("Run with --update-lock to create it")
        sys.exit(1)

    lock = load_lock_file()

    print(f"\nLock file: {LOCK_FILE}")
    print(f"{'='*80}\n")

    M = max(len(name) for name in lock.keys())

    for name, info in sorted(lock.items()):
        version = info.get("version", "unknown")
        repo = info.get("repo", "")
        print(f"{Fore.CYAN}{name:<{M}}{Fore.RESET} : v{version:<10} ({repo})")

    print()


def check_versions():
    """Compare installed versions with lock file versions."""
    lock = load_lock_file()

    print(f"\nVersion Check (Installed vs Locked)")
    print(f"{'='*80}\n")

    M = max(len(name) for name in lock.keys())

    outdated = []
    up_to_date = []
    not_installed = []

    for name, info in sorted(lock.items()):
        if name == "firacode":
            continue  # Skip font check

        locked_version = info.get("version", "unknown")

        # Try to get installed version
        if name in ["nvim", "lazygit", "difft", "fd", "hyperfine", "bat", "delta"]:
            cmd_map = {
                "nvim": (["nvim", "--version"], nvim_version),
                "lazygit": (["lazygit", "--version"], lazygit_version),
                "difft": (["difft", "--version"], None),
                "fd": (["fd", "--version"], fd_version),
                "hyperfine": (["hyperfine", "--version"], hyperfine_version),
                "bat": (["bat", "--version"], bat_version),
                "delta": (["delta", "--version"], delta_version),
            }

            if name in cmd_map:
                cmd, extract_fn = cmd_map[name]
                output = run(cmd)

                if output == "":
                    not_installed.append(name)
                    print(f"{Fore.RED}{name:<{M}}{Fore.RESET} : NOT INSTALLED (locked: v{locked_version})")
                    continue

                if extract_fn:
                    installed_version = extract_fn(output.splitlines()[0])
                else:
                    installed_version = output.strip().split()[0]

                if installed_version == locked_version:
                    up_to_date.append(name)
                    print(f"{Fore.GREEN}{name:<{M}}{Fore.RESET} : v{installed_version} ✓")
                else:
                    outdated.append(name)
                    print(f"{Fore.YELLOW}{name:<{M}}{Fore.RESET} : v{installed_version} → v{locked_version}")

    print(f"\n{'='*80}")
    print(f"Summary: {Fore.GREEN}{len(up_to_date)} up-to-date{Fore.RESET}, "
          f"{Fore.YELLOW}{len(outdated)} outdated{Fore.RESET}, "
          f"{Fore.RED}{len(not_installed)} not installed{Fore.RESET}\n")

    if outdated or not_installed:
        print("Run './install.py' to install missing or update outdated tools")


def main():
    parser = argparse.ArgumentParser(description="Install dotfiles and dependencies")
    parser.add_argument(
        "--update-lock",
        action="store_true",
        help="Update install.lock.json with latest releases from GitHub",
    )
    parser.add_argument(
        "--show-lock",
        action="store_true",
        help="Display contents of install.lock.json",
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="Check installed versions against lock file",
    )
    args = parser.parse_args()

    if args.update_lock:
        update_lock_file()
        return

    if args.show_lock:
        show_lock_file()
        return

    if args.check:
        check_versions()
        return

    # Check if lock file exists
    if not LOCK_FILE.exists():
        print(f"Lock file not found at {LOCK_FILE}")
        print("Run with --update-lock to create it")
        sys.exit(1)

    if not query_fira_code_fonts():
        install_fonts()

    lock = load_lock_file()

    # System dependencies (not in lock file)
    system_deps = {
        "git": Check(cmd=["git", "--version"], lines=1),
        "uv": Check(cmd=["uv", "--version"], lines=1),
        "zsh": Check(cmd=["zsh", "--version"], lines=1),
        "wget": Check(cmd=["wget", "--version"], lines=1),
        "curl": Check(cmd=["curl", "--version"], lines=1, extract_version=curl_version),
        "npm": Check(cmd=["npm", "--version"], lines=1),
        "fzf": Check(cmd=["fzf", "--version"], lines=1),
        "rg": Check(cmd=["rg", "--version"], lines=1),
        "tmux": Check(cmd=["tmux", "-V"], lines=1),
        "basedpyright": Check(
            cmd=["basedpyright", "--version"],
            lines=1,
            extract_version=basedpyright_version,
        ),
    }

    # Tools managed by lock file
    lockfile_tools = {
        "nvim": Check(
            cmd=["nvim", "--version"],
            lines=1,
            extract_version=nvim_version,
        ),
        "lazygit": Check(
            cmd=["lazygit", "--version"],
            lines=1,
            extract_version=lazygit_version,
        ),
        "difft": Check(
            cmd=["difft", "--version"],
            lines=1,
            extract_version=difftastic_version,
        ),
        "fd": Check(
            cmd=["fd", "--version"],
            lines=1,
            extract_version=fd_version,
        ),
        "hyperfine": Check(
            cmd=["hyperfine", "--version"],
            lines=1,
            extract_version=hyperfine_version,
        ),
        "bat": Check(
            cmd=["bat", "--version"],
            lines=1,
            extract_version=bat_version,
        ),
        "delta": Check(
            cmd=["delta", "--version"],
            lines=1,
            extract_version=delta_version,
        ),
    }

    M = max(len(name) for name in list(system_deps.keys()) + list(lockfile_tools.keys()))

    failed = False

    # Check system dependencies
    for name, cmd in system_deps.items():
        r = run(cmd.cmd)
        if r == "":
            print(Fore.RED + f"{name:<{M}} : not found" + Fore.RESET)
            failed = True
        else:
            lines = r.splitlines()
            version_str = ", ".join(lines[: cmd.lines])
            if cmd.extract_version:
                version_str = cmd.extract_version(version_str)
            print(Fore.GREEN + f"{name:<{M}} : {version_str}" + Fore.RESET)

    # Check and install/update lockfile-managed tools
    for name, cmd in lockfile_tools.items():
        if name not in lock:
            print(Fore.YELLOW + f"{name:<{M}} : not in lock file, skipping" + Fore.RESET)
            continue

        locked_version = lock[name].get("version", "unknown")
        r = run(cmd.cmd)

        if r == "":
            # Tool not installed
            print(Fore.YELLOW + f"{name:<{M}} : not found, installing v{locked_version}" + Fore.RESET)
            install_from_lock(name)
            # Verify installation
            r = run(cmd.cmd)
            if r:
                lines = r.splitlines()
                version_str = ", ".join(lines[: cmd.lines])
                if cmd.extract_version:
                    version_str = cmd.extract_version(version_str)
                print(Fore.GREEN + f"{name:<{M}} : {version_str} ✓" + Fore.RESET)
        else:
            # Tool is installed, check version
            lines = r.splitlines()
            version_str = ", ".join(lines[: cmd.lines])
            if cmd.extract_version:
                installed_version = cmd.extract_version(version_str)
            else:
                installed_version = version_str.strip().split()[0] if version_str else "unknown"

            if installed_version != locked_version:
                # Version mismatch, update
                print(Fore.YELLOW + f"{name:<{M}} : v{installed_version} → v{locked_version}, updating" + Fore.RESET)
                install_from_lock(name)
                # Verify update
                r = run(cmd.cmd)
                if r:
                    lines = r.splitlines()
                    version_str = ", ".join(lines[: cmd.lines])
                    if cmd.extract_version:
                        version_str = cmd.extract_version(version_str)
                    print(Fore.GREEN + f"{name:<{M}} : {version_str} ✓" + Fore.RESET)
            else:
                # Version matches
                print(Fore.GREEN + f"{name:<{M}} : {installed_version} ✓" + Fore.RESET)

    print()
    print("=" * 80)
    print("Tool installation complete!")
    print("Note: Dotfiles symlinking is handled by Dotbot (./install)")
    print("=" * 80)

    if failed:
        print("Check failed.")
        sys.exit(1)


if __name__ == "__main__":
    main()
