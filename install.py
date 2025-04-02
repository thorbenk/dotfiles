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

PWD = Path(__file__).parent
LOCAL_BIN = Path(os.path.expanduser("~/.local/bin"))
LOCAL_BIN.mkdir(parents=True, exist_ok=True)

ARCH = platform.machine()

FD_URL = f"https://github.com/sharkdp/fd/releases/download/v10.2.0/fd-v10.2.0-{ARCH}-unknown-linux-gnu.tar.gz"
LAZYGIT_URL = f"https://github.com/jesseduffield/lazygit/releases/download/v0.47.2/lazygit_0.47.2_Linux_{ARCH if ARCH == 'x86_64' else 'arm64'}.tar.gz"
DIFFTASTIC_URL = f"https://github.com/Wilfred/difftastic/releases/download/0.63.0/difft-{ARCH}-unknown-linux-gnu.tar.gz"
HYPERFINE_URL = f"https://github.com/sharkdp/hyperfine/releases/download/v1.19.0/hyperfine-v1.19.0-{ARCH}-unknown-linux-gnu.tar.gz"
BAT_URL = f"https://github.com/sharkdp/bat/releases/download/v0.25.0/bat-v0.25.0-{ARCH}-unknown-linux-gnu.tar.gz"
DELTA_URL = f"https://github.com/dandavison/delta/releases/download/0.18.2/delta-0.18.2-{ARCH}-unknown-linux-gnu.tar.gz"
NVIM_URL = f"https://github.com/neovim/neovim/releases/download/v0.10.4/nvim-linux-{ARCH if ARCH == 'x86_64' else 'arm64'}.appimage"


def download_with_progress(url, fname):
    def reporthook(block_num, block_size, total_size):
        downloaded = block_num * block_size
        progress = downloaded / total_size * 100
        sys.stdout.write(f"\rDownloading {url}: {progress:.2f}%")
        sys.stdout.flush()

    try:
        urllib.request.urlretrieve(url, fname, reporthook)
    except urllib.error.HTTPError as e:
        print(f"Download failed for {url}")
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
    url = (
        "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/FiraCode.zip"
    )
    zip_path = "FiraCode.zip"
    local_fonts = Path(os.path.expanduser("~/.local/share/fonts"))
    print(local_fonts)
    local_fonts.mkdir(parents=True, exist_ok=True)

    urllib.request.urlretrieve(url, zip_path)

    with zipfile.ZipFile(zip_path, "r") as zip_ref:
        zip_ref.extractall(local_fonts)

    os.remove(zip_path)

    subprocess.run(["fc-cache", "-f", "-v"], cwd=local_fonts)


def chmod_x(fname: Path):
    current_permissions = os.stat(fname).st_mode
    new_permissions = current_permissions | 0o111
    os.chmod(fname, new_permissions)


def install_nvim():
    with tempfile.TemporaryDirectory() as tmpdir:
        fname = os.path.basename(urlparse(NVIM_URL).path)
        fpath = tmpdir + "/" + fname
        download_with_progress(NVIM_URL, fpath)
        shutil.copy(fpath, LOCAL_BIN / fname)

        local_bin_nvim_appimg = LOCAL_BIN / fname
        chmod_x(local_bin_nvim_appimg)

        local_bin_nvim = LOCAL_BIN / "nvim"
        ensure_symlink(local_bin_nvim_appimg, local_bin_nvim)
        chmod_x(local_bin_nvim)


def install_lazygit():
    with extract_and_download(LAZYGIT_URL) as tmpdir:
        lazygit_binary = tmpdir / "lazygit"
        assert lazygit_binary.exists()
        shutil.copy(lazygit_binary, LOCAL_BIN)


def install_difftastic():
    with extract_and_download(DIFFTASTIC_URL) as tmpdir:
        bin = Path(tmpdir) / "difft"
        assert bin.exists()
        shutil.copy(bin, LOCAL_BIN)


def install_fd():
    with extract_and_download(FD_URL) as tmpdir:
        bin = Path(tmpdir) / f"fd-v10.2.0-{ARCH}-unknown-linux-gnu" / "fd"
        subprocess.call(f"ls {tmpdir}", shell=True)
        assert bin.exists()
        shutil.copy(bin, LOCAL_BIN)


def install_delta():
    with extract_and_download(DELTA_URL) as tmpdir:
        bin = Path(tmpdir) / f"delta-0.18.2-{ARCH}-unknown-linux-gnu" / "delta"
        subprocess.call(f"ls {tmpdir}", shell=True)
        assert bin.exists()
        shutil.copy(bin, LOCAL_BIN)


def install_bat():
    with extract_and_download(BAT_URL) as tmpdir:
        bin = Path(tmpdir) / f"bat-v0.25.0-{ARCH}-unknown-linux-gnu" / "bat"
        subprocess.call(f"ls {tmpdir}", shell=True)
        assert bin.exists()
        shutil.copy(bin, LOCAL_BIN)


def install_hyperfine():
    with extract_and_download(HYPERFINE_URL) as tmpdir:
        bin = Path(tmpdir) / f"hyperfine-v1.19.0-{ARCH}-unknown-linux-gnu" / "hyperfine"
        subprocess.call(f"ls {tmpdir}", shell=True)
        assert bin.exists()
        shutil.copy(bin, LOCAL_BIN)


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
        print(Fore.GREEN + f"symlink {src} -> {dst} already exists" + Fore.RESET)
    else:
        print(f"creating symlink {src} -> {dst}")
        dst.symlink_to(src)


def main():
    if not query_fira_code_fonts():
        install_fonts()

    required = {
        "git": Check(cmd=["git", "--version"], lines=1),
        "uv": Check(cmd=["uv", "--version"], lines=1),
        "zsh": Check(cmd=["zsh", "--version"], lines=1),
        "wget": Check(cmd=["wget", "--version"], lines=1),
        "curl": Check(cmd=["curl", "--version"], lines=1, extract_version=curl_version),
        "npm": Check(cmd=["npm", "--version"], lines=1),
        "fzf": Check(cmd=["fzf", "--version"], lines=1),
        "rg": Check(cmd=["rg", "--version"], lines=1),
        "tmux": Check(cmd=["tmux", "-V"], lines=1),
        "nvim": Check(
            cmd=["nvim", "--version"],
            lines=1,
            extract_version=nvim_version,
            install=install_nvim,
        ),
        "lazygit": Check(
            cmd=["lazygit", "--version"],
            lines=1,
            extract_version=lazygit_version,
            install=install_lazygit,
        ),
        "difft": Check(cmd=["difft", "--version"], lines=1, install=install_difftastic),
        "fd": Check(
            cmd=["fd", "--version"],
            lines=1,
            extract_version=fd_version,
            install=install_fd,
        ),
        "hyperfine": Check(
            cmd=["hyperfine", "--version"],
            lines=1,
            extract_version=hyperfine_version,
            install=install_hyperfine,
        ),
        "bat": Check(
            cmd=["bat", "--version"],
            lines=1,
            extract_version=bat_version,
            install=install_bat,
        ),
        "delta": Check(
            cmd=["delta", "--version"],
            lines=1,
            extract_version=delta_version,
            install=install_delta,
        ),
        "basedpyright": Check(
            cmd=["basedpyright", "--version"],
            lines=1,
            extract_version=basedpyright_version,
        ),
    }

    M = max(len(name) for name in required.keys())

    failed = False

    for name, cmd in required.items():
        r = run(cmd.cmd)
        if r == "":
            print(Fore.RED + f"{name:<{M}} : not found" + Fore.RESET)
            if cmd.install:
                print(f"installing {name}")
                cmd.install()
            else:
                failed = True
                continue
        else:
            r = run(cmd.cmd)
            lines = r.splitlines()
            version_str = ", ".join(lines[: cmd.lines])
            if cmd.extract_version:
                version_str = cmd.extract_version(version_str)
            print(Fore.GREEN + f"{name:<{M}} : {version_str}" + Fore.RESET)

    ensure_symlink(PWD / "zshrc", mkpath("~/.zshrc"))
    ensure_symlink(PWD / "zprofile", mkpath("~/.zprofile"))

    ensure_symlink(PWD / "nvim", mkpath("~/.config/nvim"))

    ensure_symlink(PWD / "tmux.conf", mkpath("~/.tmux.conf"))
    ensure_symlink(PWD / "tmux", mkpath("~/.tmux"))

    ZED_CONFIG = Path(os.path.expanduser("~/.config/zed"))

    ZED_CONFIG.mkdir(exist_ok=True, parents=True)

    ensure_symlink(PWD / "zed/settings.json", ZED_CONFIG / "settings.json")
    ensure_symlink(PWD / "zed/keymap.json", ZED_CONFIG / "keymap.json")

    if failed:
        print("Check failed.")
        sys.exit(1)


if __name__ == "__main__":
    main()
