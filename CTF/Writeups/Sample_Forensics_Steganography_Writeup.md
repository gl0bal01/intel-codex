---
title: "Sample Forensics Challenge: Hidden Image Data"
description: "CTF writeup: LSB steganography & EXIF analysis. Extract hidden data from image pixels using Python, PIL & forensics tools for CTF forensics challenges."
---

# 🕵️ Sample Forensics Challenge: Hidden Image Data

**Challenge**: Picture Perfect
**Category**: Forensics
**Points**: 200  
**Event**: Beginner CTF 2024
**Team**: Team Example
**Author**: CTF Guide
**Date**: 2024-01-15

---

## 🎯 Challenge Summary

**TL;DR**: Multi-layered steganography challenge involving EXIF data analysis and LSB (Least Significant Bit) extraction from an image file.

### Challenge Description
```
We intercepted this image from a suspicious communication channel. 
Our analysts believe it contains hidden information, but they can't figure out how to extract it.
Can you help us uncover the secret?

File: suspicious_image.jpg
Hint: Sometimes the most important information is in the details you can't see.
```

### Files & Services
- `suspicious_image.jpg` - Image file suspected of containing hidden data

---

## 🔍 Analysis

### Initial Reconnaissance
Let's start by examining the image file:

```bash
$ file suspicious_image.jpg
suspicious_image.jpg: JPEG image data, JFIF standard 1.01, aspect ratio, density 1x1, segment length 16, baseline, precision 8, 1920x1080, components 3

$ ls -la suspicious_image.jpg
-rw-r--r-- 1 user user 2,847,392 Jan 15 10:30 suspicious_image.jpg
```

### Key Observations
1. **File Type**: Standard JPEG image, 1920x1080 resolution
2. **File Size**: 2.8MB - seems large for a simple image
3. **Hint Analysis**: "details you can't see" suggests metadata or steganography

Let's check for obvious strings:
```bash
$ strings suspicious_image.jpg | grep -i flag
# No obvious flags found

$ strings suspicious_image.jpg | tail -20
# Various binary data, no clear text
```

---

## 💡 Solution Approach  

### Method 1: Metadata Analysis

1. **Step 1**: Extract EXIF data
   ```bash
   $ exiftool suspicious_image.jpg
   ExifTool Version Number         : 12.16
   File Name                       : suspicious_image.jpg
   Directory                       : .
   File Size                       : 2.8 MiB
   File Modification Date/Time     : 2024:01:15 10:30:00+01:00
   File Access Date/Time          : 2024:01:15 10:35:00+01:00
   File Permissions               : rw-r--r--
   File Type                      : JPEG
   File Type Extension            : jpg
   MIME Type                      : image/jpeg
   Image Width                    : 1920
   Image Height                   : 1080
   Encoding Process               : Baseline DCT, Huffman coding
   Bits Per Sample                : 8
   Color Components              : 3
   Y Cb Cr Sub Sampling          : YCbCr4:2:0 (2 2)
   Comment                       : VGhlIGZpcnN0IGNsdWUgaXM6IGxvb2sgZGVlcGVyIGluIHRoZSBwaXhlbHM=
   ```
   
   🎯 **Interesting!** There's a Base64-encoded comment field.

2. **Step 2**: Decode the Base64 comment
   ```bash
   $ echo "VGhlIGZpcnN0IGNsdWUgaXM6IGxvb2sgZGVlcGVyIGluIHRoZSBwaXhlbHM=" | base64 -d
   The first clue is: look deeper in the pixels
   ```
   
   This confirms our suspicion about steganography in the pixel data.

3. **Step 3**: LSB Steganography Analysis
   ```python
   from PIL import Image
   import numpy as np
   
   def extract_lsb_data(image_path):
       img = Image.open(image_path)
       data = np.array(img)
       
       # Extract LSB from red channel
       red_channel = data[:, :, 0]
       lsb_bits = red_channel & 1  # Get only the LSB
       
       # Convert to binary string
       binary_string = ''.join(lsb_bits.flatten().astype(str))
       
       return binary_string
   
   binary_data = extract_lsb_data('suspicious_image.jpg')
   print(f"LSB binary length: {len(binary_data)}")
   print(f"First 100 bits: {binary_data[:100]}")
   ```
   
   **Results**:
   ```
   LSB binary length: 2073600
   First 100 bits: 0110011001101100011000010110011101111011011100110111010001100101011001110110000101101110...
   ```

---

## 🛠️ Technical Details

### Tools Used
- **Primary Tools**: exiftool, Python PIL, numpy
- **Secondary Tools**: hexedit, strings, binwalk  

### Key Technical Concepts
- **EXIF Data**: Metadata stored in image files
- **LSB Steganography**: Hiding data in least significant bits of pixel values
- **Base64 Encoding**: Common encoding scheme for binary data in text
- **Binary to ASCII Conversion**: Converting binary data back to readable text

### LSB Extraction Process
The challenge uses the red channel's least significant bit to store hidden data:
1. Each pixel's red value has its LSB replaced with secret data
2. The secret data is stored sequentially across all pixels
3. The binary data needs to be converted back to ASCII text

---

## 🎯 The Solution

### Final Exploit
```python
#!/usr/bin/env python3
"""
Complete LSB Steganography Extraction Tool
Extracts hidden data from the LSB of image pixels
"""

from PIL import Image
import numpy as np
import base64

def extract_metadata(image_path):
    """Extract and decode EXIF comment field"""
    import subprocess
    
    result = subprocess.run(['exiftool', image_path], capture_output=True, text=True)
    
    for line in result.stdout.split('\n'):
        if 'Comment' in line:
            comment = line.split(':', 1)[1].strip()
            try:
                decoded = base64.b64decode(comment).decode('utf-8')
                return decoded
            except:
                return comment
    return None

def extract_lsb_steganography(image_path, channel='red'):
    """Extract LSB data from specified color channel"""
    img = Image.open(image_path)
    data = np.array(img)
    
    # Select channel (0=red, 1=green, 2=blue)
    channel_map = {'red': 0, 'green': 1, 'blue': 2}
    channel_data = data[:, :, channel_map[channel]]
    
    # Extract LSB
    lsb_bits = channel_data & 1
    binary_string = ''.join(lsb_bits.flatten().astype(str))
    
    return binary_string

def binary_to_ascii(binary_string):
    """Convert binary string to ASCII text"""
    ascii_chars = []
    
    # Process 8 bits at a time
    for i in range(0, len(binary_string), 8):
        byte = binary_string[i:i+8]
        if len(byte) == 8:
            ascii_value = int(byte, 2)
            if 32 <= ascii_value <= 126:  # Printable ASCII range
                ascii_chars.append(chr(ascii_value))
            elif ascii_value == 0:  # Null terminator - end of message
                break
    
    return ''.join(ascii_chars)

def find_flag_in_data(data):
    """Search for flag pattern in extracted data"""
    import re
    
    # Look for common flag patterns
    flag_patterns = [
        r'flag\{[^}]+\}',
        r'FLAG\{[^}]+\}',
        r'[A-Za-z0-9_]+\{[^}]+\}'
    ]
    
    for pattern in flag_patterns:
        matches = re.findall(pattern, data, re.IGNORECASE)
        if matches:
            return matches
    
    return None

if __name__ == "__main__":
    image_file = "suspicious_image.jpg"
    
    print("=== FORENSICS ANALYSIS REPORT ===")
    print(f"Analyzing: {image_file}")
    
    # Step 1: Extract metadata
    print("\n[1] Extracting metadata...")
    metadata_clue = extract_metadata(image_file)
    if metadata_clue:
        print(f"Hidden comment found: {metadata_clue}")
    
    # Step 2: Try LSB extraction on different channels
    print("\n[2] Extracting LSB data from color channels...")
    
    for channel in ['red', 'green', 'blue']:
        print(f"\nTrying {channel} channel...")
        
        binary_data = extract_lsb_steganography(image_file, channel)
        ascii_data = binary_to_ascii(binary_data)
        
        print(f"Extracted {len(ascii_data)} ASCII characters")
        print(f"First 100 characters: {ascii_data[:100]}")
        
        # Look for flag
        flags = find_flag_in_data(ascii_data)
        if flags:
            print(f"\n🏆 FLAG FOUND in {channel} channel: {flags[0]}")
            
            # Show more context around the flag
            flag_pos = ascii_data.find(flags[0])
            context_start = max(0, flag_pos - 50)
            context_end = min(len(ascii_data), flag_pos + len(flags[0]) + 50)
            print(f"Context: ...{ascii_data[context_start:context_end]}...")
            
            break
    else:
        print("\n❌ No flag found in LSB data")
        
        # Try alternative approaches
        print("\n[3] Trying alternative steganography methods...")
        
        # Check for embedded files with binwalk
        import subprocess
        result = subprocess.run(['binwalk', image_file], capture_output=True, text=True)
        if result.returncode == 0 and result.stdout:
            print("Binwalk analysis:")
            print(result.stdout)
```

### Execution Output
```bash
$ python3 solve.py
=== FORENSICS ANALYSIS REPORT ===
Analyzing: suspicious_image.jpg

[1] Extracting metadata...
Hidden comment found: The first clue is: look deeper in the pixels

[2] Extracting LSB data from color channels...

Trying red channel...
Extracted 1847 ASCII characters
First 100 characters: flag{steganography_is_everywhere_in_the_pixels_2024}The secret message continues here with more

🏆 FLAG FOUND in red channel: flag{steganography_is_everywhere_in_the_pixels_2024}
Context: ...flag{steganography_is_everywhere_in_the_pixels_2024}The secret message continues here with more hidden data that was embedded using LSB steganography techniques...
```

---

## 🏁 Flag

```
flag{steganography_is_everywhere_in_the_pixels_2024}
```

---

## 💭 Reflection

### What Went Well
- Systematic approach to metadata analysis first
- Correct identification of steganography technique
- Successfully implemented LSB extraction algorithm
- Found flag efficiently using pattern matching

### Challenges Faced  
- Initial confusion about which color channel contained data
- Had to understand LSB encoding technique
- Needed to handle binary-to-ASCII conversion properly

### Learning Outcomes
- **Image Forensics**: EXIF data can contain important clues
- **LSB Steganography**: Common technique for hiding data in images
- **Base64 Encoding**: Often used for embedding text in metadata
- **Systematic Testing**: Try different channels/approaches methodically

---

## 🔗 References

### Documentation
- [Steganography Techniques](https://en.wikipedia.org/wiki/Steganography) - Overview of hiding techniques
- [LSB Steganography](https://www.researchgate.net/publication/220069844_LSB_Steganography) - Technical details  
- [EXIF Metadata](https://exiftool.org/TagNames/) - Complete EXIF tag reference

### Further Reading
- [Digital Image Steganography Survey](https://arxiv.org/abs/1401.5561) - Academic overview
- [Forensic Analysis Tools](https://forensicswiki.xyz/wiki/index.php?title=Tools) - Comprehensive tool list

---

## 📷 Screenshots

### Initial Analysis
![EXIF Analysis](path/to/exif_screenshot.png)
*Caption: ExifTool revealing Base64-encoded comment*

### LSB Extraction Process  
![LSB Visualization](path/to/lsb_screenshot.png)
*Caption: Visual representation of LSB extraction from red channel*

### Final Success
![Flag Discovery](path/to/flag_screenshot.png)  
*Caption: Flag found in extracted ASCII data*

---

## 🤝 Acknowledgments

### Team Contributions
- **Solo effort**: Completed independently with systematic approach

### External Help
- ExifTool documentation for metadata extraction
- PIL/numpy documentation for image processing

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

### Alternative LSB Extraction
```python
# Alternative approach using different bit planes
def extract_bit_plane(image_path, bit_position=0):
    """Extract specific bit plane from image"""
    img = Image.open(image_path)
    data = np.array(img)
    
    # Extract specified bit (0 = LSB, 7 = MSB)
    red_channel = data[:, :, 0]
    bit_plane = (red_channel >> bit_position) & 1
    
    return bit_plane

# Check multiple bit planes
for bit in range(8):
    plane = extract_bit_plane('suspicious_image.jpg', bit)
    print(f"Bit plane {bit}: {np.sum(plane)} ones out of {plane.size} pixels")
```

### Steganography Detection Tools
```bash
# StegSolve alternative
java -jar stegsolve.jar

# Steghide for password-protected data
steghide extract -sf suspicious_image.jpg

# Outguess detection
outguess -r suspicious_image.jpg output.txt

# Stegdetect for detection
stegdetect suspicious_image.jpg
```

---

**Completion Time**: `1.5 hours`
**Team Size**: `1 member`
**First Blood**: `NO` 
**Published**: `2024-01-15`

## Tags
#ctf-writeup #forensics #steganography #lsb #image-analysis #exif-data