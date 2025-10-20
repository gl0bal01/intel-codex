---
title: "CTF Team Coordination Guide"
description: "Quick reference for CTF team coordination: roles, communication, tracking, time management & crisis protocols."
---

# 🤝 CTF Team Coordination Guide

Quick-reference guide for effective CTF team collaboration during competitions.

---

## 📋 Team Roles (Quick Assignment)

**🎯 Team Captain** - Strategy, time management, challenge prioritization, final decisions
**🌐 Web Expert** - SQL injection, XSS, CSRF, web pentesting (Burp Suite, dev tools)
**🔐 Crypto Expert** - Ciphers, hashes, crypto analysis (CyberChef, Python)
**💾 Binary/RevEng** - Disassembly, exploitation, malware (Ghidra, GDB, IDA)
**🕵️ Forensics** - Steganography, memory, file analysis (Wireshark, binwalk, volatility)
**🔧 Misc/OSINT** - Programming, OSINT, puzzles (search, scripting, creative thinking)

---

## 🛠️ Communication Setup

**Discord Server Structure:**
```
📢 #announcements      - Critical updates only
💬 #general           - Team coordination
🌐 #web               - Web challenges
🔐 #crypto            - Crypto challenges
💾 #binary-rev        - Binary/RevEng challenges
🕵️ #forensics         - Forensics challenges
🚨 #urgent            - Time-sensitive help needed
💡 #breakthroughs     - Share wins & insights immediately
```

**Emergency Backup:** WhatsApp/Telegram group with all team members

---

## 📊 Challenge Tracking

**Google Sheets Tracker (Recommended):**
```
Columns:
Challenge Name | Category | Points | Status | Owner | Time Started | Notes | Flag
```

**Status Values:**
- 🔵 Not Started
- 🟡 In Progress
- 🔴 Blocked (need help)
- 🟢 Solved

**Priority Rules:**
1. Easy challenges (quick points first)
2. Medium in team strengths
3. High-value challenges
4. Hard challenges (if time allows)

---

## ⏰ Time Management

**Competition Phases:**

**Phase 1: Setup (First 30 min)**
- Team check-in, role confirmation
- Challenge overview & categorization
- Priority assignment & initial distribution

**Phase 2: Quick Wins (Next 2-4 hours)**
- Focus on easy challenges (100-200 pts)
- Build momentum, establish rhythm

**Phase 3: Deep Work (Main period)**
- Tackle medium/hard challenges
- Check-in every 1-2 hours
- Share breakthroughs immediately

**Phase 4: Final Push (Last 2-4 hours)**
- Focus on nearly-solved challenges only
- Final submission verification

**Time-Boxing Rules:**
```
Easy:   30-60 min max
Medium: 2-4 hours max
Hard:   4+ hours (team decision)

⚠️ No progress at 50% → Ask for help
⚠️ No progress at 75% → Stop and pivot
```

---

## 💡 Quick Communication Templates

**Breakthrough Alert:**
```
🚨 BREAKTHROUGH: [Challenge Name]
Discovery: [Brief description]
Status: [Working/Need help/Solved]
```

**Solved Challenge:**
```
🏆 SOLVED: [Challenge Name] ([Points]pts)
Method: [Brief approach]
Time: [Duration]
Reusable for: [Other challenges]
```

**Help Needed:**
```
🔴 BLOCKED: [Challenge Name]
Tried: [What you've attempted]
Stuck on: [Specific issue]
Need: [Type of help]
```

---

## 🚨 Crisis Protocols

**Team Member Disappears:**
- Try all communication channels
- Redistribute their challenges immediately
- Update tracker, continue momentum

**Major Technical Issues:**
- Identify scope (individual vs. team-wide)
- Find workaround/alternative tool quickly
- Keep team informed

**Time Running Out:**
- Triage: focus only on nearly-solved challenges
- Target high-point challenges first
- Ensure all flags submitted properly

**Lost Progress/Files:**
- Save to shared drive every 30 minutes
- Use Git for code/scripts
- Screenshot all important findings

---

## 📋 Pre-CTF Checklist

```
□ Team roles assigned
□ Discord server + channels set up
□ Google Sheets tracker created
□ Tools tested (Burp, Ghidra, Python, etc.)
□ Competition rules reviewed
□ Emergency contacts shared
```

---

## 🔗 Related Resources

- [[CTF_Challenge_Methodology|CTF Challenge Methodology]] - Systematic approach to challenges
- [CTF_Tools](CTF_Tools.md) - Essential tools by category
- [[Writeups/Writeups-Index|CTF Writeups]] - Example solutions

---

**Post-CTF Review:** What worked? What needs improvement? Skill gaps? Action items for next time.

## Tags
#ctf #teamwork #coordination #communication #strategy