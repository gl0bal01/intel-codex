---
type: sop
title: OPSEC Planning for OSINT Investigations
description: "Protect yourself during investigations: VPN setup, burner accounts, browser isolation & operational security best practices for safe OSINT work."
created: 2025-10-05
updated: 2026-10-29
template_version: 2026-09-20
tags: [sop, opsec, operational-security, investigation]
---

# OPSEC Planning for OSINT Investigations

> **Purpose:** Comprehensive operational security planning to protect investigator identity, prevent attribution, and minimize detection during OSINT investigations.

---

## Table of Contents

1. [Overview](#overview)
2. [Threat Modeling](#threat-modeling)
3. [Investigation Environment](#investigation-environment)
4. [Network Security](#network-security)
5. [Identity Management](#identity-management)
6. [Browser Security](#browser-security)
7. [Operational Rules](#operational-rules)
8. [Platform-Specific OPSEC](#platform-specific-opsec)
9. [Detection Indicators](#detection-indicators)
10. [Incident Response](#incident-response)
11. [OPSEC Checklist](#opsec-checklist)

---

## Overview

### Why OPSEC Matters

**Attribution risks during OSINT:**
- Target receives notification of profile view (LinkedIn, Instagram Stories)
- Platform detects abnormal access patterns and locks account
- Adversary correlates investigator activity across platforms
- IP address reveals investigator location or organization
- Browser fingerprinting links research personas to real identity
- Metadata in screenshots/reports leaks investigator information

**Consequences of OPSEC failure:**
- Target becomes aware of investigation (destroys evidence, goes dark)
- Investigator identity exposed to adversary
- Legal liability (unauthorized access, terms of service violations)
- Organization compromise (adversary pivots to investigator's employer)
- Physical safety risk (doxxing, retaliation)

### OPSEC Principles

**The 5 OPSEC Steps:**
1. **Identify Critical Information:** What must be protected? (investigator identity, investigation scope, techniques)
2. **Analyze Threats:** Who might want this information? (investigation target, platform security, third parties)
3. **Analyze Vulnerabilities:** How could they get it? (IP logging, browser fingerprinting, behavioral analysis)
4. **Assess Risk:** What's the likelihood and impact? (high-value target = high risk)
5. **Apply Countermeasures:** How do we protect it? (VPN, VM isolation, burner accounts)

---

## Threat Modeling

### Adversary Profiles

**Level 1: Automated Detection (Low Skill)**
- **Capabilities:** Platform anti-bot systems, rate limiting, CAPTCHA challenges
- **Detection methods:** Scraping patterns, rapid clicks, unusual traffic volume
- **Countermeasures:** Randomized timing, human-like behavior, session cookies

**Level 2: Platform Security Teams (Medium Skill)**
- **Capabilities:** Account linking algorithms, device fingerprinting, abuse detection
- **Detection methods:** Multiple accounts from same IP, browser fingerprint correlation, TOS violations
- **Countermeasures:** Dedicated VPN per persona, browser isolation, profile warming

**Level 3: Individual Target (Variable Skill)**
- **Capabilities:** Profile view notifications, connection request screening, suspicious activity awareness
- **Detection methods:** LinkedIn "Who viewed your profile", Instagram Story views, unfamiliar account interaction
- **Countermeasures:** Passive collection only, no direct engagement, fake profiles with realistic activity

**Level 4: Sophisticated Adversary (High Skill)**
- **Capabilities:** Counter-OSINT techniques, honey pot accounts, investigator identification
- **Detection methods:** Cross-platform correlation, timing analysis, infrastructure fingerprinting, EXIF metadata in investigator reports
- **Countermeasures:** Air-gapped analysis, metadata scrubbing, compartmentalized identities, operational security discipline

**Level 5: Nation-State or APT (Advanced)**
- **Capabilities:** Network traffic analysis, browser exploits, infrastructure compromise
- **Detection methods:** VPN exit node monitoring, zero-day exploits, supply chain attacks
- **Countermeasures:** Tor over VPN, dedicated hardware, Whonix/Tails, assume compromise

### Risk Assessment Matrix

| Target Type | Detection Risk | Attribution Risk | Recommended OPSEC Level |
|-------------|----------------|------------------|-------------------------|
| Public figure (passive collection) | Low | Low | Basic (VPN + privacy browser) |
| Corporate investigation | Medium | Medium | Standard (VM + VPN + burner accounts) |
| Criminal investigation | High | High | Advanced (Whonix + Tor + air-gapped analysis) |
| Nation-state actor | Critical | Critical | Maximum (Tails OS + Tor + physical security) |

### Exposure Risk Categories

**Technical Exposure:**
- IP address reveals investigator location/ISP/organization
- Browser fingerprint links research personas to real identity
- DNS queries leak investigation targets
- Metadata in files (EXIF, Office documents) contains investigator info
- Traffic timing correlates investigator activity across platforms

**Behavioral Exposure:**
- Profile view notifications alert target
- Unusual account activity triggers platform security review
- Interaction patterns (likes, follows) create investigator profile
- Language/timezone inconsistencies in persona reveal investigator location
- Search queries logged by platforms create investigation trail

**Operational Exposure:**
- Screenshots contain taskbar, browser UI, or open tabs
- Reports include investigator name, organization, or email
- Evidence files stored with metadata timestamps
- Communication channels (email, Slack) leak investigation details
- Physical security (shoulder surfing, unlocked workstation)

---

## Investigation Environment

### Workspace Isolation

**Option 1: Virtual Machine**

**VMware Workstation / VirtualBox:**
```bash
# Create dedicated OSINT investigation VM
# Base OS: Windows 11 or Ubuntu 24.04 / 26.04 LTS (Windows 10 support ended 2025-10-14) [verify 2026-10-29]

# Take clean snapshot before each investigation
# VMware CLI example: [verify 2026-10-25]
vmrun snapshot "C:\VMs\OSINT-VM\OSINT-VM.vmx" "Clean_2025-10-05"

# Revert to snapshot after investigation [verify 2026-10-25]
vmrun revertToSnapshot "C:\VMs\OSINT-VM\OSINT-VM.vmx" "Clean_2025-10-05"
```

**VM Configuration Best Practices:**
- **Host-only networking** during analysis phase (no internet exposure)
- **NAT networking** for collection phase (via VPN on host)
- **Shared folders disabled** (prevent cross-contamination)
- **Guest additions installed** (better usability)
- **Snapshots before each investigation** (quick rollback)
- **No personal accounts or files** in VM

**Option 2: Docker Containers (Lightweight)**

```bash
# Firefox in isolated Docker container. jlesage/firefox serves its own web UI
# (port 5800; VNC on 5900) and keeps its data in /config — it does not use host X11. [verify 2026-10-29]
docker run -d \
  --name osint-firefox \
  --shm-size=2g \
  -p 127.0.0.1:5800:5800 \
  -v /home/analyst/osint-data:/config:rw \
  jlesage/firefox
# Open http://localhost:5800 in a local browser

# Destroy container after investigation (the profile persists in /home/analyst/osint-data)
docker stop osint-firefox && docker rm osint-firefox
```

**Option 3: Whonix (Maximum Anonymity)**

```bash
# Whonix Workstation + Gateway (Tor-routed by design)
# Download: https://www.whonix.org/ [verify 2026-10-25]

# All traffic forced through Tor
# DNS leaks impossible by design [verify 2026-10-25]
# Recommended for high-risk investigations
# Best deployed inside Qubes OS (Qubes-Whonix integration). [verify 2026-10-25]
# Verify current Qubes major version (R4.3 current; 4.3.2 released 2026-10-02) [verify 2026-10-29]
```

**Option 4: Tails OS (Amnesic Live System)**

```bash
# Tails USB boot (no persistence by default)
# All traffic through Tor
# RAM-only operation (no disk traces) [verify 2026-10-25]
# Recommended for maximum OPSEC
# Verify current major before download (Tails 7.x, Debian 13 based, since 2025-09-18; 7.15.1 as of 2026-10-23; check tails.net) [verify 2026-10-29]
```

**Option 5: Exegol (Security Testing Environment)**

```bash
# Exegol: Fully-featured security testing Docker environment
# https://exegol.com/ [verify 2026-10-25]
# Licensing: the free Community plan is for students and hobbyists in non-commercial
# use and gets only the `free` image; commercial work needs Pro, Team or Enterprise
# (all official images: full, ad, web, light, osint, nightly) — https://exegol.com/pricing [verify 2026-10-29]

# Install Exegol [verify 2026-10-25]
pipx install exegol

# Start a container (Community: `free` image; paid plans can use `full`, `osint`, etc.).
# Host GUI (X11/Wayland) sharing is on by default (--gui); pass --no-gui to disable it. [verify 2026-10-29]
exegol start osint-workspace free

# Features:
# - Large curated tool set (per-image lists: https://docs.exegol.com/images/tools)
# - Default network mode is "host" (shares the host's interfaces — NOT isolated);
#   use --network disable (no connectivity) or --network nat (Pro/Team/Enterprise) [verify 2026-10-29]
# - Web browser with privacy extensions

# Stop and remove container [verify 2026-10-25]
exegol stop osint-workspace
exegol remove osint-workspace
```

**Option 6: Kasm Workspaces (Browser-Based Isolation)**

```bash
# Kasm Workspaces: Containerized desktop/app streaming
# https://kasm.com/ [verify 2026-10-29]

# Features:
# - Browser-based access (no local software needed)
# - Each workspace is isolated Docker container
# - Disposable sessions (destroy after use)
# - Remote access from anywhere
# - Pre-built images (Firefox, Chrome, Ubuntu Desktop, Kali Linux)

# Community Edition (free): [verify 2026-10-25]
# Download from: https://kasm.com/downloads [verify 2026-10-29]
# Resolve the current release filename from the downloads page
# rather than relying on shell wildcards against an S3 listing.

# Installation (Ubuntu) — pin to the verified release filename: [verify 2026-10-25]
cd /tmp
# curl -O https://kasm-static-content.s3.amazonaws.com/kasm_release_<VERSION>.tar.gz
tar -xf kasm_release_*.tar.gz
sudo bash kasm_release/install.sh

# Access Kasm UI:
# https://localhost:443 [verify 2026-10-25]
# Login and create workspace (Firefox, Chrome, Kali Desktop)

# Workspace workflow:
# 1. Create isolated Firefox workspace
# 2. Configure VPN inside workspace
# 3. Conduct investigation
# 4. Export evidence to host
# 5. Destroy workspace (no traces left)

# Benefits for OPSEC:
# - Zero client-side traces (all in container)
# - Access from any device via browser
# - Network isolation per workspace
# - Multi-user support (team investigations)
```

### Physical Security

**Workstation Hardening:**
- [ ] Full-disk encryption enabled (BitLocker, LUKS, FileVault)
- [ ] Screen privacy filter installed (prevent shoulder surfing)
- [ ] Automatic screen lock after 5 minutes of inactivity
- [ ] Webcam/microphone physically disabled or covered
- [ ] Work from secure location (not public Wi-Fi or coffee shops)
- [ ] Clean desk policy (no sensitive documents visible)

**Evidence Security:**
```bash
# Encrypt evidence directory
# Windows (BitLocker): [verify 2026-10-25]
manage-bde -on E: -RecoveryPassword

# Linux (LUKS): [verify 2026-10-25]
cryptsetup luksFormat /dev/sdb1
cryptsetup luksOpen /dev/sdb1 evidence_vault
mkfs.ext4 /dev/mapper/evidence_vault

# macOS (FileVault, APFS volume): -user disk is required; enter the new passphrase
# interactively or pass it with -stdinpassphrase [verify 2026-10-29]
diskutil apfs encryptVolume /Volumes/Evidence -user disk
```

---

## Network Security

### VPN Configuration

**VPN Selection Criteria:**
- **No-logs policy** (independently audited)
- **Jurisdiction** outside Five Eyes (Switzerland, Panama, Iceland)
- **Payment method** accepts cryptocurrency or prepaid cards
- **Kill switch** prevents IP leaks if VPN drops
- **DNS leak protection** forces all DNS through VPN tunnel

**Recommended VPN Providers:**
- **Mullvad VPN** (numbered-account signup — no username, password or email; accepts cash/crypto/voucher/card; new card/PayPal subscriptions ended June 2022 — accounts are topped up with one-time payments; Swedish jurisdiction. An April 2023 Swedish police search warrant at Mullvad's office ended with nothing seized because the customer data sought did not exist, publicly validating the no-logs claim) [verify 2026-10-29]
- **Proton VPN** (Swiss jurisdiction, Secure Core multi-hop, Tor over VPN; rebranded from ProtonVPN in 2022, current domain `protonvpn.com` / unified `proton.me` account) [verify 2026-10-25]
- **IVPN** (no email required, account-ID-only signup; one no-logs audit, by Cure53 in March 2019 — IVPN says it will not commission further no-logs audits but runs annual Cure53 security audits; port forwarding retired 30 September 2023) [verify 2026-10-29]

**VPN Best Practices:**

```bash
# Linux: Verify VPN connection before starting investigation
# Check IP address: [verify 2026-10-25]
curl -s https://ifconfig.me
# Expected: VPN exit node IP (NOT your real IP)

# Check DNS leak:
nslookup google.com
# Expected: VPN provider's DNS server

# Check WebRTC leak (Firefox):
# about:config → media.peerconnection.enabled → false [verify 2026-10-25]
```

**VPN Configuration Examples:**

```bash
# WireGuard (modern default — faster, smaller attack surface, recommended):
sudo wg-quick up mullvad-us-ny
# Interface name will be the config name (e.g. mullvad-us-ny), not tun0. [verify 2026-10-25]

# OpenVPN (legacy fallback for environments where WG is blocked): [verify 2026-10-25]
sudo openvpn --config mullvad_us_ny.conf --auth-user-pass credentials.txt
```

**Kill Switch Configuration:**

Prefer the VPN client's built-in kill switch where it has one. A hand-rolled rule must still let the tunnel's own encrypted packets reach the VPN server, or the tunnel can never come up.

```ini
# Linux, WireGuard: add to the [Interface] section of the wg-quick config (rule from wg-quick(8)).
# Works with a peer whose AllowedIPs includes 0.0.0.0/0: rejects every packet that neither
# leaves via the tunnel nor is the tunnel's own fwmark-tagged encrypted traffic; local
# destinations stay reachable. IPv4 only — add matching ip6tables lines if IPv6 is in use. [verify 2026-10-29]
[Interface]
PostUp = iptables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT
PreDown = iptables -D OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT
```

```bash
# Linux, OpenVPN: allow loopback and the VPN server endpoint first, then drop everything
# that does not leave via the tunnel (iptables(8) / iptables-extensions(8) syntax).
# Use the IP (not hostname), port and proto (udp/tcp) of the `remote` line in your .conf;
# check the tunnel name with `ip -br a`. Rules are inserted at the top (-I) so existing
# ACCEPT rules (e.g. ufw's) cannot let traffic bypass them. IPv4 only — add matching
# ip6tables rules or disable IPv6, or IPv6 traffic bypasses the tunnel.
# Remove later with `sudo iptables -D OUTPUT <rule spec>` for each rule. [verify 2026-10-29]
VPN_SERVER_IP=203.0.113.10   # replace: IP from the `remote` line
VPN_PORT=1194                # replace: port from the `remote` line
sudo iptables -I OUTPUT 1 -o lo -j ACCEPT
sudo iptables -I OUTPUT 2 -d "$VPN_SERVER_IP" -p udp --dport "$VPN_PORT" -j ACCEPT
sudo iptables -I OUTPUT 3 ! -o tun0 -j DROP
```

```powershell
# Windows: allow only the VPN adapter and the VPN server IP, then default-deny outbound.
# Block rules always beat allow rules in Windows Firewall (there is no rule ordering), so
# never add a "block everything" rule — the allow rules would never match. Default-deny only
# drops traffic that matches no outbound rule, so review existing enabled outbound Allow rules.
# Create the allow rules first: if one fails, you are not left with outbound blocked. [verify 2026-10-29]
# Replace both placeholders; the adapter alias is listed by Get-NetAdapter.
New-NetFirewallRule -DisplayName "Allow VPN tunnel" -Direction Outbound -Action Allow -InterfaceAlias "<VPN_ADAPTER_ALIAS>"
New-NetFirewallRule -DisplayName "Allow VPN server" -Direction Outbound -Action Allow -RemoteAddress "<VPN_SERVER_IP>"
Set-NetFirewallProfile -Profile Domain,Private,Public -DefaultOutboundAction Block
# Undo:
# Set-NetFirewallProfile -Profile Domain,Private,Public -DefaultOutboundAction Allow
# Remove-NetFirewallRule -DisplayName "Allow VPN tunnel","Allow VPN server"
```

### Tor Configuration

**When to Use Tor:**
- High-risk investigations (criminal, nation-state)
- Maximum anonymity required
- Adversary has sophisticated tracking capabilities
- Investigating dark web resources

**Tor Browser Best Practices:**
```bash
# Download Tor Browser from official site only:
# https://www.torproject.org/ [verify 2026-10-25]
# Tor Browser is built on a Firefox ESR base; verify current major
# (Tor Browser 15.x, Firefox ESR 140 base, shipped 2025-10-28; 15.0.26 as of 2026-10-21; 16.0 in alpha) [verify 2026-10-29]

# Verify GPG signature: fetch the Tor Browser Developers signing key over WKD
# (fingerprint EF6E 286D DA85 EA2A 4BA7 DE68 4E2C 6E87 9329 8290), then check the .asc [verify 2026-10-29]
gpg --auto-key-locate nodefault,wkd --locate-keys torbrowser@torproject.org
gpg --verify tor-browser-linux-x86_64-*.tar.xz.asc

# Security slider: set to "Safest" — JavaScript disabled on all sites; some fonts,
# icons, math symbols and images disabled; audio/video click-to-play [verify 2026-10-29]
# about:preferences#privacy → Security Level → Safest

# Window size: Tor Browser starts with its content window rounded to a multiple of 200x100 px.
# If you maximize or resize, keep letterboxing (the margins it adds around the page):
# it keeps you in one of a couple of shared screen-size buckets [verify 2026-10-29]
# Never install extensions (fingerprinting via extension detection)
# Never login to personal accounts over Tor
```

**Mullvad Browser (non-Tor anti-fingerprinting alternative):**

```text
Tor Project + Mullvad collaboration, launched April 2023. [verify 2026-10-25]
Same anti-fingerprinting hardening as Tor Browser, designed to be used
behind a trusted VPN (Mullvad or any other) instead of the Tor network.
Use case: investigations where Tor exit nodes are blocked or where
hostile destinations correlate Tor users heavily, but the analyst
still wants the Tor-Browser-grade fingerprint defenses.
Download: https://mullvad.net/en/browser  [verify 2026-10-25]
```

**Tor over VPN (Recommended for High-Risk):**
```
Your Computer → VPN → Tor Network → Internet
```
- VPN hides Tor usage from ISP
- Tor provides anonymity from VPN provider
- Defense in depth against traffic analysis

**Tor Bridges (Circumvent Tor Blocking):**
```bash
# Use obfs4 bridges if Tor is blocked: [verify 2026-10-25]
# Tor Browser → Settings (≡) → Connection → Bridges → "Request bridges"; or
# https://bridges.torproject.org/options, Telegram @GetBridgesBot, or email
# bridges@torproject.org from a Gmail or Riseup address [verify 2026-10-29]
```

### DNS Security

**DNS Leak Prevention:**

```bash
# Linux: Force all DNS through VPN
# /etc/resolv.conf:
nameserver 10.8.0.1  # VPN DNS server only

# Prevent DHCP from overwriting (note: systemd-resolved manages
# /etc/resolv.conf on most modern distros — use `resolvectl dns`
# or disable systemd-resolved before pinning):
sudo chattr +i /etc/resolv.conf

# Test for DNS leaks (the page is JS-rendered, so use the
# extended-test JSON or a dedicated CLI rather than scraping HTML):
# Browser-based:  https://dnsleaktest.com/  (run "Extended test") [verify 2026-10-25]
# CLI:            https://github.com/macvk/dnsleaktest  (open-source script) [verify 2026-10-25]
```

**Encrypted DNS — protocol options (2024+):**

| Protocol | Port | Notes |
|---|---|---|
| **DoH** (DNS-over-HTTPS, RFC 8484) [verify 2026-10-25] | 443 | Hides DNS in HTTPS traffic; broad client support (Firefox, Chrome, Edge, Safari). |
| **DoT** (DNS-over-TLS, RFC 7858) | 853 | Easier to fingerprint than DoH (dedicated port) but cleaner separation; Android Private DNS uses DoT. [verify 2026-10-25] |
| **DoQ** (DNS-over-QUIC, RFC 9250) | 853/UDP | Latency close to plain DNS over UDP (no TCP head-of-line blocking); AdGuard DNS supports it (`quic://dns.adguard-dns.com`); Cloudflare 1.1.1.1 does not (DoT, DoH, ODoH only). [verify 2026-10-29] |
| **ODoH** (Oblivious DoH, RFC 9230, Experimental) | 443 | Decouples client IP from DNS query via a proxy — resolver never sees who asked. Limited deployment: Cloudflare target `odoh.cloudflare-dns.com`; client support in dnscrypt-proxy. [verify 2026-10-29] |

```javascript
// Firefox: Enable DNS-over-HTTPS
// about:config → network.trr.mode → 3 (enforce DoH; mode 5 disables it) [verify 2026-10-25]
// network.trr.uri → https://mozilla.cloudflare-dns.com/dns-query
// Alternatives: https://dns.quad9.net/dns-query [verify 2026-10-25], https://dns.nextdns.io/<id> (use the per-account endpoint shown in your NextDNS dashboard)
```

**DNS-over-Tor (Maximum Privacy):**
```bash
# dnscrypt-proxy configuration (routes DNS through Tor)
# /etc/dnscrypt-proxy/dnscrypt-proxy.toml (settings per the upstream example config): [verify 2026-10-29]
force_tcp = true
proxy = 'socks5://dnscrypt:dnscrypt@127.0.0.1:9050'  # random user/pass = isolated Tor circuit
```

**Encrypted Client Hello (ECH):**

ECH (RFC 9849, Proposed Standard, March 2026) is a TLS 1.3 extension that
encrypts the SNI (Server Name Indication), hiding the destination hostname from
on-path observers (ISPs, DPI). Without ECH, even DoH leaves the SNI in cleartext
during TLS handshake. Chrome enabled ECH by default in version 117 and Firefox
shipped it in 119 (both 2023); it applies only when the site publishes an ECH
configuration in its HTTPS DNS record, which Cloudflare does by default on Free
zones. Firefox 129+ can fetch that record through the OS resolver (macOS still
requires DoH), but keep DoH on so the lookup itself is encrypted. Firefox prefs:
`network.dns.echconfig.enabled` (TLS) and `network.dns.http3_echconfig.enabled`
(HTTP/3) — both must be `true`. [verify 2026-10-29]

---

## Identity Management

### Research Personas

**Persona Development Framework:**

**1. Basic Identity:**
- Full name (realistic, region-appropriate)
- Age/DOB (affects platform access, e.g., LinkedIn requires 16+) [verify 2026-10-25]
- Location (timezone, language alignment)
- Occupation (justifies platform presence)
- Profile photo (AI-generated, never reverse-searchable)

**2. Digital Footprint:**
- Email address (burner, Proton Mail/Tuta) [verify 2026-10-29]
- Phone number (VoIP, burner SIM, or services like MySudo)
- Bio/description (consistent across platforms)
- Interests/hobbies (support cover story)

**3. Activity History:**
- Account age (older = more trustworthy)
- Post history (realistic content, not empty profile)
- Connections/followers (build gradually)
- Engagement patterns (likes, comments, shares)

**Persona Creation Example:**

```text
Name: Sarah Martinez
Age: 32
Location: Austin, TX
Occupation: Marketing Consultant
Email: sarah.martinez.atx@proton.me
Phone: +1-512-555-0198 (Google Voice)
Photo: AI-generated synthetic face (saved as sarah_martinez_profile.jpg)

Bio: "Marketing consultant specializing in tech startups. Coffee enthusiast, trail runner, and amateur photographer. Views are my own."

Platforms:
- Twitter: @sarahm_atx (created 2023-06-10, 150 followers, posts about marketing/tech)
- LinkedIn: sarah-martinez-marketing (complete profile, 200+ connections)
- Instagram: sarahm_runs (photos of Austin, running, coffee - no personal identifiers)
```

### Profile Warming

**Why Warming Matters:**
- New accounts with no activity flagged as bots/fake
- Empty profiles trigger suspicion from targets
- Platforms restrict access for new accounts (LinkedIn requires connections to view some profiles)

**Profile Warming Timeline (30-day process):**

**Week 1:**
- [ ] Create account with complete profile information
- [ ] Upload profile photo and header image
- [ ] Write bio/description (150-300 characters)
- [ ] Follow 10-20 accounts in target industry
- [ ] Enable 2FA (SMS or authenticator app)

**Week 2:**
- [ ] Post 2-3 times (generic content, no investigation-related)
- [ ] Like/share 5-10 posts per day
- [ ] Join 3-5 relevant groups/communities
- [ ] Update profile (add skills, interests, or experience)

**Week 3:**
- [ ] Increase connections/followers to 50-100
- [ ] Engage with posts (thoughtful comments, not spam)
- [ ] Share external articles (news, industry reports)
- [ ] Upload additional media (photos, videos)

**Week 4:**
- [ ] Profile now appears established and legitimate
- [ ] Begin passive investigation activities (viewing profiles, monitoring)
- [ ] Avoid direct engagement with investigation targets

**Profile Warming Log Template:**

```markdown
# Persona Warming Log: sarah.martinez.atx@proton.me

## Week 1 (2025-09-01 to 2025-09-07)
- 2025-09-01: Created Twitter @sarahm_atx, followed 15 marketing accounts
- 2025-09-02: Uploaded profile photo (AI-generated)
- 2025-09-03: Posted first tweet: "Excited to connect with the Austin tech community!"
- 2025-09-05: LinkedIn profile created, added work history

## Week 2 (2025-09-08 to 2025-09-14)
- 2025-09-08: Posted marketing article to Twitter, 3 likes
- 2025-09-10: Joined "Austin Marketing Professionals" LinkedIn group
- 2025-09-12: Connected with 20 LinkedIn profiles (marketing professionals)

## Week 3 (2025-09-15 to 2025-09-21)
- 2025-09-16: Twitter followers reached 50
- 2025-09-18: Posted photo of Austin coffee shop to Instagram
- 2025-09-20: Commented on 5 LinkedIn posts (thoughtful engagement)

## Week 4 (2025-09-22 to 2025-09-28)
- 2025-09-23: Profile considered "warm" - ready for investigation use
- 2025-09-25: Began monitoring target accounts (passive only)
```

### Burner Accounts & Email

**Email Providers (Anonymity-focused):**
- **Proton Mail** (encrypted, Swiss jurisdiction; signup may require CAPTCHA, email or SMS verification; rebranded from ProtonMail in 2022 — current domain `proton.me`. **Teaching case:** in 2021 a legally binding order from Swiss authorities forced Proton to log a French climate activist's IP address, and the activist was then arrested by French police (Proton: "approval from 3 authorities in 2 countries was required") — Proton complies with Swiss legal orders, "no-logs" applies only to mail content, not to enforced metadata logging.) [verify 2026-10-29]
- **Tuta** (encrypted, German jurisdiction; rebranded from Tutanota in late 2023 — current domain `tuta.com`) [verify 2026-10-25]
- **Guerrilla Mail** (temporary, disposable, no signup) [verify 2026-10-29]
- **SimpleLogin** (email aliasing, masks real address; acquired by Proton 2022) [verify 2026-10-25]
- **Addy.io** (email aliasing, rebranded from AnonAddy in August 2023) [verify 2026-10-29]
- **Apple Hide My Email** (iCloud+ subscribers, generates `@icloud.com` aliases per site, or `@privaterelay.appleid.com` via Sign in with Apple) [verify 2026-10-29]
- **Firefox Relay** (Mozilla; free tier 5 email masks; Premium adds unlimited masks + a personal `mozmail.com` subdomain; phone masking is waitlist-only) [verify 2026-10-29]

**Email Creation Best Practices:**

```bash
# Create Proton Mail account via Tor Browser
# https://proton.me/mail
# Tor onion (verify current v3 address from https://proton.me/tor): [verify 2026-10-25]
#   https://protonmailrmez3lotccipshtkleegetolb73fuirgj7r4o4vfu7ozyd.onion/  [verify 2026-10-25]

# Use password manager for unique passwords:
# Generate 20-character random password
openssl rand -base64 20

# Store credentials in KeePassXC (offline password manager): [verify 2026-10-25]
keepassxc-cli add /home/analyst/osint_personas.kdbx "Sarah Martinez - Proton Mail"
```

**Phone Numbers (Verification):**
- **Google Voice** (US only, requires real Google account for setup) [verify 2026-10-25]
- **MySudo** (multiple numbers, privacy-focused, tiered subscription [verify 2026-10-25 for current pricing])
- **Burner SIM cards** (purchased with cash, disposable). Note: US iPhone 14 and newer are eSIM-only — physical SIM swap into a stock US iPhone is no longer possible; use an Android handset or non-US iPhone for physical-SIM burners. [verify 2026-10-25]
- **eSIM resellers** — convenient for short-term cellular data without a SIM swap. ID checks depend on the provider and destination: Silent.link advertises "No KYC required" (no email; crypto payment), while Airalo asks for a passport (sometimes an address) only where the destination country requires identity verification. [verify 2026-10-29]
- **SMS verification services** (sms-activate.org, 5sim.net, smspva — use with caution; numbers are recycled, no privacy guarantee, and many platforms block known SMS-PVA ranges). [verify 2026-10-25]

**Payment Methods (Anonymous):**
- Cryptocurrency (Bitcoin via mixer-free CoinJoin / Monero for maximum privacy on-chain)
- Prepaid debit cards (purchased with cash; KYC requirements vary by jurisdiction — in the US, FinCEN's 2011 Prepaid Access Rule puts customer-information collection on providers and sellers of covered products; exempt are products of $1,000 or less that cannot be used internationally, transferred between users or reloaded from a non-depository source, and closed-loop products of $2,000 or less) [verify 2026-10-29]
- Cash by mail (Mullvad accepts it; IVPN for 1–3 year plans only) [verify 2026-10-29]
- Provider-issued vouchers (Mullvad voucher codes via resellers — air-gaps the analyst from any direct payment trail) [verify 2026-10-25]

### Password Management

**KeePassXC (Recommended Offline Password Manager):**

```bash
# Create encrypted password database (-p sets a password; without -p or --set-key-file nothing is created) [verify 2026-10-29]
keepassxc-cli db-create -p /home/analyst/osint_personas.kdbx

# Add persona credentials (-u is --username; the URL needs --url) [verify 2026-10-29]
keepassxc-cli add /home/analyst/osint_personas.kdbx "Twitter - @sarahm_atx" \
  --username sarah.martinez.atx@proton.me \
  --password-prompt \
  --url "https://x.com/sarahm_atx" \
  --notes "Created 2023-06-10, warming complete 2023-07-10"

# Backup database to encrypted volume
cp /home/analyst/osint_personas.kdbx /mnt/encrypted_backup/
```

**Password Database Structure:**

```
OSINT Personas Database
├── Twitter Accounts/
│   ├── @sarahm_atx (Sarah Martinez)
│   ├── @crypto_researcher_512 (John Doe)
├── LinkedIn Accounts/
│   ├── sarah-martinez-marketing
│   ├── john-doe-crypto
├── Email Accounts/
│   ├── sarah.martinez.atx@proton.me
│   ├── j.doe.crypto@tuta.com
├── VPN Credentials/
│   ├── Mullvad VPN (Account: 1234567890123456)
├── Phone Numbers/
│   ├── Google Voice +1-512-555-0198 (Sarah Martinez)
```

---

## Browser Security

### Browser Fingerprinting

**What is Browser Fingerprinting?**
Websites collect data about your browser configuration to create a unique "fingerprint":
- Screen resolution, color depth, timezone
- Installed fonts, plugins, extensions
- Canvas/WebGL rendering signatures
- User-Agent string, Accept-Language headers
- Battery status, hardware concurrency (CPU cores)

**Test Your Fingerprint:**
- https://coveryourtracks.eff.org/ (formerly Panopticlick) [verify 2026-10-25]
- https://amiunique.org/ [verify 2026-10-25]
- https://browserleaks.com/ [verify 2026-10-25]

**Goal:** Make your browser fingerprint as common as possible, or use Tor Browser (all users have identical fingerprints).

### Browser Configuration

**Option 1: Firefox (Privacy-Hardened)**

**Firefox `about:config` Tweaks:**

```javascript
// Disable WebRTC (prevents IP leak) [verify 2026-10-25]
media.peerconnection.enabled → false

// Disable geolocation [verify 2026-10-25]
geo.enabled → false

// Resist fingerprinting (timezone spoofed to UTC, window size rounded to 200x100, etc.) [verify 2026-10-29]
privacy.resistFingerprinting → true

// Disable telemetry (toolkit.telemetry.enabled is locked to false on release builds;
// the upload pref below is the one that matters) [verify 2026-10-29]
datareporting.healthreport.uploadEnabled → false

// Force DNS through SOCKS proxy (when using Tor/VPN) [verify 2026-10-25]
network.proxy.socks_remote_dns → true

// Reject all third-party cookies. Firefox's default (5) partitions third-party
// cookies instead; 1 is stricter but breaks more sites [verify 2026-10-29]
network.cookie.cookieBehavior → 1

// HTTPS-only mode [verify 2026-10-25]
dom.security.https_only_mode → true
```

**Firefox Extensions (Privacy):**
- **uBlock Origin** (block trackers, ads, malicious domains) [verify 2026-10-25]
- **NoScript** (block JavaScript by default, allow per-site)
- **Privacy Badger** (block trackers automatically) [verify 2026-10-25]
- **Cookie AutoDelete** (delete cookies when tab closes; no release since December 2022) [verify 2026-10-29]
- No User-Agent switcher — see [User-Agent (Do Not Rotate)](#user-agent-do-not-rotate)

**Firefox Container Tabs (Persona Isolation):**

```bash
# Install Firefox Multi-Account Containers extension [verify 2026-10-25]
# Create container for each persona:
# - "Sarah Martinez" container (isolated cookies, storage)
# - "John Doe" container (isolated cookies, storage)
# - "Personal" container (never use for investigations)

# Containers prevent cross-contamination of sessions
```

**Option 2: Brave Browser (Privacy-Focused Chromium)**

**Brave Settings:**
- Shields: Aggressive (block ads, trackers, scripts) [verify 2026-10-25]
- Fingerprinting protection: Standard — Brave announced in January 2024 that Strict mode would be removed in desktop and Android 1.64; don't rely on Brave for Tor-Browser-grade fingerprint uniformity [verify 2026-10-29]
- Cookies: Block all third-party cookies
- WebRTC: Disabled or proxied through VPN [verify 2026-10-25]
- HTTPS by Default: built in since Brave 1.50 (February 2023), replacing the unmaintained HTTPS Everywhere list [verify 2026-10-29]
- Private window with Tor: Use for high-risk investigations (note: Brave's Tor mode is convenience-tier, not Tor-Browser-grade — for adversaries above Level 3, use real Tor Browser) [verify 2026-10-25]

**Option 3: LibreWolf (Pre-hardened Firefox fork)**

```text
Open-source Firefox fork shipping with telemetry disabled,
RFP (`privacy.resistFingerprinting`) on by default, uBlock Origin
pre-installed, DRM disabled, and search engines pruned. Useful as a
"sane defaults" privacy browser for analysts who don't want to maintain
the about:config tweak list manually. Not anti-fingerprinting at the
Tor Browser level, but a strong baseline.
Download: https://librewolf.net/  [verify 2026-10-25]
```

**Option 4: Tor Browser (Maximum Anonymity)**

**Tor Browser Configuration:**
- Security Level: **Safest** (disables JavaScript, some fonts, images) [verify 2026-10-25]
- Window size: Tor Browser starts with its content window rounded to a multiple of 200x100 px. If you maximize or resize, keep letterboxing (the margins it adds around the page): it keeps you in one of a couple of shared screen-size buckets [verify 2026-10-29]
- Never install extensions (fingerprinting via extension detection)
- Never login to accounts that reveal identity
- Use .onion sites when available (end-to-end Tor encryption)

### User-Agent (Do Not Rotate)

Do not install User-Agent switcher extensions or set `general.useragent.override` in an investigation browser. With `privacy.resistFingerprinting` on (Firefox, LibreWolf, Tor Browser, Mullvad Browser), the browser version is reported as the most recent ESR, so RFP users share the same value; Mozilla notes the OS is not spoofed. A manual override swaps that shared value for one few other users send, which makes the browser easier to single out, not harder. arkenfox's user.js warns "DO NOT USE extensions to alter RFP protected metrics" and lists `general.useragent.override` among prefs that "can interfere with built-in solutions such as RFP and FPP" (https://wiki.mozilla.org/Security/Fingerprinting; https://github.com/arkenfox/user.js). [verify 2026-10-29]

UA overrides belong only in disposable headless automation (Selenium/Playwright). Copy the string from a current release of the browser you are imitating when the job runs. Never take it from a hard-coded list, because those go stale as browsers update.

### Cookie & Session Management

**Cookie Best Practices:**
- Clear cookies after each investigation session
- Use browser containers to isolate persona cookies
- Export/import cookies for long-term persona maintenance
- Never mix personal and research persona cookies

**Cookie Management Tools:**

```bash
# Firefox: Export cookies for persona preservation
# Install "Cookie-Editor" (imports/exports JSON, Netscape or header string;
# Cookie Quick Manager has had no release since July 2019) [verify 2026-10-29]
# Export cookies for @sarahm_atx → save as sarahm_atx_cookies.json

# Import cookies for next session:
# Cookie-Editor → Import → sarahm_atx_cookies.json
```

**Session Storage:**

```javascript
// Clear session storage between investigations (Browser Console):
sessionStorage.clear();
localStorage.clear();
```

---

## Operational Rules

### No-Go Actions (Strictly Prohibited)

**Never do the following during investigations:**

1. **Login to Personal Accounts**
   - ❌ Check personal email, social media, or bank accounts in investigation browser/VM
   - Risk: Links research personas to real identity via session correlation

2. **Direct Engagement with Target**
   - ❌ Like, comment, DM, or follow target accounts without authorization
   - Risk: Alerts target to investigation, creates notification trail

3. **Real Identity Disclosure**
   - ❌ Use real name, work email, or organization in personas
   - Risk: Attribution, legal liability, physical safety

4. **Unsecured Evidence Transmission**
   - ❌ Email screenshots via unencrypted email
   - ❌ Upload evidence to cloud storage (Google Drive, Dropbox)
   - Risk: Evidence leaked, chain of custody broken

5. **Credential Reuse**
   - ❌ Reuse passwords across personas or personal accounts
   - Risk: One breach compromises all accounts

6. **Public Wi-Fi Without VPN**
   - ❌ Conduct investigations over coffee shop, hotel, or airport Wi-Fi
   - Risk: Traffic interception, man-in-the-middle attacks

### Authorized Actions (Pre-Approved)

**Passive Collection (Low Risk):**
- ✅ Viewing public profiles (no login required)
- ✅ Searching public posts, hashtags, or keywords
- ✅ Archiving websites with Archive.org or archive.is [verify 2026-10-25]
- ✅ Downloading publicly available files (images, PDFs)
- ✅ WHOIS lookups, DNS queries, blockchain analysis

**Active Collection (Requires Authorization):**
- ⚠️ Creating burner accounts (document persona details)
- ⚠️ Requesting to connect/follow targets (approval required)
- ⚠️ Sending messages or interacting with targets (scripted, supervised)
- ⚠️ Purchasing services or products (payment method, legal review)

### Timing & Behavioral Patterns

**Avoid Automated Patterns:**
- ❌ Viewing 100 profiles in 10 minutes (scraping detection)
- ❌ Posting at exactly 09:00 every day (bot-like behavior)
- ❌ Following accounts in rapid succession (spam detection)

**Human-Like Behavior:**
- ✅ Randomize timing between actions (2-10 minute delays)
- ✅ Vary session duration (15-45 minutes per session)
- ✅ Spread activity across hours/days (not all at once)
- ✅ Occasionally skip days (humans aren't perfectly consistent)

**Timing Randomization Script:**

```python
import time
import random

def human_delay():
    """Random delay between 2-10 minutes"""
    delay = random.randint(120, 600)
    print(f"Waiting {delay} seconds...")
    time.sleep(delay)

def view_profile(profile):
    """Placeholder: the analyst views the profile manually in the persona browser."""
    print(f"View {profile} now")

# Example: View profiles with human-like delays
profiles = ["user1", "user2", "user3"]
for profile in profiles:
    view_profile(profile)
    human_delay()
```

### Staggered Collection

**Why Stagger Collection?**
- Platforms rate-limit rapid queries (429 Too Many Requests)
- Burst activity triggers abuse detection algorithms
- Timing correlation can link multiple research personas

**Staggered Collection Timeline:**

```text
Investigation Target: 50 LinkedIn profiles

BAD (all at once):
09:00-09:30: View all 50 profiles → FLAGGED as scraping

GOOD (staggered over 5 days):
Day 1 (Mon): View 10 profiles between 09:00-17:00 (random intervals)
Day 2 (Tue): View 10 profiles between 10:00-16:00
Day 3 (Wed): Skip day (weekend break simulation)
Day 4 (Thu): View 15 profiles between 14:00-18:00
Day 5 (Fri): View 15 profiles between 09:00-12:00
```

---

## Platform-Specific OPSEC

### LinkedIn

**High-Risk Platform (Robust View Tracking):**

**Attribution Risks:**
- Target receives "Who viewed your profile" notification
- LinkedIn correlates accounts by IP, device fingerprint, behavior
- Premium accounts see full viewer details (name, headline, company) [verify 2026-10-25]

**OPSEC Measures:**

```text
✅ Use burner account with complete, realistic profile
✅ Enable Private mode (Me → Settings & Privacy → Visibility → Visibility when
   viewing other profiles → Private mode)
   - Note: Basic accounts then lose "Who's viewed your profile"; Premium keeps the
     90-day list (but never sees names of private-mode viewers) [verify 2026-10-29]
✅ Build 100+ connections before investigating (established account)
✅ Never view target profile more than once per week
✅ Try the public profile logged out (https://www.linkedin.com/in/USERNAME in a clean
   private window) — works only if the target left public visibility on, and
   LinkedIn may prompt non-members to sign in to see parts of it [verify 2026-10-29]
✅ Alternative: Use search engines (site:linkedin.com "target name" "company")
```

**LinkedIn Private Mode:**

```text
Private Mode ON:
- Target sees: "LinkedIn Member - This person is viewing profiles in private mode" [verify 2026-10-29]
- Basic account: you cannot see who viewed your profile

Private Mode OFF:
- Target sees: Your name, headline, company, profile photo
- You can see who viewed your profile
```

### Twitter/X

**Medium-Risk Platform (Limited View Tracking):**

**Attribution Risks:**
- No profile view notifications (safe to browse) [verify 2026-10-25]
- Rate limiting on API and scraping
- Account suspension for TOS violations (automation, fake accounts)

**OPSEC Measures:**

```text
⚠️ Nitter: treat as unavailable. X Corp. sent cease-and-desist letters (24 Aug and
   8 Sep 2026) demanding a permanent takedown of Nitter instances and the project's
   repository; zedeus/nitter was archived on 9 Oct 2026, nitter.net now shows only
   the maintainer's notice, and xcancel.com returns HTTP 451. Do not rely on public
   instances or self-host one for investigations.
   Status: https://nitter.net/  [verify 2026-10-29]
✅ Burner account NOT required for many public tweets via X's logged-out
   web view (verify per-page; X has progressively gated read access).
✅ For archiving, prefer:
   - Wayback Machine (archive.org/web/) — rate-limited but stable [verify 2026-10-25]
   - Archive.today (archive.is) — captures dynamic content well [verify 2026-10-25]
   - yt-dlp for media (single posts only; no X profile/timeline extractor) [verify 2026-10-29]
     yt-dlp "https://x.com/USERNAME/status/POST_ID" --skip-download --write-info-json
✅ Avoid liking, retweeting, or following targets (creates audit trail)
```

### Instagram

**High-Risk Platform (Story View Tracking):**

**Attribution Risks:**
- Viewing Stories reveals your account name to target [verify 2026-10-25]
- Viewing profiles does NOT notify target (unlike LinkedIn) [verify 2026-10-25]
- Instagram aggressively detects fake accounts

**OPSEC Measures:**

```text
✅ Use burner account with realistic profile (profile photo, bio, 10+ posts)
✅ NEVER view Instagram Stories (target sees viewer list) [verify 2026-10-25]
✅ Use Instagram web viewer (no app installation, harder to track)
✅ Download posts with yt-dlp / gallery-dl instead of viewing in Instagram: [verify 2026-10-25]
   # yt-dlp fetches public posts logged out until Instagram's anonymous rate limit
   # redirects it to the login page; then pass the same burner/persona cookies.txt.
   # Private posts also require the persona to follow the account — direct engagement,
   # authorization required. Logged-in automated collection breaches Instagram's terms;
   # get sign-off per the Legal & Ethics SOP (sop-legal-ethics) [verify 2026-10-29]
   yt-dlp "https://www.instagram.com/p/POST_ID/"
   yt-dlp --cookies /home/analyst/personas/PERSONA/instagram-cookies.txt "https://www.instagram.com/p/POST_ID/"
   # gallery-dl logs in to Instagram with cookies only (username/password login is no
   # longer supported). Use a Netscape-format cookies.txt from the burner/persona
   # account, never cookies from your personal account [verify 2026-10-29]
   gallery-dl --cookies /home/analyst/personas/PERSONA/instagram-cookies.txt "https://www.instagram.com/USERNAME/"
⚠️ Bibliogram is DEFUNCT (discontinued 2022-09-01 after Instagram cracked down on the routes it scraped). [verify 2026-10-29]
   No reliable Instagram privacy frontend currently exists; archive via
   Wayback Machine / archive.today, or use a fully isolated burner browser.
```

### Telegram

**Medium-Risk Platform (Last Seen Tracking):**

**Attribution Risks:**
- "Last seen" timestamp reveals when you're online
- Opening a target's Story puts you on their viewer list ("like a read receipt"); Telegram documents no profile-view notification [verify 2026-10-29]
- Phone number required for signup (use burner SIM/VoIP) [verify 2026-10-25]

**OPSEC Measures:**

```text
✅ Disable "Last Seen": Settings → Privacy & Security → Last Seen & Online → Nobody [verify 2026-10-25]
✅ Disable "Profile Photo": Settings → Privacy & Security → Profile Photo → My Contacts
✅ Use Telegram Desktop (not mobile app with real SIM card)
✅ Phone number via VoIP (Google Voice, MySudo) or burner SIM
✅ Join public channels only (no DMs with targets)
✅ Use Telegram's public preview (no login required):
   https://t.me/s/CHANNEL_NAME  [verify 2026-10-25]
```

### Reddit

**Low-Risk Platform (Anonymous Browsing):**

**Attribution Risks:**
- No profile view notifications
- Sign-up needs an email (6-digit code), a Google/Apple account, or — in some countries — a phone number [verify 2026-10-29]
- Platform tolerates anonymous research

**OPSEC Measures:**

```text
✅ Privacy frontends (status as of October 2026):
   - Redlib (active fork of the archived Libreddit project): https://github.com/redlib-org/redlib  [verify 2026-10-25]
   - Teddit: unmaintained (README: "teddit is no more actively maintained!"; last commit April 2025) — do not rely on it [verify 2026-10-29]
   Reddit's mid-2023 API pricing change broke many third-party clients. [verify 2026-10-25]
   Privacy frontends rely on scraping and degrade when Reddit changes its HTML.
⚠️ old.reddit.com requires login since July 2026; logged-out browsing still works on
   www.reddit.com (Reddit Changelog, 9 Jul 2026). RSS feeds end 2026-11-13. Public API:
   new access requests close 2026-10-31, removal begins 2027-01-12, remaining access
   ends March 2027 (Reddit Changelog, 8 Oct 2026). [verify 2026-10-29]
✅ For account creation: burner email, unique password, VPN
   (Unverified community reports: new accounts from VPN IP ranges may face extra
   verification; Reddit's Help Center documents no such rule.)
✅ Avoid commenting or posting (creates audit trail)
✅ Pushshift historical archive is now mod-restricted; arctic_shift /
   academic mirrors (e.g., Watchful1's torrents) are the public route. [verify 2026-10-25]
```

### Facebook

**High-Risk Platform (Extensive Tracking):**

**Attribution Risks:**
- No profile-view notifications (Facebook "doesn't let people track who views their profile"), but Story posters see who viewed their story [verify 2026-10-29]
- Aggressive fake account detection (phone number verification)
- Friend suggestions algorithm links research personas to real identity
- Pixel tracking across websites

**OPSEC Measures:**

```text
✅ Avoid Facebook if possible (highest OPSEC risk)
✅ If required: burner account with aged profile (6+ months old)
✅ Complete profile (school, work, friends, posts) to avoid detection
✅ NEVER friend or message targets
✅ View the target's public profile from the burner (Facebook does not notify
   profile views; "View as" previews only your own profile) — NEVER open their
   Stories (the poster sees the viewer list) [verify 2026-10-29]
✅ Block Facebook tracking with uBlock Origin filters
```

---

## Detection Indicators

### Platform Detection Mechanisms

**Automated Bot Detection:**
- Rapid clicking or scrolling (inhuman speed)
- Repeated actions in perfect intervals (not randomized)
- High volume of requests in short time (scraping)
- Missing cookies or JavaScript disabled (headless browsers)
- CAPTCHA challenges (solve manually, never automate)

**Account Linking Detection:**
- Same IP address across multiple accounts
- Identical browser fingerprints
- Shared cookies or session storage
- Similar naming patterns (sarahm_atx, sarahm_linkedin)
- Activity timing correlation (both accounts active simultaneously)

**Behavioral Anomalies:**
- New account immediately viewing profiles (no organic activity)
- Empty profile with no posts or connections
- Profile information inconsistencies (Austin, TX but timezone is UTC+8)
- Unusual activity patterns (viewing 50 profiles at 3 AM)

### Signs You've Been Detected

**Platform-Side Detection:**
- ⚠️ CAPTCHA challenges appear frequently
- ⚠️ Account locked or suspended ("suspicious activity")
- ⚠️ Login requires phone verification (previously didn't)
- ⚠️ Rate limiting (429 errors, "try again later")
- ⚠️ Features restricted (can't view profiles, send messages)

**Target-Side Detection:**
- ⚠️ Target mentions "suspicious profile views" in posts
- ⚠️ Target's account goes private immediately after your research
- ⚠️ Target blocks your research persona
- ⚠️ Target posts screenshots of "fake accounts" matching your persona

**Investigator-Side Indicators:**
- ⚠️ VPN suddenly blocked by platform
- ⚠️ Browser fingerprint unique (fails EFF Cover Your Tracks)
- ⚠️ DNS leaks detected (real IP exposed)
- ⚠️ WebRTC leaks detected (real IP exposed)

### Self-Assessment Tests

**Weekly OPSEC Audit:**

```bash
# 1. Check IP address (should be VPN exit node) [verify 2026-10-25]
curl -s https://ifconfig.me

# 2. Check DNS leaks. dnsleaktest.com is JavaScript-driven, so use its CLI script
#    (needs curl and ping); every resolver it lists must belong to the VPN [verify 2026-10-29]
curl -fL --create-dirs -o /home/analyst/tools/dnsleaktest.sh https://raw.githubusercontent.com/macvk/dnsleaktest/master/dnsleaktest.sh
chmod +x /home/analyst/tools/dnsleaktest.sh
/home/analyst/tools/dnsleaktest.sh

# 3. Check WebRTC leaks (Firefox console):
# about:config → media.peerconnection.enabled → false (verify)

# 4. Browser fingerprint test
# Visit: https://coveryourtracks.eff.org/
# Result should read: "strong protection against Web tracking" [verify 2026-10-29]

# 5. Tor circuit (if using Tor Browser)
# Main menu (≡) → "New Tor circuit for this site" (also in the circuit display of the
# site information menu in the URL bar) [verify 2026-10-29]
```

**Persona Audit Checklist:**
- [ ] Profile photo NOT reverse-searchable (TinEye, Google Images)
- [ ] Bio/description unique (not copy-pasted from real profile)
- [ ] Account age >30 days (if active investigation)
- [ ] Activity history looks human (not empty or bot-like)
- [ ] Connections/followers realistic (not 0 or 10,000)
- [ ] No links to real identity (search persona name + "real name")

---

## Incident Response

### OPSEC Breach Scenarios

**Scenario 1: Persona Account Suspended**

**Immediate Actions:**
1. Do NOT attempt to appeal or recover account (draws more attention)
2. Document suspension notice (screenshot, date/time, reason given)
3. Notify supervisor/team lead
4. Assess impact: Did suspension reveal investigation to target?
5. Switch to backup persona or pause investigation

**Long-Term Actions:**
- Review logs to identify detection trigger (timing, volume, behavior)
- Improve persona warming for future accounts
- Consider using aged accounts purchased from vendors (risky, not recommended)

**Scenario 2: VPN/Tor Exit Node Blocked**

**Immediate Actions:**
1. Switch to different VPN server or Tor circuit
2. Test new connection with https://ifconfig.me [verify 2026-10-25]
3. Verify DNS and WebRTC not leaking
4. Resume investigation if clean

**Alternative Solutions:**
- Use residential proxies (more expensive, harder to detect)
- Switch to mobile network (4G/5G hotspot)
- Use cloud VPS as proxy (AWS, DigitalOcean with VPN)

**Scenario 3: Target Notices Investigation**

**Immediate Actions:**
1. STOP all active collection immediately
2. Do NOT delete personas (appears suspicious, may violate evidence preservation)
3. Document target's awareness (screenshot posts, DMs, or public statements)
4. Notify legal team and supervisor
5. Prepare incident report

**Assessment Questions:**
- How did target become aware? (profile view notification, behavioral red flags?)
- What information was exposed? (persona details, organization affiliation?)
- Is investigation compromised? (target deleting evidence, going dark?)
- Legal implications? (terms of service violation, unauthorized access?)

**Scenario 4: IP Address Leaked (DNS/WebRTC Leak)**

**Immediate Actions:**
1. Disconnect from network immediately
2. Verify leak with multiple tests (browserleaks.com, ipleak.net) [verify 2026-10-25]
3. Identify leak source (DNS, WebRTC, IPv6, etc.)
4. Fix leak (update VPN config, disable WebRTC, block IPv6)
5. Assess exposure: Which sites received real IP? What time period?

**Impact Assessment:**
- If real IP leaked to Google/Facebook: Assume account linking occurred
- If real IP leaked to target's website: Assume attribution compromised
- If real IP leaked to ISP only: Lower risk, but fix immediately

**Scenario 5: Metadata in Screenshot Leaked**

**Immediate Actions:**
1. Identify what metadata was leaked (EXIF GPS, username in taskbar, etc.)
2. Determine who received the leaked screenshot (internal team only, or external?)
3. If external: Assess attribution risk and notify affected parties
4. If internal: Update evidence collection procedures

**Prevention:**
- Before sharing, scrub metadata from a disclosure copy, never from original evidence; originals keep the hashes recorded in the [[sop-collection-log|Collection Log]]
- Use screenshot tools that don't capture taskbar/browser UI
- Review screenshots manually before distribution

### Incident Documentation

**OPSEC Incident Report Template:**

```markdown
# OPSEC Incident Report

**Incident ID:** INC-2025-1005-001
**Date/Time:** 2025-10-05 14:30:00 UTC
**Investigator:** [Your Name]
**Case ID:** CASE-2025-001

## Incident Summary
Brief description of what happened (1-2 sentences).

## Timeline of Events
- 14:25: Began viewing target LinkedIn profile (persona: @sarahm_atx)
- 14:30: Received account suspension notice from LinkedIn
- 14:31: Disconnected from VPN, switched to backup persona
- 14:35: Notified supervisor via secure channel

## Root Cause Analysis
What went wrong?
- Account too new (created 10 days ago, not fully warmed)
- Viewed 15 profiles in 20 minutes (too rapid)
- Possible IP correlation with previous suspended account

## Impact Assessment
- Persona compromised: Yes (@sarahm_atx suspended)
- Investigation compromised: No (target unaware)
- Attribution risk: Low (persona not linked to real identity)
- Evidence loss: None (all evidence already collected)

## Corrective Actions
- [ ] Implement 30-day warming period for all personas (not 10 days)
- [ ] Limit profile views to 5 per session (not 15)
- [ ] Use dedicated VPN server per persona (prevent IP correlation)

## Lessons Learned
- LinkedIn's detection is more aggressive than previously assessed
- Profile warming timeline needs extension
- Backup personas should be maintained in parallel
```

---

## OPSEC Checklist

### Pre-Investigation Checklist

**Environment Setup:**
- [ ] Investigation VM or isolated environment ready
- [ ] Clean snapshot taken (can revert if needed)
- [ ] VPN connected and verified (curl https://ifconfig.me) [verify 2026-10-25]
- [ ] DNS leak test passed (/home/analyst/tools/dnsleaktest.sh — every resolver listed belongs to the VPN) [verify 2026-10-29]
- [ ] WebRTC disabled (Firefox: media.peerconnection.enabled → false)
- [ ] Browser fingerprint tested (coveryourtracks.eff.org → strong protection)
- [ ] No personal accounts logged in (check browser sessions)

**Identity & Persona:**
- [ ] Research persona selected and documented
- [ ] Persona warming completed (30-day timeline)
- [ ] Password retrieved from KeePassXC
- [ ] Persona cookies imported (if returning to existing session)
- [ ] Timezone: with `privacy.resistFingerprinting` on, the browser reports UTC; that is expected and the same for every RFP user, so leave it. The persona's posting schedule, profile details and any non-RFP environment follow the persona's location (e.g., America/Chicago — CST/CDT — for an Austin persona) [verify 2026-10-29]
- [ ] Language settings match persona (e.g., en-US)

**Legal & Authorization:**
- [ ] Investigation scope approved by supervisor
- [ ] Legal review completed (if required)
- [ ] Collection log prepared: [[sop-collection-log]]
- [ ] Escalation contacts identified (if sensitive content encountered)

### During Investigation Checklist

**Operational Security:**
- [ ] VPN connection stable (monitor for disconnects)
- [ ] Human-like behavior maintained (randomized timing, 2-10 min delays)
- [ ] No direct engagement with targets (no likes, DMs, follows)
- [ ] Screenshots captured with URL and timestamp visible
- [ ] Evidence logged immediately in collection log
- [ ] Session duration reasonable (<45 minutes per session)

**Awareness & Monitoring:**
- [ ] No CAPTCHA challenges encountered (sign of detection)
- [ ] No account warnings or suspicious activity alerts
- [ ] Target behavior unchanged (no sudden privacy changes)
- [ ] No unusual platform behavior (rate limiting, errors)

### Post-Investigation Checklist

**Evidence Handling:**
- [ ] All evidence copied to secure storage
- [ ] SHA-256 hashes calculated for all files
- [ ] Metadata scrubbed from disclosure copies only (ExifTool -all=), never from original evidence; originals keep the hashes recorded above ([[../../Security/Analysis/sop-hash-generation-methods|Hash Generation Methods]]). ExifTool keeps `FILE_original` backups that still hold the metadata, so delete them from the disclosure copy [verify 2026-10-29]
- [ ] Evidence encrypted (BitLocker, LUKS, or 7z with password)
- [ ] Collection log updated with all evidence entries

**Cleanup & Shutdown:**
- [ ] Browser cookies exported (if preserving persona session)
- [ ] Browser history cleared (or VM reverted to snapshot)
- [ ] Persona activity logged (for future reference)
- [ ] VPN disconnected
- [ ] VM shut down or snapshot restored

**Review & Documentation:**
- [ ] OPSEC incidents documented (if any occurred)
- [ ] Lessons learned recorded
- [ ] Persona status updated (active, compromised, retired)
- [ ] Next steps identified (follow-up investigation, monitoring, etc.)

---

## Appendix

### Recommended Tools

| Tool                         | Category          | Purpose                                      | Platform              |
| ---------------------------- | ----------------- | -------------------------------------------- | --------------------- |
| **Mullvad VPN**              | Network Security  | Account-number-only VPN, audited no-logs; an April 2023 police search warrant left with no customer data [verify 2026-10-29] | Windows, Linux, macOS |
| **Proton VPN**               | Network Security  | Secure Core multi-hop, Tor over VPN; Swiss jurisdiction [verify 2026-10-25] | Windows, Linux, macOS |
| **IVPN**                     | Network Security  | Account-number-only; one no-logs audit (Cure53, 2019), annual Cure53 security audits since [verify 2026-10-29] | Windows, Linux, macOS |
| **Tor Browser**              | Anonymity         | Maximum anonymity, anti-fingerprinting; Firefox-ESR base [verify 2026-10-25] | Windows, Linux, macOS |
| **Mullvad Browser**          | Anonymity         | Tor-Browser-grade fingerprint defenses for use behind a VPN (no Tor) [verify 2026-10-25] | Windows, Linux, macOS |
| **Whonix**                   | Anonymity         | Tor-routed VM by design (best inside Qubes OS) [verify 2026-10-25] | Linux (VM)            |
| **Tails**                    | Anonymity         | Amnesic live OS, leaves no traces            | USB boot              |
| **Qubes OS**                 | Isolation         | Compartmentalization via xen domains; Whonix-aware [verify 2026-10-25] | Bare metal (x86_64)   |
| **Exegol**                   | Security Testing  | Pre-configured Docker environment with OSINT tools (Community licence: personal, learning and CTF use; work use needs a paid plan) [verify 2026-10-29] | Linux (Docker)        |
| **Kasm Workspaces**          | Isolation         | Browser-based containerized desktop streaming (Community Edition: free, non-commercial, 5 concurrent sessions) [verify 2026-10-29] | Linux (self-hosted)   |
| **Firefox**                  | Browser           | Privacy-hardened with about:config           | Windows, Linux, macOS |
| **LibreWolf**                | Browser           | Pre-hardened Firefox fork (RFP, no telemetry, uBO bundled) [verify 2026-10-25] | Windows, Linux, macOS |
| **Brave**                    | Browser           | Chromium-based, built-in ad/tracker blocking | Windows, Linux, macOS |
| **uBlock Origin**            | Browser Extension | Ad/tracker blocking                          | Firefox, Chromium* [verify 2026-10-25] |
| **NoScript**                 | Browser Extension | JavaScript blocking (built into Tor Browser) | Firefox, Chrome, Edge, Brave [verify 2026-10-29] |
| **Multi-Account Containers** | Browser Extension | Isolate cookies per persona                  | Firefox               |
| **KeePassXC**                | Password Manager  | Offline, encrypted password storage          | Windows, Linux, macOS |
| **Proton Mail**              | Email             | Encrypted email; sign-up may require CAPTCHA, email or SMS verification [verify 2026-10-29] | Web, mobile           |
| **Tuta** (formerly Tutanota) | Email             | Encrypted email, German jurisdiction         | Web, mobile           |
| **SimpleLogin**              | Email Aliasing    | Hides real address (Proton-acquired 2022) [verify 2026-10-25] | Web, browser ext.     |
| **Addy.io**                  | Email Aliasing    | Self-hostable email aliasing (formerly AnonAddy) [verify 2026-10-25] | Web, browser ext.     |
| **MySudo**                   | Phone Number      | Virtual US/UK/Canada numbers for verification (UK numbers require legal ID) [verify 2026-10-29] | iOS, Android, macOS, Windows |
| **YubiKey 5 / Bio**          | Hardware Token    | YubiKey 5: FIDO2/U2F, smart card (PIV), OpenPGP, OTP; YubiKey Bio (FIDO Edition): FIDO2/U2F only [verify 2026-10-29] | USB-A/USB-C; NFC on YubiKey 5 NFC models only |
| **Nitrokey 3**               | Hardware Token    | Open-source hardware and software; FIDO2/U2F, PIV, OpenPGP [verify 2026-10-29] | USB-A/USB-C; NFC on 3A NFC / 3C NFC (not 3A Mini) |
| **ExifTool**                 | Metadata          | Scrub EXIF from images [verify 2026-10-25]   | CLI (all platforms)   |
| **mat2**                     | Metadata          | Scrub metadata from a wide range of formats  | CLI / Dolphin service menu [verify 2026-10-29] |
| **VirtualBox**               | Virtualization    | Free VM software [verify 2026-10-25]         | Windows, Linux, macOS |
| **VMware Workstation**       | Virtualization    | Free for commercial, educational and personal use since Nov 2024; no ticketed support [verify 2026-10-29] | Windows, Linux        |

*Full uBlock Origin (Manifest V2) no longer runs in Chrome: Chrome 138 disabled MV2 extensions for all users on 2025-07-24 with no way to re-enable them, and all remaining MV2 extensions were removed from the Chrome Web Store on 2026-08-31. On Chromium use uBO Lite (the MV3 build), or use Firefox/LibreWolf for full uBO. [verify 2026-10-29]

### Resources & References

**OPSEC Frameworks & Threat-Modeling:**
- ODNI / NCSC resources (OPSEC program plan templates, self-evaluation checklist, NSPM-28 requirements): https://www.odni.gov/about/mission-centers-directorates/ncsc/resources/  [verify 2026-10-29]
- NIST SP 800-53 Rev. 5, Security and Privacy Controls for Information Systems and Organizations: https://csrc.nist.gov/pubs/sp/800/53/r5/upd1/final  [verify 2026-10-29]
- EFF Surveillance Self-Defense: https://ssd.eff.org/  [verify 2026-10-25]
- Tactical Tech "Holistic Security": https://holistic-security.tacticaltech.org/  [verify 2026-10-25]
- Front Line Defenders Workbook on Security: https://www.frontlinedefenders.org/en/resource-publication/workbook-security-practical-steps-human-rights-defenders-risk  [verify 2026-10-25]
- Bellingcat Editorial Standards & Practices (privacy and harm, disguised online identities): https://www.bellingcat.com/about/editorial-standards-practices/  [verify 2026-10-29]
- Bellingcat, "Notes from the Digital Field: Ethical Dilemmas in Open Source Research" (Giancarlo Fiorella, 2023): https://www.bellingcat.com/resources/2023/09/18/notes-from-the-digital-field-ethical-dilemmas-in-open-source-research/  [verify 2026-10-29]
- UN OHCHR Berkeley Protocol on Digital Open Source Investigations (see chapter IV "Security" and annex II, the digital threat and risk assessment template, for OPSEC-relevant guidance): https://www.ohchr.org/en/publications/policy-and-methodological-publications/berkeley-protocol-digital-open-source  [verify 2026-10-29]

**Privacy Testing:**
- Cover Your Tracks (Browser Fingerprinting, EFF): https://coveryourtracks.eff.org/  [verify 2026-10-25]
- DNS Leak Test: https://www.dnsleaktest.com/  [verify 2026-10-25]
- IP Leak Test: https://ipleak.net/  [verify 2026-10-25]
- Browser Leaks (canvas/WebGL/WebRTC/WebGPU): https://browserleaks.com/  [verify 2026-10-25]
- AmIUnique (browser fingerprint research): https://amiunique.org/  [verify 2026-10-25]

**Anonymity Networks & Privacy Browsers:**
- Tor Project: https://www.torproject.org/  [verify 2026-10-25]
- Tor Project — bridges database: https://bridges.torproject.org/  [verify 2026-10-25]
- Mullvad Browser: https://mullvad.net/en/browser  [verify 2026-10-25]
- Whonix: https://www.whonix.org/  [verify 2026-10-25]
- Tails OS: https://tails.net/  (canonical domain; the old tails.boum.org no longer completes an HTTPS connection because its certificate does not match — update bookmarks) [verify 2026-10-29]
- Qubes OS: https://www.qubes-os.org/  [verify 2026-10-25]
- LibreWolf: https://librewolf.net/  [verify 2026-10-25]

**Investigation Environments:**
- Exegol (Community licence: personal, learning and CTF use; work use needs a paid plan): https://exegol.com/  [verify 2026-10-29]
- Kasm Workspaces (Community Edition: free, non-commercial, 5 concurrent sessions): https://kasm.com/  [verify 2026-10-29]

**Persona Management:**
- Fake Name Generator: https://www.fakenamegenerator.com/  [verify 2026-10-25]
- Guerrilla Mail (Temporary Email): https://www.guerrillamail.com/  [verify 2026-10-29]

**Operator OPSEC failure case studies (teaching cases):**

- Marcus Hutchins (MalwareTechBlog) — early-career WannaCry-mitigation researcher. Brian Krebs (Sept 2017) linked his teenage aliases to him through a reused domain-registration email, a Skype account and a 2009 Twitter handle; the lesson is identifier reuse across years. [verify 2026-10-29]
- Ross Ulbricht (Silk Road) — an IRS agent's plain Google search found 2011 Bitcointalk posts by "altoid", one giving rossulbricht@gmail.com as a contact; he was arrested on 1 Oct 2013 in a San Francisco public library while doing admin work on the site. [verify 2026-10-29]
- Reality Winner — yellow printer tracking dots on a leaked NSA document encoded the printer's serial number and the print date and time (9 May 2017). [verify 2026-10-29]

These reinforce the rule that **OPSEC is durable, not perfect** — analysts should assume any single-channel anonymity layer can fail and rely on compartmentalization across persona, network, device, and timing.

---

**Version:** 2.1
**Last Updated:** 2026-10-29
**Review Cycle:** Yearly

---

**Related SOPs:**
[[sop-legal-ethics|Legal & Ethics]] | [[sop-collection-log|Collection Log]] | [[sop-entity-dossier|Entity Dossier]] | [[sop-reporting-packaging-disclosure|Reporting & Disclosure]] | [[Investigations-Index|Investigations Index]]

