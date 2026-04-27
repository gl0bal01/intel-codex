---
type: sop
title: Discord SOP
description: "Discord investigation guide: server enumeration, snowflake timestamp extraction, bot/webhook discovery, lurking discipline, and ToS-aware evidence collection for OSINT analysts."
tags:
  - sop
  - platform
  - discord
  - messaging
  - osint
created: 2026-04-27
updated: 2026-04-27
template_version: 1.0
---

# Discord OSINT SOP

> **Authorized OSINT use only.** Investigation accounts must comply with Discord's [Terms of Service](https://discord.com/terms) and the platform's prohibitions on bulk scraping, automated account creation, self-bots, and coordinated inauthentic behavior. Review [[../Techniques/sop-legal-ethics|Legal & Ethics SOP]] and [[../Techniques/sop-opsec-plan|OPSEC Planning]] before any engagement. CSAM, threat-to-life DMs, or trafficking content trigger an immediate hard stop and routing per [[../Techniques/sop-sensitive-crime-intake-escalation|Sensitive Crime Escalation SOP]].

## Table of Contents

1. [Access & Client Options](#1-access--client-options)
2. [Discovery & Search Methods](#2-discovery--search-methods)
3. [Search Operators & Methods](#3-search-operators--methods)
4. [Repeatable Workflow](#4-repeatable-workflow)
5. [Server & Channel Analysis](#5-server--channel-analysis)
6. [User Profile Intelligence](#6-user-profile-intelligence)
7. [Investigation Recipes](#7-investigation-recipes)
8. [Collection & Evidence Integrity](#8-collection--evidence-integrity)
9. [Advanced Techniques](#9-advanced-techniques)
10. [Pivoting & Cross-Platform Correlation](#10-pivoting--cross-platform-correlation)
11. [Tools & Resources](#11-tools--resources)
12. [Risks & Limitations](#12-risks--limitations)
13. [Quality Assurance & Verification](#13-quality-assurance--verification)
14. [Real-World Scenarios](#14-real-world-scenarios)
15. [Emergency Procedures](#15-emergency-procedures)
16. [Legal & Ethical Considerations](#16-legal--ethical-considerations)
17. [Related SOPs](#17-related-sops)
18. [External Resources](#18-external-resources)

## 1) Access & Client Options

- **Web**: https://discord.com/app (full feature parity with desktop, runs in browser)
- **Desktop apps**: Windows / macOS / Linux clients with full feature access
- **Mobile apps**: iOS / Android with most features (some admin actions desktop-only)
- **Official API**: Discord HTTP + Gateway APIs documented at https://discord.com/developers/docs (bot accounts only; user-token automation is a ToS violation called "self-botting")
- **Bot integration**: discord.py (Python), discord.js (Node), serenity (Rust), JDA (Java) — bot must be invited to a server by an admin via OAuth2 URL
- **Authorized export tooling**: DiscordChatExporter (CLI/GUI) — see §8 for ToS framing
- **Third-party clients**: BetterDiscord, Powercord/Replugged, and similar client mods are ToS violations and risk account termination — do not use on investigation accounts

## 2) Discovery & Search Methods

### Server Discovery
- **Direct invites**: `discord.gg/<code>` and `discord.com/invite/<code>` resolve to a server preview (server name, icon, approximate member count, approximate online count) without joining
- **Vanity URLs**: `discord.gg/<vanity>` — vanity codes require Boost Level 3 to claim [verify 2026-04-27 — Discord has rotated boost-tier reward thresholds; current boost count for Level 3 may differ]; presence of a vanity is a weak signal of established/funded server
- **Server listing sites**: Disboard (https://disboard.org), Disforge (https://disforge.com), Top.gg server directory (https://top.gg/servers), Discords.com (https://discords.com), DiscordHome (https://discordhome.com) — quality varies; treat as discovery surface, not authoritative inventory
- **Bot listing sites**: Top.gg bot directory, Discord Bot List (https://discordbotlist.com) — useful for identifying bots seen in target server
- **Cross-platform mentions**: Twitter/X bios, Reddit posts, Telegram channels, GitHub READMEs, YouTube descriptions frequently link to Discord invites
- **Invite-graph pivots**: a single user posting an invite across 5 unrelated platforms is a coordination signal — capture all source posts before the invite is rotated or revoked

### Invite Resolution Without Joining
- The unauthenticated endpoint `https://discord.com/api/v10/invites/<code>?with_counts=true&with_expiration=true` returns server name, ID, icon hash, splash hash, approximate_member_count, approximate_presence_count, expiration timestamp, inviter (if set), and the target channel — without joining and without an authenticated session [verify 2026-04-27 — endpoint version may have rotated]
- Useful for documenting a server's existence and rough size before deciding whether to join with a sock-puppet account
- Rate-limited per IP; do not script bulk resolution against this endpoint

### Search Techniques
- **Username enumeration**: try common variations (underscores, numbers, leetspeak) — note Discord moved from `username#discriminator` (legacy) to globally unique handles in 2023; both forms may surface in old screenshots/logs
- **Server name search**: server-listing sites support keyword search and tag filters (gaming, crypto, NFT, anime, etc.)
- **Channel structure inference**: common naming patterns (`#announcements`, `#rules`, `#general`, `#trades`, `#vendors`, `#leaks`) correlate with server purpose
- **Bot fingerprinting**: presence of MEE6, Dyno, Carl-bot, Tatsu indicates moderation maturity; Tip.cc, Collab.Land, Vulcan indicate crypto/Web3 focus

## 3) Search Operators & Methods

Discord's in-app search supports a limited operator set scoped to the current server (DMs and group DMs have their own search). Key operators (verify current set against client UI — Discord rotates these):

- `from:@user` — messages authored by a specific user
- `mentions:@user` — messages mentioning a specific user
- `has:link` / `has:embed` / `has:file` / `has:video` / `has:image` / `has:sound` — content type filter
- `before:YYYY-MM-DD` / `during:YYYY-MM-DD` / `after:YYYY-MM-DD` — date range filter
- `in:#channel` — restrict to a specific channel
- `pinned:true` — pinned messages only
- Operators stack: `from:@vendor has:link in:#trades after:2024-01-01`
- **Quote** exact phrases with double quotes: `"contract address"`
- **Limitation**: search results are capped (UI shows up to ~25 per page, with paginated continuation); for completeness, use authorized export

## 4) Repeatable Workflow

1. **Target identification**: server invite code, vanity URL, user IDs, bot IDs, suspected aliases
2. **Pre-join intel**: resolve invite metadata (member counts, server ID, channel ID); decide whether joining is in scope
3. **Sock-puppet selection**: choose investigation account appropriate for server profile (gaming, crypto, hobby) — see [[../Techniques/sop-opsec-plan|OPSEC Planning]]
4. **Server enumeration**: capture full channel list, role list, emoji set, server boost level, server creation date (from server snowflake ID)
5. **Member-list discipline**: large servers (10k+ members) only render online members in the sidebar by default; full member list requires scrolling, bot enumeration via authorized API, or [verify 2026-04-27 — Member List Update gateway opcode behavior]
6. **Lurking phase**: passive observation, role-assignment to limit detectability (avoid roles that grant moderator visibility), no posting
7. **Content harvest**: targeted message capture (screenshots + authorized export); preserve full chain (server → channel → message ID)
8. **User-ID resolution**: extract snowflake IDs (Developer Mode → right-click → Copy ID) for every entity of interest
9. **Cross-server pivots**: shared bots, shared moderators, shared invite-poster accounts → enumerate adjacent servers
10. **Documentation**: timestamps in UTC, SHA-256 hashes for media, log entries in [[../Techniques/sop-collection-log|Collection Log]]

## 5) Server & Channel Analysis

### Server Intelligence
- **Server ID**: snowflake ID — extractable via Developer Mode → right-click server icon → Copy Server ID
- **Server creation date**: derived from server snowflake (see §6 snowflake structure); useful for distinguishing established communities from rapidly stood-up scam infrastructure
- **Boost Level (0–3)**: indicates community investment; vanity URL and animated icon require Level 3
- **Verification Level**: Discord's anti-spam tier (None / Low / Medium / High / Highest) — visible to members, affects who can post
- **Explicit Content Filter**: server-wide image scanning setting
- **Server description / About**: discoverable via server-listing sites and the Discovery feature for Community-enabled servers
- **Welcome Screen / Onboarding**: Community-feature servers expose channel hints and rule summaries to new members — capture before joining if possible

### Channel Intelligence
- **Channel types**: Text, Voice, Announcement, Stage, Forum, Media, Thread (parent-child), Category (organizational only)
- **Channel ID**: snowflake — Developer Mode → right-click channel → Copy Channel ID
- **Channel creation date**: derived from snowflake; channels created during a single short window suggest scripted server setup (template, bot, or copied server)
- **Permission overwrites**: each channel can override server-wide role permissions (visible to members with View Channel)
- **Slowmode / NSFW flag / Age-restricted**: channel metadata visible in channel settings preview
- **Pinned messages**: often contain rules, vendor menus, contract addresses, or admin contact info — capture early
- **Forum channels** (post-2022): each post is a thread with tags; search behaves differently from text channels

### Role & Permission Mapping
- **Role list**: Server Settings → Roles (visible to all members in most servers); roles often encode hierarchy (`@Owner`, `@Admin`, `@Mod`, `@Vendor`, `@Verified`, `@Booster`)
- **Permission audit**: roles with `Administrator`, `Manage Server`, `Manage Channels`, `Ban Members`, `Kick Members`, `Manage Roles`, `Manage Webhooks` are operationally significant
- **Hoisted roles**: `Display role members separately` — visible in member sidebar, useful for quick admin enumeration
- **Role color**: cosmetic but consistent within a server hierarchy

### Audit Log Limits
- **Audit Log access**: requires `View Audit Log` permission (typically admin/mod only); the analyst account in a lurker role will not see audit logs
- **Retention**: Discord retains audit logs for a limited window (commonly cited as 45–90 days depending on source) [verify 2026-04-27 — confirm current retention against Discord's published documentation before relying on a specific number in a report]
- **Coverage**: audit log captures structural changes (channel create/delete, role create/delete, ban, kick, member role change, webhook create) — does **not** capture message content

## 6) User Profile Intelligence

### Profile Analysis
- **Global Name** (display name): user-chosen, server-overridable, may not match handle
- **Username** (handle): globally unique, lowercase, post-2023 migration replaces the legacy `username#discriminator` form
- **Discriminator (legacy)**: `#1234` four-digit suffix — phased out in 2023 but still appears in archived screenshots / logs / older bots
- **Server Nickname**: per-server alias, set by the user or by mods; differs from global name
- **Bio / About Me**: free-text profile field, supports limited markdown and links
- **Pronouns**: profile field added 2023
- **Profile picture (avatar)**: server-overridable; reverse-image search candidate, often reused across platforms
- **Banner**: Nitro-only profile field
- **Connections**: linked accounts (Twitch, YouTube, Steam, Spotify, GitHub, Twitter/X, Reddit, eBay, PlayStation, Xbox, etc.) — visible per the user's privacy settings; high-value pivot when present
- **Mutual servers / Mutual friends**: visible to anyone who shares at least one server with the target (privacy setting)
- **Activity / Status**: "Playing", "Listening to Spotify", "Streaming on Twitch" — leaks platform usage and timezone
- **Custom Status**: free-text status, often contains contact info (Telegram handle, email, Tox ID)

### Discord Snowflake Structure (timestamp extraction)

Discord IDs (user, server, channel, message, role, webhook, etc.) are **snowflake IDs**: 64-bit integers whose top bits encode a millisecond-precision creation timestamp. Contrast with Telegram, where user IDs are monotonically-increasing integers without an embedded timestamp (see [[sop-platform-telegram|Telegram SOP §6]]).

**Extraction formula:**

```
unix_ms = (snowflake_id >> 22) + 1420070400000
```

Where `1420070400000` is Discord's epoch (2015-01-01T00:00:00.000Z) in milliseconds since the Unix epoch. The result is a millisecond Unix timestamp; divide by 1000 for seconds.

**Python example:**

```python
import datetime

DISCORD_EPOCH_MS = 1_420_070_400_000

def snowflake_to_datetime(snowflake: int) -> datetime.datetime:
    """Convert a Discord snowflake ID to its UTC creation timestamp."""
    unix_ms = (snowflake >> 22) + DISCORD_EPOCH_MS
    return datetime.datetime.fromtimestamp(unix_ms / 1000, tz=datetime.timezone.utc)

# Example: a user ID
user_id = 175928847299117063  # any valid snowflake
print(snowflake_to_datetime(user_id))  # -> 2016-04-30 11:18:25.796000+00:00
```

**One-liner (any shell with python3):**

```bash
python3 -c 'import sys, datetime; s=int(sys.argv[1]); print(datetime.datetime.fromtimestamp(((s>>22)+1420070400000)/1000, tz=datetime.timezone.utc))' 175928847299117063
```

**Operational uses:**
- **Account creation date** from a user's snowflake → flags freshly-created accounts in a coordinated server
- **Server creation date** from a server's snowflake → distinguishes established communities from rapid scam stand-up
- **Channel creation date** from a channel's snowflake → channels all created within a short window suggest scripted setup (server template / bot / copy)
- **Message creation date** from a message's snowflake → independent of any client-displayed timestamp; useful when a screenshot's timestamp is suspect
- **Webhook creation date** → see §9 webhook discovery

The 22-bit shift discards: 5 bits internal worker ID, 5 bits process ID, 12 bits sequence counter — none of which are operationally useful for OSINT.

### Behavioral Analysis
- **Posting cadence**: tracked across captured messages; identifies timezone clusters
- **Cross-server presence**: mutual-servers UI shows shared servers (subject to privacy setting); valuable for identifying community overlap
- **Reaction patterns**: who reacts to what — note that reactions are visible and tracked
- **Voice activity**: who joins which voice channels and when (visible in voice channel member list while joined)
- **Bot interactions**: which slash commands a target invokes, which bots they have authorized via OAuth
- **Username changes**: Discord does **not** publish username history; bots like Vulcan and some moderation bots track and expose history within their own server (verify per server)

## 7) Investigation Recipes

### Ransomware Affiliate Coordination
**Objective**: Document affiliate / partner coordination on Discord servers operated by or adjacent to a ransomware group.

**Method**:
1. Identify the server via leak-site links, dark-web mirror references, or actor-profile pivots from [[../Techniques/sop-darkweb-investigation|Darkweb Investigation]]
2. Resolve invite metadata (server ID, member count) before joining
3. Join with a sock-puppet account meeting any vetting requirements; do not engage
4. Capture server structure: channel list, role list, pinned messages, rules, vendor verification process
5. Document affiliate-recruitment messages, payment terms, victim-targeting criteria, share of proceeds
6. Extract crypto wallet addresses from payment instructions; route to [[../Techniques/sop-blockchain-investigation|Blockchain Investigation]] and [[../Techniques/sop-financial-aml-osint|Financial AML OSINT]]
7. Map admin / partner accounts; pivot to other servers via mutual-servers and shared-bot heuristics
8. Preserve evidence with timestamps, snowflake IDs, and SHA-256 hashes per [[../Techniques/sop-collection-log|Collection Log]]
9. Escalate per engagement RoE — if active threat-to-life or imminent victim impact, route per [[../Techniques/sop-sensitive-crime-intake-escalation|Sensitive Crime Escalation SOP]]

### No-KYC Crypto Swap / OTC Server
**Objective**: Document no-KYC swap or OTC server acting as a money-laundering layer.

**Method**:
1. Locate via server-listing sites (search: "OTC", "swap", "instant exchange") and Telegram cross-references
2. Document fee structure, supported chains, minimum/maximum amounts, payment workflow
3. Capture deposit-address rotation patterns and bot interaction transcripts
4. Pivot identified deposit addresses to [[../Techniques/sop-blockchain-investigation|Blockchain Investigation]] and [[../Techniques/sop-mixer-tracing|Mixer & Privacy-Pool Tracing]] via the Financial OSINT path
5. Capture admin / operator handles for cross-platform correlation (Telegram, X, dark-web forums)

### Scam Community (Pump-and-Dump / Rug-Pull / Pig-Butchering / Fake Airdrop)
**Objective**: Document a coordinated scam community and its victim funnel.

**Method**:
1. Identify entry-point invites posted on Twitter/X, TikTok, Telegram, or via paid Disboard bumps
2. Capture the funnel: landing channel → "verification" bot → role assignment → "alpha" channel
3. Document the contract address(es), trade-call timing, and admin/influencer rotation
4. Extract victim-report messages, complaint patterns, "where's my money" channels
5. Cross-reference contract addresses with token-launch tooling (pump.fun, Solana SPL launchers) and DEX trade history
6. Preserve admin-DM screenshots only when consensual or under explicit authorization (sock-puppet engaging in active conversation crosses into pretexting — see §16)

### Credential-Stealer Logs Market
**Objective**: Document Discord-based markets selling stealer logs (RedLine, Raccoon, LummaC2, StealC, etc.) without acquiring or analyzing the logs themselves.

**Method**:
1. Identify markets via dark-web forum cross-posts, Telegram channel links, and Discord-listing-site search
2. Document seller pricing, log-volume claims, geo/category filters offered, sample-set policy
3. Capture seller handles, admin handles, payment wallets, bot-mediated checkout flow
4. **Do not download logs.** Stealer logs contain real-victim PII and credentials; possession may violate computer-misuse statutes and engagement RoE. Route stealer-malware analysis to [[../../Security/Analysis/sop-malware-analysis|Malware Analysis SOP]]
5. If logs include child-victim data or imminent-threat indicators, hard-stop and escalate per [[../Techniques/sop-sensitive-crime-intake-escalation|Sensitive Crime Escalation SOP]]

### Geographic / Community Intelligence
**Objective**: Local-incident reporting and community intel via city/region servers.

**Method**:
1. Locate local servers via Disboard tag filter (city / region / language)
2. Search incident keywords: protest, blackout, shooting, evacuation, scam (in local language)
3. Cross-reference timestamps with corroborating sources (local news, X, Reddit)
4. Geolocate posted media via [[../Techniques/sop-image-video-osint|Image & Video OSINT]]
5. Verify with multiple sources before attribution

## 8) Collection & Evidence Integrity

### Authorized Export
- **Discord's first-party data export** (Settings → Privacy & Safety → Request All My Data) returns ZIP of analyst's own messages / servers / connections — useful for investigator-account record-keeping, not third-party-server collection
- **DiscordChatExporter** (https://github.com/Tyrrrz/DiscordChatExporter): CLI/GUI exports a channel to HTML / JSON / plaintext / CSV. **ToS framing:**
  - **Self-owned data**: clearly permitted (analyst's own DMs, analyst-owned servers)
  - **Authorized customer-server engagement**: permitted under the server-owner's authority and within engagement scope
  - **Third-party server (analyst joined as lurker)**: ToS gray area — Discord ToS prohibits scraping and data-mining; route the question to [[../Techniques/sop-legal-ethics|Legal & Ethics SOP]] before automating, document the legal basis in [[../Techniques/sop-collection-log|Collection Log]]
  - DiscordChatExporter operates against a user token by default (which is itself self-bot territory) or a bot token (requires bot to be present in the server, which requires admin-side OAuth). Use the bot path when the engagement permits it.
- **Authorized bot collection**: discord.py / discord.js bots invited via OAuth2 with `Read Message History` and the necessary intents (Server Members Intent, Message Content Intent — both privileged, require Discord-side verification once the bot crosses the verification threshold) [verify 2026-04-27 — exact server-count threshold for required privileged-intent verification]. Cleaner audit trail than user-token tooling.

### Manual Capture
- **Screenshot capture**: include channel name, server name, timestamp visible (or hover-revealed full timestamp); capture both compact and cozy modes when message structure matters
- **Message ID copy**: Developer Mode → right-click message → Copy Message ID (snowflake captures exact creation time independent of client display)
- **Message link copy**: right-click → Copy Message Link → returns `https://discord.com/channels/<server_id>/<channel_id>/<message_id>` — the canonical reference form, even though it requires server membership to resolve

### File Organization

```
/Evidence/{{case_id}}/Discord/
├── YYYYMMDD-HHMM/
│   ├── servers/
│   │   ├── <server_id>_metadata.json     # name, ID, owner, created_at, channel list, role list
│   │   ├── <server_id>_channels/
│   │   │   ├── <channel_id>_<channel_name>.html   # DiscordChatExporter HTML
│   │   │   └── <channel_id>_<channel_name>.json   # DiscordChatExporter JSON
│   │   └── <server_id>_screenshots/
│   ├── users/
│   │   └── <user_id>_<handle>_profile.png
│   ├── bots/
│   │   └── <bot_id>_<handle>_oauth_scopes.txt
│   ├── webhooks/
│   │   └── <webhook_id>_metadata.json
│   ├── media/
│   │   ├── images/
│   │   ├── videos/
│   │   └── attachments/
│   └── SHA256SUMS
```

### Hashing & Verification
- SHA-256 every exported file and downloaded attachment immediately after capture
- Store hashes in `SHA256SUMS` (one per capture batch)
- Record snowflake IDs alongside human-readable names in the metadata file (names change; IDs are immutable)
- Reference all captures in [[../Techniques/sop-collection-log|Collection Log]] with capture timestamp (UTC), snowflake ID, server / channel / message reference, and analyst account used

## 9) Advanced Techniques

### Webhook Discovery & Triage

Discord webhooks have the URL form:

```
https://discord.com/api/webhooks/<webhook_id>/<webhook_token>
```

- The `<webhook_id>` is a snowflake; the `<webhook_token>` is a long opaque secret — anyone holding the URL can post to the channel until the webhook is rotated/deleted
- Webhooks frequently leak in:
  - Public GitHub commits (CI configs, `.env` files, JS bundles)
  - Public S3 / GCS buckets (config drift)
  - Mobile app reversed binaries
  - JavaScript files served from compromised sites
- **Do not POST to a third-party webhook URL** — this is unauthorized access to a target system, regardless of how publicly the URL was exposed. Capture the URL, GET its metadata via `GET https://discord.com/api/webhooks/<id>/<token>` only when authorized in scope (this is read-only and returns webhook name, channel ID, server ID, avatar) [verify 2026-04-27]
- Webhook leaks discovered during bug-bounty engagements: route disclosure through [[../../Security/Pentesting/sop-bug-bounty|Bug Bounty Methodology SOP]] and report to the program; do not validate by posting

### Bot Scope & Slash-Command Surface Review
- Bots in a server expose their slash commands via the `/` autocomplete UI; capture the full command list as part of server enumeration
- Bot OAuth scopes can be inspected via the Authorized Apps page (Settings → Authorized Apps) for the analyst's account; for a target's bot, scopes can be inferred from the bot's invite URL: `client_id=<bot_id>&scope=bot+applications.commands&permissions=<permission_int>`
- Decode the `permissions` integer (Discord publishes the bit table at https://discord.com/developers/docs/topics/permissions) to enumerate exactly what the bot can do — `Administrator` (bit 3) or `Manage Server` (bit 5) on a third-party bot is a strong supply-chain signal
- High-risk permission combinations on a community bot:
  - `Manage Webhooks` + `Manage Server` → bot can pivot to webhook-based exfiltration
  - `Manage Roles` + position above `@everyone` → bot can self-elevate trusted users
  - `Read Message History` + `Send Messages` + privileged `Message Content Intent` → bot can mass-DM, scrape, or relay content out of band

### Cross-Server Moderator / Bot Overlap
- Mutual-server enumeration on a confirmed admin account often reveals the operator's other servers
- Shared custom bots (especially uncommon or self-hosted) across multiple servers indicate operational overlap
- Reaction-emoji custom emoji are server-bound; a custom emoji from server A appearing as a reaction in server B reveals that the reactor has Nitro and is a member of server A

### Voice & Stage Channel Surveillance Discipline
- **Joining a voice channel announces presence** to every member with View Channel permission on that voice channel — there is no silent observe mode
- **Stage Channels** (audience-style): joining as audience does not announce as prominently as voice-channel join, but the audience list is visible to speakers and moderators
- For evidence collection from voice content, prefer authorized recording with explicit operator consent or law-enforcement legal process; surreptitious recording violates wiretap statutes in many jurisdictions — consult [[../Techniques/sop-legal-ethics|Legal & Ethics SOP]]

### Deleted Content
- Discord does not retroactively expose deleted messages
- Continuous capture (authorized bot logging every message, or active analyst with notification cache) is the only OSINT path
- Some moderation bots (Vulcan, Dyno, Carl-bot) keep a deletion log within their own server scope — visible only to staff with the relevant permission

## 10) Pivoting & Cross-Platform Correlation

### Profile Pivots
- **Bio / About Me links** → personal sites, X, Telegram, GitHub, Linktree
- **Connections panel** → linked Twitch / YouTube / Steam / GitHub / Spotify / X / Reddit / PlayStation / Xbox / eBay accounts (visibility per user privacy)
- **Username** → cross-platform handle search via Sherlock, Maigret, WhatsMyName ([[../Techniques/sop-entity-dossier|Entity Dossier]] consolidation)
- **Avatar** → reverse-image search (Google Lens, Yandex, TinEye); avatars are reused across platforms more than display names
- **Custom Status** → free-text often contains Telegram `@handle`, Tox ID, Session ID, or email
- **Snowflake ID** → account creation date narrows the alias-overlap search

### Content Pivots
- **Shared URLs** → website infrastructure via [[../Techniques/sop-web-dns-whois-osint|Web/DNS/WHOIS OSINT]]
- **Cryptocurrency addresses** in messages → [[../Techniques/sop-blockchain-investigation|Blockchain Investigation]] / [[../Techniques/sop-financial-aml-osint|Financial AML OSINT]]
- **Smart-contract addresses** in trade-call channels → contract source review via block explorer; route audit-style review to existing audit SOPs
- **Leaked API keys / cloud credentials** posted in chat (AWS / GCP / Azure keys, Discord bot tokens, OpenAI keys, GitHub PATs are common in screenshots) → [[../../Security/Pentesting/sop-cloud-pentest|Cloud Pentesting SOP]] for authorized validation, or report to the affected vendor
- **Media files** → reverse search, EXIF stripping behavior (Discord generally strips most EXIF from images on upload, but documents / archives / video containers retain their metadata) [verify 2026-04-27 — confirm current upload-pipeline behavior; Discord has changed this several times] — [[../Techniques/sop-image-video-osint|Image & Video OSINT]]
- **Document metadata** → author, organization, file path artifacts in PDFs / Office docs

### Network Pivots
- **Mutual servers** between two accounts → community overlap
- **Shared admin set** across multiple servers → operator network
- **Shared bots** (especially self-hosted or unlisted) → infrastructure overlap
- **Invite-poster account** posting the same invite across X, Reddit, Telegram, TikTok → coordinated promotion
- **Reaction overlap**: same set of reactor accounts on different servers' announcement posts → astroturf signal
- **Comparative messaging-platform pivot** — Telegram channel linked from Discord server (or vice versa) is a common pattern; cross-reference [[sop-platform-telegram|Telegram SOP]] for the comparative channel/group methodology

## 11) Tools & Resources

| Tool                       | Purpose                                                            | Platform     | Access                                                          |
| -------------------------- | ------------------------------------------------------------------ | ------------ | --------------------------------------------------------------- |
| **Discord Desktop**        | Primary investigation client (enable Developer Mode in Settings)   | Desktop      | https://discord.com/download                                    |
| **DiscordChatExporter**    | Authorized channel/DM export (HTML/JSON/CSV/plaintext)             | CLI / GUI    | https://github.com/Tyrrrz/DiscordChatExporter                   |
| **discord.py**             | Python bot library for authorized monitoring                       | Python       | `pip install discord.py`                                        |
| **discord.js**             | Node.js bot library for authorized monitoring                      | Node         | `npm install discord.js`                                        |
| **Disboard**               | Server discovery & tag-filter search                               | Web          | https://disboard.org                                            |
| **Disforge**               | Server discovery directory                                         | Web          | https://disforge.com                                            |
| **Top.gg**                 | Server + bot directory                                             | Web          | https://top.gg                                                  |
| **Discords.com**           | Server directory (formerly discord.me)                             | Web          | https://discords.com                                            |
| **Snowflake decoder**      | Convert snowflake → UTC creation timestamp                         | Web / CLI    | `python3 -c '...'` (see §6) or https://snowsta.mp [verify 2026-04-27 — third-party site availability] |
| **Sherlock / Maigret**     | Cross-platform username enumeration                                | CLI / Python | `pip install maigret` / Sherlock GitHub                         |
| **WhatsMyName**            | Username presence across hundreds of sites                         | Web / CLI    | https://whatsmyname.app                                         |
| **Nuclei (osint tags)**    | Templated username enumeration                                     | CLI          | `nuclei -tags osint -var user=<handle>`                         |
| **Discord API docs**       | Official endpoint and gateway reference                            | Docs         | https://discord.com/developers/docs                             |
| **IntelX**                 | Discord token / webhook leak search                                | Web          | https://intelx.io                                               |
| **GrepApp / GitHub search**| Code-search for leaked Discord webhooks / tokens                   | Web          | https://grep.app, https://github.com/search                     |

### API Usage Example (authorized bot)

```python
# discord.py - capture authorized channel history (analyst-side bot, invited via OAuth)
import os
import discord

intents = discord.Intents.default()
intents.message_content = True  # privileged intent; enable in Developer Portal

client = discord.Client(intents=intents)

@client.event
async def on_ready():
    target_channel_id = int(os.environ["DISCORD_CHANNEL_ID"])
    channel = client.get_channel(target_channel_id)
    async for msg in channel.history(limit=None, oldest_first=True):
        print(f"{msg.created_at.isoformat()} | {msg.id} | {msg.author} | {msg.content}")
        for att in msg.attachments:
            print(f"  attachment: {att.url} ({att.size} bytes)")
    await client.close()

client.run(os.environ["DISCORD_BOT_TOKEN"])
```

### Snowflake Decode One-Liner

```bash
# Decode a snowflake to UTC datetime
python3 -c 'import sys, datetime; s=int(sys.argv[1]); print(datetime.datetime.fromtimestamp(((s>>22)+1420070400000)/1000, tz=datetime.timezone.utc))' 175928847299117063
```

## 12) Risks & Limitations

- **ToS prohibition on scraping & self-bots**: user-token automation, mass DMs, automated account creation, and scraping are explicitly prohibited; investigation accounts that violate ToS risk ban and evidence inadmissibility
- **Coordinated inauthentic behavior detection**: Discord aggressively bans linked sock-puppet accounts (shared payment, shared IP, shared device fingerprint, similar registration cadence)
- **Voice-channel join announces presence** to all members with View Channel — there is no silent observation mode
- **DM acceptance signal**: opening a DM may notify the recipient depending on their privacy settings (server-shared default, friends-only, off); consider this before initiating
- **Reaction-emoji visibility**: reactions are public to the channel and persistent until removed — a reaction is evidentially equivalent to a post
- **Friend request signal**: sending a friend request notifies the target
- **Profile / Connections privacy**: targets can hide mutual servers, mutual friends, connections, and "Now Playing" — absence of data is not absence of activity
- **Phone / email obscured**: Discord does not surface email or phone to other users; data-broker correlation requires legal process or breach data
- **Account verification phone requirement**: high-risk-flagged servers may require verified phone on the joining account; investigation phones must be isolated from analyst identity per [[../Techniques/sop-opsec-plan|OPSEC Planning]]
- **Rate limiting**: REST endpoints rate-limit per route per token; Gateway has connection identify limits — bulk enumeration scripts will be throttled or terminated
- **Content deletion**: messages, channels, servers, and accounts can disappear without warning; capture early
- **Server template / mass-deployment churn**: many scam servers are stood up from a template, banned, and re-deployed within hours — sustained tracking requires automation under engagement scope
- **Malware risk**: attachments in criminal servers may contain malicious payloads; never open on the analyst host — route to [[../../Security/Analysis/sop-malware-analysis|Malware Analysis SOP]] sandbox

## 13) Quality Assurance & Verification

### Source Verification
- **Snowflake-derived timestamps** are authoritative for creation time of the entity (server, channel, message, user) — use them to validate any user-displayed timestamp
- **Server authenticity**: Community-feature servers expose verified status for partners; "verification" claimed in a server's About text is not the same as Discord's verification — confirm via the badge on the server icon
- **Bot identity**: a bot's `client_id` (snowflake) is fixed; impostor bots use similar names but new IDs — capture and compare
- **Cross-source corroboration**: cross-reference claims with Telegram channels, X profiles, dark-web forum posts, and on-chain activity before attribution

### Evidence Validation
- **Snowflake IDs** alongside every captured artifact (server, channel, message, user)
- **Both human-readable name and ID** in collection log — names mutate, IDs do not
- **Capture context**: include channel name, server name, server ID in every screenshot (or in the filename)
- **Hash chain**: SHA-256 immediately after capture; entries in [[../Techniques/sop-collection-log|Collection Log]]
- **Sock-puppet account documentation**: which investigation account observed each artifact, with the account's own snowflake recorded once per case

## 14) Real-World Scenarios

### Scenario 1: Stealer-Logs Market Disruption Support
**Situation**: Analyst-tracked Discord server selling RedLine and LummaC2 stealer logs at $5–$50 per log, organized by geo and credential type.

**Approach**:
1. Confirm jurisdiction and engagement RoE before joining; route through legal review
2. Resolve invite metadata and document server ID, member counts, channel structure pre-join
3. Join with a sock-puppet account that fits the community's vetting (often only requires reading rules + reacting to a verification emoji)
4. Document seller pricing, stock claims, sample-policy, supported payment methods, OPSEC instructions to buyers, refund policy
5. Capture seller and admin handles + snowflake IDs; pivot via mutual servers to identify the operator's network
6. Extract crypto wallet addresses; route to [[../Techniques/sop-blockchain-investigation|Blockchain Investigation]]
7. **Do not download any logs.** Stealer logs contain real-victim PII; possession may itself violate computer-misuse statutes
8. Compile evidence package (screenshots, exports, hashes, snowflake IDs, wallet pivots) per [[../Techniques/sop-reporting-packaging-disclosure|Reporting & Disclosure SOP]]
9. Hand off to law enforcement or the affected vendor security team

**Outcome shape**: Evidence package supports takedown coordination and victim-notification efforts; sustained tracking requires authorized bot collection, not user-token automation.

### Scenario 2: Pump-and-Dump / Scam Token Community
**Situation**: A 60k-member Discord server promoting "alpha calls" on Solana SPL tokens, with admin-rotated wallet addresses for "VIP access" payment.

**Approach**:
1. Map the funnel: invite source (X promoted post / TikTok) → landing channel → verification bot → role-gated alpha channel
2. Capture announcement-channel call timing relative to on-chain trade times (admins front-running their own calls is the dominant pattern)
3. Document the contract addresses called and their launch / liquidity events via on-chain investigation
4. Capture admin handles, snowflake IDs, Connections-panel data; pivot to other servers via mutual-servers
5. Cross-reference launch wallets and recipient wallets to identify the operator's address cluster
6. Document victim complaint patterns in `#support` / `#general` channels (often deleted by mods within hours — capture early)
7. Package per [[../Techniques/sop-reporting-packaging-disclosure|Reporting & Disclosure SOP]]; consider responsible disclosure to the chain's compliance contacts and to relevant exchanges (deposit-address blocking)

**Outcome shape**: Evidence supports civil recovery and CFTC / SEC complaints in US scope; cross-reference with the financial AML OSINT path for tracing.

### Scenario 3: Webhook Leak Bug-Bounty Triage
**Situation**: During an authorized bug-bounty engagement, a public S3 bucket exposes a `config.json` containing a Discord webhook URL used by the customer's CI pipeline for build-failure notifications.

**Approach**:
1. **Do not POST** to the webhook URL — that is unauthorized access to a customer system
2. GET the webhook metadata via `GET https://discord.com/api/webhooks/<id>/<token>` to confirm ownership (returns webhook name, server ID, channel ID) — only if read-only metadata access is in scope
3. Document the leak with: source URL of the leaked config, capture timestamp, file SHA-256, webhook ID (snowflake → creation timestamp), server ID, channel ID
4. Report through the bug-bounty program's official channel per [[../../Security/Pentesting/sop-bug-bounty|Bug Bounty Methodology SOP]]
5. Recommend remediation: rotate webhook (delete + recreate), audit S3 bucket policy, enable secret-scanning in CI
6. **Do not** publish the webhook URL in any report draft, screenshot, or external write-up — redact the token portion before any handoff

**Outcome shape**: Disclosure-grade evidence package; vendor rotates webhook within hours of report; finding may qualify for the program's information-disclosure tier.

## 15) Emergency Procedures

### Immediate Archival Triggers
- Server announces shutdown / migration / "moving to Telegram"
- Admins begin mass channel deletion or role purges
- Active threat-to-life content (violence planning, victim targeting)
- CSAM or trafficking indicators
- Law-enforcement preservation request directed at the engagement

### Rapid Response Protocol
1. **Immediate authorized export** of in-scope channels via DiscordChatExporter (HTML + JSON, both formats — HTML for human review, JSON for machine pipeline)
2. **Screenshot** server overview, channel list, role list, member sidebar (visible online members), pinned messages of every monitored channel
3. **Capture all snowflake IDs** for server, channels, roles, key users — names mutate, IDs do not
4. **Download attachments** at original quality; SHA-256 immediately
5. **External archival** for any public-facing endpoints (server-listing-site profile, public bot pages) via Archive.org / archive.today
6. **Forward critical messages** to a dedicated case "saved messages" workspace (analyst's own DMs) — preserves the message link form `https://discord.com/channels/<sid>/<cid>/<mid>` even if the source channel is later purged
7. **Hash everything** and update [[../Techniques/sop-collection-log|Collection Log]]
8. **Notify** engagement lead / client / law-enforcement liaison per RoE

### Sensitive-Crime Hard Stop (CSAM, Trafficking, Imminent Threat-to-Life)
- **Do not download** the offending content
- **Capture URL + timestamp + snowflake ID + server / channel ID only**
- **Do not analyze further**
- **Route immediately** per [[../Techniques/sop-sensitive-crime-intake-escalation|Sensitive Crime Intake & Escalation SOP]]
- **CSAM**: report to NCMEC CyberTipline (US — https://report.cybertip.org), IWF (UK), INHOPE network national member elsewhere; preserve URL only
- **Imminent threat-to-life**: local emergency services + Discord Trust & Safety (https://dis.gd/request) with emergency-disclosure framing

### Escalation Triggers (see [[../Techniques/sop-sensitive-crime-intake-escalation|Sensitive Crime Escalation SOP]])
- **Immediate threats**: terrorism, mass violence, specific threats to identifiable individuals
- **Child safety**: CSAM, grooming, sextortion, trafficking
- **Active crimes**: large-scale stealer markets with active victim-data flow, contract-killing-for-hire claims, weapons sales
- **National security**: state-sponsored influence operations, espionage adjacency, CI targeting
- **Legal process**: court orders, subpoenas, mutual-legal-assistance requests routed to the engagement lead

## 16) Legal & Ethical Considerations

> Discord OSINT sits at the intersection of platform ToS, sock-puppet pretexting law, and (frequently) sensitive-crime evidence. The canonical source for legal posture is [[../Techniques/sop-legal-ethics|Legal & Ethics SOP]] — never re-derive it here.

- **Platform ToS**: bulk scraping, self-bots (user-token automation), mass DMs, coordinated inauthentic behavior, automated account creation, and ToS-circumventing client mods are prohibited by [Discord's ToS](https://discord.com/terms) and [Community Guidelines](https://discord.com/guidelines). Investigation accounts that violate ToS risk ban and evidence-admissibility challenges.
- **Sock-puppet & pretexting framing**: lurking in a server joined via a public invite is generally OSINT; sustained false-identity engagement (fake vendor persona, fake buyer interaction, paid VIP-tier access under a manufactured backstory) crosses into pretexting under several legal frameworks (US — varies by state and engagement context; EU — GDPR Recital 47 / lawful basis; UK — CMA pretexting prohibitions) and may compromise evidence admissibility. Document the legal basis in [[../Techniques/sop-collection-log|Collection Log]].
- **DiscordChatExporter ToS gray area**: self-owned data is fine; authorized customer-server engagement is fine; running it against a third-party server the analyst joined as a lurker is a ToS gray area — flag and route to [[../Techniques/sop-legal-ethics|Legal & Ethics SOP]]. Prefer authorized-bot collection when in scope; document the authority chain.
- **Wiretap / eavesdropping statutes**: surreptitious recording of voice channels and Stage Channels triggers wiretap statutes in many jurisdictions (US — federal Wiretap Act and state-level "two-party consent" rules in CA, FL, IL, MA, MD, MT, NH, PA, WA; EU — varies); only record under explicit consent or legal process.
- **Webhook & token interaction limits**: capturing a leaked webhook URL is OSINT; POSTing to it is unauthorized access. Capturing a leaked bot token is OSINT; using it to authenticate is unauthorized access. Treat any leaked credential as evidence to disclose, not to validate.
- **Sensitive-crime hard stop**: CSAM, trafficking, and threat-to-life trigger immediate routing per [[../Techniques/sop-sensitive-crime-intake-escalation|Sensitive Crime Escalation SOP]]. Do not download; preserve URL + timestamp + snowflake-ID metadata only.
- **OPSEC**: investigation phone numbers, payment methods, devices, and IPs must be isolated from the analyst's personal identity per [[../Techniques/sop-opsec-plan|OPSEC Planning SOP]]. Discord's coordinated-inauthentic-behavior detection links accounts via shared payment, shared IP, and device fingerprint; account warming + payment isolation + connection routing are required for sustained investigation accounts.
- **Connections-panel disclosure**: capturing a target's voluntarily-public Connections (Twitch / GitHub / Spotify / etc.) is OSINT; correlating connections to deanonymize a pseudonymous target may engage GDPR/CCPA personal-data scope — ensure lawful basis is documented.

## 17) Related SOPs

- [[../Techniques/sop-legal-ethics|Legal & Ethics SOP]] — Review before every investigation
- [[../Techniques/sop-opsec-plan|OPSEC Planning]] — Investigation account isolation, sock-puppet hygiene, payment/device discipline
- [[../Techniques/sop-collection-log|Collection Log]] — Evidence tracking, chain of custody, snowflake-ID logging
- [[../Techniques/sop-sensitive-crime-intake-escalation|Sensitive Crime Escalation]] — CSAM / trafficking / threat-to-life routing
- [[../Techniques/sop-image-video-osint|Image & Video OSINT]] — Avatar reverse search, attachment analysis
- [[../Techniques/sop-entity-dossier|Entity Dossier]] — Subject / server / bot dossier consolidation
- [[../Techniques/sop-web-dns-whois-osint|Web/DNS/WHOIS OSINT]] — Linked-domain pivots from server bios and bot landing pages
- [[../Techniques/sop-financial-aml-osint|Financial & AML OSINT]] — Wallet / payment-flow tracing from server-posted addresses
- [[../Techniques/sop-blockchain-investigation|Blockchain Investigation]] — Multi-chain tracing for crypto-coordinated communities
- [[../Techniques/sop-reporting-packaging-disclosure|Reporting & Disclosure]] — Final report preparation, redaction discipline
- [[sop-platform-telegram|Telegram SOP]] — Comparative messaging-platform methodology and Telegram-side cross-references
- [[../../Security/Pentesting/sop-cloud-pentest|Cloud Pentesting SOP]] — Authorized validation of leaked cloud credentials posted in Discord
- [[../../Security/Pentesting/sop-bug-bounty|Bug Bounty Methodology SOP]] — Responsible disclosure path for webhook / token leaks
- [[../../Security/Analysis/sop-malware-analysis|Malware Analysis SOP]] — Sandbox analysis of attachments and stealer payloads referenced in Discord channels

## 18) External Resources

**Official Documentation:**
- Discord Developer Portal: https://discord.com/developers/docs
- Discord API Reference: https://discord.com/developers/docs/reference
- Discord Permissions Reference: https://discord.com/developers/docs/topics/permissions
- Discord Terms of Service: https://discord.com/terms
- Discord Community Guidelines: https://discord.com/guidelines
- Discord Privacy Policy: https://discord.com/privacy
- Discord Trust & Safety / Law Enforcement: https://dis.gd/request

**Third-Party Tools:**
- DiscordChatExporter: https://github.com/Tyrrrz/DiscordChatExporter
- discord.py: https://discordpy.readthedocs.io
- discord.js: https://discord.js.org
- serenity (Rust): https://github.com/serenity-rs/serenity
- Sherlock: https://github.com/sherlock-project/sherlock
- Maigret: https://github.com/soxoj/maigret
- WhatsMyName: https://whatsmyname.app

**Server Discovery Directories:**
- Disboard: https://disboard.org
- Disforge: https://disforge.com
- Top.gg: https://top.gg
- Discords.com: https://discords.com
- DiscordHome: https://discordhome.com

**Training & Guides:**
- Bellingcat OSINT Resources: https://www.bellingcat.com/resources/
- OSINT Framework: https://osintframework.com
- DFRLab Investigative Resources: https://www.atlanticcouncil.org/programs/digital-forensic-research-lab/

---

**Last Updated:** 2026-04-27
**Version:** 1.0 (initial draft — Group H queue)
**Review Frequency:** Quarterly (Fast tier — platform APIs, ToS, attacker TTPs rotate frequently)
