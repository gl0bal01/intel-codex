---
type: sop
title: Reddit SOP
description: "Reddit OSINT guide: user history analysis, subreddit investigation, comment tracking & archived content discovery for comprehensive digital investigations."
tags:
  - sop
  - platform
  - reddit
  - social-media
  - osint
created: 2025-10-02
updated: 2026-10-29
---

# Reddit OSINT SOP

> **Authorized OSINT use only.** Investigation accounts must comply with Reddit's [User Agreement](https://redditinc.com/policies/user-agreement) (scraping without Reddit's prior written consent is prohibited; crawling only within robots.txt) and, for API collection, the [Data API Terms](https://redditinc.com/policies/data-api-terms) (exceeding documented call limits can bring a permanent block; delete data not required for your approved use case) [verify 2026-10-18]. Review [[../Techniques/sop-legal-ethics|Legal & Ethics SOP]] and [[../Techniques/sop-opsec-plan|OPSEC Planning SOP]] before any engagement.

## Table of Contents

1. [Access & Client Options](#1-access--client-options)
2. [Search Operators & Syntax](#2-search-operators--syntax)
3. [Repeatable Workflow](#3-repeatable-workflow)
4. [Subreddit Intelligence](#4-subreddit-intelligence)
5. [User Profile Analysis](#5-user-profile-analysis)
6. [Investigation Recipes](#6-investigation-recipes)
7. [Collection & Evidence Integrity](#7-collection--evidence-integrity)
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

- **Web**: https://www.reddit.com/search (basic search interface)
- **Old Reddit**: https://old.reddit.com (legacy interface, sometimes better search). Requires login since July 2026; logged-out browsing still works on www.reddit.com (Reddit Changelog, 9 Jul 2026) [verify 2026-10-29]
- **Mobile apps**: iOS/Android (limited search functionality)
- **API access**: Reddit API (requires OAuth, rate limited) [verify 2026-10-18]
- **Third-party tools**: Arctic Shift, Reveddit
- **Access consideration**: Logged-out vs logged-in (balance visibility vs attribution). In the UK, Reddit asks for a birthdate before mature (NSFW) or restricted content, verifies age via Apple account or Persona, and unverified UK users may have limited anonymous browsing; the Data API blocks traffic without OAuth [verify 2026-10-18]

## 2) Search Operators & Syntax

### Basic Operators
- `"exact phrase"` - Exact match search [verify 2026-10-18]
- `keyword NOT exclusion` - Exclude terms (`AND`/`OR`/`NOT` are case-sensitive; write them uppercase) [verify 2026-10-18]
- `keyword1 OR keyword2` - Either term [verify 2026-10-18]
- `(keyword1 OR keyword2) AND keyword3` - Boolean logic [verify 2026-10-18]
- `author:username` - Posts/comments by specific user [verify 2026-10-18]
- `subreddit:name` - Search within specific subreddit [verify 2026-10-18]
- `self:true` - Text posts only (not links); `self:false` for non-text posts [verify 2026-10-18]
- `url:domain.com` - Posts containing specific domain [verify 2026-10-18]
- `url:"specific-path"` - Posts with specific URL path

### Advanced Operators
- Reddit search has no date-range, score or comment-count operators; narrow by time with the UI time filter (hour, 24 hours, week, month, year, all time), or use Arctic Shift `after=`/`before=` (§8) [verify 2026-10-18]
- `flair:"flair_name"` - Posts with specific flair [verify 2026-10-18]
- `flair:"AMA"` - No space after the colon; wrap multi-word values in quotes [verify 2026-10-18]
- NSFW: there is no `nsfw:` operator; NSFW results depend on the Safe Search toggle, which requires turning on *Show mature (18+) content* in preferences [verify 2026-10-18]
- `site:reddit.com` - Use in Google for better historical search

### High-Value Combinations
```
(subreddit:news OR subreddit:worldnews) "breaking"
author:username subreddit:politics
(cryptocurrency OR bitcoin) (scam OR fraud) self:false
url:suspicious-domain.com
```

## 3) Repeatable Workflow

1. **Keyword identification**: Core terms, synonyms, related concepts, slang
2. **Subreddit discovery**: Relevant communities, niche expertise areas
3. **Temporal mapping**: Time-based search for incident correlation
4. **User profiling**: Post/comment history, karma analysis, account age
5. **Thread archaeology**: Deleted/edited content via archives (Arctic Shift, Reveddit)
6. **Network analysis**: User interactions, cross-posting patterns, mod connections
7. **Content harvesting**: Comments, links, media, embedded content
8. **Cross-platform pivoting**: Usernames, linked profiles, external references
9. **Sentiment analysis**: Community reactions, voting patterns, controversy
10. **Documentation**: Archive critical threads, calculate hashes, log evidence

## 4) Subreddit Intelligence

### Community Analysis
- **Subscriber count**: Size indicators, growth patterns
- **Activity level**: Posts per day, comment frequency
- **Moderation**: Active mods, rule enforcement, ban patterns
- **Content type**: Text-heavy, link sharing, image posts
- **Community culture**: Tone, inside jokes, shared values
- **Geographic focus**: Location-specific or global
- **Topic expertise**: Professional communities, hobbyists, general interest

### Metadata Analysis
- **Creation date**: Subreddit age, historical context
- **Sidebar info**: Rules, related subreddits, external links
- **Moderator list**: Who controls the community
- **Flair system**: Categories, user tags, post classification
- **Wiki content**: Community guidelines, resources, FAQs
- **Automated bots**: AutoModerator rules, custom bots

## 5) User Profile Analysis

### Profile Intelligence
- **Username**: Handle patterns, throwaway indicators, themed names
- **Account age**: Creation date vs first post (dormant accounts)
- **Karma breakdown**: Post vs comment karma, subreddit distribution
- **Trophy case**: Achievements, verified email, Reddit premium
- **Bio/About**: Self-description, social links, external profiles
- **Avatar/banner**: Profile customization, brand indicators

### Activity Patterns
- **Post frequency**: Daily/weekly patterns, activity bursts
- **Comment style**: Length, tone, grammar, vocabulary
- **Subreddit participation**: Communities frequented, expertise areas
- **Posting times**: Timezone indicators, work schedule patterns
- **Content preferences**: Text vs links vs images vs videos
- **Engagement style**: Conversational, argumentative, informative

### Behavioral Indicators
- **Karma farming**: Low-effort reposts, bot-like behavior
- **Throwaway usage**: Single-purpose accounts, confession posts
- **Ban evasion**: New accounts with similar patterns
- **Astroturfing**: Coordinated messaging, brand promotion
- **Expertise claims**: Professional knowledge, insider information
- **Emotional state**: Mental health indicators, crisis signals

## 6) Investigation Recipes

### Incident Monitoring
**Objective**: Track breaking news and real-time events

**Search**:
```
(subreddit:news OR subreddit:worldnews OR subreddit:politics) ("breaking" OR "urgent")
subreddit:CityName ("incident" OR "emergency" OR "police")
```

**Method**:
1. Identify location-specific subreddits (r/NYC, r/London)
2. Search incident keywords with the UI time filter (past hour / 24 hours / week)
3. Sort by "new" for chronological tracking
4. Check comments for eyewitness accounts
5. Cross-reference with local news, Twitter

### Expertise Discovery
**Objective**: Find subject matter experts and professional insights

**Search**:
```
(subreddit:AskExperts OR subreddit:askscience OR subreddit:IAmA) ("expert in" OR "professional")
subreddit:IndustryName (certification OR licensed OR "years experience")
```

**Method**:
1. Search professional subreddits (r/AskHistorians, r/legaladvice)
2. Look for verified AMA posts
3. Check user flair for credentials
4. Review post history for consistency
5. Verify external credentials if provided

### Market Sentiment Analysis
**Objective**: Gauge community opinions on products, stocks, companies

**Search**:
```
(subreddit:investing OR subreddit:stocks OR subreddit:wallstreetbets) "CompanyName"
subreddit:ProductReviews "product_name" (disappointed OR excellent)
```

**Method**:
1. Identify relevant financial/review subreddits
2. Search brand/product mentions, sorted by Top
3. Analyze sentiment in comments (positive/negative ratio)
4. Track sentiment changes over time
5. Identify influencers driving opinion

### Disinformation Tracking
**Objective**: Track false narratives and coordinated campaigns

**Search**:
```
(misinformation OR "fake news" OR debunked) topic_keyword
subreddit:conspiracy ("false flag" OR "psyop") specific_event
```
Group `OR` terms in parentheses: Reddit warns that mixing boolean operators without `()` can give unexpected results [verify 2026-10-18].

**Method**:
1. Search conspiracy/political subreddits for false claims
2. Identify coordinated posting (same users, similar messages)
3. Track narrative evolution and amplification
4. Check debunking subreddits (r/DebunkThis)
5. Document with archives before deletion

## 7) Collection & Evidence Integrity

### Capture Methods
- **Thread archival**: Full thread HTML + JSON via API
- **User profiles**: Complete post/comment history with timestamps
- **Screenshot evidence**: Full context, URL visible, timestamp included
- **Arctic Shift dumps**: Monthly historical Reddit data dumps
- **API extraction**: Automated collection within rate limits
- **Manual documentation**: Critical content transcribed with metadata

### File Organization
```
/Evidence/{{case_id}}/Reddit/
├── YYYYMMDD-HHMM/
│   ├── threads/
│   │   ├── r_subreddit_thread_[ID].html
│   │   ├── r_subreddit_thread_[ID].json
│   │   └── r_subreddit_thread_[ID].png
│   ├── users/
│   │   ├── u_username_profile.json
│   │   ├── u_username_posts.json
│   │   └── u_username_comments.json
│   ├── subreddits/
│   │   └── r_subreddit_info.json
│   └── SHA256SUMS
```

### Hashing & Verification
- Calculate SHA-256 for all captured content immediately
- Store hashes in `SHA256SUMS` file
- Document capture timestamp (UTC), Reddit post/comment ID
- Reference in [[../Techniques/sop-collection-log|Collection Log]]
- Maintain chain of custody documentation

## 8) Advanced Techniques

### Deleted Content Recovery
- **Arctic Shift API**: Historical Reddit data, no auth (https://arctic-shift.photon-reddit.com); Pushshift is now restricted to Reddit moderators for moderation use [verify 2026-10-18]
- **Reveddit**: Mod-removed (not user-deleted) content; user pages compare against what Reddit shows elsewhere, while subreddit/thread views rely on Pushshift, whose terms now limit access to registered Reddit moderators for moderation purposes and which Reveddit's FAQ says can fall behind, miss content or go offline; treat those views as incomplete (https://www.reveddit.com) [verify 2026-10-18]
- **Archive.today**: Manual thread preservation
- **Wayback Machine**: Pre-2025-08 snapshots only (Reddit has blocked Wayback captures of threads, comments and profiles since 2025-08)
- **API historical search**: Arctic Shift for deleted posts/comments (archived at posting time)

### Arctic Shift API Usage
```bash
# Search comments by user (includes since-deleted ones archived at posting time) [verify 2026-10-18]
curl "https://arctic-shift.photon-reddit.com/api/comments/search?author=username&limit=100"

# Search posts in subreddit by date range [verify 2026-10-18]
curl "https://arctic-shift.photon-reddit.com/api/posts/search?subreddit=name&after=2022-01-01&before=2022-02-01&limit=100"

# Search by keyword (keyword search needs subreddit or author) [verify 2026-10-18]
curl "https://arctic-shift.photon-reddit.com/api/posts/search?subreddit=name&query=keyword&limit=100"
```

### Automation & Monitoring

> **Public API closing (per Reddit's Help Center changelog, 2026-10-08):** new public API access requests close 2026-10-31; removal of unregistered apps and users begins 2027-01-12; remaining public API access ends March 2027, with apps moving to the Developer Platform [verify 2026-10-18].

- **PRAW (Python Reddit API Wrapper)**: Automated data collection (PRAW 8.x requires Python ≥ 3.10) [verify 2026-10-18]
- **RSS feeds**: Discontinued by Reddit on 2026-11-13, with no replacement outside communities you moderate; use PRAW streams (`subreddit.stream.submissions()`) while public API access lasts [verify 2026-10-18]
- **Reddit Stream**: Live comment/post streams [verify 2026-10-18]
- **Alert bots**: Keyword/user monitoring with notifications
- **Data pipelines**: Automated archival to databases

### PRAW Example
```python
import praw

reddit = praw.Reddit(
    client_id="YOUR_CLIENT_ID",
    client_secret="YOUR_SECRET",
    user_agent="linux:osint-collector:1.0 (by /u/yourusername)"
)

# Monitor subreddit for keywords
subreddit = reddit.subreddit("news")
for submission in subreddit.stream.submissions():
    if "keyword" in submission.title.lower():
        print(f"Found: {submission.title} - {submission.url}")
```

## 9) Pivoting & Cross-Platform Correlation

### Profile Pivots
- **Username search** → Same handle on other platforms (use Nuclei)
- **Bio links** → Personal websites, social media, professional profiles
- **Email mentions** → In posts/comments, reverse lookup
- **External profiles** → LinkedIn, Twitter, GitHub linked in bio
- **Pattern matching** → Writing style, interests, posting times

### Content Pivots
- **Shared URLs** → Website/domain investigation via [[../Techniques/sop-web-dns-whois-osint|Web OSINT]]
- **Image posts** → Reverse image search, EXIF data extraction
- **Cryptocurrency mentions** → Wallet addresses, transaction tracking
- **Location references** → Geolocation, timezone correlation
- **Phone/email** → Contact information in posts (rare, but occurs)

### Network Pivots
- **Subreddit overlap**: Users active in multiple related communities
- **Comment interactions**: Who they reply to frequently
- **Moderator connections**: Mod teams across subreddits
- **Cross-posting patterns**: Content sharing between communities
- **Vote brigading**: Coordinated upvote/downvote patterns

## 10) Tools & Resources

| Tool                | Purpose                                    | Platform | Access                                  |
| ------------------- | ------------------------------------------ | -------- | --------------------------------------- |
| **Reddit Search**   | Native search interface                    | Web      | https://www.reddit.com/search           |
| **Old Reddit**      | Legacy interface, better for some searches | Web      | https://old.reddit.com (login required since July 2026) [verify 2026-10-29] |
| **Arctic Shift**    | Historical data, deleted content           | API      | https://arctic-shift.photon-reddit.com  |
| **Reveddit**        | Mod-removed (not user-deleted) content     | Web      | https://www.reveddit.com [verify 2026-10-18] |
| **PRAW**            | Python Reddit API wrapper                  | Python   | `pip install praw` (Python ≥ 3.10) [verify 2026-10-18] |
| **Nuclei**          | Username enumeration                       | CLI      | `nuclei -tags osint -esc -var user=username` [verify 2026-10-18] |
| **Social-Analyzer** | Cross-platform username search             | CLI      | `pip install social-analyzer` (PyPI release 0.45 dates from 2022-05; the GitHub repo is newer) [verify 2026-10-18] |
| **Wayback Machine** | Historical snapshots (pre-2025-08 only for Reddit) | Web | https://web.archive.org             |

### Reddit API Authentication
```python
# PRAW configuration
import praw

reddit = praw.Reddit(
    client_id="YOUR_CLIENT_ID",        # From reddit.com/prefs/apps
    client_secret="YOUR_CLIENT_SECRET",
    user_agent="linux:osint-collector:1.0 (by /u/yourusername)"
)

# Read-only access (no login required for public content) [verify 2026-10-18]
for submission in reddit.subreddit("news").hot(limit=10):
    print(submission.title)
```

## 11) Risks & Limitations

- **Deleted content**: Posts/comments removed by users/mods (use archives)
- **Shadowbanned users**: Content invisible to others but visible to user
- **Vote manipulation**: Upvotes/downvotes don't reflect true sentiment
- **Bot accounts**: Automated posting creates noise in data
- **Throwaway accounts**: Single-use accounts for anonymity
- **Subreddit bans**: Investigation accounts may be banned
- **Rate limiting**: 100 queries per minute per OAuth client id, averaged over a 10-minute window; API traffic without OAuth is blocked [verify 2026-10-18]
- **Privacy focus**: Reddit increasingly restricts data access
- **Deleted subreddits**: Entire communities can disappear
- **Edit history**: Users can edit posts without showing original (archives help)

## 12) Quality Assurance & Verification

### Content Verification
- **Cross-reference sources**: Verify claims with external evidence
- **Check user history**: Consistent expertise or karma farming?
- **Account age**: New accounts less credible for breaking news
- **Subreddit context**: Is community known for satire, misinformation?
- **Voting patterns**: Heavily downvoted may indicate false claims

### Bias Mitigation
- **Subreddit echo chambers**: Communities reinforce existing beliefs
- **Voting bias**: Popular ≠ accurate or representative
- **Demographic skew**: Reddit users not representative of general population
- **Temporal bias**: Recent content prioritized in search
- **Algorithm impact**: "Hot" and "Best" sorting affect visibility

### Evidence Quality
- **Multiple capture methods**: Screenshot + JSON + archive for redundancy
- **Metadata completeness**: Capture timestamps, IDs, vote counts
- **Context preservation**: Include parent comments, thread structure
- **Chain of custody**: Document all collection steps
- **Source attribution**: Reddit post ID, permalink, username, subreddit

## 13) Real-World Scenarios

### Scenario 1: Financial Fraud Investigation
**Situation**: Pump-and-dump cryptocurrency scheme coordinated on Reddit.

**Approach**:
1. Search crypto subreddits: `(subreddit:CryptoMoonShots OR subreddit:SatoshiStreetBets) "coin_name"`
2. Identify coordinated posting (same message, multiple users, short timeframe)
3. Check user account ages (mass creation indicates coordination)
4. Extract wallet addresses from posts/comments
5. Track blockchain transactions via [[../Techniques/sop-financial-aml-osint|Financial OSINT]]
6. Document price manipulation timeline
7. Archive all evidence before deletion (posts often removed after pump)

**Illustrative outcome (fictional)**: Identified network of 83 coordinated accounts created within 48 hours; documented $1.2M pump-and-dump scheme; traced crypto wallets to exchange accounts; evidence submitted to SEC resulting in enforcement action.

### Scenario 2: Missing Person Location Intelligence
**Situation**: Missing person known to be active on Reddit, searching for location clues.

**Approach**:
1. Search user's post history for location references
2. Analyze posting times for timezone indicators
3. Check subreddit participation (local city/region subreddits)
4. Review comments for personal details (workplace, hangouts, routines)
5. Examine image posts for geolocation via [[../Techniques/sop-image-video-osint|Image OSINT]]
6. Cross-reference with other platforms (same username search)
7. Contact moderators of relevant subreddits if appropriate

**Illustrative outcome (fictional)**: Post history revealed regular participation in r/Seattle and r/Hiking; timestamped comment mentioned "heading to Rattlesnake Ledge this weekend"; cross-referenced with weather data and trail conditions; provided location lead to search and rescue within 4 hours of report.

### Scenario 3: Disinformation Campaign Attribution
**Situation**: Coordinated disinformation spread across multiple subreddits before election.

**Approach**:
1. Identify narrative: Search for specific false claims across subreddits
2. Map posting patterns: Same content, multiple accounts, timing analysis
3. Account analysis: Creation dates, karma levels, posting history
4. Network mapping: Which users interact, cross-post, coordinate
5. Language analysis: Copy-paste detection, bot-like patterns
6. Archive everything: Arctic Shift API for comprehensive collection
7. Cross-platform check: Same campaign on Twitter, Facebook?

**Illustrative outcome (fictional)**: Discovered 127 accounts posting identical disinformation across 23 subreddits; accounts created within 3-day period from same IP range (VPN detected); documented 2,400+ false posts reaching 8M+ views; evidence provided to Reddit admins (mass suspension) and election security officials.

## 14) Emergency Procedures

### Immediate Archival Triggers
- User threatens suicide or violence (preserve for authorities)
- Evidence of imminent crime (child exploitation, terrorism, mass violence)
- Thread about to be deleted/locked (capture before removal)
- User announces account deletion
- Subreddit quarantine/ban imminent

### Rapid Response Protocol
1. **Immediate screenshot**: Full thread with URL, timestamp visible
2. **Arctic Shift backup**: Check if content already archived
3. **Manual archive**: Submit to Archive.today (Reddit has blocked Wayback Machine captures of threads, comments and profiles since 2025-08)
4. **API extraction**: Use PRAW to pull JSON data immediately
5. **User profile capture**: Full post/comment history
6. **Related content**: Check user's other posts, crossposted threads
7. **Hash calculation**: SHA-256 for all files
8. **Documentation**: Log all actions with timestamps

### Escalation Triggers (see [[../Techniques/sop-sensitive-crime-intake-escalation|Sensitive Crime Escalation SOP]])
- **Suicide threats**: Immediate welfare check required
- **Child safety**: CSAM, exploitation, grooming (NCMEC report)
- **Imminent violence**: Specific threats, attack planning (FBI, local police)
- **Terrorism**: Plots, recruitment, propaganda (FBI, DHS)
- **Human trafficking**: Victim indicators, recruitment posts

### Legal Process & Preservation
- **Preservation**: Reddit preserves account records for 90 days by default pending legal process, extendable by a further 90 days on a written extension request (submit at least 7 days before expiry); requests must be signed, on law-enforcement letterhead, and identify the u/username(s), records, relevant post/comment URLs and timeframe [verify 2026-10-18]
- **Submission**: Guidelines for Law Enforcement (https://redditinc.com/policies/guideline-for-law-enforcement), law enforcement and government agencies only; submit via the Reddit Legal Request Portal (https://legalrequests.reddithelp.com/hc/en-us), which also hosts the Emergency Disclosure Form for imminent threats to life [verify 2026-10-18]
- **User notice**: Reddit attempts to notify users of legal requests for their account information unless legally prohibited or in exceptional emergency, exigent or counterproductive circumstances (such as certain child-safety or terrorism investigations); time-limited non-disclosure orders delay notice until expiry. Users are not notified of preservation requests in the ordinary course. Factor this into referral timing [verify 2026-10-18]
- **Non-government parties**: Follow Reddit's civil and non-government request guidelines (https://support.reddithelp.com/hc/en-us/articles/12793653507860-Guidelines-for-civil-and-non-government-legal-requests-for-account-information); refer criminal matters via [[../Techniques/sop-sensitive-crime-intake-escalation|Sensitive Crime Intake & Escalation]] [verify 2026-10-18]
- **Transparency**: Reddit's biannual Transparency Report (https://redditinc.com/transparency) covers legal requests from governments, law enforcement and third parties to remove content or disclose user data [verify 2026-10-18]
- Review [[../Techniques/sop-legal-ethics|Legal & Ethics]] before any request or referral

## 15) Legal & Ethical Considerations

> The canonical source for legal posture is [[../Techniques/sop-legal-ethics|Legal & Ethics SOP]]. Never re-derive it here.

- **Platform ToS**: Reddit's [User Agreement](https://redditinc.com/policies/user-agreement) (effective 2026-07-01) bars accessing, searching or collecting data by any means except as it permits or under a separate agreement; crawling is conditionally allowed within robots.txt, but scraping without Reddit's prior written consent is prohibited. The [Data API Terms](https://redditinc.com/policies/data-api-terms) bar exceeding documented call limits (Reddit may permanently block access), retaining data beyond your approved use case, and training AI models on user content without rightsholder permission [verify 2026-10-18]. Plan for the public API closure dates in §8.
- **Legal process**: preservation, disclosure and user-notice rules follow [Legal Process & Preservation](#legal-process--preservation) under §14; do not duplicate them here.
- **Sensitive-crime routing**: CSAM, threat-to-life, trafficking, terrorism content found during OSINT triggers immediate hard-stop and routing per [[../Techniques/sop-sensitive-crime-intake-escalation|Sensitive Crime Escalation SOP]]. Do not download or further analyze CSAM; preserve URL + timestamp only and report to NCMEC (US) / IWF (UK) / national equivalent.
- **OPSEC**: investigation accounts, their email, OAuth app credentials and devices must be isolated from the analyst's personal identity per [[../Techniques/sop-opsec-plan|OPSEC Planning SOP]]. UK age verification (Apple account or Persona, §1) can link the persona to a real identity.

## 16) Related SOPs

- [[../Techniques/sop-legal-ethics|Legal & Ethics SOP]] - Review before every investigation
- [[../Techniques/sop-opsec-plan|OPSEC Planning]] - Protect investigator identity
- [[../Techniques/sop-collection-log|Collection Log]] - Evidence tracking and chain of custody
- [[../Techniques/sop-image-video-osint|Image & Video OSINT]] - Analyze media from Reddit posts
- [[../Techniques/sop-web-dns-whois-osint|Web/DNS/WHOIS OSINT]] - Investigate linked domains
- [[../Techniques/sop-financial-aml-osint|Financial & AML OSINT]] - Cryptocurrency tracking
- [[../Techniques/sop-entity-dossier|Entity Dossier Building]] - User profiling
- [[../Techniques/sop-reporting-packaging-disclosure|Reporting & Disclosure]] - Final report preparation
- [[../Techniques/sop-sensitive-crime-intake-escalation|Sensitive Crime Escalation]] - Law enforcement referral

## 17) External Resources

**Official Documentation:**
- Reddit API Documentation: https://www.reddit.com/dev/api
- PRAW Documentation: https://praw.readthedocs.io [verify 2026-10-18]
- Reddit Rules & Guidelines: https://www.redditinc.com/policies
- Reddit Guidelines for Law Enforcement: https://redditinc.com/policies/guideline-for-law-enforcement [verify 2026-10-18]
- Reddit Legal Requests Overview: https://support.reddithelp.com/hc/en-us/articles/50446339398804-Legal-requests-overview-for-Reddit-users [verify 2026-10-18]
- Reddit Transparency Report: https://redditinc.com/transparency [verify 2026-10-18]

**Third-Party Tools:**
- Arctic Shift API: https://arctic-shift.photon-reddit.com
- Reveddit: https://www.reveddit.com
- Nuclei Templates: https://github.com/projectdiscovery/nuclei-templates
- Social-Analyzer: https://github.com/qeeqbox/social-analyzer [verify 2026-10-18]
- PRAW GitHub: https://github.com/praw-dev/praw

**Training & Guides:**
- Bellingcat How-To Guides (general): https://www.bellingcat.com/resources/how-tos/ [verify 2026-10-18]
- OSINT Framework Reddit: https://osintframework.com/ [verify 2026-10-18]
- Reddit Investigations Guide: https://www.reddit.com/r/OSINT/wiki/index

---

**Last Updated:** 2026-10-29
**Version:** 1.0
**Review Frequency:** Yearly
