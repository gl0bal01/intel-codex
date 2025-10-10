# Hash Generation Methods for Evidence Integrity

## Overview

**Purpose:** Hash values provide cryptographic fingerprints of digital evidence, ensuring integrity, authenticity, and non-repudiation throughout the investigation lifecycle. Any modification to the file will result in a completely different hash value, making tampering immediately detectable.

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
# SHA-256 (Recommended for forensics)
certutil -hashfile "evidence.bin" SHA256

# Output:
# SHA256 hash of evidence.bin:
# a1b2c3d4e5f6789012345678901234567890123456789012345678901234567890
# CertUtil: -hashfile command completed successfully.

# Multiple algorithms at once (batch script)
@echo off
echo Hashing: %1
certutil -hashfile "%1" MD5 | findstr /v "hash CertUtil"
certutil -hashfile "%1" SHA1 | findstr /v "hash CertUtil"
certutil -hashfile "%1" SHA256 | findstr /v "hash CertUtil"
certutil -hashfile "%1" SHA512 | findstr /v "hash CertUtil"

# Save to file with timestamp
certutil -hashfile "evidence.bin" SHA256 > "%DATE:/=-%_%TIME::=-%_evidence_hash.txt"
```

**Batch processing multiple files:**
```cmd
# Hash all files in directory
for %f in (C:\Evidence\*) do @certutil -hashfile "%f" SHA256 | findstr /v "hash CertUtil" >> evidence_hashes.txt

# With filenames
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
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
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
# Output: a1b2c3d4e5f6... evidence.bin

# MD5
md5sum evidence.bin

# SHA-1
sha1sum evidence.bin

# SHA-512
sha512sum evidence.bin

# Multiple algorithms
echo "MD5:    $(md5sum evidence.bin | awk '{print $1}')"
echo "SHA1:   $(sha1sum evidence.bin | awk '{print $1}')"
echo "SHA256: $(sha256sum evidence.bin | awk '{print $1}')"
```

**Batch processing:**
```bash
# Hash all files in directory
find /evidence -type f -exec sha256sum {} \; > evidence_hashes.txt

# With formatted output
find /evidence -type f -print0 | while IFS= read -r -d '' file; do
    echo "File: $file"
    echo "SHA256: $(sha256sum "$file" | awk '{print $1}')"
    echo "Size: $(stat -f%z "$file") bytes"
    echo "Modified: $(stat -f%Sm "$file")"
    echo "---"
done > evidence_manifest.txt

# Create checksums file for verification
sha256sum /evidence/* > SHA256SUMS

# Verify integrity later
sha256sum -c SHA256SUMS
# Output:
# evidence1.bin: OK
# evidence2.bin: OK
# evidence3.bin: FAILED
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

find "$EVIDENCE_DIR" -type f | while read -r file; do
    echo "File: $file" >> "$OUTPUT_FILE"
    echo "Size: $(stat -f%z "$file" 2>/dev/null || stat -c%s "$file") bytes" >> "$OUTPUT_FILE"
    echo "Modified: $(stat -f%Sm "$file" 2>/dev/null || stat -c%y "$file")" >> "$OUTPUT_FILE"
    echo "MD5:    $(md5sum "$file" | awk '{print $1}')" >> "$OUTPUT_FILE"
    echo "SHA256: $(sha256sum "$file" | awk '{print $1}')" >> "$OUTPUT_FILE"
    echo "---" >> "$OUTPUT_FILE"
done

# Sign the manifest
sha256sum "$OUTPUT_FILE"
```

### macOS - Specific Commands

```bash
# macOS uses different stat syntax
md5 evidence.bin
shasum -a 256 evidence.bin
shasum -a 512 evidence.bin

# Or use coreutils versions (if installed via Homebrew)
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
6. Export verification log: File → Export Verification Results
```

**Command line (FTK Imager CLI):**
```cmd
# Windows
ftkimager.exe --verify "E:\evidence.dd"

# Generate hash report
ftkimager.exe --list-drives > drives.txt
ftkimager.exe "\\.\PhysicalDrive1" "E:\image.dd" --verify --sha256
```

### md5deep / hashdeep

```bash
# Install (Linux)
sudo apt install md5deep

# Calculate SHA-256 recursively
hashdeep -r -c sha256 /evidence > evidence_hashes.txt

# Audit mode (verify against known hashes)
hashdeep -r -c sha256 -a -k evidence_hashes.txt /evidence

# Multiple algorithms
hashdeep -r -c md5,sha1,sha256 /evidence > multi_hash.txt

# Match known malware hashes
hashdeep -M /path/to/malware_hashes.txt -r /suspect_files
```

### Autopsy / Sleuth Kit

```bash
# Calculate hash using Sleuth Kit
img_stat -h evidence.dd

# Or md5sum equivalent
md5sum evidence.dd

# For disk images, use specialized tools
ewfverify image.E01  # Verify EnCase/EWF images
```

---

## 3. Third-Party Tools

### HashTab (Windows - GUI)

```
1. Download: https://hashtab.io/
2. Right-click any file → Properties
3. "File Hashes" tab appears
4. Select algorithms: MD5, SHA-1, SHA-256
5. Compare hash against known value
6. Copy hash to clipboard
```

### HashMyFiles (Windows - Portable)

```
1. Download from NirSoft: https://www.nirsoft.net/utils/hash_my_files.html
2. Drag-and-drop files/folders
3. Select hash algorithms (MD5/SHA1/SHA256/CRC32)
4. File → Save Selected Items (Ctrl+S)
5. Export to CSV/TXT/HTML for documentation
```

### GtkHash (Linux - GUI)

```bash
# Install
sudo apt install gtkhash

# Launch
gtkhash

# Or command line
gtkhash-cli -a md5,sha1,sha256 evidence.bin
```

### RapidCRC Unicode (Windows)

```
1. Download: https://www.rapidcrc.net/
2. Drag files to RapidCRC window
3. Right-click → Create SFV/MD5 file
4. Saves .sfv or .md5 checksum file
5. Later: Drag .sfv file to verify integrity
```

---

## 4. Hash Algorithm Selection

### Algorithm Comparison

| Algorithm | Output Length | Security Status | Speed | Use Case |
|-----------|---------------|-----------------|-------|----------|
| **MD5**   | 128-bit (32 hex) | ❌ Broken (collision attacks) | Fast | Legacy compatibility only |
| **SHA-1** | 160-bit (40 hex) | ⚠️ Deprecated (SHAttered attack 2017) | Fast | Legacy systems |
| **SHA-256** | 256-bit (64 hex) | ✅ Secure | Medium | **Recommended for forensics** |
| **SHA-512** | 512-bit (128 hex) | ✅ Secure | Medium | High-security evidence |
| **SHA-3** | Variable | ✅ Secure (latest standard) | Medium | Future-proofing |
| **CRC32** | 32-bit | ❌ Not cryptographic | Very Fast | Error detection only |

### Current Best Practices (2025)

**Primary standard:**
```
SHA-256 - Recommended for all new evidence
```

**Why SHA-256:**
- NIST approved (FIPS 180-4)
- No known practical attacks
- Widely supported across forensic tools
- Court admissible (Daubert/Frye standards)
- Balance of security and performance
- 2^256 possible values (effectively collision-proof)

**When to use SHA-512:**
- Critical national security evidence
- Long-term archival (50+ years)
- When disk I/O is not a bottleneck
- Compliance requirements (CMMC Level 5, FedRAMP High)

**When MD5 is acceptable:**
- ⚠️ **ONLY** for deduplication in controlled environments
- ⚠️ **ONLY** when comparing against legacy databases
- ⚠️ **NEVER** as sole integrity verification in court
- ⚠️ **ALWAYS** pair with SHA-256 when used

### Collision Attack Examples

**MD5 collision (2004):**
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
# Linux - Calculate hash during copy with tee
dd if=/dev/sdb of=/evidence/disk.dd bs=512 conv=noerror,sync | tee >(sha256sum > /evidence/disk_SHA256.txt)

# Or after copy
sha256sum /evidence/disk.dd | tee /evidence/disk_SHA256.txt
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
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC"
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
# Create disk image with verification
dc3dd if=/dev/sdb of=evidence.dd hash=sha256 hash=md5 hashlog=evidence_hashes.txt

# Verify disk image later
dc3dd if=evidence.dd hash=sha256 hashlog=verification.txt
diff evidence_hashes.txt verification.txt
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
# Some tools hash metadata + content, others hash content only
# File hash will differ if metadata is included

# Content-only hash (most common)
sha256sum file.bin

# Metadata + content hash
# Use specialized tools like md5deep with -l flag
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

# Hash the symlink itself
sha256sum -L /path/to/symlink  # Some versions support -L flag

# Best practice: Resolve symlinks first
readlink -f /path/to/symlink
sha256sum /actual/target/path
```

### Performance Optimization

**Parallel hashing (multiple files):**
```bash
# GNU parallel (fastest for many files)
find /evidence -type f | parallel -j 8 sha256sum {} > all_hashes.txt

# Or xargs
find /evidence -type f | xargs -P 8 -I {} sha256sum {}
```

**Large file optimization:**
```bash
# Use buffered I/O for large files
dd if=large_image.dd bs=1M | sha256sum

# Or specialized tools
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
- **Tool:** FTK Imager 4.7.1.2
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
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC"
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
# Autopsy automatically calculates MD5 for all files

# Query Autopsy database for file hashes
sqlite3 autopsy.db "SELECT name, md5 FROM tsk_files WHERE md5 IS NOT NULL;"

# Export hash list
sqlite3 -csv autopsy.db "SELECT md5, name FROM tsk_files;" > autopsy_hashes.csv
```

### EnCase / FTK Integration

```
# EnCase automatically calculates MD5 and SHA-1 during evidence processing
# Access via Evidence > File Properties > Hash

# Export hash report:
# EnCase: View > Hash Analysis > Export
# FTK: File > Export > Hash List
```

### Volatility (Memory Forensics)

```bash
# Hash memory dump
sha256sum memory.dmp > memory_SHA256.txt

# Volatility automatically verifies integrity if hash stored in profile
vol.py -f memory.dmp --profile=Win10x64 pslist
```

---

## 10. Tools Reference

| Tool | Platform | Type | Use Case | Link |
|------|----------|------|----------|------|
| certutil | Windows | Built-in | Quick hashing | Built-in |
| Get-FileHash | Windows | Built-in | PowerShell automation | Built-in |
| sha256sum | Linux/Mac | Built-in | Command-line hashing | Built-in |
| md5deep/hashdeep | Cross-platform | CLI | Recursive hashing, audit | [GitHub](https://github.com/jessek/hashdeep) |
| HashTab | Windows | GUI | Right-click integration | [hashtab.io](https://hashtab.io) |
| HashMyFiles | Windows | GUI | Batch processing | [NirSoft](https://www.nirsoft.net/utils/hash_my_files.html) |
| FTK Imager | Windows | GUI/CLI | Forensic imaging + hash | [Exterro](https://www.exterro.com/ftk-imager) |
| GtkHash | Linux | GUI | GTK-based hashing | [gtkhash](https://github.com/tristanheaven/gtkhash) |
| RapidCRC | Windows | GUI | SFV/MD5 checksum files | [rapidcrc.net](https://www.rapidcrc.net) |

---

**Best Practice Summary:**
- ✅ Use SHA-256 for all new evidence (2025 standard)
- ✅ Calculate hash immediately upon acquisition
- ✅ Verify hash before and after transfers
- ✅ Log all verifications in chain of custody
- ✅ Use multiple algorithms for critical evidence (SHA-256 + SHA-512)
- ❌ Never rely on MD5 alone for court evidence
- ❌ Never skip hash verification before analysis
