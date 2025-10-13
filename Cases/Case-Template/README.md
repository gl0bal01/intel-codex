# Case Template

**This is a blank case template for starting new OSINT investigations.**

---

## 📋 How to Use This Template

### Step 1: Copy This Folder

```bash
# From the ObsidianVault root directory
cp -r Cases/Case-Template Cases/YYYY-NNN-Your-Case-Name

# Example:
cp -r Cases/Case-Template Cases/2025-005-Twitter-Investigation
```

### Step 2: Rename Your Case

Follow the naming convention: `YYYY-NNN-Brief-Description`

- **YYYY** = Year (e.g., 2025)
- **NNN** = Sequential case number (001, 002, 003...)
- **Brief-Description** = Short kebab-case description

**Examples:**
- `2025-005-Domain-Phishing-Analysis`
- `2025-006-Instagram-Impersonation`
- `2025-007-Crypto-Wallet-Tracing`

### Step 3: Complete Each File

Work through the files in order:

1. **00-Case-Overview.md** - Document case details, scope, objectives
2. **01-Subject-Profiles.md** - Build entity dossiers
3. **02-Collection-Log.md** - Track evidence as you collect it
4. **03-Evidence/** - Store all collected materials
5. **04-Reports/** - Write your final reports
6. **05-Admin/** - Maintain authorization, chain of custody

### Step 4: Follow the Workflow

Refer to the [Investigation Workflow Guide](../Investigation-Workflow.md) for step-by-step procedures.

---

## ⚠️ Before You Start

**REQUIRED READING:**
- [ ] [Legal & Ethics SOP](../../Investigations/Techniques/sop-legal-ethics.md)
- [ ] [OPSEC Planning SOP](../../Investigations/Techniques/sop-opsec-plan.md)
- [ ] Obtain **written authorization** from your supervisor/instructor
- [ ] Set up isolated investigation environment (VPN, burner accounts)

**If you skip these steps, you may violate laws or compromise the investigation.**

---

## 📁 Template Structure

```
Case-Template/
├── README.md                          # This file (instructions)
├── Case-Completion-Checklist.md      # How to know when you're done
├── 00-Case-Overview.md                # Case details and summary
├── 01-Subject-Profiles.md             # Entity dossiers
├── 02-Collection-Log.md               # Evidence tracking
├── 03-Evidence/                       # All collected evidence
│   ├── screenshots/
│   ├── domains/
│   ├── social-media/
│   ├── blockchain/
│   ├── images/
│   ├── documents/
│   ├── network/
│   └── victim-reports/
├── 04-Reports/                        # Investigation reports
└── 05-Admin/                          # Administrative files
    ├── authorization.txt
    ├── evidence-hashes.txt
    └── case-notes.md
```

---

## ✅ Quick Checklist

**Pre-Investigation:**
- [ ] Authorization obtained and documented
- [ ] Scope clearly defined (what's in/out of scope)
- [ ] OPSEC plan created
- [ ] Environment configured (VPN, isolated VM, etc.)

**During Investigation:**
- [ ] Evidence logged immediately after collection
- [ ] All files hashed (SHA-256)
- [ ] Chain of custody maintained
- [ ] Regular backups performed

**Post-Investigation:**
- [ ] All objectives addressed
- [ ] Report completed
- [ ] Evidence package created
- [ ] Case properly closed (see [Case Completion Checklist](Case-Completion-Checklist.md))

---

## 📚 Related Resources

- [Investigation Workflow Guide](../Investigation-Workflow.md)
- [Example Investigation](../2025-001-Example-Investigation/README.md)
- [Legal & Ethics SOP](../../Investigations/Techniques/sop-legal-ethics.md)
- [OPSEC Planning SOP](../../Investigations/Techniques/sop-opsec-plan.md)
- [Collection Log SOP](../../Investigations/Techniques/sop-collection-log.md)
- [Entity Dossier SOP](../../Investigations/Techniques/sop-entity-dossier.md)
- [Reporting SOP](../../Investigations/Techniques/sop-reporting-packaging-disclosure.md)

---

**Good luck with your investigation! Remember: Document everything, maintain OPSEC, and stay within legal/ethical boundaries.**
