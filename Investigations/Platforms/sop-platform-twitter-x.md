---
type: sop
title: Twitter/X SOP
tags:
  - sop
  - platform
  - twitter
  - x
  - social-media
  - osint
created: 2023-02-05
updated: 2025-08-24
---

# Twitter/X OSINT SOP

## 1) Access & Client Options

- **Web**: https://x.com/search-advanced (GUI - full search operators)
- **Direct search**: https://x.com/search?q=<query>
- **Mobile apps**: iOS/Android (different rate limits, stronger fingerprinting)
- **API access**: X API v2 https://docs.x.com/x-api/introduction
- **Third-party tools**: Nitter instances (privacy-focused frontends)
- **Access consideration**: Logged-out vs persona-logged-in (balance visibility vs attribution risk)

## 2) Search Operators & Syntax

### Basic Operators
- `"exact phrase"` - Exact match search
- `keyword1 keyword2` - AND logic (both must appear)
- `keyword1 OR keyword2` - Either term
- `-keyword` - Exclude term
- `#hashtag` - Hashtag search
- `@username` - Mentions of user
- `from:username` - Tweets from specific user
- `to:username` - Replies to specific user

### Advanced Operators
- `since:YYYY-MM-DD until:YYYY-MM-DD` - Date range
- `lang:en` - Language filter (en, fr, es, de, etc.)
- `place:"Paris, France"` - Location-tagged tweets
- `has:geo` - Geo-tagged content only
- `has:images` / `has:videos` / `has:links` - Media filters
- `is:retweet` / `-is:retweet` - Include/exclude retweets
- `is:reply` / `-is:reply` - Include/exclude replies
- `is:verified` - From verified accounts only
- `url:domain.com` - Tweets containing specific domain
- `url:"/specific-path"` - Tweets with specific URL path
- `min_retweets:10` - Minimum retweet count
- `min_faves:100` - Minimum likes count
- `min_replies:5` - Minimum reply count
- `context:123.456` - Event/trend context (when known)

### High-Value Combinations
- `"(exact phrase)" lang:en -is:retweet -is:reply` - Original content only
- `from:user since:YYYY-MM-DD until:YYYY-MM-DD` - User timeline slice
- `(@handle OR "real name") (scam OR fraud) -is:retweet` - Scam mentions
- `place:"City Name" has:geo has:images` - Geolocated visual content
- `url:linkstub.tld -is:retweet min_retweets:5` - Popular link shares

## 3) Repeatable Workflow

1. **Frame the time window**: Start with incident ±48h, expand to ±7d, then ±30d if needed
2. **Start broad**: Use core keywords without filters
3. **Refine progressively**: Add `lang:`, `has:media`, `-is:retweet` to narrow results
4. **Pivot on actors**: Identify key users with `from:`, `to:`, check followers/following
5. **Harvest artifacts**: Extract URLs, phone/email in bios, media files, hashtags
6. **Temporal analysis**: Plot activity timeline, identify posting patterns
7. **Network mapping**: Identify interactions, retweet chains, conversation threads
8. **Content capture**: Archive tweets (WARC + PDF + PNG + JSON if API available)
9. **Document queries**: Log exact query strings and timestamps for reproducibility
10. **Cross-reference**: Verify findings with external sources

## 4) User Profile Analysis

### Profile Intelligence
- **Display name**: Real name, pseudonym, organization
- **Username (@handle)**: Username history (if tracked), variations
- **Bio**: Location claims, occupation, affiliations, contact info
- **Profile/banner images**: Reverse image search, location indicators
- **Website link**: Personal site, business, link aggregators
- **Location field**: Self-reported location (often unreliable)
- **Join date**: Account age, creation patterns
- **Verification status**: Blue check (legacy), gold (organization), grey (government)

### Behavioral Analysis
- **Tweet frequency**: Posts per day/week, activity spikes
- **Posting times**: Timezone indicators, work schedule patterns
- **Language patterns**: Native language, grammar, vocabulary
- **Interaction style**: Aggressive, professional, casual
- **Topic clusters**: Main interests, expertise areas
- **Hashtag usage**: Campaign participation, community affiliation
- **Media sharing**: Screenshot patterns, original content vs shares

### Network Analysis
- **Followers/Following ratio**: Influence indicators
- **Mutual connections**: Shared networks, communities
- **Retweet patterns**: Information sources, trusted voices
- **Mention frequency**: Who they engage with most
- **List memberships**: How others categorize the account
- **Conversation threads**: Long-form discussions, debates

## 5) Advanced Search Techniques

### Thread & Conversation Tracking
- Use "Show this thread" to capture full conversations
- Track quoted tweets for context and reactions
- Monitor reply chains for developing narratives
- Identify coordinated behavior (same message, multiple accounts)

### Temporal Intelligence
- **Crisis monitoring**: `("breaking" OR "urgent") place:"City" since:YYYY-MM-DD`
- **Event correlation**: Search during/after known incidents
- **Anniversary analysis**: Historical date ranges for recurring events
- **Pattern detection**: Weekly/monthly activity cycles

### Media Intelligence
- **Image forensics**: Download full resolution, extract EXIF metadata
- **Video analysis**: Frame extraction, audio transcription
- **Reverse image search**: Google, Yandex, TinEye for original sources
- **Alt-text mining**: Accessibility descriptions may contain hidden details
- **Media timeline**: Chronological media posting for location verification

## 6) Investigation Recipes (Copy/Paste)

### Crisis Eyewitnessing
```
("explosion" OR "gunshots" OR "incident") ("street name" OR "city area") lang:en -is:retweet has:media since:2025-08-20 until:2025-08-26
```

### Scam Tracking
```
("investment" OR "loan" OR "crypto") ("guaranteed" OR "quick profit" OR "DM me") (WhatsApp OR Telegram) -is:retweet lang:en min_retweets:2
```

### Disinformation Monitoring
```
("fake news" OR "debunked" OR "false claim") (topic_keyword) -is:retweet lang:en has:links since:YYYY-MM-DD
```

### Image Lead Investigation
```
"unique caption fragment" has:images -is:retweet lang:en
```

### Location Verification
```
place:"Specific Location" has:geo has:images since:YYYY-MM-DD until:YYYY-MM-DD
```

### Influencer Campaign Tracking
```
#campaignhashtag -is:retweet min_faves:100 lang:en
```

### Breaking News Discovery
```
(breaking OR urgent OR "just happened") has:images -is:retweet lang:en
```

## 7) Collection & Evidence Integrity

### Capture Methods
- **Full thread archive**: Screenshot entire conversation with context
- **Media preservation**: Download original resolution images/videos
- **Profile snapshots**: Bio, profile pic, banner, pinned tweet at time of capture
- **Alt-text capture**: Include accessibility descriptions
- **Metadata recording**: Tweet ID, timestamp (UTC), engagement metrics
- **URL preservation**: Resolve shortened links, log redirect chains
- **JSON export**: API data for machine-readable evidence

### File Organization
```
/Evidence/{{case_id}}/Twitter/
├── YYYYMMDD-HHMM/
│   ├── tweets/
│   │   ├── tweet_[ID].png
│   │   ├── tweet_[ID].json
│   │   └── tweet_[ID].pdf
│   ├── media/
│   │   ├── image_[ID].jpg
│   │   └── video_[ID].mp4
│   ├── profiles/
│   │   ├── @username_profile.png
│   │   └── @username_bio.txt
│   └── SHA256SUMS
```

### Hashing & Verification
- Calculate SHA-256 for all media files immediately
- Store hashes in `SHA256SUMS` file
- Document capture timestamp and URL
- Reference in [[../Techniques/sop-collection-log|Collection Log]]
- Maintain chain of custody documentation

## 8) Pivoting & Cross-Platform Correlation

### Profile Pivots
- **Bio links** → Personal websites, Linktree, OnlyFans, business pages
- **Username search** → Same handle on other platforms (Instagram, TikTok, GitHub)
- **Email/phone** → Data breach searches, reverse lookups
- **Profile image** → Reverse image search for other accounts
- **Location claims** → Verify with geotagged posts, local knowledge

### Content Pivots
- **Media reverse search** → [[../Techniques/sop-image-video-osint|Image/Video OSINT]]
- **URL analysis** → [[../Techniques/sop-web-dns-whois-osint|Web/DNS/WHOIS OSINT]]
- **Cryptocurrency mentions** → [[../Techniques/sop-financial-aml-osint|Financial/AML OSINT]]
- **Domain sharing** → Infrastructure attribution
- **Hashtag correlation** → Campaign participation across platforms

### Network Pivots
- **Shared followers** → Community mapping
- **Retweet chains** → Information flow analysis
- **Conversation partners** → Regular interactions, relationships
- **List analysis** → Who categorizes this account and how
- **Mutual connections** → Social graph construction

## 9) Tools & Resources

| Tool                        | Purpose                            | Platform    | Access                                                |
| --------------------------- | ---------------------------------- | ----------- | ----------------------------------------------------- |
| **Twitter Advanced Search** | Native search interface            | Web         | https://x.com/search-advanced                         |
| **Nitter**                  | Privacy-focused Twitter frontend   | Web         | https://nitter.net (various instances)                |
| **Twint**                   | Twitter scraping (archived tweets) | CLI         | `pip install twint` (discontinued, archives may work) |
| X API v2**                  | Programmatic access                | API         | https://docs.x.com/x-api/introduction                 |
| **Wayback Machine**         | Historical Twitter snapshots       | Web         | https://web.archive.org                               |
| **Social-Analyzer**         | Username enumeration               | CLI         | `pip install social-analyzer`                         |
| **Nuclei**                  | Username search across platforms   | CLI         | nuclei -tags osint -var user=username<br>             |
| **ExifTool**                | Image metadata extraction          | CLI         | `exiftool image.jpg`                                  |
| **Gephi**                   | Network visualization              | Desktop     | https://gephi.org                                     |

## 10) Risks & Limitations

- **De-indexing**: Tweets may disappear post-capture, archive immediately
- **Account suspension**: Targets may delete or be suspended during investigation
- **API changes**: Frequent policy/pricing changes affect tooling
- **Shadow banning**: Content hidden from search without notification
- **Algorithm bias**: "Top" results prioritize engagement over relevance
- **Self-reported data**: Location, bio information often unreliable
- **Automated accounts**: Bots, scrapers create noise in results
- **Deleted content**: Historical data gaps from account deletions
- **Media manipulation**: Deepfakes, edited images, misleading captions

## 11) Advanced Techniques

### Deleted Content Recovery
- **Archive.org Wayback Machine**: Historical snapshots of profiles/tweets
- **Cached pages**: Google cache may retain recent deleted content
- **Third-party archives**: Archive.today, Archive.is manual captures
- **API historical access**: Enterprise tier includes deleted tweet access
- **Screenshot databases**: Politwoops, TrumpTwitterArchive (specialized)

### Automation & Monitoring
- **RSS feeds**: Create search RSS for real-time monitoring
- **IFTTT/Zapier**: Automated alerts for specific keywords/accounts
- **Python scripts**: Custom scrapers using Selenium/BeautifulSoup
- **API webhooks**: Real-time notifications for account activity

### Network Analysis
- **Follower/following exports**: Bulk relationship data collection
- **Interaction matrices**: Map reply/retweet relationships
- **Community detection**: Identify clusters in network graphs
- **Influence metrics**: Calculate centrality, reach, amplification
- **Bot detection**: Identify automated/coordinated accounts

## 12) Quality Assurance & Verification

### Content Verification
- **Cross-reference sources**: Verify with non-Twitter evidence
- **Reverse image search**: Confirm media originality
- **Timestamp validation**: Check tweet time vs claimed events
- **Geolocation verification**: Match location claims with visual evidence
- **Account authentication**: Verify blue checks, look for impersonators

### Bias Mitigation
- **Sample diversity**: Include both retweets and original content
- **Algorithm awareness**: "Top" tweets ≠ representative sample
- **Temporal balance**: Cover full time range, not just peaks
- **Language inclusion**: Search in multiple languages for global events
- **Source variety**: Don't rely solely on high-engagement tweets

### Evidence Quality
- **Multiple capture methods**: Screenshot + JSON + PDF for redundancy
- **Metadata completeness**: Capture all context (thread, profile, media)
- **Chain of custody**: Document every step from discovery to storage
- **Hash verification**: Ensure file integrity with SHA-256
- **Attribution clarity**: Document how evidence was discovered and collected

## 13) Real-World Scenarios

### Scenario 1: Breaking News Verification
**Situation**: Alleged terrorist attack reported on Twitter, need to verify authenticity.

**Approach**:
1. Search: `(attack OR explosion OR shooting) place:"City Name" has:geo has:media -is:retweet since:2025-08-20`
2. Identify earliest tweets with geotagged media
3. Reverse image search all media to check for recycled content
4. Verify user accounts (local residents vs foreign accounts)
5. Cross-reference with news outlets, official sources
6. Map tweet timeline against known event chronology

**Outcome**: Determined incident was real but initial reports exaggerated casualties; identified 3 eyewitnesses with credible geotagged video.

### Scenario 2: Cryptocurrency Scam Investigation
**Situation**: Fake celebrity account promoting crypto giveaway scam.

**Approach**:
1. Search: `from:fake_account (crypto OR bitcoin OR ethereum OR giveaway)`
2. Analyze account: Creation date (2 days old), follower count (purchased bots)
3. Search for victims: `@fake_account (scam OR fraud OR "send back")`
4. Track cryptocurrency addresses: Extract wallet addresses from tweets
5. Blockchain analysis: Trace funds using [[../Techniques/sop-financial-aml-osint|Financial/AML OSINT]]
6. Network mapping: Find coordinated accounts using same template

**Outcome**: Identified scam network of 12 accounts, $48,000 stolen from 63 victims; evidence package submitted to platform and law enforcement.

### Scenario 3: Disinformation Campaign
**Situation**: Coordinated spread of false political narrative ahead of election.

**Approach**:
1. Hashtag analysis: `#campaign_hashtag -is:retweet lang:en`
2. Temporal clustering: Identify unnatural activity spikes
3. Account profiling: Check creation dates, follower patterns
4. Content analysis: Extract identical/near-identical tweets
5. Network mapping: Map retweet chains, identify amplifiers
6. Bot detection: Analyze posting frequency, interaction ratios

**Outcome**: Discovered 200+ bot accounts created within 2-week period, coordinated posting schedule (every 15min), traced to single operator via pattern analysis.

## 14) Emergency Procedures

### Immediate Archival Triggers
- Target account shows signs of deletion (bio changes, follower purge)
- Critical evidence tweet marked as "This tweet is unavailable"
- Account suspension imminent (multiple ToS violations)
- Legal hold requirements (preserve everything immediately)
- Active threat situation (time-sensitive intelligence)

### Rapid Response Protocol
1. **Immediate capture**: Screenshot + archive.is + Wayback Machine
2. **Media download**: All images/videos at full resolution
3. **Thread preservation**: Entire conversation context
4. **Profile snapshot**: Complete bio, media tab, likes (if visible)
5. **Network capture**: Followers/following lists (if accessible)
6. **Notification**: Alert team/client of preservation actions
7. **Documentation**: Record all actions with timestamps

### Escalation Triggers (see [[../Techniques/sop-sensitive-crime-intake-escalation|Sensitive Crime Escalation SOP]])
- **Immediate threats**: Specific threats of violence, suicide, terrorism
- **Child safety**: CSAM, exploitation, grooming indicators
- **Human trafficking**: Recruitment, victim solicitation
- **National security**: Terrorism planning, state threat actors
- **Active harm**: Ongoing crimes, imminent danger to persons

## 15) Related SOPs

- [[../Techniques/sop-legal-ethics|Legal & Ethics SOP]] - Review before every investigation
- [[../Techniques/sop-opsec-plan|OPSEC Planning]] - Protect investigator identity
- [[../Techniques/sop-collection-log|Collection Log]] - Evidence tracking and chain of custody
- [[../Techniques/sop-image-video-osint|Image & Video OSINT]] - Media analysis and geolocation
- [[../Techniques/sop-web-dns-whois-osint|Web/DNS/WHOIS OSINT]] - URL and infrastructure analysis
- [[../Techniques/sop-financial-aml-osint|Financial & AML OSINT]] - Cryptocurrency tracking
- [[../Techniques/sop-entity-dossier|Entity Dossier Building]] - Subject profiling
- [[../Techniques/sop-reporting-packaging-disclosure|Reporting & Disclosure]] - Final report preparation
- [[../Techniques/sop-sensitive-crime-intake-escalation|Sensitive Crime Escalation]] - Law enforcement referral

## 16) External Resources

**Third-Party Tools:**
- Social-Analyzer: https://github.com/qeeqbox/social-analyzer
- Nuclei: https://github.com/projectdiscovery/nuclei-templates
- Nitter Instances: https://github.com/zedeus/nitter/wiki/Instances
- Twint Archive: https://github.com/twintproject/twint

**Training & Guides:**
- Bellingcat Twitter OSINT Guide: https://www.bellingcat.com/resources/how-tos/
- OSINT Framework Twitter Section: https://osintframework.com/
- IntelTechniques Twitter Tools: https://inteltechniques.com/tools/Twitter.html

---

**Last Updated:** 2025-08-24
**Version:** 3.0 (Expanded & Standardized)
**Review Frequency:** Yearly 
