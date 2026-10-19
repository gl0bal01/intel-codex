---
type: sop
title: LinkedIn SOP
description: "Professional LinkedIn OSINT: profile investigation, employment history tracking, connection mapping & corporate intelligence gathering techniques."
tags: [sop, platform, linkedin, professional, osint]
created: 2025-10-05
updated: 2026-10-18
---

# LinkedIn OSINT SOP

> **Authorized OSINT use only.** Investigation accounts must comply with LinkedIn's [User Agreement](https://www.linkedin.com/legal/user-agreement) §8.2 (no false or misrepresented identity; no software, scripts, robots, crawlers, browser plugins or add-ons to scrape or copy profiles and other data; no bots or unauthorized automated methods to access the Services, add or download contacts, or send messages) [verify 2026-10-18]. Review [[../Techniques/sop-legal-ethics|Legal & Ethics SOP]] and [[../Techniques/sop-opsec-plan|OPSEC Planning SOP]] before any engagement.

## Table of Contents

1. [Access & Client Options](#1-access--client-options)
2. [Search Operators & Boolean Logic](#2-search-operators--boolean-logic)
3. [Repeatable Workflow](#3-repeatable-workflow)
4. [Profile Intelligence](#4-profile-intelligence)
5. [Company Page Intelligence](#5-company-page-intelligence)
6. [Investigation Recipes](#6-investigation-recipes)
7. [Collection & Evidence Integrity](#7-collection--evidence-integrity)
8. [Advanced Techniques](#8-advanced-techniques)
9. [Pivoting & Cross-Platform Correlation](#9-pivoting--cross-platform-correlation)
10. [Tools & Resources](#10-tools--resources)
11. [Risks & Limitations](#11-risks--limitations)
12. [Quality Assurance & Verification](#12-quality-assurance--verification)
13. [Real-World Scenarios](#13-real-world-scenarios)
14. [Emergency Procedures](#14-emergency-procedures)
15. [Legal & Ethical Considerations](#15-legal--ethical-considerations)
16. [Related SOPs](#16-related-sops)
17. [External Resources](#17-external-resources)

## 1) Access & Client Options

- **Web**: https://www.linkedin.com/search/results/all/ (most comprehensive search)
- **Sales Navigator**: https://www.linkedin.com/sales (premium, advanced filtering) [verify 2026-10-18]
- **Recruiter Lite**: https://business.linkedin.com/hire/recruiter (premium) [verify 2026-10-18]
- **Mobile apps**: iOS/Android (limited functionality, messaging-focused)
- **API access**: LinkedIn API (heavily restricted, primarily for partners) [verify 2026-10-18]
- **Access consideration**: Logged-out vs persona profiles (balance access vs visibility)
- **View modes**: Public view (limited) vs logged-in (profile view tracking) [verify 2026-10-18]

## 2) Search Operators & Boolean Logic

### Basic Operators
- `"exact phrase"` - Exact match [verify 2026-10-18]
- `AND` - Both terms must appear [verify 2026-10-18]
- `OR` - Either term [verify 2026-10-18]
- `NOT` - Exclude term [verify 2026-10-18]
- Parentheses `()` - Group logic [verify 2026-10-18]
- `+` and `-` are not officially supported (they may appear to work); use `AND` / `NOT` instead [verify 2026-10-18]

### Advanced Filters
- **No field operators**: LinkedIn's Boolean search help documents only quotes, `AND`, `OR`, `NOT` and parentheses in the main search bar; `title:`, `company:`, `school:` and `location:` are not documented, so narrow by employer, school and place with **All filters** (**Current company**, **Past company**, **School**, **Locations**) [verify 2026-10-18]
- **Combining keywords and filters**:
  - `"CEO" OR "Founder" OR "President"` (keywords only)
  - **Current company** = Google + **Locations** = Seattle (filters only)
  - `VP NOT (assistant OR SVP)` + **School** = MIT

### Search Filter Categories
- **Connections**: 1st, 2nd, 3rd degree, or all members [verify 2026-10-18]
- **Locations**: City, metro area, country [verify 2026-10-18]
- **Current/Past Companies**: Filter by employment status [verify 2026-10-18]
- **Industries**: LinkedIn's predefined industry categories [verify 2026-10-18]
- **Profile Language**: Filter by language [verify 2026-10-18]
- **Schools**: Filter by school [verify 2026-10-18]
- **Service Categories**: For consultants, freelancers [verify 2026-10-18]

## 3) Repeatable Workflow

1. **Target identification**: Name variations, maiden names, nicknames, company affiliations
2. **Profile analysis**: Current role, career history, education, skills
3. **Network mapping**: Connections (1st/2nd/3rd degree), mutual connections
4. **Career timeline reconstruction**: Role progression, gaps, promotions, lateral moves
5. **Skills assessment**: Endorsements, recommendations, certifications, courses
6. **Content analysis**: Posts, articles, comments for personality/interests/expertise
7. **Contact harvesting**: Direct contact info, company email patterns
8. **Corporate intelligence**: Company page analysis, employee networks, org structure
9. **Cross-platform pivoting**: External links, Twitter/GitHub handles
10. **Documentation**: Export data, screenshots, hashing, chain of custody

## 4) Profile Intelligence

### Profile Analysis
- **Basic info**: Full name, headline, location, industry
- **Current role**: Title, company, duration, responsibilities (if listed)
- **Career history**: Previous roles, employment gaps, promotions
- **Education**: Degrees, institutions, graduation years, activities
- **Skills & endorsements**: Top skills, endorsement counts, endorsers
- **Recommendations**: Given/received, relationship context
- **Certifications**: Professional licenses, technical certs, completion dates
- **Volunteer work**: Non-profit involvement, causes supported
- **Publications**: Articles, papers, patents, media mentions
- **Languages**: Proficiency levels, native language indicators

### Behavioral Indicators
- **Profile activity**: Last update timestamp, posting frequency
- **Engagement style**: Likes, comments, shares (if visible)
- **Engagement extraction**: LinkedIn OSINT Comment Extractor bookmarklet https://github.com/gl0bal01/bookmarklets/tree/main/bookmarklet-linkedin-osint-extractor [verify 2026-10-18]
- **Content themes**: Topics posted about, industry focus
- **Network growth**: Connection velocity, network size
- **Job seeking**: "Open to work" badge, recent profile updates
- **Thought leadership**: Published articles, industry commentary

## 5) Company Page Intelligence

### Company Analysis
- **Employee directory**: Current employees by department, seniority, function
- **Alumni network**: Former employees and their current positions (competitive intel)
- **Hiring signals**: Open positions, growth areas, job posting frequency
- **Leadership team**: Executives, board members, recent appointments
- **Company updates**: News, funding, partnerships, product launches
- **Follower analysis**: Who follows the company, competitor employees
- **Affiliated pages**: Subsidiaries, brands, regional offices

### Organizational Mapping
- **Org structure**: Department sizes, leadership hierarchy (inferred from titles)
- **Employee tenure**: Average time at company, retention indicators
- **Hiring patterns**: Which companies they recruit from
- **Expansion signals**: New office locations, international growth
- **Competitive migration**: Employee movement to/from competitors

## 6) Investigation Recipes

### Executive Mapping
**Objective**: Identify C-suite and senior leadership

**Search** (keywords; All filters → **Current company** = Target Corp) [verify 2026-10-18]:
```
"CEO" OR "CFO" OR "CTO" OR "President" OR "VP" OR "SVP"
```

**Method**:
1. Search company name with executive titles
2. Export results to spreadsheet
3. Map reporting structures via titles
4. Identify tenure, previous companies
5. Check for external advisors, board members

### Competitive Intelligence
**Objective**: Find employees who moved between competitor companies

**Search** (keywords; All filters → **Current company** = Your Company, or **Past company** = Your Company for leavers) [verify 2026-10-18]:
```
"Competitor A" OR "Competitor B" OR "Competitor C"
```

**Method**:
1. Search for profiles listing both companies
2. Determine employment order (current vs past)
3. Analyze knowledge transfer risk (engineers, executives)
4. Check for non-compete violations (timing)
5. Identify recruitment patterns

### M&A Due Diligence
**Objective**: Map target company leadership and key personnel

**Search** (keywords; All filters → **Current company** = Acquisition Target) [verify 2026-10-18]:
```
"Founder" OR "C-level" OR "VP" OR "Director"
```

**Method**:
1. Identify all key personnel
2. Check for recent departures (red flag)
3. Verify credentials, experience
4. Map customer-facing employees
5. Assess technical talent depth

### Industry Expert Discovery
**Objective**: Find subject matter experts in specific domain

**Search** (keywords; All filters → **Locations** = Washington DC) [verify 2026-10-18]:
```
"Cybersecurity" AND ("Director" OR "VP" OR "CISO")
```

**Method**:
1. Search by expertise + seniority + location
2. Check certifications (CISSP, etc.)
3. Review published content, speaking engagements
4. Verify via external sources (conference speakers)
5. Assess credibility via recommendations

## 7) Collection & Evidence Integrity

### Capture Methods
- **Profile PDFs**: Use "Save to PDF" for official record [verify 2026-10-18]
- **Screenshots**: Full profile with URL, timestamp visible
- **HTML source**: Save page source for metadata
- **Connection data**: Export 1st-degree connections (if accessible) [verify 2026-10-18]
- **Company pages**: Full company page with employee count, updates
- **Posts/comments**: Individual content items with engagement metrics; LinkedIn OSINT Comment Extractor bookmarklet https://github.com/gl0bal01/bookmarklets/tree/main/bookmarklet-linkedin-osint-extractor [verify 2026-10-18]

### File Organization
```
/Evidence/{{case_id}}/LinkedIn/
├── YYYYMMDD-HHMM/
│   ├── profiles/
│   │   ├── firstname_lastname_profile.pdf
│   │   ├── firstname_lastname_profile.html
│   │   └── firstname_lastname_screenshot.png
│   ├── companies/
│   │   ├── company_name_page.pdf
│   │   └── company_name_employees.csv
│   ├── posts/
│   │   └── post_[ID]_screenshot.png
│   └── SHA256SUMS
```

### Hashing & Verification
- Calculate SHA-256 for all captured files
- Store hashes in `SHA256SUMS` file
- Document capture timestamp (UTC), profile URL, LinkedIn ID
- Reference in [[../Techniques/sop-collection-log|Collection Log]]
- Maintain chain of custody for legal proceedings

## 8) Advanced Techniques

### Sales Navigator Techniques (Premium)
- **Lead lists**: Save and track specific individuals
- **Advanced filters**: More granular search options
- **TeamLink**: Leverage team connections for warm intros [verify 2026-10-18]
- **Saved searches**: Weekly alerts on new matches (up to 50 lead and 50 account searches); separate **Alerts** give real-time signals such as job changes and new content [verify 2026-10-18]
- **InMail credits**: Direct messaging without connections [verify 2026-10-18]

### Network Analysis
- **Mutual connections**: Identify relationship paths
- **2nd-degree mapping**: Potential warm introductions
- **Company network clustering**: Employee interconnections
- **Educational networks**: Alumni associations, cohorts
- **Industry communities**: Professional groups, associations

### Temporal Intelligence
- **Profile snapshots**: Wayback Machine for historical profiles
- **Job change tracking**: Monitor for role updates
- **Company transitions**: Track employee departures/arrivals
- **Promotion patterns**: Career velocity indicators
- **Content timeline**: Track thought leadership evolution

## 9) Pivoting & Cross-Platform Correlation

### Profile Pivots
- **Email patterns** → Corporate email format (`firstname.lastname@company.com`)
- **Username consistency** → Same name on Twitter, GitHub, personal blogs
- **External links** → Personal websites, portfolios, social media profiles
- **Phone numbers** → Rarely listed, but check "Contact Info" section
- **Company websites** → Leadership pages, team bios, press releases

### Content Pivots
- **Published articles** → Reposted on Medium, personal blogs
- **Conference talks** → YouTube videos, presentation slides
- **Patents** → USPTO database, Google Patents
- **Academic papers** → Google Scholar, ResearchGate
- **Media mentions** → News articles, press releases, podcasts

### Network Pivots
- **Shared connections** → Mutual professional relationships
- **Recommendation networks** → Who endorses whom (trust indicators)
- **Company alumni** → Where former colleagues went
- **Educational networks** → Classmates, faculty connections
- **Board interlocks** → Directors serving on multiple boards

## 10) Tools & Resources

| Tool                                 | Purpose                                                                             | Platform        | Access                                                                                                |
| ------------------------------------ | ----------------------------------------------------------------------------------- | --------------- | ----------------------------------------------------------------------------------------------------- |
| **LinkedIn Search**                  | Native search interface                                                             | Web             | https://www.linkedin.com/search                                                                       |
| **Sales Navigator**                  | Advanced search and tracking                                                        | Web (Premium)   | https://www.linkedin.com/sales [verify 2026-10-18]                                                    |
| **Recruiter Lite**                   | Talent search and outreach                                                          | Web (Premium)   | https://business.linkedin.com/hire/recruiter [verify 2026-10-18]                                      |
| **Nuclei**                           | Username enumeration                                                                | CLI             | `nuclei -tags osint -esc -var user=username` [verify 2026-10-18]                                           |
| **Social-Analyzer**                  | Cross-platform username search                                                      | CLI             | `pip install social-analyzer` (last PyPI release 0.45, May 2022) [verify 2026-10-18]                  |
| **PhantomBuster**                    | LinkedIn automation (use carefully)                                                 | Web             | https://phantombuster.com                                                                             |
| **Wayback Machine**                  | Historical profile snapshots                                                        | Web             | https://web.archive.org                                                                               |
| **Hunter.io**                        | Email finder and verification                                                       | Web             | https://hunter.io [verify 2026-10-18]                                                                 |
| **RocketReach**                      | Contact information database                                                        | Web             | https://rocketreach.co [verify 2026-10-18]                                                            |
| LinkedIn OSINT Comment Extractor | Extract comment data, user profiles, and engagement metrics from LinkedIn posts | Bookmarklet | https://github.com/gl0bal01/bookmarklets/tree/main/bookmarklet-linkedin-osint-extractor [verify 2026-10-18] |

### Email Pattern Tools
```bash
# Common corporate email patterns
firstname.lastname@company.com
firstnamelastname@company.com
flastname@company.com
firstname@company.com
f.lastname@company.com

# Verify using Hunter.io or similar [verify 2026-10-18]
curl "https://api.hunter.io/v2/email-finder?domain=company.com&first_name=John&last_name=Doe&api_key=YOUR_KEY"
```

## 11) Risks & Limitations

- **Premium requirements**: Advanced features require Sales Navigator Core (US$119.99/mo, or US$1,079.88/yr billed annually; excl. tax, subject to change) [verify 2026-10-18]
- **Profile view tracking**: Targets see who viewed their profile (unless private mode) [verify 2026-10-18]
- **Rate limiting**: Free accounts have search result caps [verify 2026-10-18]
- **Geographic restrictions**: Content varies by region, EU has stricter privacy
- **Profile completeness**: Not all users maintain detailed profiles
- **Privacy settings**: Some info hidden from non-connections
- **Data accuracy**: Self-reported data may be outdated or false
- **Automated scraping bans**: Platform actively blocks scrapers
- **Connection limits**: Weekly connection-request cap (number not documented by LinkedIn)

## 12) Quality Assurance & Verification

### Profile Verification
- **Cross-reference employment**: Check company websites, press releases
- **Timeline consistency**: Role dates should align with company announcements
- **Education verification**: Confirm degrees via university records (if accessible)
- **Certification validation**: Verify professional licenses with issuing bodies
- **Recommendation authenticity**: Check if recommenders are real, current connections

### Evidence Validation
- **Multiple data points**: Don't rely solely on LinkedIn (use company sites, news)
- **Temporal consistency**: Check if career timeline makes logical sense
- **Skill claims**: Technical certifications should match claimed expertise
- **Company verification**: Confirm company legitimacy (not shell companies)
- **Network plausibility**: Connection count and quality should match seniority

## 13) Real-World Scenarios

### Scenario 1: M&A Due Diligence
**Situation**: Private equity firm acquiring SaaS company, needs leadership assessment.

**Approach**:
1. Map all C-suite and VP-level personnel via company page
2. Check tenure (recent executive departures = red flag)
3. Verify credentials, previous company success/failures
4. Identify key technical talent (engineering VPs, CTOs)
5. Check for non-compete issues (recently hired from competitors)
6. Assess sales team strength (customer relationships)
7. Document findings in dossiers per [[../Techniques/sop-entity-dossier|Entity Dossier SOP]]

**Outcome**: Identified 3 VPs hired within 6 months (poaching from competitor); CTO had failed startup in same vertical (concern); 60% of engineering team had <1 year tenure (retention risk); provided detailed leadership assessment influencing $15M valuation adjustment.

### Scenario 2: Competitor Intelligence
**Situation**: Tech company wants to understand competitor's AI strategy and hiring.

**Approach**:
1. Search AI-related titles with All filters → **Current company** = Competitor: `"AI" OR "Machine Learning" OR "Data Scientist"` [verify 2026-10-18]
2. Track employee growth in AI org over 12 months (10 → 45 = aggressive hiring)
3. Identify where they're recruiting from (universities, specific companies)
4. Check job postings for technology stack indicators (PyTorch, TensorFlow)
5. Review published content from AI team members (research papers, blog posts)
6. Map org structure: VP AI → Engineering Managers → team sizes

**Outcome**: Discovered competitor building 50-person AI team; recruiting PhDs from Stanford/MIT; job posts revealed focus on computer vision (not NLP); adjusted own company's product roadmap and talent acquisition strategy based on intelligence.

### Scenario 3: Pre-Employment Background Investigation
**Situation**: Candidate for CFO position, verify credentials and identify any concerns.

**Approach**:
1. Verify employment history matches resume (dates, titles, companies)
2. Check education credentials (MBA from claimed university)
3. Review recommendations (are they from claimed colleagues?)
4. Search for any concerning posts/comments (judgment issues)
5. Check for connections at competitor companies (potential conflicts)
6. Verify professional certifications (CPA license number)
7. Cross-reference with SEC filings if was executive at public company

**Outcome**: Found 6-month employment gap not on resume; title inflation (was "Senior Accountant" not "Controller"); MBA from unaccredited online university; 2 DUI-related posts from 5 years ago; flagged concerns to hiring manager; candidate ultimately withdrew from process.

## 14) Emergency Procedures

### Immediate Archival Triggers
- Candidate withdrawing from process (capture before profile updates)
- Target showing signs of profile deletion (changing to minimal info)
- Ongoing litigation requires evidence preservation
- M&A deal closing soon (capture pre-acquisition state)
- Employee under investigation for misconduct

### Rapid Response Protocol
1. **Full profile PDF**: Save official version immediately [verify 2026-10-18]
2. **Screenshots**: Capture with URL and timestamp visible
3. **Connection export**: Save 1st-degree connections if accessible [verify 2026-10-18]
4. **Content archive**: All posts, articles, comments
5. **Company page**: Full company info and employee list
6. **Hash calculation**: SHA-256 for integrity
7. **Documentation**: Log all actions with timestamps
8. **External archive**: Submit to Wayback Machine

### Escalation Triggers (see [[../Techniques/sop-sensitive-crime-intake-escalation|Sensitive Crime Escalation SOP]])
- **Security clearance**: Classified positions require special handling
- **Legal concerns**: Employment disputes, discrimination, harassment
- **Threat assessment**: Concerning posts indicating violence, extremism
- **Corporate espionage**: Evidence of trade secret theft
- **Fraud indicators**: False credentials, fake employment history

### Legal Process & Preservation
- **Guidelines**: LinkedIn Law Enforcement Data Request Guidelines https://www.linkedin.com/help/linkedin/answer/a1340284; serve requests via https://app.kodex.us/linkedin/signin [verify 2026-10-18]
- **Legal standard**: Outside emergencies, formal U.S. legal process (subpoena, court order, search warrant); messages, invitations and connections need a search warrant; requests from outside the U.S. and EU generally go through an MLAT or letter rogatory [verify 2026-10-18]
- **Request contents**: Agent badge/ID number and contact information, and the member account by full name plus associated email, or by public profile URL [verify 2026-10-18]
- **Emergency**: Only for imminent serious bodily harm or death, on LinkedIn's Emergency Disclosure Request Form signed under penalty of perjury by a law enforcement agent [verify 2026-10-18]
- **Preservation**: The guidelines do not state a preservation period; confirm retention with LinkedIn when serving process and capture public data yourself (Rapid Response above) [verify 2026-10-18]
- Review [[../Techniques/sop-legal-ethics|Legal & Ethics]] before any request or referral

## 15) Legal & Ethical Considerations

> LinkedIn OSINT sits at the intersection of platform ToS, employment and personal-data law, and (at times) sensitive-crime evidence. The canonical source for legal posture is [[../Techniques/sop-legal-ethics|Legal & Ethics SOP]] — never re-derive it here.

- **Platform ToS**: LinkedIn's [User Agreement](https://www.linkedin.com/legal/user-agreement) §8.2 (effective 2025-11-03) bars creating a false identity or misrepresenting your identity; developing, supporting or using software, devices, scripts, robots or other means (such as crawlers, browser plugins and add-ons) to scrape or copy the Services, including profiles; and using bots or other unauthorized automated methods to access the Services, add or download contacts, or send or redirect messages [verify 2026-10-18]. Persona profiles, PhantomBuster and the comment-extractor bookmarklet (§10) sit against these clauses. Investigation accounts that violate ToS risk ban and evidence inadmissibility.
- **Legal process**: disclosure and emergency requests go through LinkedIn's law-enforcement guidelines and portal; see [Legal Process & Preservation](#legal-process--preservation) in §14.
- **Sensitive-crime routing**: CSAM, threat-to-life, trafficking, terrorism content found during OSINT triggers immediate hard-stop and routing per [[../Techniques/sop-sensitive-crime-intake-escalation|Sensitive Crime Escalation SOP]]. Do not download or further analyze CSAM; preserve URL + timestamp only and report to NCMEC (US) / IWF (UK) / national equivalent.
- **OPSEC**: persona accounts, phone numbers, payment methods and devices must be isolated from the analyst's personal identity per [[../Techniques/sop-opsec-plan|OPSEC Planning SOP]]. Set the persona's profile viewing mode to private before viewing targets; viewed members then see only "LinkedIn Member" [verify 2026-10-18].

## 16) Related SOPs

- [[../Techniques/sop-legal-ethics|Legal & Ethics SOP]] - Review before every investigation
- [[../Techniques/sop-opsec-plan|OPSEC Planning]] - Private browsing mode, VPN usage
- [[../Techniques/sop-collection-log|Collection Log]] - Evidence tracking and chain of custody
- [[../Techniques/sop-web-dns-whois-osint|Web/DNS/WHOIS OSINT]] - Investigate company websites
- [[../Techniques/sop-financial-aml-osint|Financial & AML OSINT]] - Executive compensation, insider trading
- [[../Techniques/sop-entity-dossier|Entity Dossier Building]] - Professional profile documentation
- [[../Techniques/sop-reporting-packaging-disclosure|Reporting & Disclosure]] - Final report preparation

## 17) External Resources

**Official Documentation:**
- LinkedIn Help Center: https://www.linkedin.com/help/linkedin [verify 2026-10-18]
- Sales Navigator Guide: https://business.linkedin.com/sell/resources [verify 2026-10-18]
- LinkedIn Developer Platform: https://developer.linkedin.com (limited access) [verify 2026-10-18]
- LinkedIn Law Enforcement Data Request Guidelines: https://www.linkedin.com/help/linkedin/answer/a1340284 [verify 2026-10-18]
- LinkedIn law-enforcement request portal: https://app.kodex.us/linkedin/signin [verify 2026-10-18]

**Third-Party Tools:**
- Nuclei Templates: https://github.com/projectdiscovery/nuclei-templates
- Social-Analyzer: https://github.com/qeeqbox/social-analyzer
- PhantomBuster: https://phantombuster.com [verify 2026-10-18]
- Hunter.io API: https://hunter.io/api [verify 2026-10-18]
- LinkedIn OSINT Comment Extractor: https://github.com/gl0bal01/bookmarklets/tree/main/bookmarklet-linkedin-osint-extractor [verify 2026-10-18]

**Training & Guides:**
- Bellingcat guides (general OSINT): https://www.bellingcat.com/resources/how-tos/ [verify 2026-10-18]
- OSINT Framework LinkedIn: https://osintframework.com/
- Sales Navigator Help: https://www.linkedin.com/help/sales-navigator [verify 2026-10-18]

---

**Last Updated:** 2026-10-18
**Version:** 2.0 (Expanded & Standardized)
**Review Frequency:** Yearly
