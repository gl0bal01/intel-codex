---
title: "CTF Essential Tools Setup Guide"
description: "Complete CTF tools setup: Kali Linux, Burp Suite, Ghidra, Wireshark, pwntools & more. Installation scripts for web, crypto, binary & forensics tools."
---

# 🔧 CTF Essential Tools Setup Guide

## 🐧 Operating System Setup

### Recommended Distributions
1. **Exegol** - Containerized environments for professionals, students, CTF players, bug hunters, researchers
2. **Kali Linux** / **Parrot OS** - Pre-installed security tools
3. **Ubuntu/Debian** - Build your own toolkit
4. **Windows + WSL2** - For Windows users

### Virtual Machine Setup
```bash
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

### Shell Configuration (.bashrc/.zshrc)
```bash
https://github.com/gl0bal01/exegol-config/blob/master/my-resources/setup/zsh/aliases
```

---

## 🌐 Web Exploitation Tools

### Burp Suite Community
```bash
# Download from https://portswigger.net/burp/communitydownload
sudo sh burpsuite_community_linux_*.sh
```

### OWASP ZAP
```bash
sudo apt install zaproxy
# Or download from https://www.zaproxy.org/download/
```

### Web Utilities
```bash
# Essential web tools
sudo apt install curl wget httpie
pip3 install requests beautifulsoup4 selenium

# Browser automation
sudo apt install firefox chromium-browser
```

### Directory & File Discovery
```bash
# Gobuster
sudo apt install gobuster

# Dirb
sudo apt install dirb

# Feroxbuster (Rust-based, fast)
cargo install feroxbuster
```

---

## 🔐 Cryptography Tools

### CyberChef
```bash
# Web-based: https://gchq.github.io/CyberChef/
# Offline: git clone and serve locally
git clone https://github.com/gchq/CyberChef.git
```

### Python Crypto Libraries
```bash
pip3 install pycryptodome cryptography sympy gmpy2
pip3 install sage-math  # For advanced cryptography
```

### Command Line Tools
```bash
# OpenSSL
sudo apt install openssl

# Hash tools
sudo apt install hashcat john
```

### Crypto Scripts
```python
# ~/ctf/scripts/crypto_utils.py
import base64
import binascii
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
        except:
            continue
```

---

## 💾 Binary Analysis & Reverse Engineering  

### Disassemblers
```bash
# Ghidra (NSA's free tool)
# Download from https://ghidra-sre.org/

# Radare2
sudo apt install radare2

# Binary Ninja (commercial, has free version)
# Download from https://binary.ninja/
```

### Debuggers
```bash
# GDB with enhancements
sudo apt install gdb
git clone https://github.com/pwndbg/pwndbg ~/pwndbg
cd ~/pwndbg && ./setup.sh

# Alternative: GEF
git clone https://github.com/hugsy/gef ~/gef
echo "source ~/gef/gef.py" >> ~/.gdbinit
```

### Binary Utilities
```bash
# Essential binary tools
sudo apt install binutils file strings hexdump xxd
sudo apt install ltrace strace  # System call tracers
sudo apt install objdump readelf nm  # ELF analysis
pipx install binary-refinery
```

---

## 🕵️ Forensics Tools

### File Analysis
```bash
# File identification
sudo apt install file

# Hex editors
sudo apt install hexedit bless
sudo apt install ghex  # GUI hex editor

# Binwalk for firmware analysis  
sudo apt install binwalk

# Foremost for file carving
sudo apt install foremost
```

### Image Forensics  
```bash
# Steganography
sudo apt install steghide
pip3 install stegcracker

# Image analysis
sudo apt install exiftool
pip3 install pillow

# Audio steganography
sudo apt install audacity
```

### Memory Analysis
```bash
# Volatility Framework
pip3 install volatility3

# Alternative: Download from GitHub
git clone https://github.com/volatilityfoundation/volatility3.git
```

---

## 📡 Network Analysis Tools

### Wireshark
```bash
sudo apt install wireshark tshark
sudo usermod -a -G wireshark $USER  # Add user to wireshark group
```

### Network Utilities
```bash
# Scanning and enumeration
sudo apt install nmap zenmap
sudo apt install netcat socat

# DNS tools
sudo apt install dnsutils
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
# Core libraries
pip3 install requests urllib3 pycryptodome
pip3 install numpy matplotlib pillow

# CTF-specific
pip3 install pwntools z3-solver angr

# Web scraping  
pip3 install beautifulsoup4 selenium scrapy

# Data analysis
pip3 install pandas jupyter
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
    ubuntu:20.04 /bin/bash
```

### Docker CTF Images
```dockerfile
# ~/ctf/Dockerfile
FROM ubuntu:20.04

RUN apt-get update && apt-get install -y \
    python3 python3-pip \
    curl wget git \
    binutils file strings \
    netcat socat \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install pwntools requests pycryptodome

WORKDIR /ctf
CMD ["/bin/bash"]
```

---

## ⚡ Quick Setup Script

```bash
#!/bin/bash
# ~/ctf/setup.sh - Quick CTF environment setup

echo "Setting up CTF environment..."

# Create directory structure
mkdir -p ~/ctf/{tools,challenges,writeups,scripts}
mkdir -p ~/ctf/challenges/{crypto,web,pwn,rev,forensics,misc}

# Update system
sudo apt update && sudo apt upgrade -y

# Install essential packages
sudo apt install -y \
    python3 python3-pip \
    git curl wget \
    file binutils hexedit \
    netcat socat \
    nmap wireshark \
    gobuster dirb \
    hashcat john

# Install Python packages
pip3 install --user \
    pwntools requests pycryptodome \
    beautifulsoup4 pillow \
    z3-solver

# Install pwndbg
git clone https://github.com/pwndbg/pwndbg ~/pwndbg
cd ~/pwndbg && ./setup.sh

echo "CTF environment setup complete!"
echo "Don't forget to:"
echo "1. Download and install Burp Suite"
echo "2. Download and install Ghidra"
echo "3. Configure your shell aliases"
```

---

## 📋 Tool Categories Quick Reference

### By Challenge Type

| Category | Primary Tools | Secondary Tools |
|----------|---------------|-----------------|
| **Crypto** | CyberChef, Python, OpenSSL | SageMath, Hashcat |
| **Web** | Burp Suite, curl, Browser | ZAP, Gobuster, SQLmap |
| **Pwn** | GDB, pwntools, Ghidra | Radare2, ROPgadget |
| **Rev** | Ghidra, GDB, strings | IDA, Binary Ninja |
| **Forensics** | Binwalk, Wireshark, file | Volatility, Steghide |
| **Misc** | Python, Linux utils | Custom scripts |

### Installation Priority

#### Phase 1 (Essential)
- [ ] Python 3 + pip
- [ ] Git
- [ ] Basic Linux utilities (file, strings, hexdump)
- [ ] Text editor (vim/nano/vscode)
- [ ] Web browser with dev tools

#### Phase 2 (Important)  
- [ ] Burp Suite Community
- [ ] GDB + pwndbg
- [ ] Ghidra
- [ ] Wireshark
- [ ] Python libraries (pwntools, requests, crypto)

#### Phase 3 (Advanced)
- [ ] Specialized tools per category
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
- **Radare2**: https://book.rada.re/
- **GDB**: https://www.gnu.org/software/gdb/documentation/

---

*Last updated: {{date}}*

## Tags
#ctf #tools #setup #environment #guide