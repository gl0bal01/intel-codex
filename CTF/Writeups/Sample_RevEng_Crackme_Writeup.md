---
title: "Sample Reverse Engineering Challenge: Simple Crackme"
description: "CTF writeup: Reverse engineer license validator with Ghidra. Extract validation algorithm, generate valid keys & master static analysis for CTF challenges."
---

# 🔧 Sample Reverse Engineering Challenge: Simple Crackme

**Challenge**: License Check
**Category**: Reverse Engineering
**Points**: 250  
**Event**: Beginner CTF 2024
**Team**: Team Example
**Author**: CTF Guide
**Date**: 2024-01-15

---

## 🎯 Challenge Summary

**TL;DR**: Basic crackme requiring analysis of a license validation function to find the correct serial key that produces the flag.

### Challenge Description
```
We found this software license validator from a compromised system. 
The criminals were using it to validate stolen software licenses.
Can you reverse engineer it to find out what valid license keys look like?

When you find the correct key format, the program will reveal the flag.

File: license_validator
Usage: ./license_validator [license_key]
```

### Files & Services
- `license_validator` - ELF executable for license validation

---

## 🔍 Analysis

### Initial Reconnaissance
Let's examine the binary:

```bash
$ file license_validator
license_validator: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 3.2.0, BuildID[sha1]=abc123..., not stripped

$ ls -la license_validator
-rwxr-xr-x 1 user user 16,832 Jan 15 09:00 license_validator

$ checksec --file=license_validator
RELRO           STACK CANARY      NX            PIE             RPATH      RUNPATH      FILE
Partial RELRO   No canary found   NX enabled    No PIE          No RPATH   No RUNPATH   license_validator
```

### Key Observations
1. **File Type**: Standard ELF 64-bit executable
2. **Security**: Basic protections (NX enabled, but no PIE or stack canary)
3. **Symbols**: Not stripped, which helps with analysis
4. **Size**: 16KB suggests moderate complexity

Let's test basic functionality:
```bash
$ ./license_validator
Usage: ./license_validator [license_key]

$ ./license_validator test123
Invalid license key format!

$ ./license_validator 12345678901234567890
Invalid license key format!
```

---

## 💡 Solution Approach  

### Method 1: Static Analysis with Ghidra

1. **Step 1**: Load binary in Ghidra and analyze functions
   ```c
   // Main function (decompiled)
   int main(int argc, char **argv) {
       if (argc != 2) {
           puts("Usage: ./license_validator [license_key]");
           return 1;
       }
       
       if (validate_license(argv[1]) == 1) {
           print_flag();
           return 0;
       } else {
           puts("Invalid license key format!");
           return 1;
       }
   }
   ```

2. **Step 2**: Analyze the validate_license function
   ```c
   // validate_license function (decompiled)
   int validate_license(char *license_key) {
       int len;
       int sum;
       int i;
       
       len = strlen(license_key);
       if (len != 16) {
           return 0;
       }
       
       // Check if all characters are digits
       for (i = 0; i < len; i++) {
           if (license_key[i] < '0' || license_key[i] > '9') {
               return 0;
           }
       }
       
       // Calculate sum of digits
       sum = 0;
       for (i = 0; i < len; i++) {
           sum += (license_key[i] - '0');
       }
       
       // Check if sum equals 64
       if (sum == 64) {
           return 1;
       }
       
       return 0;
   }
   ```

3. **Step 3**: Analyze the print_flag function
   ```c
   // print_flag function (decompiled)
   void print_flag(void) {
       char flag_buffer[64];
       
       strcpy(flag_buffer, "flag{");
       strcat(flag_buffer, "r3v3rs3_3ng1n33r1ng_m4d3_34sy_");
       strcat(flag_buffer, "2024}");
       
       printf("Congratulations! Here's your flag: %s\n", flag_buffer);
   }
   ```

### Method 2: Dynamic Analysis (Verification)

Let's verify our understanding using GDB:

```bash
$ gdb ./license_validator
(gdb) break validate_license
(gdb) run 1234567890123456

# At the breakpoint, examine the validation logic
(gdb) disas validate_license
# ... assembly code shows the same logic we found in Ghidra
```

---

## 🛠️ Technical Details

### Tools Used
- **Primary Tools**: Ghidra, strings, GDB
- **Secondary Tools**: objdump, readelf, hexdump  

### Key Technical Concepts
- **Function Analysis**: Understanding program flow through function calls
- **String Analysis**: Identifying string constants and operations
- **Algorithm Reverse Engineering**: Understanding validation logic
- **Static vs Dynamic Analysis**: Combining both approaches for verification

### Validation Algorithm
The program requires a license key that:
1. **Length**: Exactly 16 characters
2. **Character Set**: Only digits (0-9)
3. **Sum Constraint**: Sum of all digits must equal 64

---

## 🎯 The Solution

### Final Exploit
```python
#!/usr/bin/env python3
"""
License Key Generator for CTF Challenge
Generates valid license keys based on reverse engineering analysis
"""

def generate_valid_license_key():
    """
    Generate a valid license key based on discovered constraints:
    - 16 digits long
    - Sum of digits = 64
    """
    
    # Strategy: Use mostly 4s (16 * 4 = 64), then adjust
    digits = [4] * 16  # Start with all 4s
    current_sum = sum(digits)  # Should be 64
    
    # Verify our math
    assert current_sum == 64, f"Math error: sum is {current_sum}, not 64"
    
    # Convert to string
    license_key = ''.join(map(str, digits))
    
    return license_key

def verify_license_key(license_key):
    """Verify the license key meets all constraints"""
    
    # Check length
    if len(license_key) != 16:
        return False, f"Wrong length: {len(license_key)} (expected 16)"
    
    # Check all digits
    if not license_key.isdigit():
        return False, "Contains non-digit characters"
    
    # Check sum
    digit_sum = sum(int(d) for d in license_key)
    if digit_sum != 64:
        return False, f"Sum is {digit_sum} (expected 64)"
    
    return True, "Valid license key"

def generate_alternative_keys():
    """Generate several valid license keys using different strategies"""
    
    keys = []
    
    # Strategy 1: All 4s
    keys.append('4444444444444444')
    
    # Strategy 2: Mix of digits that sum to 64
    keys.append('5555555555555559')  # 15*5 + 1*9 = 75 + 9 = 84 (too high)
    keys.append('3333333333333337')  # 15*3 + 1*7 = 45 + 7 = 52 (too low)
    keys.append('4444444444444446')  # 14*4 + 2*6 = 56 + 12 = 68 (too high)
    keys.append('4444444444444440')  # 15*4 + 1*0 = 60 + 0 = 60 (too low)
    keys.append('4444444444444448')  # 14*4 + 2*8 = 56 + 16 = 72 (too high)
    keys.append('4444444444444422')  # 14*4 + 2*2 = 56 + 4 = 60 (too low)
    keys.append('4444444444444466')  # 12*4 + 4*6 = 48 + 24 = 72 (too high)
    keys.append('4444444444442222')  # 12*4 + 4*2 = 48 + 8 = 56 (too low)
    
    # Let's calculate a correct one:
    # We need sum = 64, length = 16
    # Try: 8888888800000000 = 8*8 + 8*0 = 64
    keys.append('8888888800000000')
    
    # Validate all keys
    valid_keys = []
    for key in keys:
        is_valid, message = verify_license_key(key)
        print(f"Key: {key} - {message}")
        if is_valid:
            valid_keys.append(key)
    
    return valid_keys

if __name__ == "__main__":
    import subprocess
    
    print("=== LICENSE KEY GENERATOR ===")
    print("Based on reverse engineering analysis\n")
    
    print("Requirements discovered:")
    print("- Length: 16 characters")
    print("- Characters: digits only (0-9)")
    print("- Constraint: sum of digits = 64\n")
    
    # Generate primary solution
    primary_key = generate_valid_license_key()
    is_valid, message = verify_license_key(primary_key)
    print(f"Generated key: {primary_key}")
    print(f"Validation: {message}\n")
    
    # Test with actual binary
    print("Testing with actual binary:")
    try:
        result = subprocess.run(
            ['./license_validator', primary_key], 
            capture_output=True, 
            text=True,
            timeout=5
        )
        
        if result.returncode == 0:
            print("✅ SUCCESS!")
            print(f"Output: {result.stdout.strip()}")
            
            # Extract flag
            import re
            flag_match = re.search(r'flag\{[^}]+\}', result.stdout)
            if flag_match:
                print(f"\n🏆 FLAG FOUND: {flag_match.group()}")
        else:
            print("❌ FAILED")
            print(f"Error: {result.stderr.strip()}")
            
    except FileNotFoundError:
        print("Binary not found - make sure license_validator is in current directory")
    except subprocess.TimeoutExpired:
        print("Process timed out")
    
    print("\n" + "="*50)
    print("Generating alternative valid keys:")
    alternative_keys = generate_alternative_keys()
    
    if alternative_keys:
        print(f"\nFound {len(alternative_keys)} valid alternatives:")
        for key in alternative_keys[:3]:  # Show first 3
            print(f"  {key}")
```

### Execution Output
```bash
$ python3 solve.py
=== LICENSE KEY GENERATOR ===
Based on reverse engineering analysis

Requirements discovered:
- Length: 16 characters
- Characters: digits only (0-9)
- Constraint: sum of digits = 64

Generated key: 4444444444444444
Validation: Valid license key

Testing with actual binary:
✅ SUCCESS!
Output: Congratulations! Here's your flag: flag{r3v3rs3_3ng1n33r1ng_m4d3_34sy_2024}

🏆 FLAG FOUND: flag{r3v3rs3_3ng1n33r1ng_m4d3_34sy_2024}

==================================================
Generating alternative valid keys:
Key: 4444444444444444 - Valid license key
Key: 5555555555555559 - Sum is 84 (expected 64)
Key: 3333333333333337 - Sum is 52 (expected 64)
Key: 4444444444444446 - Sum is 68 (expected 64)
Key: 4444444444444440 - Sum is 60 (expected 64)
Key: 4444444444444448 - Sum is 72 (expected 64)
Key: 4444444444444422 - Sum is 60 (expected 64)
Key: 4444444444444466 - Sum is 72 (expected 64)
Key: 4444444444442222 - Sum is 56 (expected 64)
Key: 8888888800000000 - Valid license key

Found 2 valid alternatives:
  4444444444444444
  8888888800000000
```

### Manual Verification
```bash
$ ./license_validator 4444444444444444
Congratulations! Here's your flag: flag{r3v3rs3_3ng1n33r1ng_m4d3_34sy_2024}

$ ./license_validator 8888888800000000  
Congratulations! Here's your flag: flag{r3v3rs3_3ng1n33r1ng_m4d3_34sy_2024}
```

---

## 🏁 Flag

```
flag{r3v3rs3_3ng1n33r1ng_m4d3_34sy_2024}
```

---

## 💭 Reflection

### What Went Well
- Ghidra provided excellent decompilation of the validation logic
- Clear understanding of all three constraints (length, digits, sum)
- Successfully generated multiple valid solutions
- Verified solution with actual binary execution

### Challenges Faced  
- Initial confusion about the exact sum requirement
- Had to understand the relationship between character arithmetic and actual values
- Testing multiple key combinations to verify the algorithm

### Learning Outcomes
- **Static Analysis**: Ghidra is powerful for understanding program logic
- **Algorithm Extraction**: Reverse engineering validation routines is common in CTFs
- **Constraint Satisfaction**: Many challenges involve finding inputs that meet specific mathematical constraints
- **Verification**: Always test your understanding with the actual binary

---

## 🔗 References

### Documentation
- [Ghidra Documentation](https://ghidra-sre.org/CheatSheet.html) - Reverse engineering tool
- [x86-64 Assembly Reference](https://www.cs.virginia.edu/~evans/cs216/guides/x86.html) - Understanding assembly
- [ELF File Format](https://en.wikipedia.org/wiki/Executable_and_Linkable_Format) - Binary file structure

### Similar Challenges
- PicoCTF: Reverse Engineering category - Various crackme challenges
- OverTheWire: Narnia/Behemoth - Binary exploitation with RE elements
- Crackmes.one - Dedicated platform for reverse engineering challenges

### Further Reading
- [Reverse Engineering for Beginners](https://beginners.re/) - Comprehensive guide
- [Radare2 Book](https://book.rada.re/) - Alternative RE tool
- [IDA Pro Book](https://nostarch.com/idapro2.htm) - Advanced techniques

---

## 🧠 Alternative Approaches

### Method 2: Dynamic Analysis with GDB
```bash
# Alternative approach - brute force with GDB scripting
$ gdb ./license_validator
(gdb) set pagination off
(gdb) break validate_license
(gdb) commands
silent
printf "Trying: %s\n", $rdi
continue
end

# Then try different inputs systematically
```

### Method 3: String Analysis
```bash
# Look for embedded strings that might give hints
$ strings license_validator | grep -E "(flag|key|valid|sum|64)"
flag{r3v3rs3_3ng1n33r1ng_m4d3_34sy_2024}
Invalid license key format!
```

Actually, we can see the flag directly in strings! But the proper approach teaches more.

---

## 📷 Screenshots

### Ghidra Decompilation
![Ghidra Analysis](path/to/ghidra_screenshot.png)
*Caption: Ghidra showing decompiled validate_license function*

### GDB Dynamic Analysis  
![GDB Session](path/to/gdb_screenshot.png)
*Caption: GDB breakpoint showing validation logic execution*

### Successful Execution
![Flag Output](path/to/success_screenshot.png)  
*Caption: Successful license validation revealing the flag*

---

## 📋 Challenge Rating

| Aspect | Rating (1-5) | Notes |
|--------|--------------|-------|
| Difficulty | ⭐⭐ | Easy-moderate, good for beginners |
| Fun Factor | ⭐⭐⭐ | Satisfying logic puzzle |
| Learning Value | ⭐⭐⭐⭐⭐ | Excellent intro to reverse engineering |
| Realism | ⭐⭐⭐ | Simplified but realistic validation logic |

**Overall**: ⭐⭐⭐⭐ (4/5) - Perfect learning challenge for RE beginners

---

## 📚 Appendix

### Complete Mathematical Solutions
```python
# All possible ways to get sum=64 with 16 digits
# This is a constrained optimization problem

def find_all_solutions(target_sum=64, num_digits=16):
    """Generate all valid license key combinations"""
    solutions = []
    
    def backtrack(current_digits, remaining_sum, remaining_positions):
        if remaining_positions == 0:
            if remaining_sum == 0:
                solutions.append(current_digits[:])
            return
        
        # Try each digit 0-9
        for digit in range(10):
            if digit <= remaining_sum:  # Pruning
                current_digits.append(digit)
                backtrack(current_digits, remaining_sum - digit, remaining_positions - 1)
                current_digits.pop()
    
    backtrack([], target_sum, num_digits)
    return solutions

# Note: This would generate a huge number of solutions
# The challenge just needs any valid one
```

### Assembly Code Analysis
```assembly
; validate_license function key parts
mov    rax, rdi          ; license_key argument
call   strlen            ; get length
cmp    rax, 0x10         ; compare with 16
jne    invalid           ; jump if not equal

; Sum calculation loop
mov    eax, 0x0          ; sum = 0
mov    ecx, 0x0          ; i = 0

sum_loop:
movzx  edx, BYTE PTR [rdi+rcx]  ; load character
sub    edx, 0x30               ; convert ASCII to digit  
add    eax, edx                ; add to sum
inc    ecx                     ; i++
cmp    ecx, 0x10               ; compare with 16
jne    sum_loop                ; continue if not done

cmp    eax, 0x40               ; compare sum with 64
```

---

**Completion Time**: `2 hours`
**Team Size**: `1 member`
**First Blood**: `NO` 
**Published**: `2024-01-15`

## Tags
#ctf-writeup #reverse-engineering #crackme #ghidra #static-analysis #algorithm-extraction