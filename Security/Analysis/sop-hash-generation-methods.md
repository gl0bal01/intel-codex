---
type: sop
title: "Hash Generation Methods for Evidence Integrity"
description: "Forensic hashing guide: SHA-256, SHA-3, BLAKE2/3, MD5/SHA-1 deprecation, file integrity verification, chain of custody & cryptographic hashing for digital evidence preservation."
tags:
  - sop
  - hashing
  - forensics
  - integrity
  - evidence
  - chain-of-custody
  - cryptography
updated: 2026-10-30
template_version: 2026-04-26
---

# Hash Generation Methods for Evidence Integrity

## Table of Contents

1. [Command Line Tools (Primary Methods)](#1-command-line-tools-primary-methods)
2. [Forensic Tools (Professional Methods)](#2-forensic-tools-professional-methods)
3. [Third-Party Tools](#3-third-party-tools)
4. [Hash Algorithm Selection](#4-hash-algorithm-selection)
5. [Evidence Collection Workflow](#5-evidence-collection-workflow)
6. [Advanced Use Cases](#6-advanced-use-cases)
7. [Troubleshooting & Common Issues](#7-troubleshooting--common-issues)
8. [Chain of Custody Best Practices](#8-chain-of-custody-best-practices)
9. [Integration with Forensic Tools](#9-integration-with-forensic-tools)
10. [Tools Reference](#10-tools-reference)
11. [Reference Resources](#11-reference-resources)

---

## Overview

**Purpose:** Hash values provide cryptographic fingerprints of digital evidence, ensuring integrity throughout the investigation lifecycle. Authenticity and non-repudiation additionally need a digital signature over the hash manifest, because a bare hash binds the data to no person or key (NIST glossary, "non-repudiation", from FIPS 186-5) [verify 2026-10-30]. Any modification to the file will result in a completely different hash value, making tampering immediately detectable.

**Use Cases:**
- Evidence acquisition and chain of custody verification
- Malware sample identification and deduplication
- File integrity monitoring in incident response
- Data transfer verification (network/physical media)
- Court admissibility of digital evidence (Daubert/Frye standards)

---

## 1. Command Line Tools (Primary Methods)

### Windows - CertUtil

**Basic hashing:**
```cmd
REM cmd.exe has no # comments; REM marks a comment line [verify 2026-10-30]
REM SHA-256 (Recommended for forensics)
certutil -hashfile "evidence.bin" SHA256

REM Output:
REM SHA256 hash of evidence.bin:
REM a1b2c3d4e5f6789012345678901234567890123456789012345678901234567890
REM CertUtil: -hashfile command completed successfully.

REM Multiple algorithms at once (batch script)
@echo off
echo Hashing: %1
certutil -hashfile "%1" MD5 | findstr /v "hash CertUtil"
certutil -hashfile "%1" SHA1 | findstr /v "hash CertUtil"
certutil -hashfile "%1" SHA256 | findstr /v "hash CertUtil"
certutil -hashfile "%1" SHA512 | findstr /v "hash CertUtil"

REM Save to file with timestamp
certutil -hashfile "evidence.bin" SHA256 > "%DATE:/=-%_%TIME::=-%_evidence_hash.txt"
```

**Batch processing multiple files:**
```cmd
REM Interactive prompt form: inside a .bat/.cmd file write %%f instead of %f [verify 2026-10-30]
REM Hash all files in directory
for %f in (C:\Evidence\*) do @certutil -hashfile "%f" SHA256 | findstr /v "hash CertUtil" >> evidence_hashes.txt

REM With filenames
for %f in (C:\Evidence\*) do @echo %f && certutil -hashfile "%f" SHA256 | findstr /v "hash CertUtil"
```

### Windows - PowerShell

**Single file hashing:**
```powershell
# SHA-256 with clean output
Get-FileHash -Path "evidence.bin" -Algorithm SHA256 | Format-List

# Output:
# Algorithm : SHA256
# Hash      : A1B2C3D4E5F6789012345678901234567890123456789012345678901234567890
# Path      : C:\Evidence\evidence.bin

# Just the hash value
(Get-FileHash -Path "evidence.bin" -Algorithm SHA256).Hash

# Multiple algorithms
@('MD5', 'SHA1', 'SHA256', 'SHA512') | ForEach-Object {
    $hash = Get-FileHash -Path "evidence.bin" -Algorithm $_
    Write-Output "$($_): $($hash.Hash)"
}
```

**Batch processing and export:**
```powershell
# Hash all files in directory tree
Get-ChildItem -Path "C:\Evidence" -Recurse -File |
    Get-FileHash -Algorithm SHA256 |
    Select-Object Algorithm, Hash, Path |
    Export-Csv -Path "evidence_hashes.csv" -NoTypeInformation

# Generate verification report
Get-ChildItem -Path "C:\Evidence" -Recurse -File | ForEach-Object {
    $hash = Get-FileHash -Path $_.FullName -Algorithm SHA256
    [PSCustomObject]@{
        Timestamp = (Get-Date).ToUniversalTime().ToString('u')
        Filename = $_.Name
        Path = $_.FullName
        Size = $_.Length
        Created = $_.CreationTime
        Modified = $_.LastWriteTime
        SHA256 = $hash.Hash
        Analyst = $env:USERNAME
    }
} | Export-Csv -Path "evidence_manifest.csv" -NoTypeInformation

# Compare hash against known value
$knownHash = "a1b2c3d4e5f6789012345678901234567890123456789012345678901234567890"
$currentHash = (Get-FileHash -Path "evidence.bin" -Algorithm SHA256).Hash
if ($currentHash -eq $knownHash) {
    Write-Host "✓ VERIFIED: Hash matches" -ForegroundColor Green
} else {
    Write-Host "✗ MISMATCH: File integrity compromised!" -ForegroundColor Red
}
```

### Linux/macOS - Command Line

**Basic hashing:**
```bash
# SHA-256 (Recommended)
sha256sum evidence.bin
# Output: a1b2c3d4e5f6...  evidence.bin   (hash, two spaces, filename: the format sha256sum -c reads) [verify 2026-10-30]

# MD5
md5sum evidence.bin

# SHA-1
sha1sum evidence.bin

# SHA-512
sha512sum evidence.bin

# BLAKE2b (b2sum, coreutils >= 8.26); cksum -a (coreutils >= 9.0) takes sysv, bsd, crc, md5, sha1, sha224-sha512, blake2b or sm3 (9.4) and prints BSD-tagged output [verify 2026-10-30]
b2sum evidence.bin
cksum -a sha256 evidence.bin

# Multiple algorithms
echo "MD5:    $(md5sum evidence.bin | awk '{print $1}')"
echo "SHA1:   $(sha1sum evidence.bin | awk '{print $1}')"
echo "SHA256: $(sha256sum evidence.bin | awk '{print $1}')"
```

**Batch processing:**
```bash
# Hash all files in directory
find /evidence -type f -exec sha256sum {} \; > evidence_hashes.txt

# With formatted output (stat syntax differs: BSD/macOS uses -f, GNU/Linux uses -c)
# Hash via stdin: given a filename containing a backslash or newline, *sum prefixes the hash with "\" [verify 2026-10-30]
find /evidence -type f -print0 | while IFS= read -r -d '' file; do
    echo "File: $file"
    echo "SHA256: $(sha256sum < "$file" | awk '{print $1}')"
    echo "Size: $(stat -c%s "$file" 2>/dev/null || stat -f%z "$file") bytes"
    echo "Modified: $(stat -c%y "$file" 2>/dev/null || stat -f%Sm "$file")"
    echo "---"
done > evidence_manifest.txt

# Create checksums file for verification (find recurses and passes only files; /evidence/* skips dotfiles and nested files and passes directory names, which sha256sum rejects)
find /evidence -type f -exec sha256sum {} + > SHA256SUMS

# Verify integrity later
sha256sum -c SHA256SUMS
# Output:
# /evidence/evidence1.bin: OK
# /evidence/evidence2.bin: OK
# /evidence/evidence3.bin: FAILED
# sha256sum: WARNING: 1 computed checksum did NOT match   (exit status 1) [verify 2026-10-30]
```

**Advanced verification workflow:**
```bash
#!/bin/bash
# evidence_hash.sh - Comprehensive evidence hashing script

EVIDENCE_DIR="/evidence"
OUTPUT_FILE="evidence_manifest_$(date +%Y%m%d_%H%M%S).txt"
ANALYST=$(whoami)

echo "Evidence Hash Manifest" > "$OUTPUT_FILE"
echo "Generated: $(date -u)" >> "$OUTPUT_FILE"
echo "Analyst: $ANALYST" >> "$OUTPUT_FILE"
echo "========================================" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Hash via stdin: given a filename containing a backslash or newline, *sum prefixes the hash with "\"
find "$EVIDENCE_DIR" -type f -print0 | while IFS= read -r -d '' file; do
    echo "File: $file" >> "$OUTPUT_FILE"
    echo "Size: $(stat -f%z "$file" 2>/dev/null || stat -c%s "$file") bytes" >> "$OUTPUT_FILE"
    echo "Modified: $(stat -f%Sm "$file" 2>/dev/null || stat -c%y "$file")" >> "$OUTPUT_FILE"
    echo "MD5:    $(md5sum < "$file" | awk '{print $1}')" >> "$OUTPUT_FILE"
    echo "SHA256: $(sha256sum < "$file" | awk '{print $1}')" >> "$OUTPUT_FILE"
    echo "---" >> "$OUTPUT_FILE"
done

# Hash the manifest and record the value in the custody log; a hash is not a signature,
# so sign the manifest with a detached GPG signature (Best Practice Summary, §10)
sha256sum "$OUTPUT_FILE"
```

### macOS - Specific Commands

```bash
# macOS native hashing tools
md5 evidence.bin
shasum -a 256 evidence.bin
shasum -a 512 evidence.bin

# macOS 15 and later also ship md5sum / sha1sum / sha256sum / sha512sum as variants of md5(1) [verify 2026-10-30]
# Or install GNU coreutils via Homebrew (always available g-prefixed)
brew install coreutils
gmd5sum evidence.bin
gsha256sum evidence.bin
```

---

## 2. Forensic Tools (Professional Methods)

### FTK Imager

```
1. Open FTK Imager
2. File → Add Evidence Item → Select file/folder
3. Right-click evidence item → Verify Drive/Image
4. Tool automatically calculates MD5 and SHA1
5. Results displayed in Verify Results window
6. Record the computed and verified hash values in the collection log
```

Exterro's FTK Imager pages (current free release 8.3.1, Windows only) list MD5 and SHA-1 as its hash functions, with no SHA-256; compute SHA-256 separately with the §1 tools [verify 2026-10-30].

**Command line (FTK Imager CLI):**

The CLI is the legacy AccessData FTK Imager v3.1.1 CLI (2012). Exterro's current FTK Imager page does not offer a command-line edition, so confirm you have a copy before relying on it. Its usage text lists `--verify`, `--list-drives` and `--no-sha1`, and no SHA-256 option [verify 2026-10-30].

```cmd
REM Windows: verify an existing image (MD5 + SHA-1)
ftkimager.exe --verify "E:\evidence.dd"

REM List drives, then image and verify (MD5 + SHA-1; --no-sha1 skips SHA-1)
ftkimager.exe --list-drives > drives.txt
ftkimager.exe "\\.\PhysicalDrive1" "E:\image" --verify
REM The CLI appends the image-type extension to E:\image; add --e01 for E01 output
```

### md5deep / hashdeep

```bash
# Install (Debian/Ubuntu: the package is hashdeep; it also installs md5deep, sha1deep, sha256deep) [verify 2026-10-30]
sudo apt install hashdeep

# Calculate SHA-256 recursively
hashdeep -r -c sha256 /evidence > evidence_hashes.txt

# Audit mode (verify against known hashes)
hashdeep -r -c sha256 -a -k evidence_hashes.txt /evidence

# Multiple algorithms
hashdeep -r -c md5,sha1,sha256 /evidence > multi_hash.txt

# Match known malware hashes: -M takes no argument; the known set goes in -k [verify 2026-10-30]
# hashdeep -k only reads hashdeep-format files (e.g. output of hashdeep -c sha256)
hashdeep -r -M -k /path/to/malware_hashes.txt /suspect_files

# For a sha256sum-style list (hash, space, filename), use the md5deep-family matcher
sha256deep -r -m /path/to/malware_hashes.txt /suspect_files
```

### Autopsy / Sleuth Kit

```bash
# img_stat computes no hash: it prints image metadata and, for E01, the MD5 stored at acquisition [verify 2026-10-30]
# (other TSK tools do hash, e.g. tsk_loaddb -h computes per-file hashes)
img_stat evidence.E01

# Hash the media data of any image TSK can read (raw or E01) by streaming it [verify 2026-10-30]
img_cat evidence.E01 | sha256sum

# Hash a raw image with the standard tools
md5sum evidence.dd

# For disk images, use specialized tools
ewfverify image.E01  # Verify EnCase/EWF images
```

---

## 3. Third-Party Tools

### OpenHashTab (Windows - GUI)

HashTab (Implbits) is discontinued: hashtab.io no longer resolves and implbits.com is a parked domain, so do not install it from mirrors [verify 2026-10-30].
OpenHashTab is a maintained open-source shell extension that fills the same role (release 3.1.1, July 2025) [verify 2026-10-30].

```
1. Download: https://github.com/namazso/OpenHashTab/releases/latest
2. Right-click any file → Properties → OpenHashTab's hash tab
3. Select algorithms (MD5, SHA-1, SHA-256, SHA-3, BLAKE3, among others)
4. Check against a checksum file (*sum output, SFV or corz .hash) placed next to the file
5. Export hashes to a *sum-format file or copy them to the clipboard
```

### HashMyFiles (Windows - Portable)

```
1. Download from NirSoft: https://www.nirsoft.net/utils/hash_my_files.html
2. Drag-and-drop files/folders
3. Select hash algorithms (MD5, SHA1, CRC32, SHA-256, SHA-384, SHA-512)
4. File → Save Selected Items (Ctrl+S)
5. Export to TXT/HTML/XML/CSV for documentation (/stext, /shtml, /sxml, /scomma on the command line)
```

HashMyFiles' algorithm list and save formats are from NirSoft's v2.52 page [verify 2026-10-30].

### GtkHash (Linux - GUI)

```bash
# Install
sudo apt install gtkhash

# Launch
gtkhash

# GtkHash ships no CLI binary; script with sha256sum / b2sum (§1) instead [verify 2026-10-30]
```

### RapidCRC Unicode (Windows)

rapidcrc.net no longer resolves; the maintained fork is RapidCRC Unicode 0.3.42 (August 2026) from ov2.eu [verify 2026-10-30].

```
1. Download: https://www.ov2.eu/programs/rapidcrc-unicode (source: https://github.com/OV2/RapidCRC-Unicode)
2. Drag files to RapidCRC window
3. Create a checksum file from the main window or the shell-extension context menu
4. Saves .sfv, .md5, .sha1, .sha256 or .sha512 checksum files (prefer .sha256 for evidence)
5. Later: Drag the checksum file to RapidCRC to verify integrity
```

---

## 4. Hash Algorithm Selection

### Algorithm Comparison

| Algorithm | Output Length | Standard | Security Status | Speed | Use Case |
|-----------|---------------|----------|-----------------|-------|----------|
| **MD5**   | 128-bit (32 hex) | RFC 1321 (1992) | ❌ Broken — practical collisions (Wang et al. 2004) | Fast | Legacy compatibility / known-bad hash sets only |
| **SHA-1** | 160-bit (40 hex) | RFC 3174 / FIPS 180-4 | ❌ Broken — SHAttered collision (2017), chosen-prefix collision "SHA-1 is a Shambles" (2020); NIST transition announced 2022-12-15, completes 2030-12-31 [verify 2026-10-30] | Fast | Legacy systems and older hash sets (NSRL RDSv3 and VirusTotal also take SHA-256) |
| **SHA-256** | 256-bit (64 hex) | NIST FIPS 180-4 / RFC 6234 | ✅ Secure (~2^128 collision resistance via birthday bound) | Medium | **Recommended primary for forensics** |
| **SHA-512** | 512-bit (128 hex) | NIST FIPS 180-4 / RFC 6234 | ✅ Secure; speed relative to SHA-256 depends on CPU extensions (e.g., SHA-NI) | Medium | High-assurance / long-term archival |
| **SHA-3 (SHA3-256/384/512)** | 256/384/512-bit | NIST FIPS 202 (2015) | ✅ Secure (Keccak sponge — different construction from SHA-2) | Medium | Redundancy when paired with SHA-2; future-proofing |
| **SHAKE128 / SHAKE256** | Variable (XOF) | NIST FIPS 202 | ✅ Secure | Medium | Variable-length output (e.g., SLH-DSA signature internals) |
| **BLAKE2 (b2sum)** | 256/512-bit | RFC 7693 | ✅ Secure; faster than SHA-256 in software | Fast | Performance-sensitive integrity (used in Argon2, WireGuard) |
| **BLAKE3 (b3sum)** | 256-bit (extensible) | No NIST FIPS [inferred — not court-grade as primary] | ✅ Secure; parallelizable (`b3sum` is multithreaded) | Very Fast | Performance-critical integrity; **pair with SHA-256, do not use as sole primary** |
| **CRC32** | 32-bit | ISO/IEC 13239 / Ethernet | ❌ Not cryptographic | Very Fast | Error detection only — **never** for evidence |

Speed labels are rough and relative. The ranking depends on the CPU, because SHA extensions such as SHA-NI change it, so benchmark on the acquisition host (`openssl speed -evp sha256`, `openssl speed -evp sha512`) before choosing on speed. For BLAKE3, upstream reports multithreaded `b3sum` as an order of magnitude faster than `sha256sum` on typical desktop hardware (BLAKE3 README) [verify 2026-10-30].

### Current Best Practices

**Primary standard:**
```
SHA-256 — Recommended for all new evidence (NIST FIPS 180-4 baseline)
```

**Why SHA-256:**
- NIST approved (FIPS 180-4); also specified in RFC 6234.
- No known practical pre-image or collision attacks.
- Widely supported across forensic tools and OS-native utilities.
- Admissibility: in US federal courts, expert testimony is tested under FRE 702 (amended 2023-12-01; Daubert); state courts apply their own rules, and some still use Frye. Hash-verified copies can be self-authenticating under FRE 902(14) ("authenticated by a process of digital identification", with a qualified person's certification; 902(13) covers system-generated records). In England & Wales, the Forensic Science Regulator's statutory Code of Practice v2 (in force 2 October 2025) applies. Admissibility still depends on jurisdiction and documentation, not on the algorithm alone [verify 2026-10-30].
- 256-bit output → birthday-bound collision resistance ≈ 2^128 operations (preimage ≈ 2^256). Adequate against foreseeable classical attacks.

**When to use SHA-512:**
- Long-term archival (slower hash deprecation cycle).
- Hosts where SHA-512 measures faster than SHA-256 (CPU-dependent; benchmark with `openssl speed` first).
- Compliance regimes that require SHA-384 or SHA-512, e.g., NSA's CNSA 2.0 suite for US national security systems, which lists SHA-384 and SHA-512 (per draft-becker-cnsa2-tls-profile, an IETF Internet-Draft co-authored by NSA's Center for Cybersecurity Standards; work in progress) [verify 2026-10-30].

**When SHA-3 (FIPS 202) is appropriate:**
- Defensive redundancy against an unforeseen SHA-2 weakness — pair SHA-256 + SHA3-256 on critical evidence.
- Output-length flexibility via SHAKE128/256 (rare in forensics; common in PQ signature internals such as SLH-DSA).

**When MD5 is acceptable:**
- ⚠️ **ONLY** for deduplication in controlled environments.
- ⚠️ **ONLY** when a legacy tool or hash set offers nothing stronger (NSRL RDSv3 carries SHA-256 and VirusTotal accepts it; MD5 remains for older sets and tools) [verify 2026-10-30].
- ⚠️ **NEVER** as sole integrity verification in court.
- ⚠️ **ALWAYS** pair with SHA-256 when recorded.

**SHA-1 status (2022 retirement):**
- NIST announced the SHA-1 transition on **2022-12-15**; the transition completes **2030-12-31**. Before then NIST plans FIPS 180-5 (removing SHA-1; not yet published) and a revised SP 800-131A (Rev. 3 initial public draft 2024-10-21; not final as of 2026-10-30) [verify 2026-10-30].
- Acceptable only for backward-compatibility lookups (older hash sets and tools, git commit IDs). Pair with SHA-256.
- See SHAttered (2017) for the first practical collision and "SHA-1 is a Shambles" (2020) for the chosen-prefix collision.

### HMAC and Keyed Hashing

For tamper-evident logs where the verifier holds a secret key, use **HMAC-SHA256** (NIST FIPS 198-1) rather than a bare hash:

```bash
# Linux/macOS (the key is visible in the process list while this runs; use a single-user analysis host)
openssl dgst -sha256 -hmac "$SECRET_KEY" evidence.bin
```

```powershell
# Windows (PowerShell): stream the file (ReadAllBytes fails above 2 GB) via ComputeHash(Stream) [verify 2026-10-30]
# .NET resolves relative paths against the process directory, not Set-Location, so pass an absolute path
$hmac = [System.Security.Cryptography.HMACSHA256]::new([Text.Encoding]::UTF8.GetBytes($env:SECRET_KEY))
$fs = [IO.File]::OpenRead((Resolve-Path -LiteralPath "evidence.bin").ProviderPath)
try { [BitConverter]::ToString($hmac.ComputeHash($fs)).Replace("-","").ToLower() } finally { $fs.Dispose() }
```

HMAC is **not** a substitute for evidence hashing (chain-of-custody hashes must be reproducible by anyone holding the artefact); it is for log/manifest authenticity where unauthorized modification by an attacker who reads the log must be detectable. See NIST SP 800-107 Rev. 1 for guidance on approved hash applications; on 2022-12-20 NIST announced its decision to withdraw it (CSRC still lists it as final) and moved the supplementary material to the CSRC Hash Functions page [verify 2026-10-30].

### Quantum-era considerations

- **Grover's algorithm** halves effective hash bit-strength against a quantum adversary: SHA-256 retains ≈ 2^128 preimage security, still adequate.
- **No PQ migration urgency for hashing** (unlike signatures: NIST FIPS 203 ML-KEM, FIPS 204 ML-DSA, FIPS 205 SLH-DSA, all finalized 2024-08). SLH-DSA is built on SHA-256/SHA-512 (SHA2 parameter sets) or SHAKE256 (SHAKE parameter sets) [verify 2026-10-30], which confirms forensic continuity for evidence hashing into the PQ era.

### Out-of-scope hashing families (this SOP is cryptographic-only)

- **Fuzzy / similarity hashing** (ssdeep / sdhash / TLSH / mrsh-v2) — used to *group similar* binaries, not to verify exact integrity. Belongs in [[sop-malware-analysis|Malware Analysis]] (sample clustering).
- **Perceptual hashing** (pHash / dHash / aHash / PhotoDNA) — used for image/video similarity (CSAM detection, deduplication). Belongs in [[../../Investigations/Techniques/sop-image-video-osint|Image & Video OSINT]]. **PhotoDNA is operator-access only.**
- **Password KDFs** (Argon2id, scrypt, bcrypt, PBKDF2) — out of scope for evidence integrity; see [[sop-cryptography-analysis|Cryptography Analysis]].

### Collision Attack Examples

**MD5 collision (illustrative; practical collisions since Wang et al. 2004, meaningful chosen-prefix pairs via HashClash):** [verify 2026-10-30]
```
# Two different files with identical MD5 hash
File1: "Hello World\n" + malicious_code
File2: "Hello World\n" + benign_code
MD5(File1) == MD5(File2)  # Same hash, different content!
```

**SHA-1 collision (SHAttered, 2017):**
```
# Two different PDF files with same SHA-1
https://shattered.io/
# Proof that SHA-1 is no longer secure
```

**SHA-1 chosen-prefix collision (SHA-1 is a Shambles, 2020):** https://sha-mbles.github.io/ shows collisions with attacker-chosen prefixes (demonstrated on PGP/GnuPG keys), the practically relevant break [verify 2026-10-30].

---

## 5. Evidence Collection Workflow

### Step-by-Step Process

**1. Immediate Acquisition (T+0 minutes)**
```powershell
# Windows - Calculate hash immediately after copying evidence
Copy-Item -Path "\\suspect-pc\C$\evidence.bin" -Destination "E:\CASE-001\evidence.bin"
$hash = Get-FileHash -Path "E:\CASE-001\evidence.bin" -Algorithm SHA256
$hash.Hash | Out-File "E:\CASE-001\evidence_SHA256.txt"
Write-Host "SHA256: $($hash.Hash)"
```

```bash
# Linux - Calculate hash during copy: dd writes to stdout (no of=), tee writes the image
# (with of= set, dd sends nothing down the pipe and you would hash empty input) [verify 2026-10-30]
# Without pipefail a failed dd exits 0 and records the empty-input hash e3b0c442... [verify 2026-10-30]
set -o pipefail
dd if=/dev/sdb bs=512 conv=noerror,sync | tee /evidence/disk.dd | sha256sum > /evidence/disk_SHA256.txt
# dc3dd, dcfldd and ewfacquire hash during acquisition without the pipe (§6, §11)

# Verify the written image; the digest must match the acquisition hash above
sha256sum /evidence/disk.dd | tee /evidence/disk_SHA256_verify.txt
# Sizes must match (blockdev --getsize64 prints the device size in bytes)
blockdev --getsize64 /dev/sdb; stat -c%s /evidence/disk.dd
```

**2. Chain of Custody Documentation (T+5 minutes)**
```markdown
# Evidence Log - CASE-2025-1005-001

## Acquisition
- **Date/Time:** 2025-10-05 14:30:00 UTC
- **Source:** Laptop (HOSTNAME: SUSPECT-PC)
- **Path:** C:\Users\suspect\Documents\evidence.bin
- **Acquired By:** Analyst Name
- **Method:** Physical copy via USB write-blocker

## Hash Values (Acquisition)
- **SHA-256:** a1b2c3d4e5f6789012345678901234567890123456789012345678901234567890
- **SHA-1:**   1234567890abcdef1234567890abcdef12345678
- **MD5:**     12345678901234567890123456789012
- **Algorithm:** SHA-256 (primary)
- **Tool:** Get-FileHash (PowerShell 5.1)

## Verification Log
| Date | Time (UTC) | Result | Hash Match | Analyst |
|------|------------|--------|------------|---------|
| 2025-10-05 | 14:30 | ✓ VERIFIED | SHA-256 match | analyst1 |
| 2025-10-06 | 09:00 | ✓ VERIFIED | SHA-256 match | analyst2 |
| 2025-10-07 | 11:15 | ✗ MISMATCH | SHA-256 FAIL | analyst1 |

## Notes
- 2025-10-07 mismatch: File was re-acquired from backup. New hash documented below.
```

**3. Periodic Re-Verification (Daily/Before Analysis)**
```powershell
# Automated verification script
$evidencePath = "E:\CASE-001\evidence.bin"
$knownHashFile = "E:\CASE-001\evidence_SHA256.txt"
$knownHash = (Get-Content $knownHashFile).Trim()
$currentHash = (Get-FileHash -Path $evidencePath -Algorithm SHA256).Hash

$result = @{
    # 'u' is culture-invariant (e.g. 2026-10-30 21:30:00Z); convert to UTC first, because 'u' does not convert [verify 2026-10-30]
    Timestamp = (Get-Date).ToUniversalTime().ToString('u')
    Analyst = $env:USERNAME
    FilePath = $evidencePath
    KnownHash = $knownHash
    CurrentHash = $currentHash
    Match = ($currentHash -eq $knownHash)
}

if ($result.Match) {
    Write-Host "✓ VERIFIED: Evidence integrity maintained" -ForegroundColor Green
    Add-Content -Path "E:\CASE-001\verification_log.txt" -Value "$($result.Timestamp) - VERIFIED by $($result.Analyst)"
} else {
    Write-Host "✗ CRITICAL: Evidence integrity compromised!" -ForegroundColor Red
    Write-Host "Expected: $knownHash"
    Write-Host "Got:      $currentHash"
    Add-Content -Path "E:\CASE-001\verification_log.txt" -Value "$($result.Timestamp) - MISMATCH detected by $($result.Analyst) - INVESTIGATION REQUIRED"
}
```

**4. Transfer Verification**
```bash
# Sender side (create manifest)
sha256sum evidence.bin > evidence_SHA256.txt
tar -czf evidence_package.tar.gz evidence.bin evidence_SHA256.txt

# Receiver side (verify after transfer)
tar -xzf evidence_package.tar.gz
sha256sum -c evidence_SHA256.txt
# Output: evidence.bin: OK
```

---

## 6. Advanced Use Cases

### Malware Sample Deduplication

```bash
# Build malware sample database
find /malware_samples -type f -exec sha256sum {} \; | sort > malware_hashes.txt

# Check if new sample is already in database
NEW_HASH=$(sha256sum new_sample.exe | awk '{print $1}')
if grep -q "$NEW_HASH" malware_hashes.txt; then
    echo "Duplicate sample - already analyzed"
else
    echo "New sample - requires analysis"
    echo "$NEW_HASH new_sample.exe" >> malware_hashes.txt
fi
```

### Disk Image Verification

```bash
# Create disk image with verification (the hash-log option is hlog=; there is no hashlog=) [verify 2026-10-30]
dc3dd if=/dev/sdb of=evidence.dd hash=sha256 hash=md5 hlog=evidence_hashes.txt

# Verify disk image later (of=/dev/null: without of=, dc3dd writes the image to stdout)
dc3dd if=evidence.dd of=/dev/null hash=sha256 hlog=verification.txt
# Compare the digest lines, not whole logs (logs include timestamps and the command line)
grep '(sha256)' evidence_hashes.txt verification.txt
```

### Network Transfer Integrity

```bash
# Sender: Calculate hash before upload
sha256sum evidence.bin > evidence.sha256
rsync -avz evidence.bin evidence.sha256 analyst@server:/evidence/

# Receiver: Verify after download
cd /evidence
sha256sum -c evidence.sha256
```

### Large File Streaming Hash

```bash
# Hash file while reading (doesn't load entire file into memory)
sha256sum large_image.dd
# Works for files larger than available RAM

# Or with progress bar (requires pv)
pv large_image.dd | sha256sum
```

---

## 7. Troubleshooting & Common Issues

### Hash Mismatch Scenarios

**1. Line Ending Differences (Text Files)**
```bash
# Windows (CRLF) vs Linux (LF) line endings cause different hashes
# On Windows:
certutil -hashfile document.txt SHA256
# Result: a1b2c3d4...

# Same file on Linux:
sha256sum document.txt
# Result: b2c3d4e5... (DIFFERENT!)

# Solution: Use binary comparison or normalize line endings
dos2unix document.txt  # Convert to Unix
unix2dos document.txt  # Convert to Windows
```

**2. Filesystem Metadata vs Content**
```bash
# Standard hashing tools (sha256sum, md5deep/hashdeep, Get-FileHash) hash content only;
# timestamps, permissions and other filesystem metadata are not part of the digest
sha256sum file.bin

# md5deep/hashdeep -l only switches output to relative paths [verify 2026-10-30]
# Record metadata separately in the manifest
stat file.bin
```

**3. File Locking**
```powershell
# Windows: File in use by another process
Get-FileHash evidence.bin
# Error: The process cannot access the file because it is being used by another process

# Solution: Use handle.exe to find locking process
handle.exe evidence.bin
# Or reboot into forensic boot environment
```

**4. Symbolic Links**
```bash
# Hash follows symlink (hashes target file)
sha256sum /path/to/symlink  # Hashes target

# sha256sum has no option to hash the link itself (no -L flag) [verify 2026-10-30]

# Best practice: Resolve symlinks first and log the readlink -f output in the manifest
readlink -f /path/to/symlink
sha256sum /actual/target/path
```

### Performance Optimization

**Parallel hashing (multiple files):**
```bash
# GNU parallel (fastest for many files); -0 reads the NUL-delimited -print0 list, safe for any filename [verify 2026-10-30]
find /evidence -type f -print0 | parallel -0 -j 8 sha256sum {} > all_hashes.txt

# Or xargs (NUL-delimited, safe for spaces and newlines in names) [verify 2026-10-30]
find /evidence -type f -print0 | xargs -0 -P 8 -n 1 sha256sum
```

**Large file optimization:**
```bash
# sha256sum already streams large files (§6); piping through dd adds nothing [verify 2026-10-30]
# For directory trees, use the hashdeep suite
sha256deep -r /evidence  # Optimized for forensics
```

---

## 8. Chain of Custody Best Practices

### Documentation Template

```markdown
# Evidence Hash Verification Form

**Case Number:** CASE-2025-1005-001
**Evidence ID:** EV-001
**Description:** Laptop hard drive image

## Initial Hash (Acquisition)
- **Date/Time:** 2025-10-05 14:30:00 UTC
- **Calculated By:** John Doe (Analyst ID: A123)
- **Algorithm:** SHA-256
- **Hash Value:** a1b2c3d4e5f6789012345678901234567890123456789012345678901234567890
- **Tool:** sha256sum (GNU coreutils 9.4)
- **Signature:** [Digital signature or initials]

## Verification Record

### Verification 1
- **Date/Time:** 2025-10-06 09:00:00 UTC
- **Verified By:** Jane Smith (Analyst ID: A456)
- **Result:** ✓ MATCH
- **Signature:** [Digital signature or initials]

### Verification 2
- **Date/Time:** 2025-10-07 11:15:00 UTC
- **Verified By:** John Doe (Analyst ID: A123)
- **Result:** ✗ MISMATCH
- **Action Taken:** Evidence re-acquired from backup. New hash documented.
- **Incident Report:** INC-2025-1007-001
- **Signature:** [Digital signature or initials]

## Transfer Log
| Date | From | To | Method | Hash Verified | Signature |
|------|------|-----|--------|---------------|-----------|
| 2025-10-05 | Crime Scene | Lab | USB 3.0 | ✓ | JD |
| 2025-10-06 | Lab | Storage | Network | ✓ | JS |
```

### Automated Logging Script

```powershell
# evidence_tracker.ps1
param(
    [string]$EvidencePath,
    [string]$CaseNumber
)

$logPath = "E:\Cases\$CaseNumber\hash_verification_log.csv"

# Calculate current hash
$hash = Get-FileHash -Path $EvidencePath -Algorithm SHA256

# Log entry
$entry = [PSCustomObject]@{
    # 'u' is culture-invariant (e.g. 2026-10-30 21:30:00Z); convert to UTC first, because 'u' does not convert [verify 2026-10-30]
    Timestamp = (Get-Date).ToUniversalTime().ToString('u')
    CaseNumber = $CaseNumber
    FilePath = $EvidencePath
    SHA256 = $hash.Hash
    Analyst = $env:USERNAME
    Computername = $env:COMPUTERNAME
}

# Append to log
$entry | Export-Csv -Path $logPath -Append -NoTypeInformation

Write-Host "Hash logged: $($hash.Hash)"
```

---

## 9. Integration with Forensic Tools

### Autopsy / Sleuth Kit Integration

```bash
# Calculate hash during Autopsy ingest
# Autopsy's Hash Lookup ingest module calculates MD5 and SHA-256 for the files it processes
# (SHA-256 is not used for hash-set matching) [verify 2026-10-30]

# Query Autopsy database for file hashes
sqlite3 autopsy.db "SELECT name, md5, sha256 FROM tsk_files WHERE md5 IS NOT NULL;"

# Export hash list
sqlite3 -csv autopsy.db "SELECT md5, sha256, name FROM tsk_files;" > autopsy_hashes.csv

# Hash sets import as md5sum/md5deep text, Autopsy .idx/.kdb, EnCase .hash or HashKeeper .hsh;
# NSRL is offered in the .idx format [verify 2026-10-30]
```

### EnCase / FTK Integration

```
# EnCase and FTK compute file hashes during evidence processing.
# Menu paths for viewing and exporting hashes vary by version and are not publicly
# documented: follow the vendor manual for your release and record the tool
# version in the custody log [verify 2026-10-30]
```

### Volatility (Memory Forensics)

```bash
# Hash memory dump
sha256sum memory.dmp > memory_SHA256.txt

# Volatility does not check dump integrity for you; Volatility 2 (vol.py --profile) is archived [verify 2026-10-30]
vol -f memory.dmp windows.pslist

# Re-hash after analysis and compare
sha256sum -c memory_SHA256.txt
```

---

## 10. Tools Reference

| Tool | Platform | Type | Use Case | Link |
|------|----------|------|----------|------|
| certutil | Windows | Built-in | Quick hashing | Built-in |
| Get-FileHash | Windows | Built-in | PowerShell automation | Built-in |
| sha256sum / shasum -a 256 | Linux / macOS | Built-in | Command-line hashing | Built-in |
| md5deep/hashdeep | Cross-platform | CLI | Recursive hashing, audit | [GitHub](https://github.com/jessek/hashdeep) |
| OpenHashTab | Windows | GUI | Right-click integration (replaces discontinued HashTab) | [GitHub](https://github.com/namazso/OpenHashTab) |
| HashMyFiles | Windows | GUI | Batch processing | [NirSoft](https://www.nirsoft.net/utils/hash_my_files.html) |
| FTK Imager | Windows | GUI (legacy CLI) | Forensic imaging + hash (MD5/SHA-1) | [Exterro](https://www.exterro.com/digital-forensics-software/ftk-imager) |
| GtkHash | Linux | GUI | GTK-based hashing | [gtkhash](https://github.com/gtkhash/gtkhash) |
| RapidCRC Unicode | Windows | GUI | SFV/MD5/SHA checksum files | [ov2.eu](https://www.ov2.eu/programs/rapidcrc-unicode) |

Links and tool status checked 2026-10-30: hashtab.io and rapidcrc.net no longer resolve, Exterro moved the FTK Imager page, and GtkHash moved to the gtkhash organisation [verify 2026-10-30].

---

**Best Practice Summary:**
- ✅ Use SHA-256 (NIST FIPS 180-4) as the primary hash for all new evidence.
- ✅ Calculate hash immediately upon acquisition; record before any other operation.
- ✅ Verify hash before and after every transfer or movement (hash-on-acquisition / hash-after-transport).
- ✅ Log all verifications in chain of custody with analyst, timestamp (UTC), and tool version.
- ✅ For critical evidence, pair algorithms with **different constructions** (SHA-256 + SHA3-256, or SHA-256 + BLAKE2/3) so a single-family weakness does not invalidate both.
- ✅ Sign manifests (GPG detached signature, minisign, or `ssh-keygen -Y sign`; age only encrypts and cannot sign) [verify 2026-10-30] and consider RFC 3161 / OpenTimestamps anchoring for non-repudiation.
- ❌ Never rely on MD5 or SHA-1 alone for court evidence.
- ❌ Never use BLAKE3 as the sole forensic primary (no NIST FIPS standardization yet) [inferred].
- ❌ Never skip hash verification before analysis.

---

## 11. Reference Resources

### Hash Algorithm Standards & Documentation
- **NIST FIPS 180-4** — [nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.180-4.pdf](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.180-4.pdf)
  - Official SHA-1 / SHA-2 family specification (SHA-1, SHA-224, SHA-256, SHA-384, SHA-512, SHA-512/224, SHA-512/256).
- **NIST FIPS 202** — [nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.202.pdf](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.202.pdf)
  - SHA-3 standard (Keccak): SHA3-224/256/384/512, SHAKE128, SHAKE256.
- **NIST FIPS 198-1** — [nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.198-1.pdf](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.198-1.pdf)
  - HMAC (keyed-hash message authentication code).
- **NIST SP 800-107 Rev. 1** — [csrc.nist.gov/pubs/sp/800/107/r1/final](https://csrc.nist.gov/pubs/sp/800/107/r1/final)
  - Recommendation for Applications Using Approved Hash Algorithms. Decision to withdraw it announced 2022-12-20 (CSRC still lists it as final); supplementary material moved to the CSRC Hash Functions page [verify 2026-10-30].
- **NIST SHA-1 transition notice** — [csrc.nist.gov/news/2022/nist-transitioning-away-from-sha-1-for-all-apps](https://csrc.nist.gov/news/2022/nist-transitioning-away-from-sha-1-for-all-apps)
  - 2022-12-15 announcement; transition completes 2030-12-31; FIPS 180-5 and SP 800-131A Rev. 3 still pending [verify 2026-10-30].
- **NIST Hash Functions Portal** — [csrc.nist.gov/projects/hash-functions](https://csrc.nist.gov/projects/hash-functions)
  - Cryptographic hash function projects and research.
- **RFC 1321 (MD5)** — [datatracker.ietf.org/doc/html/rfc1321](https://datatracker.ietf.org/doc/html/rfc1321)
  - MD5 specification (1992, historical/broken).
- **RFC 3174 (SHA-1)** — [datatracker.ietf.org/doc/html/rfc3174](https://datatracker.ietf.org/doc/html/rfc3174)
  - US Secure Hash Algorithm 1 (2001).
- **RFC 6234 (SHA-2 family + HMAC-SHA)** — [datatracker.ietf.org/doc/html/rfc6234](https://datatracker.ietf.org/doc/html/rfc6234)
  - Reference implementation for SHA-224/256/384/512 and HMAC variants.
- **RFC 7693 (BLAKE2)** — [datatracker.ietf.org/doc/html/rfc7693](https://datatracker.ietf.org/doc/html/rfc7693)
  - BLAKE2b / BLAKE2s / BLAKE2x cryptographic hash and MAC.
- **BLAKE3 specification** — [github.com/BLAKE3-team/BLAKE3-specs](https://github.com/BLAKE3-team/BLAKE3-specs)
  - Whitepaper (2020); no NIST FIPS standardization as of 2026-10 (not listed on the CSRC Hash Functions page) [verify 2026-10-30].
- **RFC 3161 (Time-Stamp Protocol)** — [datatracker.ietf.org/doc/html/rfc3161](https://datatracker.ietf.org/doc/html/rfc3161)
  - PKI timestamping for non-repudiable hash anchoring.
- **OpenTimestamps** — [opentimestamps.org](https://opentimestamps.org/)
  - Bitcoin-anchored timestamping for hash manifests.

### Digital Forensics Standards
- **NIST SP 800-86** - [csrc.nist.gov/pubs/sp/800/86/final](https://csrc.nist.gov/pubs/sp/800/86/final)
  - Guide to Integrating Forensic Techniques into Incident Response
- **ISO/IEC 27037:2012** - [iso.org](https://www.iso.org/standard/44381.html)
  - Guidelines for identification, collection, acquisition, and preservation of digital evidence
- **Scientific Working Group on Digital Evidence (SWGDE)** - [swgde.org](https://www.swgde.org/)
  - Best practices for digital evidence handling
- **National Institute of Justice (NIJ)** - [nij.ojp.gov/topics/forensics/digital-multimedia-evidence](https://nij.ojp.gov/topics/forensics/digital-multimedia-evidence)
  - Digital evidence best practices

### Hash Collision Research
- **SHAttered Attack** - [shattered.io](https://shattered.io/)
  - First practical SHA-1 collision (2017)
  - Demonstrates why SHA-1 should be deprecated
- **MD5 Collision Vulnerabilities** - [eprint.iacr.org/2004/199](https://eprint.iacr.org/2004/199)
  - Wang et al. MD5 collision research (2004)
- **HashClash Project** - [github.com/cr-marcstevens/hashclash](https://github.com/cr-marcstevens/hashclash)
  - MD5 and SHA-1 collision tools (academic research)

### Forensic Hashing Tools
- **md5deep/hashdeep** - [github.com/jessek/hashdeep](https://github.com/jessek/hashdeep)
  - Recursive hash computation and audit
  - Cross-platform, forensically sound
- **HashMyFiles (NirSoft)** - [nirsoft.net/utils/hash_my_files.html](https://www.nirsoft.net/utils/hash_my_files.html)
  - Portable Windows hash calculator
- **GtkHash** - [github.com/gtkhash/gtkhash](https://github.com/gtkhash/gtkhash)
  - Linux GTK-based hash calculator

### Forensic Imaging Tools (with Hash Verification)
- **FTK Imager** — [exterro.com/digital-forensics-software/ftk-imager](https://www.exterro.com/digital-forensics-software/ftk-imager)
  - Free forensic imaging tool with automatic hash verification.
  - Exterro documents MD5 and SHA-1 only (no SHA-256); compute SHA-256 with the §1 tools [verify 2026-10-30].
- **dc3dd** — [sourceforge.net/projects/dc3dd](https://sourceforge.net/projects/dc3dd/)
  - Enhanced dd with on-the-fly hashing, originally from the DoD Cyber Crime Center; upstream 7.3.1 (2023) is packaged in Debian. `dcfldd` is maintained again (v1.9.3, 2025). Use `ewfacquire` for E01/Ex01 and `dc3dd`/`dcfldd` for raw images with on-the-fly hashes. The 7.3.1 package reports itself as 7.2.646 in `--version` and in its hash logs, so record the version the binary prints, plus the package version (e.g. `dpkg -s dc3dd`) [verify 2026-10-30].
- **Guymager** — [guymager.sourceforge.io](https://guymager.sourceforge.io/)
  - Linux forensic imager with MD5/SHA verification.
- **ewfacquire (libewf)** — [github.com/libyal/libewf](https://github.com/libyal/libewf)
  - Expert Witness Format (E01/Ex01) imaging; the E01 container embeds MD5, plus SHA-1 when `-d sha1` is given, but never SHA-256. Add `-d sha256` and `-l <log>` so a SHA-256 is computed during acquisition and written to the log for the custody record, and recompute it later with `ewfverify -d sha256 image.E01` [verify 2026-10-30].

### Online Hash Lookup Services
- **VirusTotal** - [virustotal.com](https://www.virustotal.com/)
  - Malware hash lookup (MD5, SHA1, SHA256)
  - Submit samples or search by hash
- **NSRL (National Software Reference Library)** - [nist.gov/…/national-software-reference-library-nsrl](https://www.nist.gov/itl/csd/secure-systems-and-applications/national-software-reference-library-nsrl)
  - Reference hash database of known software
  - Filter out known-good files from forensic analysis
  - RDSv3 (SQLite) carries SHA-256, SHA-1 and MD5; the RDS 2.x text format is discontinued [verify 2026-10-30]
- **CIRCL hashlookup** - [hashlookup.circl.lu](https://hashlookup.circl.lu/)
  - Public known-file lookup API that includes an NSRL RDS import from 2023 (its /info endpoint reports nsrl-version 2023.09.2); MD5, SHA-1 and SHA-256 lookups [verify 2026-10-30]
- **MalwareBazaar** - [bazaar.abuse.ch](https://bazaar.abuse.ch/)
  - Malware sample hash database
  - Community-driven malware intelligence
- **ThreatFox** - [threatfox.abuse.ch](https://threatfox.abuse.ch/)
  - IOC database including file hashes

### Training & Certification
- **SANS FOR500: Windows Forensic Analysis** - Hash verification techniques
- **SANS FOR508: Advanced Incident Response** - Evidence integrity practices
- **EnCase Certified Examiner (EnCE)** - Includes hash verification methodologies
- **CHFI (Computer Hacking Forensic Investigator)** - EC-Council certification covering evidence handling

### Community & Forums
- **Forensic Focus Forums** - [forensicfocus.com](https://www.forensicfocus.com/)
  - Digital forensics community
- **Reddit r/computerforensics** - [reddit.com/r/computerforensics](https://www.reddit.com/r/computerforensics/)
  - Forensic practitioners community

### Automation Scripts & Tools
- **PowerForensics** - [github.com/Invoke-IR/PowerForensics](https://github.com/Invoke-IR/PowerForensics)
  - PowerShell raw-disk/NTFS forensic framework (last repository activity 2023)
  - No dedicated hash-verification cmdlets; pair with `Get-FileHash` [verify 2026-10-30]

---

## Legal & Ethical Considerations

Hash generation is a methodology, not an authorization. The SOP focuses on technical correctness; jurisdictional rules, evidence handling authority, and disclosure obligations are governed elsewhere in the vault.

> **Authorized environments only.** See [[sop-legal-ethics|Legal & Ethics]] for canonical jurisdictional framing (CFAA, CMA, EU e-Evidence Regulation 2023/1543, applicable from 2026-08-18, and Directive 2023/1544, GDPR Art. 6/9) [verify 2026-10-30], and [[sop-collection-log|Collection Log]] for the chain-of-custody rules into which hash records are integrated.

Hashing-specific guardrails:

- **Hash through a write-blocker, verify the copy.** For physical media, compute the acquisition hash of the source behind a hardware write-blocker and the verification hash of the image; both go in the log. On a live, mounted system, hash the acquired copy, because reading a mounted filesystem can update access times [verify 2026-10-30].
- **Record tool + version.** A SHA-256 value is reproducible only if the algorithm and reader are unambiguous. Record `sha256sum --version`, `$PSVersionTable.PSVersion` (PowerShell), or the Windows build from `ver` (certutil ships with the OS) alongside the hash [verify 2026-10-30].
- **Two-analyst attestation.** Critical evidence should be hashed by the acquiring analyst and re-hashed by an independent verifier; both hashes go into the chain of custody.
- **Disclosure.** Hash manifests are part of the evidence package. See [[../../Investigations/Techniques/sop-reporting-packaging-disclosure|Reporting, Packaging & Disclosure]].

---

## Related SOPs

**Methodology & governance:**
- [[sop-legal-ethics|Legal & Ethics]] — canonical jurisdictional framing
- [[sop-opsec-plan|OPSEC Plan]] — handler/host hygiene during evidence handling
- [[../../Investigations/Techniques/sop-collection-log|Collection Log]] — chain-of-custody record into which hash values are integrated
- [[../../Investigations/Techniques/sop-reporting-packaging-disclosure|Reporting, Packaging & Disclosure]] — hash manifests in deliverable packages

**Analysis:**
- [[sop-malware-analysis|Malware Analysis]] — hash-based sample identification and deduplication
- [[sop-cryptography-analysis|Cryptography Analysis]] — algorithm security analysis (length-extension, collision, hashcat modes)
- [[sop-reverse-engineering|Reverse Engineering]] — file integrity during binary analysis
- [[sop-forensics-investigation|Forensics Investigation]] — evidence acquisition

**Pentesting & Security:**
- [[../Pentesting/sop-detection-evasion-testing|Detection Evasion Testing]] — hash-based malware detection bypass techniques

---

**Version:** 1.1
**Last Updated:** 2026-10-30
**Review Frequency:** Annual (slow-rot anchor SOP — algorithm-standards horizon is multi-year)
