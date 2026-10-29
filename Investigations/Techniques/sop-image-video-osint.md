---
type: sop
title: Image & Video OSINT
description: "Visual intelligence techniques: EXIF analysis, reverse image search, geolocation, video verification & deepfake detection for media investigations."
tags: [sop, media, exif, reverse, geolocation, verification]
template_version: 2026-04-25
updated: 2026-10-29
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
# Set name=orig in the image URL (undocumented by X; community-documented)
# https://pbs.twimg.com/media/IMAGE_ID?format=jpg&name=large
# Change to: https://pbs.twimg.com/media/IMAGE_ID?format=jpg&name=orig

# Instagram image download (bypass restrictions)
# Method 1: Browser console
# Right-click image → Inspect → Find <img> tag → Copy image URL
# Method 2: Instaloader — target is the post shortcode (the part after /p/ in the URL); caption is saved to a .txt by default [verify 2026-10-29]
instaloader --no-videos --no-video-thumbnails -- -SHORTCODE

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
# ImageMagick: perceptual-hash distance between two images (0 = identical) [verify 2026-10-29]
# (ImageMagick 7's primary command is `magick`; `compare`/`convert` remain as legacy links) [verify 2026-10-29]
compare -metric PHASH image1.jpg image2.jpg null:

# Or use Python with imagehash library [verify 2026-10-29]
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
```text
1. Navigate to https://images.google.com
2. Click the camera/lens icon in the search bar
3. Upload image OR paste image URL
4. In the Lens results pane, click "Find image source" (or "Exact matches")
   to surface the legacy reverse-search view with:
   - Pages that include matching images
   - Visually similar images
   - Other sizes
   (UI labels change; Google's help page documents only the "Search by image"
   icon and its "Upload a file" / "Paste image link" options) [verify 2026-10-29]
```

**Direct legacy URL (undocumented by Google; may bounce through a consent/Lens page — test before relying on it):** [verify 2026-10-29]
```text
# searchbyimage endpoint accepts a public image URL
https://www.google.com/searchbyimage?image_url=https://example.com/image.jpg
```

**Command-line method:**
```bash
# Using Google Custom Search API (requires API key + cx Programmable Search Engine ID) [verify 2026-10-29]
# Note: this is text search with image filter, not reverse-image upload — Google has no
# public reverse-image API.
curl "https://www.googleapis.com/customsearch/v1?q=SEARCH_TERM&cx=YOUR_CX&searchType=image&imgSize=large&key=YOUR_API_KEY"

# Headless browser upload (Selenium/Playwright) is the only reliable
# automated path for upload-based reverse search.
```

**Advanced techniques:**
```text
# Crop image to focus on specific element
# Example: Crop to just the face, or just a landmark
# Then reverse search the cropped version

# Adjust contrast/brightness before searching
# Some images may match better after enhancement [verify 2026-10-29]
convert image.jpg -brightness-contrast 10x20 enhanced.jpg
```

### Yandex Reverse Image Search

**Why Yandex is superior for faces:**
- Better facial recognition algorithm
- Indexes more Eastern European and Russian content
- Often finds results when Google fails

**Usage:**
```text
1. Navigate to https://yandex.com/images [verify 2026-10-29]
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
```text
1. Navigate to https://tineye.com
2. Upload image or paste URL
3. Sort results by: [verify 2026-10-29]
   - "Oldest" - find original source
   - "Most changed" - find manipulated versions
   - "Biggest image" - highest resolution

# TinEye API (commercial; API key sent in the X-API-KEY header, kept in an env var) [verify 2026-10-29]
curl -H "X-API-KEY: $TINEYE_API_KEY" \
  -F "image_upload=@image.jpg" \
  "https://api.tineye.com/rest/search/"
```

### Specialized Reverse Search Engines

**PimEyes (Face Search):**
```text
https://pimeyes.com
- Upload face photo → finds matches across the open web (excludes
  social-media and professional-network sites per their published scope) [verify 2026-10-29]
- Pricing tiers: Open Plus, PROtect, Advanced (paid plans required to view source URLs,
  set alerts, or use takedown features); free tier shows matches but hides source URLs [verify 2026-10-29]
- Pricing rendered client-side — confirm current plan prices on
  https://pimeyes.com/en/pricing [verify 2026-10-29]
- ⚠️ Significant privacy controversy — investigated by EU DPAs; opt-out form
  available at https://pimeyes.com/en/opt-out (requires a face photo and an anonymised ID scan) [verify 2026-10-29]
- Index size not published; CEO cited ~2.1B faces in a 2022 netzpolitik.org interview (via Bellingcat toolkit) [verify 2026-10-29]
```

**FaceCheck.id (face search, pay-per-search):**
```text
https://facecheck.id
- Per-search pricing model (no monthly subscription required) [verify 2026-10-29]
- Index described as "millions of faces" from mugshot and sex-offender sites
  and news-pictured suspects; no size figure published [verify 2026-10-29]
- Often the better choice when the target image is low-quality, masked,
  or non-frontal
- States that uploaded probe images are deleted and not indexed
  (verify in current ToS before relying on this) [verify 2026-10-29]
```

**Bing Visual Search:**
```text
https://www.bing.com/images (click the camera / visual-search icon) [verify 2026-10-29]
- Upload image
- Often finds shopping/product matches
- Good for identifying objects, brands
```

**Baidu Image Search (China):**
```text
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

# Current databases (verify on the site — they expand periodically): [verify 2026-10-29]
# - VK avatars + main profile photos
# - Odnoklassniki (OK) avatars + main photos
# - TikTok user avatars (avatar only, not video frames)
# - Clubhouse user avatars
# - Celebrity datasets (Wikipedia, IMDb)
# No search limits or pricing published on the site; API access (JSON-RPC, API key;
# free test key on request): https://search4faces.com/api.html [verify 2026-10-29]
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
Most social media platforms strip EXIF data on upload (✓ = stripped, ✗ = preserved,
~ = depends). The Facebook, Instagram, TikTok and WhatsApp entries are observed
behaviour the platforms do not document — test with a known-GPS file before relying on them:
- X (Twitter): ✓ EXIF not visible to viewers (X states it reads Exif only transiently while processing the photo) [verify 2026-10-29]
- Facebook: ✓ Strips all EXIF
- Instagram: ✓ Strips all EXIF
- TikTok: ✓ Strips EXIF on uploaded video; avatar/image uploads also stripped
- Bluesky: ✓ Strips EXIF on image post; the embedded thumbnail is re-encoded [verify 2026-10-29]
- Mastodon: ✓ Strips EXIF (local uploads unconditionally re-encoded since
  mastodon PR #8714, 2018; forks may differ) [verify 2026-10-29]
- WhatsApp: ✓ Strips EXIF, compresses image
- Signal: ✓ Strips EXIF [verify 2026-10-29]
- Telegram: ~ Sending as "File" (uncompressed) may keep EXIF, but it is client-dependent — Android paperclip → File was reported stripping GPS while iOS kept it (https://bugs.telegram.org/c/19150) [verify 2026-10-29]
- Discord: ✓ Strips EXIF from uploads (Discord engineering blog, March 2025: piexif-based removal); other metadata (XMP, PNG text) undocumented [verify 2026-10-29]
- Email (SMTP/IMAP): ✗ Preserves EXIF (mail clients do not re-encode)

### EXIF Extraction Tools

**ExifTool (comprehensive):**
```bash
# Install
# Ubuntu/Debian: sudo apt install libimage-exiftool-perl [verify 2026-10-29]
# macOS: brew install exiftool [verify 2026-10-29]
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

# Extract thumbnail (embedded preview) [verify 2026-10-29]
exiftool -b -ThumbnailImage image.jpg > thumbnail.jpg
# Sometimes thumbnail shows pre-edit version!
```

### GPS Coordinate Analysis

**Convert GPS to decimal degrees:**
```bash
# EXIF stores GPS as degrees, minutes, seconds
# Example: 37°46'29.64"N 122°25'9.96"W

# ExifTool can output decimal [verify 2026-10-29]
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

# Or use exiftool to generate a GPX track; gpx.fmt ships with the full ExifTool
# distribution — pass its full path or copy it to the working directory [verify 2026-10-29]
exiftool -p gpx.fmt -r /path/to/images/ > photos.gpx
# Import photos.gpx into Google Earth
```

---

## 4. Image Forensics & Verification

### Error Level Analysis (ELA)

**Purpose:** Detect manipulated regions (different compression levels indicate editing)

**Using FotoForensics:**
```text
1. Navigate to https://fotoforensics.com
2. Upload image
3. Click "Error Level Analysis"
4. Interpretation:
   - Similar brightness = untouched
   - Bright areas = recently edited/added
   - ⚠️ Not definitive — ELA produces false positives on JPEGs that have
     been re-saved at different qualities, screen-captured, or exported
     from editors that re-compress losslessly. Treat as a lead, not proof. [verify 2026-10-29]
```

**Command-line ELA:**
```bash
# Using ImageMagick [verify 2026-10-29]
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

# Method 1: Visual inspection after enhancement [verify 2026-10-29]
convert image.jpg -contrast -contrast -contrast enhanced.jpg

# Method 2: Python with opencv (advanced)
# Requires: pip install opencv-python numpy [verify 2026-10-29]
python3 << 'EOF'
import cv2
import numpy as np

img = cv2.imread('image.jpg')
gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

# Find repeated patterns (SIFT features)
sift = cv2.SIFT_create()
kp, des = sift.detectAndCompute(gray, None)

# Match features to themselves (finds clones); k=3 because each keypoint's
# nearest neighbour is itself (distance 0) and must be skipped [verify 2026-10-29]
bf = cv2.BFMatcher()
matches = bf.knnMatch(des, des, k=3)

# Filter for strong matches (potential clones)
clones = []
for cands in matches:
    others = [c for c in cands if c.trainIdx != c.queryIdx]  # drop the self-match
    if len(others) < 2:
        continue
    m, n = others[0], others[1]
    if m.distance < 0.75 * n.distance:
        (x1, y1), (x2, y2) = kp[m.queryIdx].pt, kp[m.trainIdx].pt
        if np.hypot(x1 - x2, y1 - y2) > 30:  # ignore neighbouring keypoints
            clones.append(m)

print(f"Potential clone matches: {len(clones)}")
EOF
```

### Metadata Consistency Checks

```bash
# Check for timestamp mismatches [verify 2026-10-29]
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
```text
1. Identify claimed date/time and location
2. Calculate sun position for that date/time/location
3. Compare with shadows in image

Tool: SunCalc - https://www.suncalc.org/ [verify 2026-10-29]
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
  signature — argument names have shifted across releases) [verify 2026-10-29]
```

**Example:**
```markdown
**Claim:** Photo taken in Paris (48.8566°N, 2.3522°E) on June 21, 2024 at 12:00 local (CEST)

**Sun position (SunCalc):**
- Azimuth: ~129° (south-east; solar noon is not until ~13:50 CEST) [verify 2026-10-29]
- Altitude: ~56° (high in sky)
- Expected shadow: Medium (~0.7× object height), pointing north-west

**Actual shadow in image:**
- Direction: West
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

# Output: output.txt contains extracted text [verify 2026-10-29]
cat output.txt
# Example: "КАФЕ" (Russian) → likely Russia/former USSR
#          "Pharmacie" (French) → France/French-speaking region
#          "+1-555-" (phone) → North America (country code +1)

# Search extracted text
# "Café de Paris" → Google: "Café de Paris" + visible landmarks
```

**Method 3: Street View matching**
```text
1. Identify approximate area from other clues
2. Use Google Street View
3. Navigate streets looking for matching:
   - Building facades
   - Street signs
   - Landmarks visible in background
   - Road markings, curb styles

Tool: Google Street View - https://www.google.com/maps (drag pegman icon)
Tool: Mapillary - https://www.mapillary.com (crowdsourced street imagery,
       owned by Meta; CC-BY-SA imagery, large global coverage) [verify 2026-10-29]
Tool: KartaView - https://kartaview.org (crowdsourced, free and open street-level
       imagery for OpenStreetMap; complementary coverage to Mapillary) [verify 2026-10-29]
Tool: Panoramax - https://panoramax.fr (open-source, federated street
       imagery; growing OSM-aligned coverage) [verify 2026-10-29]
```

**Method 4: OSM tag-based search (Overpass Turbo)**
```text
When you suspect a region but need to filter for specific features
(e.g., "all McDonald's in Gdańsk", "all churches
with onion domes in city X", "all roundabouts with a fountain"):

1. Open https://overpass-turbo.eu/ [verify 2026-10-29]
2. Set the bbox to the suspected region (zoom + click "current view")
3. Write an Overpass QL query, e.g. for fast-food chains:
     [out:json][timeout:25];
     area[name="Gdańsk"]->.searchArea;
     node["amenity"="fast_food"]["brand"="McDonald's"](area.searchArea);
     out;
4. Click "Run" → results plot on the map; click a node to get coordinates,
   then verify with Street View / Mapillary

For a simplified front-end to the same OSM tag search, use Bellingcat's
OpenStreetMap Search (https://osm-search.bellingcat.com/; toolkit entry:
https://bellingcat.gitbook.io/toolkit/more/all-tools/openstreetmap-search-tool) [verify 2026-10-29]
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
- Drives on the left (right-hand-drive vehicles): UK, Japan, India, Australia, South Africa [verify 2026-10-29]
- Drives on the right (left-hand-drive vehicles): Most of the world

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
```text
1. Identify potential location (city/neighborhood)
2. Find reference images from same location (Google Images, Flickr)
3. Match specific features:
   - Window count on building
   - Signage exact positions
   - Sidewalk patterns
   - Tree locations

Tool: GeoGuessr - https://www.geoguessr.com [verify 2026-10-29]
- Practice identifying locations from Street View
- Builds pattern recognition skills
```

**Satellite imagery:**
```text
1. Google Earth Pro (desktop version - free) [verify 2026-10-29]
2. Navigate to suspected area
3. Use historical imagery feature (clock icon)
   - View location at different dates
   - Match vegetation, construction, parked vehicles
4. Measure distances between landmarks
5. Match roof shapes, building shadows

Tool: Google Earth Pro - https://www.google.com/earth/about/versions/#earth-pro
      (Google: desktop downloads end 25 June 2027 — keep an installer) [verify 2026-10-29]
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

# Twitter video [verify 2026-10-29]
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

# Extract one frame per second [verify 2026-10-29]
ffmpeg -i video.mp4 -vf fps=1 frame_%04d.jpg

# Extract one frame every 10 seconds
ffmpeg -i video.mp4 -vf fps=1/10 frame_%04d.jpg

# Extract specific frame (at 5 seconds)
ffmpeg -ss 00:00:05 -i video.mp4 -frames:v 1 frame_at_5s.jpg

# Extract keyframes only (scene changes); -fps_mode replaces -vsync, removed in FFmpeg 9.0 [verify 2026-10-29]
ffmpeg -i video.mp4 -vf "select='eq(pict_type,I)'" -fps_mode vfr keyframe_%04d.jpg

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
# ffprobe (comes with ffmpeg) [verify 2026-10-29]
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
# Extract audio as WAV (-acodec = alias of -codec:a) [verify 2026-10-29]
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
# Install: pip install openai-whisper [verify 2026-10-29]

whisper audio.mp3 --model medium --language en --output_format txt

# Output: audio.txt with transcription
# Useful for:
# - Identifying names, locations mentioned
# - Searching transcript for keywords
# - Timestamp verification (mentions of time/date)
```

### Video Verification

**InVID / WeVerify Verification Plugin (now "Fake News Debunker"):**
```text
The plugin originated in EU project InVID (2016-2018), was extended in
WeVerify (2018-2021), and is now maintained by AFP Medialab R&D under the
vera.ai project (https://www.veraai.eu/). Marketed as "Fake News Debunker
by InVID & WeVerify" on the Chrome Web Store. [verify 2026-10-29]

Chrome:  https://chromewebstore.google.com/detail/fake-news-debunker-invid/mhccpoafgdgbhnjfhkcmgknndkeenfhe [verify 2026-10-29]
Firefox: https://addons.mozilla.org/addon/fake-news-debunker/ [verify 2026-10-29]

Features (current):
- Keyframe extraction from major social-video platforms
- One-click reverse image search across Google Lens, Yandex, Bing, TinEye,
  Baidu, Karma Decay [verify 2026-10-29]
- EXIF / video metadata viewer
- Tesseract OCR on frames
- Video magnifier + per-frame inspection
- Forensic image analysis (ELA, copy-move, JPEG ghosts)
- WACZ archiving panel (WACZ menu added in v0.86, Jun 2025) [verify 2026-10-29]
- Hiya-powered voice-clone detector for audio (Hiya named in release notes
  from v0.88, Nov 2025) [verify 2026-10-29]

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
| Microsoft Video Authenticator | Video | **Limited release only** — offered in 2020 initially only through the AI Foundation's Reality Defender 2020 (RD2020) initiative to news outlets and political campaigns; never generally available | Originally announced 2020; per-frame confidence score [verify 2026-10-29] |
| Intel FakeCatcher | Real-time video | Commercial / OEM integration | Uses photoplethysmography (PPG) blood-flow signal; vendor-claimed 96% accuracy (Intel, 2022); the underlying paper (arXiv:1901.02212) reports 91.07% on its in-the-wild Deep Fakes Dataset [verify 2026-10-29] |
| Reality Defender | Video, image, audio | Commercial API (RealAPI) + browser portal (RealScan) [verify 2026-10-29] | Multi-model ensemble; common choice for newsroom / enterprise pipelines |
| Sensity AI | Image + video, identity-focused | Commercial [verify 2026-10-29] | Strong on face-swap and synthetic-portrait attribution |
| Hive AI Moderation | Image, video, audio | Commercial API | No customers named on the vendor site; AI-generated-content classifier ("Detect AI Content") exposed via API [verify 2026-10-29] |
| AI or Not | Image (single-shot) | Free tier ($5 credits ≈ 20 image checks) + paid from $5/mo | Fast single-image checks; no independent benchmark of its accuracy located — treat vendor accuracy claims as unverified [verify 2026-10-29] |
| Deepware Scanner | Video upload | Free (status unverified — scanner endpoint unreachable 2026-10-29) | Web upload; useful as a triage second opinion |
| Manual frame-by-frame in DaVinci Resolve / Premiere / VLC | Any | Free | Slow but defeats most automated countermeasures |

**AI-image detectors — explicit caveat:**
```markdown
Generative-image detection (single still image, no provenance signal) is
NOT reliable in 2026. False positives are common on real photos that
look "AI-like" (smooth skin, cinematic lighting), and accuracy varies by
generator — do not quote a fixed false-positive rate. Treat any
single-detector verdict on a still image as a weak signal. Provenance
metadata (C2PA) and reverse-image-search for an earlier human-attributed
instance are stronger evidence.
```

### Synthetic Media Provenance (C2PA Content Credentials)

**What it is:**
C2PA (Coalition for Content Provenance and Authenticity) is a cross-vendor
standard for cryptographically-signed provenance metadata embedded in
images, video, audio, and PDFs [verify 2026-10-29]. The user-facing brand is "Content
Credentials". A C2PA manifest records who produced or modified an asset,
which tools were used, and (optionally) whether AI was involved.

**Adoption snapshot (as of 2026-10-29):**
- **Adobe** — Photoshop, Lightroom, Firefly attach C2PA manifests [verify 2026-10-29]
- **OpenAI** — images from ChatGPT, Codex and the OpenAI API carry C2PA
  Content Credentials plus an invisible SynthID watermark; visible marks
  are separate from these signals, and legacy-model output may carry
  neither. OpenAI is on the C2PA steering committee (since May 2024) [verify 2026-10-29]
- **Google** — SynthID watermark on Imagen / Veo / Gemini image+video
  output (>180B images and videos watermarked, vendor figure, Oct 2026);
  the Pixel 10 lineup is the first with Content Credentials on every
  Pixel Camera photo (app rated C2PA Assurance Level 2) [verify 2026-10-29]
- **Microsoft** — Bing Image Creator, Designer, Copilot, Paint and
  Azure OpenAI image models attach C2PA manifests; no verified rollout to
  Microsoft 365 documents [verify 2026-10-29]
- **Meta** — AI-generated content labelling on Facebook/Instagram/Threads [verify 2026-10-29]
- **Cameras** — in-camera capture-side signing: Leica M11-P (Oct 2023,
  first camera with Content Credentials); Sony α1, α7S III, α7 IV (Mar 2024
  firmware) and α9 III (after Apr 2024), plus α1 II via a Jan 2025 firmware
  update — all through a separate upgrade licence, initially for select news
  organisations; Nikon Z6III via firmware 2.00
  (Aug 2025; Nikon Authenticity Service, not available in all regions);
  Canon EOS R1 / EOS R5 Mark II via the Authenticity Imaging System
  (May 2026, paid activation, EMEA first) [verify 2026-10-29]
- **EU AI Act Article 50** transparency obligations have applied since
  2026-08-02 (Art. 50(2) requires machine-readable marking of
  AI-generated output). The Digital Omnibus on AI (Regulation (EU)
  2026/1744) gave generative systems already on the market before
  2026-08-02 until 2026-12-02 to meet the Art. 50(2) marking duty [verify 2026-10-29]

**Inspecting C2PA manifests:**
```bash
# c2patool — Content Authenticity Initiative CLI (Rust)
# c2patool used to live in the contentauth/c2pa-rs monorepo and is back in
# its own repo. Releases: https://github.com/contentauth/c2patool/releases
# (v0.28.x, Oct 2026; 0.27.x releases are tagged c2patool-vX.Y.Z on c2pa-rs).
# Install a prebuilt binary from the c2patool releases page; Homebrew's formula
# still builds 0.27.22 from c2pa-rs. [verify 2026-10-29]

# Read manifest from any signed asset (image/video/PDF/audio) [verify 2026-10-29]
c2patool image.jpg

# Dump full JSON manifest (signers, ingredients, actions, AI assertions);
# -d / --detailed = "Display detailed C2PA-formatted manifest data"; check
# `c2patool --help` for the current flag set. [verify 2026-10-29]
c2patool image.jpg --detailed
```

**Browser-side check:**
- Adobe-hosted verifier: https://contentcredentials.org/verify [verify 2026-10-29]
  (drag-drop any file → manifest, signer, edit history)
- Content Credentials icon (the "CR" pin) appears in supporting viewers
  (Chromium browsers via the Adobe Content Authenticity extension, Adobe
  apps) [verify 2026-10-29]

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
```text
https://pimeyes.com
- Upload face photo (crop to just face)
- Finds other instances online (open web only — no social media) [verify 2026-10-29]
- Results include: news articles, blogs, image-hosting sites
- Pricing/restrictions: see §2.5 above
- ⚠️ Privacy implications — use only with documented legal basis
```

**FaceCheck.id (commercial, social-leaning):**
```text
https://facecheck.id
- Per-search pricing; better signal on social-media-sourced faces [verify 2026-10-29]
- See §2.5 above for full details
```

**Search4Faces (social media specific):**
```text
https://search4faces.com/
- Searches: VK, Odnoklassniki, TikTok avatars, Clubhouse, celebrity DBs [verify 2026-10-29]
- Better for Eastern European profiles
- No pricing or search limits published on the site — check after login [verify 2026-10-29]
```

**Face comparison (manual verification):**

> **Maintenance note:** `ageitgey/face_recognition` (the historical
> "simplest face recognition" Python wrapper around dlib) has not seen
> a release since 2020 and dlib itself moves slowly [verify 2026-10-29]. For new work prefer
> [DeepFace](https://github.com/serengil/deepface) — actively maintained,
> wraps modern backbones (ArcFace, FaceNet, VGG-Face, SFace, GhostFaceNet)
> with a single API. [verify 2026-10-29]

```python
# Modern path — DeepFace (pip install deepface) [verify 2026-10-29]
from deepface import DeepFace

# Verify whether two images depict the same person
result = DeepFace.verify(
    img1_path="person1.jpg",
    img2_path="person2.jpg",
    model_name="ArcFace",        # ArcFace / Facenet512 are strong defaults
    detector_backend="retinaface" # robust face detection
)
print(result)
# {'verified': True/False, 'distance': 0.42, 'threshold': 0.68, ...} [verify 2026-10-29]

# Bulk search: find all matches for a probe inside a directory
dfs = DeepFace.find(
    img_path="probe.jpg",
    db_path="reference_set/",
    model_name="ArcFace"
)
```

```python
# Legacy path — face_recognition (still works, but unmaintained)
# pip install face_recognition [verify 2026-10-29]
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
# Crop image to just license plate (-crop WxH+X+Y) [verify 2026-10-29]
convert original.jpg -crop 200x50+100+200 plate.jpg

# Enhance contrast (-contrast is repeatable)
convert plate.jpg -contrast -contrast enhanced_plate.jpg

# OCR
tesseract enhanced_plate.jpg plate_text

# Output: plate_text.txt [verify 2026-10-29]
cat plate_text.txt
# Example: ABC1234

# Search plate format to identify region
# US: varies by state (CA: 7ABC123, NY: ABC-1234)
# EU: typically country code + numbers (D-AB 1234 for Germany)
# UK: AB12 CDE format
```

**Automated ALPR (Automatic License Plate Recognition):**
```bash
# OpenALPR (open-source, AGPL-3.0) — repo at github.com/openalpr/openalpr
# OpenALPR was acquired by Rekor Systems (2019); the open-source repo has
# had no commits since July 2020 [verify 2026-10-29]. Still works on
# common Western plate formats, but accuracy on modern EU/Asian formats
# is best-in-class only via the commercial alternatives below.
# -c = country code (us or eu), -n = max plate candidates (default 10) [verify 2026-10-29]
alpr -c us plate_image.jpg            # Output: plate + confidence score
alpr -c eu -n 10 plate_image.jpg      # Top 10 matches, EU pattern set

# Modern alternatives:
# - Plate Recognizer (https://platerecognizer.com) — hosted API; free tier
#   2,500 lookups/month, evaluation only — not for production / deployment
#   use [verify 2026-10-29]
# - ultimateALPR SDK (https://github.com/DoubangoTelecom/ultimateALPR-SDK) —
#   source-available, licence "For non commercial use only" (commercial
#   version from Doubango); multi-charset Latin / Korean / Chinese plates [verify 2026-10-29]
# - V0LT Predator (https://github.com/connervieira/Predator) — open-source
#   (AGPL-3.0) dash-cam platform with ALPR; its engine Phantom is heavily
#   based on OpenALPR, and stock OpenALPR can be set as back-end [verify 2026-10-29]
```

### Reverse Video Search

**YouTube upload time + thumbnails (DataViewer replacement):**

Amnesty's YouTube DataViewer was hosted at citizenevidence.amnestyusa.org,
which no longer resolves; the Citizen Evidence Lab now lives at
https://citizenevidence.org/ and does not list a working DataViewer. [verify 2026-10-29]
Reproduce its two outputs (exact upload time, all thumbnails) with yt-dlp:

```bash
# Write .info.json (upload_date = UTC YYYYMMDD; timestamp = UNIX time the
# video became available) and every thumbnail; skip the video itself [verify 2026-10-29]
yt-dlp --skip-download --write-info-json --write-all-thumbnails "VIDEO_URL"

# Then: reverse-search each thumbnail across engines to find earlier
# uploads / re-uploads, and log upload_date in the forensic timeline
```

**Manual video fingerprinting:**
```bash
# Exact hash of 8x8 grayscale frames — NOT a perceptual hash: any pixel change (e.g. a re-encode)
# alters it, so it only matches identical streams; -f image2pipe -vcodec ppm - streams frames to stdout [verify 2026-10-29]
ffmpeg -i video.mp4 -vf "scale=8:8,format=gray" -f image2pipe -vcodec ppm - | sha256sum

# Compare two videos (similarity)
# Using ffmpeg to extract fingerprints, then compare
```

---

## 8. Tools Reference

### Essential Tools

| Tool | Purpose | Platform | Link |
|------|---------|----------|------|
| **ExifTool** | Metadata extraction | CLI (all platforms) | [exiftool.org](https://exiftool.org) [verify 2026-10-29] |
| **Google Images / Lens** | Reverse image search | Web | [images.google.com](https://images.google.com) |
| **Yandex Images** | Reverse search (faces, Cyrillic) | Web | [yandex.com/images](https://yandex.com/images) [verify 2026-10-29] |
| **TinEye** | Reverse search (temporal / oldest instance) | Web / API | [tineye.com](https://tineye.com) [verify 2026-10-29] |
| **Bing Visual Search** | Reverse search (objects, products) | Web | [bing.com/images](https://www.bing.com/images) (camera icon; /visualsearch now redirects to a feature page) [verify 2026-10-29] |
| **PimEyes** | Face search (open web) | Web (commercial) | [pimeyes.com](https://pimeyes.com) [verify 2026-10-29] |
| **FaceCheck.id** | Face search (social-leaning) | Web (commercial, pay-per-search) | [facecheck.id](https://facecheck.id) [verify 2026-10-29] |
| **Search4Faces** | Face search (VK / OK / TikTok / Clubhouse) | Web | [search4faces.com](https://search4faces.com) [verify 2026-10-29] |
| **DeepFace** | Face comparison / verification | Python | [github.com/serengil/deepface](https://github.com/serengil/deepface) [verify 2026-10-29] |
| **SunCalc** | Sun-position calculator | Web | [suncalc.org](https://www.suncalc.org) [verify 2026-10-29] |
| **ShadowFinder** | Inverse sun-position (find lat/long from shadow) | CLI / Colab (Python) | [github.com/bellingcat/ShadowFinder](https://github.com/bellingcat/ShadowFinder) [verify 2026-10-29] |
| **Google Earth Pro** | Satellite imagery, historical layers, 3D | Desktop (free) | [google.com/earth/about/versions](https://www.google.com/earth/about/versions/) [verify 2026-10-29] |
| **Mapillary** | Crowdsourced street imagery | Web | [mapillary.com](https://www.mapillary.com) [verify 2026-10-29] |
| **KartaView** | Crowdsourced street imagery | Web | [kartaview.org](https://kartaview.org) [verify 2026-10-29] |
| **Overpass Turbo** | OSM tag-based area queries | Web | [overpass-turbo.eu](https://overpass-turbo.eu) [verify 2026-10-29] |
| **ffmpeg / ffprobe** | Video processing + metadata | CLI | [ffmpeg.org](https://ffmpeg.org) [verify 2026-10-29] |
| **yt-dlp** | Social-video download | CLI (Python) | [github.com/yt-dlp/yt-dlp](https://github.com/yt-dlp/yt-dlp) [verify 2026-10-29] |
| **InVID / WeVerify (vera.ai)** | Video verification toolkit | Browser extension | [veraai.eu](https://www.veraai.eu/) [verify 2026-10-29] |
| **Tesseract OCR** | Text extraction | CLI | [github.com/tesseract-ocr/tesseract](https://github.com/tesseract-ocr/tesseract) [verify 2026-10-29] |
| **ImageMagick** | Image manipulation | CLI | [imagemagick.org](https://imagemagick.org) [verify 2026-10-29] |
| **FotoForensics** | Error-level analysis | Web | [fotoforensics.com](https://fotoforensics.com) [verify 2026-10-29] |
| **Whisper** | Audio transcription | CLI (Python) | [github.com/openai/whisper](https://github.com/openai/whisper) [verify 2026-10-29] |
| **Intel FakeCatcher** | Real-time deepfake detection (PPG) | OEM / commercial | [intel.com/.../trusted-media-deepfake-detection](https://www.intel.com/content/www/us/en/research/trusted-media-deepfake-detection.html) [verify 2026-10-29] |
| **Reality Defender** | Multi-modal deepfake detection | Commercial API | [realitydefender.com](https://www.realitydefender.com) [verify 2026-10-29] |
| **Sensity AI** | Identity-focused deepfake detection | Commercial | [sensity.ai](https://sensity.ai) [verify 2026-10-29] |
| **AI or Not** | Single-image AI-generation check | Web (free tier) | [aiornot.com](https://www.aiornot.com) [verify 2026-10-29] |
| **C2PA c2patool** | Inspect Content Credentials | CLI (Rust) | [github.com/contentauth/c2patool](https://github.com/contentauth/c2patool) [verify 2026-10-29] |
| **Content Credentials Verify** | Browser-side C2PA check | Web | [contentcredentials.org/verify](https://contentcredentials.org/verify) [verify 2026-10-29] |
| **Plate Recognizer** | ALPR (hosted, free tier) | Web / API | [platerecognizer.com](https://platerecognizer.com) [verify 2026-10-29] |
| **GeoGuessr** | Geolocation practice | Web | [geoguessr.com](https://www.geoguessr.com) [verify 2026-10-29] |
| **Bellingcat Toolkit** | Curated OSINT tool index | Web | [bellingcat.gitbook.io/toolkit](https://bellingcat.gitbook.io/toolkit/) [verify 2026-10-29] |

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

# Download video (best quality; bestvideo+bestaudio is merged with ffmpeg) [verify 2026-10-29]
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
   - Cyrillic + Pyaterochka → points to Russia (confirm against the chain's current store footprint before concluding)
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
   - Tool: timeanddate.com/weather (historical weather) [verify 2026-10-29]

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
```text
❌ Bad: "Google reverse search found nothing, therefore image is original"
✅ Good: Search Google, Yandex, TinEye, Bing minimum before concluding

❌ Bad: "EXIF says photo taken in Paris, so it's from Paris"
✅ Good: EXIF can be easily spoofed - verify with visual clues
```

**2. Ignoring social media platform metadata stripping**
```text
❌ Bad: Download from Twitter → check EXIF → "no GPS data, can't geolocate"
✅ Good: Know that Twitter strips GPS → use visual geolocation techniques instead
```

**3. Certainty without corroboration**
```text
❌ Bad: "Shadows suggest this was taken at 3 PM"
✅ Good: "Shadow analysis suggests 3 PM ± 30 minutes, consistent with claimed timestamp"

Always provide:
- Confidence level (high/medium/low)
- Alternative explanations
- Limiting factors (quality, partial view, etc.)
```

**4. Forgetting to preserve originals**
```text
❌ Bad: Download → crop → enhance → analyze cropped version
✅ Good: Download → hash → save original → create working copy → analyze copy

Never modify original evidence files
```

**5. Tunnel vision on initial hypothesis**
```text
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
# If full image yields no results, try cropping to specific elements
# (-crop WxH+X+Y) [verify 2026-10-29]:
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
- EU: GDPR Art. 9(1) prohibits processing biometric data "for the purpose of
  uniquely identifying a natural person" unless an Art. 9(2) exception applies
  (in addition to an Art. 6 lawful basis), and Art. 9(4) lets member states add
  further conditions. The EU AI Act (in force 2024-08-01,
  staged enforcement) further restricts real-time remote biometric
  identification in public spaces. [verify 2026-10-29]
- US: Varies sharply by state. Illinois BIPA (740 ILCS 14) imposes
  notice/consent requirements AND a private right of action (§ 20);
  Texas CUBI (Tex. Bus. & Com. Code
  § 503.001) and Washington RCW 19.375 (2017 HB 1493) impose notice/consent
  requirements but are enforceable only by the state attorney general;
  most other states have minimal biometric-specific regulation. Federal
  sectoral laws (FERPA, HIPAA) may apply contextually. [verify 2026-10-29]
- UK: UK GDPR + DPA 2018 mirror EU GDPR for biometric data; ICO has
  taken enforcement action against indiscriminate face-search providers. [verify 2026-10-29]
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
      `yt-dlp --version` — record output verbatim, do not paraphrase) [verify 2026-10-29]
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
- [Bellingcat Online Investigation Toolkit](https://bellingcat.gitbook.io/toolkit/) — curated, frequently-updated tool catalogue [verify 2026-10-29]
- [vera.ai](https://www.veraai.eu/) — successor to InVID/WeVerify; verification-plugin home [verify 2026-10-29]
- [Content Authenticity Initiative](https://contentauthenticity.org/) — C2PA reference implementations and policy resources [verify 2026-10-29]
- [Gral Hix](https://gralhix.com/) - OSINT tools and resources [verify 2026-10-29]
- [Benjamin Strick (Bendobrown)](https://www.youtube.com/c/bendobrown) - Geolocation and OSINT techniques [verify 2026-10-29]
- [GeoRainbolt](https://www.youtube.com/@georainbolt) - Expert geolocation content [verify 2026-10-29]
- [start.me OSINT Resources](https://start.me/u/gl0bal01) - Comprehensive OSINT tool directory

---

**Last Updated:** 2026-10-29
