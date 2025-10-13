# Case Completion Checklist

**Use this checklist to ensure you've completed all required tasks before closing your investigation.**

---

## 📋 Investigation Completion Checklist

### 1. Case Documentation

- [ ] **00-Case-Overview.md** is complete with:
  - [ ] Case ID, dates, and status
  - [ ] Scope and objectives clearly defined
  - [ ] All objectives addressed or explained if not met
  - [ ] Timeline of key events
  - [ ] Risk assessment completed
  - [ ] Intelligence gaps documented

- [ ] **01-Subject-Profiles.md** contains:
  - [ ] Complete entity dossiers for all subjects
  - [ ] Confidence ratings for all data points
  - [ ] Attribution assessment
  - [ ] Digital footprint summary
  - [ ] Cross-platform correlation analysis

- [ ] **02-Collection-Log.md** includes:
  - [ ] All evidence items logged
  - [ ] Each entry has: Evidence ID, date/time, source, hash, description
  - [ ] No missing evidence (all files in 03-Evidence/ are logged)
  - [ ] Collection methods documented

---

### 2. Evidence Management

- [ ] **All evidence files are properly stored:**
  - [ ] Organized in appropriate subdirectories (03-Evidence/screenshots/, etc.)
  - [ ] Files named descriptively with dates (YYYY-MM-DD format)
  - [ ] No duplicate or unnecessary files
  - [ ] Original files preserved (not edited or modified)

- [ ] **Evidence integrity verified:**
  - [ ] SHA-256 hashes calculated for ALL files
  - [ ] Hashes documented in 05-Admin/evidence-hashes.txt
  - [ ] Hash verification performed (re-hash and compare)
  - [ ] No hash mismatches

- [ ] **Chain of custody maintained:**
  - [ ] All evidence transfers documented
  - [ ] Custodian names and dates recorded
  - [ ] Access log maintained (who accessed evidence, when)
  - [ ] Evidence stored securely (encrypted volume recommended)

---

### 3. Reporting

- [ ] **Final report completed (04-Reports/):**
  - [ ] Executive summary (1-2 paragraphs)
  - [ ] Case information section
  - [ ] Methodology explained
  - [ ] All findings documented with evidence references
  - [ ] Timeline included
  - [ ] Risk assessment provided
  - [ ] Intelligence gaps acknowledged
  - [ ] Recommendations included
  - [ ] Proper formatting and professional language

- [ ] **Report quality checked:**
  - [ ] Proofread for spelling/grammar
  - [ ] All evidence IDs match Collection Log
  - [ ] No speculation or unverified claims
  - [ ] Confidence levels stated for all findings
  - [ ] Sources properly cited

- [ ] **Evidence package created:**
  - [ ] All evidence files organized and archived
  - [ ] Evidence manifest included (list of files with hashes)
  - [ ] Chain of custody documentation included
  - [ ] README file explaining package contents
  - [ ] Archive encrypted (if contains sensitive data)

---

### 4. Legal & Ethical Compliance

- [ ] **Authorization and scope:**
  - [ ] Written authorization obtained and filed (05-Admin/)
  - [ ] Investigation stayed within defined scope
  - [ ] Any scope changes documented and approved
  - [ ] No unauthorized access or methods used

- [ ] **Legal requirements met:**
  - [ ] Data protection laws respected (GDPR, CCPA, etc.)
  - [ ] Privacy boundaries observed
  - [ ] Terms of Service violations documented (not committed)
  - [ ] Proper escalation for sensitive crimes (if applicable)

- [ ] **Ethical standards upheld:**
  - [ ] No doxxing or harassment
  - [ ] Information not used for personal gain
  - [ ] Confidentiality maintained
  - [ ] Subject's privacy respected (within investigation scope)

---

### 5. Administrative Files

- [ ] **05-Admin/ folder contains:**
  - [ ] Authorization letter/email
  - [ ] Evidence hashes file (SHA-256SUMS or evidence-hashes.txt)
  - [ ] Chain of custody documentation
  - [ ] Case notes (investigator's observations and decisions)
  - [ ] Communication logs (if applicable)
  - [ ] Escalation documentation (if crimes reported)

---

### 6. Escalation & Disclosure

- [ ] **If criminal activity discovered:**
  - [ ] Appropriate authorities notified (see [Escalation SOP](../../Investigations/Techniques/sop-sensitive-crime-intake-escalation.md))
  - [ ] Escalation documented in case notes
  - [ ] Evidence preserved for law enforcement
  - [ ] Reporting followed proper procedures

- [ ] **Platform reporting (if applicable):**
  - [ ] Terms of Service violations reported to platforms
  - [ ] Reporting receipts/confirmation saved
  - [ ] Documentation in case notes

---

### 7. Quality Assurance

- [ ] **Self-review completed:**
  - [ ] All checklist items above completed
  - [ ] Case files re-read for accuracy
  - [ ] Evidence cross-checked against logs
  - [ ] Findings verified from multiple sources (where possible)

- [ ] **Peer review (if available):**
  - [ ] Case reviewed by colleague/instructor
  - [ ] Feedback incorporated
  - [ ] Issues addressed

---

### 8. Case Closure

- [ ] **Final steps:**
  - [ ] Case status updated to 🔴 Closed in README
  - [ ] Final deliverables submitted to requestor
  - [ ] Backup created and stored securely
  - [ ] Retention schedule documented
  - [ ] Access restricted (need-to-know basis)

- [ ] **Lessons learned:**
  - [ ] What went well documented
  - [ ] What could be improved noted
  - [ ] New techniques/tools discovered recorded
  - [ ] Personal skills assessment completed

---

## ✅ When All Items Are Checked

**Your case is ready for closure!**

1. Update case README with final status
2. Submit deliverables to requestor/instructor
3. Archive case files securely
4. Document retention policy
5. Move on to your next investigation

---

## 🚨 Common Mistakes to Avoid

| Mistake | Impact | Prevention |
|---------|--------|------------|
| **Missing evidence hashes** | Evidence inadmissible | Hash immediately after collection |
| **Incomplete collection log** | Can't trace evidence origin | Log as you go, not at the end |
| **No authorization documented** | Legal liability | Get written authorization BEFORE starting |
| **Poor OPSEC** | Tipped off subject | Follow OPSEC plan throughout |
| **Single-source verification** | False conclusions | Always cross-reference multiple sources |
| **Skipping chain of custody** | Evidence contamination concerns | Document every transfer/access |

---

## 📚 Related Resources

- [Investigation Workflow Guide](../Investigation-Workflow.md)
- [Reporting & Disclosure SOP](../../Investigations/Techniques/sop-reporting-packaging-disclosure.md)
- [Collection Log SOP](../../Investigations/Techniques/sop-collection-log.md)
- [Legal & Ethics SOP](../../Investigations/Techniques/sop-legal-ethics.md)

---

**Last Updated:** 2025-10-13
**Version:** 1.0
