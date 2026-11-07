---
title: "Sample Forensics Challenge: Hidden Image Data"
description: "CTF writeup: PNG text-chunk metadata clue and LSB steganography. Extract data hidden in PNG pixel bits with Python, Pillow, exiftool and zsteg."
tags:
  - ctf-writeup
  - forensics
  - steganography
  - lsb
  - image-analysis
  - exif-data
updated: 2026-11-07
---

# 🕵️ Sample Forensics Challenge: Hidden Image Data

**Challenge**: Picture Perfect
**Category**: Forensics
**Points**: 200
**Time Spent**: 1.5 hours
**Event**: Beginner CTF 2024
**Team**: Team Example
**Author**: CTF Guide
**Date**: 2024-01-15

---

## 🎯 Challenge Summary

**TL;DR**: Two-stage steganography challenge: a Base64 clue in a PNG text chunk, then LSB (Least Significant Bit) extraction from the image's red channel.

### Challenge Description
```text
We intercepted this image from a suspicious communication channel.
Our analysts believe it contains hidden information, but they can't figure out how to extract it.
Can you help us uncover the secret?

File: suspicious_image.png
Hint: Sometimes the most important information is in the details you can't see.
```

### Files & Services
- `suspicious_image.png` - Image file suspected of containing hidden data

> **Reproducibility note:** every output below was produced by running the shown commands against a `suspicious_image.png` rebuilt to match this challenge (Pillow; clue in a `tEXt` chunk, payload in red-channel bit 0). Long outputs are abridged where marked.

---

## 🔍 Analysis

### Initial Reconnaissance
Let's start by examining the image file:

```bash
file suspicious_image.png
ls -l suspicious_image.png
```

```text
suspicious_image.png: PNG image data, 1024 x 768, 8-bit/color RGB, non-interlaced
-rw-rw-r-- 1 dev dev 1524526 Jan 15  2024 suspicious_image.png
```

### Key Observations
1. **File Type**: PNG, 1024x768, 8-bit RGB. PNG is **lossless**, so individual pixel bits survive saving - pixel-level LSB hiding is possible
2. **File Size**: ~1.5 MB is normal for a photo-like lossless PNG, so size alone is not a signal here
3. **Hint Analysis**: "details you can't see" suggests metadata or steganography

Let's check for obvious strings:
```bash
strings suspicious_image.png | grep -i flag     # no output
strings -n 8 suspicious_image.png | head -n 2
```

```text
DtEXtComment
VGhlIGZpcnN0IGNsdWUgaXM6IGxvb2sgZGVlcGVyIGluIHRoZSBwaXhlbHM=$H
```

No flag in plain text, but `tEXt` + `Comment` right after the header is a PNG text chunk carrying a Base64-looking value. The stray characters are chunk framing that happens to be printable: `D` is the chunk length byte (0x44 = 68), `$H` the first two bytes of its CRC.

---

## 💡 Solution Approach

### Method 1: Metadata Analysis

A PNG has no JPEG-style EXIF segment. Text metadata lives in **`tEXt`** (Latin-1), **`zTXt`** (compressed) or **`iTXt`** (UTF-8) chunks as keyword/value pairs; EXIF, if present, sits in an **`eXIf`** chunk. `exiftool` reads all of them.

1. **Step 1**: Read the PNG metadata
   ```bash
   exiftool suspicious_image.png
   ```

   Output (abridged: filesystem date/permission lines removed):
   ```text
   ExifTool Version Number         : 12.76
   File Name                       : suspicious_image.png
   File Size                       : 1525 kB
   File Type                       : PNG
   MIME Type                       : image/png
   Image Width                     : 1024
   Image Height                    : 768
   Bit Depth                       : 8
   Color Type                      : RGB
   Compression                     : Deflate/Inflate
   Filter                          : Adaptive
   Interlace                       : Noninterlaced
   Comment                         : VGhlIGZpcnN0IGNsdWUgaXM6IGxvb2sgZGVlcGVyIGluIHRoZSBwaXhlbHM=
   Image Size                      : 1024x768
   Megapixels                      : 0.786
   ```

   🎯 **Interesting!** A Base64-encoded `Comment`. `pngcheck -v` confirms which chunk holds it (`pngcheck -t` prints the text-chunk contents instead):
   ```bash
   pngcheck -v suspicious_image.png | head -n 5
   ```

   ```text
   File: suspicious_image.png (1524526 bytes)
     chunk IHDR at offset 0x0000c, length 13
       1024 x 768 image, 24-bit RGB, non-interlaced
     chunk tEXt at offset 0x00025, length 68, keyword: Comment
     chunk IDAT at offset 0x00075, length 65536
   ```

2. **Step 2**: Decode the Base64 comment
   ```bash
   echo "VGhlIGZpcnN0IGNsdWUgaXM6IGxvb2sgZGVlcGVyIGluIHRoZSBwaXhlbHM=" | base64 -d
   ```

   ```text
   The first clue is: look deeper in the pixels
   ```

   This confirms our suspicion about steganography in the pixel data.

3. **Step 3**: LSB Steganography Analysis
   ```python
   from PIL import Image
   import numpy as np

   def extract_lsb_data(image_path):
       img = Image.open(image_path).convert("RGB")
       data = np.array(img)

       # Extract LSB from red channel
       red_channel = data[:, :, 0]
       lsb_bits = red_channel & 1  # Get only the LSB

       # Convert to binary string (row-major pixel order)
       binary_string = ''.join(lsb_bits.flatten().astype(str))

       return binary_string

   binary_data = extract_lsb_data('suspicious_image.png')
   print(f"LSB binary length: {len(binary_data)}")
   print(f"First 64 bits: {binary_data[:64]}")
   print(f"As bytes (MSB-first): {bytes(int(binary_data[i:i+8], 2) for i in range(0, 64, 8))}")
   ```

   **Results**:
   ```text
   LSB binary length: 786432
   First 64 bits: 0110011001101100011000010110011101111011011100110111010001100101
   As bytes (MSB-first): b'flag{ste'
   ```

   One bit per pixel (1024 x 768 = 786432), and the first eight bytes already read `flag{ste`.

### Method 2: One-shot with zsteg

For PNG/BMP, `zsteg` tries the common bit-plane/channel/order combinations in one go (`zsteg -a` tries all of them):

```bash
zsteg suspicious_image.png
```

Output (abridged: first 3 of many lines):
```text
meta Comment        .. text: "VGhlIGZpcnN0IGNsdWUgaXM6IGxvb2sgZGVlcGVyIGluIHRoZSBwaXhlbHM="
imagedata           .. file: VAX-order 68k Blit mpx/mux executable
b1,r,lsb,xy         .. text: "flag{steganography_is_everywhere_in_the_pixels_2024}"
```

`b1,r,lsb,xy` = 1 bit per pixel, red channel, pixels in `xy` (row-major) order. The other hits (`imagedata` "file:" guesses, random short strings, "OpenPGP key" matches in the full output) are noise from `file` magic on random bits. Dump the payload with `-E` to see where it ends:

```bash
zsteg -E b1,r,lsb,xy suspicious_image.png | head -c 53 | xxd
```

```text
00000000: 666c 6167 7b73 7465 6761 6e6f 6772 6170  flag{steganograp
00000010: 6879 5f69 735f 6576 6572 7977 6865 7265  hy_is_everywhere
00000020: 5f69 6e5f 7468 655f 7069 7865 6c73 5f32  _in_the_pixels_2
00000030: 3032 347d 00                             024}.
```

The `00` after `}` is the NUL terminator the solver script stops on.

---

## 🛠️ Technical Details

### Tools Used
- **Primary Tools**: exiftool, pngcheck, Python (Pillow, numpy), zsteg
- **Secondary Tools**: strings, xxd, base64

### Key Technical Concepts
- **PNG text chunks**: `tEXt`/`zTXt`/`iTXt` keyword/value metadata; `eXIf` holds EXIF in PNG
- **LSB Steganography**: Hiding data in the least significant bits of pixel values
- **Base64 Encoding**: Common encoding scheme for binary data in text
- **Binary to ASCII Conversion**: Converting binary data back to readable text

### LSB Extraction Process
The challenge hides the payload in the red channel's least significant bit:
1. Payload = flag bytes followed by one NUL byte (`0x00`) as terminator
2. Each byte is split into 8 bits, **most significant bit first**
3. Bit *i* replaces bit 0 of the red value of pixel *i*, pixels in row-major order (left to right, top to bottom)
4. Green and blue are untouched; extraction reverses the steps and stops at the NUL

### Why PNG, not JPEG
LSB-in-pixels only works on **lossless** formats (PNG, BMP). JPEG stores quantised DCT coefficients, not pixel values, so encoding scrambles the low bits: re-saving this PNG as a quality-95 JPEG flips about half of the red LSBs (49.8% for this image), i.e. the bit plane becomes random. Running the same extraction on the JPEG shows it (the junk bytes differ from image to image):

```python
from PIL import Image
from solve import binary_to_ascii, extract_lsb_steganography  # solve.py = Final Exploit below

Image.open("suspicious_image.png").save("resaved.jpg", quality=95)
print(binary_to_ascii(extract_lsb_steganography("resaved.jpg"))[:40])
```

```text
Wbo+q.<q+z[:{1
```

JPEG challenges hide data in the DCT domain instead: `steghide` (passphrase-protected), `outguess`, and `stegseek` to crack a steghide passphrase with a wordlist. See the appendix.

---

## 🎯 The Solution

### Final Exploit
```python
#!/usr/bin/env python3
"""
Complete LSB Steganography Extraction Tool
Reads the PNG text-chunk clue, then extracts data hidden in pixel LSBs.
"""

import base64
import binascii
import re

import numpy as np
from PIL import Image


def extract_metadata(image_path):
    """Return the PNG tEXt/iTXt 'Comment' value, Base64-decoded if possible."""
    comment = Image.open(image_path).text.get("Comment")
    if comment is None:
        return None
    try:
        return base64.b64decode(comment, validate=True).decode("utf-8")
    except (binascii.Error, UnicodeDecodeError):
        return comment


def extract_lsb_steganography(image_path, channel='red'):
    """Extract bit 0 of one colour channel, pixels in row-major order."""
    data = np.array(Image.open(image_path).convert("RGB"))

    # Select channel (0=red, 1=green, 2=blue)
    channel_map = {'red': 0, 'green': 1, 'blue': 2}
    channel_data = data[:, :, channel_map[channel]]

    lsb_bits = channel_data & 1
    return ''.join(lsb_bits.flatten().astype(str))


def binary_to_ascii(binary_string):
    """Group bits into bytes (MSB first); stop at the NUL terminator."""
    ascii_chars = []

    for i in range(0, len(binary_string), 8):
        byte = binary_string[i:i+8]
        if len(byte) < 8:
            break
        ascii_value = int(byte, 2)
        if ascii_value == 0:  # Null terminator - end of message
            break
        if 32 <= ascii_value <= 126:  # Keep printable ASCII only
            ascii_chars.append(chr(ascii_value))

    return ''.join(ascii_chars)


def find_flag_in_data(data):
    """Search for a flag-format string such as flag{...}."""
    return re.findall(r'[A-Za-z0-9_]+\{[^}]+\}', data)


if __name__ == "__main__":
    image_file = "suspicious_image.png"

    print("=== FORENSICS ANALYSIS REPORT ===")
    print(f"Analyzing: {image_file}")

    # Step 1: Extract metadata
    print("\n[1] Extracting metadata...")
    metadata_clue = extract_metadata(image_file)
    if metadata_clue:
        print(f"Hidden comment found: {metadata_clue}")

    # Step 2: Try LSB extraction on each colour channel
    print("\n[2] Extracting LSB data from color channels...")

    for channel in ['red', 'green', 'blue']:
        print(f"\nTrying {channel} channel...")

        binary_data = extract_lsb_steganography(image_file, channel)
        ascii_data = binary_to_ascii(binary_data)

        print(f"Extracted {len(ascii_data)} ASCII characters")
        print(f"First 100 characters: {ascii_data[:100]}")

        flags = find_flag_in_data(ascii_data)
        if flags:
            print(f"\n[+] FLAG FOUND in {channel} channel: {flags[0]}")
            break
    else:
        print("\n[-] No flag in bit 0 of R/G/B - try other bit planes/orders: zsteg -a")
```

### Execution Output
```bash
python3 solve.py
```

```text
=== FORENSICS ANALYSIS REPORT ===
Analyzing: suspicious_image.png

[1] Extracting metadata...
Hidden comment found: The first clue is: look deeper in the pixels

[2] Extracting LSB data from color channels...

Trying red channel...
Extracted 52 ASCII characters
First 100 characters: flag{steganography_is_everywhere_in_the_pixels_2024}

[+] FLAG FOUND in red channel: flag{steganography_is_everywhere_in_the_pixels_2024}
```

---

## 🏁 Flag

```text
flag{steganography_is_everywhere_in_the_pixels_2024}
```

---

## 💭 Reflection

### What Went Well
- Systematic approach to metadata analysis first
- Correct identification of steganography technique
- Successfully implemented LSB extraction algorithm
- Confirmed the result with an independent tool (zsteg)

### Challenges Faced
- Initial confusion about which color channel contained data
- Had to understand LSB encoding technique (bit order, terminator)
- Needed to handle binary-to-ASCII conversion properly

### Learning Outcomes
- **Image Forensics**: Image metadata (PNG text chunks, EXIF) can contain important clues
- **LSB Steganography**: Common technique for hiding data in images - only on lossless formats
- **Base64 Encoding**: Often used for embedding text in metadata
- **Systematic Testing**: Try different channels/approaches methodically, or let `zsteg -a` sweep them

---

## 🔗 References

### Related
- [[sop-forensics-investigation|Forensics Investigation SOP]] - Digital forensics procedures
- [[CTF_Cheat_Sheets]] - Forensics and stego quick reference
- [[Writeups-Index]] - All sample writeups

### Documentation
- [Steganography](https://en.wikipedia.org/wiki/Steganography) - Overview of hiding techniques
- [PNG Specification (W3C, Third Edition)](https://www.w3.org/TR/png-3/) - Chunk layout, including `tEXt`/`zTXt`/`iTXt`/`eXIf`
- [ExifTool PNG Tags](https://exiftool.org/TagNames/PNG.html) - What exiftool reads from PNG files
- [zsteg](https://github.com/zed-0xff/zsteg) - PNG/BMP LSB detection and extraction
- [StegSeek](https://github.com/RickdeJager/StegSeek) - steghide passphrase cracker for JPEG challenges
- [Binwalk](https://github.com/ReFirmLabs/binwalk) - Embedded-file detection (v3 is a Rust rewrite; distro `binwalk` is still v2.4)

### Further Reading
- [A Study of Various Steganographic Techniques Used for Information Hiding (arXiv:1401.5561)](https://arxiv.org/abs/1401.5561) - Academic overview

---

## 🤝 Acknowledgments

### Team Contributions
- **Solo effort**: Completed independently with systematic approach

### External Help
- ExifTool documentation for metadata extraction
- Pillow/numpy documentation for image processing

---

## 📋 Challenge Rating

| Aspect | Rating (1-5) | Notes |
|--------|--------------|-------|
| Difficulty | ⭐⭐⭐ | Moderate - requires multiple techniques |
| Fun Factor | ⭐⭐⭐⭐ | Satisfying progression of discoveries |
| Learning Value | ⭐⭐⭐⭐⭐ | Excellent introduction to image forensics |
| Realism | ⭐⭐⭐⭐ | Real-world steganography techniques |

**Overall**: ⭐⭐⭐⭐ (4/5) - Great learning challenge for forensics

---

## 📚 Appendix

### Bit-Plane Images
```python
from PIL import Image
import numpy as np

def extract_bit_plane(image_path, bit_position=0, channel=0):
    """Return one bit plane (0 = LSB, 7 = MSB) of one channel (0=R, 1=G, 2=B)."""
    data = np.array(Image.open(image_path).convert("RGB"))
    return (data[:, :, channel] >> bit_position) & 1

# Save each red bit plane as a black/white image and inspect it
for bit in range(8):
    plane = extract_bit_plane('suspicious_image.png', bit)
    Image.fromarray((plane * 255).astype(np.uint8)).save(f'red_plane_{bit}.png')
```

Visual inspection works best for large or image-shaped payloads; a 53-byte payload like this one is only a 424-pixel strip in the top row, so the scripted extraction or zsteg is faster.

### Steganography Detection Tools
```bash
# PNG/BMP pixel LSBs: sweep all bit planes, channels and orders in one shot
zsteg -a suspicious_image.png
# Dump one payload once zsteg names its parameters
zsteg -E b1,r,lsb,xy suspicious_image.png > payload.bin

# StegSolve is a Java GUI (no CLI): open the image, cycle colour planes with < >,
# Analyse > Data Extract to dump chosen bits
java -jar stegsolve.jar

# Embedded/appended files. Kali/Debian `binwalk` is v2.4; Kali packages v3 (Rust) as `binwalk3`
binwalk suspicious_image.png      # signature scan
binwalk -e suspicious_image.png   # v2: extract into ./_suspicious_image.png.extracted/
binwalk3 -e suspicious_image.png  # v3: extract into ./extractions/suspicious_image.png.extracted/

# JPEG (DCT-domain) stego - these do not read PNG pixel LSBs
steghide extract -sf image.jpg            # prompts for the passphrase
stegseek image.jpg wordlist.txt           # crack a steghide passphrase
outguess -r image.jpg output.txt
```

---

**Challenge**: `Picture Perfect`
**Points**: `200`
**Completion Time**: `1.5 hours`
**Team Size**: `1 member`
**First Blood**: `NO`
**Published**: `2024-01-15`

---

**Last Updated:** 2026-11-07
