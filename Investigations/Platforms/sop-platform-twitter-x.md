---
type: sop
title: Twitter/X SOP
description: "Master Twitter/X OSINT: profile analysis, tweet collection, advanced search operators, account verification & follower investigation for threat intelligence."
tags:
  - sop
  - platform
  - twitter
  - x
  - social-media
  - osint
created: 2023-02-05
updated: 2026-10-18
---

# Twitter/X OSINT SOP

> **Authorized OSINT use only.** Investigation accounts must comply with X's [Terms of Service](https://x.com/en/tos), which permit access only through X's currently available, published interfaces and expressly prohibit crawling or scraping in any form without X's prior written consent [verify 2026-10-18]. Review [[../Techniques/sop-legal-ethics|Legal & Ethics SOP]] and [[../Techniques/sop-opsec-plan|OPSEC Planning SOP]] before any engagement.

## Table of Contents

1. [Access & Client Options](#1-access--client-options)
2. [Search Operators & Syntax](#2-search-operators--syntax)
3. [Repeatable Workflow](#3-repeatable-workflow)
4. [User Profile Analysis](#4-user-profile-analysis)
5. [Advanced Search Techniques](#5-advanced-search-techniques)
6. [Investigation Recipes (Copy/Paste)](#6-investigation-recipes-copypaste)
7. [API-Based Collection](#7-api-based-collection)
8. [Collection & Evidence Integrity](#8-collection--evidence-integrity)
9. [Pivoting & Cross-Platform Correlation](#9-pivoting--cross-platform-correlation)
10. [Tools & Resources](#10-tools--resources)
11. [Risks & Limitations](#11-risks--limitations)
12. [Advanced Techniques](#12-advanced-techniques)
13. [Quality Assurance & Verification](#13-quality-assurance--verification)
14. [Real-World Scenarios](#14-real-world-scenarios)
15. [Emergency Procedures](#15-emergency-procedures)
16. [Legal & Ethical Considerations](#16-legal--ethical-considerations)
17. [Related SOPs](#17-related-sops)
18. [External Resources](#18-external-resources)

## 1) Access & Client Options

- **Web**: https://x.com/search-advanced (GUI; available only when logged in) [verify 2026-10-18]
- **Direct search**: https://x.com/search?q=<query>
- **Mobile apps**: iOS/Android (different rate limits, stronger fingerprinting)
- **API access**: X API v2 https://docs.x.com/x-api/introduction [verify 2026-10-18]
- **Access consideration**: Plan for a logged-in persona account per [[../Techniques/sop-opsec-plan|OPSEC Planning]]; advanced search needs a login and X has restricted logged-out viewing since mid-2023 (press reports), so there is no dependable logged-out collection path

## 2) Search Operators & Syntax

### Basic Operators (web search and API)
- `"exact phrase"` - Exact match search
- `keyword1 keyword2` - AND logic (both must appear)
- `keyword1 OR keyword2` - Either term
- `-keyword` - Exclude term
- `#hashtag` - Hashtag search
- `@username` - Mentions of user
- `from:username` - Tweets from specific user
- `to:username` - Replies to specific user

### Web Search Operators (x.com only)
- `since:YYYY-MM-DD until:YYYY-MM-DD` - Date range (API: use the `start_time`/`end_time` parameters) [verify 2026-10-18]
- `near:city within:10km` - Geotagged posts near a place, e.g. `fire near:san-francisco within:10km` [verify 2026-10-18]
- `min_retweets:10` / `min_faves:100` - Minimum reposts / likes (web names; the API rejects them with a 400, use `min_reposts:` / `min_likes:`) [verify 2026-10-18]

### API Query Operators (`/2/tweets/search/*`)
X's help centre does not document `place:`, `has:geo`, `is:verified`, `context:` or `url:` for web search; treat them as API operators.
- `lang:en` - Language filter (en, fr, es, de, etc.) [verify 2026-10-18]
- `place:"Paris, France"` - Location-tagged tweets [verify 2026-10-18]
- `has:geo` - Geo-tagged content only [verify 2026-10-18]
- `has:images` / `has:video_link` / `has:links` - Media filters (native video is `has:video_link`; there is no `has:videos`) [verify 2026-10-18]
- `is:retweet` / `-is:retweet` - Include/exclude retweets [verify 2026-10-18]
- `is:reply` / `-is:reply` - Include/exclude replies [verify 2026-10-18]
- `is:verified` - From verified accounts only [verify 2026-10-18]
- `url:domain.com` - Tweets containing specific domain [verify 2026-10-18]
- `url:"/specific-path"` - URL path fragment (untested: X documents `url:` only as a tokenized match on the `url`/`expanded_url` fields, with full-URL examples such as `url:"https://developer.x.com"`) [verify 2026-10-18]
- `min_reposts:10` / `min_likes:100` - Minimum reposts / likes (API names) [verify 2026-10-18]
- `min_replies:5` - Minimum reply count [verify 2026-10-18]
- `context:123.456` - Event/trend context (when known) [verify 2026-10-18]

### High-Value Combinations
Written for x.com search. For the API, replace `since:`/`until:` with `start_time`/`end_time` and `min_retweets:`/`min_faves:` with `min_reposts:`/`min_likes:`.
- `"(exact phrase)" lang:en -is:retweet -is:reply` - Original content only
- `from:user since:YYYY-MM-DD until:YYYY-MM-DD` - User timeline slice
- `(@handle OR "real name") (scam OR fraud) -is:retweet` - Scam mentions
- `near:city-name within:10km filter:images` - Geolocated visual content
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
- **Verification status**: blue = active X Premium subscription, not ID verification (ID verification is a separate "ID verified" label); gold = official organization via Premium Business; grey = government, multilateral organization or official; affiliation badge = linked to an organization. In the API read `verified_type` (blue, government, business or none) [verify 2026-10-18]

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
- **Crisis monitoring**: `("breaking" OR "urgent") near:city within:10km since:YYYY-MM-DD` (web syntax; X documents `place:` only for the API) [verify 2026-10-18]
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

Written for x.com search; for the API apply the swaps in §2 (`start_time`/`end_time`, `min_reposts:`/`min_likes:`).

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
near:specific-location within:1km filter:images since:YYYY-MM-DD until:YYYY-MM-DD
```

### Influencer Campaign Tracking
```
#campaignhashtag -is:retweet min_faves:100 lang:en
```

### Breaking News Discovery
```
(breaking OR urgent OR "just happened") has:images -is:retweet lang:en
```

## 7) API-Based Collection

### Twitter/X API v2 Setup

**Pricing (pay-per-usage, no subscriptions):**
- **Credits**: Bought upfront in the Developer Console (https://console.x.com); requests are blocked while the balance is negative [verify 2026-10-18]
- **Read prices**: Post $0.005/resource, User $0.010/resource, Followers/Following $0.010/resource; resources deduplicated within a 24h UTC day (soft guarantee) [verify 2026-10-18]
- **Volume cap**: 3M Post reads per monthly billing cycle; Enterprise plan above that [verify 2026-10-18]
- **Search**: Recent search (7 days) available to all developers; full-archive search to pay-per-use and Enterprise customers [verify 2026-10-18]

**API Key Setup:**
```bash
# Get API keys from: https://console.x.com (Developer Console → New App; credentials are shown only once) [verify 2026-10-18]
# Store in environment variables (never hardcode!)
export TWITTER_BEARER_TOKEN="your_bearer_token_here"
export TWITTER_API_KEY="your_api_key"
export TWITTER_API_SECRET="your_api_secret"
```

### User Profile Collection

**Get User by Username:**
```bash
# Basic profile information [verify 2026-10-18]
curl -X GET "https://api.x.com/2/users/by/username/crypto_alex" \
     -H "Authorization: Bearer $TWITTER_BEARER_TOKEN" \
     -H "Content-Type: application/json" \
     > twitter_user_profile_$(date +%Y%m%d_%H%M%S).json

# Enhanced profile with all fields [verify 2026-10-18]
curl -X GET "https://api.x.com/2/users/by/username/crypto_alex?user.fields=created_at,description,entities,id,location,name,pinned_tweet_id,profile_image_url,protected,public_metrics,url,username,verified,verified_type,withheld" \
     -H "Authorization: Bearer $TWITTER_BEARER_TOKEN" \
     > twitter_user_full_$(date +%Y%m%d_%H%M%S).json
```

**Get User by ID:**
```bash
curl -X GET "https://api.x.com/2/users/USER_ID?user.fields=created_at,description,location,public_metrics,verified" \
     -H "Authorization: Bearer $TWITTER_BEARER_TOKEN" \
     > twitter_user_id_$(date +%Y%m%d_%H%M%S).json
```

### Tweet Collection

**Get User's Tweets (Timeline):**
```bash
# Recent tweets (up to the 3,200 most recent) [verify 2026-10-18]
curl -X GET "https://api.x.com/2/users/USER_ID/tweets?max_results=100&tweet.fields=created_at,author_id,conversation_id,public_metrics,referenced_tweets,entities,geo,in_reply_to_user_id,lang,source&expansions=author_id,referenced_tweets.id,attachments.media_keys&media.fields=url,preview_image_url,type,duration_ms,variants" \
     -H "Authorization: Bearer $TWITTER_BEARER_TOKEN" \
     > twitter_tweets_$(date +%Y%m%d_%H%M%S).json

# Pagination for large datasets
curl -X GET "https://api.x.com/2/users/USER_ID/tweets?max_results=100&pagination_token=NEXT_TOKEN" \
     -H "Authorization: Bearer $TWITTER_BEARER_TOKEN" \
     >> twitter_tweets_page2_$(date +%Y%m%d_%H%M%S).json
```

**Get Specific Tweet:**
```bash
curl -X GET "https://api.x.com/2/tweets/TWEET_ID?tweet.fields=created_at,text,author_id,public_metrics,entities,geo,lang&expansions=author_id,attachments.media_keys&media.fields=url,type,preview_image_url" \
     -H "Authorization: Bearer $TWITTER_BEARER_TOKEN" \
     > tweet_$(date +%Y%m%d_%H%M%S).json
```

**Search Recent Tweets:**
```bash
# Search tweets from last 7 days (available to all developers) [verify 2026-10-18]
curl -X GET "https://api.x.com/2/tweets/search/recent?query=from:username%20-is:retweet&max_results=100&tweet.fields=created_at,public_metrics,entities&expansions=author_id" \
     -H "Authorization: Bearer $TWITTER_BEARER_TOKEN" \
     > twitter_search_$(date +%Y%m%d_%H%M%S).json

# URL-encoded query example: "crypto scam" lang:en -is:retweet
QUERY=$(echo '"crypto scam" lang:en -is:retweet' | jq -sRr @uri)
curl -X GET "https://api.x.com/2/tweets/search/recent?query=$QUERY&max_results=100" \
     -H "Authorization: Bearer $TWITTER_BEARER_TOKEN" \
     > twitter_search_crypto_$(date +%Y%m%d_%H%M%S).json
```

**Full Archive Search (pay-per-use and Enterprise):**
```bash
# Search all historical tweets; bound dates with start_time/end_time (since:/until: are web-only) [verify 2026-10-18]
curl -X GET "https://api.x.com/2/tweets/search/all?query=from:username&start_time=2020-01-01T00:00:00Z&end_time=2025-01-01T00:00:00Z&max_results=500&tweet.fields=created_at,public_metrics,entities,geo,lang" \
     -H "Authorization: Bearer $TWITTER_BEARER_TOKEN" \
     > twitter_archive_search_$(date +%Y%m%d_%H%M%S).json
```

### Follower/Following Analysis

**Get Followers:**
```bash
curl -X GET "https://api.x.com/2/users/USER_ID/followers?max_results=1000&user.fields=created_at,description,public_metrics,verified" \
     -H "Authorization: Bearer $TWITTER_BEARER_TOKEN" \
     > twitter_followers_$(date +%Y%m%d_%H%M%S).json
```

**Get Following:**
```bash
curl -X GET "https://api.x.com/2/users/USER_ID/following?max_results=1000&user.fields=created_at,public_metrics,verified" \
     -H "Authorization: Bearer $TWITTER_BEARER_TOKEN" \
     > twitter_following_$(date +%Y%m%d_%H%M%S).json
```

### Media Download

**Extract Media URLs from JSON:**
```bash
# Extract image URLs from API response
jq -r '.data[].attachments.media_keys[]' twitter_tweets.json

# Download media files
jq -r '.includes.media[] | select(.type=="photo") | .url' twitter_tweets.json | while read URL; do
    wget "$URL" -P media/
done

# Download videos (extract video URLs; needs media.fields=variants) [verify 2026-10-18]
jq -r '.includes.media[] | select(.type=="video") | .variants[] | select(.content_type=="video/mp4") | .url' twitter_tweets.json | while read URL; do
    wget "$URL" -P media/
done
```

### Rate Limit Handling

**Check Rate Limit Status:**
```bash
curl -X GET "https://api.x.com/2/users/by/username/twitter" \
     -H "Authorization: Bearer $TWITTER_BEARER_TOKEN" \
     -I | grep -i "x-rate-limit"

# Output:
# x-rate-limit-limit: 300 [verify 2026-10-18]
# x-rate-limit-remaining: 299
# x-rate-limit-reset: 1672531200
```

**Rate Limit Aware Script:**
```bash
#!/bin/bash
# twitter_api_safe.sh - Respects rate limits

BEARER_TOKEN="$TWITTER_BEARER_TOKEN"
USER_ID="$1"

# Check remaining rate limit
REMAINING=$(curl -s -I -X GET "https://api.x.com/2/users/$USER_ID" \
    -H "Authorization: Bearer $BEARER_TOKEN" | grep -i "x-rate-limit-remaining" | awk '{print $2}' | tr -d '\r')

if [ "$REMAINING" -lt 10 ]; then
    echo "⚠️ Rate limit low ($REMAINING remaining). Pausing 15 minutes..."
    sleep 900
fi

# Proceed with request
curl -X GET "https://api.x.com/2/users/$USER_ID/tweets?max_results=100" \
    -H "Authorization: Bearer $BEARER_TOKEN" \
    > tweets_$(date +%Y%m%d_%H%M%S).json
```

### Python API Collection Script

**Using Tweepy Library:**
```python
#!/usr/bin/env python3
# twitter_collector.py - Automated collection with Tweepy

import tweepy
import json
from datetime import datetime, timezone

# Authentication
BEARER_TOKEN = "your_bearer_token_here"
client = tweepy.Client(bearer_token=BEARER_TOKEN)

# Collect user tweets
def collect_user_tweets(username, max_results=100):
    user = client.get_user(username=username)
    user_id = user.data.id

    tweets = client.get_users_tweets(
        id=user_id,
        max_results=max_results,
        tweet_fields=['created_at', 'public_metrics', 'entities', 'geo'],
        expansions=['author_id', 'attachments.media_keys'],
        media_fields=['url', 'type', 'preview_image_url']
    )

    timestamp = datetime.now(timezone.utc).strftime('%Y%m%d_%H%M%S')
    filename = f'twitter_tweets_{username}_{timestamp}.json'

    with open(filename, 'w') as f:
        json.dump({
            'user': user.data.__dict__,
            'tweets': [tweet.data for tweet in tweets.data]
        }, f, indent=2, default=str)

    print(f"✓ Collected {len(tweets.data)} tweets → {filename}")

# Search tweets
def search_tweets(query, max_results=100):
    tweets = client.search_recent_tweets(
        query=query,
        max_results=max_results,
        tweet_fields=['created_at', 'author_id', 'public_metrics', 'entities']
    )

    timestamp = datetime.now(timezone.utc).strftime('%Y%m%d_%H%M%S')
    filename = f'twitter_search_{timestamp}.json'

    with open(filename, 'w') as f:
        json.dump([tweet.data for tweet in tweets.data], f, indent=2, default=str)

    print(f"✓ Search complete: {len(tweets.data)} results → {filename}")

if __name__ == "__main__":
    # Example usage
    collect_user_tweets("crypto_alex", max_results=100)
    search_tweets('"scam" lang:en -is:retweet', max_results=100)
```

### API Query Examples

**Complex Search Queries:**
```bash
# Cryptocurrency scam mentions
QUERY="(bitcoin OR ethereum OR crypto) (scam OR fraud OR \"send back\") -is:retweet lang:en"
curl -X GET "https://api.x.com/2/tweets/search/recent?query=$(echo $QUERY | jq -sRr @uri)&max_results=100" \
     -H "Authorization: Bearer $TWITTER_BEARER_TOKEN"

# Geotagged tweets in specific location
QUERY="place:\"New York City\" has:geo has:images -is:retweet"
curl -X GET "https://api.x.com/2/tweets/search/recent?query=$(echo $QUERY | jq -sRr @uri)" \
     -H "Authorization: Bearer $TWITTER_BEARER_TOKEN"

# High-engagement tweets about specific topic (API: min_reposts:/min_likes:; web-only min_retweets:/min_faves: return 400) [verify 2026-10-18]
QUERY="Ukraine min_reposts:100 -is:retweet lang:en has:links"
curl -X GET "https://api.x.com/2/tweets/search/recent?query=$(echo $QUERY | jq -sRr @uri)" \
     -H "Authorization: Bearer $TWITTER_BEARER_TOKEN"
```

### Evidence Packaging (API Data)

**Hash Calculation:**
```bash
# Calculate SHA-256 hash for API JSON response
sha256sum twitter_tweets_20251005_143022.json > twitter_tweets_20251005_143022.json.sha256

# Batch hash all JSON files
find . -name "*.json" -type f -exec sha256sum {} \; > MANIFEST_SHA256SUMS.txt
```

**Metadata Extraction:**
```bash
# Extract key metadata from JSON
jq '{
  collection_timestamp: now | strftime("%Y-%m-%d %H:%M:%S UTC"),
  user_id: .data[0].author_id,
  tweet_count: (.data | length),
  date_range: {
    earliest: (.data | min_by(.created_at) | .created_at),
    latest: (.data | max_by(.created_at) | .created_at)
  },
  total_engagement: (.data | map(.public_metrics.retweet_count + .public_metrics.like_count) | add)
}' twitter_tweets.json > metadata.json
```

### API Best Practices

**1. Always log requests:**
```bash
# Log all API calls for reproducibility
echo "$(date -u): GET /users/by/username/crypto_alex" >> api_requests.log
```

**2. Store credentials securely:**
```bash
# Use environment variables, never hardcode
export TWITTER_BEARER_TOKEN=$(cat ~/.twitter_api_token)

# Or use credential manager
# Windows: Credential Manager
# Linux: gnome-keyring, pass
# macOS: Keychain
```

**3. Respect rate limits:**
- Track credit balance; requests are blocked when the balance goes negative [verify 2026-10-18]
- Track usage to avoid hitting limits mid-investigation
- Implement backoff/retry logic

**4. Preserve raw responses:**
```bash
# Always save raw JSON before processing
curl [...] | tee raw_response.json | jq '.' > processed_response.json
```

**5. Document API version:**
```bash
# Include API version in filenames/logs
# twitter_v2_tweets_20251005.json (not twitter_tweets_20251005.json)
```

## 8) Collection & Evidence Integrity

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

## 9) Pivoting & Cross-Platform Correlation

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

## 10) Tools & Resources

| Tool                        | Purpose                            | Platform    | Access                                                |
| --------------------------- | ---------------------------------- | ----------- | ----------------------------------------------------- |
| **Twitter Advanced Search** | Native search interface            | Web         | https://x.com/search-advanced (login required) [verify 2026-10-18] |
| **Nitter**                  | Privacy-focused Twitter frontend   | Web         | Archived Oct 2026; remaining community instances are unsupported and may disappear [verify 2026-10-18] |
| **Twint**                   | Twitter scraping (archived tweets) | CLI         | `pip install twint` (repo archived Feb 2023, unmaintained; historical reference only) [verify 2026-10-18] |
| **X API v2**                | Programmatic access                | API         | https://docs.x.com/x-api/introduction [verify 2026-10-18] |
| **Wayback Machine**         | Historical Twitter snapshots       | Web         | https://web.archive.org                               |
| **Social-Analyzer**         | Username enumeration               | CLI         | `pip install social-analyzer` [verify 2026-10-18] |
| **Nuclei**                  | Username search across platforms   | CLI         | `nuclei -tags osint -esc -var user=username` (user-enumeration templates are self-contained; `-esc` loads them) [verify 2026-10-18] |
| **ExifTool**                | Image metadata extraction          | CLI         | `exiftool image.jpg`                                  |
| **Gephi**                   | Network visualization              | Desktop     | https://gephi.org [verify 2026-10-18] |

## 11) Risks & Limitations

- **De-indexing**: Tweets may disappear post-capture, archive immediately
- **Account suspension**: Targets may delete or be suspended during investigation
- **API changes**: Frequent policy/pricing changes affect tooling
- **Shadow banning**: Content hidden from search without notification
- **Algorithm bias**: "Top" results prioritize engagement over relevance
- **Self-reported data**: Location, bio information often unreliable
- **Automated accounts**: Bots, scrapers create noise in results
- **Deleted content**: Historical data gaps from account deletions
- **Media manipulation**: Deepfakes, edited images, misleading captions

## 12) Advanced Techniques

### Deleted Content Recovery
- **Archive.org Wayback Machine**: Historical snapshots of profiles/tweets
- **Third-party archives**: Archive.today, Archive.is manual captures
- **API historical access**: Batch compliance endpoints only report a Post ID's status (e.g. deleted); X documents no way to retrieve deleted content through the API [verify 2026-10-18]
- **Screenshot databases**: Politwoops (ProPublica US archive no longer maintained, last updated Nov 2022), Trump Twitter Archive https://www.thetrumparchive.com [verify 2026-10-18]

### Automation & Monitoring
- **IFTTT/Zapier**: Automated alerts for specific keywords/accounts
- **Python scripts**: Custom scrapers using Selenium/BeautifulSoup
- **X Activity API** (replaces the deprecated Account Activity API): create subscriptions with `POST /2/activity/subscriptions`, receive events via `GET /2/activity/stream` or webhook; public events (post creation/deletion, profile updates) for any public account by user ID, private events (likes, DMs, mentions, reposts) only for users who authorized your app; protected accounts' posts are not delivered; self-serve cap 1,500 subscriptions [verify 2026-10-18]

### Network Analysis
- **Follower/following exports**: Bulk relationship data collection
- **Interaction matrices**: Map reply/retweet relationships
- **Community detection**: Identify clusters in network graphs
- **Influence metrics**: Calculate centrality, reach, amplification
- **Bot detection**: Identify automated/coordinated accounts

## 13) Quality Assurance & Verification

### Content Verification
- **Cross-reference sources**: Verify with non-Twitter evidence
- **Reverse image search**: Confirm media originality
- **Timestamp validation**: Check tweet time vs claimed events
- **Geolocation verification**: Match location claims with visual evidence
- **Account authentication**: Treat a blue check as a paid subscription, not identity verification; check `verified_type` and affiliation badges, look for impersonators [verify 2026-10-18]

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

## 14) Real-World Scenarios

### Scenario 1: Breaking News Verification
**Situation**: Alleged terrorist attack reported on Twitter, need to verify authenticity.

**Approach**:
1. Search: `(attack OR explosion OR shooting) near:city-name within:10km filter:media -is:retweet since:2025-08-20`
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

## 15) Emergency Procedures

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

### Legal Process & Preservation
- **Preservation**: X preserves, but does not disclose, a temporary snapshot of account records for 90 days pending valid legal process; request extensions as a separate submission at least 7 days before expiry (not guaranteed) [verify 2026-10-18]
- **Submission**: Legal Request Submissions site https://legalrequests.x.com (t.co/lr), government agencies and law enforcement only; signed, on letterhead, non-editable, with a valid return email, identifying the account by @username and profile URL and/or user ID [verify 2026-10-18]
- **Non-government parties**: Serve X Corp's registered agent (CT Corporation); refer criminal matters via [[../Techniques/sop-sensitive-crime-intake-escalation|Sensitive Crime Intake & Escalation]] [verify 2026-10-18]
- Review [[../Techniques/sop-legal-ethics|Legal & Ethics]] before any request or referral

## 16) Legal & Ethical Considerations

> The canonical source for legal posture is [[../Techniques/sop-legal-ethics|Legal & Ethics SOP]]. Never re-derive it here.

- **Platform ToS**: [X's Terms of Service](https://x.com/en/tos) permit access or search only through X's currently available, published interfaces (and only under the applicable terms), unless a separate agreement allows otherwise, and expressly prohibit crawling or scraping in any form, for any purpose, without X's prior written consent [verify 2026-10-18]. Collect through the web client or the X API (§7), not scrapers.
- **Legal process**: preservation and disclosure requests follow [Legal Process & Preservation](#legal-process--preservation) under §15; do not duplicate them here.
- **Sensitive-crime routing**: CSAM, threat-to-life, trafficking, terrorism content found during OSINT triggers immediate hard-stop and routing per [[../Techniques/sop-sensitive-crime-intake-escalation|Sensitive Crime Escalation SOP]]. Do not download or further analyze CSAM; preserve URL + timestamp only and report to NCMEC (US) / IWF (UK) / national equivalent.
- **OPSEC**: the logged-in persona account (§1), its email/phone, payment method for X Premium or API credits, and devices must be isolated from the analyst's personal identity per [[../Techniques/sop-opsec-plan|OPSEC Planning SOP]].

## 17) Related SOPs

- [[../Techniques/sop-legal-ethics|Legal & Ethics SOP]] - Review before every investigation
- [[../Techniques/sop-opsec-plan|OPSEC Planning]] - Protect investigator identity
- [[../Techniques/sop-collection-log|Collection Log]] - Evidence tracking and chain of custody
- [[../Techniques/sop-image-video-osint|Image & Video OSINT]] - Media analysis and geolocation
- [[../Techniques/sop-web-dns-whois-osint|Web/DNS/WHOIS OSINT]] - URL and infrastructure analysis
- [[../Techniques/sop-financial-aml-osint|Financial & AML OSINT]] - Cryptocurrency tracking
- [[../Techniques/sop-entity-dossier|Entity Dossier Building]] - Subject profiling
- [[../Techniques/sop-reporting-packaging-disclosure|Reporting & Disclosure]] - Final report preparation
- [[../Techniques/sop-sensitive-crime-intake-escalation|Sensitive Crime Escalation]] - Law enforcement referral

## 18) External Resources

**Third-Party Tools:**
- Social-Analyzer: https://github.com/qeeqbox/social-analyzer [verify 2026-10-18]
- Nuclei: https://github.com/projectdiscovery/nuclei-templates [verify 2026-10-18]
- Nitter Instances (project archived Oct 2026, unsupported): https://github.com/zedeus/nitter/wiki/Instances [verify 2026-10-18]
- Twint Archive: https://github.com/twintproject/twint [verify 2026-10-18]

**Training & Guides:**
- Bellingcat How-To Guides (general): https://www.bellingcat.com/resources/how-tos/ [verify 2026-10-18]
- OSINT Framework Twitter Section: https://osintframework.com/ [verify 2026-10-18]
- IntelTechniques Twitter Tools: https://inteltechniques.com/tools/Twitter.html [verify 2026-10-18]

---

**Last Updated:** 2026-10-18
**Version:** 3.0
**Review Frequency:** Yearly
