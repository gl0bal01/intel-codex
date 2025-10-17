---
type: sop
title: Instagram SOP
description: "Instagram investigation techniques: photo analysis, story tracking, location discovery, hashtag research & influencer network mapping for OSINT investigations."
tags:
  - sop
  - platform
  - instagram
  - social-media
  - osint
created: 2024-04-11
updated: 2025-10-01
---

# Instagram OSINT SOP

## 1) Access & Client Options

- **Web**: https://www.instagram.com/ (GUI - limited search functionality)
- **Mobile app**: iOS/Android (full search capabilities, stronger device fingerprinting)
- **API access**: Instagram Graph API (business accounts only, limited OSINT capability)
- **Third-party tools**: Browser extensions, scraping tools (use with caution)
- **Access consideration**: Logged-out vs persona-logged-in (balance visibility vs attribution risk)
- **View limits**: ~200 stories/day logged out, more when logged in

## 2) Search Methods & Techniques

### Basic Search
- **Hashtags**: `#keyword` - shows recent & top posts
- **Locations**: Search by place name, coordinate proximity
- **Users**: `@username` or direct profile access
- **Reverse username**: Try variations, common patterns
- **Explore page**: Curated content based on interests/activity

### Advanced Discovery
- **Location intelligence**: Search specific venues, neighborhoods, landmarks
- **Hashtag combinations**: Track event-specific or trending tags
- **Tagged posts**: Find who tags specific accounts/locations
- **Story locations**: Location stickers in stories
- **Reels search**: Video content discovery by topic/sound
- **Guides feature**: Curated collections by users

## 3) Repeatable Workflow

1. **Profile reconnaissance**: Bio, highlights, tagged photos, followers/following (if public)
2. **Content mapping**: Post timeline, story highlights, IGTV/Reels content
3. **Temporal analysis**: Posting patterns, activity schedules, timezone indicators
4. **Network analysis**: Tagged users, frequent commenters, story viewers (if accessible)
5. **Location intelligence**: Geotagged posts, location stories, background analysis
6. **Link pivoting**: Bio links (Linktree, personal sites), tagged businesses
7. **Content harvesting**: Full-resolution images, video files, captions, metadata
8. **Media forensics**: EXIF data extraction, reverse image search
9. **Cross-platform correlation**: Username/bio matching across platforms
10. **Documentation**: Log all findings with timestamps and evidence hashes

## 4) Profile Intelligence

### Profile Analysis
- **Username**: Handle variations, username history (if tracked)
- **Display name**: Real name, pseudonym, business name
- **Bio**: Location claims, occupation, contact info, website links
- **Profile picture**: Reverse image search, facial recognition potential
- **Verification status**: Blue check (authentic), grey check (business/organization)
- **Account type**: Personal, business, creator
- **Privacy settings**: Public vs private account
- **Follower/following count**: Influence indicators, bot detection

### Content Patterns
- **Post frequency**: Daily/weekly activity, posting schedule
- **Content types**: Photos, videos, carousels, Reels, IGTV
- **Aesthetic style**: Filter usage, color palettes, visual themes
- **Caption style**: Language, tone, hashtag patterns
- **Story activity**: Story frequency, highlight organization
- **Engagement metrics**: Likes, comments, shares (if visible)
- **Sponsored content**: Brand partnerships, affiliate links

### Network Intelligence
- **Tagged users**: Family, friends, colleagues, business associates
- **Mutual connections**: Shared followers/following
- **Comment interactions**: Who they engage with regularly
- **Story mentions**: Who they mention in stories
- **Collaboration posts**: Co-created content with other accounts
- **Business tags**: Companies, venues, events tagged

## 5) Investigation Recipes

### Geolocation Verification
**Objective**: Verify claimed location or identify unknown location

**Method**:
1. Search location tags for the area of interest
2. Review posts with same location tag around specific timeframe
3. Cross-reference with Google Street View, Maps, satellite imagery
4. Analyze background details: signage, landmarks, architecture
5. Check sun position/shadows for time/direction verification

### Event Documentation
**Objective**: Document attendance or activities at specific event

**Method**:
1. Search event hashtags and location tags
2. Check story highlights from attendees (time-sensitive)
3. Identify key participants via tagged photos
4. Timeline reconstruction from multiple accounts
5. Cross-reference with news coverage, official event pages

### Identity Verification
**Objective**: Confirm identity or detect impersonation

**Method**:
1. Reverse image search profile picture
2. Check verification badge authenticity
3. Analyze posting history for consistency
4. Cross-reference with other social media platforms
5. Verify contact information in bio (phone, email, website)

### Business Intelligence
**Objective**: Investigate business connections and partnerships

**Method**:
1. Identify tagged business accounts
2. Check for sponsored content indicators
3. Analyze bio link destinations (Linktree, company sites)
4. Review collaboration posts and brand mentions
5. Map network of associated businesses/influencers

## 6) Collection & Evidence Integrity

### Media Capture Methods
- **Full resolution images**: Use browser dev tools or specialized downloaders
- **Video content**: Download Reels, IGTV, story videos at highest quality
- **Story archival**: Screen recording for ephemeral content (24h window)
- **Profile snapshots**: Complete bio, highlights, post grid
- **Metadata extraction**: EXIF data, caption text, post IDs, timestamps
- **URL preservation**: Save post permalinks, bio links

### File Organization
```
/Evidence/{{case_id}}/Instagram/
├── YYYYMMDD-HHMM/
│   ├── posts/
│   │   ├── post_[ID]_image.jpg
│   │   ├── post_[ID]_caption.txt
│   │   └── post_[ID]_metadata.json
│   ├── stories/
│   │   └── story_[timestamp].mp4
│   ├── reels/
│   │   └── reel_[ID].mp4
│   ├── profile/
│   │   ├── @username_bio.txt
│   │   ├── @username_profile.png
│   │   └── @username_grid.pdf
│   └── SHA256SUMS
```

### Hashing & Verification
- Calculate SHA-256 for all captured media immediately 
- Store hashes in `SHA256SUMS` file
- Document capture timestamp and source URL
- Reference in [[../Techniques/sop-collection-log|Collection Log]]
- Maintain chain of custody documentation

## 7) Advanced Techniques

### Deleted Content Recovery
- **Wayback Machine**: Historical snapshots of public profiles
- **Third-party archives**: Archive.today, Archive.is manual captures
- **Screenshot databases**: Existing compilations (legal/ethical review required)
- **Cross-platform mirrors**: Content reposted on Twitter, TikTok, etc.

### Media Forensics
- **EXIF extraction**: `exiftool image.jpg` for GPS, camera, timestamp data
- **Reverse image search**: Google Images, Yandex, TinEye, PimEyes
- **Facial recognition**: PimEyes, Social-Analyzer (legal considerations)
- **Background analysis**: License plates, signage, reflections, landmarks
- **Metadata verification**: Check for manipulation, verify original source

### Automation & Monitoring
- **Browser automation**: Selenium/Playwright for systematic collection
- **RSS monitoring**: Limited, third-party services may offer feeds
- **Alert systems**: IFTTT/Zapier for new posts from specific accounts
- **API integration**: Instagram Graph API for business accounts
- **Hashtag tracking**: Monitor trending or campaign-specific tags

## 8) Pivoting & Cross-Platform Correlation

### Profile Pivots
- **Bio links** → Personal websites, OnlyFans, Linktree, TikTok, business pages
- **Username search** → Same handle on Twitter, TikTok, Snapchat, Facebook
- **Email/phone** → Data breach searches, reverse lookups
- **Profile image** → Reverse search for duplicate accounts
- **Location claims** → Verify with geotagged posts, local knowledge

### Content Pivots
- **Tagged locations** → Event attendance, residence/work indicators
- **Tagged users** → Social network mapping, family/friends identification
- **Hashtags** → Campaign participation, community affiliation
- **Music in Reels** → Cultural/regional indicators, trending sounds
- **Business tags** → Employment, partnerships, sponsored content

### Network Pivots
- **Mutual followers** → Community mapping, shared connections
- **Comment patterns** → Regular interactions, relationship indicators
- **Story mentions** → Close connections, collaborations
- **Collaboration posts** → Business partners, content creators
- **Tagged photos** → Social events, group affiliations

## 9) Tools & Resources

| Tool                | Purpose                               | Platform      | Access                                                                                                |
| ------------------- | ------------------------------------- | ------------- | ----------------------------------------------------------------------------------------------------- |
| **Instagram Web**   | Native search interface               | Web           | https://www.instagram.com                                                                             |
| **Nuclei**          | Username enumeration across platforms | CLI           | `nuclei -tags osint -var user=username`                                                               |
| **Social-Analyzer** | Cross-platform username search        | CLI           | `pip install social-analyzer`                                                                         |
| **ExifTool**        | Image metadata extraction             | CLI           | `exiftool image.jpg`                                                                                  |
| **InstaLoader**     | Download posts, stories, highlights   | CLI           | `pip install instaloader`                                                                             |
| **4K Stogram**      | Instagram downloader                  | Desktop       | https://www.4kdownload.com/products/stogram                                                           |
| **Wayback Machine** | Historical profile snapshots          | Web           | https://web.archive.org                                                                               |
| **Google Images**   | Reverse image search                  | Web           | https://images.google.com                                                                             |
| **Yandex Images**   | Reverse image search                  | Web           | https://yandex.com/images                                                                             |
| **PimEyes**         | Facial recognition search             | Web           | https://pimeyes.com (paid, legal review)                                                              |
| **TinEye**          | Reverse image search                  | Web           | https://tineye.com                                                                                    |
| **Search by image** | Reverse image search                  | Extension     | https://chromewebstore.google.com/detail/search-by-image/cnojnbdhbhnkbcieeekonklommdnndci?pli=1       |
| **Toutatis**        | Instagram account extraction          | CLI           | https://github.com/megadose/toutatis                                                                  |

### Download Tools Commands
```bash
# InstaLoader - Download profile content
instaloader profile_username

# Download specific post
instaloader --post=POST_ID

# Download stories (requires login)
instaloader --login=YOUR_USERNAME --stories profile_username

# Download highlights
instaloader --login=YOUR_USERNAME --highlights profile_username
```

## 10) Risks & Limitations

- **Ephemeral content**: Stories disappear in 24h unless saved to highlights
- **Algorithm filtering**: Explore page shows curated, not comprehensive results
- **Shadow banning**: Some content hidden from search results
- **Account deactivation**: Target may delete/deactivate during investigation
- **Technical detection**: Platform may flag unusual viewing patterns
- **Privacy settings**: Private accounts limit investigation capabilities
- **API restrictions**: Limited OSINT functionality, business-focused
- **Rate limiting**: Viewing/download limits may trigger restrictions
- **Metadata stripping**: Instagram removes most EXIF data from uploads

## 11) Quality Assurance & Verification

### Content Verification
- **Cross-reference timestamps** with external sources (news, other social media)
- **Verify locations** with satellite imagery, Street View, local knowledge
- **Authentication checks**: Verification badges, account age, posting patterns
- **Deepfake detection**: Reverse image search, metadata analysis
- **Context verification**: Comments, tagged users, event correlation

### Bias Mitigation
- **Algorithm awareness**: Explore page shows curated content, not complete picture
- **Privacy blind spots**: Private accounts create investigation gaps
- **Temporal sampling**: Check full timeline, not just recent/popular posts
- **Network diversity**: Don't rely solely on tagged/mentioned accounts
- **Source triangulation**: Verify with independent sources

### Evidence Quality
- **Multiple capture methods**: Screenshot + download + PDF for redundancy
- **Metadata preservation**: Capture all available data before platform strips it
- **Chain of custody**: Document discovery, collection, storage steps
- **Hash verification**: SHA-256 for file integrity
- **Contextualization**: Include surrounding posts, comments, account status

## 12) Real-World Scenarios

### Scenario 1: Geolocation of Kidnapping Victim
**Situation**: Missing person posts cryptic story with background details visible.

**Approach**:
1. Screenshot story immediately (24h window)
2. Analyze background: buildings, signage, landmarks, vehicles
3. Extract metadata if available (unlikely, but check)
4. Reverse image search recognizable features
5. Cross-reference with known locations victim frequents
6. Use sun position, shadows for directional clues
7. Search location tags in area for matching backgrounds

**Outcome**: Identified apartment building from reflection in window; matched to location 2 miles from residence; provided coordinates to law enforcement within 6 hours.

### Scenario 2: Fake Influencer Investment Scam
**Situation**: Impersonation account promoting fake investment scheme.

**Approach**:
1. Compare profile picture with legitimate account (reverse image search)
2. Check verification badge (fake account lacks legitimate badge)
3. Analyze follower patterns (sudden spike, bot followers)
4. Review post history (recent account creation, minimal history)
5. Check bio link destination (phishing site, not legitimate business)
6. Search for victim reports: `"@fake_account" scam` on Twitter/Reddit
7. Document evidence of impersonation and fraudulent claims

**Outcome**: Identified 15 victim accounts who sent funds; traced payment methods from stories/posts; reported to Instagram (account suspended) and provided evidence package to cybercrime unit.

### Scenario 3: Event Attendance Verification
**Situation**: Subject claims alibi of attending wedding, need to verify or disprove.

**Approach**:
1. Search wedding venue location tag for date in question
2. Check event-specific hashtags (#LastNameWedding2025)
3. Review subject's tagged photos from other attendees
4. Analyze story highlights from subject and connections
5. Verify timestamp metadata against claimed timeline
6. Cross-reference with other platforms (Facebook event, Twitter mentions)

**Outcome**: Found NO evidence of subject at wedding; discovered geotagged post from different city at same time; alibi disproven with photo evidence showing subject 200 miles away.

## 13) Emergency Procedures

### Immediate Archival Triggers
- Account shows signs of deletion (removing posts, changing bio)
- Target becomes aware of investigation
- Stories contain time-sensitive evidence (24h window)
- Legal hold requirements (preserve all content immediately)
- Threats to safety or child protection concerns

### Rapid Response Protocol
1. **Immediate capture**: Screenshot profile, stories, highlights, recent posts
2. **Media download**: All images/videos at full resolution
3. **Story archival**: Screen recording of all active stories
4. **Archive services**: Submit to Archive.org, Archive.today
5. **Network preservation**: Screenshot followers/following (if public)
6. **Documentation**: Log all actions with timestamps
7. **Escalation**: Notify supervisor/client of preservation actions

### Escalation Triggers (see [[../Techniques/sop-sensitive-crime-intake-escalation|Sensitive Crime Escalation SOP]])
- **Child safety**: CSAM, exploitation, grooming indicators
- **Immediate threats**: Violence, suicide, terrorism
- **Human trafficking**: Recruitment, victim indicators
- **Active crimes**: Ongoing illegal activity
- **Legal requirements**: Court orders, subpoenas, law enforcement requests

## 14) Related SOPs

- [[../Techniques/sop-legal-ethics|Legal & Ethics SOP]] - Review before every investigation
- [[../Techniques/sop-opsec-plan|OPSEC Planning]] - Protect investigator identity
- [[../Techniques/sop-collection-log|Collection Log]] - Evidence tracking and chain of custody
- [[../Techniques/sop-image-video-osint|Image & Video OSINT]] - Media analysis and geolocation
- [[../Techniques/sop-web-dns-whois-osint|Web/DNS/WHOIS OSINT]] - Bio link analysis
- [[../Techniques/sop-entity-dossier|Entity Dossier Building]] - Subject profiling
- [[../Techniques/sop-reporting-packaging-disclosure|Reporting & Disclosure]] - Final report preparation
- [[../Techniques/sop-sensitive-crime-intake-escalation|Sensitive Crime Escalation]] - Law enforcement referral

## 15) External Resources

**Third-Party Tools:**
- InstaLoader: https://github.com/instaloader/instaloader
- Social-Analyzer: https://github.com/qeeqbox/social-analyzer
- Nuclei: https://github.com/projectdiscovery/nuclei-templates
- 4K Stogram: https://www.4kdownload.com/products/stogram

**Training & Guides:**
- Bellingcat Instagram OSINT: https://www.bellingcat.com/resources/how-tos/
- OSINT Framework Instagram: https://osintframework.com/
- IntelTechniques Instagram Tools: https://inteltechniques.com/tools/Instagram.html

---

**Last Updated:** 2025-10-01
**Version:** 2.0
**Review Frequency:** Yearly
