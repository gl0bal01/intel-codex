# Cryptography Analysis SOP

## Table of Contents

1. [Overview](#overview)
2. [Quick Reference](#quick-reference)
3. [Mathematical Foundations](#mathematical-foundations)
4. [Symmetric Cryptography](#symmetric-cryptography)
5. [Asymmetric Cryptography](#asymmetric-cryptography)
6. [Hash Functions & Authentication](#hash-functions--authentication)
7. [Password Cracking](#password-cracking)
8. [SSL/TLS & PKI](#ssltls--pki)
9. [Common Attacks](#common-attacks)
10. [CTF Crypto Challenges](#ctf-crypto-challenges)
11. [Tools Reference](#tools-reference)

---

## Overview

**Purpose:** Practical guide for cryptographic analysis, vulnerability assessment, and security research focused on real-world applications.

**Scope:**
- Cryptographic algorithm analysis and exploitation
- Password hash cracking techniques
- SSL/TLS security assessment
- RSA and symmetric crypto attacks
- CTF cryptography challenges

**Prerequisites:**
- Basic programming (Python recommended)
- Command-line proficiency
- Understanding of hexadecimal and binary

**Key Philosophy:**
- **Focus on practical attacks** over theoretical cryptography
- **Hands-on examples** for every concept
- **Real-world tools** used in security research

---

## Quick Reference

### Algorithm Security Status

| Type | Algorithm | Key Size | Status | Notes |
|------|-----------|----------|--------|-------|
| **Symmetric** | AES | 128/192/256-bit | ✅ Secure | Industry standard |
| | ChaCha20 | 256-bit | ✅ Secure | Modern alternative |
| | 3DES | 168-bit | ⚠️ Deprecated | Use AES instead |
| | DES/RC4 | 56-bit/Variable | ❌ Broken | Never use |
| **Asymmetric** | RSA | ≥2048-bit | ✅ Secure | 4096-bit for high security |
| | RSA | <2048-bit | ❌ Weak | Easily factored |
| | ECC | 256-bit | ✅ Secure | Smaller keys, same security |
| **Hash** | SHA-256/512 | 256/512-bit | ✅ Secure | General purpose |
| | SHA-1 | 160-bit | ❌ Broken | Collision attacks exist |
| | MD5 | 128-bit | ❌ Broken | Never use for security |
| **Password** | Argon2 | Variable | ✅ Best | PHC winner 2015 |
| | bcrypt | Variable | ✅ Secure | Industry standard |
| | PBKDF2 | Variable | ✅ Acceptable | Minimum 100k iterations |

### Essential Commands

```bash
# Hash identification
hashid '$2y$10$abc123...'
echo "5d41402abc4b2a76b9719d911017c592" | hashid

# Password cracking
hashcat -m 0 -a 0 hashes.txt rockyou.txt           # MD5 dictionary
hashcat -m 1400 -a 0 hashes.txt rockyou.txt        # SHA-256
hashcat -m 3200 -a 0 hashes.txt rockyou.txt        # bcrypt

# RSA analysis/attacks
python3 RsaCtfTool.py --publickey public.pem --private
openssl rsa -in private.pem -text -noout

# SSL/TLS testing
testssl.sh --full https://target.com
nmap --script ssl-enum-ciphers -p 443 target.com

# Certificate inspection
openssl x509 -in cert.pem -text -noout
openssl s_client -connect target.com:443 -showcerts

# Encoding/Decoding
echo "SGVsbG8=" | base64 -d                        # Base64 decode
echo "48656c6c6f" | xxd -r -p                      # Hex to ASCII
```

---

## Mathematical Foundations

### Why Math Matters in Crypto

**Purpose:** Modern cryptography relies on mathematical "hard problems" - operations that are easy to compute but hard to reverse without a secret key.

**Core Concepts You Need:**
- **Modular arithmetic** → RSA encryption/decryption
- **Prime numbers** → RSA key generation
- **Greatest Common Divisor (GCD)** → Finding shared prime factors between keys

**Real-World Impact:**
- Weak math = broken crypto (Debian OpenSSL bug 2008, ROCA 2017)
- Understanding math enables attacks (factoring RSA, discrete log problems)

---

### Modular Arithmetic

**What it is:** "Clock arithmetic" - numbers wrap around after reaching a modulus value.

**Example:** `17 mod 5 = 2` (17 ÷ 5 = 3 remainder 2)

**Why it's used in crypto:**
- Operations are reversible with the correct key (modular inverse)
- Results stay bounded (0 to n-1)
- Foundation of RSA: `c = m^e mod n` (encryption), `m = c^d mod n` (decryption)

**Python Examples:**

```python
# Basic modular operations
print((17 + 8) % 5)      # 0 (25 mod 5)
print((7 * 9) % 5)       # 3 (63 mod 5)
print(pow(2, 100, 17))   # 1 (2^100 mod 17, computed efficiently)

# Modular inverse (required for RSA)
def mod_inverse(a, m):
    """Find x such that (a * x) mod m = 1"""
    def extended_gcd(a, b):
        if a == 0:
            return b, 0, 1
        gcd, x1, y1 = extended_gcd(b % a, a)
        x = y1 - (b // a) * x1
        y = x1
        return gcd, x, y

    gcd, x, _ = extended_gcd(a, m)
    if gcd != 1:
        return None  # Inverse doesn't exist
    return (x % m + m) % m

# Example: 3 * 4 ≡ 1 (mod 11)
print(mod_inverse(3, 11))  # Output: 4
```

---

### Prime Numbers & Factorization

**What they are:** Numbers divisible only by 1 and themselves (2, 3, 5, 7, 11...).

**Why they're critical:**
- **RSA security** depends on difficulty of factoring n = p × q (two large primes)
- Small or predictable primes = broken RSA
- GCD attacks reveal shared factors between multiple RSA keys

**Primality Testing:**

```python
import random

def is_prime_miller_rabin(n, k=5):
    """Miller-Rabin primality test (probabilistic)"""
    if n < 2:
        return False
    if n == 2 or n == 3:
        return True
    if n % 2 == 0:
        return False

    # Write n-1 as 2^r * d
    r, d = 0, n - 1
    while d % 2 == 0:
        r += 1
        d //= 2

    # Witness loop
    for _ in range(k):
        a = random.randint(2, n - 2)
        x = pow(a, d, n)

        if x == 1 or x == n - 1:
            continue

        for _ in range(r - 1):
            x = pow(x, 2, n)
            if x == n - 1:
                break
        else:
            return False

    return True

print(is_prime_miller_rabin(17))  # True
print(is_prime_miller_rabin(18))  # False
```

**GCD Attack (Finding Shared Factors):**

```python
import math

# Real-world scenario: Two RSA moduli share a prime factor
n1 = 143  # 11 × 13
n2 = 221  # 13 × 17

# GCD reveals shared prime
gcd = math.gcd(n1, n2)
print(f"Shared factor: {gcd}")  # 13

# Both keys are now broken!
p1 = gcd
q1 = n1 // p1
print(f"n1 = {p1} × {q1}")  # 13 × 11

p2 = gcd
q2 = n2 // p2
print(f"n2 = {p2} × {q2}")  # 13 × 17
```

**Real Attack (2012):** Researchers collected millions of RSA public keys and computed GCDs between pairs, finding thousands that shared prime factors!

---

### Common Encoding Schemes

**IMPORTANT:** Encoding ≠ Encryption! Encoding is reversible by anyone - no security!

#### Base64

**What it is:** Encodes binary data into ASCII text (64 printable characters: A-Z, a-z, 0-9, +, /).

**When used:**
- Email attachments (SMTP requires text)
- JSON/XML with binary data
- Embedded images in HTML: `data:image/png;base64,...`

**How to recognize:** Ends with `=` or `==` (padding), only alphanumeric + `/` + `+`

```python
import base64

# Encode
encoded = base64.b64encode(b"Hello World")
print(encoded)  # b'SGVsbG8gV29ybGQ='

# Decode
decoded = base64.b64decode(encoded)
print(decoded)  # b'Hello World'
```

#### Hexadecimal

**What it is:** Represents binary using 16 symbols (0-9, A-F). 2 hex digits = 1 byte.

**When used:**
- Hash outputs (MD5, SHA-256)
- Memory addresses (0x401000)
- Raw bytes in packet captures

```python
# String to hex
text = "Hello"
hex_string = text.encode().hex()
print(hex_string)  # 48656c6c6f

# Hex to string
original = bytes.fromhex(hex_string).decode()
print(original)  # Hello
```

---

## Symmetric Cryptography

### AES (Advanced Encryption Standard)

**Status:** ✅ Secure (when used correctly)

**Key Sizes:** 128-bit (secure), 192-bit, 256-bit (high security)

**Modes of Operation:**
- **ECB** (Electronic Codebook) - ❌ **Never use** (deterministic, patterns visible)
- **CBC** (Cipher Block Chaining) - ⚠️ Requires random IV, vulnerable to padding oracle
- **CTR** (Counter Mode) - ✅ Good (parallelizable, no padding)
- **GCM** (Galois/Counter Mode) - ✅ **Best choice** (authenticated encryption)

#### AES-GCM (Recommended)

```python
from Crypto.Cipher import AES
from Crypto.Random import get_random_bytes

# Encryption
key = get_random_bytes(32)      # 256-bit key
nonce = get_random_bytes(12)    # 96-bit nonce

cipher = AES.new(key, AES.MODE_GCM, nonce=nonce)
plaintext = b"Secret message"
ciphertext, tag = cipher.encrypt_and_digest(plaintext)

print(f"Key: {key.hex()}")
print(f"Nonce: {nonce.hex()}")
print(f"Ciphertext: {ciphertext.hex()}")
print(f"Tag: {tag.hex()}")

# Decryption
cipher = AES.new(key, AES.MODE_GCM, nonce=nonce)
decrypted = cipher.decrypt_and_verify(ciphertext, tag)
print(f"Decrypted: {decrypted}")
```

#### ECB Mode Vulnerability

**Problem:** Identical plaintext blocks → identical ciphertext blocks (patterns leak information)

**Famous Example:** ECB-encrypted Tux penguin image shows visible outline

**Detection:**
```bash
# Look for repeating blocks in ciphertext
xxd ciphertext.bin | sort | uniq -d
# If duplicates found → likely ECB mode
```

#### Padding Oracle Attack

**Vulnerability:** Application leaks whether padding is valid/invalid → decrypt ciphertext byte-by-byte

**Vulnerable Code:**
```python
from Crypto.Cipher import AES
from Crypto.Util.Padding import unpad

def decrypt_and_check(ciphertext, iv, key):
    cipher = AES.new(key, AES.MODE_CBC, iv)
    try:
        plaintext = unpad(cipher.decrypt(ciphertext), 16)
        return True  # Valid padding
    except ValueError:
        return False  # Invalid padding ← INFORMATION LEAK!
```

**Tool:** PadBuster automates this attack
```bash
padbuster http://target.com/decrypt.php "ciphertext_hex" "iv_hex" 16 -encoding 0
```

---

## Asymmetric Cryptography

### RSA (Rivest-Shamir-Adleman)

**How RSA Works:**
1. Choose two large primes: p, q
2. Compute modulus: n = p × q
3. Compute totient: φ(n) = (p-1)(q-1)
4. Choose public exponent: e (commonly 65537)
5. Compute private exponent: d = e^(-1) mod φ(n)

**Public key:** (n, e)
**Private key:** (n, d)

**Encryption:** c = m^e mod n
**Decryption:** m = c^d mod n

#### Generate RSA Keys

```bash
# OpenSSL
openssl genrsa -out private.pem 4096
openssl rsa -in private.pem -pubout -out public.pem
openssl rsa -in private.pem -text -noout  # View key components
```

```python
from Crypto.PublicKey import RSA

# Generate 2048-bit key
key = RSA.generate(2048)

# Export keys
with open('private.pem', 'wb') as f:
    f.write(key.export_key())

with open('public.pem', 'wb') as f:
    f.write(key.publickey().export_key())

print(f"n: {key.n}")
print(f"e: {key.e}")
print(f"d: {key.d}")
```

---

### RSA Attacks

#### 1. Small Exponent Attack (e=3)

**Vulnerability:** If e=3 and m^3 < n, ciphertext c = m^3 (no modular reduction) → just compute cube root!

```python
import gmpy2

def small_e_attack(c, e=3):
    """If m^e < n, then c = m^e → m = e-th root of c"""
    m, exact = gmpy2.iroot(c, e)
    if exact:
        return int(m)
    return None

# Example
c = 1030301  # Small ciphertext
m = small_e_attack(c, e=3)
if m:
    print(f"Plaintext: {m}")
    print(f"Text: {bytes.fromhex(hex(m)[2:])}")
```

#### 2. Common Modulus Attack

**Vulnerability:** Same message encrypted with same n but different e values → recover plaintext without private key!

```python
def common_modulus_attack(c1, c2, e1, e2, n):
    """
    If m^e1 mod n = c1 and m^e2 mod n = c2
    Can recover m using Extended Euclidean Algorithm
    """
    from math import gcd

    def extended_gcd(a, b):
        if a == 0:
            return b, 0, 1
        gcd, x1, y1 = extended_gcd(b % a, a)
        x = y1 - (b // a) * x1
        y = x1
        return gcd, x, y

    gcd_val, a, b = extended_gcd(e1, e2)

    if gcd_val != 1:
        return None

    # m = (c1^a * c2^b) mod n
    if a < 0:
        c1 = pow(c1, -1, n)
        a = -a
    if b < 0:
        c2 = pow(c2, -1, n)
        b = -b

    m = (pow(c1, a, n) * pow(c2, b, n)) % n
    return m
```

#### 3. Fermat's Factorization (Close Primes)

**Vulnerability:** If p and q are close in value, can factor n quickly

```python
import gmpy2

def fermat_factor(n):
    """Factor n if p and q are close"""
    a = gmpy2.isqrt(n) + 1

    for _ in range(100000):
        b_squared = a * a - n
        b = gmpy2.isqrt(b_squared)

        if b * b == b_squared:
            p = a + b
            q = a - b
            return int(p), int(q)

        a += 1

    return None, None

# Example with close primes
n = 8051  # 89 × 91-1 = 89 × 90 (close primes)
p, q = fermat_factor(n)
if p and q:
    print(f"p = {p}, q = {q}")
```

#### 4. Automated RSA Attacks

**RsaCtfTool** - Automates 20+ RSA attacks

```bash
# Install
git clone https://github.com/RsaCtfTool/RsaCtfTool.git
cd RsaCtfTool
pip3 install -r requirements.txt

# Recover private key from public key
python3 RsaCtfTool.py --publickey public.pem --private

# Decrypt ciphertext
python3 RsaCtfTool.py --publickey public.pem --uncipherfile encrypted.bin

# Try all attacks
python3 RsaCtfTool.py --publickey public.pem --private --attack all
```

---

## Hash Functions & Authentication

### Hash Function Basics

**Purpose:** One-way function that produces fixed-size output from variable input

**Properties:**
- **Deterministic:** Same input always produces same output
- **Fast to compute:** Hashing is quick
- **Avalanche effect:** Small input change = completely different hash
- **One-way:** Can't reverse hash to get original input
- **Collision-resistant:** Hard to find two inputs with same hash

### Common Hash Algorithms

```python
import hashlib

message = b"Hello World"

# MD5 (128-bit) - ❌ BROKEN
md5 = hashlib.md5(message).hexdigest()
print(f"MD5: {md5}")

# SHA-1 (160-bit) - ❌ BROKEN (collisions exist)
sha1 = hashlib.sha1(message).hexdigest()
print(f"SHA-1: {sha1}")

# SHA-256 (256-bit) - ✅ SECURE
sha256 = hashlib.sha256(message).hexdigest()
print(f"SHA-256: {sha256}")

# SHA-512 (512-bit) - ✅ SECURE
sha512 = hashlib.sha512(message).hexdigest()
print(f"SHA-512: {sha512}")
```

### HMAC (Message Authentication)

**Purpose:** Verify message integrity and authenticity using secret key

```python
import hmac
import hashlib

key = b"secret_key"
message = b"Important message"

# Generate HMAC
mac = hmac.new(key, message, hashlib.sha256).hexdigest()
print(f"HMAC: {mac}")

# Verify HMAC (constant-time comparison prevents timing attacks)
def verify_hmac(key, message, provided_mac):
    expected_mac = hmac.new(key, message, hashlib.sha256).hexdigest()
    return hmac.compare_digest(expected_mac, provided_mac)  # ✅ Secure

# ❌ INSECURE: if expected_mac == provided_mac  (timing attack vulnerable)
```

### Hash Length Extension Attack

**Vulnerability:** Hash functions like SHA-256 vulnerable when used as `H(secret || data)` instead of HMAC

**Vulnerable Code:**
```python
import hashlib

secret = b"secret_key"
data = b"user=admin"

# ❌ VULNERABLE
hash_vulnerable = hashlib.sha256(secret + data).hexdigest()

# ✅ SECURE: Use HMAC instead
hash_secure = hmac.new(secret, data, hashlib.sha256).hexdigest()
```

**Attack Tool:**
```bash
# HashPump - Exploits length extension
git clone https://github.com/bwall/HashPump.git
cd HashPump && make

# Extend hash without knowing secret
./hashpump -s 'original_hash' \
           -d 'original_data' \
           -a '&admin=true' \
           -k 10  # Secret length guess
```

---

## Password Cracking

### Password Hashing

**Wrong Way (Fast Hashing):**
```python
import hashlib

# ❌ MD5/SHA-256 too fast - vulnerable to brute force
password = "password123"
bad_hash = hashlib.sha256(password.encode()).hexdigest()
```

**Right Way (Slow Hashing with Salt):**
```python
import bcrypt

# ✅ bcrypt - Slow hashing resistant to brute force
password = b"password123"
salt = bcrypt.gensalt(rounds=12)  # Work factor (higher = slower)
hashed = bcrypt.hashpw(password, salt)

print(f"Hash: {hashed}")

# Verify
if bcrypt.checkpw(password, hashed):
    print("Password correct")
```

### Hash Identification

```bash
# hashid tool
hashid '$2y$10$abc...'
# Output: bcrypt

hashid '5d41402abc4b2a76b9719d911017c592'
# Output: MD5
```

**Manual Identification:**

| Hash Example | Algorithm | Pattern |
|--------------|-----------|---------|
| 5d41402abc4b2a76b9719d911017c592 | MD5 | 32 hex chars |
| 356a192b7913b04c54574d18c28d46e6395428ab | SHA-1 | 40 hex chars |
| a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e | SHA-256 | 64 hex chars |
| $1$abc$xyz | MD5 (Unix) | Starts with $1$ |
| $2a$10$... or $2y$10$... | bcrypt | Starts with $2a$ or $2y$ |
| $6$abc$xyz | SHA-512 (Unix) | Starts with $6$ |

### Hashcat (GPU Password Cracking)

**Common Hash Modes:**
- `0` = MD5
- `100` = SHA1
- `1400` = SHA-256
- `3200` = bcrypt
- `1800` = sha512crypt (Unix)

**Dictionary Attack:**
```bash
# MD5
hashcat -m 0 -a 0 hashes.txt /usr/share/wordlists/rockyou.txt

# SHA-256
hashcat -m 1400 -a 0 hashes.txt /usr/share/wordlists/rockyou.txt

# bcrypt (slow)
hashcat -m 3200 -a 0 hashes.txt /usr/share/wordlists/rockyou.txt
```

**Rule-Based Attack:**
```bash
# Apply rules (password → Password1, p@ssword, etc.)
hashcat -m 0 -a 0 hashes.txt rockyou.txt -r /usr/share/hashcat/rules/best64.rule
```

**Mask Attack (Pattern Brute Force):**
```bash
# Crack 8-digit PIN
hashcat -m 0 -a 3 hashes.txt ?d?d?d?d?d?d?d?d

# Mask charsets:
# ?l = lowercase (a-z)
# ?u = uppercase (A-Z)
# ?d = digits (0-9)
# ?s = special chars
# ?a = all (?l?u?d?s)

# Pattern: "password" + 2 digits
hashcat -m 0 -a 3 hashes.txt password?d?d
```

**Show Cracked:**
```bash
hashcat -m 0 hashes.txt --show
```

---

## SSL/TLS & PKI

### Certificate Inspection

```bash
# View certificate details
openssl x509 -in cert.pem -text -noout

# Extract from server
openssl s_client -connect target.com:443 -showcerts </dev/null 2>/dev/null | \
  openssl x509 -outform PEM > cert.pem

# Check expiration
openssl x509 -in cert.pem -noout -dates

# View subject/issuer
openssl x509 -in cert.pem -noout -subject
openssl x509 -in cert.pem -noout -issuer
```

### SSL/TLS Testing

**testssl.sh (Comprehensive Scanner):**

```bash
# Clone
git clone https://github.com/drwetter/testssl.sh.git

# Full scan
./testssl.sh --full https://target.com

# Specific vulnerabilities
./testssl.sh --heartbleed https://target.com
./testssl.sh --poodle https://target.com
./testssl.sh --robot https://target.com

# Check weak ciphers
./testssl.sh --cipher-per-proto https://target.com
```

**Nmap SSL Scripts:**

```bash
# Enumerate ciphers
nmap --script ssl-enum-ciphers -p 443 target.com

# Check Heartbleed
nmap --script ssl-heartbleed -p 443 target.com

# Check POODLE
nmap --script ssl-poodle -p 443 target.com
```

### Common SSL/TLS Vulnerabilities

| Vulnerability | CVE | Impact | Test |
|---------------|-----|--------|------|
| Heartbleed | CVE-2014-0160 | Memory leak | `nmap --script ssl-heartbleed` |
| POODLE | CVE-2014-3566 | SSLv3 padding oracle | `testssl.sh --poodle` |
| BEAST | CVE-2011-3389 | CBC vulnerability TLS 1.0 | `testssl.sh --beast` |
| DROWN | CVE-2016-0800 | SSLv2 cross-protocol attack | `testssl.sh --drown` |
| ROBOT | - | RSA PKCS#1 oracle | `testssl.sh --robot` |

---

## Common Attacks

### Classical Ciphers

#### Caesar Cipher (ROT13)

```python
def caesar_decrypt(ciphertext, shift):
    plaintext = ""
    for char in ciphertext:
        if char.isalpha():
            shifted = ord(char) - shift
            if char.isupper():
                if shifted < ord('A'):
                    shifted += 26
            else:
                if shifted < ord('a'):
                    shifted += 26
            plaintext += chr(shifted)
        else:
            plaintext += char
    return plaintext

# Brute force all shifts
ciphertext = "KHOOR ZRUOG"
for shift in range(26):
    print(f"Shift {shift}: {caesar_decrypt(ciphertext, shift)}")
# Output includes: "Shift 3: HELLO WORLD"
```

### XOR Cipher

#### Single-Byte XOR

```python
def single_byte_xor(data, key):
    return bytes([b ^ key for b in data])

def score_english(text):
    """Score based on English letter frequency"""
    common = b'etaoinshrdlu '
    return sum(1 for b in text.lower() if b in common)

# Brute force
ciphertext = bytes.fromhex("1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736")

best_score = 0
best_key = 0
best_text = b''

for key in range(256):
    plaintext = single_byte_xor(ciphertext, key)
    score = score_english(plaintext)

    if score > best_score:
        best_score = score
        best_key = key
        best_text = plaintext

print(f"Key: {best_key} ('{chr(best_key)}')")
print(f"Plaintext: {best_text}")
```

#### Repeating-Key XOR

```python
def repeating_key_xor(data, key):
    """XOR with repeating key"""
    repeated_key = (key * (len(data) // len(key) + 1))[:len(data)]
    return bytes([d ^ k for d, k in zip(data, repeated_key)])

# Encrypt
plaintext = b"Secret message"
key = b"KEY"
ciphertext = repeating_key_xor(plaintext, key)

# Decrypt (same operation)
decrypted = repeating_key_xor(ciphertext, key)
print(decrypted)  # b"Secret message"
```

---

## CTF Crypto Challenges

### Common Patterns

#### 1. RSA Challenges

```bash
# Automated approach
python3 RsaCtfTool.py --publickey public.pem --uncipherfile flag.enc

# Manual checks:
# - Small e (e=3) → small exponent attack
# - Small n → factor with factordb.com
# - Multiple keys → common modulus attack
# - p and q close → Fermat factorization
```

#### 2. XOR Challenges

```python
# Single-byte XOR
ciphertext = bytes.fromhex("...")
for key in range(256):
    plaintext = bytes([b ^ key for b in ciphertext])
    if b'flag{' in plaintext or b'CTF{' in plaintext:
        print(plaintext)

# Repeating-key XOR → use frequency analysis to find key length
```

#### 3. Base64 Layers

```python
import base64

# Multiple layers of encoding
encoded = "VkZoU1FtRnRjRXhsZEVGMVZHaGxiblJwWTJGMFpVRjFkR2hsYm5ScFkyRjBaVUYxZEdob..."

# Decode until plaintext
while True:
    try:
        decoded = base64.b64decode(encoded)
        if decoded == encoded or not decoded:
            break
        encoded = decoded
        print(f"Decoded: {decoded}")
    except:
        break

print(f"Final: {encoded}")
```

#### 4. AES ECB Oracle

```python
# If you can encrypt chosen plaintexts (ECB mode)
# Can decrypt unknown suffix byte-by-byte

def ecb_oracle_attack(encryption_oracle, block_size=16):
    """Byte-at-a-time ECB decryption"""
    known = b''

    for block_num in range(10):
        for byte_pos in range(block_size):
            # Craft input
            padding = b'A' * (block_size - 1 - byte_pos)
            target = encryption_oracle(padding)[:block_size * (block_num + 1)]

            # Try all bytes
            for byte_val in range(256):
                test_input = padding + known + bytes([byte_val])
                test_output = encryption_oracle(test_input)[:block_size * (block_num + 1)]

                if test_output == target:
                    known += bytes([byte_val])
                    break
            else:
                return known

    return known
```

### Useful Tools & Websites

**Online Tools:**
- **CyberChef:** https://gchq.github.io/CyberChef/ (encoding chains, crypto operations)
- **dcode.fr:** https://www.dcode.fr/ (classical ciphers, analysis)
- **FactorDB:** http://factordb.com/ (factor integers, check known RSA moduli)

**Command-Line:**
```bash
# CyberChef offline
git clone https://github.com/gchq/CyberChef.git
cd CyberChef && firefox CyberChef.html
```

---

## Tools Reference

### Essential Tools

| Tool | Purpose | Installation |
|------|---------|--------------|
| **OpenSSL** | Crypto operations, certs | `apt install openssl` |
| **Hashcat** | GPU password cracking | `apt install hashcat` |
| **John the Ripper** | CPU password cracking | `apt install john` |
| **testssl.sh** | SSL/TLS testing | `git clone https://github.com/drwetter/testssl.sh` |
| **RsaCtfTool** | Automated RSA attacks | `git clone https://github.com/RsaCtfTool/RsaCtfTool.git` |
| **hashid** | Hash identification | `pip install hashid` |

### Python Libraries

```bash
# Core crypto
pip install pycryptodome      # AES, RSA, ECC
pip install cryptography      # High-level API

# Math/Analysis
pip install gmpy2             # Fast math operations
pip install primefac          # Prime factorization
pip install ecdsa             # Elliptic curves

# Password hashing
pip install bcrypt            # bcrypt
pip install argon2-cffi       # Argon2

# Utilities
pip install base58            # Bitcoin addresses
pip install hashid            # Hash identification
```

### Specialized Tools

| Tool          | Purpose                        | Link                                      |
| ------------- | ------------------------------ | ----------------------------------------- |
| **PadBuster** | Padding oracle attack          | https://github.com/AonCyberLabs/PadBuster |
| **CyberChef** | Multi-tool for encoding/crypto | https://gchq.github.io/CyberChef/         |
| **FactorDB**  | Integer factorization database | http://factordb.com/                      |
| **Slither**   | Smart contract analyzer        | `pip install slither-analyzer`            |

---

## Reference Resources

### Comprehensive Knowledge Bases
- **CryptoHack** - [cryptohack.org](https://cryptohack.org/)
  - Interactive cryptography challenges and learning platform
  - Covers RSA, AES, elliptic curves, hash functions
  - Excellent for CTF preparation
- **Practical Cryptography for Developers** - [cryptobook.nakov.com](https://cryptobook.nakov.com/)
  - Modern cryptography handbook with Python examples
  - Covers symmetric/asymmetric crypto, digital signatures, key exchange
- **Crypto101** - [crypto101.io](https://www.crypto101.io/)
  - Introductory cryptography course (free book)
  - Explains fundamentals with practical examples
- **CyberChef Wiki** - [github.com/gchq/CyberChef/wiki](https://github.com/gchq/CyberChef/wiki)
  - Documentation for CyberChef multi-tool
  - Encoding/decoding, crypto operations, data analysis

### Attack Techniques & Exploits
- **HackTricks - Crypto** - [book.hacktricks.xyz/crypto-and-stego/crypto-ctfs-tricks](https://book.hacktricks.xyz/crypto-and-stego/crypto-ctfs-tricks)
  - CTF cryptography tricks and common patterns
  - RSA attacks, padding oracle, ECB vulnerabilities
- **PayloadsAllTheThings - Cryptography** - [github.com/swisskyrepo/PayloadsAllTheThings/tree/master/Methodology%20and%20Resources#crypto](https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/Methodology%20and%20Resources)
  - Cryptographic attack payloads and techniques
- **Cryptopals Challenges** - [cryptopals.com](https://cryptopals.com/)
  - Hands-on crypto breaking exercises
  - Covers AES, RSA, hash functions, padding oracle attacks
- **GTFOBins - OpenSSL** - [gtfobins.github.io/gtfobins/openssl](https://gtfobins.github.io/gtfobins/openssl/)
  - OpenSSL command examples for crypto operations

### RSA Specific Resources
- **FactorDB** - [factordb.com](http://factordb.com/)
  - Database of known integer factorizations
  - Check if RSA modulus has been factored
- **RsaCtfTool Documentation** - [github.com/RsaCtfTool/RsaCtfTool](https://github.com/RsaCtfTool/RsaCtfTool)
  - Automated RSA attack tool (20+ attack methods)
  - Handles small exponent, common modulus, Fermat, Wiener, etc.
- **Twenty Years of Attacks on RSA** - [crypto.stanford.edu/~dabo/pubs/papers/RSA-survey.pdf](https://crypto.stanford.edu/~dabo/pubs/papers/RSA-survey.pdf)
  - Dan Boneh's comprehensive RSA attack survey (academic paper)

### Password Cracking Resources
- **Hashcat Wiki** - [hashcat.net/wiki](https://hashcat.net/wiki/)
  - Official documentation for GPU password cracking
  - Hash modes, attack types, performance tuning
- **John the Ripper Documentation** - [openwall.com/john/doc](https://www.openwall.com/john/doc/)
  - CPU-based password cracker documentation
- **SecLists** - [github.com/danielmiessler/SecLists](https://github.com/danielmiessler/SecLists)
  - Curated password wordlists (rockyou.txt, common passwords)
  - Username lists, fuzzing payloads
- **Have I Been Pwned - Passwords** - [haveibeenpwned.com/Passwords](https://haveibeenpwned.com/Passwords)
  - Database of compromised passwords (API available)

### SSL/TLS Testing Resources
- **testssl.sh Documentation** - [github.com/drwetter/testssl.sh](https://github.com/drwetter/testssl.sh)
  - Comprehensive SSL/TLS testing tool
  - Checks for Heartbleed, POODLE, weak ciphers, etc.
- **SSL Labs Server Test** - [ssllabs.com/ssltest](https://www.ssllabs.com/ssltest/)
  - Online SSL/TLS configuration analyzer
  - Industry standard for certificate/cipher validation
- **OWASP TLS Cheat Sheet** - [cheatsheetseries.owasp.org/cheatsheets/Transport_Layer_Security_Cheat_Sheet.html](https://cheatsheetseries.owasp.org/cheatsheets/Transport_Layer_Security_Cheat_Sheet.html)
  - Best practices for TLS configuration
- **crt.sh** - [crt.sh](https://crt.sh/)
  - Certificate transparency log search

### Online Tools
- **CyberChef** - [gchq.github.io/CyberChef](https://gchq.github.io/CyberChef/)
  - Multi-tool for encoding, decoding, crypto operations
  - Visual recipe builder for data transformations
- **dcode.fr** - [dcode.fr](https://www.dcode.fr/)
  - Classical cipher solver (Caesar, Vigenère, substitution)
  - Frequency analysis, cryptanalysis tools
- **Crackstation** - [crackstation.net](https://crackstation.net/)
  - Online hash lookup (15 billion hashes)
  - Fast MD5/SHA1/NTLM cracking
- **Cipher Identifier** - [dcode.fr/cipher-identifier](https://www.dcode.fr/cipher-identifier)
  - Automatic cipher type detection

### Cheat Sheets & Quick References
- **OpenSSL Cheat Sheet** - [freecodecamp.org/news/openssl-command-cheatsheet-b441be1e8c4a](https://www.freecodecamp.org/news/openssl-command-cheatsheet-b441be1e8c4a/)
  - Common OpenSSL commands for certificates, keys, hashing
- **Hashcat Example Hashes** - [hashcat.net/wiki/doku.php?id=example_hashes](https://hashcat.net/wiki/doku.php?id=example_hashes)
  - Example hash formats for all hash modes
- **Hash Algorithm Comparison** - [en.wikipedia.org/wiki/Comparison_of_cryptographic_hash_functions](https://en.wikipedia.org/wiki/Comparison_of_cryptographic_hash_functions)
  - Performance and security comparison of hash functions

### Vulnerability Databases
- **CVE Details - Cryptography** - [cvedetails.com](https://www.cvedetails.com/)
  - Search for crypto-related CVEs (Heartbleed, POODLE, etc.)
- **NIST Cryptographic Standards** - [csrc.nist.gov/projects/cryptographic-standards-and-guidelines](https://csrc.nist.gov/projects/cryptographic-standards-and-guidelines)
  - Official FIPS standards (FIPS 140-2, SP 800-series)

### Research & Academic Papers
- **IACR ePrint Archive** - [eprint.iacr.org](https://eprint.iacr.org/)
  - Cryptology research papers (pre-prints)
  - Latest attacks and cryptographic research
- **Applied Cryptography by Bruce Schneier** - Classic cryptography textbook
  - Covers algorithms, protocols, implementation
- **The Joy of Cryptography** - [joyofcryptography.com](https://joyofcryptography.com/)
  - Free undergraduate-level cryptography textbook

### CTF & Practice Platforms
- **OverTheWire - Krypton** - [overthewire.org/wargames/krypton](https://overthewire.org/wargames/krypton/)
  - Cryptography wargame challenges
- **PicoCTF** - [picoctf.org](https://picoctf.org/)
  - Beginner-friendly CTF with crypto challenges
- **Root-Me - Cryptanalysis** - [root-me.org](https://www.root-me.org/)
  - French platform with cryptanalysis challenges

### Defensive Resources
- **OWASP Cryptographic Failures (A02:2021)** - [owasp.org/Top10/A02_2021-Cryptographic_Failures](https://owasp.org/Top10/A02_2021-Cryptographic_Failures/)
  - Common crypto implementation mistakes
  - Weak algorithms, improper key management
- **NIST Key Management Guidelines (SP 800-57)** - [csrc.nist.gov/publications/detail/sp/800-57-part-1/rev-5/final](https://csrc.nist.gov/publications/detail/sp/800-57-part-1/rev-5/final)
  - Key lifecycle management best practices
- **Password Storage Cheat Sheet** - [cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html)
  - Argon2, bcrypt, PBKDF2 recommendations

---

## Related SOPs

**Analysis:**
- [[sop-reverse-engineering|Reverse Engineering]] - Binary crypto implementation analysis
- [[sop-malware-analysis|Malware Analysis]] - Encrypted malware communications
- [[sop-hash-generation-methods|Hash Generation Methods]] - File integrity verification

**Pentesting & Security:**
- [[../Pentesting/sop-web-application-security|Web Application Security]] - Cryptographic failures (OWASP A02:2021)
- [[../Pentesting/sop-vulnerability-research|Vulnerability Research]] - Finding crypto vulnerabilities
- [[../Pentesting/sop-bug-bounty|Bug Bounty Hunting]] - Responsible disclosure
- [[../Pentesting/sop-mobile-security|Mobile Security]] - SSL pinning bypass
- [[../Pentesting/sop-forensics-investigation|Forensics Investigation]] - Encrypted data recovery

---

**Version:** 2.0
**Last Updated:** 2025-10-11
**Focus:** Practical cryptanalysis for security research and CTF challenges
