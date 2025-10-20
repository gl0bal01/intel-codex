# Exercise 02: Domain Analysis

**Difficulty:** 📗 Beginner
**Estimated Time:** 3-5 hours
**Prerequisites:** Exercise 01 completed, Web/DNS/WHOIS SOP reviewed

---

## 🎯 Learning Objectives

By completing this exercise, you will learn to:
1. **Perform WHOIS lookups** and interpret registration data
2. **Analyze DNS records** (A, MX, TXT, NS records)
3. **Investigate SSL/TLS certificates** and certificate transparency logs
4. **Identify hosting infrastructure** and CDN usage
5. **Assess domain reputation** and potential threats
6. **Document technical findings** in investigative format

---

## 📋 Scenario

**Case ID:** EXERCISE-2025-002
**Target Domain:** `suspicious-tech-deals.example` (fictional for training)
**Authorization:** Educational exercise (fictional scenario)

**Background:**
A colleague received a phishing email promoting "exclusive tech deals" from the domain `suspicious-tech-deals.example`. Your task is to investigate this domain's infrastructure, ownership, and reputation to assess whether it's legitimate or malicious.

**Important:** This is a **FICTIONAL** domain. For this exercise, you will use a **real, safe domain** to practice your skills.

**Practice Domain:** Use `example.com` (official IANA reserved domain for documentation)

---

## 📝 Your Assignment

### Part 1: WHOIS Investigation (1 hour)

**Task:** Perform comprehensive WHOIS lookups on the target domain.

**Information to Collect:**
- [ ] Domain registrar
- [ ] Registration date
- [ ] Expiration date
- [ ] Last updated date
- [ ] Registrant information (name, organization, email)
- [ ] Administrative contact
- [ ] Technical contact
- [ ] Name servers
- [ ] Domain status (locked, unlocked, etc.)
- [ ] Privacy protection status

**Tools to Use:**
- `whois` command-line tool
- https://whois.domaintools.com/
- https://lookup.icann.org/
- Your registrar's WHOIS lookup

**Commands to Run:**
```bash
# Basic WHOIS lookup
whois example.com

# Save output to file
whois example.com > whois-example-com.txt

# Historical WHOIS (if available via web tools)
# Check DomainTools or similar services
```

**What to Document:**
- Save raw WHOIS output to `Evidence/domains/whois-raw.txt`
- Screenshot of web-based WHOIS lookup
- Note any privacy protection services used
- Identify any suspicious patterns (recent registration, frequent changes)

---

### Part 2: DNS Analysis (1-2 hours)

**Task:** Enumerate and analyze DNS records for the domain.

**DNS Records to Query:**
- [ ] **A Record** - IPv4 addresses
- [ ] **AAAA Record** - IPv6 addresses
- [ ] **MX Record** - Mail servers
- [ ] **TXT Record** - SPF, DKIM, DMARC, other text records
- [ ] **NS Record** - Name servers
- [ ] **CNAME Record** - Aliases
- [ ] **SOA Record** - Start of Authority

**Tools to Use:**
- `dig` command-line tool (Linux/Mac)
- `nslookup` command-line tool (Windows)
- https://mxtoolbox.com/
- https://dnsdumpster.com/

**Commands to Run:**
```bash
# All DNS records
dig example.com ANY

# Specific record types
dig example.com A
dig example.com AAAA
dig example.com MX
dig example.com TXT
dig example.com NS

# Reverse DNS lookup
dig -x [IP-ADDRESS]
```

**What to Analyze:**
1. **IP Address(es):** Who hosts the domain? (Use IP geolocation tools)
2. **Mail Servers:** Does the domain send email? Are SPF/DKIM/DMARC configured?
3. **Name Servers:** Who manages DNS? (Cloudflare, AWS, Google, self-hosted?)
4. **TXT Records:** Any security policies, verification records, or suspicious entries?

**What to Document:**
- Save all DNS query results to `Evidence/domains/dns-records.txt`
- Screenshot of DNS lookup tools
- Create a table summarizing key findings

---

### Part 3: SSL/TLS Certificate Investigation (45-60 minutes)

**Task:** Analyze the domain's SSL/TLS certificate and search certificate transparency logs.

**Certificate Information to Collect:**
- [ ] Issuer (Certificate Authority)
- [ ] Validity period (issued date, expiration date)
- [ ] Subject Alternative Names (SANs) - other domains on same cert
- [ ] Certificate type (DV, OV, EV)
- [ ] Public key algorithm and size
- [ ] Certificate transparency logs

**Tools to Use:**
- Browser (visit https://example.com and view certificate)
- https://crt.sh/ (Certificate Transparency search)
- https://censys.io/
- `openssl` command-line tool

**Commands to Run:**
```bash
# Check SSL certificate
openssl s_client -connect example.com:443 -servername example.com < /dev/null

# Extract certificate details
echo | openssl s_client -connect example.com:443 2>/dev/null | openssl x509 -noout -text
```

**What to Analyze:**
1. **Certificate Issuer:** Free (Let's Encrypt) or paid CA? (Free = potentially suspicious)
2. **Certificate Age:** Recently issued for old domain? (Possible takeover)
3. **SANs:** Other domains sharing certificate? (Hosting patterns)
4. **CT Logs:** Any subdomain discoveries via crt.sh?

**What to Document:**
- Screenshot of certificate details from browser
- Save crt.sh search results showing all certificates for domain
- List of discovered subdomains
- Certificate validity assessment

---

### Part 4: Hosting & Infrastructure Analysis (1 hour)

**Task:** Identify hosting provider, CDN usage, and infrastructure patterns.

**Information to Collect:**
- [ ] Hosting provider (from IP WHOIS lookup)
- [ ] Geographic location of servers
- [ ] CDN usage (Cloudflare, Akamai, etc.)
- [ ] Shared hosting indicators (reverse IP lookup)
- [ ] HTTP headers (server software, security headers)
- [ ] Technologies used (CMS, frameworks)

**Tools to Use:**
- https://builtwith.com/
- https://www.shodan.io/ (IP intelligence)
- https://securityheaders.com/
- `curl` command-line tool
- Reverse IP lookup tools

**Commands to Run:**
```bash
# Get HTTP headers
curl -I https://example.com

# More detailed headers
curl -v https://example.com 2>&1 | grep -E "^(<|>)"

# IP geolocation (use web tools or APIs)
# Reverse IP lookup (find other domains on same IP)
```

**What to Analyze:**
1. **Hosting Provider:** Legitimate provider or bulletproof hosting?
2. **Shared Hosting:** How many other domains share the IP? (High = shared hosting)
3. **CDN:** Using Cloudflare/similar? (Hides real IP, complicates investigation)
4. **Security Headers:** HSTS, CSP, X-Frame-Options present? (Good = more legitimate)
5. **Server Software:** Outdated versions? (Vulnerable = possibly compromised)

**What to Document:**
- Save HTTP headers to `Evidence/domains/http-headers.txt`
- Screenshot of BuiltWith analysis
- IP geolocation results
- Reverse IP lookup results (other domains on same IP)

---

### Part 5: Reputation & Threat Intelligence (30-45 minutes)

**Task:** Check domain reputation across threat intelligence sources.

**Checks to Perform:**
- [ ] VirusTotal scan
- [ ] Google Safe Browsing status
- [ ] URLhaus (malware URL database)
- [ ] PhishTank (phishing database)
- [ ] AbuseIPDB (IP reputation)
- [ ] Spamhaus (spam/malware blocklists)

**Tools to Use:**
- https://virustotal.com/
- https://transparencyreport.google.com/safe-browsing/search
- https://urlhaus.abuse.ch/
- https://phishtank.org/
- https://abuseipdb.com/
- https://check.spamhaus.org/

**What to Document:**
- VirusTotal scan results (how many engines flag it?)
- Safe Browsing status (clean or flagged?)
- Any threat intelligence hits
- Screenshot of all reputation checks
- Summary table of findings

---

### Part 6: Analysis & Reporting (1 hour)

**Task:** Synthesize findings and create assessment report.

**Create These Documents:**

1. **`00-Domain-Investigation-Summary.md`**
   - Executive summary
   - Key findings
   - Risk assessment (Low/Medium/High)
   - Indicators of compromise (if any)
   - Recommendations

2. **`01-Technical-Findings.md`**
   - Detailed DNS/WHOIS data
   - Certificate analysis
   - Hosting infrastructure summary
   - Technology stack

3. **`02-Collection-Log.md`**
   - All evidence logged with hashes

**Risk Assessment Framework:**

| Indicator | Suspicious | Legitimate | Your Finding |
|-----------|------------|------------|--------------|
| Domain age | < 30 days | > 1 year | |
| WHOIS privacy | Yes (hidden) | No (transparent) | |
| Certificate | Free (Let's Encrypt) | Paid CA (EV/OV) | |
| Hosting | Bulletproof/foreign | Major provider | |
| Reputation | Flagged by 5+ engines | Clean across all | |
| Email config | No SPF/DKIM/DMARC | Properly configured | |

**Scoring:**
- 0-1 suspicious indicators = Low Risk
- 2-3 suspicious indicators = Medium Risk
- 4+ suspicious indicators = High Risk

---

## ✅ Completion Criteria

Your exercise is complete when:
- [ ] WHOIS data collected and saved
- [ ] All DNS records queried and documented
- [ ] SSL certificate analyzed (including CT logs)
- [ ] Hosting infrastructure identified
- [ ] Reputation checks performed across 5+ sources
- [ ] Collection log complete with all evidence hashed
- [ ] Risk assessment completed with scoring
- [ ] Final report written (executive summary + technical findings)

---

## 🎓 Self-Assessment Questions

1. **Based on your analysis, would you classify this domain as suspicious? Why?**
2. **What was the most revealing piece of information you discovered?**
3. **If this were a real phishing investigation, what would be your next steps?**
4. **What additional tools would you want to use in a real-world scenario?**
5. **How would you explain your findings to a non-technical audience?**

---

## 📤 Submission Instructions

**Folder Structure:**
```
Exercise-02-Domain-Analysis/
├── 00-Domain-Investigation-Summary.md
├── 01-Technical-Findings.md
├── 02-Collection-Log.md
└── Evidence/
    └── domains/
        ├── whois-raw.txt
        ├── dns-records.txt
        ├── http-headers.txt
        ├── certificate-details.txt
        └── screenshots/
            ├── whois-lookup.png
            ├── dns-results.png
            ├── virustotal-scan.png
            └── builtwith-analysis.png
```

Submit as: `Exercise-02-[YourName]-[Date].zip`

---

## 💡 Hints & Tips

**Common Challenges:**

1. **"I can't run command-line tools"**
   - Use web-based alternatives (MXToolbox, DNSdumpster, etc.)
   - Windows users: Use `nslookup` instead of `dig`
   - Google Colab/Replit for Linux commands

2. **"The domain is using Cloudflare"**
   - This is common - document it
   - Real IP hidden behind CDN (note as finding)
   - Check historical DNS for original IP

3. **"I found too much information"**
   - Focus on key indicators (registration date, reputation, hosting)
   - Summarize, don't transcribe everything
   - Use tables for easy reference

4. **"Everything looks legitimate"**
   - That's okay! Document why it's legitimate
   - Practice is about the process, not just finding threats
   - Low-risk findings are still valid

---

## 🔍 Advanced Challenges (Optional)

**For students who finish early:**

1. **Subdomain Enumeration:**
   - Use `sublist3r` or `subfinder` to find subdomains
   - Check certificate transparency logs for historical subdomains
   - Analyze subdomain naming patterns

2. **Historical Analysis:**
   - Use Wayback Machine (archive.org) to see domain history
   - Check historical WHOIS via SecurityTrails
   - Compare current vs. historical DNS records

3. **Associated Domains:**
   - Find other domains registered by same email
   - Search for domains on same IP
   - Identify domain registration patterns

---

## 📚 Related Resources

**Required Reading:**
- [Web, DNS & WHOIS OSINT SOP](../../../Investigations/Techniques/sop-web-dns-whois-osint.md)
- [Legal & Ethics SOP](../../../Investigations/Techniques/sop-legal-ethics.md)
- [Collection Logging SOP](../../../Investigations/Techniques/sop-collection-log.md)

**Reference Material:**
- [Example Investigation - Infrastructure Section](../../2025-001-Example-Investigation/00-Case-Overview.md#network-infrastructure)

**Tool Documentation:**
- WHOIS Guide: https://whois.icann.org/en/about-whois
- DNS Records Explained: https://www.cloudflare.com/learning/dns/dns-records/
- Certificate Transparency: https://certificate.transparency.dev/

---

## ⚠️ Important Reminders

- ✅ Use **example.com** for practice (safe, official test domain)
- ✅ **Don't scan** real suspicious domains without authorization
- ✅ **Document everything** - screenshots + raw output
- ✅ Practice **passive reconnaissance only** (no active probing)
- ❌ **Don't visit** actual phishing/malware domains in browser
- ❌ **Don't interact** with suspicious sites (no clicks, no forms)

---

**Exercise Created:** 2025-10-12
**Version:** 1.0
**Difficulty:** 📗 Beginner
**Estimated Completion Time:** 3-5 hours
