import subprocess
import dataclasses
from colorama import Fore
import shutil
import urllib.request
from pathlib import Path
import tarfile
import zipfile
import os
import sys
import tempfile

PWD = Path(__file__).parent
LOCAL_BIN = Path(os.path.expanduser("~/.local/bin"))
LOCAL_BIN.mkdir(parents=True, exist_ok=True)

def download_with_progress(url, fname):
    def reporthook(block_num, block_size, total_size):
        downloaded = block_num * block_size
        progress = downloaded / total_size * 100
        sys.stdout.write(f"\rDownloading {url}: {progress:.2f}%")
        sys.stdout.flush()
    urllib.request.urlretrieve(url, fname, reporthook)
    sys.stdout.write("\n")

def mkpath(s: str) -> Path:
    return Path(os.path.expanduser(s))

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

def install_fonts():
    url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/FiraCode.zip"
    zip_path = "FiraCode.zip"
    local_fonts = Path(os.path.expanduser("~/.local/share/fonts"))
    print(local_fonts)
    local_fonts.mkdir(parents=True, exist_ok=True)

    urllib.request.urlretrieve(url, zip_path)

    with zipfile.ZipFile(zip_path, 'r') as zip_ref:
        zip_ref.extractall(local_fonts)

    os.remove(zip_path)

    subprocess.run(["fc-cache", "-f", "-v"], cwd=local_fonts)

def install_lazygit():
    url = "https://github.com/jesseduffield/lazygit/releases/download/v0.47.2/lazygit_0.47.2_Linux_x86_64.tar.gz"
    with tempfile.TemporaryDirectory(delete=True) as tmpdir:
        fname = tmpdir + "/lazygit.tar.gz"
        download_with_progress(url, fname)
        with tarfile.open(fname, "r:gz") as tar:
            tar.extractall(path=tmpdir, filter="data")
            lazygit_binary = Path(tmpdir) / "lazygit"
            shutil.copy(lazygit_binary, LOCAL_BIN)

def install_difftastic():
    url = "https://github.com/Wilfred/difftastic/releases/download/0.63.0/difft-x86_64-unknown-linux-gnu.tar.gz"
    with tempfile.TemporaryDirectory(delete=True) as tmpdir:
        fname = tmpdir + "/lazygit.tar.gz"
        download_with_progress(url, fname)
        with tarfile.open(fname, "r:gz") as tar:
            tar.extractall(path=tmpdir, filter="data")
            bin = Path(tmpdir) / "difft"
            shutil.copy(bin, LOCAL_BIN)

def query_fira_code_fonts():
    result = subprocess.run(["fc-list", ":family"], capture_output=True, text=True, check=True).stdout
    fira_code_fonts = [line for line in result.splitlines() if "FiraCode" in line]
    if fira_code_fonts:
        print(Fore.GREEN + "FiraCode fonts found:" + Fore.RESET)
        for font in fira_code_fonts:
            print(" ",font)
        return True
    return False

def ensure_symlink(src: Path, dst: Path):
    if dst.exists() and dst.is_symlink() and dst.resolve() == src:
        print(Fore.GREEN + f"symlink {src} -> {dst} already exists" + Fore.RESET)
    else:
        print(f"creating symlink {src} -> {dst}")

def main():
    # install_lazygit()
    # install_difftastic()

    if not query_fira_code_fonts():
        install_fonts()

    required = {
        "git": Check(cmd=["git", "--version"], lines=1),
        "uv": Check(cmd=["uv", "--version"], lines=1),
        "zsh": Check(cmd=["zsh", "--version"], lines=1),
        "wget": Check(cmd=["wget", "--version"], lines=1),
        "curl": Check(cmd=["curl", "--version"], lines=1),
        "npm": Check(cmd=["npm", "--version"], lines=1),
        "fzf": Check(cmd=["fzf", "--version"], lines=1),
        "rg": Check(cmd=["rg", "--version"], lines=1),
        "tmux": Check(cmd=["tmux", "-V"], lines=1),
        "nvim": Check(cmd=["nvim", "--version"], lines=1),
        "lazygit": Check(cmd=["lazygit", "--version"], lines=1),
        "difft": Check(cmd=["difft", "--version"], lines=1)
    }

    M = max(len(name) for name in required.keys())

    failed = False

    for name, cmd in required.items():
        r = run(cmd.cmd)
        if r == "":
            print(Fore.RED + f"{name:<{M} } not found" + Fore.RESET)
            failed = True
        else:
            lines = r.splitlines()
            print(Fore.GREEN + f"{name: <{M}}: {", ".join(lines[:cmd.lines])}" + Fore.RESET)

    ensure_symlink(PWD / "zshrc", mkpath("~/.zshrc"))
    ensure_symlink(PWD / "zprofile", mkpath("~/.zprofile"))

    ensure_symlink(PWD / "nvim", mkpath("~/.config/nvim"))

    ensure_symlink(PWD / "tmux.conf", mkpath("~/.tmux.conf"))
    ensure_symlink(PWD / "tmux", mkpath("~/.tmux"))

    if failed:
        print("Check failed.")
        sys.exit(1)

if __name__ == "__main__":
    main()
