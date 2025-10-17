---
type: sop
title: OPSEC Planning for OSINT Investigations
description: "Protect yourself during investigations: VPN setup, burner accounts, browser isolation & operational security best practices for safe OSINT work."
created: 2025-10-05
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
# Base OS: Windows 10/11 or Ubuntu 22.04 LTS

# Take clean snapshot before each investigation
# VMware CLI example:
vmrun snapshot "C:\VMs\OSINT-VM\OSINT-VM.vmx" "Clean_2025-10-05"

# Revert to snapshot after investigation
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
# Firefox in isolated Docker container
docker run -d \
  --name osint-firefox \
  --shm-size=2g \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v /home/analyst/osint-data:/data \
  jlesage/firefox

# Destroy container after investigation
docker stop osint-firefox && docker rm osint-firefox
```

**Option 3: Whonix (Maximum Anonymity)**

```bash
# Whonix Workstation + Gateway (Tor-routed by design)
# Download: https://www.whonix.org/

# All traffic forced through Tor
# DNS leaks impossible by design
# Recommended for high-risk investigations
```

**Option 4: Tails OS (Amnesic Live System)**

```bash
# Tails USB boot (no persistence by default)
# All traffic through Tor
# RAM-only operation (no disk traces)
# Recommended for maximum OPSEC
```

**Option 5: Exegol (Security Testing Environment)**

```bash
# Exegol: Fully-featured security testing Docker environment
# https://exegol.com/

# Install Exegol
pipx install exegol

# Start Exegol container with GUI support
exegol start osint-workspace full

# Features:
# - Pre-configured with 500+ security tools
# - Network isolation by default
# - Easy snapshots and rollback
# - Web browser with privacy extensions
# - OSINT tools pre-installed (theHarvester, nuclei, maltego, etc.)

# Access Exegol GUI (if configured)
# Supports X11 forwarding for GUI applications
exegol start osint-workspace full --X11

# Stop and remove container
exegol stop osint-workspace
exegol remove osint-workspace
```

**Option 6: Kasm Workspaces (Browser-Based Isolation)**

```bash
# Kasm Workspaces: Containerized desktop/app streaming
# https://kasm.com/

# Features:
# - Browser-based access (no local software needed)
# - Each workspace is isolated Docker container
# - Disposable sessions (destroy after use)
# - Remote access from anywhere
# - Pre-built images (Firefox, Chrome, Ubuntu Desktop, Kali Linux)

# Community Edition (free):
# Download from: https://www.kasmweb.com/downloads.html

# Installation (Ubuntu):
cd /tmp
curl -O https://kasm-static-content.s3.amazonaws.com/kasm_release_*.tar.gz
tar -xf kasm_release_*.tar.gz
sudo bash kasm_release/install.sh

# Access Kasm UI:
# https://localhost:443
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
# Windows (BitLocker):
manage-bde -on E: -RecoveryPassword

# Linux (LUKS):
cryptsetup luksFormat /dev/sdb1
cryptsetup luksOpen /dev/sdb1 evidence_vault
mkfs.ext4 /dev/mapper/evidence_vault

# macOS (FileVault):
diskutil apfs encryptVolume /Volumes/Evidence
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
- **Mullvad VPN** (anonymous signup, accepts cash, audited no-logs)
- **ProtonVPN** (Swiss jurisdiction, secure core, Tor over VPN)
- **IVPN** (no email required, audited no-logs, port forwarding)

**VPN Best Practices:**

```bash
# Linux: Verify VPN connection before starting investigation
# Check IP address:
curl -s https://ifconfig.me
# Expected: VPN exit node IP (NOT your real IP)

# Check DNS leak:
nslookup google.com
# Expected: VPN provider's DNS server

# Check WebRTC leak (Firefox):
# about:config → media.peerconnection.enabled → false
```

**VPN Configuration Examples:**

```bash
# OpenVPN (Linux):
sudo openvpn --config mullvad_us_ny.conf --auth-user-pass credentials.txt

# WireGuard (faster, more modern):
sudo wg-quick up mullvad-us-ny

# Verify no traffic leaks outside VPN:
sudo iptables -A OUTPUT ! -o tun0 -j DROP
sudo iptables -A OUTPUT -o tun0 -j ACCEPT
```

**Kill Switch Configuration:**

```powershell
# Windows PowerShell: Block all traffic except VPN
New-NetFirewallRule -DisplayName "Block Non-VPN" -Direction Outbound -Action Block -RemoteAddress Any
New-NetFirewallRule -DisplayName "Allow VPN" -Direction Outbound -Action Allow -RemoteAddress 10.8.0.0/24
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
# https://www.torproject.org/

# Verify GPG signature:
gpg --verify tor-browser-linux64-*.tar.xz.asc

# Security slider: Set to "Safest" (disables JavaScript)
# about:preferences#privacy → Security Level → Safest

# Never resize Tor Browser window (fingerprinting risk)
# Never install extensions (fingerprinting risk)
# Never login to personal accounts over Tor
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
# Use obfs4 bridges if Tor is blocked:
# Tor Browser → Settings → Tor → Bridges → Request from torproject.org
```

### DNS Security

**DNS Leak Prevention:**

```bash
# Linux: Force all DNS through VPN
# /etc/resolv.conf:
nameserver 10.8.0.1  # VPN DNS server only

# Prevent DHCP from overwriting:
sudo chattr +i /etc/resolv.conf

# Test for DNS leaks:
curl -s https://www.dnsleaktest.com/ | grep -i "your ip"
```

**Encrypted DNS (DNS-over-HTTPS):**

```javascript
// Firefox: Enable DNS-over-HTTPS
// about:config → network.trr.mode → 3 (enforce DoH)
// network.trr.uri → https://mozilla.cloudflare-dns.com/dns-query
```

**DNS-over-Tor (Maximum Privacy):**
```bash
# dnscrypt-proxy configuration (routes DNS through Tor)
# /etc/dnscrypt-proxy/dnscrypt-proxy.toml:
force_tcp = true
proxy = 'socks5://127.0.0.1:9050'  # Tor SOCKS proxy
```

---

## Identity Management

### Research Personas

**Persona Development Framework:**

**1. Basic Identity:**
- Full name (realistic, region-appropriate)
- Age/DOB (affects platform access, e.g., LinkedIn requires 16+)
- Location (timezone, language alignment)
- Occupation (justifies platform presence)
- Profile photo (AI-generated, never reverse-searchable)

**2. Digital Footprint:**
- Email address (burner, ProtonMail/Tutanota)
- Phone number (VoIP, burner SIM, or services like MySudo)
- Profile photo (ThisPersonDoesNotExist.com)
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
Email: sarah.martinez.atx@protonmail.com
Phone: +1-512-555-0198 (Google Voice)
Photo: thispersondoesnotexist.com (saved as sarah_martinez_profile.jpg)

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
# Persona Warming Log: sarah.martinez.atx@protonmail.com

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
- **ProtonMail** (encrypted, no phone required for paid accounts)
- **Tutanota** (encrypted, German jurisdiction)
- **Guerrilla Mail** (temporary, disposable, no signup)
- **SimpleLogin** (email aliasing, masks real address)

**Email Creation Best Practices:**

```bash
# Create ProtonMail account via Tor Browser
# https://protonmail.com/ (Tor onion: https://protonmailrmez3lotccipshtkleegetolb73fuirgj7r4o4vfu7ozyd.onion/)

# Use password manager for unique passwords:
# Generate 20-character random password
openssl rand -base64 20

# Store credentials in KeePassXC (offline password manager):
keepassxc-cli add /home/analyst/personas.kdbx "Sarah Martinez - ProtonMail"
```

**Phone Numbers (Verification):**
- **Google Voice** (US only, requires real Google account for setup)
- **MySudo** (multiple numbers, privacy-focused, $0.99/month per number)
- **Burner SIM cards** (purchased with cash, disposable)
- **SMS verification services** (sms-activate.org, 5sim.net - use with caution, no privacy)

**Payment Methods (Anonymous):**
- Cryptocurrency (Bitcoin, Monero for maximum privacy)
- Prepaid debit cards (purchased with cash, no ID required)
- Cash by mail (some VPN providers accept)

### Password Management

**KeePassXC (Recommended Offline Password Manager):**

```bash
# Create encrypted password database
keepassxc-cli db-create /home/analyst/osint_personas.kdbx

# Add persona credentials
keepassxc-cli add /home/analyst/osint_personas.kdbx "Twitter - @sarahm_atx" \
  --username sarah.martinez.atx@protonmail.com \
  --password-prompt \
  -u "https://twitter.com/sarahm_atx" \
  --notes "Created 2023-06-10, warming complete 2023-07-10"

# Backup database to encrypted volume
cp osint_personas.kdbx /mnt/encrypted_backup/
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
│   ├── sarah.martinez.atx@protonmail.com
│   ├── j.doe.crypto@tutanota.com
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
- https://coveryourtracks.eff.org/ (formerly Panopticlick)
- https://amiunique.org/
- https://browserleaks.com/

**Goal:** Make your browser fingerprint as common as possible, or use Tor Browser (all users have identical fingerprints).

### Browser Configuration

**Option 1: Firefox (Privacy-Hardened)**

**Firefox `about:config` Tweaks:**

```javascript
// Disable WebRTC (prevents IP leak)
media.peerconnection.enabled → false

// Disable geolocation
geo.enabled → false

// Resist fingerprinting (spoofs timezone, screen size, etc.)
privacy.resistFingerprinting → true

// Disable telemetry
toolkit.telemetry.enabled → false
datareporting.healthreport.uploadEnabled → false

// Force DNS through SOCKS proxy (when using Tor/VPN)
network.proxy.socks_remote_dns → true

// Block third-party cookies
network.cookie.cookieBehavior → 1

// HTTPS-only mode
dom.security.https_only_mode → true
```

**Firefox Extensions (Privacy):**
- **uBlock Origin** (block trackers, ads, malicious domains)
- **NoScript** (block JavaScript by default, allow per-site)
- **Privacy Badger** (block trackers automatically)
- **Cookie AutoDelete** (delete cookies when tab closes)
- **User-Agent Switcher** (rotate User-Agent strings)

**Firefox Container Tabs (Persona Isolation):**

```bash
# Install Firefox Multi-Account Containers extension
# Create container for each persona:
# - "Sarah Martinez" container (isolated cookies, storage)
# - "John Doe" container (isolated cookies, storage)
# - "Personal" container (never use for investigations)

# Containers prevent cross-contamination of sessions
```

**Option 2: Brave Browser (Privacy-Focused Chromium)**

**Brave Settings:**
- Shields: Aggressive (block ads, trackers, scripts)
- Fingerprinting protection: Strict
- Cookies: Block all third-party cookies
- WebRTC: Disabled or proxied through VPN
- HTTPS Everywhere: Enabled
- Private window with Tor: Use for high-risk investigations

**Option 3: Tor Browser (Maximum Anonymity)**

**Tor Browser Configuration:**
- Security Level: **Safest** (disables JavaScript, some fonts, images)
- Never maximize window (fingerprinting via screen resolution)
- Never install extensions (fingerprinting via extension detection)
- Never login to accounts that reveal identity
- Use .onion sites when available (end-to-end Tor encryption)

### User-Agent Rotation

**Why Rotate User-Agent?**
- Default User-Agent reveals OS, browser version, device type
- Static User-Agent creates trackable signature across sites
- Rotating User-Agent mimics different devices/browsers

**Common User-Agent Strings:**

```bash
# Windows 10 + Chrome
Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36

# macOS + Safari
Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.1 Safari/605.1.15

# Linux + Firefox
Mozilla/5.0 (X11; Linux x86_64; rv:120.0) Gecko/20100101 Firefox/120.0

# iPhone + Mobile Safari
Mozilla/5.0 (iPhone; CPU iPhone OS 17_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.1 Mobile/15E148 Safari/604.1
```

**User-Agent Rotation Script (Python + Selenium):**

```python
from selenium import webdriver
from selenium.webdriver.firefox.options import Options
import random

user_agents = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120.0.0.0",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Safari/605.1.15",
    "Mozilla/5.0 (X11; Linux x86_64; rv:120.0) Gecko/20100101 Firefox/120.0"
]

options = Options()
options.set_preference("general.useragent.override", random.choice(user_agents))
driver = webdriver.Firefox(options=options)
```

### Cookie & Session Management

**Cookie Best Practices:**
- Clear cookies after each investigation session
- Use browser containers to isolate persona cookies
- Export/import cookies for long-term persona maintenance
- Never mix personal and research persona cookies

**Cookie Management Tools:**

```bash
# Firefox: Export cookies for persona preservation
# Install "Cookie Quick Manager" extension
# Export cookies for @sarahm_atx → save as sarahm_atx_cookies.json

# Import cookies for next session:
# Cookie Quick Manager → Import → sarahm_atx_cookies.json
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
- ✅ Archiving websites with Archive.org or archive.is
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
- Premium accounts see full viewer details (name, headline, company)

**OPSEC Measures:**

```text
✅ Use burner account with complete, realistic profile
✅ Enable "Private Mode" (Settings → Visibility → Profile viewing options → Private mode)
   - Note: Private mode prevents YOU from seeing who viewed YOUR profile
✅ Build 100+ connections before investigating (established account)
✅ Never view target profile more than once per week
✅ Use LinkedIn's public profile view (append /in/USERNAME to URL, view in incognito)
✅ Alternative: Use search engines (site:linkedin.com "target name" "company")
```

**LinkedIn Private Mode:**

```text
Private Mode ON:
- Target sees: "Someone viewed your profile" (no details)
- You cannot see who viewed your profile

Private Mode OFF:
- Target sees: Your name, headline, company, profile photo
- You can see who viewed your profile
```

### Twitter/X

**Medium-Risk Platform (Limited View Tracking):**

**Attribution Risks:**
- No profile view notifications (safe to browse)
- Rate limiting on API and scraping
- Account suspension for TOS violations (automation, fake accounts)

**OPSEC Measures:**

```text
✅ Use Nitter (privacy frontend) for passive viewing: https://nitter.net/
✅ Burner account not required for viewing public tweets
✅ For archiving, use Nitter RSS feeds or yt-dlp:
   yt-dlp "https://twitter.com/USERNAME" --skip-download --write-info-json
✅ Avoid liking, retweeting, or following targets (creates audit trail)
```

### Instagram

**High-Risk Platform (Story View Tracking):**

**Attribution Risks:**
- Viewing Stories reveals your account name to target
- Viewing profiles does NOT notify target (unlike LinkedIn)
- Instagram aggressively detects fake accounts

**OPSEC Measures:**

```text
✅ Use burner account with realistic profile (profile photo, bio, 10+ posts)
✅ NEVER view Instagram Stories (target sees viewer list)
✅ Use Instagram web viewer (no app installation, harder to track)
✅ Download posts with yt-dlp instead of viewing in Instagram:
   yt-dlp "https://www.instagram.com/p/POST_ID/"
✅ Alternative: Bibliogram (privacy frontend, often rate-limited)
```

### Telegram

**Medium-Risk Platform (Last Seen Tracking):**

**Attribution Risks:**
- "Last seen" timestamp reveals when you're online
- Target can see when you view their profile (if enabled)
- Phone number required for signup (use burner SIM/VoIP)

**OPSEC Measures:**

```text
✅ Disable "Last Seen": Settings → Privacy & Security → Last Seen & Online → Nobody
✅ Disable "Profile Photo": Settings → Privacy & Security → Profile Photo → My Contacts
✅ Use Telegram Desktop (not mobile app with real SIM card)
✅ Phone number via VoIP (Google Voice, MySudo) or burner SIM
✅ Join public channels only (no DMs with targets)
✅ Use Telegram's public preview (no login required):
   https://t.me/s/CHANNEL_NAME
```

### Reddit

**Low-Risk Platform (Anonymous Browsing):**

**Attribution Risks:**
- No profile view notifications
- Account creation easy (email not required)
- Platform tolerates anonymous research

**OPSEC Measures:**

```text
✅ Use Teddit or Libreddit (privacy frontends): https://teddit.net/
✅ No account required for viewing public subreddits/posts
✅ For account creation: burner email, unique password, VPN
✅ Avoid commenting or posting (creates audit trail)
```

### Facebook

**High-Risk Platform (Extensive Tracking):**

**Attribution Risks:**
- Profile view notifications (some contexts)
- Aggressive fake account detection (phone number verification)
- Friend suggestions algorithm links research personas to real identity
- Pixel tracking across websites

**OPSEC Measures:**

```text
✅ Avoid Facebook if possible (highest OPSEC risk)
✅ If required: burner account with aged profile (6+ months old)
✅ Complete profile (school, work, friends, posts) to avoid detection
✅ NEVER friend or message targets
✅ Use Facebook's "View As Public" to see target profile as non-friend
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
# 1. Check IP address (should be VPN exit node)
curl -s https://ifconfig.me

# 2. Check DNS leaks
curl -s https://www.dnsleaktest.com/ | grep "Your IP"

# 3. Check WebRTC leaks (Firefox console):
# about:config → media.peerconnection.enabled → false (verify)

# 4. Browser fingerprint test
# Visit: https://coveryourtracks.eff.org/
# Result: "Strong protection against tracking"

# 5. Tor circuit (if using Tor Browser)
# Click onion icon → "New Tor Circuit for this Site"
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
2. Test new connection with https://ifconfig.me
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
2. Verify leak with multiple tests (browserleaks.com, ipleak.net)
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
- Always scrub metadata from evidence files before sharing
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
- [ ] VPN connected and verified (curl https://ifconfig.me)
- [ ] DNS leak test passed (curl https://www.dnsleaktest.com/)
- [ ] WebRTC disabled (Firefox: media.peerconnection.enabled → false)
- [ ] Browser fingerprint tested (coveryourtracks.eff.org → strong protection)
- [ ] No personal accounts logged in (check browser sessions)

**Identity & Persona:**
- [ ] Research persona selected and documented
- [ ] Persona warming completed (30-day timeline)
- [ ] Password retrieved from KeePassXC
- [ ] Persona cookies imported (if returning to existing session)
- [ ] Timezone aligned with persona location (e.g., PST for Austin persona)
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
- [ ] Metadata scrubbed from evidence (ExifTool -all=)
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
| **Mullvad VPN**              | Network Security  | Anonymous VPN with no-logs policy            | Windows, Linux, macOS |
| **ProtonVPN**                | Network Security  | Secure Core, Tor over VPN                    | Windows, Linux, macOS |
| **Tor Browser**              | Anonymity         | Maximum anonymity, anti-fingerprinting       | Windows, Linux, macOS |
| **Whonix**                   | Anonymity         | Tor-routed VM by design                      | Linux (VM)            |
| **Tails**                    | Anonymity         | Amnesic live OS, leaves no traces            | USB boot              |
| **Exegol**                   | Security Testing  | Pre-configured Docker environment with OSINT tools | Linux (Docker)        |
| **Kasm Workspaces**          | Isolation         | Browser-based containerized desktop streaming | Linux (self-hosted)   |
| **Firefox**                  | Browser           | Privacy-hardened with about:config           | Windows, Linux, macOS |
| **Brave**                    | Browser           | Chromium-based, built-in ad/tracker blocking | Windows, Linux, macOS |
| **uBlock Origin**            | Browser Extension | Ad/tracker blocking                          | Firefox, Chrome       |
| **NoScript**                 | Browser Extension | JavaScript blocking                          | Firefox               |
| **Multi-Account Containers** | Browser Extension | Isolate cookies per persona                  | Firefox               |
| **KeePassXC**                | Password Manager  | Offline, encrypted password storage          | Windows, Linux, macOS |
| **ProtonMail**               | Email             | Encrypted email, no phone required           | Web, mobile           |
| **MySudo**                   | Phone Number      | Virtual phone numbers for verification       | iOS, Android          |
| **ExifTool**                 | Metadata          | Scrub EXIF from images                       | CLI (all platforms)   |
| **VirtualBox**               | Virtualization    | Free VM software                             | Windows, Linux, macOS |
| **VMware Workstation**       | Virtualization    | Commercial VM software (more features)       | Windows, Linux        |

### Resources & References

**OPSEC Frameworks:**
- ODNI OPSEC Guidelines: https://www.dni.gov/index.php/ncsc-how-we-work/ncsc-know-the-risk-raise-your-shield/ncsc-opsec
- NIST SP 800-53 (Operational Security Controls): https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final
- Bellingcat OSINT Ethics Guide: https://www.bellingcat.com/resources/2022/11/23/a-guide-to-ethics-in-open-source-research/

**Privacy Testing:**
- Cover Your Tracks (Browser Fingerprinting): https://coveryourtracks.eff.org/
- DNS Leak Test: https://www.dnsleaktest.com/
- IP Leak Test: https://ipleak.net/
- Browser Leaks: https://browserleaks.com/

**Anonymity Networks:**
- Tor Project: https://www.torproject.org/
- Whonix: https://www.whonix.org/
- Tails OS: https://tails.boum.org/

**Investigation Environments:**
- Exegol: https://exegol.com/
- Kasm Workspaces: https://www.kasmweb.com/

**Persona Management:**
- This Person Does Not Exist (AI-generated faces): https://thispersondoesnotexist.com/
- Fake Name Generator: https://www.fakenamegenerator.com/
- Guerrilla Mail (Temporary Email): https://www.guerrillamail.com/

---

**Version:** 2.0
**Last Updated:** 2025-10-05
**Review Cycle:** Yearly

---

**Related SOPs:**
[[sop-legal-ethics|Legal & Ethics]] | [[sop-collection-log|Collection Log]] | [[sop-entity-dossier|Entity Dossier]] | [[sop-reporting-packaging-disclosure|Reporting & Disclosure]] | [Investigations-Index](../Investigations-Index.md)

