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
updated: 2025-10-08
---

# TikTok OSINT SOP

## 1) Access & Client Options

- **Web**: https://www.tiktok.com (limited functionality, view-only)
- **Mobile apps**: iOS/Android (full feature access, strongest tracking)
- **Desktop apps**: Windows/Mac applications (better for collection)
- **API access**: TikTok Research API (academic only, limited)
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
- **Monetization**: Brand partnerships, TikTok Shop, sponsored content

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
2. Sort by "Latest" for real-time content
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
- **Web downloaders**: snaptik.app, tiktokdownloader.com (watermark considerations)
- **Browser extensions**: Video DownloadHelper, Save TikTok Videos
- **Command-line tools**: yt-dlp, TikTok-DL
- **Screen recording**: OBS Studio, built-in screen capture (quality loss)
- **API extraction**: TikTok Research API (academic access only)

### File Organization
```
/Evidence/{{case_id}}/TikTok/
├── YYYYMMDD-HHMM/
│   ├── videos/
│   │   ├── @username_video_[ID].mp4
│   │   ├── @username_video_[ID]_nowatermark.mp4
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
# yt-dlp (most reliable)
yt-dlp "https://www.tiktok.com/@username/video/1234567890123456789"

# Download without watermark
yt-dlp --no-watermark "https://www.tiktok.com/@username/video/1234567890123456789"

# Download with metadata
yt-dlp --write-info-json "https://www.tiktok.com/@username/video/1234567890123456789"

# Bulk download from user
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
| **yt-dlp**            | Video downloader               | CLI      | `pip install yt-dlp`                    |
| **TikTok Downloader** | Web-based video download       | Web      | https://snaptik.app                     |
| **FFmpeg**            | Video/audio processing         | CLI      | https://ffmpeg.org                      |
| **Nuclei**            | Username enumeration           | CLI      | `nuclei -tags osint -var user=username` |
| **Social-Analyzer**   | Cross-platform username search | CLI      | `pip install social-analyzer`           |
| **InVID**             | Video verification toolkit     | Browser  | https://www.invid-project.eu            |
| **ExifTool**          | Metadata extraction            | CLI      | `exiftool video.mp4`                    |
| **Wayback Machine**   | Historical profile snapshots   | Web      | https://web.archive.org                 |

## 11) Risks & Limitations

- **Content deletion**: Videos deleted by users/TikTok (archive immediately)
- **Private accounts**: Limited access to content
- **Geographic restrictions**: Some content unavailable in certain regions
- **Algorithm bias**: "For You" page personalized, not comprehensive
- **Watermarks**: TikTok watermark on downloads (complicates verification)
- **Platform detection**: Unusual download patterns may trigger bans
- **Age restrictions**: COPPA compliance limits access to minor content
- **Ephemeral features**: Live streams not archived by platform
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
7. Contact TikTok safety team with case number

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
2. Sort by "Latest" for real-time documentation
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
- Live stream with critical evidence (archive immediately, no replay)
- Breaking news eyewitness content (may be removed)

### Rapid Response Protocol
1. **Immediate download**: Use fastest method (yt-dlp preferred)
2. **Multiple copies**: Download both watermarked and clean versions
3. **Frame extraction**: Key frames for immediate analysis
4. **Metadata capture**: Video info, comments, engagement stats
5. **Profile snapshot**: Full creator profile in case of deletion
6. **Hash calculation**: SHA-256 immediately
7. **External archive**: Submit to Archive.org, archive.today
8. **Documentation**: Log all actions with precise timestamps

### Escalation Triggers (see [[../Techniques/sop-sensitive-crime-intake-escalation|Sensitive Crime Escalation SOP]])
- **Child safety**: CSAM, exploitation, grooming (NCMEC: 1-800-843-5678)
- **Imminent violence**: Specific threats, attack planning (FBI, local police)
- **Suicide/self-harm**: Active crisis content (platform reporting + crisis hotline)
- **Terrorism**: Recruitment, propaganda, attack planning (FBI: tips.fbi.gov)
- **Human trafficking**: Victim indicators, recruitment content

## 15) Related SOPs

- [[../Techniques/sop-legal-ethics|Legal & Ethics SOP]] - Review before every investigation
- [[../Techniques/sop-opsec-plan|OPSEC Planning]] - Device isolation, account separation
- [[../Techniques/sop-collection-log|Collection Log]] - Evidence tracking and chain of custody
- [[../Techniques/sop-image-video-osint|Image & Video OSINT]] - Geolocation, verification, analysis
- [[../Techniques/sop-web-dns-whois-osint|Web/DNS/WHOIS OSINT]] - Analyze bio links, external sites
- [[../Techniques/sop-entity-dossier|Entity Dossier Building]] - Creator profiling
- [[../Techniques/sop-reporting-packaging-disclosure|Reporting & Disclosure]] - Final report preparation
- [[../Techniques/sop-sensitive-crime-intake-escalation|Sensitive Crime Escalation]] - Law enforcement referral

## 16) External Resources

**Official Documentation:**
- TikTok Safety Center: https://www.tiktok.com/safety
- Community Guidelines: https://www.tiktok.com/community-guidelines

**Third-Party Tools:**
- yt-dlp GitHub: https://github.com/yt-dlp/yt-dlp
- Nuclei Templates: https://github.com/projectdiscovery/nuclei-templates
- Social-Analyzer: https://github.com/qeeqbox/social-analyzer
- InVID Verification: https://www.invid-project.eu/tools-and-services/invid-verification-plugin/

**Training & Guides:**
- Bellingcat TikTok OSINT: https://www.bellingcat.com/resources/how-tos/
- OSINT Framework TikTok: https://osintframework.com/
- First Draft TikTok Verification: https://firstdraftnews.org/

---

**Last Updated:** 2025-10-08
**Version:** 1.0
**Review Frequency:** Yearly
