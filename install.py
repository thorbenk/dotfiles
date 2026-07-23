#!/usr/bin/env -S uv run python

import subprocess
import dataclasses
import contextlib
from typing import Generator, TypedDict, cast, NotRequired, Callable
from colorama import Fore
from urllib.parse import urlparse
import re
import gzip
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
LOCAL_FONTS = Path(os.path.expanduser("~/.local/share/fonts"))

ARCH = platform.machine()
# aarch64 -> arm64/arm64; x86_64 -> x86_64/x64. Fall back to raw ARCH otherwise.
ARCH_ALT = {"aarch64": "arm64"}.get(ARCH, ARCH)
ARCH_SHORT = {"x86_64": "x64", "aarch64": "arm64"}.get(ARCH, ARCH)
LOCK_FILE = PWD / "install.lock.json"
HOSTNAME = platform.node()


def url_filename(url: str) -> str:
    """The trailing filename of a URL, ignoring any query/fragment."""
    return os.path.basename(urlparse(url).path)


def fill(pattern: str, version: str = "", arch: str | None = None) -> str:
    """Fill {version}/{arch}/{arch_alt}/{arch_short} placeholders in a pattern."""
    return pattern.format(
        version=version, arch=arch or ARCH, arch_alt=ARCH_ALT, arch_short=ARCH_SHORT
    )


@dataclasses.dataclass(frozen=True)
class Dep:
    name: str
    only_on: tuple[str, ...] | None = None
    not_on: tuple[str, ...] | None = None

    def __post_init__(self) -> None:
        if self.only_on is not None and self.not_on is not None:
            raise ValueError(f"Dep {self.name}: cannot set both only_on and not_on")

    def applies_here(self) -> bool:
        if self.only_on is not None and HOSTNAME not in self.only_on:
            return False
        if self.not_on is not None and HOSTNAME in self.not_on:
            return False
        return True


# WHAT to install, and on which hosts. HOW each dep is fetched / version-checked
# is defined below in GITHUB_RELEASES and SYSTEM_DEPS / LOCKFILE_TOOLS.
DEPS: list[Dep] = [
    # System tools (provided by package manager; only version-checked)
    Dep("git"),
    Dep("uv"),
    Dep("zsh"),
    Dep("wget"),
    Dep("curl"),
    Dep("npm"),
    Dep("fnm"),
    Dep("direnv"),
    Dep("fzf"),
    Dep("rg"),
    Dep("tmux"),
    # Tools managed via install.lock.json + GitHub releases
    Dep("nvim"),
    Dep("lazygit"),
    Dep("difft"),
    Dep("fd"),
    Dep("hyperfine"),
    Dep("bat"),
    Dep("delta"),
    Dep("codex"),
    Dep("btm"),
    Dep("tree-sitter"),
    Dep("clangd"),
    Dep("zed"),
    Dep("marktext"),
    Dep("typst"),
    Dep("atuin"),
    Dep("zoxide"),
    Dep("just"),
    Dep("hunk"),
    Dep("rclone", only_on=("DEHEI-7H3ZXL3",)),
    # Fonts
    Dep("firacode"),
    Dep("iosevkaterm"),
]

# Lock-file key -> font-family pattern used by fc-list
FONTS: dict[str, str] = {
    "firacode": "FiraCode",
    "iosevkaterm": "IosevkaTerm",
}


class PackageInfo(TypedDict):
    version: str
    tag: str
    url: str
    repo: str
    source: NotRequired[str]
    binary_name: NotRequired[str]
    archive_binary_name: NotRequired[str]
    extract_dir: NotRequired[str]


class GitHubAsset(TypedDict):
    name: str
    browser_download_url: str


class GitHubReleaseData(TypedDict):
    tag_name: str
    assets: list[GitHubAsset]
    tarball_url: str


@dataclasses.dataclass(frozen=True)
class GitHubRelease:
    repo: str  # e.g., "sharkdp/fd"
    version_pattern: str | None = (
        None  # regex to match version in tag, e.g., r"v(\d+\.\d+\.\d+)"
    )
    asset_pattern: str | None = (
        None  # pattern to match asset name with {version} and {arch} placeholders
    )
    binary_name: str | None = None  # name of the binary in the archive
    archive_binary_name_pattern: str | None = None  # actual binary name inside archive
    extract_dir_pattern: str | None = (
        None  # pattern for directory in archive with {version} and {arch} placeholders
    )
    extra_dirs: list[tuple[str, str]] | None = (
        None  # list of (src_pattern, dest) dirs to copy; src relative to extract_dir, dest relative to ~/.local/
    )
    install: Callable[[str, "PackageInfo", Path], None] | None = (
        None  # custom installer; if set, takes over after archive extraction
    )


def install_zed(name: str, info: "PackageInfo", tmpdir: Path) -> None:
    """Install Zed as an app bundle under ~/.local/zed.app, with a binary
    symlink and a path-patched .desktop file."""
    local_prefix = LOCAL_BIN.parent  # ~/.local
    bundle = local_prefix / "zed.app"
    if bundle.exists():
        shutil.rmtree(bundle)
    shutil.copytree(tmpdir / "zed.app", bundle)
    ensure_symlink(bundle / "bin" / "zed", LOCAL_BIN / "zed")

    appid = "dev.zed.Zed"
    desktop_src = bundle / "share/applications" / f"{appid}.desktop"
    desktop_dst = local_prefix / "share/applications" / f"{appid}.desktop"
    desktop_dst.parent.mkdir(parents=True, exist_ok=True)
    icon = bundle / "share/icons/hicolor/512x512/apps/zed.png"
    text = desktop_src.read_text()
    text = text.replace("Icon=zed", f"Icon={icon}")
    text = text.replace("Exec=zed", f"Exec={bundle / 'bin/zed'}")
    desktop_dst.write_text(text)


def install_hunk(name: str, info: "PackageInfo", tmpdir: Path) -> None:
    # The hunk binary resolves its own path and loads skills/hunk-review/SKILL.md
    # relative to it, so the binary and skills/ dir must live together.
    local_prefix = LOCAL_BIN.parent  # ~/.local
    bundle = local_prefix / "hunk"
    extract_dir = tmpdir / info["extract_dir"]
    if bundle.exists():
        shutil.rmtree(bundle)
    shutil.copytree(extract_dir, bundle)
    chmod_x(bundle / "hunk")
    ensure_symlink(bundle / "hunk", LOCAL_BIN / "hunk")


def install_marktext(name: str, info: "PackageInfo", tmpdir: Path) -> None:
    # MarkText is an Electron bundle: the binary must stay with its resources.
    # The bundled chrome-sandbox isn't setuid-root after a home-dir extract, so
    # a bare launch aborts; a wrapper on PATH and the .desktop both pass
    # --no-sandbox so both CLI and GUI launches work.
    local_prefix = LOCAL_BIN.parent  # ~/.local
    bundle = local_prefix / "marktext"
    extract_dir = tmpdir / info["extract_dir"]
    if bundle.exists():
        shutil.rmtree(bundle)
    shutil.copytree(extract_dir, bundle)
    chmod_x(bundle / "marktext")

    launcher = LOCAL_BIN / "marktext"
    if launcher.exists() or launcher.is_symlink():
        launcher.unlink()
    launcher.write_text(f'#!/bin/sh\nexec "{bundle / "marktext"}" --no-sandbox "$@"\n')
    chmod_x(launcher)

    icon = bundle / "resources/static/icon.png"
    desktop_dst = local_prefix / "share/applications" / "marktext.desktop"
    desktop_dst.parent.mkdir(parents=True, exist_ok=True)
    desktop_dst.write_text(
        "[Desktop Entry]\n"
        "Name=MarkText\n"
        "Comment=Next generation markdown editor\n"
        f"Exec={launcher} %F\n"
        f"Icon={icon}\n"
        "Terminal=false\n"
        "Type=Application\n"
        "Categories=Office;TextEditor;Utility;\n"
        "MimeType=text/markdown;\n"
        "StartupWMClass=marktext\n"
    )


GITHUB_RELEASES = {
    "codex": GitHubRelease(
        repo="openai/codex",
        version_pattern=r"rust-v(\d+\.\d+\.\d+)",
        asset_pattern="codex-{arch}-unknown-linux-musl.tar.gz",
        binary_name="codex",
        archive_binary_name_pattern="codex-{arch}-unknown-linux-musl",
    ),
    "fnm": GitHubRelease(
        repo="Schniz/fnm",
        asset_pattern="fnm-linux.zip",
        binary_name="fnm",
    ),
    "fzf": GitHubRelease(
        repo="junegunn/fzf",
        asset_pattern="fzf-{version}-linux_amd64.tar.gz",
        binary_name="fzf",
    ),
    "direnv": GitHubRelease(
        repo="direnv/direnv",
        asset_pattern="direnv.linux-amd64",
        binary_name="direnv",
    ),
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
    "difft": GitHubRelease(
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
    "iosevkaterm": GitHubRelease(
        repo="ryanoasis/nerd-fonts",
        asset_pattern="IosevkaTerm.zip",
    ),
    "btm": GitHubRelease(
        repo="ClementTsang/bottom",
        asset_pattern="bottom_{arch}-unknown-linux-gnu.tar.gz",
        binary_name="btm",
    ),
    "tree-sitter": GitHubRelease(
        repo="tree-sitter/tree-sitter",
        asset_pattern="tree-sitter-linux-x64.gz",
        binary_name="tree-sitter",
    ),
    "clangd": GitHubRelease(
        repo="clangd/clangd",
        asset_pattern="clangd-linux-{version}.zip",
        binary_name="clangd",
        extract_dir_pattern="clangd_{version}/bin",
        extra_dirs=[("../lib", "lib")],
    ),
    "zed": GitHubRelease(
        repo="zed-industries/zed",
        asset_pattern="zed-linux-{arch}.tar.gz",
        binary_name="zed",
        install=install_zed,
    ),
    "marktext": GitHubRelease(
        repo="marktext/marktext",
        asset_pattern="marktext-linux-{version}.tar.gz",
        binary_name="marktext",
        extract_dir_pattern="marktext-linux-{version}",
        install=install_marktext,
    ),
    "typst": GitHubRelease(
        repo="typst/typst",
        asset_pattern="typst-{arch}-unknown-linux-musl.tar.xz",
        binary_name="typst",
        extract_dir_pattern="typst-{arch}-unknown-linux-musl",
    ),
    "atuin": GitHubRelease(
        repo="atuinsh/atuin",
        asset_pattern="atuin-{arch}-unknown-linux-gnu.tar.gz",
        binary_name="atuin",
        extract_dir_pattern="atuin-{arch}-unknown-linux-gnu",
    ),
    "zoxide": GitHubRelease(
        repo="ajeetdsouza/zoxide",
        asset_pattern="zoxide-{version}-{arch}-unknown-linux-musl.tar.gz",
        binary_name="zoxide",
    ),
    "just": GitHubRelease(
        repo="casey/just",
        asset_pattern="just-{version}-{arch}-unknown-linux-musl.tar.gz",
        binary_name="just",
    ),
    "hunk": GitHubRelease(
        repo="modem-dev/hunk",
        asset_pattern="hunkdiff-linux-{arch_short}.tar.gz",
        binary_name="hunk",
        extract_dir_pattern="hunkdiff-linux-{arch_short}",
        install=install_hunk,
    ),
    "rclone": GitHubRelease(
        repo="rclone/rclone",
        asset_pattern="rclone-v{version}-linux-amd64.zip",
        binary_name="rclone",
        extract_dir_pattern="rclone-v{version}-linux-amd64",
    ),
}


def github_token() -> str | None:
    """A GitHub token from the environment, if set. Raises the API rate limit
    from 60 to 5000 requests/hour when present."""
    return os.environ.get("GITHUB_TOKEN") or os.environ.get("GH_TOKEN")


def fetch_latest_release(repo: str) -> GitHubReleaseData:
    """Fetch the latest release info from GitHub API."""
    url = f"https://api.github.com/repos/{repo}/releases/latest"

    request = urllib.request.Request(url)
    request.add_header("Accept", "application/vnd.github+json")
    request.add_header("X-GitHub-Api-Version", "2022-11-28")
    token = github_token()
    if token:
        request.add_header("Authorization", f"Bearer {token}")

    try:
        with urllib.request.urlopen(request) as response:
            return cast(GitHubReleaseData, json.loads(response.read().decode()))
    except urllib.error.HTTPError as e:
        print(f"Error fetching release for {repo}: {e}")
        if e.code in (403, 429) and not github_token():
            print(
                "  Looks like a rate limit (60 req/hour unauthenticated). "
                "Set GITHUB_TOKEN to raise it to 5000/hour."
            )
        raise


def extract_version_from_tag(tag: str, pattern: str | None = None) -> str:
    """Extract version from git tag."""
    if pattern:
        match = re.search(pattern, tag)
        if match:
            return match.group(1)

    # Default: remove leading 'v' if present
    return tag.lstrip("v")


def find_matching_asset(
    assets: list[GitHubAsset], pattern: str, version: str
) -> str | None:
    """Find asset URL matching the pattern for current architecture."""
    # Try both spellings of the machine arch for the {arch} placeholder.
    for arch in (ARCH, ARCH_ALT):
        pattern_filled = fill(pattern, version, arch=arch)
        for asset in assets:
            if asset["name"] == pattern_filled:
                return asset["browser_download_url"]

    return None


def update_lock_file() -> None:
    """Fetch latest releases and update the lock file."""
    lock_data: dict[str, PackageInfo] = {}
    dep_names = {d.name for d in DEPS}

    for name, release_info in GITHUB_RELEASES.items():
        if name not in dep_names:
            continue
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
                lock_data[name]["binary_name"] = fill(release_info.binary_name, version)

            if release_info.extract_dir_pattern:
                lock_data[name]["extract_dir"] = fill(
                    release_info.extract_dir_pattern, version
                )

            if release_info.archive_binary_name_pattern:
                lock_data[name]["archive_binary_name"] = fill(
                    release_info.archive_binary_name_pattern, version
                )

            if release_info.extra_dirs:
                lock_data[name]["extra_dirs"] = release_info.extra_dirs

            print(f"✓ {name}: {version}")

        except Exception as e:
            print(f"✗ Failed to fetch {name}: {e}")
            continue

    with open(LOCK_FILE, "w") as f:
        json.dump(lock_data, f, indent=2)

    print(f"\nLock file updated: {LOCK_FILE}")


def load_lock_file() -> dict[str, PackageInfo]:
    if not LOCK_FILE.exists():
        print(f"Lock file not found. Run with --update-lock to create it.")
        sys.exit(1)

    with open(LOCK_FILE) as f:
        return cast(dict[str, PackageInfo], json.load(f))


def download_with_progress(url: str, fname: str) -> None:
    def reporthook(block_num: int, block_size: int, total_size: int) -> None:
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


@contextlib.contextmanager
def download_to_tempdir(url: str) -> Generator[Path, None, None]:
    """Download a single file to a temp dir and yield its path."""
    with tempfile.TemporaryDirectory() as tmpdir:
        fpath = Path(tmpdir) / url_filename(url)
        download_with_progress(url, str(fpath))
        yield fpath


@contextlib.contextmanager
def extract_and_download(url: str) -> Generator[Path, None, None]:
    """Download an archive and yield the temp dir it was extracted into."""
    with download_to_tempdir(url) as fpath:
        name = fpath.name
        if name.endswith((".tar.gz", ".tar.xz")):
            mode = "r:gz" if name.endswith(".tar.gz") else "r:xz"
            with tarfile.open(fpath, mode) as tar:
                tar.extractall(path=fpath.parent, filter="data")
        elif name.endswith(".zip"):
            with zipfile.ZipFile(fpath, "r") as zip_ref:
                zip_ref.extractall(fpath.parent)
        yield fpath.parent


def run(cmd: list[str]) -> str:
    try:
        r = subprocess.run(cmd, capture_output=True)
    except FileNotFoundError:
        return ""
    if r.returncode != 0:
        return ""
    return r.stdout.decode("utf-8")


@dataclasses.dataclass(frozen=True)
class Check:
    cmd: list[str]
    # Regex (one capture group) for the version in the first line of `cmd`'s
    # output. For lockfile tools, None falls back to a generic "\d+.\d+.\d+"
    # (see query_version); for system deps, None just prints the raw line.
    pattern: str | None = None


def extract_version(output: str, pattern: str | None = None) -> str:
    """Pull a version out of command/tag output via `pattern` (group 1)."""
    match = re.search(pattern or r"(\d+\.\d+\.\d+)", output)
    assert match, f"could not parse version from: {output!r}"
    return match.group(1)


def query_version(check: "Check") -> str | None:
    """Run `check.cmd` and return its extracted version, or None if not found."""
    output = run(check.cmd)
    if not output:
        return None
    return extract_version(output.splitlines()[0], check.pattern)


# System tools provided by the package manager (version-checked, not installed).
SYSTEM_DEPS: dict[str, Check] = {
    "git": Check(["git", "--version"]),
    "uv": Check(["uv", "--version"]),
    "zsh": Check(["zsh", "--version"]),
    "wget": Check(["wget", "--version"]),
    "curl": Check(["curl", "--version"], pattern=r"curl (\d+\.\d+\.\d+)"),
    "npm": Check(["npm", "--version"]),
    "rg": Check(["rg", "--version"]),
    "tmux": Check(["tmux", "-V"]),
}

# Tools installed from install.lock.json, all checked with `<tool> --version`.
LOCKFILE_TOOL_NAMES = [
    "nvim", "lazygit", "difft", "fd", "hyperfine", "bat", "delta", "codex",
    "fnm", "fzf", "direnv", "btm", "tree-sitter", "clangd", "zed", "marktext",
    "typst", "atuin", "zoxide", "just", "hunk", "rclone",
]  # fmt: skip

# Override the version regex only where the first "\d+.\d+.\d+" in the
# --version output isn't the tool's own version.
LOCKFILE_PATTERNS = {"lazygit": r"version=(\d+\.\d+\.\d+)"}

LOCKFILE_TOOLS: dict[str, Check] = {
    name: Check([name, "--version"], pattern=LOCKFILE_PATTERNS.get(name))
    for name in LOCKFILE_TOOL_NAMES
}


def install_font(font_name: str) -> bool:
    """Install a single Nerd Font from the lock file."""
    lock = load_lock_file()

    if font_name not in lock:
        print(f"{font_name} not found in lock file")
        return False

    package_info = lock[font_name]
    url = package_info["url"]
    zip_filename = url_filename(url)
    LOCAL_FONTS.mkdir(parents=True, exist_ok=True)

    print(f"Installing {font_name} font...")
    download_with_progress(url, zip_filename)

    with zipfile.ZipFile(zip_filename, "r") as zip_ref:
        zip_ref.extractall(LOCAL_FONTS)

    os.remove(zip_filename)
    return True


def install_fonts(font_names: list[str]) -> None:
    """Install the listed Nerd Fonts (lock-file keys, e.g. 'firacode')."""
    any_installed = False
    for font in font_names:
        if install_font(font):
            any_installed = True

    if any_installed:
        print("Refreshing font cache...")
        subprocess.run(["fc-cache", "-f", "-v"], cwd=LOCAL_FONTS)


def chmod_x(fname: Path) -> None:
    current_permissions = os.stat(fname).st_mode
    new_permissions = current_permissions | 0o111
    os.chmod(fname, new_permissions)


def install_from_lock(package_name: str) -> None:
    lock = load_lock_file()

    if package_name not in lock:
        print(f"{package_name} not found in lock file")
        return

    package_info = lock[package_name]
    url = package_info["url"]

    # Custom installer (e.g. app bundles): takes over after archive extraction.
    release = GITHUB_RELEASES.get(package_name)
    if release is not None and release.install is not None:
        with extract_and_download(url) as tmpdir:
            release.install(package_name, package_info, tmpdir)
        return

    # Special case for appimage
    if url.endswith(".appimage"):
        with download_to_tempdir(url) as fpath:
            dest = LOCAL_BIN / fpath.name
            shutil.copy(fpath, dest)
            chmod_x(dest)

            # Create symlink without .appimage extension
            binary_link = LOCAL_BIN / package_name
            ensure_symlink(dest, binary_link)
            chmod_x(binary_link)
        return

    # Non-archive downloads: a bare binary, or a single gzip-compressed one
    # (e.g. tree-sitter-linux-x64.gz). Appimages were already handled above.
    if not url.endswith((".tar.gz", ".tar.xz", ".zip", ".tgz")):
        with download_to_tempdir(url) as fpath:
            dest = LOCAL_BIN / package_info.get("binary_name", package_name)
            if url.endswith(".gz"):
                with gzip.open(fpath, "rb") as f_in, open(dest, "wb") as f_out:
                    shutil.copyfileobj(f_in, f_out)
            else:
                shutil.copy(fpath, dest)
            chmod_x(dest)
        return

    # Regular archive extraction
    with extract_and_download(url) as tmpdir:
        binary_name = package_info.get("binary_name", package_name)
        archive_binary_name = package_info.get("archive_binary_name", binary_name)

        # Check if there's an extract_dir
        if "extract_dir" in package_info:
            bin_path = tmpdir / package_info["extract_dir"] / archive_binary_name
        else:
            bin_path = tmpdir / archive_binary_name

        if not bin_path.exists():
            # Try to find the binary in tmpdir
            print(f"Binary not found at expected path: {bin_path}")
            print(f"Contents of {tmpdir}:")
            subprocess.call(f"ls -la {tmpdir}", shell=True)

            # Try to find it recursively
            for root, dirs, files in os.walk(tmpdir):
                if archive_binary_name in files:
                    bin_path = Path(root) / archive_binary_name
                    print(f"Found binary at: {bin_path}")
                    break

        if bin_path.exists():
            dest_path = LOCAL_BIN / binary_name
            shutil.copy(bin_path, dest_path)
            chmod_x(dest_path)
        else:
            print(f"Could not find binary {binary_name} for {package_name}")

        # Copy extra directories (e.g., clangd lib/ with built-in headers)
        if "extra_dirs" in package_info:
            local_prefix = LOCAL_BIN.parent  # ~/.local
            extract_base = (
                tmpdir / package_info["extract_dir"]
                if "extract_dir" in package_info
                else tmpdir
            )
            for src_rel, dest_rel in package_info["extra_dirs"]:
                src_path = (extract_base / src_rel).resolve()
                dest_path = local_prefix / dest_rel
                if src_path.is_dir():
                    if dest_path.exists():
                        shutil.rmtree(dest_path)
                    shutil.copytree(src_path, dest_path)
                    print(f"  Copied {src_rel} -> {dest_path}")
                else:
                    print(f"  Warning: extra dir {src_path} not found")


def get_installed_font_version(font_name: str) -> str | None:
    """Extract the Nerd Fonts version from an installed font file."""
    # Map lock file names to font file patterns
    font_patterns = {
        "firacode": "FiraCode*NerdFont-Regular.ttf",
        "iosevkaterm": "IosevkaTerm*NerdFont-Regular.ttf",
    }

    if font_name not in font_patterns:
        return None

    # Find a font file for this font family
    font_files = list(LOCAL_FONTS.glob(font_patterns[font_name]))
    if not font_files:
        return None

    # Extract version from font file using strings
    result = subprocess.run(
        ["strings", str(font_files[0])], capture_output=True, text=True
    )

    for line in result.stdout.splitlines():
        if line.startswith("Version") and "Nerd Fonts" in line:
            # Extract version like "3.4.0" from "Version 6.002;Nerd Fonts 3.4.0"
            parts = line.split("Nerd Fonts")
            if len(parts) > 1:
                return parts[1].strip()

    return None


def query_fonts_installed(font_patterns: list[str]) -> bool:
    """Check if fonts matching any of the patterns are installed."""
    result = subprocess.run(
        ["fc-list", ":family"], capture_output=True, text=True, check=True
    ).stdout

    for pattern in font_patterns:
        matching_fonts = [line for line in result.splitlines() if pattern in line]
        if matching_fonts:
            print(Fore.GREEN + f"{pattern} fonts found" + Fore.RESET)
        else:
            return False

    return True


def ensure_symlink(src: Path, dst: Path) -> None:
    if dst.exists() and dst.is_symlink() and dst.resolve() == src:
        print(Fore.GREEN + f"symlink {dst} -> {src} already exists" + Fore.RESET)
    else:
        if dst.exists() or dst.is_symlink():
            print(f"removing existing {dst}")
            dst.unlink()
        print(f"creating symlink {dst} -> {src}")
        dst.symlink_to(src)


def validate_deps() -> None:
    """Sanity-check DEPS against the HOW dicts.

    Every dep must be defined in exactly one of SYSTEM_DEPS / LOCKFILE_TOOLS / FONTS,
    and every lockfile tool must have a matching GITHUB_RELEASES entry.
    """
    seen: dict[str, str] = {}
    for src, names in [
        ("SYSTEM_DEPS", SYSTEM_DEPS.keys()),
        ("LOCKFILE_TOOLS", LOCKFILE_TOOLS.keys()),
        ("fonts", FONTS.keys()),
    ]:
        for n in names:
            assert n not in seen, f"{n!r} defined in both {seen[n]} and {src}"
            seen[n] = src

    dep_names = {d.name for d in DEPS}
    missing = seen.keys() - dep_names
    extra = dep_names - seen.keys()
    assert not missing and not extra, (
        f"DEPS mismatch: missing in DEPS={sorted(missing)}, "
        f"extra in DEPS (no HOW)={sorted(extra)}"
    )

    missing_gh = LOCKFILE_TOOLS.keys() - GITHUB_RELEASES.keys()
    assert not missing_gh, (
        f"LOCKFILE_TOOLS without GITHUB_RELEASES entry: {sorted(missing_gh)}"
    )


def show_lock_file() -> None:
    """Display lock file contents in a readable format."""
    if not LOCK_FILE.exists():
        print(f"Lock file not found at {LOCK_FILE}")
        print("Run with --update-lock to create it")
        sys.exit(1)

    lock = load_lock_file()

    print(f"\nLock file: {LOCK_FILE}")
    print(f"{'=' * 80}\n")

    M = max(len(name) for name in lock.keys())

    for name, info in sorted(lock.items()):
        version = info.get("version", "unknown")
        source = info.get("source", "github")
        repo = info.get("repo", "")
        label = f"PyPI" if source == "pypi" else repo
        print(f"{Fore.CYAN}{name:<{M}}{Fore.RESET} : v{version:<10} ({label})")

    print()


def check_versions() -> None:
    """Compare installed versions with lock file versions."""
    lock = load_lock_file()
    active = {d.name for d in DEPS if d.applies_here()}

    print(f"\nVersion Check (Installed vs Locked)")
    print(f"{'=' * 80}\n")

    M = max(len(name) for name in lock.keys())
    outdated: list[str] = []
    up_to_date: list[str] = []
    not_installed: list[str] = []

    def report(name: str, installed: str | None, locked: str) -> None:
        if installed is None:
            not_installed.append(name)
            print(
                f"{Fore.RED}{name:<{M}}{Fore.RESET} : NOT INSTALLED (locked: v{locked})"
            )
        elif installed == locked:
            up_to_date.append(name)
            print(f"{Fore.GREEN}{name:<{M}}{Fore.RESET} : v{installed} ✓")
        else:
            outdated.append(name)
            print(f"{Fore.YELLOW}{name:<{M}}{Fore.RESET} : v{installed} → v{locked}")

    for name, info in sorted(lock.items()):
        if name not in active:
            continue
        locked_version = info.get("version", "unknown")
        if name in FONTS:
            report(name, get_installed_font_version(name), locked_version)
        elif name in LOCKFILE_TOOLS:
            report(name, query_version(LOCKFILE_TOOLS[name]), locked_version)

    print(f"\n{'=' * 80}")
    print(
        f"Summary: {Fore.GREEN}{len(up_to_date)} up-to-date{Fore.RESET}, "
        f"{Fore.YELLOW}{len(outdated)} outdated{Fore.RESET}, "
        f"{Fore.RED}{len(not_installed)} not installed{Fore.RESET}\n"
    )

    if outdated or not_installed:
        print("Run './install.py' to install missing or update outdated tools")


def main() -> None:
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

    active = {d.name for d in DEPS if d.applies_here()}

    # Check if fonts are installed
    active_fonts = [n for n in FONTS if n in active]
    required_font_patterns = [FONTS[n] for n in active_fonts]
    if required_font_patterns and not query_fonts_installed(required_font_patterns):
        install_fonts(active_fonts)

    lock = load_lock_file()

    validate_deps()

    M = max(len(name) for name in [*SYSTEM_DEPS, *LOCKFILE_TOOLS])
    failed = False

    # System dependencies (informational only — installed by the package manager)
    for name, check in SYSTEM_DEPS.items():
        if name not in active:
            continue
        output = run(check.cmd)
        if not output:
            print(Fore.RED + f"{name:<{M}} : not found" + Fore.RESET)
            failed = True
        else:
            line = output.splitlines()[0]
            version = extract_version(line, check.pattern) if check.pattern else line
            print(Fore.GREEN + f"{name:<{M}} : {version}" + Fore.RESET)

    # Check and install/update lockfile-managed tools
    for name, check in LOCKFILE_TOOLS.items():
        if name not in active:
            continue
        if name not in lock:
            print(
                Fore.YELLOW + f"{name:<{M}} : not in lock file, skipping" + Fore.RESET
            )
            continue

        locked = lock[name].get("version", "unknown")
        installed = query_version(check)

        if installed is None:
            print(
                Fore.YELLOW
                + f"{name:<{M}} : not found, installing v{locked}"
                + Fore.RESET
            )
        elif installed != locked:
            print(
                Fore.YELLOW
                + f"{name:<{M}} : v{installed} → v{locked}, updating"
                + Fore.RESET
            )
        else:
            print(Fore.GREEN + f"{name:<{M}} : {installed} ✓" + Fore.RESET)
            continue

        install_from_lock(name)
        installed = query_version(check)
        if installed:
            print(Fore.GREEN + f"{name:<{M}} : {installed} ✓" + Fore.RESET)

    print()

    if failed:
        print("Check failed.")
        sys.exit(1)


if __name__ == "__main__":
    main()
