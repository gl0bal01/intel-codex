---
type: sop
title: Financial Crime & AML OSINT
tags: [sop, finance, aml, sanctions]
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
- [Companies House](https://find-and-update.company-information.service.gov.uk/) - Free UK company search
- Lookup: company name, number, directors, filing history, PSC (Persons with Significant Control)

**United States:**
- [EDGAR (SEC)](https://www.sec.gov/edgar/searchedgar/companysearch.html) - Public companies
- State-level registries (e.g., Delaware Division of Corporations, California SOS)
- [OpenCorporates](https://opencorporates.com) - Global company search aggregator

**European Union:**
- [European Business Register](https://e-justice.europa.eu/topics/registers-business-insolvency-land/business-registers-search-company-eu_en/) - Cross-border company information
- Country-specific registries (e.g., Netherlands KVK, Germany Handelsregister)

**Offshore/High-Risk:**
- Limited public access (BVI, Cayman, Panama, etc.)
- Use: ICIJ leaks databases (Panama Papers, Paradise Papers, Pandora Papers)

### UBO (Ultimate Beneficial Owner) Identification

**Steps:**
1. Identify registered directors and shareholders
2. Trace ownership chains upward (holding companies, trusts)
3. Look for PSC/UBO disclosures (required in UK, EU)
4. Cross-reference names with PEP/sanctions databases
5. Map corporate structure visually

**Tools:**
- [OpenCorporates](https://opencorporates.com) - Free corporate database
- [OpenOwnership](https://register.openownership.org/) - Beneficial ownership data
- [ICIJ Offshore Leaks Database](https://offshoreleaks.icij.org/) - Leaked offshore entities

---

## 3. Sanctions & PEP Screening

### Sanctions Lists (Public)

**OFAC (US Treasury):**
- [OFAC SDN List](https://sanctionssearch.ofac.treas.gov/) - Specially Designated Nationals
- Download consolidated list: [XML/CSV](https://ofac.treasury.gov/file-finder)

**European Union:**
- [EU Sanctions Map](https://www.sanctionsmap.eu/) - EU consolidated list
- [EU Financial Sanctions Database](https://webgate.ec.europa.eu/fsd/fsf)

**United Nations:**
- [UN Security Council Sanctions](https://www.un.org/securitycouncil/sanctions/information) - UN consolidated list

**United Kingdom:**
- [UK Sanctions List](https://www.gov.uk/government/publications/financial-sanctions-consolidated-list-of-targets)

**Other:**
- [World Bank Debarred Firms](https://www.worldbank.org/en/projects-operations/procurement/debarred-firms)
- Interpol Red Notices (for individuals)

### PEP (Politically Exposed Persons)

**Free/Open Resources:**
- [WikiData](https://www.wikidata.org/) - Search for political positions, government roles
- [EveryPolitician](http://everypolitician.org/) - Global politician database
- [OpenSanctions](https://www.opensanctions.org/pep/) - Aggregated PEP & sanctions data (open source)

**Commercial (subscription):**
- World-Check, Dow Jones, LexisNexis, Refinitiv (enterprise screening)

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
- [PACER](https://pacer.uscourts.gov/) (US federal courts)
- [CourtListener](https://www.courtlistener.com/) (free US legal opinions)
- [BAILII](https://www.bailii.org/) (UK/Irish case law)

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
- [Payment Service Provider Search](https://www.fca.org.uk/firms/financial-services-register) (UK FCA)
- VISA/Mastercard partner lists
- Scam reporting databases (Action Fraud, FBI IC3, FTC)

---

## 5. Cryptocurrency Tracing

### Blockchain Explorers (Public, Free)

**Bitcoin:**
- [Blockchain.com](https://www.blockchain.com/explorer)
- [Blockchair](https://blockchair.com/bitcoin)
- [Mempool.space](https://mempool.space/)

**Ethereum:**
- [Etherscan](https://etherscan.io/)
- [Blockchair](https://blockchair.com/ethereum)

**Other Chains:**
- Litecoin: [BlockCypher](https://live.blockcypher.com/ltc/)
- Bitcoin Cash: [Blockchain.com BCH](https://www.blockchain.com/explorer?view=bch)
- Monero: Limited tracing (privacy coin)
- Tron, BSC, Polygon: Network-specific explorers

### Wallet Analysis

**Basic workflow:**
1. Input wallet address into explorer
2. Review transaction history (inflows/outflows)
3. Identify clusters (addresses transacting together)
4. Export transaction CSV for timeline analysis
5. Flag exchanges, mixers/tumblers, known entities

**Look for:**
- Exchange deposit addresses (Binance, Coinbase, Kraken tags)
- Mixing services (CoinJoin, Wasabi, ChipMixer)
- Known scam addresses (check [Chainabuse](https://www.chainabuse.com/))
- Large value transfers or patterns (layering/structuring)

### Tools

**Free:**
- [Wallet Explorer](https://www.walletexplorer.com/) - Bitcoin wallet clustering
- [OXT](https://oxt.me/) - Bitcoin transaction analysis
- [Etherscan Token Tracker](https://etherscan.io/tokens) - ERC-20 token flows

**Commercial:**
- Chainalysis (law enforcement/enterprise)
- Elliptic (compliance/investigations)
- CipherTrace (AML/CTF)

### Exchanges & On/Off Ramps

**Identify exchanges:**
- Look for known deposit address patterns (exchanges tag addresses)
- Check for exchange hot wallets (publicly documented)
- Use blockchain analytics tools to label addresses

**Document:**
- Which exchanges were used
- Timestamps of deposits/withdrawals
- Amounts and asset types
- KYC requirements of that exchange (relevant for attribution)

**Red flags:**
- Use of privacy coins (Monero, Zcash)
- Mixing/tumbling services
- Peer-to-peer (P2P) platforms with weak KYC
- Rapid movement through multiple wallets (layering)

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
2. Search Action Fraud / FBI IC3 / FTC complaints
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

- **Never transact** with crypto wallets or bank accounts under investigation
- **Do not access** darknet markets or illicit platforms
- **Respect data protection laws** (GDPR, etc.) - minimize PII collection
- **Log all queries** for audit trail and legal defensibility
- **Flag immediately** if you encounter evidence of child exploitation, terrorism, or imminent harm
- **Consult legal** before sharing findings with third parties
- **Maintain confidentiality** - handle financial intelligence as sensitive

---

## 10. Resources Quick Reference

| Resource | Type | URL |
|----------|------|-----|
| OpenCorporates | Global company search | [opencorporates.com](https://opencorporates.com) |
| Companies House (UK) | UK registry | [find-and-update.company-information.service.gov.uk](https://find-and-update.company-information.service.gov.uk/) |
| OFAC SDN Search | US sanctions | [sanctionssearch.ofac.treas.gov](https://sanctionssearch.ofac.treas.gov/) |
| EU Sanctions Map | EU sanctions | [sanctionsmap.eu](https://www.sanctionsmap.eu/) |
| OpenSanctions | Aggregated sanctions/PEP | [opensanctions.org](https://www.opensanctions.org/) |
| ICIJ Offshore Leaks | Leaked offshore data | [offshoreleaks.icij.org](https://offshoreleaks.icij.org/) |
| Etherscan | Ethereum explorer | [etherscan.io](https://etherscan.io/) |
| Blockchain.com | Bitcoin explorer | [blockchain.com/explorer](https://www.blockchain.com/explorer) |
| Chainabuse | Crypto scam database | [chainabuse.com](https://www.chainabuse.com/) |

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

❌ Relying on single-source data (cross-verify across registries)
❌ Missing historical changes (directors, addresses, ownership)
❌ Not checking sanctions lists thoroughly (check all major lists)
❌ Assuming privacy = guilt (legitimate reasons for offshore structures exist)
❌ Transacting or interacting with suspect wallets/accounts
❌ Not documenting sources and timestamps (breaks chain of custody)
❌ Overlooking adverse media in non-English sources
