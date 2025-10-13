# Evidence Collection Log

**Case ID:** YYYY-NNN
**Investigator:** [Your Name]
**Last Updated:** YYYY-MM-DD

---

## Purpose

This log tracks ALL evidence collected during the investigation. Every piece of evidence MUST be logged here immediately after collection.

**See [Collection Log SOP](../../Investigations/Techniques/sop-collection-log.md) for detailed procedures.**

---

## Evidence Tracking

### Evidence Entry Template

For each piece of evidence, document:
- **Evidence ID** (E001, E002, E003...)
- **Date/Time Collected** (YYYY-MM-DD HH:MM UTC)
- **Source** (Platform/website/tool)
- **Source URL** (if applicable)
- **File Name** (exact filename in 03-Evidence/)
- **File Type** (PNG, PDF, TXT, JSON, etc.)
- **SHA-256 Hash** (for integrity verification)
- **Description** (what this evidence shows)
- **Related Subject** (which entity this pertains to)
- **Collected By** (your name)
- **Storage Location** (path in 03-Evidence/)

---

## Evidence Log

### E001

**Date/Time:** YYYY-MM-DD HH:MM UTC
**Source:** [Platform/Website]
**Source URL:** `https://example.com/...`
**File Name:** `twitter-profile-username-20250113.png`
**File Type:** PNG (Screenshot)
**SHA-256:** `[hash value]`
**Description:** [What does this evidence show? e.g., "Screenshot of @username Twitter profile showing bio and follower count"]
**Related Subject:** [Subject 1 - @username]
**Collected By:** [Your Name]
**Storage Location:** `03-Evidence/screenshots/twitter/`

---

### E002

**Date/Time:** YYYY-MM-DD HH:MM UTC
**Source:** [Platform/Website]
**Source URL:** `https://example.com/...`
**File Name:** `instagram-post-username-20250113.png`
**File Type:** PNG (Screenshot)
**SHA-256:** `[hash value]`
**Description:** [What does this show?]
**Related Subject:** [Subject 1 - @username]
**Collected By:** [Your Name]
**Storage Location:** `03-Evidence/screenshots/instagram/`

---

### E003

**Date/Time:** YYYY-MM-DD HH:MM UTC
**Source:** WHOIS Lookup
**Source URL:** `https://whois.domaintools.com/example.com`
**File Name:** `whois-example-com-20250113.txt`
**File Type:** TXT (Raw WHOIS output)
**SHA-256:** `[hash value]`
**Description:** [WHOIS registration data for example.com showing registrant email and creation date]
**Related Subject:** [Subject 2 - example.com]
**Collected By:** [Your Name]
**Storage Location:** `03-Evidence/domains/`

---

### E004

[Continue numbering sequentially for each piece of evidence]

---

### E005

---

### E006

---

### E007

---

### E008

---

### E009

---

### E010

---

## Evidence Summary

**Total Evidence Items:** [Count]
**Date Range:** [Earliest] to [Latest]

### Evidence by Type

| Type | Count |
|------|-------|
| Screenshots | [#] |
| Documents (PDF/TXT) | [#] |
| Images | [#] |
| Videos | [#] |
| JSON/Data Files | [#] |
| Archives (HTML/WARC) | [#] |
| Other | [#] |

### Evidence by Subject

| Subject | Evidence Count | Evidence IDs |
|---------|----------------|--------------|
| [Subject 1] | [#] | E001, E002, E005, E007... |
| [Subject 2] | [#] | E003, E004, E006... |
| [Subject 3] | [#] | E010, E011... |

### Evidence by Platform

| Platform | Count | Evidence IDs |
|----------|-------|--------------|
| Twitter/X | [#] | E001, E002... |
| Instagram | [#] | E005, E006... |
| WHOIS/DNS | [#] | E003, E008... |
| LinkedIn | [#] | E010... |
| Other | [#] | E012... |

---

## Collection Methods

**Tools Used for Collection:**
- [Tool 1] - [Purpose, e.g., "Flameshot for screenshots"]
- [Tool 2] - [Purpose, e.g., "curl for downloading WHOIS data"]
- [Tool 3] - [Purpose, e.g., "yt-dlp for downloading videos"]

**Hashing Method:**
- Command: `sha256sum filename.ext`
- Platform: [Windows / Linux / macOS]
- Tool: [sha256sum / CertUtil / shasum]

---

## Chain of Custody

**Evidence Custodian:** [Your Name]
**Evidence Location:** [Physical location, e.g., "Encrypted USB drive, investigator's office"]
**Access Control:** [Who can access, e.g., "Investigator only"]

### Evidence Transfers

[Document any time evidence changes hands]

| Date | From | To | Evidence IDs | Reason | Method |
|------|------|----|--------------| -------|--------|
| YYYY-MM-DD | [Name] | [Name] | E001-E050 | [e.g., "Case handoff"] | [e.g., "Encrypted USB"] |

---

## Evidence Integrity Verification

### Initial Hashing

**Date Performed:** YYYY-MM-DD
**Method:** SHA-256
**Total Files Hashed:** [Count]
**Hash File Location:** `05-Admin/evidence-hashes.txt`

### Verification Checks

| Date | Files Checked | Mismatches | Notes |
|------|---------------|------------|-------|
| YYYY-MM-DD | [Count] | 0 | Initial collection |
| YYYY-MM-DD | [Count] | 0 | Weekly verification |
| YYYY-MM-DD | [Count] | 0 | Pre-report verification |

**If mismatches found:** [Document here what happened and corrective action taken]

---

## Evidence Notes

### Collection Issues

**Date:** YYYY-MM-DD
**Issue:** [Describe any problems during collection]
**Resolution:** [How was it resolved?]
**Impact:** [Did this affect evidence integrity?]

---

### Platform-Specific Notes

**Twitter/X:**
- [Note any platform changes, API issues, rate limits, etc.]

**Instagram:**
- [Note any collection challenges]

**Other Platforms:**
- [Document relevant issues]

---

## Missing / Unobtainable Evidence

**Evidence We Tried to Collect But Couldn't:**

| Desired Evidence | Why Unavailable | Attempted Method | Impact on Investigation |
|------------------|-----------------|------------------|-------------------------|
| [e.g., "Facebook profile"] | [e.g., "Account deleted"] | [e.g., "Manual search, Wayback Machine"] | [e.g., "Minor - other profiles available"] |
| [e.g., "Domain WHOIS"] | [e.g., "Privacy protected"] | [e.g., "whois.com, DomainTools"] | [e.g., "Moderate - can't identify registrant"] |

---

## Evidence Retention

**Retention Policy:** [How long will evidence be kept?]
- Example: "Retain for 3 years after case closure per organizational policy"

**Destruction Date:** [YYYY-MM-DD if applicable]
**Destruction Method:** [Secure deletion / physical destruction]

---

## Quality Assurance

### Evidence Review Checklist

- [ ] All evidence files are logged
- [ ] All log entries have SHA-256 hashes
- [ ] All files in 03-Evidence/ directory match log entries
- [ ] No orphaned files (files without log entries)
- [ ] No missing files (log entries without files)
- [ ] Hashes verified and match
- [ ] Chain of custody documented
- [ ] Source URLs recorded for all online evidence

---

## Related Documentation

- **Case Overview:** [00-Case-Overview.md](00-Case-Overview.md)
- **Subject Profiles:** [01-Subject-Profiles.md](01-Subject-Profiles.md)
- **Evidence Directory:** [03-Evidence/](03-Evidence/)
- **Evidence Hashes File:** [05-Admin/evidence-hashes.txt](05-Admin/evidence-hashes.txt)

---

**Last Updated:** YYYY-MM-DD
**Total Evidence Items:** [Count]
**Custodian:** [Your Name]
