---
type: sop
title: Image & Video OSINT
tags: [sop, media, exif, reverse, geolocation, verification]
template_version: 2025-10-05
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

**Browser method:**
```
1. Navigate to https://images.google.com
2. Click camera icon in search bar
3. Upload image OR paste image URL
4. Review results:
   - "Visually similar images"
   - "Pages that include matching images"
   - "Other sizes"
```

**Command-line method:**
```bash
# Using Google Custom Search API (requires API key)
curl "https://www.googleapis.com/customsearch/v1?q=SEARCH_TERM&cx=YOUR_CX&searchType=image&imgSize=large&key=YOUR_API_KEY"

# Or use search-by-image URL directly
# Upload image to temporary host, then:
firefox "https://www.google.com/searchbyimage?image_url=https://example.com/image.jpg"
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
- Upload face photo
- Finds other instances of same face online
- ⚠️ Privacy concerns - use ethically and legally
- Commercial tool (free limited searches)
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
# Multi-platform face search
# Searches VK, Odnoklassniki, TikTok, etc.
https://search4faces.com/

# Upload face photo
# Results from multiple social platforms
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
Most social media platforms strip EXIF data:
- Twitter: ✓ Strips GPS, keeps some camera info
- Facebook: ✓ Strips all EXIF
- Instagram: ✓ Strips all EXIF
- WhatsApp: ✓ Strips EXIF, compresses image
- Telegram: ✗ Preserves EXIF if sent as "File" (not photo)

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
1. Navigate to http://fotoforensics.com
2. Upload image
3. Click "Error Level Analysis"
4. Interpretation:
   - Similar brightness = untouched
   - Bright areas = recently edited/added
   - ⚠️ Not definitive - can have false positives
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
Tool: Mapillary - https://www.mapillary.com (crowdsourced street imagery)
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

**InVID Verification Plugin:**
```
Browser extension: https://www.invid-project.eu/tools-and-services/invid-verification-plugin/

Features:
- Keyframe extraction
- Reverse image search (multiple engines)
- Metadata analysis
- OCR on frames
- Video magnifier
- Rights verification (forensic analysis)

Usage:
1. Install browser extension (Chrome/Firefox)
2. Right-click video → InVID Analysis
3. Extract keyframes
4. Reverse search each frame
5. Check metadata
```

**Deepfake detection:**
```markdown
Signs of deepfakes:
- Unnatural blinking patterns (or lack of blinking)
- Inconsistent lighting on face vs background
- Blurry face edges (especially around hairline)
- Mismatched skin tones (face vs neck)
- Lip sync errors
- Unnatural head movements
- Background inconsistencies (person moves, background doesn't)

Tools:
- Microsoft Video Authenticator (not public yet)
- Sensity AI (commercial)
- Manual frame-by-frame analysis (slow but effective)
```

---

## 7. Specialized Techniques

### Facial Recognition (Ethical Use Only)

**⚠️ Legal Warning:** Facial recognition has legal restrictions in many jurisdictions. Use only when legally authorized.

**PimEyes (commercial):**
```
https://pimeyes.com
- Upload face photo (crop to just face)
- Finds other instances online
- Results include: social media, news articles, websites
- ⚠️ Privacy implications - use responsibly
```

**Search4Faces (social media specific):**
```
https://search4faces.com/
- Searches: VK, Odnoklassniki, TikTok
- Better for Eastern European profiles
- Free (limited searches)
```

**Face comparison (manual verification):**
```python
# Using face_recognition library (Python)
# Install: pip install face_recognition

import face_recognition

# Load images
image1 = face_recognition.load_image_file("person1.jpg")
image2 = face_recognition.load_image_file("person2.jpg")

# Get face encodings
encoding1 = face_recognition.face_encodings(image1)[0]
encoding2 = face_recognition.face_encodings(image2)[0]

# Compare
results = face_recognition.compare_faces([encoding1], encoding2)
print(f"Match: {results[0]}")  # True/False

# Distance (lower = more similar)
distance = face_recognition.face_distance([encoding1], encoding2)
print(f"Distance: {distance[0]}")  # 0.0 - 1.0
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
# Using OpenALPR (open-source)
# Install: https://github.com/openalpr/openalpr

alpr -c us plate_image.jpg
# Output: Plate number + confidence score

# Specify region
alpr -c eu -n 10 plate_image.jpg  # Top 10 matches for EU plates
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
| **Google Images** | Reverse image search | Web | [images.google.com](https://images.google.com) |
| **Yandex Images** | Reverse search (faces) | Web | [yandex.com/images](https://yandex.com/images) |
| **TinEye** | Reverse search (temporal) | Web/API | [tineye.com](https://tineye.com) |
| **PimEyes** | Facial recognition | Web (commercial) | [pimeyes.com](https://pimeyes.com) |
| **SunCalc** | Sun position calculator | Web | [suncalc.org](https://suncalc.org) |
| **Google Earth Pro** | Satellite imagery, 3D view | Desktop (free) | [google.com/earth/pro](https://www.google.com/earth/versions/#earth-pro) |
| **ffmpeg** | Video processing | CLI | [ffmpeg.org](https://ffmpeg.org) |
| **yt-dlp** | Video download | CLI (Python) | [github.com/yt-dlp/yt-dlp](https://github.com/yt-dlp/yt-dlp) |
| **InVID Plugin** | Video verification | Browser extension | [invid-project.eu](https://www.invid-project.eu/tools-and-services/invid-verification-plugin/) |
| **Tesseract OCR** | Text extraction | CLI | [github.com/tesseract-ocr](https://github.com/tesseract-ocr/tesseract) |
| **ImageMagick** | Image manipulation | CLI | [imagemagick.org](https://imagemagick.org) |
| **FotoForensics** | Error level analysis | Web | [fotoforensics.com](http://fotoforensics.com) |
| **Whisper** | Audio transcription | CLI (Python) | [github.com/openai/whisper](https://github.com/openai/whisper) |
| **GeoGuessr** | Geolocation practice | Web | [geoguessr.com](https://www.geoguessr.com) |

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

### Privacy & Consent

**⚠️ Legal restrictions on facial recognition:**
- EU: GDPR restricts biometric data processing
- US: Varies by state (IL/TX have strict laws, others minimal)
- Always verify legal authority before using facial recognition tools

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
- [ ] Include tool versions (exiftool 12.67, ffmpeg 4.4.2, etc.)
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
- [Hash Generation](../../Security/Analysis/sop-hash-generation-methods.md)
