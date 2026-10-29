---
type: sop
title: Web, DNS & WHOIS OSINT
description: "Domain intelligence techniques: WHOIS/RDAP lookups, DNS records, certificate transparency, subdomain enumeration, passive DNS & infrastructure mapping for web investigations."
tags: [sop, webint, whois, rdap, dns, dnssec, ct-logs, subdomain-enumeration]
updated: 2026-10-29
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
# Basic resolution [verify 2026-10-29]
dig example.com A +short
dig example.com AAAA +short
dig example.com MX +short
dig example.com NS +short
dig example.com TXT +short
dig example.com CAA +short    # CA-authorization for cert pivots

# SOA / zone authority
dig example.com SOA +short

# Trace full delegation path (root → TLD → authoritative)
dig example.com +trace

# Check specific nameserver / bypass local resolver caching
dig @8.8.8.8 example.com A
dig @1.1.1.1 example.com A +noall +answer

# ANY is widely refused since RFC 8482 — prefer per-type queries [verify 2026-10-29]
dig example.com ANY    # may return HINFO "RFC8482" only
```

### DNSSEC Inspection
```bash
# Validate chain & display RRSIG / DNSKEY / DS records [verify 2026-10-29]
dig example.com +dnssec +multi
dig example.com DNSKEY +short
dig example.com DS +short

# AD flag (Authenticated Data) confirms validating resolver succeeded
dig @1.1.1.1 example.com +dnssec | grep -E "flags:|RRSIG"

# delv = BIND's DNSSEC-validating lookup tool (same resolver/validator logic as named; dig-like syntax) [verify 2026-10-29]
delv example.com A
```
Notes:
- Absence of DS at the parent → zone is unsigned (no DNSSEC).
- `delv` returns `; fully validated` only when the chain anchors back to the root KSK. [verify 2026-10-29]
- Lame DS / expired RRSIG / missing NSEC3 are common operator misconfigurations worth flagging in dossiers.

### Subdomain Discovery
```bash
# Certificate transparency logs (URL-encode the wildcard: %25 == %) [verify 2026-10-29]
curl -s "https://crt.sh/?q=%25.example.com&output=json" | jq -r '.[].name_value' | sort -u

# Modern passive enumeration (ProjectDiscovery toolchain) [verify 2026-10-29]
subfinder -d example.com -silent -all                 # passive sources
assetfinder --subs-only example.com                   # tomnomnom, passive
amass enum -d example.com -timeout 5                  # OWASP Amass v5: passive by default (-passive is deprecated; add -active for zone transfers/cert grabs); -timeout = minutes without progress

# Resolve & filter live hosts (dnsx) [verify 2026-10-29]
subfinder -d example.com -silent | dnsx -silent -a -resp

# Brute-force / permutation [verify 2026-10-29]
dnsrecon -d example.com -t brt -D /usr/share/wordlists/subdomains.txt
puredns bruteforce wordlist.txt example.com -r resolvers.txt
gotator -sub subs.txt -perm permutations.txt -depth 1 -numbers 10 | dnsx -silent
```
Install hints (verify against upstream README before pinning):
- `subfinder`: `go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest` [verify 2026-10-29]
- `amass`: `CGO_ENABLED=0 go install -v github.com/owasp-amass/amass/v5/cmd/amass@main` (v5 module path; repo default branch is `main`) [verify 2026-10-29]
- `dnsx`: `go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest` [verify 2026-10-29]
- `assetfinder`: `go install github.com/tomnomnom/assetfinder@latest` (README still shows the pre-modules `go get -u`) [verify 2026-10-29]

### Passive DNS (Historical Records)
- [SecurityTrails](https://securitytrails.com) — Historical DNS / WHOIS; paid tiers gated — free-tier quota unconfirmed (pricing page not publicly reachable), check before relying on it
- [DomainTools Iris / Farsight DNSDB](https://www.domaintools.com/products/farsight-dnsdb/) — Farsight was acquired by DomainTools (Nov 2021); the DNSDB product URL now redirects to the DomainTools platform page [verify 2026-10-29]
- [Microsoft Defender Threat Intelligence](https://security.microsoft.com) — RiskIQ PassiveTotal lineage (community.riskiq.com retired post-acquisition); the standalone `ti.defender.microsoft.com` portal is gone — use **Threat intelligence → Intel explorer** and entity-page enrichment in the Defender portal [verify 2026-10-29]
- [Mnemonic PassiveDNS](https://passivedns.mnemonic.no/) — public API without authentication (TLP:WHITE data only; 10 req/min, 1000 req/day; `https://api.mnemonic.no/pdns/v3/<query>`); API key on request for higher limits [verify 2026-10-29]
- [VirusTotal](https://virustotal.com) — Relations / Resolutions tab, requires VT account; VT Intelligence (paid) for retro-search
- [DNSdumpster](https://dnsdumpster.com) — free web tool; API and paid Membership available (see `/developer/`) [verify 2026-10-29]
- [URLScan.io](https://urlscan.io/) — DOM / page / IP history; public-by-default unless team plan

**Query pattern:**
```bash
# SecurityTrails API (historical A records) [verify 2026-10-29]
curl -s "https://api.securitytrails.com/v1/history/example.com/dns/a" \
  -H "APIKEY: $SECURITYTRAILS_KEY" | jq .

# DomainTools Iris Investigate (historical pivots; API key or HMAC-signed auth)
# See https://docs.domaintools.com/api/iris/investigate/ (auth: https://docs.domaintools.com/api/iris/authentication/) [verify 2026-10-29]

# Wayback Machine CDX — historical snapshots of a host [verify 2026-10-29]
curl -s "https://web.archive.org/cdx/search/cdx?url=example.com&output=json&limit=100&fl=timestamp,original,statuscode,mimetype" | jq .
```

---

## 2. WHOIS / RDAP Attribution

> **Protocol note:** RDAP (Registration Data Access Protocol, RFC 9082/9083) is ICANN's structured-JSON successor to legacy WHOIS port-43 text. ICANN's 2023 Global Amendments (effective 7 Aug 2023) ran a 180-day RDAP ramp-up (to 3 Feb 2024) and sunset the contractual WHOIS obligation on **28 January 2025**: gTLD registries/registrars are no longer required to serve WHOIS (exceptions: .com, .name, .post). The Registration Data Policy (redaction rules, `REDACTED` placeholder) took effect 21 Aug 2025. Treat RDAP as primary for gTLDs; WHOIS may be absent or stale (status: https://www.icann.org/rdap). ccTLDs follow their own timelines; many still expose only WHOIS. [verify 2026-10-29]

### Domain WHOIS (legacy port-43)
```bash
# Basic WHOIS lookup
whois example.com

# Force a specific server (registrar thin-WHOIS, regional WHOIS) [verify 2026-10-29]
whois -h whois.verisign-grs.com example.com
whois -h whois.iana.org example.com    # IANA root → authoritative referral

# Extract key fields
whois example.com | grep -iE "(Registrant|Admin|Tech|Registrar|Creation|Updated|Expir|Name Server)"
```

### Domain RDAP (modern, structured JSON)
```bash
# Direct registry RDAP (Verisign for .com/.net) [verify 2026-10-29]
curl -s "https://rdap.verisign.com/com/v1/domain/example.com" | jq .

# Bootstrap router — auto-routes to the responsible registry [verify 2026-10-29]
curl -s "https://rdap.org/domain/example.com" | jq .

# CLI client (Go reference implementation)
# install: go install github.com/openrdap/rdap/cmd/rdap@latest [verify 2026-10-29]
rdap example.com
rdap --json example.com | jq '.entities[] | select(.roles[]=="registrant")'
```
Pivot fields exposed by RDAP that legacy WHOIS often loses to free-form text:
- `events[].eventAction` (registration, last changed, expiration) with ISO-8601 timestamps [verify 2026-10-29]
- `entities[].roles` (registrant / admin / tech / abuse) keyed by vCard arrays [verify 2026-10-29]
- `nameservers[].ldhName` and `ipAddresses` [verify 2026-10-29]
- `secureDNS` (delegationSigned, dsData) → DNSSEC posture [verify 2026-10-29]
- `links[].rel` (`self`, `related`, `up`, `alternate`) for traversal; registry notices carry their own links (e.g. `terms-of-service`) [verify 2026-10-29]

### IP WHOIS / RDAP (ASN/Org Attribution)
```bash
# IP ownership (RIR-aware, follows referrals)
whois 1.2.3.4

# Team Cymru bulk ASN [verify 2026-10-29]
whois -h whois.cymru.com " -v 1.2.3.4"

# RIR RDAP endpoints [verify 2026-10-29]
curl -s "https://rdap.arin.net/registry/ip/1.2.3.4"   | jq .
curl -s "https://rdap.db.ripe.net/ip/1.2.3.4"         | jq .
curl -s "https://rdap.apnic.net/ip/1.2.3.4"           | jq .
curl -s "https://rdap.lacnic.net/rdap/ip/1.2.3.4"     | jq .
curl -s "https://rdap.afrinic.net/rdap/ip/1.2.3.4"    | jq .

# ASN → announced prefixes (RIPEstat, from RIPE RIS BGP collectors) [verify 2026-10-29]
curl -s "https://stat.ripe.net/data/announced-prefixes/data.json?resource=AS13335" | jq -r '.data.prefixes[].prefix'
```

### Privacy / Redaction Detection
GDPR (May 2018) drove blanket redaction of registrant personal data for EU and many non-EU registrars. Common markers in WHOIS/RDAP output:

| Indicator | Meaning |
|-----------|---------|
| `REDACTED FOR PRIVACY` / `Data Protected` | GDPR-style registrar-side redaction (post-2018 default) |
| `Domains By Proxy, LLC` | GoDaddy proxy service |
| `WhoisGuard, Inc.` / `Withheld for Privacy ehf` | Namecheap proxy (rebranded ~2021 → "Privacy service provided by Withheld for Privacy ehf") [verify 2026-10-29] |
| `Contact Privacy Inc.` | Tucows/OpenSRS proxy |
| `PrivacyProtect.org` / `Perfect Privacy LLC` | other registrar resellers |
| `Identity Digital Services` / `MarkMonitor` privacy | enterprise proxy/brand-protection |

Registrar contact may still leak (abuse email, registrar IANA ID); historical WHOIS via DomainTools / WhoisXML / ViewDNS may show pre-redaction registrant data — but cite the snapshot date.

**Pivot points:**
- Registrant email / name → search across other domains (DomainTools Reverse WHOIS, WhoisXML reverse lookup, ViewDNS)
- Registrar IANA ID + creation date → common-choice patterns for threat actors
- Name servers (NS) → shared hosting / infrastructure clusters
- ASN + IP block → infrastructure operator, hosting reputation
- DNSSEC DS records → operational maturity signal

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
# WhatWeb (Ruby; built-in plugin set) [verify 2026-10-29]
whatweb -a 3 https://example.com

# webanalyze (Go port of Wappalyzer fingerprints; offline DB) [verify 2026-10-29]
webanalyze -host https://example.com -crawl 2

# wappalyzergo (ProjectDiscovery Go library; fingerprints from enthec/webappanalyzer + HTTPArchive/wappalyzer) — the practical CLI is httpx [verify 2026-10-29]
# helper install (per README): go install -v github.com/projectdiscovery/wappalyzergo/cmd/update-fingerprints@latest
echo "https://example.com" | httpx -tech-detect -silent
```
Wappalyzer removed public access to its app definitions; open-source ports (`webanalyze`, `wappalyzergo`) load community-maintained fingerprints (enthec/webappanalyzer) and are the practical CLI choices [verify 2026-10-29].

### Tracker & Analytics IDs

**Google Analytics:**
```bash
# GA4 (current; "G-" prefix + letters/digits — Google states no fixed length; 10 is typical) [verify 2026-10-29]
curl -s https://example.com | grep -oE "G-[A-Z0-9]{6,}"

# Universal Analytics (UA-XXXXXXX-X) — standard properties stopped processing 2023-07-01 (360 extension to 2024-07-01; data deleted from 2024-07-01); [verify 2026-10-29]
# IDs are sunset operationally but still useful as historical correlation pivots.
curl -s https://example.com | grep -oE "UA-[0-9]{4,10}-[0-9]{1,4}"

# AdSense / AdManager [verify 2026-10-29]
curl -s https://example.com | grep -oE "ca-pub-[0-9]{16}"

# Google Tag Manager container
curl -s https://example.com | grep -oE "GTM-[A-Z0-9]{6,8}"
```

**Other trackers to look for:**
- Facebook Pixel: `fbq('init', 'XXXXXXXXXX')` (15-16 digit ID)
- Hotjar: `hjid:XXXXXXX`
- Yandex Metrica: `ym(XXXXXXXX, "init"`
- Mixpanel project token: 32-char hex in `mixpanel.init("...")`
- Segment write key: `analytics.load("XXXXXXXXXXXXXXXXXXXXXXXXXX")`
- Cloudflare Web Analytics: `data-cf-beacon='{"token":"..."}'`
- Plausible / Fathom / Matomo: self-hosted endpoints in `<script src=...>` — pivot on the host, not the ID

**Search databases (cross-site ID pivoting):**
- [PublicWWW](https://publicwww.com) — source-code search; metered free, paid for bulk export
- [BuiltWith](https://builtwith.com) — technology profiler; paid for "Relationships" report (the actual GA-ID pivot)
- [NerdyData](https://nerdydata.com) — source-code search engine
- [URLScan.io](https://urlscan.io/search/) — search by tech, hash, GA ID, favicon hash via the `task.tags` / `page.url` query DSL [verify 2026-10-29]
- [Netlas.io](https://netlas.io/) — SaaS internet-asset search (free Community plan: 50 requests/day) [verify 2026-10-29]

---

## 4. SSL/TLS Certificate Intelligence

### Certificate Transparency Logs
```bash
# crt.sh JSON query (Sectigo's public CT-aggregator; rate-limited, no auth) [verify 2026-10-29]
curl -s "https://crt.sh/?q=example.com&output=json" | jq -r '.[].common_name' | sort -u

# Subject Alternative Names — usually the highest-value field
curl -s "https://crt.sh/?q=example.com&output=json" | jq -r '.[].name_value' | sort -u

# Wildcard subdomain hunt (URL-encoded %)
curl -s "https://crt.sh/?q=%25.example.com&output=json" | jq -r '.[].name_value' | sort -u

# Search by O= (Subject Organization)
curl -s "https://crt.sh/?O=Example+Inc&output=json" | jq .

# Direct CT-log query alternatives (when crt.sh is down / 502s)
# - Censys Platform: https://platform.censys.io (Legacy Search at search.censys.io deprecated Sept 2026) [verify 2026-10-29]
# - Google Transparency Report certificate search (web UI): https://transparencyreport.google.com/https/certificates
```
Usable CT logs on Chrome's list (Oct 2026) include Google Argon/Xenon (+ tiled ParcelYard/PlumbersArms), Cloudflare Nimbus, DigiCert Wyvern/Sphinx, Sectigo Elephant/Tiger (Sabre/Mammoth now read-only), Let's Encrypt Sycamore/Willow (Oak retired), TrustAsia, Geomys Tuscolo and IPng Halloumi/Gouda — logs are temporally sharded and rotate, so pull the live list from https://www.gstatic.com/ct/log_list/v3/log_list.json [verify 2026-10-29].

### Live Certificate Inspection
```bash
# Full certificate text [verify 2026-10-29]
openssl s_client -connect example.com:443 -servername example.com </dev/null 2>/dev/null \
  | openssl x509 -noout -text

# Subject Alternative Names only
echo | openssl s_client -connect example.com:443 -servername example.com 2>/dev/null \
  | openssl x509 -noout -ext subjectAltName

# Issuer + serial + fingerprints (SHA-1 + SHA-256)
echo | openssl s_client -connect example.com:443 -servername example.com 2>/dev/null \
  | openssl x509 -noout -issuer -serial -fingerprint -sha256

# Full chain dump for OCSP / pin investigation
openssl s_client -connect example.com:443 -servername example.com -showcerts </dev/null
```
Always pass `-servername` (SNI) — modern multi-tenant edges return a default cert when SNI is omitted, hiding the real one.

### TLS / JARM / JA3-JA4 Fingerprinting
Server-side TLS handshake fingerprints (JARM) and client-side ClientHello fingerprints (JA3/JA4) cluster infrastructure even when the cert and IP differ:

```bash
# JARM — Salesforce-published server TLS fingerprint (reference script; Python 3 needs no extra deps) [verify 2026-10-29]
git clone https://github.com/salesforce/jarm
python3 jarm/jarm.py -p 443 example.com

# JA4+ suite (FoxIO; supersedes JA3): ja4 / ja4s / ja4h / ja4t etc. [verify 2026-10-29]
# https://github.com/FoxIO-LLC/ja4
```

**Pivot opportunities:**
- SANs reveal additional domains on the same certificate (#1 single-query pivot)
- Certificate serial number + Issuer DN → cluster of certs from the same issuance batch
- JARM hash → infrastructure family (default Cobalt Strike / nginx / cloudfront have known JARMs)
- JA3/JA4 hash → C2 / scanner / proxy attribution
- Issuer patterns (Let's Encrypt YR1/YR2 RSA and YE1/YE2 ECDSA — R10–R14/E5–E9 are retired but still seen on older certs; ZeroSSL; Cloudflare Universal SSL via Let's Encrypt / Google Trust Services / SSL.com) reveal automation choices [verify 2026-10-29]
- Self-signed or internal-CA certificates → likely lab / test / staging

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

### Internet-Wide Scanning (Shodan / Censys / FOFA / ZoomEye)
Tier limits, query syntax, and result quotas change quarterly across all four — verify current limits at the vendor's pricing page before promising coverage to a stakeholder [verify 2026-10-29].

```bash
# Shodan (https://www.shodan.io) [verify 2026-10-29]
shodan search hostname:example.com
shodan host 1.2.3.4
shodan search 'ssl.cert.fingerprint:"HASH"'
shodan search 'org:"Example Inc"'
shodan search 'http.favicon.hash:-123456789'

# Censys Platform (https://platform.censys.io) — Legacy Search (search.censys.io) and its API deprecated Sept 2026 [verify 2026-10-29]
# CLI: cencli (brew install censys/tap/cencli ; censys config auth add  → Platform personal access token);
#   uninstall the legacy `censys` pip CLI first — both use the `censys` command name
# Platform queries use CenQL — convert legacy `services.*` queries with the built-in query converter before reuse

# FOFA (https://en.fofa.info/) — popular in red-team recon
# (web UI / API; key-only auth per the official fofa-py SDK; query is base64-encoded) [verify 2026-10-29]
QUERY=$(echo -n 'domain="example.com"' | base64 -w0)
curl -s "https://fofa.info/api/v1/search/all?key=$FOFA_KEY&qbase64=$QUERY"

# ZoomEye (https://www.zoomeye.ai/ international; https://www.zoomeye.org/ CN) — Knownsec
# CLI: pip3 install zoomeyeai ; zoomeyeai init -apikey "$ZOOMEYE_KEY" ; dork syntax at https://www.zoomeye.ai/help [verify 2026-10-29]
zoomeyeai search 'domain="example.com"'

# Quake (360 Cyberspace Mapping, https://quake.360.net/; Chinese-language UI) — alternative when others are dry [verify 2026-10-29]
```

### Favicon hash → infrastructure pivot
Shodan's `http.favicon.hash` is **mmh3** (MurmurHash3) of the **base64-encoded** favicon, signed 32-bit [verify 2026-10-29]. FOFA uses the same convention.

```bash
# Compute Shodan/FOFA-style favicon hash
python3 - <<'PY'
import mmh3, base64, requests
r = requests.get("https://example.com/favicon.ico", timeout=10)
h = mmh3.hash(base64.encodebytes(r.content))
print(h)
PY

# Pivot in Shodan / FOFA
shodan search "http.favicon.hash:$HASH"
```
MD5 of the raw bytes (the older `curl … | md5sum` recipe) is fine for unique-asset comparison but is **not** what Shodan / FOFA index — don't query their APIs with it.

### Cloud Provider Detection
Always check vendor-published prefix lists (they rotate); reverse DNS is a hint, not proof.

| Provider | Reverse-DNS / SNI hints | Authoritative prefix list |
|----------|-------------------------|---------------------------|
| AWS | `*.compute.amazonaws.com`, `*.elb.amazonaws.com`, `*.cloudfront.net` | https://ip-ranges.amazonaws.com/ip-ranges.json [verify 2026-10-29] |
| Azure | `*.azurewebsites.net`, `*.cloudapp.azure.com` | https://www.microsoft.com/en-us/download/details.aspx?id=56519 (weekly JSON) [verify 2026-10-29] |
| GCP | `*.googleusercontent.com`, `*.bc.googleusercontent.com` | https://www.gstatic.com/ipranges/cloud.json [verify 2026-10-29] |
| Cloudflare | NS `*.ns.cloudflare.com`; Universal SSL edge certs issued by Let's Encrypt, Google Trust Services or SSL.com | https://www.cloudflare.com/ips-v4/ and `/ips-v6/` [verify 2026-10-29] |
| Fastly | `*.fastly.net`, `Fastly` Server header | https://api.fastly.com/public-ip-list [verify 2026-10-29] |
| Akamai | `*.akamaiedge.net`, `*.edgesuite.net`, `*.akamaized.net` | published per customer; use ASN AS20940/AS16625 [verify 2026-10-29] |
| Vercel / Netlify | `*.vercel.app` / `*.netlify.app` | no vendor prefix list; Vercel documents dynamic egress IPs (static IPs only on Pro/Enterprise) — origin obscured [verify 2026-10-29] |

`1.1.1.1` / `1.0.0.1` are Cloudflare's public DNS resolvers, not their proxy-edge ranges. Real Cloudflare proxy CIDRs include `104.16.0.0/13`, `172.64.0.0/13`, `162.158.0.0/15`, `131.0.72.0/22` and others — always pull the live list from `https://www.cloudflare.com/ips-v4/` rather than hardcoding [verify 2026-10-29].

```bash
# Quick "is this IP on a known cloud?" check [verify 2026-10-29]
curl -s https://www.cloudflare.com/ips-v4/ | grep -E "^[0-9]+\." > /tmp/cf.txt
mapcidr -cidr /tmp/cf.txt -match-ip 1.2.3.4    # ProjectDiscovery mapcidr
```

---

## 6. Asset Reuse & Correlation

### Favicon Hash Matching
```bash
# Quick MD5 of raw bytes — useful for *exact byte match* across sites you control or scrape
curl -s https://example.com/favicon.ico | md5sum

# Shodan / FOFA index by mmh3(base64(bytes)) — see §5 for the Python recipe
shodan search "http.favicon.hash:$MMH3_HASH"
```

### Google Analytics / Tag Pivoting
1. Extract analytics ID(s) from target site (GA4 `G-`, legacy UA, GTM, AdSense `ca-pub-`). [verify 2026-10-29]
2. Search PublicWWW / NerdyData / URLScan:
   - `"G-XXXXXXXXXX"` (GA4 measurement ID)
   - `"UA-XXXXXX-X"` (legacy UA — historical pivot only; standard properties stopped collecting 2023-07-01, 360 on 2024-07-01) [verify 2026-10-29]
   - `"GTM-XXXXXXX"` (Tag Manager container — often shared across operator's properties)
3. Correlate domains using the same tracking / container ID.
4. Build ownership / operator map; cross-check against WHOIS / RDAP registrant pivots.

### Shared Resources
Look for:
- Same IP hosting multiple domains (virtual hosting; reverse-IP services)
- Shared nameservers (same DNS provider; especially same NS-set across unrelated brands)
- Same registrar + same creation timestamp / batch
- Shared CDN / proxy configurations (identical Server / Via / X-Cache headers)
- Common CSS/JS resource URLs (especially self-hosted JS libs at unique paths)
- Identical JARM / JA3S handshake fingerprints (see §4)
- Reused error pages, 404 templates, captcha keys (`recaptcha` site key)

---

## 7. Workflow Example

**Target:** `suspicious-site.com`

```bash
TARGET=suspicious-site.com
TS=$(date -u +%Y%m%dT%H%M%SZ)
mkdir -p ./out && cd ./out

# 1. Basic DNS
dig "$TARGET" A    +short | tee "${TS}_dig_A.txt"
dig "$TARGET" AAAA +short | tee "${TS}_dig_AAAA.txt"
dig "$TARGET" MX   +short | tee "${TS}_dig_MX.txt"
dig "$TARGET" NS   +short | tee "${TS}_dig_NS.txt"
dig "$TARGET" TXT  +short | tee "${TS}_dig_TXT.txt"
dig "$TARGET" CAA  +short | tee "${TS}_dig_CAA.txt"
dig "$TARGET" +dnssec     | tee "${TS}_dig_dnssec.txt"

# 2. WHOIS + RDAP (capture both — RDAP is structured; WHOIS is human-readable)
whois "$TARGET"                                      | tee "${TS}_whois.txt"
curl -s "https://rdap.org/domain/$TARGET" | jq .     | tee "${TS}_rdap.json"

# 3. Subdomains via cert transparency
curl -s "https://crt.sh/?q=%25.$TARGET&output=json" \
  | jq -r '.[].name_value' | sort -u | tee "${TS}_crtsh_subs.txt"

# 4. Subdomain enum (passive sources) → live host filter
subfinder -d "$TARGET" -silent -all \
  | dnsx -silent -a -resp | tee "${TS}_live_hosts.txt"

# 5. Technology fingerprint [verify 2026-10-29]
whatweb -a 3 "$TARGET" --log-json="${TS}_whatweb.json"

# 6. Tracking / analytics IDs
curl -s "https://$TARGET" | tee "${TS}_index.html" \
  | grep -oE "G-[A-Z0-9]{6,}|UA-[0-9]{4,10}-[0-9]{1,4}|GTM-[A-Z0-9]{6,8}|ca-pub-[0-9]{16}" \
  | sort -u | tee "${TS}_tracker_ids.txt"

# 7. Favicon hashes (both forms)
curl -s "https://$TARGET/favicon.ico" -o "${TS}_favicon.ico"
md5sum "${TS}_favicon.ico"
python3 -c "import mmh3,base64,sys;print(mmh3.hash(base64.encodebytes(open('${TS}_favicon.ico','rb').read())))"

# 8. Live cert / SAN harvest
echo | openssl s_client -connect "$TARGET:443" -servername "$TARGET" 2>/dev/null \
  | openssl x509 -noout -text > "${TS}_cert.txt"

# 9. Internet-wide views [verify 2026-10-29]
shodan search "hostname:$TARGET"
# Censys: run the equivalent CenQL query at https://platform.censys.io (legacy `censys search` CLI retired)

# 10. Passive DNS / history
# Query SecurityTrails / DomainTools / Defender TI / VT for historical A, NS, MX

# 11. Wayback content history [verify 2026-10-29]
curl -s "https://web.archive.org/cdx/search/cdx?url=$TARGET&output=json&limit=200" \
  | jq . | tee "${TS}_wayback.json"

# 12. Hash everything for chain of custody
sha256sum ${TS}_* > "${TS}_manifest.sha256"

# 13. Pivot on findings
# - Search G-/GTM/UA/ca-pub IDs on PublicWWW + URLScan
# - Search WHOIS/RDAP registrant email on DomainTools / WhoisXML reverse
# - Check IP neighbors via Shodan / Censys reverse-IP
# - Match favicon mmh3 across Shodan + FOFA
# - Cross-check certificate SANs against crt.sh
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

Passive DNS / WHOIS / CT-log lookups are generally lawful (queries against public services, no authorization needed). Active probing (port scans, subdomain brute-force against the target's authoritative resolver, pulling content from staging hosts) crosses into pentest territory and needs a written scope.

- **Authorization** — for pentest-adjacent active probing (zone transfers, brute-force resolution, scraping authenticated portals), confirm scope per [[sop-legal-ethics|Legal & Ethics]] before execution.
- **Operator OPSEC** — when probing actor infrastructure, route through a clean attribution chain (sock-puppet VPN/cloud egress, separate browser profile). See [[sop-opsec-plan|OPSEC Plan]].
- **Rate limits** — `crt.sh` 502s on bursty queries; Shodan / Censys / FOFA each enforce per-tier quotas; SecurityTrails 429s aggressively. Cache locally.
- **WHOIS harvesting at scale** — most registrar WHOIS servers throttle/blacklist on automated bulk queries. Use RDAP (cleaner JSON, generally higher per-IP quotas) and stagger requests.
- **Chain of custody** — log timestamp, resolver/source, full response, SHA-256 hash. See [[sop-collection-log|Collection Log]].
- **Reporting** — handoff conventions in [[sop-reporting-packaging-disclosure|Reporting & Disclosure]].

### Legal & Ethical Considerations

This SOP assumes investigation of public-internet metadata. For authorized engagement scoping, statute references, and notification obligations, see [[sop-legal-ethics|Legal & Ethics]] (canonical). Sensitive-target intake (CSAM, terrorism, threats-to-life) escalates per [[sop-sensitive-crime-intake-escalation|Sensitive-Crime Intake & Escalation]] — do not unilaterally pivot into adjacent infrastructure that could compromise an active law-enforcement matter.

---

## 10. Tools Reference

### DNS / RDAP / WHOIS
| Tool | Purpose | Install / Link |
|------|---------|----------------|
| `dig` | DNS queries (BIND tools) | built-in (`bind9-dnsutils` on Debian/Ubuntu) [verify 2026-10-29] |
| `delv` | DNSSEC-validating resolver lookup | ships with bind9 (`bind9-dnsutils`) [verify 2026-10-29] |
| `whois` | Legacy port-43 registration data | built-in |
| `rdap` (openrdap) | RDAP JSON client | `go install github.com/openrdap/rdap/cmd/rdap@latest` [verify 2026-10-29] |
| rdap.org | RDAP bootstrap router | https://rdap.org [verify 2026-10-29] |
| RIPEstat | ASN / announced-prefix lookup | https://stat.ripe.net [verify 2026-10-29] |

### Subdomain & host enumeration
| Tool | Purpose | Install / Link |
|------|---------|----------------|
| `subfinder` | Passive subdomain enum (ProjectDiscovery) | https://github.com/projectdiscovery/subfinder |
| `amass` | OWASP Flagship — passive + active recon | https://github.com/owasp-amass/amass [verify 2026-10-29] |
| `assetfinder` | Quick passive subdomain enum | https://github.com/tomnomnom/assetfinder |
| `dnsx` | Multi-purpose DNS probe / brute-force | https://github.com/projectdiscovery/dnsx |
| `puredns` | Wildcard-aware DNS brute-forcer | https://github.com/d3mondev/puredns |
| `gotator` | Permutation/anagram subdomain generator | https://github.com/Josue87/gotator |
| `dnsrecon` | Classic Python DNS recon | https://github.com/darkoperator/dnsrecon |

### Certificate transparency / TLS fingerprinting
| Tool | Purpose | Install / Link |
|------|---------|----------------|
| crt.sh | CT log aggregator (Sectigo) | https://crt.sh [verify 2026-10-29] |
| Censys Platform | CT / host search w/ rich filters (CenQL) | https://platform.censys.io [verify 2026-10-29] |
| Chrome CT log list | Browser-trusted CT log inventory (JSON) | https://www.gstatic.com/ct/log_list/v3/log_list.json [verify 2026-10-29] |
| `openssl s_client` | Live cert/SAN/chain extraction | built-in |
| JARM (Salesforce) | Server-side TLS handshake fingerprint | https://github.com/salesforce/jarm |
| JA4+ (FoxIO) | JA3 successor — client/server/HTTP/TCP variants | https://github.com/FoxIO-LLC/ja4 [verify 2026-10-29] |

### Web technology / tracker detection
| Tool | Purpose | Install / Link |
|------|---------|----------------|
| `whatweb` | Plugin-based web fingerprinting | `apt install whatweb` [verify 2026-10-29] |
| `webanalyze` | Go port of Wappalyzer fingerprints | https://github.com/rverton/webanalyze |
| `wappalyzergo` / `httpx -tech-detect` | ProjectDiscovery Wappalyzer-DB CLI | https://github.com/projectdiscovery/httpx |
| BuiltWith | Tech profiler + Relationships pivot (paid) | https://builtwith.com |
| PublicWWW | Source-code search engine | https://publicwww.com |
| NerdyData | Source-code search engine | https://nerdydata.com |
| URLScan.io | Web scan / DOM / search index | https://urlscan.io |

### Internet-wide / passive DNS
| Tool | Purpose | Install / Link |
|------|---------|----------------|
| Shodan | Internet-wide host search | https://shodan.io |
| Censys | Hosts + Certificates (Censys Platform) | https://platform.censys.io [verify 2026-10-29] |
| FOFA | Internet asset search | https://en.fofa.info |
| ZoomEye | Internet asset search (Knownsec) | https://www.zoomeye.ai (CN: https://www.zoomeye.org) [verify 2026-10-29] |
| Netlas.io | SaaS internet observatory | https://netlas.io |
| SecurityTrails | DNS / WHOIS history | https://securitytrails.com |
| DomainTools (incl. Farsight DNSDB) | Premium passive DNS / Iris | https://www.domaintools.com [verify 2026-10-29] |
| Microsoft Defender TI | Threat intelligence → Intel explorer in the Defender portal (RiskIQ PassiveTotal lineage) | https://security.microsoft.com [verify 2026-10-29] |
| VirusTotal | DNS resolutions, relations, intelligence | https://virustotal.com |
| Mnemonic PassiveDNS | Public passive DNS API (no key: TLP:WHITE, 1000 req/day) | https://passivedns.mnemonic.no [verify 2026-10-29] |
| Wayback CDX API | Historical content snapshots | https://archive.org/help/wayback_api.php [verify 2026-10-29] |

---

## 11. Common Pitfalls

- ❌ Forgetting to capture timestamps and resolver sources
- ❌ Not hashing saved evidence files
- ❌ Querying only current state (missing historical context)
- ❌ Ignoring privacy shields / GDPR redaction (check historical WHOIS / pre-2018 snapshots)
- ❌ Not correlating across multiple data points
- ❌ Assuming DNS/WHOIS/RDAP data is always accurate (can be spoofed/outdated)
- ❌ Treating WHOIS and RDAP as interchangeable — RDAP is structured JSON; WHOIS text is registrar-specific and must be parsed defensively
- ❌ Querying without `-servername` (SNI) → modern multi-tenant edges return a default cert that hides the real one
- ❌ Hardcoding cloud-provider CIDRs (Cloudflare/AWS/Azure ranges rotate; pull live JSON)
- ❌ Using MD5 of raw favicon bytes when querying Shodan/FOFA — they index `mmh3(base64(bytes))`
- ❌ Trusting `dig ANY` (RFC 8482; many resolvers refuse and return HINFO only — use per-type queries)
- ❌ Missing DNSSEC mismatches (expired RRSIG, lame DS) — useful operator-maturity signal
- ❌ Pivoting on a UA-XXXXX-X tracking ID without flagging it as historical (standard UA properties stopped collecting on 2023-07-01; 360 on 2024-07-01) [verify 2026-10-29]
- ❌ Burning through a SaaS tier (Shodan/Censys/SecurityTrails) on un-cached repeated queries

---

## 12. Related SOPs

- [[sop-collection-log|Collection Log & Chain of Custody]] — evidence hashing & preservation conventions
- [[sop-entity-dossier|Entity Dossier]] — structured target write-up template
- [[sop-opsec-plan|OPSEC Plan]] — attribution-chain hygiene when probing actor infrastructure
- [[sop-legal-ethics|Legal & Ethics]] — authorization, statute references, scope boundaries
- [[sop-reporting-packaging-disclosure|Reporting & Disclosure]] — handoff & disclosure conventions
- [[sop-sensitive-crime-intake-escalation|Sensitive-Crime Intake & Escalation]] — when not to pivot further
- [Vulnerability Research](../../Security/Pentesting/sop-vulnerability-research.md) — when WHOIS/CT pivots feed offensive recon
- [Web Application Security](../../Security/Pentesting/sop-web-application-security.md) — once you cross from passive metadata into authenticated probing

---

## 13. External / Reference Resources

**Standards & registries**
- ICANN RDAP program — https://www.icann.org/rdap
- RFC 9082 / 9083 (RDAP query format & JSON responses)
- RFC 8482 (refusing meta-queries — `dig ANY`)
- IANA root-zone database — https://www.iana.org/domains/root/db
- IANA RDAP bootstrap registry — https://data.iana.org/rdap/dns.json [verify 2026-10-29]
- Public Suffix List — https://publicsuffix.org/

**Browser-trusted CT logs**
- Apple CT log program — https://support.apple.com/en-us/103703 (policy: https://support.apple.com/en-us/103214) [verify 2026-10-29]
- Chrome CT log list (JSON) — https://www.gstatic.com/ct/log_list/v3/log_list.json; human view at https://certificate.transparency.dev/logs/ [verify 2026-10-29]

**Cloud / network reference**
- AWS IP ranges — https://ip-ranges.amazonaws.com/ip-ranges.json [verify 2026-10-29]
- Azure IP ranges — https://www.microsoft.com/en-us/download/details.aspx?id=56519 [verify 2026-10-29]
- GCP IP ranges — https://www.gstatic.com/ipranges/cloud.json [verify 2026-10-29]
- Cloudflare IPs — https://www.cloudflare.com/ips/ [verify 2026-10-29]

**Curated tool indexes**
- start.me OSINT (gl0bal01) — https://start.me/u/gl0bal01
- IntelTechniques tools — https://inteltechniques.com/tools/ [verify 2026-10-29]

---

**Version:** 1.1
**Last Updated:** 2026-10-29
**Review Frequency:** Quarterly (medium-rot — passive DNS providers, SaaS tier limits, and RDAP rollout state shift several times a year)
