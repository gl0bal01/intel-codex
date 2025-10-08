---
type: sop
title: Bluesky SOP
tags:
  - sop
  - platform
  - bluesky
  - decentralized
  - osint
created: 2025-09-05
updated: 2025-09-06
---

# Bluesky OSINT SOP

## 1) Access & Client Options

- **Web**: https://bsky.app (primary interface)
- **Mobile apps**: iOS/Android official apps
- **Third-party clients**: Deck.blue, Skeets, Graysky
- **AT Protocol API**: Open API with authentication (https://docs.bsky.app)
- **Firehose access**: Real-time feed of all public posts
- **Custom domains**: Users can use custom handles (@username.yourdomain.com)

## 2) Search & Discovery Methods

### Basic Search
- **Keyword search**: General content search across posts
- **Handle search**: @username.bsky.social or custom @username.domain.com
- **Hashtag search**: #keyword functionality
- **User discovery**: Display name matching
- **Post search**: Content within posts, replies, quotes

### Advanced Features
- **Custom feeds**: Algorithm-based or curated content streams
- **Lists**: User-created lists for organization
- **What's Hot**: Trending content discovery
- **Firehose monitoring**: Real-time all-posts stream
- **Federation search**: Cross-server content discovery

## 3) Repeatable Workflow

1. **Target identification**: Handle variations, custom domains, display names
2. **Profile analysis**: Bio, avatar, header, pinned posts, verification status
3. **Content timeline**: Post chronology, reply patterns, repost behavior
4. **Network mapping**: Followers, following, interaction frequency, lists
5. **Feed analysis**: Custom feeds followed/created, algorithmic vs chronological
6. **AT Protocol intelligence**: DID resolution, PDS hosting, federation data
7. **Cross-platform correlation**: Bio links, username patterns, content cross-posting
8. **Engagement tracking**: Likes, reposts, replies, quote posts
9. **Temporal analysis**: Posting patterns, timezone indicators
10. **Documentation**: Archive posts, calculate hashes, maintain chain of custody

## 4) Profile & Network Intelligence

### Profile Analysis
- **Handle**: Custom domain (@user.domain.com) vs default (@user.bsky.social)
- **DID (Decentralized Identifier)**: Permanent account identifier
- **Bio**: Links, contact info, profession, interests
- **Verification**: Domain verification status (custom handles)
- **Post patterns**: Frequency, timing, content types
- **Lists**: Public lists user appears on or has created
- **Custom feeds**: Feeds created/followed by user

### Network Mapping
- **Followers/following**: Network size, mutual connections
- **Interaction patterns**: Reply frequency, quote patterns, mentions
- **Community clusters**: Topic-based groups, shared interests
- **Influence tracking**: Repost chains, viral content propagation
- **Federation connections**: Cross-server relationships

## 5) Investigation Recipes

### Breaking News Monitoring
**Objective**: Track real-time events and citizen journalism

**Search**: `#breakingnews #[location]` + monitor "What's Hot"

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
- **DID format**: did:plc:abc123xyz (permanent account ID)
- **DID resolution**: Map DID to current handle, PDS
- **Handle changes**: Track historical handles via DID
- **PDS hosting**: Identify Personal Data Server location
- **Federation tracking**: Which servers host user data

### Firehose Monitoring
```bash
# Monitor real-time firehose (requires authentication)
# Example using AT Protocol client
bsky firehose --filter "keyword" --output firehose.json
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
from atproto import Client

client = Client()
client.login('username.bsky.social', 'password')

# Search posts
posts = client.app.bsky.feed.search_posts({'q': 'keyword', 'limit': 100})

# Get user profile
profile = client.app.bsky.actor.get_profile({'actor': 'username.bsky.social'})
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
- **Federation connections** → Cross-server relationships

## 10) Tools & Resources

| Tool                 | Purpose                        | Platform | Access                                  |
| -------------------- | ------------------------------ | -------- | --------------------------------------- |
| **Bluesky Web**      | Official web interface         | Web      | https://bsky.app                        |
| **AT Protocol API**  | Official API access            | API      | https://docs.bsky.app                   |
| **atproto (Python)** | Python client library          | Python   | `pip install atproto`                   |
| **Deck.blue**        | Third-party desktop client     | Web      | https://deck.blue                       |
| **Nuclei**           | Username enumeration           | CLI      | `nuclei -tags osint -var user=username` |
| **Social-Analyzer**  | Cross-platform username search | CLI      | `pip install social-analyzer`           |
| **Firehose Monitor** | Real-time stream viewer        | Web      | Various third-party tools               |
| **DID Resolver**     | Resolve DIDs to handles        | Web      | https://plc.directory                   |
| **Wayback Machine**  | Historical snapshots           | Web      | https://web.archive.org                 |

## 11) Risks & Limitations

- **Rapid development**: Features changing frequently
- **Federation complexity**: Content distributed across servers
- **Limited search**: Less mature than Twitter/X
- **Data permanence**: Unclear long-term retention policies
- **Moderation variance**: Different server policies
- **Third-party access**: External tools may have limitations
- **Handle changes**: Custom domains can change (track via DID)
- **Public by default**: Most content public and searchable

## 12) Quality Assurance & Verification

### Content Verification
- **DID resolution**: Verify account authenticity via DID
- **Handle verification**: Check custom domain ownership
- **Timestamp validation**: Post time vs claimed events
- **Cross-platform check**: Verify with other social media
- **Federation audit**: Check content across multiple servers

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
1. Monitor invite code distribution patterns
2. Search for "Twitter" mentions and migration announcements
3. Check bio links for Twitter handles (verify same person)
4. Track follower network reconstruction
5. Analyze posting pattern changes (frequency, tone, topics)
6. Document community formation and new dynamics

**Outcome**: Identified 250 journalists/activists who migrated; tracked handle consistency (85% used same username); documented network reformation; insights used for social media strategy analysis.

### Scenario 2: Coordinated Disinformation on Decentralized Platform
**Situation**: False narrative spreading across Bluesky federation.

**Approach**:
1. Identify original post with false claim
2. Track via firehose: all reposts, quotes, replies
3. Check DIDs: account creation patterns (coordinated?)
4. Analyze PDS hosting: same server indicates coordination
5. Map interaction network: who amplifies whom
6. Document before moderation/deletion
7. Check if campaign also on Twitter, Mastodon

**Outcome**: Discovered 12 accounts created same week, hosted on same PDS; coordinated posting pattern (15min intervals); false claim reached 50K users before flagging; evidence submitted to server admins and platform safety team.

### Scenario 3: Missing Person Located via Bluesky Post
**Situation**: Person missing 24 hours, active on Bluesky.

**Approach**:
1. Resolve DID to find current handle (may have changed)
2. Check latest posts for location clues
3. Analyze background in photos, videos
4. Review custom feeds followed (local area feeds?)
5. Check interactions with location-specific accounts
6. Analyze posting time for timezone
7. Contact via DMs if appropriate

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
5. **Federation check**: Verify content on other servers
6. **Hash calculation**: SHA-256 immediately
7. **External archive**: Submit to Wayback Machine

### Escalation Triggers (see [[../Techniques/sop-sensitive-crime-intake-escalation|Sensitive Crime Escalation SOP]])
- **Immediate threats**: Violence, suicide, terrorism
- **Child safety**: CSAM, exploitation, grooming
- **Coordinated harassment**: Organized abuse campaigns
- **Server-level issues**: Federation-wide moderation concerns
- **Legal requirements**: Court orders, law enforcement requests

## 15) Related SOPs

- [[../Techniques/sop-legal-ethics|Legal & Ethics SOP]] - Review before every investigation
- [[../Techniques/sop-opsec-plan|OPSEC Planning]] - Account isolation, federation considerations
- [[../Techniques/sop-collection-log|Collection Log]] - Evidence tracking with DIDs
- [[../Techniques/sop-web-dns-whois-osint|Web/DNS/WHOIS OSINT]] - Custom domain investigation
- [[../Techniques/sop-entity-dossier|Entity Dossier Building]] - User profiling
- [[../Techniques/sop-reporting-packaging-disclosure|Reporting & Disclosure]] - Final reports
- [[../Techniques/sop-sensitive-crime-intake-escalation|Sensitive Crime Escalation]] - Law enforcement referral

## 16) External Resources

**Official Documentation:**
- Bluesky Docs: https://docs.bsky.app
- AT Protocol Spec: https://atproto.com
- DID PLC Directory: https://plc.directory

**Third-Party Tools:**
- atproto Python: https://github.com/MarshalX/atproto
- Deck.blue: https://deck.blue
- Nuclei Templates: https://github.com/projectdiscovery/nuclei-templates
- Social-Analyzer: https://github.com/qeeqbox/social-analyzer

**Training & Guides:**
- Bellingcat Guide: https://www.bellingcat.com/resources/how-tos/
- OSINT Framework: https://osintframework.com/

---

**Last Updated:** 2025-09-06
**Version:** 1.0
**Review Frequency:** Yearly
