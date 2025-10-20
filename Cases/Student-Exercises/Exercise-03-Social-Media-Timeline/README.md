# Exercise 03: Social Media Timeline Reconstruction

**Difficulty:** 📙 Intermediate
**Estimated Time:** 5-8 hours
**Prerequisites:** Exercises 01 & 02 completed, Platform SOPs reviewed

---

## 🎯 Learning Objectives

By completing this exercise, you will learn to:
1. **Collect evidence** from multiple social media platforms systematically
2. **Reconstruct timelines** from fragmented digital evidence
3. **Cross-reference** information across platforms to verify facts
4. **Identify patterns** in posting behavior and content themes
5. **Assess credibility** of social media information
6. **Present findings** in clear, chronological format

---

## 📋 Scenario

**Case ID:** EXERCISE-2025-003
**Subject:** "Alex Morgan" (fictional persona for training)
**Platforms:** Twitter, LinkedIn, GitHub (simulated data)
**Authorization:** Educational exercise (fictional scenario)

**Background:**
You've been asked to reconstruct a timeline of professional activities for "Alex Morgan," a fictional tech professional, based on their public social media presence. Your goal is to understand their career progression, technical skills development, and professional network through their digital footprint.

**Important:** This exercise uses **SIMULATED DATA** provided below. You will practice timeline reconstruction using fictional posts and activities.

---

## 📝 Your Assignment

### Part 1: Data Collection (2-3 hours)

**Task:** Collect and organize social media posts across multiple platforms.

**Platforms to Document:**
- Twitter: @alexmorgan_tech (simulated)
- LinkedIn: Alex Morgan (simulated)
- GitHub: alexmorgan-dev (simulated)

**For Each Platform, Collect:**
- [ ] Profile information (bio, location, links)
- [ ] Account creation date
- [ ] Key posts/activities (at least 10 per platform)
- [ ] Engagement metrics (likes, shares, comments)
- [ ] Media attachments (screenshots of key images)
- [ ] Hashtags and topics
- [ ] Mentioned/tagged accounts
- [ ] Geographic indicators

**Documentation Requirements:**
- Screenshot each post/activity
- Record post date/time with timezone
- Save to `Evidence/screenshots/[platform]/`
- Log each item in collection log with hash

---

### Part 2: Timeline Reconstruction (2-3 hours)

**Task:** Create a comprehensive chronological timeline from collected data.

**Timeline Format:**

| Date | Time | Platform | Event Type | Content Summary | Source | Significance |
|------|------|----------|------------|-----------------|--------|--------------|
| YYYY-MM-DD | HH:MM TZ | Twitter | Post | [Summary] | [URL] | [Why it matters] |

**Event Categories to Track:**
- **Career Events:** Job changes, promotions, new projects
- **Skills Development:** Learning new technologies, certifications
- **Professional Network:** Conferences attended, collaborations
- **Content Creation:** Blog posts, tutorials, open source contributions
- **Personal Milestones:** (if relevant to professional context)

**Analysis Questions:**
1. What is the subject's career trajectory?
2. What technical skills have they developed over time?
3. Are there any gaps in activity? (Significant breaks?)
4. Do posts across platforms align or contradict?
5. What professional relationships are evident?

---

### Part 3: Cross-Platform Correlation (1-2 hours)

**Task:** Identify connections and verify information across platforms.

**Correlation Checks:**
- [ ] Do employment dates match across LinkedIn and Twitter?
- [ ] Do GitHub projects align with claimed skills on LinkedIn?
- [ ] Do conference mentions on Twitter match LinkedIn updates?
- [ ] Do profile pictures match across platforms? (OSINT verification)
- [ ] Do location tags align across platforms?
- [ ] Do contact details (website, email) match?

**Create Correlation Matrix:**

| Claim | LinkedIn | Twitter | GitHub | Verified? |
|-------|----------|---------|--------|-----------|
| Works at TechCorp | ✓ (profile) | ✓ (bio) | ✓ (repos) | Yes |
| Knows Python | ✓ (skills) | ✓ (tweets) | ✓ (code) | Yes |
| Attended DefCon 2024 | ✗ | ✓ (tweet) | ✗ | Partial |

**Confidence Assessment:**
- **High:** Verified across 3+ sources
- **Medium:** Verified across 2 sources
- **Low:** Single source, unverified

---

### Part 4: Pattern Analysis (1 hour)

**Task:** Identify behavioral patterns and anomalies.

**Patterns to Analyze:**

**Posting Behavior:**
- Peak activity times (hourly breakdown)
- Day-of-week patterns
- Frequency changes over time
- Platform preferences (which platform for what content?)

**Content Themes:**
- Primary topics/interests (quantify: X% cybersecurity, Y% programming, etc.)
- Sentiment (positive, negative, neutral)
- Interaction style (questions, statements, shares?)
- Evolution of interests over time

**Network Patterns:**
- Who does the subject interact with most?
- Any notable connections to organizations/companies?
- Follower growth patterns
- Engagement rate trends

**Anomalies to Flag:**
- Sudden topic shifts
- Account inactivity periods
- Location inconsistencies
- Suspicious behavior (mass follows, bot-like posting)

---

## 📊 Simulated Data for Exercise

**Use this fictional data to practice timeline reconstruction:**

### Twitter: @alexmorgan_tech

**Profile:**
- Bio: "Cybersecurity researcher | Python enthusiast | Coffee addict ☕ | Views my own"
- Location: "San Francisco, CA"
- Joined: January 2022
- Followers: 1,247
- Following: 892

**Sample Posts:**

1. **2022-01-15, 09:30 PST**
   - "Excited to join @TechCorpSecurity as a Junior Security Analyst! Ready to learn and grow 🚀"
   - [120 likes, 15 retweets]

2. **2022-03-22, 14:45 PST**
   - "Just passed my Security+ certification! Hard work pays off. #cybersecurity #infosec"
   - [89 likes, 8 retweets]

3. **2022-06-10, 11:20 PST**
   - "Working on a Python script to automate log analysis. Any recommendations for libraries? #Python #SIEM"
   - [45 likes, 12 replies]

4. **2022-08-05, 16:00 PST**
   - "At BlackHat USA 2022! First time attending. So much to learn. 🎉 #BlackHat #infosec"
   - [Geotagged: Las Vegas, NV]
   - [Photo: Conference badge]

5. **2023-01-20, 10:15 PST**
   - "1 year at @TechCorpSecurity! Grateful for the learning opportunities. Onwards and upwards!"
   - [156 likes, 23 retweets]

6. **2023-05-12, 13:40 PST**
   - "Released my first open source tool: LogHunter - automated SIEM log parser. Check it out! github.com/alexmorgan-dev/loghunter"
   - [234 likes, 67 retweets]

7. **2023-08-18, 09:00 PST**
   - "Excited to announce I'm now a Senior Security Analyst at @TechCorpSecurity! 🎊 #promotion #cybersecurity"
   - [189 likes, 31 retweets]

8. **2023-11-03, 15:30 PST**
   - "Speaking at BSides SF next week about automated threat hunting. First conference talk! Nervous but excited!"
   - [98 likes, 15 retweets]

9. **2024-02-14, 11:45 PST**
   - "LogHunter just hit 500 stars on GitHub! Thank you to everyone using and contributing 🙏"
   - [201 likes, 45 retweets]

10. **2024-09-30, 14:20 PST**
    - "Heading to @DefCon this weekend. DM if you want to meet up! #DefCon32 #networking"
    - [76 likes, 9 retweets]

---

### LinkedIn: Alex Morgan

**Profile:**
- Headline: "Senior Security Analyst at TechCorp Security | Cybersecurity Researcher"
- Location: "San Francisco Bay Area"
- 500+ connections

**Experience:**

**TechCorp Security**
- **Senior Security Analyst** (August 2023 - Present)
  - "Leading threat hunting initiatives and security automation projects"
  - "Developed LogHunter, an open-source SIEM log parser used by 20+ organizations"

- **Junior Security Analyst** (January 2022 - August 2023)
  - "Monitored security events using SIEM platforms"
  - "Investigated security incidents and created response playbooks"
  - "Automated log analysis workflows using Python"

**Certifications:**
- CompTIA Security+ (March 2022)
- Certified Ethical Hacker (CEH) (November 2023)

**Sample Posts:**

1. **2022-01-10**
   - "Thrilled to start my career in cybersecurity at TechCorp Security! Looking forward to protecting digital assets and learning from incredible mentors."
   - [87 reactions, 12 comments]

2. **2023-05-15**
   - "Proud to announce the release of LogHunter, an open-source tool for automated log analysis. Check it out on my GitHub!"
   - [Link to GitHub]
   - [145 reactions, 28 comments]

3. **2023-08-15**
   - "Excited to step into my new role as Senior Security Analyst at TechCorp Security. Grateful for the mentorship and growth opportunities!"
   - [203 reactions, 45 comments]

---

### GitHub: alexmorgan-dev

**Profile:**
- Bio: "Security researcher | Python developer | Building tools for defenders"
- Location: "San Francisco, CA"
- Member since: December 2021

**Repositories:**

1. **loghunter** (Created: May 2023)
   - Description: "Automated SIEM log parser and threat detector"
   - Language: Python
   - Stars: 523
   - Forks: 87
   - Last commit: October 2024 (active)
   - Key commits:
     - 2023-05-10: Initial release
     - 2023-07-22: Added ML-based anomaly detection
     - 2024-02-12: Version 2.0 with GUI interface

2. **security-scripts** (Created: March 2022)
   - Description: "Collection of Python scripts for security tasks"
   - Language: Python
   - Stars: 45
   - Forks: 12
   - Last commit: September 2024

3. **ctf-writeups** (Created: June 2022)
   - Description: "My solutions to various CTF challenges"
   - Language: Markdown
   - Stars: 23
   - Last commit: August 2024

**Contribution Activity:**
- Most active: May-August 2023 (LogHunter development)
- Average: 15-20 commits per month
- Peak days: Weekends and evenings

---

## ✅ Your Deliverables

### 1. Master Timeline (`00-Master-Timeline.md`)

Create a comprehensive timeline including:
- All 30+ events from the simulated data
- Chronological order (oldest to newest)
- Source citations for each event
- Significance assessment for each entry

### 2. Cross-Platform Analysis (`01-Cross-Platform-Analysis.md`)

Include:
- Correlation matrix (which claims are verified?)
- Consistency assessment across platforms
- Identified discrepancies (if any)
- Confidence ratings for key facts

### 3. Pattern Analysis Report (`02-Pattern-Analysis.md`)

Include:
- Posting behavior analysis (times, frequency)
- Content theme breakdown (quantified percentages)
- Network analysis (key connections, interactions)
- Career progression summary
- Technical skill development timeline

### 4. Executive Summary (`03-Executive-Summary.md`)

One-page summary including:
- Subject overview
- Key findings (top 5)
- Career trajectory assessment
- Confidence level (overall)
- Recommendations for further investigation (if this were real)

### 5. Collection Log (`04-Collection-Log.md`)

Complete evidence log with:
- All 30+ simulated posts logged
- SHA-256 hashes (you'll screenshot the simulated data)
- Collection timestamps
- Source URLs (fictional)

### 6. Visual Timeline (Optional - Bonus)

Create a visual representation:
- Use timeline tool (TimelineJS, Tiki-Toki, or simple diagram)
- Show career progression graphically
- Highlight key milestones

---

## ✅ Completion Criteria

Your exercise is complete when:
- [ ] All 30+ events from simulated data documented
- [ ] Master timeline created in chronological order
- [ ] Cross-platform correlation matrix completed
- [ ] Pattern analysis report written
- [ ] Executive summary (1 page) completed
- [ ] Collection log includes all evidence with hashes
- [ ] At least 15 screenshots created (of simulated data)
- [ ] All confidence assessments included

---

## 🎓 Self-Assessment Questions

1. **What was the most challenging aspect of timeline reconstruction?**
2. **Did you find any inconsistencies across platforms? How did you resolve them?**
3. **What patterns did you identify in the subject's professional development?**
4. **How confident are you in your timeline's accuracy? (Low/Medium/High)**
5. **If this were a real investigation, what additional data would you seek?**
6. **How would cross-platform correlation help in a fraud investigation?**

---

## 📤 Submission Instructions

**Folder Structure:**
```
Exercise-03-Social-Media-Timeline/
├── 00-Master-Timeline.md
├── 01-Cross-Platform-Analysis.md
├── 02-Pattern-Analysis.md
├── 03-Executive-Summary.md
├── 04-Collection-Log.md
├── 05-Visual-Timeline.pdf (optional)
└── Evidence/
    └── screenshots/
        ├── twitter/
        ├── linkedin/
        └── github/
```

Submit as: `Exercise-03-[YourName]-[Date].zip`

---

## 💡 Hints & Tips

**Common Challenges:**

1. **"There's too much data to organize"**
   - Start with a simple spreadsheet
   - Use markdown tables for clean formatting
   - Sort by date first, analyze later

2. **"I can't find conflicts"**
   - That's okay! Sometimes data is consistent
   - Document that you checked for conflicts
   - Note high confidence in verified facts

3. **"Creating screenshots of simulated data?"**
   - Type the simulated posts into a text document
   - Screenshot that document (as if it were real)
   - Or use mockup tools (Tweeten, etc.)
   - Focus on practicing the process, not perfect fakes

4. **"Timeline is confusing"**
   - Use timeline template provided
   - One event per row
   - Add "Significance" column to explain importance

---

## 🔍 Advanced Challenges (Optional)

**For students who finish early:**

1. **Network Mapping:**
   - Create a visual map of subject's professional network
   - Identify key influencers/connections
   - Assess network reach and influence

2. **Sentiment Analysis:**
   - Categorize posts by sentiment (positive/negative/neutral)
   - Track sentiment changes over time
   - Identify trigger events for sentiment shifts

3. **Predictive Analysis:**
   - Based on patterns, predict subject's next career move
   - Justify prediction with evidence
   - Assess likelihood (Low/Medium/High)

---

## 📚 Related Resources

**Required Reading:**
- [Twitter/X OSINT SOP](../../../Investigations/Platforms/sop-platform-twitter-x.md)
- [LinkedIn OSINT SOP](../../../Investigations/Platforms/sop-platform-linkedin.md)
- [Collection Logging SOP](../../../Investigations/Techniques/sop-collection-log.md)

**Reference Material:**
- [Example Investigation - Timeline Section](../../2025-001-Example-Investigation/00-Case-Overview.md#investigation-timeline)
- [Example Investigation - Subject Profile](../../2025-001-Example-Investigation/01-Subject-Profiles.md)

**Tools:**
- TimelineJS: https://timeline.knightlab.com/
- Tiki-Toki: https://www.tiki-toki.com/
- Excel/Google Sheets for data organization

---

## ⚠️ Important Reminders

- ✅ This exercise uses **SIMULATED DATA** - practice the methodology
- ✅ Document **methodology** (how you verified information)
- ✅ Assign **confidence levels** to all findings
- ✅ Cross-reference across platforms for verification
- ❌ In real investigations, **never rely on single source**
- ❌ **Don't fabricate** data not provided in exercise

---

**Exercise Created:** 2025-10-12
**Version:** 1.0
**Difficulty:** 📙 Intermediate
**Estimated Completion Time:** 5-8 hours

---

## 📋 Timeline Template

**Copy this table into your `00-Master-Timeline.md`:**

```markdown
| Date | Time | Platform | Event Type | Content Summary | Evidence ID | Confidence | Significance |
|------|------|----------|------------|-----------------|-------------|------------|--------------|
| 2021-12-XX | Unknown | GitHub | Account Created | Profile created | E001 | High | Beginning of online presence |
| 2022-01-10 | ~10:00 PST | LinkedIn | Post | Career announcement | E002 | High | Started at TechCorp |
| 2022-01-15 | 09:30 PST | Twitter | Post | Job announcement tweet | E003 | High | Confirms LinkedIn post |
| ... | ... | ... | ... | ... | ... | ... | ... |
```

Fill in all 30+ events from the simulated data above.
