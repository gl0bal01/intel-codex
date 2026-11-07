---
title: "CTF Essential Tools Setup Guide"
description: "CTF tools setup for Kali, Debian 13 & Ubuntu 24.04: venv/pipx Python (PEP 668), Burp, sqlmap, Ghidra (JDK 25), pwndbg, ROP & libc helpers, binwalk v3, stego, memory & disk forensics, APK tools."
tags:
  - ctf
  - tools
  - setup
  - environment
  - guide
updated: 2026-11-07
---

# 🔧 CTF Essential Tools Setup Guide

## 🐧 Operating System Setup

### Recommended Distributions
1. **Exegol** - Containerized environments for professionals, students, CTF players, bug hunters, researchers
2. **Kali Linux** / **Parrot OS** - Pre-installed security tools
3. **Ubuntu/Debian** - Build your own toolkit
4. **Windows + WSL2** - For Windows users

> Exegol and Kali already ship most tools below. Commands target Kali rolling, Debian 13 and Ubuntu 24.04; "Kali only" marks packages Debian/Ubuntu don't have.

### Virtual Machine Setup
```text
# Recommended VM specs
RAM: 8GB minimum, 16GB preferred
Storage: 100GB minimum
CPU: 4 cores minimum
```

---

## 📁 Environment Setup

### Directory Structure
```bash
mkdir -p ~/ctf/{tools,challenges,writeups,scripts}
mkdir -p ~/ctf/challenges/{crypto,web,pwn,rev,forensics,misc}
```

### Python: one venv + pipx
Debian 12+, Ubuntu 23.04+ and Kali block system-wide `pip install`, `--user` included (PEP 668, `externally-managed-environment`). Libraries go in one venv; standalone CLI tools go in `pipx`. Never `sudo pip`.

```bash
sudo apt install python3-venv python3-dev pipx build-essential libssl-dev libffi-dev
python3 -m venv ~/ctf/venv
. ~/ctf/venv/bin/activate          # add this line to ~/.zshrc / ~/.bashrc
pipx ensurepath                    # puts ~/.local/bin on PATH (pipx tools, pwndbg, pwninit)
```

Every `pip install` below assumes `~/ctf/venv` is active.

### Shell Configuration (.bashrc/.zshrc)
Aliases: [gl0bal01/exegol-config - zsh aliases](https://github.com/gl0bal01/exegol-config/blob/master/my-resources/setup/zsh/aliases)

---

## 🌐 Web Exploitation Tools

### Burp Suite Community
```bash
sudo apt install burpsuite        # Kali
# Elsewhere: run the Linux installer from https://portswigger.net/burp/communitydownload
```

### OWASP ZAP
```bash
sudo apt install zaproxy          # Kali only
# Elsewhere: https://www.zaproxy.org/download/
```

### Web Utilities
```bash
# Essential web tools
sudo apt install curl wget httpie
pip install requests beautifulsoup4 selenium

# Browsers (Debian/Kali names; on Ubuntu, apt's firefox/chromium-browser only install the snap)
sudo apt install firefox-esr chromium
```

### SQL Injection
```bash
sudo apt install sqlmap
```

### Directory & File Discovery / Fuzzing
```bash
sudo apt install gobuster dirb ffuf

# Feroxbuster (Rust, recursive) - Kali: sudo apt install feroxbuster
curl -sL https://raw.githubusercontent.com/epi052/feroxbuster/main/install-nix.sh | bash -s "$HOME/.local/bin"
```

### Wordlists
```bash
sudo apt install seclists        # Kali only -> /usr/share/seclists
# Elsewhere: same path, from git
sudo git clone --depth 1 https://github.com/danielmiessler/SecLists.git /usr/share/seclists
```

### Recon & Scanning
```bash
sudo apt install whatweb             # fingerprint the web stack

# Nikto - Kali: sudo apt install nikto (2.6.1); Debian non-free / Ubuntu multiverse ship 2.1.5
git clone https://github.com/sullo/nikto ~/ctf/tools/nikto
~/ctf/tools/nikto/program/nikto.pl -h http://target.com
```

### JWT
```bash
# jwt_tool (no distro package; Kali's jwt-tools is libjwt's CLI, a different tool)
git clone https://github.com/ticarpi/jwt_tool ~/ctf/tools/jwt_tool
pip install -r ~/ctf/tools/jwt_tool/requirements.txt    # into ~/ctf/venv
python3 ~/ctf/tools/jwt_tool/jwt_tool.py "$JWT"
```

---

## 🔐 Cryptography Tools

### CyberChef
```bash
# Web-based: https://gchq.github.io/CyberChef/
sudo apt install cyberchef        # Kali: offline copy
# Elsewhere offline: release zip from https://github.com/gchq/CyberChef/releases
```

### Python Crypto Libraries
```bash
pip install pycryptodome cryptography sympy gmpy2

# SageMath (there is no "sage-math" pip package)
sudo apt install sagemath                  # Kali; not packaged in Debian 13 / Ubuntu 24.04
conda create -n sage sage python=3.13      # elsewhere: conda-forge (official route)
```

### RsaCtfTool
```bash
git clone https://github.com/RsaCtfTool/RsaCtfTool ~/ctf/tools/RsaCtfTool
cd ~/ctf/tools/RsaCtfTool && python3 -m venv venv && venv/bin/pip install -e .
~/ctf/tools/RsaCtfTool/venv/bin/RsaCtfTool --help
```

### Command Line Tools
```bash
# OpenSSL
sudo apt install openssl

# Hash cracking
sudo apt install hashcat john

# Hash identification: name-that-hash (`nth`) - Kali: sudo apt install name-that-hash
pipx install name-that-hash
```

### Crypto Scripts
```python
# ~/ctf/scripts/crypto_utils.py
import base64
import binascii
import urllib.parse
from Crypto.Util.number import *
from Crypto.Cipher import AES

def decode_common(data):
    """Try common encoding schemes"""
    encodings = [
        ('base64', base64.b64decode),
        ('hex', binascii.unhexlify),
        ('url', urllib.parse.unquote)
    ]

    for name, decoder in encodings:
        try:
            result = decoder(data)
            print(f"{name}: {result}")
        except Exception:
            continue
```

---

## 💾 Binary Analysis & Reverse Engineering

### Disassemblers
```bash
# Ghidra 12.2 needs JDK 25
sudo apt install ghidra                    # Kali (pulls openjdk-25-jdk)
# Elsewhere: JDK 25 + release zip from https://github.com/NationalSecurityAgency/ghidra/releases
sudo apt install openjdk-25-jdk            # Debian 13, Ubuntu 24.04 (noble-updates)
unzip ghidra_*_PUBLIC_*.zip -d ~/ctf/tools && ~/ctf/tools/ghidra_*_PUBLIC/ghidraRun

# Radare2 - Kali/Ubuntu: sudo apt install radare2 (not in Debian 13); upstream recommends git
git clone https://github.com/radareorg/radare2 ~/ctf/tools/radare2 && ~/ctf/tools/radare2/sys/install.sh

# Binary Ninja (commercial, has free version)
# Download from https://binary.ninja/
```

### Debuggers
```bash
sudo apt install gdb

# pwndbg - official installer, user install; run `pwndbg` instead of `gdb`
curl --proto '=https' --tlsv1.2 -LsSf 'https://install.pwndbg.re' | sh -s -- -t pwndbg-gdb -u

# Alternative: GEF (loaded by plain gdb)
wget -O ~/.gdbinit-gef.py -q https://gef.blah.cat/py
echo source ~/.gdbinit-gef.py >> ~/.gdbinit
```

### Binary Utilities
```bash
# binutils = strings, objdump, readelf, nm; bsdextrautils = hexdump
sudo apt install binutils file bsdextrautils xxd
sudo apt install ltrace strace  # Library / system call tracers
pipx install binary-refinery
```

### Pwn Helpers
```bash
# ROP gadgets (pwntools already pulls ROPgadget into ~/ctf/venv)
pipx install ROPGadget ropper

# checksec (pwntools also ships `checksec` / `pwn checksec`); patchelf for swapping libc/ld
sudo apt install checksec patchelf

# pwninit: fetches matching ld + libc debug symbols, patchelfs the binary, writes solve.py
curl -fL --create-dirs -o ~/.local/bin/pwninit https://github.com/io12/pwninit/releases/latest/download/pwninit
chmod +x ~/.local/bin/pwninit

# one_gadget (execve gadgets in libc), seccomp-tools (dump/disasm seccomp filters)
sudo apt install ruby ruby-dev gcc make
sudo gem install one_gadget seccomp-tools
```

### Symbolic Execution & Solvers
```bash
pip install z3-solver

# angr: own venv (angr docs recommend isolation); Python >= 3.12
python3 -m venv ~/ctf/venv-angr && ~/ctf/venv-angr/bin/pip install angr
```

### Android / APK
```bash
sudo apt install apktool           # decode/rebuild resources + smali
sudo apt install jadx              # Kali; elsewhere zip from https://github.com/skylot/jadx/releases (Java 11+)
```

---

## 🕵️ Forensics Tools

### File Analysis
```bash
# File identification
sudo apt install file

# Hex editors (TUI / GUI)
sudo apt install hexedit ghex

# Foremost for file carving
sudo apt install foremost
```

### Binwalk
```bash
sudo apt install binwalk     # v2.x (2.4.3 Debian/Kali, 2.3.4 Ubuntu 24.04): binwalk -e fw.bin -> ./_fw.bin.extracted/
sudo apt install binwalk3    # Kali: v3 (Rust rewrite), command is `binwalk3`
cargo install binwalk        # v3 elsewhere; extractor dependencies not included
```

v3 (3.1.0): `-e` and `-Me` still extract, but output lands in `./extractions/fw.bin.extracted/` (`--directory` to change). Docs: [binwalk wiki](https://github.com/ReFirmLabs/binwalk/wiki).

### Image Forensics
```bash
# Steganography
sudo apt install steghide stegseek     # stegseek: fast steghide cracker (replaces stegcracker)
sudo gem install zsteg                 # PNG/BMP LSB detection (needs ruby, see Pwn Helpers)
# StegSolve (bit planes): Java GUI, needs a JRE; jar not packaged by Kali/Debian

# Image analysis
sudo apt install libimage-exiftool-perl   # provides `exiftool`
pip install pillow

# Audio steganography
sudo apt install audacity
```

### Memory Analysis
```bash
# Volatility 3 - entrypoint is `vol`
pipx install volatility3

# Alternative: development version from GitHub
git clone https://github.com/volatilityfoundation/volatility3.git
```

### Disk Images
```bash
# The Sleuth Kit CLI (mmls, fls, icat, tsk_recover); apt's autopsy is the legacy 2.24 web UI
sudo apt install sleuthkit autopsy

# Partition recovery + file carving (testdisk ships photorec)
sudo apt install testdisk
```

---

## 📡 Network Analysis Tools

### Wireshark
```bash
sudo apt install wireshark tshark    # answer "Yes" to "non-superusers capture packets?"
sudo usermod -a -G wireshark $USER   # Add user to wireshark group, then log out/in
sudo dpkg-reconfigure wireshark-common   # if you answered "No" or installed non-interactively
```

### Network Utilities
```bash
# Scanning and enumeration
sudo apt install nmap zenmap ncat    # ncat: nmap's netcat, has --exec / --sh-exec
sudo apt install netcat-openbsd socat

# DNS tools (dig, nslookup)
sudo apt install bind9-dnsutils
```

### Protocol Analysis
```bash
# TShark command examples
tshark -r capture.pcap -Y "http" -T fields -e http.request.uri
tshark -r capture.pcap -Y "dns" -T fields -e dns.qry.name
```

---

## 🐍 Python Environment

### Essential Libraries
```bash
# In ~/ctf/venv (see Environment Setup)
# Core libraries
pip install requests urllib3 pycryptodome
pip install numpy matplotlib pillow

# CTF-specific (angr: own venv, see Symbolic Execution)
pip install pwntools z3-solver

# Web scraping
pip install beautifulsoup4 selenium scrapy

# Data analysis
pip install pandas jupyter
```

### Pwntools Setup
```python
# Example pwntools template
from pwn import *

# Set context
context.arch = 'amd64'
context.os = 'linux'

# Connect to target
p = remote('target.com', 1337)
# or p = process('./binary')

# Interact
p.sendline(b'input')
response = p.recvline()
p.interactive()
```

---

## 🔧 Development Tools

### Text Editors & IDEs
```bash
# Vim with plugins
sudo apt install vim
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# VS Code
# Download from https://code.visualstudio.com/
```

### Version Control
```bash
sudo apt install git
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

---

## 🐳 Docker Containers

### CTF-Ready Containers
```bash
# Kali Linux in Docker
docker run -it kalilinux/kali-rolling

# Custom CTF container
docker run -it --rm \
    -v ~/ctf:/ctf \
    -p 8080:8080 \
    ubuntu:24.04 /bin/bash
```

### Docker CTF Images
```dockerfile
# ~/ctf/Dockerfile
FROM ubuntu:24.04
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    python3 python3-venv python3-dev build-essential libssl-dev libffi-dev \
    curl wget git \
    binutils file bsdextrautils xxd \
    netcat-openbsd socat \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/venv && /opt/venv/bin/pip install pwntools requests pycryptodome
ENV PATH="/opt/venv/bin:$PATH"

WORKDIR /ctf
CMD ["/bin/bash"]
```

---

## ⚡ Quick Setup Script

```bash
#!/usr/bin/env bash
# ~/ctf/setup.sh - Quick CTF environment setup (Kali / Debian 13 / Ubuntu 24.04)
set -euo pipefail

echo "Setting up CTF environment..."

# Create directory structure
mkdir -p ~/ctf/{tools,challenges,writeups,scripts}
mkdir -p ~/ctf/challenges/{crypto,web,pwn,rev,forensics,misc}

# Install essential packages (noninteractive: wireshark keeps root-only capture, see Wireshark section)
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    python3 python3-venv python3-dev pipx build-essential libssl-dev libffi-dev \
    git curl wget \
    file binutils bsdextrautils xxd hexedit \
    netcat-openbsd socat \
    nmap wireshark tshark \
    gobuster dirb ffuf sqlmap \
    hashcat john gdb

# Python packages in a venv (PEP 668)
python3 -m venv ~/ctf/venv
~/ctf/venv/bin/pip install \
    pwntools requests pycryptodome \
    beautifulsoup4 pillow \
    z3-solver
pipx ensurepath

# Install pwndbg (user install -> ~/.local/bin/pwndbg)
curl --proto '=https' --tlsv1.2 -LsSf 'https://install.pwndbg.re' | sh -s -- -t pwndbg-gdb -u

echo "CTF environment setup complete!"
echo "Don't forget to:"
echo "1. Download and install Burp Suite"
echo "2. Install JDK 25 + Ghidra"
echo "3. Configure your shell aliases and activate ~/ctf/venv"
```

---

## 📋 Tool Categories Quick Reference

### By Challenge Type

| Category | Primary Tools | Secondary Tools |
|----------|---------------|-----------------|
| **Crypto** | CyberChef, Python, OpenSSL | SageMath, RsaCtfTool, Hashcat, John, name-that-hash |
| **Web** | Burp Suite, curl, Browser | ZAP, ffuf, Gobuster, sqlmap, jwt_tool, WhatWeb, Nikto, SecLists |
| **Pwn** | GDB + pwndbg, pwntools, Ghidra | ROPgadget, ropper, one_gadget, pwninit, patchelf, checksec, seccomp-tools |
| **Rev** | Ghidra, GDB, strings | Radare2, IDA, Binary Ninja, angr, z3, jadx, apktool |
| **Forensics** | Binwalk, Wireshark, file, exiftool | Volatility 3, Sleuth Kit/Autopsy, TestDisk/PhotoRec, steghide, stegseek, zsteg, StegSolve |
| **Misc** | Python, Linux utils | Custom scripts |

### Installation Priority

#### Phase 1 (Essential)
- [ ] Python 3 + venv + pipx
- [ ] Git
- [ ] Basic Linux utilities (file, binutils, bsdextrautils, xxd)
- [ ] Text editor (vim/nano/vscode)
- [ ] Web browser with dev tools

#### Phase 2 (Important)
- [ ] Burp Suite Community
- [ ] GDB + pwndbg
- [ ] Ghidra + JDK 25
- [ ] Wireshark
- [ ] Python libraries (pwntools, requests, pycryptodome)
- [ ] checksec, ROPgadget

#### Phase 3 (Advanced)
- [ ] Web: sqlmap, ffuf
- [ ] Pwn: one_gadget, pwninit, patchelf, seccomp-tools, ropper
- [ ] Crypto: RsaCtfTool, SageMath
- [ ] Forensics: stegseek, zsteg, Volatility 3, Sleuth Kit/Autopsy
- [ ] Rev/mobile: angr, jadx, apktool
- [ ] Commercial tools (if budget allows)
- [ ] Custom automation scripts

---

## 🔗 Official Resources

### Tool Websites
- **Burp Suite**: https://portswigger.net/burp
- **Ghidra**: https://ghidra-sre.org/
- **Wireshark**: https://www.wireshark.org/
- **CyberChef**: https://gchq.github.io/CyberChef/

### Documentation
- **Pwntools**: https://docs.pwntools.com/
- **pwndbg setup**: https://pwndbg.re/stable/setup/
- **Radare2**: https://book.rada.re/
- **GDB**: https://www.gnu.org/software/gdb/documentation/
- **SageMath install**: https://doc.sagemath.org/html/en/installation/

### Related Guides
[[CTF_Challenge_Methodology|Methodology]] · [[CTF_Cheat_Sheets|Cheat Sheets]] · [[sop-reverse-engineering|RE SOP]] · [[sop-forensics-investigation|Forensics SOP]]

---

**Last Updated:** 2026-11-07
