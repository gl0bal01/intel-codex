---
type: index
title: "CTF Writeups Index"
description: "Sample CTF writeups for cryptography, web exploitation, forensics and reverse engineering: step-by-step solutions with verified outputs, reusable as a writeup template."
tags:
  - index
  - ctf
  - writeups
  - capture-the-flag
  - learning-resources
updated: 2026-11-07
---

# CTF Writeups Index

**Worked CTF challenge solutions showing the methodology applied end to end.**

---

## 📊 Overview

Four sample writeups, one per core category. Each follows the same template (Summary → Analysis → Solution → Flag → Reflection → References), so any of them can be copied as the starting point for your own.

The decryptions, extracted data, keys and flags shown were reproduced by running each writeup's own code and local tools against a rebuilt challenge. Transcripts against a remote challenge host or a GUI tool are illustrative. The challenges and events themselves are fictional teaching examples.

**Total Writeups**: 4
**Categories**: Cryptography (1) | Web Exploitation (1) | Forensics (1) | Reverse Engineering (1)

---

## 🗂️ Writeups by Category

### 🔐 Cryptography

#### [[Sample_Crypto_Caesar_Writeup|Caesar Cipher with Twist]]
- **Challenge**: Ancient Messages
- **Points**: 150
- **Event**: Beginner CTF 2024
- **Concepts**: Progressive Caesar shift, brute force, crib-based confirmation
- **What You'll Learn**:
  - Reading a 25-shift brute force for partial hits
  - Turning partial hits into a hypothesis (shift = 3 + word index)
  - Confirming the rule with a stopword scan and a known-plaintext crib (`flag{`)
- **Completion Time**: 45 minutes

---

### 🌐 Web Exploitation

#### [[Sample_Web_SQLi_Writeup|SQL Injection Basic]]
- **Challenge**: Web Login Bypass
- **Points**: 100
- **Event**: Beginner CTF 2024
- **Concepts**: SQL injection, authentication bypass, comment syntax per DBMS
- **What You'll Learn**:
  - Spotting injection from a database error
  - Crafting comment-based bypass payloads (SQLite / MySQL differences)
  - The fix: parameterized queries plus hashed-password verification
- **Completion Time**: 15 minutes

---

### 🕵️ Forensics

#### [[Sample_Forensics_Steganography_Writeup|Steganography Challenge]]
- **Challenge**: Picture Perfect
- **Points**: 200
- **Event**: Beginner CTF 2024
- **Concepts**: PNG text-chunk metadata, LSB steganography, lossless vs lossy formats
- **What You'll Learn**:
  - Reading PNG metadata (exiftool, pngcheck)
  - Extracting LSB data with Python/Pillow and zsteg
  - Why pixel LSB hiding needs PNG/BMP, and which tools handle JPEG
- **Completion Time**: 1.5 hours

---

### 🔧 Reverse Engineering

#### [[Sample_RevEng_Crackme_Writeup|Basic Crackme Challenge]]
- **Challenge**: License Check
- **Points**: 250
- **Event**: Beginner CTF 2024
- **Concepts**: Static analysis, algorithm extraction, key generation
- **What You'll Learn**:
  - Finding the validation routine in a disassembler (Ghidra)
  - Turning decompiled checks into constraints
  - Writing a keygen and confirming it against the binary
- **Completion Time**: 2 hours

---

## 🎯 Using These Writeups

### For Learning
1. **Attempt first**: try a similar challenge before reading the solution
2. **Follow the reasoning**, not just the commands, including the dead ends
3. **Re-run the code**: the Python and C blocks are complete and runnable
4. **Study the reflection sections**: they name what to try first next time

### Common Workflow
1. Review [[CTF_Challenge_Methodology|CTF Challenge Methodology]] for the systematic approach
2. Pick the writeup for the category you're practicing
3. Keep [[CTF_Cheat_Sheets|Cheat Sheets]] open for the commands
4. Practice on a platform from [[CTF-Index#Practice Platforms|the practice platforms list]]
5. Document your own solutions using these as templates

---

## 💡 Tips for Writing Your Own Writeups

### Essential Sections
1. **Challenge Summary** - Quick overview and description
2. **Analysis** - Initial reconnaissance and observations
3. **Solution Approach** - Step-by-step methodology
4. **Technical Details** - Tools, concepts, and code
5. **Flag** - The final answer
6. **Reflection** - What you learned and challenges faced
7. **References** - Documentation and resources used

### Best Practices
- ✅ Paste real commands and real output; mark anything abridged
- ✅ Explain your thought process
- ✅ Document dead ends and failures
- ✅ Rate the challenge (difficulty, fun, learning value)
- ✅ Provide alternative solution methods
- ✅ Link to related resources
- ✅ Store screenshots next to the writeup and embed them with relative paths; skip the section rather than leave placeholders
- ✅ Check the event's writeup policy: many CTFs ask you to wait until the competition ends

---

## 🎓 Learning Paths by Category

### Cryptography Track
1. Start: [[Sample_Crypto_Caesar_Writeup|Caesar Cipher with Twist]]
2. Practice: picoCTF crypto challenges
3. Study: [[sop-cryptography-analysis|Cryptography Analysis SOP]]
4. Advanced: CryptoHack

### Web Exploitation Track
1. Start: [[Sample_Web_SQLi_Writeup|SQL Injection Basic]]
2. Practice: PortSwigger Web Security Academy
3. Study: [[sop-web-application-security|Web Application Security SOP]]
4. Advanced: bug bounty programs ([[sop-bug-bounty|Bug Bounty SOP]])

### Forensics Track
1. Start: [[Sample_Forensics_Steganography_Writeup|Steganography Challenge]]
2. Practice: picoCTF forensics challenges
3. Study: [[sop-forensics-investigation|Forensics Investigation SOP]]
4. Advanced: DFIR CTF competitions

### Reverse Engineering Track
1. Start: [[Sample_RevEng_Crackme_Writeup|Basic Crackme Challenge]]
2. Practice: crackmes.one
3. Study: [[sop-reverse-engineering|Reverse Engineering SOP]]
4. Advanced: malware analysis CTFs ([[sop-malware-analysis|Malware Analysis SOP]])

### Binary Exploitation (Pwn) Track
1. Start: the pwn sections of [[CTF_Challenge_Methodology|Methodology]] and [[CTF_Cheat_Sheets|Cheat Sheets]]
2. Practice: pwn.college
3. Study: [[sop-vulnerability-research|Vulnerability Research SOP]]

---

## 🔗 Related Resources

- [[CTF_Challenge_Methodology|CTF Challenge Methodology]] - Systematic approach to solving CTF challenges
- [[CTF_Tools]] - Essential tools for each category
- [[CTF_Cheat_Sheets|CTF Cheat Sheets]] - Copy-paste commands and payloads
- More practice platforms: https://gl0bal01.com/blog/ctf-platforms-training

---

**Navigation:** [[CTF-Index|🏠 CTF Main]] | [[CTF_Challenge_Methodology|📖 Methodology]] | [[CTF_Cheat_Sheets|📋 Cheat Sheets]] | [[CTF_Tools|🛠️ Tools]]

---

**Last Updated:** 2026-11-07
