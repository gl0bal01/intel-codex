---
title: "CTF Team Coordination Guide"
description: "Quick reference for CTF team coordination: roles, communication, tracking, dynamic scoring, hints, flag submission, time management, crisis protocols & post-CTF retro."
tags:
  - ctf
  - teamwork
  - coordination
  - communication
  - strategy
updated: 2026-11-07
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
```text
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
```text
Columns:
Challenge Name | Category | Points | Status | Owner | Time Started | Notes | Flag
```

**Self-hosted alternatives:**
- [CTFNote](https://github.com/TFNS/CTFNote) - CTF task board with a collaborative HedgeDoc pad per challenge; optional Discord bot
- [HedgeDoc](https://hedgedoc.org/) - Real-time collaborative Markdown notes

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

**Dynamic Scoring:**
- Many events lower a challenge's value as more teams solve it
- On CTFd the drop is retroactive - every solver's score falls with each new solve, so solving early doesn't lock in more points. Check how your event scores
- Speed still counts: CTFd breaks ties by solve time; some events add first-blood bonuses
- Read values as a signal: falling fast = widely solved, likely easier than it looks; staying high = few solves, worth the most at the end
- Re-prioritize from the scoreboard every check-in, not from the start-of-event values

**Hint Budget:**
- Paid hints deduct points (CTFd: score drops by the hint cost; can't unlock below zero)
- Captain decides; agree a threshold before the event (e.g. buy only if hint cost < 25% of the challenge's current value and the owner is blocked)
- Log every hint bought and its cost in the tracker

---

## 🚩 Flag Submission

- One submitter per challenge - announce in the channel before submitting
- Copy the exact flag from the output; never retype it
- Check the event's flag format (prefix, braces, case) and strip whitespace/newlines
- Know the limits: some events cap wrong attempts or rate-limit submissions - verify locally before submitting a guess
- Post the accepted flag in the tracker immediately

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
```text
Easy:   30-60 min max
Medium: 2-4 hours max
Hard:   4+ hours (team decision)

⚠️ 25% → Clear direction
⚠️ 50% → No working approach yet: ask for help or pivot
⚠️ 75% → Stop and pivot unless nearly solved
⚠️ 90% → Finish only, no new approaches
```

---

## 💡 Quick Communication Templates

**Breakthrough Alert:**
```text
🚨 BREAKTHROUGH: [Challenge Name]
Discovery: [Brief description]
Status: [Working/Need help/Solved]
```

**Solved Challenge:**
```text
🏆 SOLVED: [Challenge Name] ([Points]pts)
Method: [Brief approach]
Time: [Duration]
Reusable for: [Other challenges]
```

**Help Needed:**
```text
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

```text
□ Team roles assigned
□ Discord server + channels set up
□ Google Sheets tracker created
□ Tools tested (Burp, Ghidra, Python, etc.)
□ Competition rules reviewed
□ Flag format + submission limits noted
□ Hint budget agreed
□ Writeup policy / embargo checked
□ Emergency contacts shared
```

---

## 🔁 Post-CTF Retro

```text
CTF: [Name]   Date: [YYYY-MM-DD]   Rank: [X/Y]   Points: [N]

What worked:
- 

What blocked us:
- 

Skill gaps (category → who will study what):
- 

Tools/scripts to add to the toolkit:
- 

Writeups to publish (respect the event's embargo):
| Challenge | Owner | Deadline |
|-----------|-------|----------|
|           |       |          |
```

---

## 🔗 Related Resources

- [[CTF_Challenge_Methodology|CTF Challenge Methodology]] - Systematic approach to challenges
- [[CTF_Tools|CTF Tools]] - Essential tools by category
- [[Writeups-Index|CTF Writeups]] - Example solutions

---

**Last Updated:** 2026-11-07
