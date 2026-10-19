---
type: sop
title: Bluesky SOP
description: "Bluesky OSINT techniques: decentralized profile investigation, post tracking, federated network analysis & AT Protocol intelligence gathering."
tags:
  - sop
  - platform
  - bluesky
  - decentralized
  - osint
created: 2025-09-05
updated: 2026-10-18
---

# Bluesky OSINT SOP

> **Authorized OSINT use only.** Investigation accounts must comply with Bluesky's [Terms of Service](https://bsky.social/about/support/tos), which apply only to Bluesky itself (other AT Protocol apps are governed by their own terms), and tools that talk to Bluesky services must follow the [Developer Guidelines](https://bsky.network/docs/developer-guidelines) (no automated or bulk interactions; services must delete content a user has asked to delete) [verify 2026-10-18]. Review [[../Techniques/sop-legal-ethics|Legal & Ethics SOP]] and [[../Techniques/sop-opsec-plan|OPSEC Planning SOP]] before any engagement.

## Table of Contents

1. [Access & Client Options](#1-access--client-options)
2. [Search & Discovery Methods](#2-search--discovery-methods)
3. [Repeatable Workflow](#3-repeatable-workflow)
4. [Profile & Network Intelligence](#4-profile--network-intelligence)
5. [Investigation Recipes](#5-investigation-recipes)
6. [Collection & Evidence Integrity](#6-collection--evidence-integrity)
7. [AT Protocol & Technical Intelligence](#7-at-protocol--technical-intelligence)
8. [Advanced Techniques](#8-advanced-techniques)
9. [Pivoting & Cross-Platform Correlation](#9-pivoting--cross-platform-correlation)
10. [Tools & Resources](#10-tools--resources)
11. [Risks & Limitations](#11-risks--limitations)
12. [Quality Assurance & Verification](#12-quality-assurance--verification)
13. [Real-World Scenarios](#13-real-world-scenarios)
14. [Emergency Procedures](#14-emergency-procedures)
15. [Legal & Ethical Considerations](#15-legal--ethical-considerations)
16. [Related SOPs](#16-related-sops)
17. [External Resources](#17-external-resources)

## 1) Access & Client Options

- **Web**: https://bsky.app (primary interface)
- **Mobile apps**: iOS/Android official apps
- **Third-party clients**: Deck.blue, Skeets, Graysky [verify 2026-10-18]
- **AT Protocol API**: many public reads (profiles, posts, followers) need no login via the AppView at `https://public.api.bsky.app`; `searchPosts` may require auth on some providers; authenticate for private data or writes with an App Password, never the account password (https://bsky.network/docs/api-directory/) [verify 2026-10-18]
- **Firehose access**: Real-time feed of all public posts [verify 2026-10-18]
- **Custom domains**: Users can use custom handles (@username.yourdomain.com) [verify 2026-10-18]

## 2) Search & Discovery Methods

### Basic Search
- **Keyword search**: General content search across posts
- **Handle search**: @username.bsky.social or custom @username.domain.com
- **Hashtag search**: #keyword functionality [verify 2026-10-18]
- **User discovery**: Display name matching
- **Post search**: Content within posts, replies, quotes

### Search Operators
- `from:handle` / `from:me` - Posts by an account (`me` only when logged in) [verify 2026-10-18]
- `to:handle` / `mentions:handle` / `mentions:me` - Posts that mention an account [verify 2026-10-18]
- `"exact phrase"` - Exact match; `"@handle"` matches the literal text [verify 2026-10-18]
- `#tag` - Posts with that hashtag [verify 2026-10-18]
- `domain:example.com` - Posts linking to a domain; paste a full URL to find posts sharing it [verify 2026-10-18]
- `lang:en` - Two-letter ISO language code [verify 2026-10-18]
- `since:` / `until:` - Date range as `YYYY-MM-DD` or UTC `YYYY-MM-DDTHH:MM:SSZ` (no local time formats) [verify 2026-10-18]
- **API** (`app.bsky.feed.searchPosts`): `q`, `author`, `mentions`, `since` (inclusive), `until` (exclusive), `lang`, `domain`, `url`, `tag` (AND-matched), `sort` (`top`/`latest`), `limit` (≤100), `cursor` [verify 2026-10-18]

### Advanced Features
- **Custom feeds**: Algorithm-based or curated content streams [verify 2026-10-18]
- **Lists**: User-created lists for organization
- **Discover feed / Trending topics**: Trending content discovery [verify 2026-10-18]
- **Firehose monitoring**: Real-time all-posts stream [verify 2026-10-18]
- **PDS identification**: Resolve the DID document; the `service` entry with id `#atproto_pds` gives the hosting PDS in `serviceEndpoint` [verify 2026-10-18]

## 3) Repeatable Workflow

1. **Target identification**: Handle variations, custom domains, display names
2. **Profile analysis**: Bio, avatar, header, pinned posts, verification status
3. **Content timeline**: Post chronology, reply patterns, repost behavior
4. **Network mapping**: Followers, following, interaction frequency, lists
5. **Feed analysis**: Custom feeds followed/created, algorithmic vs chronological
6. **AT Protocol intelligence**: DID resolution, PDS hosting
7. **Cross-platform correlation**: Bio links, username patterns, content cross-posting
8. **Engagement tracking**: Likes, reposts, replies, quote posts
9. **Temporal analysis**: Posting patterns, timezone indicators
10. **Documentation**: Archive posts, calculate hashes, maintain chain of custody

## 4) Profile & Network Intelligence

### Profile Analysis
- **Handle**: Custom domain (@user.domain.com) vs default (@user.bsky.social) [verify 2026-10-18]
- **DID (Decentralized Identifier)**: Permanent account identifier
- **Bio**: Links, contact info, profession, interests
- **Verification**: blue check = verified by Bluesky as authentic and notable; scalloped check = issued by a Trusted Verifier organization (tap the badge to see who granted it); a domain handle links a website to the account but is not a verification badge; badges can be hidden in client settings, so record the DID and the issuing verifier [verify 2026-10-18]
- **Post patterns**: Frequency, timing, content types
- **Lists**: Public lists user appears on or has created
- **Custom feeds**: Feeds created/followed by user [verify 2026-10-18]

### Network Mapping
- **Followers/following**: Network size, mutual connections
- **Interaction patterns**: Reply frequency, quote patterns, mentions
- **Community clusters**: Topic-based groups, shared interests
- **Influence tracking**: Repost chains, viral content propagation

## 5) Investigation Recipes

### Breaking News Monitoring
**Objective**: Track real-time events and citizen journalism

**Search**: `#breakingnews #[location]` + monitor Discover and Trending topics [verify 2026-10-18]

**Method**:
1. Search event hashtags immediately
2. Monitor firehose for real-time posts
3. Identify verified eyewitnesses (check post history)
4. Archive all relevant content before deletion
5. Cross-reference with Twitter, news reports

### User Behavior Analysis
**Objective**: Profile user activity and patterns

**Search**: `@username` + review full post history

**Method**:
1. Analyze posting frequency and timing
2. Review interaction patterns (who they engage with)
3. Check custom feeds they follow/create
4. Map network (followers, following, lists)
5. Identify cross-platform presence (bio links)

### Disinformation Tracking
**Objective**: Identify coordinated inauthentic behavior

**Search**: Monitor specific claims/narratives via keywords

**Method**:
1. Search for false claim keywords
2. Identify accounts amplifying misinformation
3. Check account creation dates (coordinated?)
4. Analyze posting patterns (automated?)
5. Track narrative evolution over time
6. Use firehose for comprehensive coverage

## 6) Collection & Evidence Integrity

### Capture Methods
- **Post archival**: Full thread with AT Protocol metadata
- **Screenshots**: Visual capture with URL, timestamp
- **API extraction**: JSON data via AT Protocol API
- **Firehose capture**: Real-time stream processing
- **Media download**: Images, videos with alt-text
- **Profile snapshots**: Complete profile state

### File Organization
```
/Evidence/{{case_id}}/Bluesky/
├── YYYYMMDD-HHMM/
│   ├── posts/
│   │   ├── @username_post_[ID].json
│   │   └── @username_post_[ID].png
│   ├── profiles/
│   │   ├── @username_profile.json
│   │   └── @username_DID_resolution.txt
│   ├── media/
│   │   └── post_[ID]_image.jpg
│   └── SHA256SUMS
```

### Hashing & Verification
- Calculate SHA-256 for all files
- Document DID, post URI (at://), capture timestamp
- Reference in [[../Techniques/sop-collection-log|Collection Log]]
- Preserve AT Protocol metadata (CID, record keys)

## 7) AT Protocol & Technical Intelligence

### Decentralized Identifiers (DIDs)
- **DID format**: did:plc:abc123xyz (permanent account ID) [verify 2026-10-18]
- **DID resolution**: Map DID to current handle, PDS
- **Handle changes**: Track historical handles via DID
- **PDS hosting**: Identify Personal Data Server location
- **Data flow**: The PDS hosts the account's repository; Relays aggregate repository updates from many PDSs into the firehose; AppViews aggregate them for metrics, discovery and search [verify 2026-10-18]

### Firehose Monitoring
```bash
# Monitor real-time firehose (public, no authentication required) [verify 2026-10-18]
# Option A: goat CLI (github.com/bluesky-social/goat), one line per record op [verify 2026-10-18]
goat firehose --ops -c app.bsky.feed.post \
  | jq -c 'select(.record.text // "" | test("keyword"; "i"))' > firehose.jsonl
# Option B: Jetstream (official filtered JSON websocket; event under .payload) [verify 2026-10-18]
websocat --protocol xrpc.v1.json "wss://jetstream.us-east.bsky.network/xrpc/network.bsky.jetstream.subscribeEvents?collections=app.bsky.feed.post&kinds=commit" \
  | jq -c 'select(.payload.record.text // "" | test("keyword"; "i"))' > firehose.jsonl
```

## 8) Advanced Techniques

### Custom Feed Creation
- Create investigative feeds for specific topics
- Filter by keywords, users, engagement metrics
- Monitor target accounts automatically
- Aggregate related content for analysis

### API Automation
```python
# Example: AT Protocol Python client
import os
from atproto import Client

# Get user profile: public read, no login (AppView) [verify 2026-10-18]
public = Client(base_url='https://public.api.bsky.app')
profile = public.app.bsky.actor.get_profile({'actor': 'username.bsky.social'})

# Search posts: may require auth; log in with an App Password, never the account password [verify 2026-10-18]
client = Client()
client.login('username.bsky.social', os.environ['BSKY_APP_PASSWORD'])
posts = client.app.bsky.feed.search_posts({'q': 'keyword', 'limit': 100})
```

## 9) Pivoting & Cross-Platform Correlation

### Profile Pivots
- **Custom domains** → WHOIS lookup, domain ownership
- **Bio links** → Personal websites, Twitter, LinkedIn, other socials
- **Username consistency** → Same handle on other platforms (Nuclei)
- **DID → Handle history** → Track account migrations

### Content Pivots
- **Cross-posted content** → Same posts on Twitter, Mastodon
- **Media files** → Reverse image search for original sources
- **External links** → Website/domain investigation
- **Hashtags** → Cross-platform hashtag tracking

### Network Pivots
- **Mutual followers** → Shared communities
- **Interaction patterns** → Frequent collaborators
- **List membership** → Topic-based groupings

## 10) Tools & Resources

| Tool                 | Purpose                        | Platform | Access                                  |
| -------------------- | ------------------------------ | -------- | --------------------------------------- |
| **Bluesky Web**      | Official web interface         | Web      | https://bsky.app                        |
| **AT Protocol API**  | Official API access            | API      | https://bsky.network/docs/bluesky-api/ [verify 2026-10-18] |
| **atproto (Python)** | Python client library          | Python   | `pip install atproto` [verify 2026-10-18] |
| **Deck.blue**        | Third-party desktop client     | Web      | https://deck.blue                       |
| **Nuclei**           | Username enumeration           | CLI      | `nuclei -tags osint -esc -var user=username` (user-enumeration templates are self-contained; `-esc` loads them) [verify 2026-10-18] |
| **Social-Analyzer**  | Cross-platform username search | CLI      | `pip install social-analyzer` [verify 2026-10-18] |
| **Jetstream / goat** | Official firehose (no auth)    | WebSocket/CLI | `wss://jetstream.us-east.bsky.network/xrpc/network.bsky.jetstream.subscribeEvents?collections=app.bsky.feed.post`; `goat firehose` [verify 2026-10-18] |
| **DID Resolver**     | Resolve DIDs to handles        | Web      | https://plc.directory [verify 2026-10-18] |
| **Wayback Machine**  | Historical snapshots           | Web      | https://web.archive.org                 |

## 11) Risks & Limitations

- **Rapid development**: Features changing frequently
- **Distributed hosting**: An account's data lives on its PDS, which can be self-hosted or run by a provider other than Bluesky, and accounts can migrate between PDSs [verify 2026-10-18]
- **Search limits**: The API leaves query syntax beyond its filters (boolean, negation) unspecified; the `mentions` filter matches only rich-text facet mentions, not plain-text handles; `until` is exclusive; date filters use `sortAt`, which may differ from `createdAt` [verify 2026-10-18]
- **Data permanence**: Unclear long-term retention policies
- **Moderation variance**: Moderation is applied as labels from labelers (moderation services), which independent third parties can run; which labels hide or warn on a post depends on the viewer's client and labeler subscriptions [verify 2026-10-18]
- **Third-party access**: External tools may have limitations
- **Handle changes**: Custom domains can change (track via DID)
- **Public by default**: Most content public and searchable

## 12) Quality Assurance & Verification

### Content Verification
- **DID resolution**: Pins the account behind a handle, not who runs it; check verification badges and record the issuing verifier [verify 2026-10-18]
- **Handle verification**: A custom-domain handle shows control of that domain, not identity verification [verify 2026-10-18]
- **Timestamp validation**: Post time vs claimed events
- **Cross-platform check**: Verify with other social media

### Evidence Quality
- **AT Protocol metadata**: Preserve DIDs, CIDs, record keys
- **Multiple formats**: JSON + screenshot + PDF
- **Chain of custody**: Document all collection steps
- **Hash verification**: SHA-256 for integrity
- **DID permanence**: Use DID (not handle) as primary identifier

## 13) Real-World Scenarios

### Scenario 1: Twitter Migration Intelligence
**Situation**: Track influential accounts migrating from Twitter to Bluesky.

**Approach**:
1. Search for "Twitter" mentions and migration announcements
2. Check bio links for Twitter handles (verify same person)
3. Track follower network reconstruction
4. Analyze posting pattern changes (frequency, tone, topics)
5. Document community formation and new dynamics

**Outcome**: Identified 250 journalists/activists who migrated; tracked handle consistency (85% used same username); documented network reformation; insights used for social media strategy analysis.

### Scenario 2: Coordinated Disinformation on Decentralized Platform
**Situation**: False narrative spreading across Bluesky.

**Approach**:
1. Identify original post with false claim
2. Track via firehose: all reposts, quotes, replies
3. Check DIDs: account creation patterns (coordinated?)
4. Analyze PDS hosting: a shared self-hosted PDS can indicate coordination; Bluesky runs many PDSs behind one entryway, so a shared Bluesky-run PDS proves nothing [verify 2026-10-18]
5. Map interaction network: who amplifies whom
6. Document before moderation/deletion
7. Check if campaign also on Twitter, Mastodon

**Outcome**: Discovered 12 accounts created same week, hosted on same PDS; coordinated posting pattern (15min intervals); false claim reached 50K users before flagging; evidence submitted to the PDS operator and platform safety team.

### Scenario 3: Missing Person Located via Bluesky Post
**Situation**: Person missing 24 hours, active on Bluesky.

**Approach**:
1. Resolve DID to find current handle (may have changed)
2. Check latest posts for location clues
3. Analyze background in photos, videos
4. Review custom feeds followed (local area feeds?)
5. Check interactions with location-specific accounts
6. Analyze posting time for timezone
7. Contact via DMs if appropriate [verify 2026-10-18]

**Outcome**: Latest post 8 hours ago mentioned "new coffee shop downtown"; profile recently followed "[City]LocalNews" feed; posting times indicated PT timezone; cross-referenced with recent cafe openings; location intel provided to authorities; person found safe.

## 14) Emergency Procedures

### Immediate Archival Triggers
- Account shows signs of deletion or migration
- Content contains evidence of imminent threat
- Server shutdown announced (content may be lost)
- Legal preservation requirement
- Coordinated harassment campaign in progress

### Rapid Response Protocol
1. **Immediate capture**: API extraction + screenshots
2. **DID resolution**: Permanent identifier documentation
3. **Firehose backup**: Check if already in stream archive
4. **Media download**: All images/videos at full quality
5. **PDS check**: Fetch the record from the account's own PDS with `com.atproto.repo.getRecord` (no auth required) and compare it with the AppView copy [verify 2026-10-18]
6. **Hash calculation**: SHA-256 immediately
7. **External archive**: Submit to Wayback Machine

### Escalation Triggers (see [[../Techniques/sop-sensitive-crime-intake-escalation|Sensitive Crime Escalation SOP]])
- **Immediate threats**: Violence, suicide, terrorism
- **Child safety**: CSAM, exploitation, grooming
- **Coordinated harassment**: Organized abuse campaigns
- **Non-Bluesky services**: Content on a self-hosted PDS or another AT Protocol app is outside Bluesky's control; Bluesky's ToS tells users to contact those services directly, so identify the operator from the DID document's `serviceEndpoint` [verify 2026-10-18]
- **Legal requirements**: Court orders, law enforcement requests

### Legal Process & Preservation
- **Official Requests Portal** (law enforcement, government agencies, regulatory and competent authorities, legal representatives): sign up https://app.kodexglobal.com/bluesky/signup, sign in https://app.kodexglobal.com/bluesky/signin [verify 2026-10-18]
- **Other legal requests**: legal-req@blueskyweb.xyz; requests must be in English [verify 2026-10-18]
- **Preservation**: Bluesky accepts preservation requests and holds data pending legal authorization to transfer it; DMs are not provided to third parties unless court-ordered [verify 2026-10-18]
- Non-authority investigators refer via [[../Techniques/sop-sensitive-crime-intake-escalation|Sensitive Crime Intake & Escalation]]; review [[../Techniques/sop-legal-ethics|Legal & Ethics]] first

## 15) Legal & Ethical Considerations

> The canonical source for legal posture is [[../Techniques/sop-legal-ethics|Legal & Ethics SOP]]. Never re-derive it here.

- **Platform ToS**: [Bluesky's Terms of Service](https://bsky.social/about/support/tos) (last updated 2025-08-14) cover only Bluesky; another AT Protocol app is governed by its own terms, and the ToS does not address scraping or API use. Tools that talk to Bluesky services fall under the [Developer Guidelines](https://bsky.network/docs/developer-guidelines): no automated or bulk interactions (messages, follows, likes, replies), no account-generation tools, and every service must delete content a user has asked to delete [verify 2026-10-18]. Keep collection read-only: do not like, follow or reply from the investigation account.
- **Legal process**: requests and preservation follow [Legal Process & Preservation](#legal-process--preservation) under §14; do not duplicate them here.
- **Sensitive-crime routing**: CSAM, threat-to-life, trafficking, terrorism content found during OSINT triggers immediate hard-stop and routing per [[../Techniques/sop-sensitive-crime-intake-escalation|Sensitive Crime Escalation SOP]]. Do not download or further analyze CSAM; preserve URL + timestamp only and report to NCMEC (US) / IWF (UK) / national equivalent.
- **OPSEC**: the investigation account, its email and devices must be isolated from the analyst's personal identity per [[../Techniques/sop-opsec-plan|OPSEC Planning SOP]]; script with an App Password (§1), never the account password.

## 16) Related SOPs

- [[../Techniques/sop-legal-ethics|Legal & Ethics SOP]] - Review before every investigation
- [[../Techniques/sop-opsec-plan|OPSEC Planning]] - Account isolation, federation considerations
- [[../Techniques/sop-collection-log|Collection Log]] - Evidence tracking with DIDs
- [[../Techniques/sop-web-dns-whois-osint|Web/DNS/WHOIS OSINT]] - Custom domain investigation
- [[../Techniques/sop-entity-dossier|Entity Dossier Building]] - User profiling
- [[../Techniques/sop-reporting-packaging-disclosure|Reporting & Disclosure]] - Final reports
- [[../Techniques/sop-sensitive-crime-intake-escalation|Sensitive Crime Escalation]] - Law enforcement referral

## 17) External Resources

**Official Documentation:**
- Bluesky Docs: https://bsky.network (docs.bsky.app redirects here) [verify 2026-10-18]
- AT Protocol Spec: https://atproto.com [verify 2026-10-18]
- DID PLC Directory: https://plc.directory [verify 2026-10-18]

**Third-Party Tools:**
- atproto Python: https://github.com/MarshalX/atproto [verify 2026-10-18]
- Deck.blue: https://deck.blue
- Nuclei Templates: https://github.com/projectdiscovery/nuclei-templates [verify 2026-10-18]
- Social-Analyzer: https://github.com/qeeqbox/social-analyzer [verify 2026-10-18]

**Training & Guides:**
- Bellingcat How-To Guides (general): https://www.bellingcat.com/resources/how-tos/ [verify 2026-10-18]
- OSINT Framework: https://osintframework.com/ [verify 2026-10-18]

---

**Last Updated:** 2026-10-18
**Version:** 1.0
**Review Frequency:** Yearly
