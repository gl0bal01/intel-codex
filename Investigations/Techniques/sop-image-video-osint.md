---
type: sop
title: Image & Video OSINT
description: "Visual intelligence techniques: EXIF analysis, reverse image search, geolocation, video verification & deepfake detection for media investigations."
tags: [sop, media, exif, reverse, geolocation, verification]
template_version: 2026-04-25
updated: 2026-04-25
---

# Image & Video OSINT

> **Purpose:** Extract intelligence from images and videos through reverse image search, metadata analysis, geolocation, and forensic verification techniques. Essential for verifying social media content, identifying locations, and authenticating visual evidence.

---

## Overview

### Common Use Cases

**Image Analysis:**
- Verify social media profile authenticity (reverse search for stolen photos)
- Identify locations from photographs (geolocation)
- Authenticate evidence (detect manipulation, verify original source)
- Find additional context (other instances of same image online)
- Extract metadata (camera info, GPS coordinates, timestamp)

**Video Analysis:**
- Verify viral video authenticity
- Identify filming location (keyframe geolocation)
- Extract identifiable information (faces, license plates, landmarks)
- Detect deepfakes or manipulated footage
- Timeline verification (shadow analysis, weather conditions)

---

## 1. Image Intake & Preservation

### File Acquisition

**Download original (highest quality):**
```bash
# Right-click → Save Image As (browser)
# Always get full resolution, not thumbnail

# Twitter image download (original quality)
# Add :orig to image URL
# https://pbs.twimg.com/media/IMAGE_ID?format=jpg&name=large
# Change to: https://pbs.twimg.com/media/IMAGE_ID?format=jpg&name=orig

# Instagram image download (bypass restrictions)
# Method 1: Browser console
# Right-click image → Inspect → Find <img> tag → Copy image URL
# Method 2: Instaloader
instaloader --no-videos --no-video-thumbnails --post-metadata-txt POST_URL

# Download from URL (command-line)
wget -O original_image.jpg "https://example.com/image.jpg"

# Download with metadata preserved
curl -o original_image.jpg "https://example.com/image.jpg"
```

**Calculate hash immediately:**
```bash
# SHA-256 hash
sha256sum original_image.jpg > original_image.jpg.sha256

# Windows (PowerShell)
Get-FileHash -Path "original_image.jpg" -Algorithm SHA256 | Format-List

# Verify later
sha256sum -c original_image.jpg.sha256
```

**Check for duplicates/re-uploads:**
```bash
# Calculate perceptual hash (pHash - similar images have similar hashes)
# Using ImageMagick
convert original_image.jpg -resize 8x8! -colorspace Gray phash.txt

# Or use Python with imagehash library
python3 << EOF
from PIL import Image
import imagehash
hash = imagehash.phash(Image.open('original_image.jpg'))
print(f"pHash: {hash}")
EOF

# Compare two images
python3 << EOF
from PIL import Image
import imagehash
hash1 = imagehash.phash(Image.open('image1.jpg'))
hash2 = imagehash.phash(Image.open('image2.jpg'))
print(f"Difference: {hash1 - hash2}")  # 0 = identical, higher = more different
EOF
```

### File Format Analysis

```bash
# Identify true file type (ignores extension)
file image.jpg
# Output: image.jpg: JPEG image data, JFIF standard 1.01

# Detailed file info
identify -verbose image.jpg

# Check for steganography (hidden data)
binwalk image.jpg
# Flags embedded files or unusual data patterns

# Strings extraction (hidden text)
strings image.jpg | less
# Look for URLs, emails, metadata
```

---

## 2. Reverse Image Search

### Multi-Engine Search Strategy

**Why multiple engines:**
- Google: Best for Western web, recent images
- Yandex: Superior for faces, Cyrillic content, Eastern Europe/Russia
- Bing: Good middle ground, integrates with social media
- TinEye: Oldest instances, tracks image modifications over time
- Baidu: Essential for Chinese web content

### Google Reverse Image Search

> **Lens transition:** Since 2022 Google has consolidated reverse image search into Google Lens. The classic "Pages that include matching images" view is reachable but de-emphasised — Lens prioritises object/scene classification over exact-match URLs. For OSINT exact-match work, supplement Lens with Yandex + TinEye + Bing rather than relying on Google alone.

**Browser method (Lens, current default):**
```
1. Navigate to https://images.google.com
2. Click the camera/lens icon in the search bar
3. Upload image OR paste image URL
4. In the Lens results pane, click "Find image source" (or "Exact matches")
   to surface the legacy reverse-search view with:
   - Pages that include matching images
   - Visually similar images
   - Other sizes
```

**Direct legacy URL (still works as of 2026-04-25):**
```
# searchbyimage endpoint accepts a public image URL
https://www.google.com/searchbyimage?image_url=https://example.com/image.jpg
```

**Command-line method:**
```bash
# Using Google Custom Search API (requires API key + cx Programmable Search Engine ID)
# Note: this is text search with image filter, not reverse-image upload — Google has no
# public reverse-image API.
curl "https://www.googleapis.com/customsearch/v1?q=SEARCH_TERM&cx=YOUR_CX&searchType=image&imgSize=large&key=YOUR_API_KEY"

# Headless browser upload (Selenium/Playwright) is the only reliable
# automated path for upload-based reverse search.
```

**Advanced techniques:**
```
# Crop image to focus on specific element
# Example: Crop to just the face, or just a landmark
# Then reverse search the cropped version

# Adjust contrast/brightness before searching
# Some images may match better after enhancement
convert image.jpg -brightness-contrast 10x20 enhanced.jpg
```

### Yandex Reverse Image Search

**Why Yandex is superior for faces:**
- Better facial recognition algorithm
- Indexes more Eastern European and Russian content
- Often finds results when Google fails

**Usage:**
```
1. Navigate to https://yandex.com/images
2. Click camera icon
3. Upload image
4. Enable "Search for similar" (finds faces in images)

# Results often include:
# - Social media profiles (VK, Odnoklassniki)
# - Russian-language websites
# - Higher quality originals
```

### TinEye Reverse Search

**Best for:**
- Finding oldest instance of an image (temporal verification)
- Tracking image modifications over time
- Detecting copyright infringement

**Usage:**
```
1. Navigate to https://tineye.com
2. Upload image or paste URL
3. Sort results by:
   - "Oldest" - find original source
   - "Most changed" - find manipulated versions
   - "Biggest image" - highest resolution

# TinEye API (commercial)
curl -u "your_api_key:your_api_secret" \
  "https://api.tineye.com/rest/search/" \
  -F "image=@image.jpg"
```

### Specialized Reverse Search Engines

**PimEyes (Face Search):**
```
https://pimeyes.com
- Upload face photo → finds matches across the open web (excludes
  social-media and video platforms per their published scope)
- Pricing tiers: Open Plus, PROtect (paid plans required to view source URLs,
  set alerts, or use takedown features); free tier shows blurred matches only
- Approx. starting tier ~$29.99/month (verify on /pricing — pricing changes)
  [verify 2026-04-25]
- ⚠️ Significant privacy controversy — investigated by EU DPAs; opt-out form
  available at https://pimeyes.com/en/opt-out (irreversible, requires ID)
- Index claimed at ~3.5B images [verify 2026-04-25]
```

**FaceCheck.id (face search, pay-per-search):**
```
https://facecheck.id
- Per-search pricing model (no monthly subscription required)
- Smaller but social-media-leaning index (~763M public images claimed
  [verify 2026-04-25])
- Often the better choice when the target image is low-quality, masked,
  or non-frontal
- States that uploaded probe images are deleted post-processing and not
  used for training (verify in current ToS before relying on this)
```

**Bing Visual Search:**
```
https://www.bing.com/visualsearch
- Upload image
- Often finds shopping/product matches
- Good for identifying objects, brands
```

**Baidu Image Search (China):**
```
https://image.baidu.com
- Essential for Chinese web content
- Click camera icon (相机图标)
- Upload image
```

### Reverse Search Aggregators

**Search4Faces:**
```bash
# Multi-platform face search (Russian-language UI; English available)
https://search4faces.com/

# Current databases (verify on the site — they expand periodically):
# - VK avatars + main profile photos
# - Odnoklassniki (OK) avatars + main photos
# - TikTok user avatars (avatar only, not video frames)
# - Clubhouse user avatars
# - Celebrity datasets (Wikipedia, IMDb)
# Free tier with limited daily searches; paid tier for higher volume
```

---

## 3. EXIF Metadata Extraction

### Understanding EXIF Data

**What EXIF contains:**
- Camera make/model
- Date/time taken
- GPS coordinates (if enabled)
- Camera settings (ISO, aperture, shutter speed)
- Software used (editing apps leave traces)
- Copyright information
- Thumbnail preview

**⚠️ Platform stripping:**
Most social media platforms strip EXIF data on upload (✓ = stripped):
- X (Twitter): ✓ Strips GPS, keeps some camera info
- Facebook: ✓ Strips all EXIF
- Instagram: ✓ Strips all EXIF
- TikTok: ✓ Strips EXIF on uploaded video; avatar/image uploads also stripped
- Bluesky: ✓ Strips EXIF on image post; the embedded thumbnail is re-encoded
- Mastodon: ✓ Strips EXIF by default (server-config dependent — some
  instances preserve it; verify with target instance)
- WhatsApp: ✓ Strips EXIF, compresses image
- Signal: ✓ Strips EXIF
- Telegram: ✗ Preserves EXIF if sent as "File" / document (not "photo")
- Discord: ✗ Preserves EXIF on direct image attachments [verify 2026-04-25]
- Email (SMTP/IMAP): ✗ Preserves EXIF (mail clients do not re-encode)

### EXIF Extraction Tools

**ExifTool (comprehensive):**
```bash
# Install
# Ubuntu/Debian: sudo apt install libimage-exiftool-perl
# macOS: brew install exiftool
# Windows: Download from https://exiftool.org/

# Basic extraction
exiftool image.jpg

# Output to file
exiftool image.jpg > exif_data.txt

# Extract specific fields
exiftool -GPSLatitude -GPSLongitude -DateTimeOriginal image.jpg

# Batch process directory
exiftool -r /path/to/images/ > all_exif.txt

# GPS coordinates only
exiftool -gpslatitude -gpslongitude -n image.jpg
# Output: GPS Latitude: 37.7749, GPS Longitude: -122.4194

# Check for software/editing traces
exiftool -Software -CreatorTool image.jpg
# May reveal: Photoshop, GIMP, Snapseed, etc.

# Extract thumbnail (embedded preview)
exiftool -b -ThumbnailImage image.jpg > thumbnail.jpg
# Sometimes thumbnail shows pre-edit version!
```

### GPS Coordinate Analysis

**Convert GPS to decimal degrees:**
```bash
# EXIF stores GPS as degrees, minutes, seconds
# Example: 37°46'29.64"N 122°25'9.96"W

# ExifTool can output decimal
exiftool -n -gpslatitude -gpslongitude image.jpg
# Output: 37.7749, -122.4194

# Manual conversion formula:
# Decimal = Degrees + (Minutes/60) + (Seconds/3600)
# Example: 37 + (46/60) + (29.64/3600) = 37.7749
```

**Visualize GPS location:**
```bash
# Google Maps link
https://www.google.com/maps?q=37.7749,-122.4194

# Or use exiftool to generate KML (Google Earth)
exiftool -p gpx.fmt -r /path/to/images/ > photos.gpx
# Import photos.gpx into Google Earth
```

---

## 4. Image Forensics & Verification

### Error Level Analysis (ELA)

**Purpose:** Detect manipulated regions (different compression levels indicate editing)

**Using FotoForensics:**
```
1. Navigate to https://fotoforensics.com
2. Upload image
3. Click "Error Level Analysis"
4. Interpretation:
   - Similar brightness = untouched
   - Bright areas = recently edited/added
   - ⚠️ Not definitive — ELA produces false positives on JPEGs that have
     been re-saved at different qualities, screen-captured, or exported
     from editors that re-compress losslessly. Treat as a lead, not proof.
```

**Command-line ELA:**
```bash
# Using ImageMagick
convert image.jpg -quality 95 temp.jpg
composite image.jpg temp.jpg -compose difference ela_output.jpg
convert ela_output.jpg -auto-level ela_enhanced.jpg

# View ela_enhanced.jpg
# Bright areas indicate potential manipulation
```

### Clone Detection

```bash
# Detect copy-paste regions within image
# Using imagemagick and comparison

# Method 1: Visual inspection after enhancement
convert image.jpg -contrast -contrast -contrast enhanced.jpg

# Method 2: Python with opencv (advanced)
# Requires: pip install opencv-python numpy
python3 << 'EOF'
import cv2
import numpy as np

img = cv2.imread('image.jpg')
gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

# Find repeated patterns (SIFT features)
sift = cv2.SIFT_create()
kp, des = sift.detectAndCompute(gray, None)

# Match features to themselves (finds clones)
bf = cv2.BFMatcher()
matches = bf.knnMatch(des, des, k=2)

# Filter for strong matches (potential clones)
clones = []
for m, n in matches:
    if m.distance < 0.75 * n.distance:
        clones.append(m)

print(f"Potential clone regions: {len(clones)}")
EOF
```

### Metadata Consistency Checks

```bash
# Check for timestamp mismatches
exiftool -Time:All image.jpg

# Look for:
# - File creation date vs. EXIF date (should match if original)
# - Multiple date fields with different values (indicates editing)
# - Future dates (system clock manipulation)

# Example output analysis:
# File Modification Date/Time: 2024:10:05 14:30:00
# Create Date: 2020:05:10 08:15:30  # ← EXIF date
# Date/Time Original: 2020:05:10 08:15:30
# Modify Date: 2024:09:15 10:20:00  # ← Edited in September 2024!
```

### Shadow & Lighting Analysis

**Sun position verification:**
```
1. Identify claimed date/time and location
2. Calculate sun position for that date/time/location
3. Compare with shadows in image

Tool: SunCalc - https://www.suncalc.org/
- Enter location coordinates
- Set date and time
- View sun azimuth (direction) and altitude (angle)
- Compare with shadow direction/length in image

Tool: ShadowFinder (Bellingcat) - https://github.com/bellingcat/ShadowFinder
- Inverse problem of SunCalc: given an object's height, shadow length,
  date and time (UTC), returns a band of possible Earth-surface locations
- Useful when location is UNKNOWN but timestamp is known (e.g., conflict
  footage with visible vertical references — lamp posts, doorways)
- Available as a Python package + Jupyter / Google Colab notebook; install
  via `pip install shadowfinder` (see repo README for current Python API
  signature — argument names have shifted across releases) [verify 2026-04-25]
```

**Example:**
```markdown
**Claim:** Photo taken in Paris (48.8566°N, 2.3522°E) on June 21, 2024 at 12:00 PM

**Sun position (SunCalc):**
- Azimuth: 180° (due south)
- Altitude: 64° (high in sky)
- Expected shadow: Short, pointing north

**Actual shadow in image:**
- Direction: Northeast
- Length: Long
- **Conclusion:** ⚠️ Inconsistent - shadows suggest morning (9-10 AM) or different location
```

---

## 5. Geolocation Techniques

### Landmark Identification

**Method 1: Architectural features**
```markdown
Look for distinctive elements:
- Building style (modernist, Soviet-era, colonial, etc.)
- Roof types (flat, pitched, tiled, metal)
- Window styles (shutters, bars, ac units)
- Balcony designs
- Street furniture (benches, lights, bins)

Cross-reference with:
- Google Images: "distinctive building [city]"
- OpenStreetMap: Browse area for matching structures
- Google Earth: 3D view to match angles
```

**Method 2: Text clues**
```bash
# OCR text from signs, storefronts, license plates
tesseract image.jpg output -l eng

# Output: output.txt contains extracted text
cat output.txt
# Example: "КАФЕ" (Russian) → likely Russia/former USSR
#          "Pharmacie" (French) → France/French-speaking region
#          "+1-555-" (phone) → North America (country code +1)

# Search extracted text
# "Café de Paris" → Google: "Café de Paris" + visible landmarks
```

**Method 3: Street View matching**
```
1. Identify approximate area from other clues
2. Use Google Street View
3. Navigate streets looking for matching:
   - Building facades
   - Street signs
   - Landmarks visible in background
   - Road markings, curb styles

Tool: Google Street View - https://www.google.com/maps (drag pegman icon)
Tool: Mapillary - https://www.mapillary.com (crowdsourced street imagery,
       owned by Meta; CC-BY-SA imagery, large global coverage)
Tool: KartaView - https://kartaview.org (crowdsourced street imagery,
       operated by Grab; CC-BY-SA, complementary coverage to Mapillary)
Tool: Panoramax - https://panoramax.fr (open-source, federated street
       imagery; growing OSM-aligned coverage) [verify 2026-04-25]
```

**Method 4: OSM tag-based search (Overpass Turbo)**
```
When you suspect a region but need to filter for specific features
(e.g., "all McDonald's within 5km of Yekaterinburg centre", "all churches
with onion domes in city X", "all roundabouts with a fountain"):

1. Open https://overpass-turbo.eu/
2. Set the bbox to the suspected region (zoom + click "current view")
3. Write an Overpass QL query, e.g. for fast-food chains:
     [out:json][timeout:25];
     area[name="Yekaterinburg"]->.searchArea;
     node["amenity"="fast_food"]["brand"="McDonald's"](area.searchArea);
     out;
4. Click "Run" → results plot on the map; click a node to get coordinates,
   then verify with Street View / Mapillary

Bellingcat publishes Overpass Turbo recipes at
https://bellingcat.gitbook.io/toolkit/ for common geolocation patterns.
```

### Environmental Clues

**Vegetation & climate:**
```markdown
- Palm trees → tropical/subtropical
- Deciduous trees (no leaves) → winter in temperate zone
- Snow → winter (northern hemisphere: Dec-Feb, southern: Jun-Aug)
- Dry/brown grass → summer or arid climate
- Monsoon flooding → specific seasonal regions (India: Jun-Sep)

Cross-reference with:
- Claimed date (does climate match season?)
- Köppen climate classification map
```

**Transportation & vehicles:**
```markdown
**License plates:**
- Color scheme (EU: white/blue, US: varies by state)
- Format (UK: AB12 CDE, Russia: А123ВС)
- Language/script (Latin, Cyrillic, Arabic, Chinese)

**Road signs:**
- Shape (US: diamond for warnings, EU: triangle)
- Color (US: yellow warnings, EU: red/white)
- Language
- Measurement units (km/h vs mph)

**Traffic direction:**
- Left-hand drive: UK, Japan, India, Australia, South Africa
- Right-hand drive: Most of the world

**Vehicle types:**
- Specific models sold only in certain regions
- Commercial vehicle branding (regional companies)
- Emergency vehicle livery (police/ambulance colors vary)
```

**Utility infrastructure:**
```markdown
- Power line styles (overhead vs underground)
- Transformer boxes (designs vary by country)
- Manhole covers (often stamped with city name/utility company)
- Street lights (style, color, height)
- Fire hydrants (US has above-ground, many countries use underground)
```

### Language & Culture

**Script identification:**
```markdown
- Cyrillic → Russia, Ukraine, Belarus, Serbia, Bulgaria, Kazakhstan
- Arabic → Middle East, North Africa
- Chinese (Simplified) → China, Singapore
- Chinese (Traditional) → Taiwan, Hong Kong
- Japanese (Hiragana/Katakana) → Japan
- Korean (Hangul) → Korea
- Thai → Thailand
- Hebrew → Israel
```

**Cultural markers:**
```markdown
- Advertising styles (language, brands)
- Religious symbols (mosques, churches, temples)
- National flags
- Sports team logos/colors
- Store chains (regional/national)
```

### Coordinate Matching

**Using reference images:**
```
1. Identify potential location (city/neighborhood)
2. Find reference images from same location (Google Images, Flickr)
3. Match specific features:
   - Window count on building
   - Signage exact positions
   - Sidewalk patterns
   - Tree locations

Tool: GeoGuessr - https://www.geoguessr.com
- Practice identifying locations from Street View
- Builds pattern recognition skills
```

**Satellite imagery:**
```
1. Google Earth Pro (desktop version - free)
2. Navigate to suspected area
3. Use historical imagery feature (clock icon)
   - View location at different dates
   - Match vegetation, construction, parked vehicles
4. Measure distances between landmarks
5. Match roof shapes, building shadows

Tool: Google Earth Pro - https://www.google.com/earth/versions/#earth-pro
```

---

## 6. Video Analysis

### Video Intake & Preservation

**Download original quality:**
```bash
# YouTube (using yt-dlp - successor to youtube-dl)
yt-dlp -f "bestvideo+bestaudio" "https://www.youtube.com/watch?v=VIDEO_ID"

# Download with metadata
yt-dlp --write-info-json --write-thumbnail "https://www.youtube.com/watch?v=VIDEO_ID"

# Twitter video
yt-dlp "https://twitter.com/user/status/TWEET_ID"

# Instagram video
yt-dlp "https://www.instagram.com/p/POST_ID/"

# TikTok
yt-dlp "https://www.tiktok.com/@user/video/VIDEO_ID"

# Facebook
yt-dlp "https://www.facebook.com/user/videos/VIDEO_ID"

# Calculate hash
sha256sum video.mp4 > video.mp4.sha256
```

### Keyframe Extraction

**Extract frames for reverse search:**
```bash
# Using ffmpeg (install: apt install ffmpeg / brew install ffmpeg)

# Extract one frame per second
ffmpeg -i video.mp4 -vf fps=1 frame_%04d.jpg

# Extract one frame every 10 seconds
ffmpeg -i video.mp4 -vf fps=1/10 frame_%04d.jpg

# Extract specific frame (at 5 seconds)
ffmpeg -ss 00:00:05 -i video.mp4 -frames:v 1 frame_at_5s.jpg

# Extract keyframes only (scene changes)
ffmpeg -i video.mp4 -vf "select='eq(pict_type,I)'" -vsync vfr keyframe_%04d.jpg

# High-quality extraction
ffmpeg -i video.mp4 -qscale:v 2 frame_%04d.jpg
```

**Batch reverse search frames:**
```bash
# Upload each frame to reverse image search engines
# Manual: Upload frame_%04d.jpg files one by one
# Automated (using Google Custom Search API):

for frame in frame_*.jpg; do
    echo "Searching: $frame"
    # Upload to temporary host or use API
    # Compare results
done
```

### Video Metadata Extraction

```bash
# ffprobe (comes with ffmpeg)
ffprobe -v quiet -print_format json -show_format -show_streams video.mp4 > video_metadata.json

# Human-readable output
ffprobe video.mp4

# Specific fields
ffprobe -show_entries format=duration,bit_rate,size -of default=noprint_wrappers=1 video.mp4

# GPS location (if embedded - rare)
ffprobe -show_entries format_tags=location -of default=noprint_wrappers=1:nokey=1 video.mp4

# Creation time
ffprobe -show_entries format_tags=creation_time -of default=noprint_wrappers=1:nokey=1 video.mp4

# ExifTool also works with video
exiftool video.mp4
```

### Audio Analysis

**Extract audio track:**
```bash
# Extract audio as WAV
ffmpeg -i video.mp4 -vn -acodec pcm_s16le audio.wav

# Extract audio as MP3
ffmpeg -i video.mp4 -vn -acodec libmp3lame audio.mp3

# Analyze audio for clues:
# - Language spoken
# - Background sounds (sirens, traffic, birds, weather)
# - Music (Shazam, SoundHound for identification)
# - Accents/dialects
```

**Speech-to-text (transcription):**
```bash
# Using Whisper (OpenAI - highly accurate)
# Install: pip install openai-whisper

whisper audio.mp3 --model medium --language en --output_format txt

# Output: audio.txt with transcription
# Useful for:
# - Identifying names, locations mentioned
# - Searching transcript for keywords
# - Timestamp verification (mentions of time/date)
```

### Video Verification

**InVID / WeVerify Verification Plugin (now "Fake News Debunker"):**
```
The plugin originated in EU project InVID (2016-2018), was extended in
WeVerify (2018-2021), and is now maintained by AFP Medialab R&D under the
vera.ai project (https://www.veraai.eu/). Marketed as "Fake News Debunker
by InVID & WeVerify" on the Chrome Web Store.

Chrome:  https://chromewebstore.google.com/detail/fake-news-debunker-invid/mhccpoafgdgbhnjfhkcmgknndkeenfhe
Firefox: https://addons.mozilla.org/firefox/addon/fake-news-debunker-by-invid-we/

Features (current):
- Keyframe extraction from major social-video platforms
- One-click reverse image search across Google Lens, Yandex, Bing, TinEye,
  Baidu, Karma Decay
- EXIF / video metadata viewer
- Tesseract OCR on frames
- Video magnifier + per-frame inspection
- Forensic image analysis (ELA, copy-move, JPEG ghosts)
- WACZ disinformation-archiving panel (since v0.85)
- Hiya-powered voice-clone detector for audio (since v0.85) [verify 2026-04-25]

Usage:
1. Install browser extension (Chrome / Edge / Firefox)
2. Click toolbar icon → paste video URL OR right-click video → analyse
3. Extract keyframes → reverse-search each
4. Cross-check metadata, audio, and provenance signals
```

**Deepfake detection — manual analysis:**
```markdown
Signs of deepfakes (still useful for older / lower-quality fakes; modern
diffusion-based and lip-sync models defeat most of these):
- Unnatural blinking patterns (or lack of blinking)
- Inconsistent lighting on face vs background
- Blurry face edges (especially around hairline, glasses frames, earrings)
- Mismatched skin tones (face vs neck)
- Lip sync errors / phoneme-viseme mismatches
- Unnatural head movements; "swimming" forehead/jawline at frame transitions
- Background inconsistencies (person moves, background doesn't, or vice versa)
- Pupillary corneal-reflection mismatch between left and right eye
- Single-row tooth artefacts (teeth rendered as a flat texture rather than
  individually shaped)
- Unnatural earlobes / asymmetric earrings (common GAN failure mode)
```

**Deepfake detection — tools (2026 landscape):**

> ⚠️ **Honest baseline:** No deepfake detector is currently reliable enough
> to use alone for decision-making. Detector accuracy varies dramatically
> by generator family (face-swap vs lip-sync vs diffusion vs voice-clone),
> degrades on compressed social-media re-encodes, and lags new generation
> techniques by months. Always combine ≥2 detectors with manual analysis
> AND a provenance check (see C2PA below).

| Tool | Modality | Access | Notes |
|------|----------|--------|-------|
| Microsoft Video Authenticator | Video | **Limited release only** — never reached general availability; access via Microsoft's Election Communications / AI for Good partners | Originally announced 2020; per-frame confidence score [verify 2026-04-25] |
| Intel FakeCatcher | Real-time video | Commercial / OEM integration | Uses photoplethysmography (PPG) blood-flow signal; vendor-claimed ~96% controlled / ~91% in-the-wild [verify 2026-04-25] |
| Reality Defender | Video, image, audio, text | Commercial API + portal | Multi-model ensemble; common choice for newsroom / enterprise pipelines |
| Sensity AI | Image + video, identity-focused | Commercial | Strong on face-swap and synthetic-portrait attribution |
| Hive AI Moderation | Image, video, audio | Commercial API | Used by Reddit, BlueSky for content moderation; AI-generated-content classifier exposed via API |
| AI or Not | Image (single-shot) | Free tier + paid | Fast, no-account checks; independent benchmarks place accuracy <90% on mixed-generator test sets [verify 2026-04-25] |
| Deepware Scanner | Video upload | Free | Web upload; useful as a triage second opinion |
| Manual frame-by-frame in DaVinci Resolve / Premiere / VLC | Any | Free | Slow but defeats most automated countermeasures |

**AI-image detectors — explicit caveat:**
```markdown
Generative-image detection (single still image, no provenance signal) is
NOT reliable in 2026. False-positive rates of 6–12% are typical on real
photos that look "AI-like" (smooth skin, cinematic lighting). Treat any
single-detector verdict on a still image as a weak signal. Provenance
metadata (C2PA) and reverse-image-search for an earlier human-attributed
instance are stronger evidence.
```

### Synthetic Media Provenance (C2PA Content Credentials)

**What it is:**
C2PA (Coalition for Content Provenance and Authenticity) is a cross-vendor
standard for cryptographically-signed provenance metadata embedded in
images, video, audio, and PDFs. The user-facing brand is "Content
Credentials". A C2PA manifest records who produced or modified an asset,
which tools were used, and (optionally) whether AI was involved.

**Adoption snapshot (as of 2026-04-25):**
- **Adobe** — Photoshop, Lightroom, Firefly attach C2PA manifests
- **OpenAI** — DALL·E 3 and ChatGPT image outputs attach C2PA + visible
  marker; OpenAI is on the C2PA steering committee
- **Google** — SynthID watermark on Imagen / Veo / Gemini image+video
  output (>20B images watermarked, vendor figure); Pixel 10 was the
  first phone certified for C2PA capture
- **Microsoft** — Bing Image Creator, M365 content (rollout from
  Feb 2026 [verify 2026-04-25])
- **Meta** — AI-generated content labelling on Facebook/Instagram/Threads
- **Cameras** — Leica M11-P, Sony α1 II / α7 IV firmware, Nikon Z6 III,
  Canon (announced) support in-camera capture-side signing
- **EU AI Act Article 50** transparency obligations come into full effect
  2026-08-02 and effectively mandate machine-readable provenance for
  AI-generated content distributed in the EU [verify 2026-04-25]

**Inspecting C2PA manifests:**
```bash
# c2patool — Content Authenticity Initiative CLI (Rust)
# The original contentauth/c2patool repo was archived 2024-12-10 and merged
# into contentauth/c2pa-rs (the c2pa-rs CLI is the current build).
# Releases: https://github.com/contentauth/c2pa-rs/releases

# Read manifest from any signed asset (image/video/PDF/audio)
c2patool image.jpg

# Dump full JSON manifest (signers, ingredients, actions, AI assertions);
# refer to `c2patool --help` for the current flag set — flag names have
# shifted across releases. [verify 2026-04-25]
c2patool image.jpg --detailed
```

**Browser-side check:**
- Adobe-hosted verifier: https://contentcredentials.org/verify
  (drag-drop any file → manifest, signer, edit history)
- Content Credentials icon (the "CR" pin) appears in supporting viewers
  (Chrome via extension, Adobe apps, Microsoft Edge in some builds)

**Limitations to flag in any report:**
```markdown
- C2PA is opt-in: absence of a manifest does NOT mean the asset is fake
- Manifests can be stripped trivially (re-save, screenshot, social-media
  re-encode) — strip ≠ tamper
- Manifests can be forged with a non-trusted certificate; ALWAYS check
  the signing certificate's trust chain, not just "manifest present"
- C2PA proves what tool signed the asset; it does NOT prove the depicted
  scene is real (a real camera can photograph a screen showing a fake)
```

---

## 7. Specialized Techniques

### Facial Recognition (Ethical Use Only)

**⚠️ Legal Warning:** Facial recognition has legal restrictions in many jurisdictions. Use only when legally authorized.

**PimEyes (commercial):**
```
https://pimeyes.com
- Upload face photo (crop to just face)
- Finds other instances online (open web only — no social media)
- Results include: news articles, blogs, image-hosting sites
- Pricing/restrictions: see §2.5 above
- ⚠️ Privacy implications — use only with documented legal basis
```

**FaceCheck.id (commercial, social-leaning):**
```
https://facecheck.id
- Per-search pricing; better signal on social-media-sourced faces
- See §2.5 above for full details
```

**Search4Faces (social media specific):**
```
https://search4faces.com/
- Searches: VK, Odnoklassniki, TikTok avatars, Clubhouse, celebrity DBs
- Better for Eastern European profiles
- Free tier (limited searches)
```

**Face comparison (manual verification):**

> **Maintenance note:** `ageitgey/face_recognition` (the historical
> "simplest face recognition" Python wrapper around dlib) has not seen
> a release since 2020 and dlib itself moves slowly. For new work prefer
> [DeepFace](https://github.com/serengil/deepface) — actively maintained,
> wraps modern backbones (ArcFace, FaceNet, VGG-Face, SFace, GhostFaceNet)
> with a single API.

```python
# Modern path — DeepFace (pip install deepface)
from deepface import DeepFace

# Verify whether two images depict the same person
result = DeepFace.verify(
    img1_path="person1.jpg",
    img2_path="person2.jpg",
    model_name="ArcFace",        # ArcFace / Facenet512 are strong defaults
    detector_backend="retinaface" # robust face detection
)
print(result)
# {'verified': True/False, 'distance': 0.42, 'threshold': 0.68, ...}

# Bulk search: find all matches for a probe inside a directory
dfs = DeepFace.find(
    img_path="probe.jpg",
    db_path="reference_set/",
    model_name="ArcFace"
)
```

```python
# Legacy path — face_recognition (still works, but unmaintained)
# pip install face_recognition
import face_recognition

image1 = face_recognition.load_image_file("person1.jpg")
image2 = face_recognition.load_image_file("person2.jpg")
encoding1 = face_recognition.face_encodings(image1)[0]
encoding2 = face_recognition.face_encodings(image2)[0]

results = face_recognition.compare_faces([encoding1], encoding2)
distance = face_recognition.face_distance([encoding1], encoding2)
print(f"Match: {results[0]}, Distance: {distance[0]:.3f}")
# distance < 0.6 ≈ same person (default threshold)
```

### License Plate Recognition

**OCR extraction:**
```bash
# Crop image to just license plate
convert original.jpg -crop 200x50+100+200 plate.jpg

# Enhance contrast
convert plate.jpg -contrast -contrast enhanced_plate.jpg

# OCR
tesseract enhanced_plate.jpg plate_text

# Output: plate_text.txt
cat plate_text.txt
# Example: ABC1234

# Search plate format to identify region
# US: varies by state (CA: 7ABC123, NY: ABC-1234)
# EU: typically country code + numbers (D-AB 1234 for Germany)
# UK: AB12 CDE format
```

**Automated ALPR (Automatic License Plate Recognition):**
```bash
# OpenALPR (open-source) — repo at github.com/openalpr/openalpr
# OpenALPR was acquired by Rekor Systems; the open-source repo has been
# largely stagnant since 2021 [verify 2026-04-25]. Still works on
# common Western plate formats, but accuracy on modern EU/Asian formats
# is best-in-class only via the commercial alternatives below.
alpr -c us plate_image.jpg            # Output: plate + confidence score
alpr -c eu -n 10 plate_image.jpg      # Top 10 matches, EU pattern set

# Modern alternatives:
# - Plate Recognizer (https://platerecognizer.com) — hosted API; free tier
#   ~2,500 lookups/month for non-commercial use [verify 2026-04-25]
# - ultimateALPR SDK (https://github.com/DoubangoTelecom/ultimateALPR-SDK) —
#   open-source SDK, GPL3, strong on Asian and Arabic plates
# - V0LT Predator (https://github.com/connervieira/Predator) — open-source
#   wrapper around OpenALPR with extra ergonomics
```

### Reverse Video Search

**YouTube DataViewer (Amnesty International):**
```
https://citizenevidence.amnestyusa.org/

Features:
- Extract thumbnails from YouTube video
- Reverse search thumbnails
- Get upload date/time (forensic timeline)
- Find re-uploads of same video

Usage:
1. Paste YouTube URL
2. Tool extracts thumbnails
3. Click reverse search icons
4. Compare results across engines
```

**Manual video fingerprinting:**
```bash
# Generate video hash (perceptual)
ffmpeg -i video.mp4 -vf "scale=8:8,format=gray" -f image2pipe -vcodec ppm - | sha256sum

# Compare two videos (similarity)
# Using ffmpeg to extract fingerprints, then compare
```

---

## 8. Tools Reference

### Essential Tools

| Tool | Purpose | Platform | Link |
|------|---------|----------|------|
| **ExifTool** | Metadata extraction | CLI (all platforms) | [exiftool.org](https://exiftool.org) |
| **Google Images / Lens** | Reverse image search | Web | [images.google.com](https://images.google.com) |
| **Yandex Images** | Reverse search (faces, Cyrillic) | Web | [yandex.com/images](https://yandex.com/images) |
| **TinEye** | Reverse search (temporal / oldest instance) | Web / API | [tineye.com](https://tineye.com) |
| **Bing Visual Search** | Reverse search (objects, products) | Web | [bing.com/visualsearch](https://www.bing.com/visualsearch) |
| **PimEyes** | Face search (open web) | Web (commercial) | [pimeyes.com](https://pimeyes.com) |
| **FaceCheck.id** | Face search (social-leaning) | Web (commercial, pay-per-search) | [facecheck.id](https://facecheck.id) |
| **Search4Faces** | Face search (VK / OK / TikTok / Clubhouse) | Web | [search4faces.com](https://search4faces.com) |
| **DeepFace** | Face comparison / verification | Python | [github.com/serengil/deepface](https://github.com/serengil/deepface) |
| **SunCalc** | Sun-position calculator | Web | [suncalc.org](https://www.suncalc.org) |
| **ShadowFinder** | Inverse sun-position (find lat/long from shadow) | CLI / Colab (Python) | [github.com/bellingcat/ShadowFinder](https://github.com/bellingcat/ShadowFinder) |
| **Google Earth Pro** | Satellite imagery, historical layers, 3D | Desktop (free) | [google.com/earth/versions](https://www.google.com/earth/versions/) |
| **Mapillary** | Crowdsourced street imagery | Web | [mapillary.com](https://www.mapillary.com) |
| **KartaView** | Crowdsourced street imagery (Grab) | Web | [kartaview.org](https://kartaview.org) |
| **Overpass Turbo** | OSM tag-based area queries | Web | [overpass-turbo.eu](https://overpass-turbo.eu) |
| **ffmpeg / ffprobe** | Video processing + metadata | CLI | [ffmpeg.org](https://ffmpeg.org) |
| **yt-dlp** | Social-video download | CLI (Python) | [github.com/yt-dlp/yt-dlp](https://github.com/yt-dlp/yt-dlp) |
| **InVID / WeVerify (vera.ai)** | Video verification toolkit | Browser extension | [veraai.eu](https://www.veraai.eu/) |
| **Tesseract OCR** | Text extraction | CLI | [github.com/tesseract-ocr/tesseract](https://github.com/tesseract-ocr/tesseract) |
| **ImageMagick** | Image manipulation | CLI | [imagemagick.org](https://imagemagick.org) |
| **FotoForensics** | Error-level analysis | Web | [fotoforensics.com](https://fotoforensics.com) |
| **Whisper** | Audio transcription | CLI (Python) | [github.com/openai/whisper](https://github.com/openai/whisper) |
| **Intel FakeCatcher** | Real-time deepfake detection (PPG) | OEM / commercial | [intel.com/.../trusted-media-deepfake-detection](https://www.intel.com/content/www/us/en/research/trusted-media-deepfake-detection.html) |
| **Reality Defender** | Multi-modal deepfake detection | Commercial API | [realitydefender.com](https://www.realitydefender.com) |
| **Sensity AI** | Identity-focused deepfake detection | Commercial | [sensity.ai](https://sensity.ai) |
| **AI or Not** | Single-image AI-generation check | Web (free tier) | [aiornot.com](https://www.aiornot.com) |
| **C2PA c2patool** | Inspect Content Credentials | CLI (Rust) | [github.com/contentauth/c2pa-rs](https://github.com/contentauth/c2pa-rs) |
| **Content Credentials Verify** | Browser-side C2PA check | Web | [contentcredentials.org/verify](https://contentcredentials.org/verify) |
| **Plate Recognizer** | ALPR (hosted, free tier) | Web / API | [platerecognizer.com](https://platerecognizer.com) |
| **GeoGuessr** | Geolocation practice | Web | [geoguessr.com](https://www.geoguessr.com) |
| **Bellingcat Toolkit** | Curated OSINT tool index | Web | [bellingcat.gitbook.io/toolkit](https://bellingcat.gitbook.io/toolkit/) |

### Quick Command Reference

```bash
# Download image
wget -O image.jpg "URL"

# Hash image
sha256sum image.jpg

# Extract EXIF
exiftool image.jpg

# GPS coordinates
exiftool -n -gpslatitude -gpslongitude image.jpg

# Download video (best quality)
yt-dlp -f "bestvideo+bestaudio" "URL"

# Extract video frames (1 per second)
ffmpeg -i video.mp4 -vf fps=1 frame_%04d.jpg

# OCR text from image
tesseract image.jpg output

# Video metadata
ffprobe video.mp4

# Extract audio
ffmpeg -i video.mp4 -vn audio.mp3

# Transcribe audio
whisper audio.mp3 --model medium
```

---

## 9. Workflow Examples

### Workflow 1: Verify Profile Picture Authenticity

```markdown
**Scenario:** Suspect Instagram profile photo is stolen from someone else

1. **Download image**
   - Right-click → Save Image (get full resolution)
   - sha256sum profile_pic.jpg

2. **Reverse search**
   - Google Images: Upload → Search
   - Yandex Images: Upload → Search (better for faces)
   - TinEye: Upload → Sort by "Oldest"

3. **Analyze results**
   - If found: Note earliest instance (original source?)
   - Check dates: Profile created 2024, but image appears in 2020 blog post → stolen
   - Compare accounts: Different names → likely stolen

4. **EXIF check** (if original available)
   - exiftool original_photo.jpg
   - Check camera/software metadata
   - Look for GPS coordinates (cross-reference with claimed location)

5. **Conclusion**
   - Document findings in collection log
   - Screenshot evidence of original source
   - Hash all evidence files
```

### Workflow 2: Geolocate Unknown Photo

```markdown
**Scenario:** Photo shows street scene, need to identify location

1. **Extract visible clues**
   - Language on signs: "Кафе" (Russian Cyrillic)
   - License plates: Format suggests Russia/Ukraine
   - Architecture: Soviet-era apartment blocks
   - Vegetation: Deciduous trees with leaves → summer

2. **OCR text**
   - tesseract street_scene.jpg output
   - Extract: "Улица Ленина" (Lenin Street - very common in former USSR)
   - Store name: "Пятёрочка" (Pyaterochka - Russian grocery chain)

3. **Narrow region**
   - Cyrillic + Pyaterochka → Russia (chain doesn't operate in Ukraine)
   - Architecture style → 1960s-80s construction → most Russian cities

4. **Landmark search**
   - Identify distinctive building in background
   - Google Images: "soviet apartment building russia distinctive tower"
   - Found: Similar building in Yekaterinburg

5. **Street View verification**
   - Google Maps: Search "Pyaterochka Yekaterinburg"
   - Navigate Street View around Pyaterochka locations
   - Match building facades, street signs
   - **Found:** Ulitsa Lenina 15, Yekaterinburg (56.8389°N, 60.5973°E)

6. **Verification**
   - Google Earth: Check satellite view matches
   - Check shadows: SunCalc → verify time of day matches shadows
   - Screenshot Street View match for evidence
```

### Workflow 3: Verify Video Timestamp

```markdown
**Scenario:** Video claims to show event on specific date, verify accuracy

1. **Download and hash**
   - yt-dlp "VIDEO_URL"
   - sha256sum video.mp4

2. **Extract metadata**
   - exiftool video.mp4 | grep -i date
   - Check upload date vs claimed event date

3. **Extract keyframes**
   - ffmpeg -i video.mp4 -vf fps=1/10 frame_%04d.jpg
   - Reverse search frames (check for earlier instances online)

4. **Weather verification**
   - Identify location in video
   - Check historical weather for claimed date
   - Compare with weather shown in video (rain, snow, clear, etc.)
   - Tool: timeanddate.com/weather (historical weather)

5. **Shadow analysis**
   - Identify GPS coordinates of location
   - Use SunCalc for claimed date/time
   - Measure shadow direction/length in video
   - Compare with expected shadow for that time
   - **Result:** Shadows indicate 10 AM, but claim says 2 PM → discrepancy

6. **Conclusion**
   - Video is genuine, but timestamp claim is false
   - Evidence suggests video taken earlier in day
   - Document findings with SunCalc screenshots
```

---

## 10. Best Practices & Pitfalls

### ❌ Common Mistakes

**1. Over-reliance on single source**
```
❌ Bad: "Google reverse search found nothing, therefore image is original"
✅ Good: Search Google, Yandex, TinEye, Bing minimum before concluding

❌ Bad: "EXIF says photo taken in Paris, so it's from Paris"
✅ Good: EXIF can be easily spoofed - verify with visual clues
```

**2. Ignoring social media platform metadata stripping**
```
❌ Bad: Download from Twitter → check EXIF → "no GPS data, can't geolocate"
✅ Good: Know that Twitter strips GPS → use visual geolocation techniques instead
```

**3. Certainty without corroboration**
```
❌ Bad: "Shadows suggest this was taken at 3 PM"
✅ Good: "Shadow analysis suggests 3 PM ± 30 minutes, consistent with claimed timestamp"

Always provide:
- Confidence level (high/medium/low)
- Alternative explanations
- Limiting factors (quality, partial view, etc.)
```

**4. Forgetting to preserve originals**
```
❌ Bad: Download → crop → enhance → analyze cropped version
✅ Good: Download → hash → save original → create working copy → analyze copy

Never modify original evidence files
```

**5. Tunnel vision on initial hypothesis**
```
❌ Bad: "I think this is Moscow, so I'll only check Moscow landmarks"
✅ Good: "Clues suggest Russia, checking major cities: Moscow, St. Petersburg, Yekaterinburg..."

Remain objective - let evidence guide you
```

### ✅ Best Practices

**1. Multi-engine reverse search (always)**
```markdown
Minimum search engines:
- [ ] Google Images
- [ ] Yandex Images
- [ ] TinEye
- [ ] Bing Visual Search
- [ ] Baidu (if Chinese content suspected)

Document results from each
```

**2. Crop and re-search**
```bash
# If full image yields no results, try cropping to specific elements:
# - Just the face
# - Just a landmark
# - Just a logo/sign

convert original.jpg -crop 300x300+100+50 cropped_face.jpg
# Then reverse search cropped_face.jpg
```

**3. Time permitting, do it twice**
```markdown
Have two analysts independently:
1. Attempt geolocation
2. Compare results
3. Resolve discrepancies

Peer review catches errors and biases
```

**4. Document uncertainty**
```markdown
Report template:
- **Confidence:** Medium
- **Location:** Likely Yekaterinburg, Russia (coordinates: 56.8389°N, 60.5973°E)
- **Basis:** Cyrillic signage, Pyaterochka store chain, architectural style
- **Limitations:** Cannot see street sign clearly, similar buildings exist in other cities
- **Alternative explanations:** Could be other Russian city with similar architecture
```

**5. Preserve processing chain**
```bash
# Keep all derivative files
original.jpg          (hash: a1b2c3d4...)
enhanced.jpg          (hash: b2c3d4e5...) - from: convert original.jpg -contrast enhanced.jpg
cropped.jpg           (hash: c3d4e5f6...) - from: convert original.jpg -crop 200x200+50+50 cropped.jpg

# Document in collection log:
# 1. Downloaded original.jpg from https://example.com/image.jpg (2025-10-05 14:30 UTC)
# 2. Created enhanced.jpg using ImageMagick convert -contrast command
# 3. Created cropped.jpg for reverse search (crop face only)
```

---

## 11. Legal & Ethical Considerations

> **Authority anchor:** This section summarises image/video-specific
> considerations only. The canonical legal-and-ethics framework lives in
> [[sop-legal-ethics|Legal & Ethics SOP]] — read it first; do not rely on
> the bullets below as a complete authority. For collection-side OPSEC
> (probe-image leakage to facial-recognition vendors, browser fingerprint
> exposure when uploading), see [[sop-opsec-plan|OPSEC Plan]].

### Privacy & Consent

**⚠️ Legal restrictions on facial recognition:**
- EU: GDPR Art. 9 treats biometric data as a special category — processing
  requires an explicit lawful basis (Art. 9(2)) AND, in many member
  states, a national-law derogation. The EU AI Act (in force 2024-08-01,
  staged enforcement) further restricts real-time remote biometric
  identification in public spaces.
- US: Varies sharply by state. Illinois BIPA, Texas CUBI, Washington
  HB 1493 impose private rights of action and consent requirements;
  most other states have minimal regulation. Federal sectoral laws
  (FERPA, HIPAA) may apply contextually.
- UK: UK GDPR + DPA 2018 mirror EU GDPR for biometric data; ICO has
  taken enforcement action against indiscriminate face-search providers.
- Always verify legal authority **before** uploading a probe image to
  any third-party facial-recognition service — the upload itself may
  constitute regulated processing.

**Ethical use guidelines:**
```markdown
✅ Appropriate use:
- Verifying identity of public figure making public statements
- Investigating suspected fraud/impersonation
- Missing persons cases (with family consent)
- Criminal investigations (with legal authority)

❌ Inappropriate use:
- Stalking or harassing individuals
- Doxxing (publishing private info)
- Surveillance without legal basis
- Commercial purposes without consent
```

### Chain of Custody

```markdown
Evidence collection checklist:
- [ ] Download original (highest quality)
- [ ] Calculate SHA-256 hash immediately
- [ ] Preserve EXIF metadata (even if stripped by platform)
- [ ] Document source URL, timestamp, collection method
- [ ] Never modify originals (work on copies)
- [ ] Log all processing steps (cropping, enhancement, etc.)
- [ ] Include tool versions (e.g. `exiftool -ver`, `ffmpeg -version`,
      `yt-dlp --version` — record output verbatim, do not paraphrase)
```

See also: [[sop-collection-log|Collection Log & Chain of Custody]]

---

**Quick Reference:**
- Reverse search: Google + Yandex + TinEye (minimum)
- EXIF: `exiftool image.jpg`
- GPS: `exiftool -n -gpslatitude -gpslongitude image.jpg`
- Video frames: `ffmpeg -i video.mp4 -vf fps=1 frame_%04d.jpg`
- OCR: `tesseract image.jpg output`

**Related SOPs:**
- [[sop-collection-log|Collection Log]]
- [[sop-reporting-packaging-disclosure|Reporting]]
- [[sop-legal-ethics|Legal & Ethics]] — authority on consent / biometric law
- [[sop-opsec-plan|OPSEC Plan]] — probe-image / browser-fingerprint hygiene
- [[sop-entity-dossier|Entity Dossier]] — where face / image findings get logged
- [Hash Generation](../../Security/Analysis/sop-hash-generation-methods.md)
- [Forensics Investigation](../../Security/Analysis/sop-forensics-investigation.md) — for chain-of-custody on seized media

**Additional Resources:**
- [Bellingcat Online Investigation Toolkit](https://bellingcat.gitbook.io/toolkit/) — curated, frequently-updated tool catalogue
- [vera.ai](https://www.veraai.eu/) — successor to InVID/WeVerify; verification-plugin home
- [Content Authenticity Initiative](https://contentauthenticity.org/) — C2PA reference implementations and policy resources
- [Gral Hix](https://gralhix.com/) - OSINT tools and resources
- [Benjamin Strick (Bene Brown)](https://www.youtube.com/c/bendobrown) - Geolocation and OSINT techniques
- [GeoRainbolt](https://www.youtube.com/@georainbolt) - Expert geolocation content
- [start.me OSINT Resources](https://start.me/u/gl0bal01) - Comprehensive OSINT tool directory
