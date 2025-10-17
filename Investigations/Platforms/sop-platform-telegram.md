---
type: sop
title: Telegram SOP
description: "Telegram investigation guide: channel monitoring, group analysis, bot tracking & encrypted messaging patterns for secure communication intelligence."
tags:
  - sop
  - platform
  - telegram
  - messaging
  - osint
created: 2024-03-24
updated: 2025-08-11
---

# Telegram OSINT SOP

## 1) Access & Client Options

- **Web**: https://web.telegram.org (limited functionality, requires phone verification)
- **Desktop apps**: Windows/Mac/Linux clients with full feature access
- **Mobile apps**: iOS/Android with complete functionality
- **API access**: Telegram API for developers (requires API key from https://my.telegram.org)
- **Bot integration**: Custom bots for monitoring and data collection
- **Third-party tools**: Telethon (Python), telegram-cli (command-line interface)

## 2) Discovery & Search Methods

### Channel/Group Discovery
- **Direct links**: telegram.me/username or t.me/username
- **Invite links**: t.me/joinchat/[hash] or t.me/+[hash] format
- **Global search**: `@username`, `#hashtag`, or keyword searches within app
- **Directory sites**: combot.org, tgstat.com, lyzem.com (use with caution - data quality varies)
- **Cross-platform mentions**: Twitter, Reddit, Discord, forums linking to Telegram
- **Bot directories**: @BotFather listings, third-party bot catalogs

### Search Techniques
- **Username enumeration**: Try common variations (underscores, numbers, abbreviations)
- **Channel search**: Use in-app search for public channels by keyword
- **Group discovery**: Join related groups to find linked communities
- **Hashtag tracking**: #keyword across public channels
- **Forward source tracking**: Identify original message sources via forwarding chains

## 3) Search Operators & Methods

- **Exact phrases**: Use quotation marks `"exact phrase"` for precise matching
- **Username search**: `@username` to find specific accounts/channels
- **Hashtag search**: `#keyword` aggregates tagged messages in public channels
- **Message date filtering**: Platform-specific date range (in-app: from: @username)
- **Media type filtering**: Photos, videos, documents, voice messages, GIFs
- **Within-chat search**: Use search bar in specific channel/group for local results
- **Global search**: App-wide search across all accessible chats

## 4) Repeatable Workflow

1. **Target identification**: Username variations, related channels/groups, aliases
2. **Network mapping**: Shared members, admin connections, forwarded content patterns
3. **Content timeline**: Message chronology, posting patterns, activity peaks/troughs
4. **Channel analysis**: Subscriber growth, admin structure, content themes
5. **Media harvesting**: Files, images, videos with metadata preservation
6. **Link analysis**: External URLs, cross-platform references, shortened links
7. **User behavior tracking**: Online status, message frequency, interaction patterns
8. **Forward tracking**: Message propagation across channels/groups
9. **Bot interaction**: Identify automated accounts, command patterns
10. **Documentation**: Export data, calculate hashes, log in collection tracker

## 5) Channel & Group Analysis

### Channel Intelligence
- **Membership size**: Subscriber counts, growth patterns over time
- **Admin structure**: Channel owners, administrators, moderators (if visible)
- **Content patterns**: Posting frequency, message types, engagement levels
- **Cross-posting**: Content shared across multiple channels (forward tracking)
- **Bot usage**: Automated posting, moderation bots, interactive features
- **Language analysis**: Primary languages, geographic/cultural indicators
- **Verification status**: Telegram verified badge (✓) for authentic channels

### Group Intelligence
- **Member count**: Total members, active vs passive participants
- **Permission settings**: Who can post, add members, pin messages
- **Group type**: Public vs private, moderation level
- **Join method**: Invite-only, link-based, or public search
- **Activity patterns**: Peak hours, quiet periods, timezone indicators
- **Member interactions**: Reply patterns, mention networks, reaction usage

## 6) User Profile Intelligence

### Profile Analysis
- **Display name**: Real name, pseudonym, organization
- **Username**: @handle (if set), historical variations
- **Bio**: Self-description, contact info, affiliations
- **Profile photo**: Reverse image search potential, facial recognition
- **Phone number**: Visible to contacts only (privacy setting dependent)
- **Last seen status**: Online indicators (if not hidden by user)
- **Account creation**: Age estimation via join date of old groups

### Behavioral Analysis
- **Message patterns**: Posting frequency, time zones, language style
- **Mutual contacts**: Shared groups, common connections
- **Public channel participation**: Comments, reactions in public channels
- **Forward behavior**: What content they share, from which sources
- **Bot interactions**: Commands used, automated services subscribed to
- **Username changes**: Historical @handle variations (if tracked externally)

## 7) Investigation Recipes

### Threat Monitoring
**Objective**: Monitor extremist/threat actor channels

**Method**:
1. Join relevant public channels (terrorism, extremism, violence)
2. Set up keyword alerts: "attack", "operation", "target", location names
3. Track message forwarding to identify coordination
4. Document all threats immediately (screenshot + export)
5. Cross-reference with other platforms for corroboration
6. Escalate to law enforcement per [[../Techniques/sop-sensitive-crime-intake-escalation|Escalation SOP]]

### Criminal Marketplace Investigation
**Objective**: Document illegal marketplace activity

**Method**:
1. Search for marketplace terms: "shop", "store", "vendor", "escrow"
2. Analyze channel description, pinned messages for offerings
3. Document pricing, payment methods (crypto wallets), products
4. Track admin contacts, customer support bots
5. Map network of related channels (forward tracking)
6. Preserve evidence with hashes, export full channel history

### Geographic Intelligence
**Objective**: Gather local incident reporting and community intel

**Method**:
1. Join local city/region channels (search "City Name Telegram")
2. Search for incident keywords: "explosion", "accident", "police"
3. Cross-reference timestamps with known events
4. Identify eyewitnesses via message patterns
5. Geolocate photos/videos using [[../Techniques/sop-image-video-osint|Image OSINT]]
6. Verify information with multiple local sources

### Cryptocurrency Fraud Tracking
**Objective**: Investigate crypto scam channels and pump-and-dump schemes

**Method**:
1. Join crypto trading groups, investment channels
2. Identify suspicious patterns: guaranteed returns, urgency tactics
3. Extract wallet addresses from messages/images (OCR if needed)
4. Track transactions via [[../Techniques/sop-financial-aml-osint|Financial OSINT]]
5. Document victim reports in channel comments
6. Map scammer network across multiple channels

## 8) Collection & Evidence Integrity

### Export Methods
- **Built-in export**: Settings → Advanced → Export Chat Data (JSON/HTML)
- **Screenshot capture**: Full message threads with context visible
- **Media download**: Original file formats with metadata intact
- **Message forwarding**: To personal "Saved Messages" for archival
- **Bot-based collection**: Custom scripts via Telegram API
- **Manual documentation**: Critical messages transcribed with timestamps

### File Organization
```
/Evidence/{{case_id}}/Telegram/
├── YYYYMMDD-HHMM/
│   ├── channels/
│   │   ├── @channel_name_export.json
│   │   ├── @channel_name_export.html
│   │   └── @channel_name_screenshots/
│   ├── groups/
│   │   └── group_name_YYYYMMDD.json
│   ├── media/
│   │   ├── photos/
│   │   ├── videos/
│   │   └── documents/
│   ├── profiles/
│   │   └── @username_profile.png
│   └── SHA256SUMS
```

### Hashing & Verification
- Calculate SHA-256 for all media files immediately after download
- Store hashes in `SHA256SUMS` file for integrity verification
- Document capture timestamp (UTC), message ID, channel/user source
- Reference in [[../Techniques/sop-collection-log|Collection Log]]
- Maintain complete chain of custody documentation

## 9) Advanced Techniques

### Message Forward Tracking
- Identify original source of forwarded messages
- Map propagation paths across channels/groups
- Analyze forwarding velocity (how quickly content spreads)
- Identify amplification networks (coordinated forwarding)
- Track modifications to forwarded content

### Bot Development for Monitoring
```python
# Example: Telethon keyword monitoring bot
from telethon import TelegramClient, events

api_id = YOUR_API_ID
api_hash = 'YOUR_API_HASH'
client = TelegramClient('session', api_id, api_hash)

@client.on(events.NewMessage(pattern='(?i).*keyword.*'))
async def handler(event):
    # Log message with keyword
    print(f"Match found: {event.message.text}")
    # Save to database or alert system

client.start()
client.run_until_disconnected()
```

### Deleted Content Recovery
- Monitor channels continuously (deleted messages won't be captured retroactively)
- Use bots to auto-save all messages in real-time
- Screenshot frequently updated channels
- Check if content was forwarded to other channels (may still exist)
- Third-party archive services (if available, verify legality)

## 10) Pivoting & Cross-Platform Correlation

### Profile Pivots
- **Bio links** → Personal websites, Instagram, Twitter, other social media
- **Username search** → Same @handle on other platforms (use Nuclei)
- **Phone number** → If visible, reverse lookup, data breach searches
- **Profile photo** → Reverse image search for duplicate accounts
- **Mentioned links** → Websites, payment processors, business connections

### Content Pivots
- **Shared URLs** → Website infrastructure via [[../Techniques/sop-web-dns-whois-osint|Web OSINT]]
- **Cryptocurrency addresses** → Blockchain tracking via [[../Techniques/sop-financial-aml-osint|Financial OSINT]]
- **Media files** → Reverse search, EXIF data, geolocation
- **Document metadata** → Author names, organization info, file paths
- **Mentioned platforms** → Discord, WhatsApp, Signal groups

### Network Pivots
- **Admin connections** → Other channels managed by same admins
- **Shared members** → Users active in multiple related groups
- **Forward chains** → Content flow between channels
- **Bot usage** → Services linking multiple communities
- **Language/timezone** → Geographic clustering of related channels

## 11) Tools & Resources

| Tool                 | Purpose                         | Platform   | Access                                  |
| -------------------- | ------------------------------- | ---------- | --------------------------------------- |
| **Telegram Desktop** | Full-featured client            | Desktop    | https://desktop.telegram.org            |
| **Telethon**         | Python library for automation   | CLI/Python | `pip install telethon`                  |
| **telegram-cli**     | Command-line Telegram client    | CLI        | https://github.com/vysheng/tg           |
| **Nuclei**           | Username enumeration            | CLI        | `nuclei -tags osint -var user=username` |
| **Social-Analyzer**  | Cross-platform username search  | CLI        | `pip install social-analyzer`           |
| **TGStat**           | Channel analytics and discovery | Web        | https://tgstat.com                      |
| **Combot**           | Channel directory and analytics | Web        | https://combot.org                      |
| **Telegram API**     | Official API access             | API        | https://core.telegram.org/api           |
| **IntelX**           | Telegram data leaks search      | Web        | https://intelx.io                       |

### API Usage Example
```python
# Telethon - Download channel history
from telethon.sync import TelegramClient

api_id = YOUR_API_ID
api_hash = 'YOUR_API_HASH'

with TelegramClient('session', api_id, api_hash) as client:
    for message in client.iter_messages('@channel_username', limit=1000):
        print(f"{message.date}: {message.text}")
        if message.media:
            client.download_media(message.media)
```

## 12) Risks & Limitations

- **Content deletion**: Messages/channels can disappear without warning
- **Encryption barriers**: Private messages use end-to-end encryption (not accessible)
- **Account blocking**: Investigation accounts may be banned for unusual activity
- **Platform detection**: Telegram may flag automated/scraping behavior
- **Legal risks**: Jurisdiction-specific laws regarding encrypted communications monitoring
- **Target awareness**: Users may notice new members in smaller groups
- **Privacy settings**: Users can hide last seen, phone number, profile photo
- **Rate limiting**: API requests limited, excessive use triggers restrictions
- **Malware risk**: Files in criminal channels may contain malicious payloads

## 13) Quality Assurance & Verification

### Source Verification
- **Channel authenticity**: Check verification badges, subscriber counts, creation date
- **Information triangulation**: Corroborate claims with external sources
- **Admin verification**: Cross-reference admin accounts across multiple channels
- **Content consistency**: Check for contradictions, timeline inconsistencies
- **Language analysis**: Detect automated/bot-generated content patterns

### Evidence Validation
- **Message metadata**: Verify timestamps (UTC), message IDs, forward sources
- **Media forensics**: Check EXIF data, reverse image search for original sources
- **Link verification**: Analyze URLs for phishing, malware, legitimacy
- **Cross-platform check**: Verify content appears on other platforms (Twitter, Reddit)
- **Expert consultation**: Technical or regional expertise for context validation

## 14) Real-World Scenarios

### Scenario 1: Human Trafficking Network Disruption
**Situation**: Telegram channel recruiting victims for forced labor.

**Approach**:
1. Join channel using investigation persona account
2. Document recruitment messages, payment terms, destination locations
3. Extract admin contact info, payment wallet addresses
4. Track message forwards to identify recruitment network
5. Preserve all evidence with timestamps and hashes
6. Immediately escalate to law enforcement (FBI, Interpol)
7. Continue monitoring for new victims, operational changes

**Outcome**: Evidence provided to FBI led to 8 arrests across 3 countries; 23 victims identified and rescued; channel network of 12 related groups dismantled.

### Scenario 2: Cybercrime Marketplace Investigation
**Situation**: Channel selling stolen credit cards and hacking tools.

**Approach**:
1. Document product listings, pricing, payment methods
2. Extract crypto wallet addresses from payment instructions
3. Track blockchain transactions via [[../Techniques/sop-financial-aml-osint|Financial OSINT]]
4. Identify vendor accounts across multiple marketplace channels
5. Screenshot buyer testimonials, vendor reputation scores
6. Map network of related channels via forward tracking
7. Compile evidence package for law enforcement

**Outcome**: Identified vendor network operating across 5 channels; traced $2.3M in cryptocurrency transactions; provided evidence to Secret Service resulting in international takedown operation.

### Scenario 3: Disinformation Campaign Attribution
**Situation**: Coordinated disinformation spread via Telegram channels before election.

**Approach**:
1. Identify cluster of channels posting identical/similar false narratives
2. Analyze posting timestamps for coordination patterns (simultaneous posts)
3. Track message forwarding to map amplification network
4. Document admin connections across channels
5. Check account creation dates (mass creation within short timeframe)
6. Analyze language patterns for automation/bot indicators
7. Cross-reference with social media activity (Twitter, Facebook)

**Outcome**: Discovered 47 coordinated channels created within 2-week period; traced to single operator network via shared admin accounts; documented 500+ instances of identical false claims; evidence submitted to election security taskforce.

## 15) Emergency Procedures

### Immediate Archival Triggers
- Channel shows signs of deletion (removing content, changing settings)
- Admin announces channel closure or migration
- Law enforcement requests immediate preservation
- Active threat situation (terrorism, violence, child exploitation)
- Evidence of imminent crime (attack planning, victim targeting)

### Rapid Response Protocol
1. **Immediate export**: Use built-in export function (JSON + HTML)
2. **Screenshot everything**: Full channel history, member lists, admin info
3. **Media download**: All photos, videos, documents at original quality
4. **Message forwarding**: Critical content to "Saved Messages" for backup
5. **External archival**: Submit to Archive.org, archive.today if public
6. **Hash calculation**: SHA-256 for all files immediately
7. **Documentation**: Log all preservation actions with timestamps
8. **Escalation notification**: Alert supervisor/client/law enforcement

### Escalation Triggers (see [[../Techniques/sop-sensitive-crime-intake-escalation|Sensitive Crime Escalation SOP]])
- **Immediate threats**: Terrorism, mass violence, specific threats to life
- **Child safety**: CSAM, exploitation, grooming, trafficking
- **Active crimes**: Drug trafficking, weapons sales, contract killings
- **National security**: State-sponsored operations, espionage, critical infrastructure threats
- **Legal requirements**: Court orders, subpoenas, international law enforcement requests

## 16) Related SOPs

- [[../Techniques/sop-legal-ethics|Legal & Ethics SOP]] - Review before every investigation
- [[../Techniques/sop-opsec-plan|OPSEC Planning]] - Protect investigator identity (phone number, account isolation)
- [[../Techniques/sop-collection-log|Collection Log]] - Evidence tracking and chain of custody
- [[../Techniques/sop-image-video-osint|Image & Video OSINT]] - Media analysis from Telegram files
- [[../Techniques/sop-web-dns-whois-osint|Web/DNS/WHOIS OSINT]] - Analyze linked websites, domains
- [[../Techniques/sop-financial-aml-osint|Financial & AML OSINT]] - Cryptocurrency wallet tracking
- [[../Techniques/sop-entity-dossier|Entity Dossier Building]] - Subject/channel profiling
- [[../Techniques/sop-reporting-packaging-disclosure|Reporting & Disclosure]] - Final report preparation
- [[../Techniques/sop-sensitive-crime-intake-escalation|Sensitive Crime Escalation]] - Law enforcement referral

## 17) External Resources

**Official Documentation:**
- Telegram API Documentation: https://core.telegram.org/api
- Bot API Guide: https://core.telegram.org/bots/api
- Telegram Privacy Policy: https://telegram.org/privacy

**Third-Party Tools:**
- Telethon Documentation: https://docs.telethon.dev
- telegram-cli GitHub: https://github.com/vysheng/tg (odd)
- Nuclei Templates: https://github.com/projectdiscovery/nuclei-templates
- Social-Analyzer: https://github.com/qeeqbox/social-analyzer

**Training & Guides:**
- Bellingcat Telegram OSINT Guide: https://www.bellingcat.com/resources/how-tos/
- OSINT Framework Telegram Section: https://osintframework.com/
- DFRLab Telegram Investigation Guide: https://www.atlanticcouncil.org/programs/digital-forensic-research-lab/

---

**Last Updated:** 2025-08-11
**Version:** 2.0 (Expanded & Standardized)
**Review Frequency:** Yearly
