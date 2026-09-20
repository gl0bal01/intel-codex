---
type: index
title: "Security Index"
description: "Navigate malware analysis, penetration testing, vulnerability research, forensics & defensive security operations."
tags: [index, security, pentesting, analysis, malware, cybersecurity]
---

# Security Index

Quick navigation to security operations guides: analysis, penetration testing, forensics, and defensive security.

---

## 🗂️ Main Domains

### [[Analysis/Analysis-Index|🔬 Analysis SOPs]]
Understanding threats, reverse engineering, cryptographic analysis, and AI/ML security research.

- **Malware Analysis** – Static/dynamic analysis, IOC extraction
- **Reverse Engineering** – Disassembly, decompilation, protocol analysis
- **Cryptography Analysis** – Crypto implementation audit, weakness discovery
- **Hash Generation** – File integrity verification, forensic hashing
- **Forensics Investigation** – Evidence collection, incident response, timeline analysis
- **AI/ML Vulnerability** – Adversarial attacks, prompt injection, model extraction

### [[Pentesting/Pentesting-Index|🔓 Pentesting SOPs]]
Security assessments across infrastructure, applications, and offensive research.

**Infrastructure & Systems**
- **Linux Pentesting** – Privilege escalation, kernel exploits
- **Active Directory Pentesting** – Kerberos attacks, domain compromise

**Applications & Devices**
- **Web Application Security** – OWASP Top 10, SQLi, XSS
- **Mobile Security** – iOS/Android app analysis, API testing
- **Firmware Reverse Engineering** – IoT, embedded devices, bootloader bypass

**Offensive Research**
- **Vulnerability Research** – 0-day discovery, exploit development
- **Bug Bounty Methodology** – Reconnaissance, vulnerability chaining, disclosure
- **Detection Evasion** – AV/EDR/SIEM bypass techniques

---

## 🎯 Quick Start

### By Task

| I need to... | Go to |
|---|---|
| Analyze suspicious binary | Analysis → Malware Analysis |
| Test web application | Pentesting → Web Application Security |
| Compromise Windows domain | Pentesting → AD Pentesting |
| Find vulnerabilities | Pentesting → Vulnerability Research |
| Investigate incident | Analysis → Forensics Investigation |
| Bypass detection | Pentesting → Detection Evasion |
| Analyze encrypted protocol | Analysis → Reverse Engineering |
| Test mobile app | Pentesting → Mobile Security |
| Test AI/ML system | Analysis → AI/ML Vulnerability |

### By Workflow

**Incident Response:**
1. Forensics Investigation → collect evidence
2. Malware Analysis → analyze threats
3. Reverse Engineering → deep analysis if needed

**Penetration Test (External):**
1. Bug Bounty Methodology → reconnaissance
2. Web Application Security → identify vulnerabilities
3. Detection Evasion → bypass defenses

**Red Team Operation:**
1. Detection Evasion → establish persistence
2. AD Pentesting → lateral movement
3. Linux Pentesting → server compromise
4. Forensics Investigation → document attack chain

**APT Investigation:**
1. Forensics Investigation → collect evidence
2. Malware Analysis → analyze attacker tools
3. Reverse Engineering → understand custom malware
4. AD Pentesting → trace lateral movement

---

## ⚖️ Legal & Authorization

**Before any assessment:**
- [ ] Written authorization from system owner
- [ ] Scope clearly defined (in-scope vs. out-of-scope)
- [ ] Testing window documented
- [ ] Incident response contact provided
- [ ] Data handling agreements signed

**Key frameworks:**
- CFAA (Computer Fraud and Abuse Act) – U.S. anti-hacking law
- GDPR – Data protection in EU
- **Authorization required** – Never test without permission

**Responsible disclosure:**
- Report vulnerabilities to vendor first
- Allow 90 days for remediation
- Coordinate public disclosure with vendor

---

## 🧰 Essential Tools

**Multi-Domain:** Ghidra, IDA Pro, Radare2, VirusTotal, YARA, Metasploit, Burp Suite, Wireshark, Nmap

**Analysis:** Any.run, x64dbg, WinDbg, OpenSSL, HashCat, CyberChef

**Pentesting:** Cobalt Strike, BloodHound, Bettercap, tcpdump

**AI/ML Security:** Garak, CleverHans, Adversarial Robustness Toolbox

**Linux:** LinPEAS, pspy, GTFOBins...

**Windows/AD:** Mimikatz, Rubeus, PowerView, SharpHound

**Web:** SQLMap, XSStrike, Nuclei, ffuf

**Mobile:** Frida, objection, Apktool, jadx

See individual SOP pages for detailed tool lists.

---

## 📊 Evidence & Reporting

**Evidence collection standards:**
- Calculate SHA-256 hashes immediately
- Screenshot with visible timestamps
- Capture network traffic (PCAPs)
- Maintain chain of custody documentation
- Document all commands and actions

**Report structure:**
1. Executive Summary
2. Scope & Methodology
3. Findings (by severity)
4. Evidence (screenshots, POCs)
5. Recommendations (prioritized)

**Severity ratings (CVSS):**
- Critical (9.0-10.0) – RCE, auth bypass
- High (7.0-8.9) – Privilege escalation, data exposure
- Medium (4.0-6.9) – Information disclosure, CSRF
- Low (0.1-3.9) – Misconfiguration, verbose errors

---

## 📚 Resources

**External References:**
- [OWASP](https://owasp.org/)
- [MITRE ATT&CK](https://attack.mitre.org/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
- [HackTricks](https://book.hacktricks.xyz/)
- [GTFOBins](https://gtfobins.github.io/)

**Training Platforms:**
- [HackTheBox](https://www.hackthebox.com/) – Penetration testing labs
- [TryHackMe](https://tryhackme.com/) – Guided security training
- [PortSwigger Web Security Academy](https://portswigger.net/web-security)

**Certifications:**
- OSCP – Offensive Security Certified Professional
- GPEN – GIAC Penetration Tester
- GREM – GIAC Reverse Engineering Malware
- GCFA – GIAC Certified Forensic Analyst

---

**Navigation:** [🏠 Home](https://lecodex.xyz) | [[Analysis/Analysis-Index|🔬 Analysis]] | [[Pentesting/Pentesting-Index|🔓 Pentesting]] | [[../Investigations/Investigations-Index|🔍 Investigations]]