---
type: sop
title: Web, DNS & WHOIS OSINT
tags: [sop, webint, whois, dns]
---

# Web / DNS / WHOIS OSINT

## Objectives
- Link web assets to entities and operators
- Uncover infrastructure reuse and shared hosting patterns
- Build infrastructure maps for attribution

---

## 1. DNS Enumeration

### Active DNS Resolution
```bash
# Basic resolution
dig example.com A +short
dig example.com AAAA +short
dig example.com MX +short
dig example.com NS +short
dig example.com TXT +short

# Full zone information
dig example.com ANY

# Trace full delegation path
dig example.com +trace

# Check specific nameserver
dig @8.8.8.8 example.com A
```

### Subdomain Discovery
```bash
# Certificate transparency logs
curl -s "https://crt.sh/?q=%25.example.com&output=json" | jq -r '.[].name_value' | sort -u

# DNS brute force with common wordlist
dnsrecon -d example.com -t brt -D /usr/share/wordlists/subdomains.txt

# Passive subdomain enumeration
subfinder -d example.com -silent
amass enum -passive -d example.com
```

### Passive DNS (Historical Records)
- [SecurityTrails](https://securitytrails.com) - Historical DNS records
- [Passive Total](https://community.riskiq.com) - Passive DNS database
- [VirusTotal](https://virustotal.com) - DNS resolutions tab
- [DNSdumpster](https://dnsdumpster.com) - Free DNS recon tool

**Query pattern:**
```bash
# Using SecurityTrails API (requires key)
curl -s "https://api.securitytrails.com/v1/history/example.com/dns/a" \
  -H "APIKEY: YOUR_KEY" | jq .

# Check current vs historical IPs for changes
```

---

## 2. WHOIS Attribution

### Domain WHOIS
```bash
# Basic WHOIS lookup
whois example.com

# JSON output (using whoisjson.com or similar)
curl -s "https://www.whoisxmlapi.com/whoisserver/WhoisService?apiKey=KEY&domainName=example.com&outputFormat=json"

# Extract key fields
whois example.com | grep -E "(Registrant|Admin|Tech|Registrar|Creation Date|Expiry)"
```

### IP WHOIS (ASN/Org Attribution)
```bash
# IP ownership
whois 1.2.3.4

# ASN lookup
whois -h whois.cymru.com " -v 1.2.3.4"

# ARIN/RIPE/APNIC regional lookups
curl -s "https://rdap.arin.net/registry/ip/1.2.3.4" | jq .
```

### Privacy Shield Detection
- Look for privacy services: `REDACTED FOR PRIVACY`, `WhoisGuard`, `PrivacyProtect`, `Domains By Proxy`
- Registrar contact may still leak: check registrar abuse email
- Historical WHOIS may show original registrant before privacy was enabled

**Pivot points:**
- Registrant email/name → search across other domains
- Registrar → common choice patterns for threat actors
- Name servers → shared hosting/infrastructure clusters

---

## 3. Web Technology Fingerprinting

### Built-in Tools
```bash
# Server headers
curl -sI https://example.com | grep -E "(Server|X-Powered-By|X-AspNet-Version)"

# Full header inspection
curl -sI https://example.com

# Favicon hash (for infrastructure reuse detection)
curl -s https://example.com/favicon.ico | md5sum
```

### Specialized Tools
```bash
# Wappalyzer (CLI)
wappy https://example.com

# WhatWeb
whatweb https://example.com

# Webanalyze
webanalyze -host https://example.com -crawl 2
```

### Tracker & Analytics IDs

**Google Analytics (GA):**
```bash
# Extract GA tracking ID
curl -s https://example.com | grep -oP "UA-\d{4,10}-\d{1,4}"
curl -s https://example.com | grep -oP "G-[A-Z0-9]{10}"

# Pivot: Search for same GA ID across other domains
# Use: BuiltWith, PublicWWW, or NerdyData
```

**Other trackers to look for:**
- Google Tag Manager: `GTM-XXXXXXX`
- Facebook Pixel: `fbq('init', 'XXXXXXXXXX')`
- Hotjar: `hjid:XXXXXX`
- Yandex Metrica: `yaCounter`
- Adsense: `ca-pub-XXXXXXXXXXXXXXXX`

**Search databases:**
- [PublicWWW](https://publicwww.com) - Search source code of websites
- [BuiltWith](https://builtwith.com) - Technology profiler
- [NerdyData](https://nerdydata.com) - Source code search engine

---

## 4. SSL/TLS Certificate Intelligence

### Certificate Transparency Logs
```bash
# crt.sh query
curl -s "https://crt.sh/?q=example.com&output=json" | jq -r '.[].common_name' | sort -u

# Extract Subject Alternative Names (SANs)
curl -s "https://crt.sh/?q=example.com&output=json" | jq -r '.[].name_value' | sort -u

# Find all certs for an organization
curl -s "https://crt.sh/?O=Example+Inc&output=json" | jq .
```

### Live Certificate Inspection
```bash
# Extract certificate details
openssl s_client -connect example.com:443 </dev/null 2>/dev/null | openssl x509 -noout -text

# Subject Alternative Names
echo | openssl s_client -connect example.com:443 2>/dev/null | openssl x509 -noout -text | grep "DNS:"

# Issuer details
echo | openssl s_client -connect example.com:443 2>/dev/null | openssl x509 -noout -issuer
```

**Pivot opportunities:**
- SANs reveal additional domains on same certificate
- Certificate serial numbers for infrastructure clusters
- Issuer patterns (Let's Encrypt automation, OV vs DV validation)
- Self-signed certificates → likely internal/test infrastructure

---

## 5. Infrastructure & Hosting Attribution

### IP & Hosting Intelligence
```bash
# Resolve to IP
host example.com

# Reverse DNS
host 1.2.3.4

# Check for shared hosting (reverse IP lookup)
# Use tools like:
# - ViewDNS.info reverse IP lookup
# - SecurityTrails reverse IP
# - Shodan reverse IP search
```

### Shodan & Internet Scanning
```bash
# Shodan CLI (requires API key)
shodan search hostname:example.com
shodan host 1.2.3.4

# Search by certificate hash
shodan search ssl.cert.fingerprint:HASH

# Search by org/ASN
shodan search org:"Example Inc"
```

### Cloud Provider Detection
- AWS: Check if IP in AWS ranges, look for `amazonaws.com` in reverse DNS
- Cloudflare: `cloudflare.com` nameservers or Cloudflare IP ranges (1.1.1.0/24, etc.)
- Azure: `azurewebsites.net`, `azure.com` patterns
- Google Cloud: `googleusercontent.com`, `gcp` in reverse DNS

---

## 6. Asset Reuse & Correlation

### Favicon Hash Matching
```bash
# Download and hash favicon
curl -s https://example.com/favicon.ico | md5sum

# Search Shodan for same favicon hash
shodan search http.favicon.hash:HASH_VALUE
```

### Google Analytics Pivoting
1. Extract GA ID from target site
2. Search PublicWWW: `ga("create", "UA-XXXXX-X")`
3. Correlate domains using same tracking ID
4. Build ownership/operator map

### Shared Resources
Look for:
- Same IP hosting multiple domains (virtual hosting)
- Shared nameservers (same DNS provider)
- Same registrar + registration date patterns
- Shared CDN/proxy configurations
- Common CSS/JS resource URLs

---

## 7. Workflow Example

**Target:** `suspicious-site.com`

```bash
# 1. Basic DNS
dig suspicious-site.com A +short
dig suspicious-site.com MX +short
dig suspicious-site.com NS +short

# 2. WHOIS
whois suspicious-site.com | tee whois_$(date +%Y%m%d).txt
sha256sum whois_$(date +%Y%m%d).txt

# 3. Subdomains via cert transparency
curl -s "https://crt.sh/?q=%25.suspicious-site.com&output=json" | jq -r '.[].name_value' | sort -u

# 4. Technology fingerprint
whatweb suspicious-site.com

# 5. Extract tracking IDs
curl -s https://suspicious-site.com | grep -oP "(UA-\d+-\d+|GTM-[A-Z0-9]+|fbq\('init',\s*'\d+')"

# 6. Favicon hash
curl -s https://suspicious-site.com/favicon.ico | md5sum

# 7. Check Shodan
shodan search hostname:suspicious-site.com

# 8. Passive DNS history
# Query SecurityTrails/VirusTotal for historical IPs

# 9. Pivot on findings
# - Search GA ID on PublicWWW
# - Search registrant email on WHOIS history databases
# - Check IP neighbors on same subnet
```

---

## 8. Collection & Documentation

**For each query, log:**
- Exact command/query used
- Timestamp (UTC)
- Resolver/source used (e.g., `8.8.8.8`, `crt.sh`, `SecurityTrails`)
- Full response (save to file)
- SHA-256 hash of saved output

**File structure:**
```
/Evidence/{case_id}/WebIntel/
  ├── dns/
  │   ├── 20251005_dig_example.com_A.txt
  │   └── 20251005_subdomains_crt.sh.json
  ├── whois/
  │   └── 20251005_whois_example.com.txt
  ├── tech/
  │   └── 20251005_whatweb_output.json
  └── screenshots/
      └── 20251005_homepage.png
```

---

## 9. Privacy & Legal

- **Do not** query infrastructure without authorization if doing pentesting
- **Respect** rate limits on public services (crt.sh, WHOIS servers)
- **Avoid** WHOIS harvesting at scale (triggers abuse detection)
- **Log all queries** for defensibility and chain of custody
- **Use VPN/proxy** when operational security requires it

---

## 10. Tools Reference

| Tool | Purpose | Install/Link |
|------|---------|--------------|
| `dig` | DNS queries | Built-in (Linux/Mac) |
| `whois` | Domain/IP registration | Built-in |
| `curl` | HTTP requests | Built-in |
| `subfinder` | Passive subdomain enum | [GitHub](https://github.com/projectdiscovery/subfinder) |
| `amass` | Network mapping | [GitHub](https://github.com/owasp-amass/amass) |
| `whatweb` | Web fingerprinting | `apt install whatweb` |
| `shodan` | Internet-wide scanning | [shodan.io](https://shodan.io) |
| `crt.sh` | Cert transparency | [crt.sh](https://crt.sh) |
| PublicWWW | Source code search | [publicwww.com](https://publicwww.com) |
| SecurityTrails | DNS/WHOIS history | [securitytrails.com](https://securitytrails.com) |

---

## 11. Common Pitfalls

❌ Forgetting to capture timestamps and resolver sources
❌ Not hashing saved evidence files
❌ Querying only current state (missing historical context)
❌ Ignoring privacy shields (check historical WHOIS)
❌ Not correlating across multiple data points
❌ Assuming DNS/WHOIS data is always accurate (can be spoofed/outdated)
