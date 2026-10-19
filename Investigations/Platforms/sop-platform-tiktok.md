---
type: sop
title: TikTok SOP
description: "TikTok OSINT methods: video analysis, user profiling, hashtag tracking, sound investigation & viral content tracing for social media intelligence."
tags:
  - sop
  - platform
  - tiktok
  - video
  - osint
created: 2025-10-08
updated: 2026-10-18
---

# TikTok OSINT SOP

> **Authorized OSINT use only.** Investigation accounts must comply with TikTok's region-specific Terms of Service: the [U.S. terms](https://www.tiktok.com/legal/page/us/terms-of-service/en) (scraping, crawling or extracting data with any automated system or software needs written approval) and the [terms for users outside the US, EEA, UK, Switzerland and India](https://www.tiktok.com/legal/page/row/terms-of-service/en) (no automated scripts to collect information or interact with the Services; no impersonation or false identity) [verify 2026-10-18]. Review [[../Techniques/sop-legal-ethics|Legal & Ethics SOP]] and [[../Techniques/sop-opsec-plan|OPSEC Planning SOP]] before any engagement.

## Table of Contents

1. [Access & Client Options](#1-access--client-options)
2. [Search & Discovery Methods](#2-search--discovery-methods)
3. [Repeatable Workflow](#3-repeatable-workflow)
4. [Creator Intelligence](#4-creator-intelligence)
5. [Video Content Analysis](#5-video-content-analysis)
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

- **Web**: https://www.tiktok.com (limited functionality, view-only)
- **Mobile apps**: iOS/Android (full feature access, strongest tracking)
- **Desktop app**: Windows app via Microsoft Store (publisher TikTok Pte. Ltd.); no official macOS client located, use web on Mac [verify 2026-10-18]
- **API access**: TikTok Research API (approved academic institutions in the US, EEA, UK, Canada or Switzerland, EU not-for-profit research bodies, and Brazil-based youth-safety researchers; profiles, follower/following lists, content) [verify 2026-10-18]
- **Third-party tools**: Download tools, monitoring services
- **Geographic restrictions**: Content/features vary by region (VPN considerations)

## 2) Search & Discovery Methods

### Basic Search
- **Hashtag search**: `#keyword` for trending and recent content
- **User search**: @username or profile name
- **Sound search**: Audio track identification, trending sounds
- **Keyword search**: General content search (captions, descriptions)
- **Effect search**: AR filters and video effects

### Advanced Discovery
- **Hashtag combinations**: Stack multiple tags `#event #location #topic`
- **Trending page**: Real-time viral content discovery
- **Sound tracking**: Find all videos using specific audio
- **Effect tracking**: Videos using specific AR filters
- **Creator discovery**: Similar creators, recommendations

## 3) Repeatable Workflow

1. **Content identification**: Video themes, hashtags, music, effects, challenges
2. **Creator profiling**: Account analysis, posting patterns, audience demographics
3. **Trend analysis**: Viral content propagation, meme evolution, challenge tracking
4. **Audio forensics**: Background sounds, voice analysis, music identification
5. **Visual intelligence**: Location clues, faces, license plates, signage, landmarks
6. **Network mapping**: Duets, stitches, collaborations, cross-platform links
7. **Temporal correlation**: Posting times, event timestamps, timezone indicators
8. **Engagement analysis**: Like/comment/share patterns, viral velocity
9. **Content preservation**: Download videos, extract frames, archive metadata
10. **Documentation**: Log evidence with hashes, timestamps, chain of custody

## 4) Creator Intelligence

### Profile Analysis
- **Username**: Handle variations, consistency across platforms
- **Display name**: Real name, pseudonym, business name
- **Bio**: Location, contact info, website links, other social handles
- **Profile picture**: Reverse image search potential
- **Verification status**: Blue check for authentic creators
- **Follower/following count**: Influence indicators
- **Video count**: Content volume, posting frequency
- **Likes count**: Total engagement received

### Content Patterns
- **Posting schedule**: Time patterns, timezone indicators
- **Content themes**: Recurring topics, niches, expertise
- **Video style**: Production quality, editing techniques
- **Audio preferences**: Music choices, original sounds
- **Effect usage**: Favorite filters, AR effects
- **Collaboration patterns**: Frequent duet/stitch partners
- **Monetization**: Brand partnerships, TikTok Shop, sponsored content [verify 2026-10-18]

## 5) Video Content Analysis

### Visual Elements
- **Objects**: Products, brands, weapons, contraband
- **People**: Faces, clothing, tattoos, identifying features
- **Locations**: Landmarks, street signs, architecture, vehicles
- **Text overlays**: Captions, hashtags, on-screen messages
- **Branding**: Logos, watermarks, product placements
- **Activities**: Actions depicted, behaviors shown

### Audio Analysis
- **Music tracks**: Identify songs via Shazam, SoundHound
- **Original sounds**: User-created audio, voice recordings
- **Voice characteristics**: Accent, dialect, language
- **Background audio**: Environmental sounds, conversations
- **Sound effects**: Added effects, audio manipulation

### Metadata
- **Upload timestamp**: Date/time posted (UTC conversion)
- **Video duration**: Length indicators
- **Resolution**: Quality indicators
- **Engagement stats**: Views, likes, comments, shares
- **Hashtags used**: Tag combinations
- **Location tag**: If geotagged (rare on TikTok)

## 6) Investigation Recipes

### Breaking News Monitoring
**Objective**: Track real-time events and eyewitness content

**Search**: `#breakingnews #[location] #[event]`

**Method**:
1. Search event-specific hashtags immediately
2. Open **Filters** (more-options menu on the results page) to narrow to recent videos where the option is offered
3. Identify verified eyewitnesses (location consistency)
4. Download all relevant videos before deletion
5. Cross-reference with news reports, other platforms
6. Geolocate videos via [[../Techniques/sop-image-video-osint|Image/Video OSINT]]

### Trend Analysis
**Objective**: Track viral challenge or meme propagation

**Search**: `#[challengename]` or search by trending sound

**Method**:
1. Identify original creator of trend
2. Track participation over time (date sorting)
3. Map geographic spread (user locations)
4. Analyze variations and derivatives
5. Identify influencers driving adoption
6. Monitor for harmful challenge variants (safety concerns)

### Brand/Product Investigation
**Objective**: Monitor brand mentions and user-generated content

**Search**: `#[brandname]` or `@[brandaccount]`

**Method**:
1. Search brand hashtags and official account
2. Identify top influencers mentioning brand
3. Check for fake products, scams using brand name
4. Monitor sentiment (positive vs negative content)
5. Track sponsored vs organic mentions
6. Document unauthorized use of IP/trademarks

### Geolocation Intelligence
**Objective**: Identify unknown location from video content

**Method**:
1. Analyze background for landmarks, signs, architecture
2. Check audio for language, accents, local references
3. Review other videos from same creator for location clues
4. Use reverse image search on key frames
5. Check weather in video against meteorological data
6. Correlate posting time with timezone
7. Reference [[../Techniques/sop-image-video-osint|Image/Video OSINT SOP]]

## 7) Collection & Evidence Integrity

### Download Methods
- **Web downloaders**: snaptik.app, tiktokdownloader.com (watermark considerations) [verify 2026-10-18]
- **Browser extensions**: Video DownloadHelper
- **Command-line tools**: yt-dlp [verify 2026-10-18]
- **Screen recording**: OBS Studio, built-in screen capture (quality loss)
- **API extraction**: TikTok Research API (approved academic and not-for-profit researchers only; see §1) [verify 2026-10-18]

### File Organization
```
/Evidence/{{case_id}}/TikTok/
├── YYYYMMDD-HHMM/
│   ├── videos/
│   │   ├── @username_video_[ID].mp4
│   │   └── @username_video_[ID]_metadata.json
│   ├── frames/
│   │   └── @username_video_[ID]_frame_001.png
│   ├── profiles/
│   │   ├── @username_profile.png
│   │   └── @username_bio.txt
│   ├── comments/
│   │   └── video_[ID]_comments.txt
│   └── SHA256SUMS
```

### Hashing & Verification
- Calculate SHA-256 for all video files immediately
- Store hashes in `SHA256SUMS` file
- Document capture timestamp (UTC), video URL, TikTok video ID
- Reference in [[../Techniques/sop-collection-log|Collection Log]]
- Note watermark presence (affects authenticity verification)

### Command-Line Download
```bash
# yt-dlp (most reliable) [verify 2026-10-18]
yt-dlp "https://www.tiktok.com/@username/video/1234567890123456789"

# List available formats, then download one with -f FORMAT_ID (yt-dlp documents no watermark-removal option) [verify 2026-10-18]
yt-dlp -F "https://www.tiktok.com/@username/video/1234567890123456789"

# Download with metadata [verify 2026-10-18]
yt-dlp --write-info-json "https://www.tiktok.com/@username/video/1234567890123456789"

# Bulk download from user [verify 2026-10-18]
yt-dlp "https://www.tiktok.com/@username"
```

## 8) Advanced Techniques

### Frame-by-Frame Analysis
- Extract frames using FFmpeg: `ffmpeg -i video.mp4 -vf fps=1 frame_%04d.png`
- Analyze individual frames for hidden details
- Use image enhancement tools (upscaling, noise reduction)
- Check for deepfake indicators, manipulation artifacts
- Extract text from frames using OCR

### Audio Analysis
```bash
# Extract audio from video
ffmpeg -i tiktok_video.mp4 -vn -acodec copy audio.aac

# Audio fingerprinting
fpcalc audio.aac

# Spectral analysis
audacity audio.aac
```

### Reverse Video Search
- Google Videos search (upload video or key frame)
- TinEye for frame reverse search
- Check if video appears on other platforms (YouTube, Instagram)
- Identify original source if video is repurposed

## 9) Pivoting & Cross-Platform Correlation

### Profile Pivots
- **Bio links** → Instagram, YouTube, Linktree, personal websites
- **Username search** → Same handle on other platforms (use Nuclei)
- **Email/contact** → Rarely in bio, but check "Contact" button
- **Profile picture** → Reverse image search for other accounts
- **Watermarks** → Other platform handles embedded in videos

### Content Pivots
- **Recycled content** → Same videos on Instagram Reels, YouTube Shorts
- **Cross-posting patterns** → TikTok → Instagram → Twitter pipeline
- **Original source** → If TikTok video is from elsewhere
- **Music used** → Track artist accounts, related content
- **Hashtags** → Cross-platform hashtag tracking

### Network Pivots
- **Duet partners** → Frequent collaborators, relationship mapping
- **Stitch sources** → Who they respond to, content inspiration
- **Comment interactions** → Regular engagers, fan relationships
- **Following/followers** → If public, analyze network
- **Live stream participants** → Live video co-hosts, regular viewers

## 10) Tools & Resources

| Tool                  | Purpose                        | Platform | Access                                  |
| --------------------- | ------------------------------ | -------- | --------------------------------------- |
| **TikTok Web**        | Basic viewing and search       | Web      | https://www.tiktok.com                  |
| **yt-dlp**            | Video downloader               | CLI      | `pip install yt-dlp` [verify 2026-10-18] |
| **TikTok Downloader** | Web-based video download       | Web      | https://snaptik.app [verify 2026-10-18] |
| **FFmpeg**            | Video/audio processing         | CLI      | https://ffmpeg.org [verify 2026-10-18]  |
| **Nuclei**            | Username enumeration           | CLI      | `nuclei -tags osint -esc -var user=username` [verify 2026-10-18] |
| **Social-Analyzer**   | Cross-platform username search | CLI      | `pip install social-analyzer` (last PyPI release 0.45, May 2022) [verify 2026-10-18] |
| **InVID-WeVerify**    | Video verification plugin      | Browser  | https://weverify.eu/verification-plugin/ [verify 2026-10-18] |
| **ExifTool**          | Metadata extraction            | CLI      | `exiftool video.mp4`                    |
| **Wayback Machine**   | Historical profile snapshots   | Web      | https://web.archive.org [verify 2026-10-18] |

## 11) Risks & Limitations

- **Content deletion**: Videos deleted by users/TikTok (archive immediately)
- **Private accounts**: Limited access to content
- **Geographic restrictions**: Some content unavailable in certain regions
- **Algorithm bias**: "For You" page personalized, not comprehensive
- **Watermarks**: TikTok watermark on downloads (complicates verification)
- **Platform detection**: Unusual download patterns may trigger bans
- **Age restrictions**: Accounts of 13-15-year-olds are private by default, their videos can't be downloaded, and Duet/Stitch is locked to no one, so minors' content is largely out of reach [verify 2026-10-18]
- **Ephemeral features**: LIVE replays are available to the creator for 30 days and can be deleted; don't rely on them, record LIVE streams yourself [verify 2026-10-18]
- **Edit capabilities**: Users can edit captions, change privacy settings
- **Deepfakes**: AI-generated content increasingly common

## 12) Quality Assurance & Verification

### Content Authentication
- **Deepfake detection**: Check for AI-generated faces, unnatural movements
- **Edit indicators**: Look for jump cuts, timeline inconsistencies
- **Reverse search**: Find original source if video is recycled
- **Metadata analysis**: Check upload time vs claimed event time
- **Audio verification**: Original sound vs added audio track

### Location Verification
- **Background analysis**: Landmarks, architecture, signage, license plates
- **Weather correlation**: Visible weather vs meteorological records
- **Sun position**: Shadow analysis for time/location verification
- **Language/accent**: Spoken language matches claimed location
- **Cross-reference**: Verify with Google Street View, satellite imagery

## 13) Real-World Scenarios

### Scenario 1: Missing Person Located via TikTok
**Situation**: Teenager missing 48 hours, known to be active on TikTok.

**Approach**:
1. Search username across all platforms (Nuclei scan)
2. Check recent TikTok activity for location clues
3. Analyze background in latest videos for landmarks
4. Review comments for interactions mentioning location
5. Check duets/stitches with local creators
6. Analyze posting times for timezone indicators
7. Have the investigating police file an emergency request through TikTok's law-enforcement webform (sworn officers only; see Legal Process & Preservation in §14) [verify 2026-10-18]

**Outcome**: Latest video posted 6 hours ago showed recognizable coffee shop sign in background; reverse image search identified shop in neighboring city; video timestamp correlated with shop hours; provided location to police; teen found safe within 2 hours.

### Scenario 2: Viral Misinformation Campaign
**Situation**: False claim about product danger spreading rapidly on TikTok.

**Approach**:
1. Identify original video making false claim
2. Track spread: search hashtag, find all derivative videos
3. Map influencer amplification (who's resharing)
4. Document claim evolution (how story changes)
5. Check for coordinated behavior (account creation dates, posting patterns)
6. Archive all evidence before deletions
7. Prepare fact-check report with evidence

**Outcome**: Traced false claim to single creator account (3 days old); identified network of 47 accounts amplifying message within 12 hours; accounts showed coordinated creation pattern; documented 2.3M views before TikTok removal; evidence provided to brand for legal action and platform safety team.

### Scenario 3: Protest Documentation and Safety
**Situation**: Large protest, need to document for human rights monitoring.

**Approach**:
1. Search location + date hashtags: `#protest #cityname #date`
2. Open **Filters** (more-options menu on the results page) to narrow to recent videos where the option is offered
3. Download all relevant videos immediately
4. Verify locations using [[../Techniques/sop-image-video-osint|Image OSINT]]
5. Document police actions, violence, injuries
6. Protect creator identities (redact faces if sharing)
7. Archive before platform removal

**Outcome**: Archived 380 videos from 127 unique creators documenting protest; verified 12 instances of excessive force via geolocation and timestamp analysis; evidence submitted to human rights organization and legal team representing protesters; 23 videos removed by TikTok but preserved in archive.

## 14) Emergency Procedures

### Immediate Archival Triggers
- Video shows imminent threat (violence, suicide, terrorism)
- Evidence of crime in progress (assault, trafficking, child abuse)
- Content about to be deleted (creator announces deletion)
- Live stream with critical evidence (archive immediately; don't rely on a replay)
- Breaking news eyewitness content (may be removed)

### Rapid Response Protocol
1. **Immediate download**: Use fastest method (yt-dlp preferred)
2. **Multiple copies**: Download each available format listed by `yt-dlp -F` (a watermark-free file is not guaranteed)
3. **Frame extraction**: Key frames for immediate analysis
4. **Metadata capture**: Video info, comments, engagement stats
5. **Profile snapshot**: Full creator profile in case of deletion
6. **Hash calculation**: SHA-256 immediately
7. **External archive**: Submit to Archive.org, archive.today
8. **Documentation**: Log all actions with precise timestamps

### Escalation Triggers (see [[../Techniques/sop-sensitive-crime-intake-escalation|Sensitive Crime Escalation SOP]])
- **Child safety**: CSAM, exploitation, grooming (NCMEC: 1-800-843-5678) [verify 2026-10-18]
- **Imminent violence**: Specific threats, attack planning (FBI, local police)
- **Suicide/self-harm**: Active crisis content (platform reporting + crisis hotline)
- **Terrorism**: Recruitment, propaganda, attack planning (FBI: tips.fbi.gov) [verify 2026-10-18]
- **Human trafficking**: Victim indicators, recruitment content

### Legal Process & Preservation
- **Entity**: Address requests to the TikTok entity for the user's location; U.S. users are served by TikTok USDS Joint Venture LLC under its own U.S. guidelines (https://usdsjv.tiktok.com/law-enforcement-guidelines), all others under the global guidelines [verify 2026-10-18]
- **Submission**: Law-enforcement webform https://www.tiktok.com/legal/report/lawenforcementrequest, attachments in PDF (Word not accepted) [verify 2026-10-18]
- **Preservation**: 90 days on a formal request on law-enforcement letterhead, signed, naming the username, data type and date range; one further 90-day extension on formal request; preserved data may be deleted at expiry if no legal process arrives [verify 2026-10-18]
- **Emergency**: Same webform; sworn law-enforcement officials only, for imminent harm or risk of death or serious physical injury; anyone else contacts local law enforcement directly [verify 2026-10-18]
- Review [[../Techniques/sop-legal-ethics|Legal & Ethics]] before any request or referral

## 15) Legal & Ethical Considerations

> TikTok OSINT sits at the intersection of platform ToS, minors' data, and (frequently) sensitive-crime evidence. The canonical source for legal posture is [[../Techniques/sop-legal-ethics|Legal & Ethics SOP]] — never re-derive it here.

- **Platform ToS**: TikTok's [U.S. Terms of Service](https://www.tiktok.com/legal/page/us/terms-of-service/en) (TikTok USDS Joint Venture LLC) prohibit scraping, crawling, exporting or otherwise extracting data from the Platform using any automated system or software, including bots, except as approved in writing, and operating spam or impersonation accounts; the [terms for users outside the US, EEA, UK, Switzerland and India](https://www.tiktok.com/legal/page/row/terms-of-service/en) (TikTok Pte. Ltd.) prohibit using automated scripts to collect information from or otherwise interact with the Services, impersonating any person or entity, and creating a false identity [verify 2026-10-18]. Bulk yt-dlp collection (§7) is automated collection under these clauses. Investigation accounts that violate ToS risk ban and evidence inadmissibility.
- **Legal process**: preservation, disclosure and emergency requests go through TikTok's law-enforcement webform; see [Legal Process & Preservation](#legal-process--preservation) in §14.
- **Sensitive-crime routing**: CSAM, threat-to-life, trafficking, terrorism content found during OSINT triggers immediate hard-stop and routing per [[../Techniques/sop-sensitive-crime-intake-escalation|Sensitive Crime Escalation SOP]]. Do not download or further analyze CSAM; preserve URL + timestamp only and report to NCMEC (US) / IWF (UK) / national equivalent.
- **OPSEC**: persona accounts, phone numbers, payment methods and devices must be isolated from the analyst's personal identity per [[../Techniques/sop-opsec-plan|OPSEC Planning SOP]]. Keep **Profile view history** off on personas: when it is on, accounts you visit that also have it on can see your visit [verify 2026-10-18].

## 16) Related SOPs

- [[../Techniques/sop-legal-ethics|Legal & Ethics SOP]] - Review before every investigation
- [[../Techniques/sop-opsec-plan|OPSEC Planning]] - Device isolation, account separation
- [[../Techniques/sop-collection-log|Collection Log]] - Evidence tracking and chain of custody
- [[../Techniques/sop-image-video-osint|Image & Video OSINT]] - Geolocation, verification, analysis
- [[../Techniques/sop-web-dns-whois-osint|Web/DNS/WHOIS OSINT]] - Analyze bio links, external sites
- [[../Techniques/sop-entity-dossier|Entity Dossier Building]] - Creator profiling
- [[../Techniques/sop-reporting-packaging-disclosure|Reporting & Disclosure]] - Final report preparation
- [[../Techniques/sop-sensitive-crime-intake-escalation|Sensitive Crime Escalation]] - Law enforcement referral

## 17) External Resources

**Official Documentation:**
- TikTok Safety Center: https://www.tiktok.com/safety/en [verify 2026-10-18]
- Community Guidelines: https://www.tiktok.com/safety/en/policies-and-engagement/overview [verify 2026-10-18]
- TikTok Law Enforcement Guidelines (global): https://www.tiktok.com/safety/en/tools-and-guides/tiktok-law-enforcement-guidelines [verify 2026-10-18]
- TikTok U.S. (USDS JV) Law Enforcement Guidelines: https://usdsjv.tiktok.com/law-enforcement-guidelines [verify 2026-10-18]
- Law-enforcement request webform: https://www.tiktok.com/legal/report/lawenforcementrequest [verify 2026-10-18]

**Third-Party Tools:**
- yt-dlp GitHub: https://github.com/yt-dlp/yt-dlp [verify 2026-10-18]
- Nuclei Templates: https://github.com/projectdiscovery/nuclei-templates
- Social-Analyzer: https://github.com/qeeqbox/social-analyzer
- InVID-WeVerify Verification Plugin: https://weverify.eu/verification-plugin/ [verify 2026-10-18]

**Training & Guides:**
- Bellingcat guides (general OSINT): https://www.bellingcat.com/resources/how-tos/ [verify 2026-10-18]
- OSINT Framework TikTok: https://osintframework.com/ [verify 2026-10-18]
- First Draft (archived 2022; static reference only): https://firstdraftnews.org/ [verify 2026-10-18]

---

**Last Updated:** 2026-10-18
**Version:** 1.0
**Review Frequency:** Yearly
