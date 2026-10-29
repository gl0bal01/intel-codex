---
type: sop
title: Financial Crime & AML OSINT
description: "Financial intelligence techniques: cryptocurrency tracing, sanctions screening, AML investigation & blockchain analysis for financial crime detection."
tags: [sop, finance, aml, sanctions]
updated: 2026-10-29
---

# Financial Crime & AML OSINT

## Objectives
- Identify beneficial owners and entity relationships
- Screen for sanctions, PEP (Politically Exposed Persons), and adverse media
- Trace financial flows through corporate structures and payment systems
- Map cryptocurrency transactions (where applicable)

---

## 1. Key Questions

- **Who benefits?** Ultimate Beneficial Owners (UBOs), directors, shareholders
- **What entities/wallets/accounts touch the flow?** Payment processors, intermediaries, shell companies
- **Are there sanctions/PEP/compliance flags?** OFAC, EU, UN sanctions lists
- **What are the red flags?** Unusual structures, high-risk jurisdictions, rapid changes
- **What is the money flow?** Source → intermediaries → destination

---

## 2. Corporate Entity Research

### Company Registries (Public)

**United Kingdom:**
- [Companies House](https://find-and-update.company-information.service.gov.uk/) - Free UK company search [verify 2026-10-29]
- Lookup: company name, number, directors, filing history, PSC (Persons with Significant Control)

**United States:**
- [EDGAR (SEC)](https://www.sec.gov/search-filings) - Public companies [verify 2026-10-29]
- State-level registries (e.g., Delaware Division of Corporations, California SOS)
- [OpenCorporates](https://opencorporates.com) - Global company search aggregator [verify 2026-10-29]

**European Union:**
- [European Business Register](https://e-justice.europa.eu/topics/registers-business-insolvency-land/business-registers-search-company-eu_en/) - Cross-border company information [verify 2026-10-29]
- Country-specific registries (e.g., Netherlands KVK, Germany Handelsregister)

**Offshore/High-Risk:**
- Limited public access (BVI, Cayman, Panama, etc.)
- Use: ICIJ leaks databases (Panama Papers, Paradise Papers, Pandora Papers) [verify 2026-10-29]

### UBO (Ultimate Beneficial Owner) Identification

**Steps:**
1. Identify registered directors and shareholders
2. Trace ownership chains upward (holding companies, trusts)
3. Look for PSC/UBO disclosures — the UK PSC register is public (Companies House); EU UBO registers lost general public access after CJEU Joined Cases C-37/20 & C-601/20 (2022-11-22), and access now requires a legitimate interest (Directive (EU) 2024/1640 Art. 12, transposition due 2026-07-10; media and AML-focused civil society/academia are deemed to have one) — apply to the national register [verify 2026-10-29]
4. Cross-reference names with PEP/sanctions databases
5. Map corporate structure visually

**Tools:**
- [OpenCorporates](https://opencorporates.com) - Free corporate database [verify 2026-10-29]
- [Open Ownership BODS data](https://bods-data.openownership.org/) - Bulk beneficial-ownership datasets (UK PSC + Register of Overseas Entities; GLEIF ownership mapping); the public Open Ownership Register closed 2024-11-29 [verify 2026-10-29]
- [ICIJ Offshore Leaks Database](https://offshoreleaks.icij.org/) - Leaked offshore entities [verify 2026-10-29]

---

## 3. Sanctions & PEP Screening

### Sanctions Lists (Public)

**OFAC (US Treasury):**
- [OFAC SDN List](https://sanctionssearch.ofac.treas.gov/) - Specially Designated Nationals; web search interface [verify 2026-10-29]
- Download consolidated list (XML/CSV, updated daily): [OFAC File Finder](https://ofac.treasury.gov/file-finder) (or the newer bulk endpoint at [sanctionslist.ofac.treas.gov](https://sanctionslist.ofac.treas.gov)) [verify 2026-10-29]
- Crypto coverage: SDN list includes **Digital Currency Address** (DCA) entries tagged by currency code (`XBT`, `ETH`, `USDT`, `XMR`, etc.). Treat each DCA hit as a high-priority pivot. [verify 2026-10-29]

**European Union:**
- [EU Sanctions Map](https://www.sanctionsmap.eu/) - EU consolidated list [verify 2026-10-29]
- [EU Financial Sanctions Database](https://webgate.ec.europa.eu/fsd/fsf) [verify 2026-10-29]

**United Nations:**
- [UN Security Council Consolidated List](https://main.un.org/securitycouncil/en/content/un-sc-consolidated-list) - UN consolidated list (XML/HTML) [verify 2026-10-29]

**United Kingdom:**
- [UK Sanctions List](https://www.gov.uk/government/publications/the-uk-sanctions-list) - FCDO; the only source for all UK designations since 2026-01-28, when the OFSI Consolidated List of Asset Freeze Targets closed [verify 2026-10-29]

**Other:**
- [World Bank Debarred Firms](https://www.worldbank.org/en/projects-operations/procurement/debarred-firms) [verify 2026-10-29]
- Interpol Red Notices (for individuals) [verify 2026-10-29]

### PEP (Politically Exposed Persons)

**Free/Open Resources:**
- [WikiData](https://www.wikidata.org/) - Search for political positions, government roles
- [EveryPolitician](https://everypolitician.org/) - Global politician/position database; relaunched in 2026 as an OpenSanctions project (mySociety froze the original data in June 2019) [verify 2026-10-29]
- [OpenSanctions](https://www.opensanctions.org/pep/) - Aggregated PEP & sanctions data (bulk data CC BY-NC 4.0: free for non-commercial use, business use — including compliance screening — needs a data licence) [verify 2026-10-29]

**Commercial (subscription):**
- LSEG World-Check (formerly Refinitiv World-Check; LSEG retired the Refinitiv brand starting Aug 2023) [verify 2026-10-29]
- Dow Jones Risk & Compliance, LexisNexis Risk Solutions, Moody's Orbis (Bureau van Dijk), Sayari Graph — enterprise screening / corporate-network analytics [verify 2026-10-29]

**Manual checks:**
- Government websites (parliament, cabinet lists)
- News archives for political appointments
- LinkedIn for government/state-owned enterprise roles

### Adverse Media Screening

**Search engines with temporal filtering:**
```
"John Doe" AND ("fraud" OR "corruption" OR "money laundering" OR "embezzlement" OR "bribery")
site:news.com "Company Name" AND ("investigation" OR "charged" OR "lawsuit")
```

**News databases:**
- Google News Archive
- Bing News (with date filters)

**Legal case databases:**
- [PACER](https://pacer.uscourts.gov/) (US federal courts) [verify 2026-10-29]
- [CourtListener](https://www.courtlistener.com/) (free US legal opinions) [verify 2026-10-29]
- [BAILII](https://www.bailii.org/) (UK/Irish case law) [verify 2026-10-29]

---

## 4. Payment Systems & Financial Infrastructure

### Payment Processors & Merchant IDs

**Identifiers to collect:**
- Merchant Category Code (MCC)
- Payment processor names (Stripe, PayPal, Square, etc.)
- Bank merchant descriptors (what appears on statements)
- IBAN/SWIFT/BIC codes (if disclosed)

**Pivot opportunities:**
- Search merchant descriptors in scam databases
- Cross-reference payment processors with known fraud patterns
- Check processor websites for merchant status/verification

### High-Risk Payment Service Providers (PSPs)

**Red flags:**
- Offshore registration (BVI, Cyprus, Seychelles)
- No regulatory oversight or license
- Known association with fraud/scams (check forums, complaints)
- Multiple domain names for same processor

**Resources:**
- [Payment Service Provider Search](https://www.fca.org.uk/firms/financial-services-register) (UK FCA) [verify 2026-10-29]
- VISA/Mastercard partner lists
- Scam reporting services ([Report Fraud](https://www.reportfraud.police.uk/) — replaced Action Fraud on 2025-12-04 for England, Wales and NI; FBI IC3; FTC ReportFraud) [verify 2026-10-29]

---

## 5. Cryptocurrency Tracing — AML Analyst Quick Reference

> Deep on-chain methodology — multi-chain tracing, address clustering, mixer / CoinJoin defeat, cross-chain bridge tracing, and court-admissibility tradecraft — lives in [[sop-blockchain-investigation|Blockchain Investigation]] and [[sop-mixer-tracing|Mixer & Privacy-Pool Tracing]]. This section is the AML-analyst entry-point only: surface-level wallet check, sanctions screening, and Travel-Rule context. Hand off any deep tracing work to those SOPs.

### Surface-level wallet check

1. Look up the address in a public explorer: [Blockchain.com](https://www.blockchain.com/explorer) or [Mempool.space](https://mempool.space/) (BTC), [Etherscan](https://etherscan.io/) (ETH / EVM), [Blockchair](https://blockchair.com/) (multi-chain). [verify 2026-10-29]
2. Note inflows / outflows, exchange-deposit patterns, and any vendor-tagged labels ([Arkham Intelligence](https://info.arkm.com/) for entity labels, [Chainabuse](https://www.chainabuse.com/) for known-bad reports). [verify 2026-10-29]
3. Flag any of: privacy-coin hops (Monero, Zcash shielded), CoinJoin / mixer activity, cross-chain bridge use, peel chains, round-number layering, no-KYC swap services (FixedFloat/ff.io, ChangeNOW, SimpleSwap), OFAC SDN Digital Currency Address (DCA) hits.
4. **Stop here.** Do not transact with the address. Do not pivot deeper without engaging blockchain-investigation methodology — vendor labels are heuristics, not court evidence, and pasting addresses into free analytics surfaces can leak the investigation.

### Sanctions screening (crypto-side)

The OFAC SDN list includes **Digital Currency Address (DCA)** entries tagged by currency code (`XBT`, `ETH`, `USDT`, `XMR`, etc.). Each DCA hit is a high-priority sanctions exposure. Sanctions designations are time-stamped facts — record both the activity timestamp **and** the list state at that time (Tornado Cash addresses were SDN-listed 2022-08-08 and re-designated 2022-11-08; on 2024-11-26 the Fifth Circuit held its immutable smart contracts could not be blocked under IEEPA (*Van Loon v. Treasury*, No. 23-50669, reversed and remanded); OFAC delisted them 2025-03-21). EU, UK (FCDO UK Sanctions List), and UN consolidated lists may not mirror US DCA entries; screen all four at minimum. [verify 2026-10-29]

### Travel Rule (FATF Recommendation 16)

VASPs (exchanges, custodial wallets, OTC desks) must transmit originator / beneficiary information for crypto transfers above a jurisdictional threshold. Implementations differ:

- **US (FinCEN):** USD 3,000 threshold (31 CFR 1010.410(f)) [verify 2026-10-29]
- **EU (Transfer of Funds Regulation / MiCA):** **No de minimis** for VASP-to-VASP transfers from 2024-12-30 [verify 2026-10-29]
- **UK (FCA; MLRs 2017 reg. 64C):** no de minimis for the basic payload — originator/beneficiary names and account numbers (or a unique transaction identifier) accompany every inter-cryptoasset-business transfer. Where any business in the chain is outside the UK, one further originator identifier (customer ID number, address, ID-document number, or date and place of birth) must also accompany transfers ≥ £800 (linked transfers aggregated); all-UK chains supply it on request within three working days. £800 replaced EUR 1,000 from 2026-06-30 (SI 2026/621 reg. 32) [verify 2026-10-29]
- **Singapore / Switzerland / Japan:** thresholds vary; check the local FIU

Non-compliant VASPs and self-hosted-wallet routes are common AML red flags. Travel Rule plumbing: IVMS101 is the common data-model standard; open protocols include TRP; commercial networks include Sygna Bridge, Notabene and Shyft Veriscope [vendor list shifts annually]. [verify 2026-10-29]

### Hand-off

- **Multi-chain tracing, address clustering, bridge-event indexing, court-admissibility tradecraft** → [[sop-blockchain-investigation|Blockchain Investigation]]
- **Mixer / CoinJoin / Tornado Cash / Wasabi / Whirlpool / cross-chain-bridge obfuscation defeat, regulatory-event timeline** → [[sop-mixer-tracing|Mixer & Privacy-Pool Tracing]]

---

## 6. Financial Red Flags

### Corporate Structure Red Flags
- Rapid director/shareholder changes
- Mailbox/virtual office addresses
- Nominee directors/shareholders (names appearing across many companies)
- Circular ownership (Company A owns B, B owns A)
- Offshore entities with no clear business purpose
- Multiple dissolved companies with same directors

### Transaction Red Flags
- Transactions inconsistent with business type
- Round-number transactions (structuring to avoid reporting thresholds)
- High-risk jurisdictions in payment flow
- Funnel accounts (many in, one out or vice versa)
- Shell companies as intermediaries
- Invoices with no supporting documentation
- Goods/services mismatch (declared vs actual)

### Payment Processor Red Flags
- Unregistered or unlicensed PSPs
- Offshore payment processors for domestic business
- Frequent PSP changes
- Merchant accounts in high-risk categories (gambling, pharma, crypto)

---

## 7. Investigation Workflow

### Example: Suspicious Company Investigation

**Target:** `SuspiciousCorp Ltd (UK)`

**Step 1: Company Registry**
```
1. Search Companies House for "SuspiciousCorp Ltd"
2. Extract:
   - Company number
   - Registration date
   - Directors (current & resigned)
   - PSC (UBO) disclosures
   - Filing history
   - Registered address
3. Screenshot and save PDF of company profile
```

**Step 2: Director Background**
```
1. Extract director names
2. Search for other directorships (Companies House "Search for a director")
3. LinkedIn search for professional background
4. Google News search: "Director Name" + fraud/investigation
5. Cross-reference with sanctions lists
```

**Step 3: UBO Identification**
```
1. Check PSC register (Companies House)
2. If holding company listed, trace upward
3. Use OpenCorporates for international entities
4. Map ownership structure diagram
```

**Step 4: Sanctions & PEP Check**
```
1. Search OFAC SDN: https://sanctionssearch.ofac.treas.gov/
2. Search EU Sanctions: https://www.sanctionsmap.eu/
3. Search OpenSanctions: https://www.opensanctions.org/
4. Check UN Consolidated List
5. Document results with timestamps
```

**Step 5: Financial Infrastructure**
```
1. Identify payment processors (from website, customer complaints)
2. Check FCA register for PSP authorization
3. Search merchant descriptor in scam databases
4. Document payment flow
```

**Step 6: Adverse Media**
```
1. Google News: "SuspiciousCorp" + (fraud OR scam OR investigation)
2. Search Report Fraud (ex-Action Fraud) / FBI IC3 / FTC complaints
3. Check Trustpilot, BBB, Reddit for complaints
4. Document findings with URLs and timestamps
```

**Step 7: Cryptocurrency (if applicable)**
```
1. Identify wallet addresses (from website, social media, customer reports)
2. Input into Etherscan/Blockchain.com
3. Export transaction history CSV
4. Flag exchanges, mixers, high-value transactions
5. Create timeline and flow diagram
```

**Step 8: Document & Report**
```
1. Create entity relationship diagram
2. Build timeline of key events
3. Compile evidence bundle (screenshots, CSVs, PDFs)
4. Hash all files (SHA-256)
5. Write summary with confidence levels for findings
```

---

## 8. Collection & Evidence Handling

**For each source, log:**
- URL/database queried
- Exact search terms used
- Timestamp (UTC)
- Results (screenshot + text export)
- SHA-256 hash of saved files

**File structure:**
```
/Evidence/{case_id}/Financial/
  ├── corporate/
  │   ├── 20251005_CompaniesHouse_SuspiciousCorp.pdf
  │   └── 20251005_directors_list.csv
  ├── sanctions/
  │   ├── 20251005_OFAC_search_JohnDoe.png
  │   └── 20251005_EU_sanctions_results.txt
  ├── adverse_media/
  │   └── 20251005_news_search_fraud.pdf
  ├── crypto/
  │   ├── 20251005_wallet_0x123_transactions.csv
  │   └── 20251005_etherscan_screenshot.png
  └── diagrams/
      ├── entity_map.png
      └── payment_flow.png
```

---

## 9. Legal & Ethical Constraints

Canonical legal framework: see [[sop-legal-ethics|Legal & Ethics]]. Do not re-derive jurisdiction, statute, or authorization rules here — read them from the canonical SOP and apply.

OPSEC for the investigator (separation of attribution, network egress, wallet/account hygiene): see [[sop-opsec-plan|OPSEC Plan]]. Crypto investigations leak more than IP — viewing a wallet on a logged-in exchange, transacting from an attribution-tied address, or pasting an address into an analytics service that resells data can each compromise the investigation.

**Financial-intelligence-specific guardrails:**

- **Never transact** with crypto wallets or bank accounts under investigation. Even a 1-satoshi "test" can taint the cluster, alert the subject, and create legal exposure.
- **Do not access** darknet markets or illicit platforms to "verify" a finding — open-source pivot only.
- **Bank account / IBAN lookups:** retrieving account holder data without lawful authority is a criminal offence in most jurisdictions (e.g. UK Computer Misuse Act, US 18 U.S.C. §1030, EU GDPR Art. 6/9). [verify 2026-10-29] Use only published / leaked / sanctions-listed identifiers; pivot to a regulated channel (MLRO, FIU SAR, mutual legal assistance) for non-public account intel.
- **Sanctions hits are time-stamped facts.** Record both the activity timestamp **and** the sanctions-list state at that time (e.g. Tornado Cash addresses were SDN-listed 2022-08-08 → re-designated 2022-11-08 → Fifth Circuit held them unblockable under IEEPA 2024-11-26 (*Van Loon v. Treasury*, No. 23-50669) → delisted by OFAC 2025-03-21). Liability assessments hinge on the temporal alignment. [verify 2026-10-29]
- **PII minimization (GDPR / UK DPA / CCPA):** collect only what is necessary for the analytical purpose; document lawful basis (legitimate interest / legal claim / public-task) per query.
- **Mandatory reporting / Suspicious Activity Reports:** if you are operating inside a regulated entity, route findings through the MLRO. Outside a regulated entity, route serious findings (sanctions evasion, terrorist financing, child exploitation funding) via the appropriate FIU (FinCEN, NCA, FIU-NL, etc.) — see [[sop-sensitive-crime-intake-escalation|Sensitive Crime Intake & Escalation]].
- **Log every query** (URL, search terms, UTC timestamp, hash of saved output) — see [[sop-collection-log|Collection Log]] for the canonical format.

---

## 10. Resources Quick Reference

| Resource | Type | URL |
|----------|------|-----|
| OpenCorporates | Global company search | [opencorporates.com](https://opencorporates.com) [verify 2026-10-29] |
| Companies House (UK) | UK registry | [find-and-update.company-information.service.gov.uk](https://find-and-update.company-information.service.gov.uk/) |
| Open Ownership BODS data | Beneficial ownership bulk datasets (Register closed 2024-11-29) | [bods-data.openownership.org](https://bods-data.openownership.org/) [verify 2026-10-29] |
| OCCRP Aleph | Investigative document graph | [aleph.occrp.org](https://aleph.occrp.org/) [verify 2026-10-29] |
| C4ADS Horizons | Investigative document search (access on request; terms not published — confirm with C4ADS) | [Horizons](https://horizons.c4ads.org/about) |
| OFAC SDN Search | US sanctions | [sanctionssearch.ofac.treas.gov](https://sanctionssearch.ofac.treas.gov/) [verify 2026-10-29] |
| OFAC Sanctions List Service | US sanctions data downloads (SDN, non-SDN consolidated, delta files, custom datasets) | [sanctionslist.ofac.treas.gov/Home/SdnList](https://sanctionslist.ofac.treas.gov/Home/SdnList) [verify 2026-10-29] |
| EU Sanctions Map | EU sanctions | [sanctionsmap.eu](https://www.sanctionsmap.eu/) [verify 2026-10-29] |
| EU Financial Sanctions DB | EU consolidated list | [webgate.ec.europa.eu/fsd/fsf](https://webgate.ec.europa.eu/fsd/fsf) [verify 2026-10-29] |
| UK Sanctions List | UK designations (FCDO; OFSI Consolidated List closed 2026-01-28) | [gov.uk/government/publications/the-uk-sanctions-list](https://www.gov.uk/government/publications/the-uk-sanctions-list) [verify 2026-10-29] |
| UN Security Council Consolidated List | UN consolidated list | [main.un.org/securitycouncil/en/content/un-sc-consolidated-list](https://main.un.org/securitycouncil/en/content/un-sc-consolidated-list) [verify 2026-10-29] |
| OpenSanctions | Aggregated sanctions/PEP/CRIME | [opensanctions.org](https://www.opensanctions.org/) |
| ICIJ Offshore Leaks | Leaked offshore data | [offshoreleaks.icij.org](https://offshoreleaks.icij.org/) [verify 2026-10-29] |
| Etherscan | Ethereum explorer | [etherscan.io](https://etherscan.io/) [verify 2026-10-29] |
| Blockchair | Multi-chain explorer | [blockchair.com](https://blockchair.com/) |
| Mempool.space | Bitcoin mempool & explorer | [mempool.space](https://mempool.space/) [verify 2026-10-29] |
| Blockchain.com | Bitcoin explorer | [blockchain.com/explorer](https://www.blockchain.com/explorer) |
| Chainabuse | Crypto scam database | [chainabuse.com](https://www.chainabuse.com/) [verify 2026-10-29] |
| Arkham Intelligence | On-chain entity labels | [info.arkm.com](https://info.arkm.com/) [verify 2026-10-29] |
| Breadcrumbs | Blockchain visualization (pricing unverified) | [breadcrumbs.app](https://www.breadcrumbs.app/) |
| FATF | Standards & VASP guidance | [fatf-gafi.org](https://www.fatf-gafi.org/) |

---

## 11. Output Deliverables

**1. Entity Relationship Diagram**
- Visual map showing UBOs → Companies → Subsidiaries → Assets
- Use tools: draw.io, Maltego, or simple diagrams

**2. Financial Flow Diagram**
- Source → Intermediaries → Destination
- Label with amounts, dates, entities, confidence levels

**3. Counterparty Table**
- Entity name | Role | Jurisdiction | Sanctions/PEP Status | Confidence | Source

**4. Timeline**
- Chronological events: registrations, transactions, director changes, adverse events

**5. Evidence Bundle**
- All screenshots, exports, search results
- Hash manifest (SHA-256 for each file)
- Chain of custody log

---

## 12. Common Pitfalls

- ❌ Relying on single-source data (cross-verify across registries)
- ❌ Missing historical changes (directors, addresses, ownership) — corporate registries surface "current state" by default
- ❌ Not checking sanctions lists thoroughly (OFAC + EU + UK Sanctions List + UN at minimum; many SDN crypto entries are not present in non-US lists)
- ❌ Stating sanctions status without a timestamp — Tornado Cash's SDN entries were added (2022-08-08), replaced by a re-designation (2022-11-08) and deleted (2025-03-21), with a court ruling in between (2024-11-26); report what was true at the time of activity [verify 2026-10-29]
- ❌ Assuming privacy = guilt (legitimate reasons for offshore structures exist)
- ❌ Transacting or interacting with suspect wallets/accounts (taints clusters and may be a criminal offence)
- ❌ Not documenting sources and timestamps (breaks chain of custody)
- ❌ Overlooking adverse media in non-English sources
- ❌ Treating commercial blockchain-analytics labels as ground truth — they are heuristic clusters, not court evidence; corroborate before publishing
- ❌ Stopping at the first mixer / bridge hop instead of continuing on the receiving side
- ❌ Pasting target addresses into free analytics services without checking whether they resell or log queries (operational leak)

---

## Related SOPs

- [[sop-legal-ethics|Legal & Ethics]] — canonical legal framework
- [[sop-opsec-plan|OPSEC Plan]] — investigator OPSEC, including crypto-side leaks
- [[sop-entity-dossier|Entity Dossier]] — structured target profiling
- [[sop-collection-log|Collection Log]] — chain-of-custody and query logging
- [[sop-reporting-packaging-disclosure|Reporting, Packaging & Disclosure]] — output formatting & disclosure routes
- [[sop-web-dns-whois-osint|Web / DNS / WHOIS OSINT]] — domain pivots for fraud sites and crypto scam infrastructure
- [[sop-sensitive-crime-intake-escalation|Sensitive Crime Intake & Escalation]] — escalation path for terrorism / sanctions evasion / CSAM-funding leads

---

**Last Updated:** 2026-10-29
