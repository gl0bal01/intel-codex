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
updated: 2025-10-02
---

# Reddit OSINT SOP

## 1) Access & Client Options

- **Web**: https://www.reddit.com/search (basic search interface)
- **Old Reddit**: https://old.reddit.com (legacy interface, sometimes better search)
- **Mobile apps**: iOS/Android (limited search functionality)
- **API access**: Reddit API (requires OAuth, rate limited)
- **Third-party tools**: Pushshift, Reveddit, redditsearch.io
- **Access consideration**: Logged-out vs logged-in (balance visibility vs attribution)

## 2) Search Operators & Syntax

### Basic Operators
- `"exact phrase"` - Exact match search
- `keyword -exclusion` - Exclude terms
- `keyword1 OR keyword2` - Either term
- `(keyword1 OR keyword2) AND keyword3` - Boolean logic
- `author:username` - Posts/comments by specific user
- `subreddit:name` - Search within specific subreddit
- `selfpost:yes` - Text posts only (not links)
- `url:domain.com` - Posts containing specific domain
- `url:"specific-path"` - Posts with specific URL path

### Advanced Operators
- `after:YYYY-MM-DD` - Posts after date
- `before:YYYY-MM-DD` - Posts before date
- `score:>100` - Posts with score greater than 100
- `comments:>50` - Posts with more than 50 comments
- `flair:"flair_name"` - Posts with specific flair
- `flair_name:"AMA"` - Alternative flair syntax
- `nsfw:no` - Exclude NSFW content
- `nsfw:yes` - Include only NSFW content
- `site:reddit.com` - Use in Google for better historical search

### High-Value Combinations
```
subreddit:(news OR worldnews) "breaking" after:2025-01-01
author:username subreddit:politics score:>10
(cryptocurrency OR bitcoin) (scam OR fraud) -is:self
url:suspicious-domain.com comments:>5
```

## 3) Repeatable Workflow

1. **Keyword identification**: Core terms, synonyms, related concepts, slang
2. **Subreddit discovery**: Relevant communities, niche expertise areas
3. **Temporal mapping**: Time-based search for incident correlation
4. **User profiling**: Post/comment history, karma analysis, account age
5. **Thread archaeology**: Deleted/edited content via archives (Pushshift, Reveddit)
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
subreddit:(news OR worldnews OR politics) "breaking" OR "urgent" after:2025-01-10
subreddit:CityName ("incident" OR "emergency" OR "police") after:YYYY-MM-DD
```

**Method**:
1. Identify location-specific subreddits (r/NYC, r/London)
2. Search incident keywords with date filters
3. Sort by "new" for chronological tracking
4. Check comments for eyewitness accounts
5. Cross-reference with local news, Twitter

### Expertise Discovery
**Objective**: Find subject matter experts and professional insights

**Search**:
```
subreddit:(AskExperts OR askscience OR IAmA) "expert in" OR "professional"
subreddit:IndustryName (certification OR licensed OR years experience)
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
subreddit:(investing OR stocks OR wallstreetbets) "CompanyName" score:>10
subreddit:ProductReviews "product_name" (disappointed OR excellent)
```

**Method**:
1. Identify relevant financial/review subreddits
2. Search brand/product mentions with score filters
3. Analyze sentiment in comments (positive/negative ratio)
4. Track sentiment changes over time
5. Identify influencers driving opinion

### Disinformation Tracking
**Objective**: Track false narratives and coordinated campaigns

**Search**:
```
(misinformation OR "fake news" OR debunked) topic_keyword
subreddit:conspiracy "false flag" OR "psyop" specific_event
```

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
- **Pushshift dumps**: Historical Reddit data archives
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
- **Pushshift API**: Historical Reddit data (https://api.pushshift.io)
- **Reveddit**: Deleted comment visualization (https://www.reveddit.com)
- **Unddit** (formerly Removeddit): Deleted content viewer
- **Archive.today**: Manual thread preservation
- **Wayback Machine**: Subreddit/user page historical snapshots
- **API historical search**: Pushshift for deleted posts/comments

### Pushshift API Usage
```bash
# Search deleted comments by user
curl "https://api.pushshift.io/reddit/search/comment/?author=username&size=100"

# Search posts in subreddit by date range
curl "https://api.pushshift.io/reddit/search/submission/?subreddit=name&after=1640995200&before=1643673600"

# Search by keyword
curl "https://api.pushshift.io/reddit/search/submission/?q=keyword&size=100"
```

### Automation & Monitoring
- **PRAW (Python Reddit API Wrapper)**: Automated data collection
- **RSS feeds**: Subreddit/user RSS for real-time monitoring
- **Reddit Stream**: Live comment/post streams
- **Alert bots**: Keyword/user monitoring with notifications
- **Data pipelines**: Automated archival to databases

### PRAW Example
```python
import praw

reddit = praw.Reddit(
    client_id="YOUR_CLIENT_ID",
    client_secret="YOUR_SECRET",
    user_agent="OSINT Tool 1.0"
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
| **Old Reddit**      | Legacy interface, better for some searches | Web      | https://old.reddit.com                  |
| **Pushshift**       | Historical data, deleted content           | API      | https://api.pushshift.io                |
| **Reveddit**        | Deleted content visualization              | Web      | https://www.reveddit.com                |
| **PRAW**            | Python Reddit API wrapper                  | Python   | `pip install praw`                      |
| **Nuclei**          | Username enumeration                       | CLI      | `nuclei -tags osint -var user=username` |
| **Social-Analyzer** | Cross-platform username search             | CLI      | `pip install social-analyzer`           |
| **RedditSearch.io** | Advanced search interface                  | Web      | https://redditsearch.io                 |
| **Wayback Machine** | Historical snapshots                       | Web      | https://web.archive.org                 |

### Reddit API Authentication
```python
# PRAW configuration
import praw

reddit = praw.Reddit(
    client_id="YOUR_CLIENT_ID",        # From reddit.com/prefs/apps
    client_secret="YOUR_CLIENT_SECRET",
    user_agent="OSINT Investigation Tool 1.0 by /u/yourusername"
)

# Read-only access (no login required for public content)
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
- **Rate limiting**: API requests limited (60/minute for OAuth)
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
1. Search crypto subreddits: `subreddit:(CryptoMoonShots OR SatoshiStreetBets) "coin_name"`
2. Identify coordinated posting (same message, multiple users, short timeframe)
3. Check user account ages (mass creation indicates coordination)
4. Extract wallet addresses from posts/comments
5. Track blockchain transactions via [[../Techniques/sop-financial-aml-osint|Financial OSINT]]
6. Document price manipulation timeline
7. Archive all evidence before deletion (posts often removed after pump)

**Outcome**: Identified network of 83 coordinated accounts created within 48 hours; documented $1.2M pump-and-dump scheme; traced crypto wallets to exchange accounts; evidence submitted to SEC resulting in enforcement action.

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

**Outcome**: Post history revealed regular participation in r/Seattle and r/Hiking; timestamped comment mentioned "heading to Rattlesnake Ledge this weekend"; cross-referenced with weather data and trail conditions; provided location lead to search and rescue within 4 hours of report.

### Scenario 3: Disinformation Campaign Attribution
**Situation**: Coordinated disinformation spread across multiple subreddits before election.

**Approach**:
1. Identify narrative: Search for specific false claims across subreddits
2. Map posting patterns: Same content, multiple accounts, timing analysis
3. Account analysis: Creation dates, karma levels, posting history
4. Network mapping: Which users interact, cross-post, coordinate
5. Language analysis: Copy-paste detection, bot-like patterns
6. Archive everything: Pushshift API for comprehensive collection
7. Cross-platform check: Same campaign on Twitter, Facebook?

**Outcome**: Discovered 127 accounts posting identical disinformation across 23 subreddits; accounts created within 3-day period from same IP range (VPN detected); documented 2,400+ false posts reaching 8M+ views; evidence provided to Reddit admins (mass suspension) and election security officials.

## 14) Emergency Procedures

### Immediate Archival Triggers
- User threatens suicide or violence (preserve for authorities)
- Evidence of imminent crime (child exploitation, terrorism, mass violence)
- Thread about to be deleted/locked (capture before removal)
- User announces account deletion
- Subreddit quarantine/ban imminent

### Rapid Response Protocol
1. **Immediate screenshot**: Full thread with URL, timestamp visible
2. **Pushshift backup**: Check if content already archived
3. **Manual archive**: Submit to Archive.today, Wayback Machine
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

## 15) Related SOPs

- [[../Techniques/sop-legal-ethics|Legal & Ethics SOP]] - Review before every investigation
- [[../Techniques/sop-opsec-plan|OPSEC Planning]] - Protect investigator identity
- [[../Techniques/sop-collection-log|Collection Log]] - Evidence tracking and chain of custody
- [[../Techniques/sop-image-video-osint|Image & Video OSINT]] - Analyze media from Reddit posts
- [[../Techniques/sop-web-dns-whois-osint|Web/DNS/WHOIS OSINT]] - Investigate linked domains
- [[../Techniques/sop-financial-aml-osint|Financial & AML OSINT]] - Cryptocurrency tracking
- [[../Techniques/sop-entity-dossier|Entity Dossier Building]] - User profiling
- [[../Techniques/sop-reporting-packaging-disclosure|Reporting & Disclosure]] - Final report preparation
- [[../Techniques/sop-sensitive-crime-intake-escalation|Sensitive Crime Escalation]] - Law enforcement referral

## 16) External Resources

**Official Documentation:**
- Reddit API Documentation: https://www.reddit.com/dev/api
- PRAW Documentation: https://praw.readthedocs.io
- Reddit Rules & Guidelines: https://www.redditinc.com/policies

**Third-Party Tools:**
- Pushshift API: https://api.pushshift.io
- Reveddit: https://www.reveddit.com
- Nuclei Templates: https://github.com/projectdiscovery/nuclei-templates
- Social-Analyzer: https://github.com/qeeqbox/social-analyzer
- PRAW GitHub: https://github.com/praw-dev/praw

**Training & Guides:**
- Bellingcat Reddit OSINT: https://www.bellingcat.com/resources/how-tos/
- OSINT Framework Reddit: https://osintframework.com/
- Reddit Investigations Guide: https://www.reddit.com/r/OSINT/wiki/index

---

**Last Updated:** 2025-10-02
**Version:** 1.0 
**Review Frequency:** Yearly
