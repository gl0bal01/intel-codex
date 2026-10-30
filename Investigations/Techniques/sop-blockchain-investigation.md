---
type: sop
title: Blockchain Investigation
description: "Multi-chain crypto-asset tracing methodology: address clustering, bridge read-flow tracing, sanctions integration, commercial and open-source analytics, and court-admissibility tradecraft for OSINT and investigative work."
tags:
  - sop
  - blockchain
  - cryptocurrency
  - tracing
  - clustering
  - sanctions
  - aml
  - bitcoin
  - ethereum
  - osint
  - investigation
created: 2026-04-26
updated: 2026-10-29
template_version: 2026-04-26
---

# Blockchain Investigation

> **Authorized environments only.** This SOP covers open-source observation and analysis of public blockchain ledgers for lawful investigative, journalistic, threat-intelligence, compliance, and research purposes. It is **not** a guide to interacting with target wallets, paying ransoms, transacting through sanctioned contracts, or running on-chain attacks. Address clustering and entity attribution are heuristic — not ground truth — and the difference matters when findings reach court. Read [[sop-legal-ethics|Legal & Ethics]] before every engagement and [[sop-opsec-plan|OPSEC Plan]] before configuring the analyst environment. Crypto investigations leak more signal than typical OSINT (logged-in exchange views, attribution-tied wallet queries, paid-analytics search histories) — apply OPSEC tightly. Mixer and privacy-pool obfuscation tracing routes to [[sop-mixer-tracing|Mixer & Privacy-Pool Tracing]]. Smart-contract code audit / exploit class review routes to [[sop-smart-contract-audit|Smart Contract Audit]].

---

## Table of Contents

1. [Objectives & Scope](#1-objectives--scope)
2. [Pre-Engagement & Authorization](#2-pre-engagement--authorization)
3. [Multi-Chain Landscape](#3-multi-chain-landscape)
4. [Blockchain Explorers & Public Data](#4-blockchain-explorers--public-data)
5. [Address Clustering Heuristics](#5-address-clustering-heuristics)
6. [Cross-Chain Bridge Tracing (Read-Flow)](#6-cross-chain-bridge-tracing-read-flow)
7. [Sanctions Integration](#7-sanctions-integration)
8. [Commercial Analytics Tools](#8-commercial-analytics-tools)
9. [Open-Source Analytics Workflows](#9-open-source-analytics-workflows)
10. [Exchange & VASP Pivots](#10-exchange--vasp-pivots)
11. [Investigation Workflow](#11-investigation-workflow)
12. [Court-Admissibility & Evidentiary Tradecraft](#12-court-admissibility--evidentiary-tradecraft)
13. [Cross-Platform Pivots](#13-cross-platform-pivots)
14. [Hand-off Boundaries (Scope Contract)](#14-hand-off-boundaries-scope-contract)
15. [Tools Reference](#15-tools-reference)
16. [Risks & Limitations](#16-risks--limitations)
17. [Common Pitfalls](#17-common-pitfalls)
18. [Real-World Scenarios](#18-real-world-scenarios)
19. [Emergency Procedures](#19-emergency-procedures)
20. [Related SOPs](#20-related-sops)
21. [External / Reference Resources](#21-external--reference-resources)

---

## 1. Objectives & Scope

### What this SOP covers

- Reading transparent blockchains (Bitcoin and UTXO-family, Ethereum and EVM-family, Tron, Solana, XRPL, etc.) for transaction-graph reconstruction
- Address clustering using public heuristics (common-input ownership, change-address detection, peel-chain pattern recognition, exchange-deposit clustering)
- Cross-chain bridge **read-flow** — pairing source-chain lock/burn events with destination-chain mint/release events through bridge contract logs
- Sanctions integration — OFAC SDN Digital Currency Address (DCA) screening, EU TFR / MiCA enforcement context, FATF Travel Rule (Recommendation 16) workflow
- Commercial-analytics tradecraft (Chainalysis, TRM Labs, Elliptic, Crystal, Arkham, GraphSense) — including the appropriate evidentiary weight to give vendor cluster labels
- Open-source workflows that can be independently reproduced (BlockSci-style queries, GraphSense, Breadcrumbs, raw-RPC + custom indexers)
- Exchange and VASP pivots — deposit-address clustering, hot/cold wallet recognition, KYC-subpoena pathway, Travel Rule data flow
- Court-admissibility framing — Sterlingov / Bitcoin Fog defense, Daubert posture toward heuristic clustering, expert-witness considerations
- Hand-offs to and from sibling SOPs (darkweb observation, malware-analysis IOC pivots, financial / AML, sensitive-crime escalation)

### What this SOP **does not** cover

- **Mixer / privacy-pool / cross-chain-bridge obfuscation tracing.** Routed to [[sop-mixer-tracing|Mixer & Privacy-Pool Tracing]]. CoinJoin clustering attacks, Tornado Cash on-chain heuristics, bridge-laundering deobfuscation, Monero / Zcash shielded-pool research limits, and the regulatory event timeline (Tornado Cash sanctions trajectory, Samourai / Wasabi enforcement) all live there. Bridge **read-flow** is in scope here (§6); deobfuscation is not.
- **Smart-contract source / bytecode audit.** Routed to [[sop-smart-contract-audit|Smart Contract Audit]]. SWC registry, vulnerability classes (reentrancy, access-control, oracle manipulation, MEV, signature replay, delegatecall confusion), formal-verification tooling (Slither, Mythril, Echidna, Foundry, Halmos, Aderyn), and audit-report structure live there. **Post-exploit fund tracing** is in scope here (§11, §18).
- **Buying, transacting, depositing, withdrawing, or "test-sending"** to or from any address under investigation. Even a 1-satoshi probe taints the cluster, alerts the subject, and may create legal exposure. Observation-only.
- **Privacy-coin transparent on-chain tracing.** Monero RingCT and Zcash shielded transactions are not directly traceable; this SOP notes the research literature and the off-chain pivot path (exchange records, IP / timing, transparent-pool reuse, address poisoning) but does not promise tracing.
- **Operational sanctions enforcement.** Identifying SDN exposure is in scope; freezing assets, issuing OFAC licenses, or coordinating asset recovery is the regulator / law-enforcement job. This SOP escalates per §14 / §19.
- **Banking / fiat-side AML.** Corporate registries, UBO mapping, payment-processor research, PEP screening, and adverse-media screening live in [[sop-financial-aml-osint|Financial & AML OSINT]]. This SOP picks up at the on/off-ramp.
- **Solving the wallet-key custody problem.** Cracking, brute-forcing, or social-engineering keys is out of scope and frequently illegal.

### Threat-model framing

The blockchain analyst is observed by:

- **Targets** monitoring for analytics queries that match their wallets (paid alerts on Arkham, Etherscan watchlists, custom WebSocket subscribers).
- **Vendors** who log queries, train labels on customer activity, and may share data with paying customers — query attribution leak is a real OPSEC failure mode.
- **Adversarial counterparties** running address-poisoning campaigns (look-alike addresses crafted to appear in transaction history and mislead clipboard / copy-paste workflows).
- **Defense teams** in eventual prosecutions who will challenge every heuristic, every cluster label, and every vendor-tool inference. The Sterlingov defense (§12) is the canonical roadmap for that challenge.

Three failure modes drive this SOP:

1. **Heuristic-overreach attribution** — treating a cluster label as identity proof rather than a probabilistic finding.
2. **Operational leak** — pasting a target wallet into a logged query surface that ties the investigation to the analyst.
3. **Evidentiary fragility** — building findings on vendor-only data that cannot be independently reproduced under Daubert / equivalent challenge.

---

## 2. Pre-Engagement & Authorization

### 2.1 Authorization checklist

Before any non-trivial query or large-scale collection:

- [ ] Written authorization names blockchain collection / analytics as in-scope, with target wallets / contracts / chains enumerated.
- [ ] Engagement letter or task assignment specifies the deliverable (intel report, evidence package, court submission, regulator filing, ISAC notification) — this drives the evidentiary bar.
- [ ] Sanctions exposure check: confirm the analyst's jurisdiction permits research on designated entities (most permit analytical work; transactional interaction is the prohibited line).
- [ ] Data-protection lawful basis documented per query class (GDPR Art. 6 / Art. 9, UK DPA, CCPA / CPRA — see [[sop-legal-ethics|Legal & Ethics]]).
- [ ] If operating inside a regulated entity (bank, VASP, exchange, broker-dealer, insurer): MLRO / compliance is looped in before findings are externalized.
- [ ] If operating on behalf of law enforcement: chain-of-custody requirements pre-agreed, including hashing (see [[../../Security/Analysis/sop-hash-generation-methods|Hash Generation Methods]]) and tool-version pinning.

### 2.2 Environment prerequisites

- Dedicated investigator workstation or VM (per [[sop-opsec-plan|OPSEC Plan]] §"Environment isolation"). Crypto investigations deserve harder isolation than general OSINT because clipboard contents, browser sessions, and wallet-software residue all leak.
- VPN / Tor for query egress where the analyst's IP should not appear in vendor logs against a target wallet. Some commercial vendors block Tor; use VPN in those cases.
- Burner email + non-attribution accounts for free-tier analytics (Arkham, Breadcrumbs, Etherscan watchlists). Separate per-investigation per [[sop-opsec-plan|OPSEC Plan]] §"Persona discipline."
- **No real wallet software** on the analyst host. If a wallet is required for read-only RPC submission, use a watch-only wallet on a clean profile.
- Time-synchronized host (NTP) — block-time reasoning depends on accurate UTC clocks.
- Disk encryption (LUKS / FileVault / BitLocker) for any persisted query exports, address lists, or cluster artifacts.

### 2.3 Disclosure-ready posture

From the first query, structure for downstream disclosure:

- Per-query log entry — chain, address / tx-hash queried, tool, timestamp UTC, response artifact, SHA-256 — per [[sop-collection-log|Collection Log]].
- Capture **raw on-chain data** (RPC responses, explorer JSON / CSV exports), not just screenshots of vendor-rendered cluster graphs. Vendor renderings can change between sessions; raw on-chain data is independently re-derivable.
- Pin tool versions where the vendor publishes them (Chainalysis Reactor build, TRM Forensics version, Etherscan API endpoint version). Heuristic outputs are version-dependent; reproducibility requires the version stamp.

---

## 3. Multi-Chain Landscape

### 3.1 At-a-glance taxonomy

| Family               | Examples                                                      | Model        | Privacy posture      | Tracing baseline                            |
| -------------------- | ------------------------------------------------------------- | ------------ | -------------------- | ------------------------------------------- |
| Bitcoin / UTXO       | Bitcoin, Litecoin, Bitcoin Cash, Dogecoin                      | UTXO         | Transparent          | Cluster via common-input + change heuristic |
| Ethereum / EVM       | Ethereum, BSC, Polygon, Avalanche C-chain, Sonic (ex-Fantom)   | Account      | Transparent          | Account-balance + internal-tx + token-tx [verify 2026-10-29] |
| EVM L2 (optimistic)  | Arbitrum, Optimism, Base                                       | Account (L2) | Transparent          | Pair via L1 deposit / withdrawal contracts  |
| EVM L2 (ZK)          | zkSync Era, Starknet, Scroll, Linea, Polygon zkEVM             | Account (L2) | Transparent          | Pair via L1 deposit / withdrawal contracts  |
| Non-EVM L1           | Solana, Tron (TRC-20), Aptos, Sui, NEAR, Cosmos (IBC zones)    | Account      | Transparent          | Chain-specific explorers; varied API depth  |
| Other non-EVM L1     | XRPL, Stellar, Cardano, Polkadot relay + parachains            | Mixed (Cardano: EUTXO) | Transparent          | Per-protocol explorer + ledger walk [verify 2026-10-29] |
| Privacy-default      | Monero (XMR), Zcash (z-addresses)                              | Ring / shield | Opaque on-chain      | Off-chain pivots only — see §3.4            |
| Optional-privacy     | Dash (PrivateSend), Decred (mixed)                             | UTXO + opt-in | Mixed                | Reduced clustering on opt-in, plain UTXO otherwise |

### 3.2 What changes when you switch chains

- **UTXO vs account.** UTXO chains (BTC family) require multi-input clustering and change-address detection to merge addresses into a wallet. Account chains (ETH family) treat each address as a wallet by default — clustering merges *addresses controlled by the same actor*, not "outputs that came from the same wallet." Different heuristic toolkit.
- **Token vs native value.** ERC-20 / TRC-20 / SPL token transfers are events emitted by token contracts, not native transfers. Etherscan's "Token Tracker" view, Tronscan's TRC-20 tab, and Solscan's SPL Token tab are required to see the value flow on tokenized chains. USDT (issued natively by Tether on Ethereum, Tron, Solana, Avalanche, TON, Aptos and others per [tether.to](https://tether.to/en/supported-protocols/); BSC and Polygon are not on Tether's USD₮ list, so USDT there is a bridged / pegged representation) is the dominant cross-chain stablecoin and frequent obfuscation vehicle. [verify 2026-10-29]
- **Internal transactions.** EVM "internal" transactions are contract-call value transfers that do not appear in the top-level transaction list — they live in trace logs. Etherscan shows them under the "Internal Txns" tab; missing them misses contract-mediated flows.
- **L2 finality and bridging.** Optimistic rollups have a 7-day challenge window before withdrawals finalize on L1; ZK rollups finalize on each proof submission. Withdrawal flows therefore have very different on-chain timing patterns. [verify 2026-10-29]
- **Block time and reorgs.** BTC ~10 min, ETH ~12 s, Solana ~200 ms since 2026-10-09 (stepped down from 400 ms under SIMD-0525: 350 ms from 2026-08-21, 300 ms from 08-28, 250 ms from 09-18 — use the step dates when converting historical slots to wall-clock time), BSC ~0.45 s (down from 3 s via the Lorentz, Maxwell and Fermi hardforks). Reorg risk for finality varies; for evidence purposes, wait for confirmations matching the chain's finality convention (BTC 6, ETH 32 / 2 epochs for finality, Solana `finalized` = 31+ confirmed blocks built on top under Tower BFT — under Alpenglow `confirmed` and `finalized` are equivalent, etc.). [verify 2026-10-29]

### 3.3 Transparent vs privacy postures

Most chains are pseudonymous-but-transparent — every transaction, value, sender, recipient, and (on EVM) event log is in the public ledger forever. "Privacy" comes from *not knowing which real person controls a given address.* Investigation is fundamentally an attribution exercise.

Privacy-default chains are the exception:

- **Monero (XMR)** — RingCT (ring signatures + Pedersen commitments + stealth addresses). On-chain inputs ambiguous within a ring; values blinded; recipient one-time stealth addresses. Public reverse-engineering of Monero clustering has limited published success; assume on-chain tracing is **not** feasible for current ring sizes (16 by default, post-Bulletproofs+). [verify 2026-10-29]
- **Zcash (z-addresses)** — sapling / orchard shielded pool. Shielded → shielded transactions are private; the bulk of historical Zcash usage is transparent (t-addresses) or shielded-to-transparent (z→t), which leaks the egress. Research (Quesnelle 2017; Kappos et al. 2018) showed that most coins sent to shielded addresses later return to transparent addresses and that simple usage-pattern heuristics shrink the shielded anonymity set considerably. [verify 2026-10-29]

### 3.4 When the chain itself is opaque

Off-chain pivots are the only practical path:

- **Exchange records** via subpoena / regulatory request when the analyst's jurisdiction permits, or via voluntary cooperation under Travel Rule between VASPs.
- **IP / timing correlation** — public mempool nodes, eclipse-attack research, IXP-level visibility (rare but documented). Out of scope for OSINT.
- **Address reuse on transparent chains.** Many investigations of XMR / Zcash actors hinge on a parallel transparent address (the actor's BTC or ETH wallet), not on the privacy chain itself.
- **OPSEC failures of the user.** The actor's clearnet account, social handle, or reused PGP key (see [[sop-darkweb-investigation|Darkweb Investigation]] §6) is more often the attribution path than the chain.
- **Address poisoning detection** — a class of attack where a near-look-alike address appears in the target's history. Investigators can sometimes use poison-attempt patterns to fingerprint attacker tooling. (Not a tracing technique against the privacy chain itself.)

---

## 4. Blockchain Explorers & Public Data

### 4.1 Per-chain canonical explorers

| Chain                  | Primary explorer                                       | Notes                                                                |
| ---------------------- | ------------------------------------------------------ | -------------------------------------------------------------------- |
| Bitcoin                | [mempool.space](https://mempool.space/)                | Best mempool view, fee-rate analytics, address page rich             |
| Bitcoin (alt)          | [blockchair.com](https://blockchair.com/bitcoin)       | Multi-chain comparator, CSV export, advanced search                  |
| Bitcoin (legacy)       | [blockchain.com/explorer](https://www.blockchain.com/explorer) | Long-standing, lighter address-cluster surface                |
| Bitcoin Cash           | [blockchair.com/bitcoin-cash](https://blockchair.com/bitcoin-cash) | Same UI as BTC                                          |
| Litecoin               | [blockchair.com/litecoin](https://blockchair.com/litecoin) | Same UI                                                          |
| Dogecoin               | [blockchair.com/dogecoin](https://blockchair.com/dogecoin) | Same UI                                                          |
| Ethereum               | [etherscan.io](https://etherscan.io/)                  | Reference EVM explorer; internal-tx + token-tx tabs essential        |
| Ethereum (alt)         | [blockscout.com](https://www.blockscout.com/)          | Open-source; multi-chain deployments                                |
| BSC                    | [bscscan.com](https://bscscan.com/)                    | Etherscan-family                                                     |
| Polygon                | [polygonscan.com](https://polygonscan.com/)            | Etherscan-family                                                     |
| Arbitrum               | [arbiscan.io](https://arbiscan.io/)                    | Etherscan-family; check L1 deposit pairing                           |
| Optimism               | [optimistic.etherscan.io](https://optimistic.etherscan.io/) | Etherscan-family                                                |
| Base                   | [basescan.org](https://basescan.org/)                  | Etherscan-family                                                     |
| Avalanche C-chain      | [snowtrace.io](https://snowtrace.io/)                  | Routescan-operated (Etherscan deployment retired 2023-11-30); Etherscan V2 API covers chainid 43114 on paid plans only [verify 2026-10-29] |
| Solana                 | [solscan.io](https://solscan.io/) / [solana.fm](https://solana.fm/) | SPL token + program-call surfaces                       |
| Tron                   | [tronscan.org](https://tronscan.org/)                  | Critical for USDT-TRC20 flows                                        |
| XRPL                   | [xrpscan.com](https://xrpscan.com/) / [bithomp.com](https://bithomp.com/) | Account flagging, destination-tag analysis           |
| Cardano                | [cardanoscan.io](https://cardanoscan.io/)              | EUTxO model — different clustering shape                             |
| Polkadot               | [polkadot.subscan.io](https://polkadot.subscan.io/)    | Substrate-based; parachains have their own subscan deployments       |
| Cosmos hubs            | [mintscan.io](https://www.mintscan.io/)                | Multi-chain Cosmos / IBC                                             |
| NEAR                   | [nearblocks.io](https://nearblocks.io/)                | Account-based                                                        |
| Aptos / Sui            | [aptoscan.com](https://aptoscan.com/) / [suiscan.xyz](https://suiscan.xyz/) | Move-based chains                                       |

[verify 2026-10-29 — explorer URL stability]

### 4.2 Multi-chain aggregators

- **[Blockchair](https://blockchair.com/)** — universal search across BTC, ETH, BCH, LTC, DOGE, XLM, XRP, etc.; CSV export; query API (free tier rate-limited).
- **[Etherscan family](https://etherscan.io/)** — single login covers most EVM chains (ETH, BSC, Polygon, Arbitrum, Optimism, Base, Avalanche, Sonic, Linea, Gnosis, Mantle, etc.); V2 unified API — one key plus a `chainid` parameter on `https://api.etherscan.io/v2/api`; current chain list at [api.etherscan.io/v2/chainlist](https://api.etherscan.io/v2/chainlist) — the free tier covers only some chains (BSC, Base, OP, Avalanche and Gnosis need a paid plan; free keys get "Free API access is not supported for this chain"); check the tier column on [docs.etherscan.io/supported-chains](https://docs.etherscan.io/supported-chains). [verify 2026-10-29]
- **[Arkham](https://platform.arkhamintelligence.com/)** — entity-labeled multi-chain explorer with profile pages on labeled wallets (DeFi protocols, exchanges, named individuals); login required — confirm current access tiers and terms per engagement.
- **[DeBank](https://debank.com/)** — DeFi-portfolio aggregation per address across EVM chains; useful for "what is this wallet exposed to?" surface. [verify 2026-10-29]
- **[Zapper](https://zapper.xyz/)** — similar DeFi aggregation surface. [verify 2026-10-29]
- **[OnChainFX](https://messari.io/)** / **Messari** — protocol-level metrics; complement transaction-level work. [verify 2026-10-29]

### 4.3 Public data feeds

- **Node-level RPC** — running a local archive node (Bitcoin Core full node + index, Erigon / Reth for Ethereum) gives query-side independence from explorers and removes the third-party log surface. High disk cost; appropriate for sustained investigation.
- **Public RPC endpoints** — Infura, Alchemy, QuickNode, Ankr publish RPC for major chains; useful for ad-hoc queries; logs requests against API keys (treat as an attribution surface).
- **Indexer APIs** — [The Graph](https://thegraph.com/), Subsquid, Goldsky for protocol-specific indexed data; less useful for raw tracing, more useful for protocol context. [verify 2026-10-29]
- **Bulk data dumps** — [Google BigQuery blockchain datasets](https://docs.cloud.google.com/blockchain-analytics/docs/supported-datasets) host Bitcoin, Ethereum, Arbitrum, Avalanche, Base, Optimism, Polygon, Tron, Solana and others (BCH, LTC, DOGE, ZEC are not on the current list); ideal for SQL-style analytics on years of history at low marginal cost. Google publishes no refresh cadence — record the dataset snapshot date. [verify 2026-10-29]
- **Whale-alert / monitoring feeds** — [whale-alert.io](https://www.whale-alert.io) for large-transfer notifications; useful for situational awareness, not as primary evidence. [verify 2026-10-29]

---

## 5. Address Clustering Heuristics

Clustering merges multiple on-chain addresses into a single hypothesized actor. Every heuristic is **probabilistic**; document confidence and the heuristic basis when reporting.

### 5.1 Common-input ownership (BTC / UTXO)

- **Heuristic:** addresses appearing as inputs in the same transaction are jointly controlled by the spender (common-input ownership).
- **Origin:** Meiklejohn et al. 2013 ("A Fistful of Bitcoins") — foundational paper formalizing this and other Bitcoin heuristics. [verify 2026-10-29]
- **Failure modes:** CoinJoin transactions (Wasabi, Samourai Whirlpool, JoinMarket) deliberately violate the assumption — multiple unrelated parties contribute inputs. Vendor tools mark CoinJoin transactions specifically; do not common-input-merge through them. PayJoin (BIP 78) similarly violates the heuristic. [verify 2026-10-29]
- **Evidentiary weight:** moderate-to-high outside of CoinJoin contexts; commercial-tool clusters built on this assumption carry decades of operational confirmation but have been challenged in court (see §12).

### 5.2 Change-address detection (BTC / UTXO)

- **Heuristic:** of the outputs in a transaction, one is the recipient and one is "change" returning to the spender. Several sub-heuristics identify the change output:
  - **Fresh-address heuristic** — change goes to a previously-unseen address.
  - **Round-number heuristic** — recipient amount is a "human" round number; change is the remainder.
  - **Script-type heuristic** — change matches the input script type (P2PKH inputs → P2PKH change; P2WPKH inputs → P2WPKH change). Wallet software preserves type for change.
  - **Output-position heuristic** — many wallets place change first or last consistently.
- **Combination:** no single sub-heuristic is reliable in isolation; vendors combine multiple. Open-source frameworks (BlockSci, GraphSense) document their combinations.
- **Failure modes:** mixers, batched payment processors, exchange-internal sweeps, and modern wallet software with deliberate change-pattern obfuscation (Wasabi, Samourai) all break individual sub-heuristics. zkSNACKs closed Wasabi's default coinjoin coordinator 2024-06-01 and Samourai's servers were seized 2024-04-24; their historical transactions still break the heuristics. [verify 2026-10-29]

### 5.3 Peeling chains (BTC / ETH)

- **Pattern:** a single large balance is repeatedly split into a small "peel" payment + the remaining balance, often hopping through fresh addresses each step.
- **Indicator:** chain of transactions where one output is small and one output is large; the large output becomes the next transaction's input.
- **Use:** a peel chain on the receiving side of a known illicit address suggests structuring or wallet-internal sweeping. Length and rhythm are signal — automated peel chains are very regular; manual ones are not.

### 5.4 Account clustering (ETH / EVM)

- **Heuristic:** EVM addresses controlled by the same EOA (externally owned account) cluster around interaction patterns:
  - **Common-funding heuristic** — a single funding source (often a CEX hot wallet) deposits into multiple addresses; if those addresses then transact among themselves, they likely share a controller.
  - **Gas-payer heuristic** — a sponsor address pays gas for multiple recipients (especially with EIP-4337 account abstraction or sponsored-transaction patterns) — gas-payer is not necessarily the controller, but is a strong signal. [verify 2026-10-29]
  - **Token-approval heuristic** — addresses that grant unlimited token approvals to the same contract pair are probably operationally linked.
  - **Reused method-call patterns** — wallet "fingerprints" via the sequence of contract calls (DeFi-protocol routing, NFT mint patterns).
- **Cluster shape:** account chains rarely produce the dense merge you see on UTXO chains; clusters are often graph neighborhoods, not single super-clusters.

### 5.5 Exchange-deposit clustering

- **Pattern:** centralized exchanges issue per-customer deposit addresses. Funds deposited into a customer's address are swept into the exchange's hot-wallet system shortly after.
- **Identification:** the deposit address has one or two inflows and a single outflow to a known exchange hot-wallet cluster.
- **Use:** identifying that a target's funds entered via a specific exchange deposit address links the target to a (subpoena-able) exchange account. The exchange holds the KYC.
- **Caveat:** some exchanges (especially those using shared addresses with destination tags — XRPL, Stellar, EOS) do **not** issue per-customer addresses; the destination tag / memo carries customer routing.

### 5.6 Confidence framework

For every clustered finding, record:

- **Heuristic basis** — which heuristic(s) merged the addresses.
- **Counter-evidence** — does any transaction in the cluster contradict the merge (e.g., a known CoinJoin)?
- **Independent corroboration** — does a second source (vendor tool, open-source clusterer, off-chain pivot) agree?
- **Confidence label** — Low / Medium / High per [[sop-entity-dossier|Entity Dossier]] §"Confidence Rating."

A cluster label without these four data points is intelligence, not evidence. The Sterlingov defense (§12) attacked vendor labels precisely on these axes.

---

## 6. Cross-Chain Bridge Tracing (Read-Flow)

This section covers **reading what a bridge did** — pairing a source-chain event with the destination-chain event so the value flow is reconstructed across chains. Defeating bridge-mediated obfuscation (rapid hops, staged splits, deliberate routing through bridges with weak attribution) is the [[sop-mixer-tracing|Mixer & Privacy-Pool Tracing]] scope.

### 6.1 The bridge-as-event-pair model

Every cross-chain bridge fundamentally executes:

1. Source chain — value is **locked** in a bridge contract or **burned** by a wrapped-asset contract.
2. Off-chain consensus — guardians, validators, MPC committee, or zk-proof system attest to the source event.
3. Destination chain — wrapped or native asset is **minted** or **released** by the destination bridge contract.

The investigator's job: pair the source `lock`/`burn` log with the destination `mint`/`release` log so the on-chain graph extends across chains.

### 6.2 Major bridge protocols and their event signatures

| Protocol               | Source-side event                                | Destination-side event                          | Pairing key                                       |
| ---------------------- | ------------------------------------------------ | ----------------------------------------------- | ------------------------------------------------- |
| Wormhole               | `LogMessagePublished` from core bridge            | `TransferRedeemed` on destination               | Sequence number + emitter chain + emitter addr [verify 2026-10-29] |
| LayerZero (v1 / v2)    | `Packet` (v1) / `PacketSent` (v2)                | `PacketReceived` (v1) / `PacketVerified` → `PacketDelivered` (v2) | Nonce + src chain + dst chain + sender / receiver [verify 2026-10-29] |
| Stargate (LayerZero-based) | OFT / pool token transfer                     | OFT mint on destination                         | LayerZero nonce + Stargate pool ID [verify 2026-10-29] |
| Synapse                | `TokenDeposit` / `TokenRedeem` on bridge router  | `TokenMint` / `TokenWithdraw` on destination    | Nonce + kappa hash [verify 2026-10-29] |
| Across                 | `FundsDeposited` from spoke pool                  | `FilledRelay` (relayer fills)                  | Deposit ID + source chain + destination chain [verify 2026-10-29] |
| THORChain              | Inbound observation TX                            | Outbound observation TX                         | Inbound TX hash → outbound TX hash via Midgard / THORNode |
| Hop                    | `TransferSent` on source                          | `TransferFromL1Completed` / bonder relay        | Transfer ID [verify 2026-10-29] |
| cBridge (Celer)        | `Send` event                                      | `Relay` event                                   | Transfer ID [verify 2026-10-29] |
| Multichain (deprecated) | `LogAnySwapOut`                                  | `LogAnySwapIn`                                  | Swap ID (multichain dissolved 2023; legacy bridges still queryable) [verify 2026-10-29] |
| Ronin Bridge (Axie)    | `DepositRequested` on Ethereum                    | `Deposited` on Ronin                            | Receipt ID / `receiptHash` [verify 2026-10-29] |
| Polygon PoS bridge     | `LockedERC20` + `StateSynced` on Ethereum         | `StateCommitted` (StateReceiver) + child-token `Transfer` from `0x0` on Polygon | State-sync ID (`StateSynced.id` = `StateCommitted.stateId`) [verify 2026-10-29] |
| Arbitrum native bridge | `OutBoxTransactionExecuted` (withdrawal) / `MessageDelivered` (deposit) | matching L1 / L2 events             | Message index + sequencer batch [verify 2026-10-29] |
| Optimism native bridge | `SentMessage` / `RelayedMessage`                  | matching cross-domain message                  | Message hash [verify 2026-10-29] |
| Hyperlane              | `Dispatch`                                        | `Process`                                       | Message ID + origin domain + destination domain [verify 2026-10-29] |

[verify 2026-10-29 — bridge contract addresses, event names, and protocol versions update frequently; treat the table as a starting point and verify event signature against the deployed contract before reporting.]

### 6.3 Practical pairing workflow

1. **Identify the bridge** by the source-side contract address. The bridge protocol's documentation lists official deployments per chain. Phishing / spoofed bridges exist; verify the contract address against the canonical list.
2. **Decode the source event** — extract the recipient (destination chain + destination address), value, token, and unique sequence / nonce / deposit ID.
3. **Locate the destination chain.** Bridge events typically encode the destination chain ID; look up the matching deployment.
4. **Search the destination contract** for the matching event using the sequence / nonce / deposit ID. Most bridges expose an indexer (Wormhole's [wormholescan.io](https://wormholescan.io/), LayerZeroscan (covers Stargate), THORChain's [thorchain.net](https://thorchain.net/) or Midgard).
5. **Document both events** — source TX hash, destination TX hash, value, token, sequence ID. Capture the bridge indexer page if used.
6. **Continue the trace on the destination chain.** The destination event identifies the receiving address; that address becomes the next clustering / pivot target.

### 6.4 Bridge-specific pitfalls

- **Wormhole signature-verification exploit (2022-02-02):** a bug in the Solana core contract's guardian-signature check let the attacker mint 120,000 unbacked wETH on Solana; destination-side mint exists with no legitimate source-side event. Always confirm the source-side event actually exists. [verify 2026-10-29]
- **Multichain (Anyswap) collapse (July 2023):** assets stranded; cross-references to legacy Multichain transfers may dead-end at the protocol's failure date. Note the protocol-status at observation time.
- **Ronin validator compromise (2022-03-23):** 173,600 ETH + 25.5M USDC drained via compromised Sky Mavis and Axie DAO validator keys (≈$620M per the FBI); the drain transactions are bridge withdrawals signed with the stolen keys, with no legitimate withdrawal request behind them. FBI attributed the theft to DPRK (Lazarus / APT38); OFAC added the exploiter address to the Lazarus Group SDN entry 2022-04-14. [verify 2026-10-29]
- **Nomad bridge exploit (2022-08-01):** "free-for-all" replay of a routine event after an initialization bug; subsequent in-and-out flows on both chains do not represent legitimate user transfers. [verify 2026-10-29]
- **Bridge nonce collisions** (rare) — protocol versions or chain redeployments can produce duplicate sequence numbers; always disambiguate by chain-of-deployment + version.
- **Wrapped-asset reuse.** A single user transferring `wBTC` on Ethereum, bridging to Polygon, swapping to USDC on Polygon, bridging USDC to Arbitrum — produces five contract-event pairs to follow. Tooling that stops at the first hop loses the trail.

### 6.5 Useful bridge indexers

- [wormholescan.io](https://wormholescan.io/) — Wormhole transfers, queryable by sequence, token, address, chain pair. [verify 2026-10-29]
- [layerzeroscan.com](https://layerzeroscan.com/) — LayerZero packets across deployed chains. [verify 2026-10-29]
- [thorchain.net](https://thorchain.net/) / [Midgard v2 API](https://gateway.liquify.com/chain/thorchain_midgard/v2/doc) — THORChain swaps with inbound / outbound TX pairing (Midgard endpoint as listed in docs.thorchain.org). [verify 2026-10-29]
- [bungee.exchange](https://www.bungee.exchange/) (Socket) and [li.fi explorer](https://li.fi/) — multi-bridge / multi-DEX route surfaces; useful for understanding which bridges a route used. [verify 2026-10-29]
- [Across explorer](https://across.to/) — Across deposit / fill explorer. [verify 2026-10-29]
- [Hop](https://hop.exchange/) — Hop bridge UI; the hosted explorer (`explorer.hop.exchange`) returns 404 and its repo is archived — pair `TransferSent` / `TransferFromL1Completed` events directly. [verify 2026-10-29]
- [Stargate](https://stargate.finance/) — Stargate (LayerZero) flows. [verify 2026-10-29]

---

## 7. Sanctions Integration

### 7.1 OFAC SDN Digital Currency Address (DCA) regime

- **Authority:** US Treasury Office of Foreign Assets Control (OFAC) administers the Specially Designated Nationals (SDN) list. Since 2018, individual cryptocurrency addresses have been listed as DCA entries appended to SDN profiles, tagged by currency code (`XBT`, `TRX`, `ETH`, `USDT`, `USDC`, `XMR`, `BSV`, `ZEC`, `LTC`, `DASH`, `ETC`, `XRP`, etc.; long entries overflow into `SDN_COMMENTS.CSV`, so screen both files). [verify 2026-10-29]
- **Source feeds:**
  - HTML search: [sanctionssearch.ofac.treas.gov](https://sanctionssearch.ofac.treas.gov/) [verify 2026-10-29]
  - Bulk data: [OFAC sanctions list service](https://sanctionslist.ofac.treas.gov/Home/SdnList) (XML / CSV / fixed-width / PDF) [verify 2026-10-29]
  - File finder (legacy): [ofac.treasury.gov/file-finder](https://ofac.treasury.gov/file-finder) [verify 2026-10-29]
- **Investigative use:**
  - Screen every wallet observed in scope against the latest SDN feed (cache locally; refresh daily for active investigations).
  - Cluster screening — if any address in a cluster matches SDN, the **wallet** is sanctions-implicated; report cluster membership with evidence.
  - **Time-stamp every sanctions finding.** Designations are added and removed; the legal posture at the time of activity is what matters.
- **Notable trajectory: Tornado Cash.** Listed 2022-08-08 (the first smart-contract address designations); contested in court; 5th Circuit *Van Loon v. Treasury* ruled 2024-11-26 that immutable smart contracts are not "property" subject to OFAC blocking; Treasury removed the Tornado Cash sanctions 2025-03-21. Tornado Cash addresses post-delist are no longer SDN, but historical activity during the listed period remains a sanctions exposure. [verify 2026-10-29]

### 7.2 EU sanctions and TFR / MiCA

- **EU consolidated list:** [sanctionsmap.eu](https://www.sanctionsmap.eu/) (consolidated EU restrictive measures); [EU Financial Sanctions Database](https://webgate.ec.europa.eu/fsd/fsf) (machine-readable). [verify 2026-10-29]
- **Transfer of Funds Regulation (TFR) / MiCA crypto-asset transfer rules:** since 2024-12-30, all crypto-asset transfers between Crypto-Asset Service Providers (CASPs) must carry originator and beneficiary information regardless of value (no de minimis). Self-hosted-wallet transfers above EUR 1,000 trigger additional verification by the CASP. [verify 2026-10-29]
- **MiCA broader:** Markets in Crypto-Assets Regulation (Regulation (EU) 2023/1114); Titles III–IV (asset-referenced and e-money token issuers) apply from 30 June 2024; everything else, including CASP authorisation, from December 2024. Cross-border CASP supervision is via the home-state regulator with EBA / ESMA oversight. [verify 2026-10-29]

### 7.3 UK OFSI and other regimes

- **UK:** the [UK Sanctions List](https://www.gov.uk/government/publications/the-uk-sanctions-list) (FCDO) is the only source of UK designations since 2026-01-28, replacing the OFSI Consolidated List; FCA supervises crypto-AML registration under the Money Laundering Regulations 2017 (as amended). [verify 2026-10-29]
- **UN:** UN Security Council [consolidated list](https://main.un.org/securitycouncil/en/sanctions/information). [verify 2026-10-29]
- **Other major regimes:** Canada (OSFI / Global Affairs), Australia (DFAT consolidated list), Switzerland (SECO), Japan (MOF), Singapore (MAS), South Korea (FIU).
- **OpenSanctions** ([opensanctions.org](https://www.opensanctions.org/)) aggregates the major lists and publishes a normalized data feed; useful for cross-jurisdiction screening. [verify 2026-10-29]

### 7.4 FATF Travel Rule (Recommendation 16)

- Virtual Asset Service Providers (VASPs) — exchanges, custodial wallets, OTC desks — are required by FATF Recommendation 16 to collect and transmit originator / beneficiary information for crypto transfers above a jurisdiction-specific threshold. [verify 2026-10-29]
  - **US (FinCEN):** USD 3,000 threshold (31 CFR 1010.410(f)); the 2020 FinCEN / Federal Reserve proposal to cut it to USD 250 for cross-border transfers (85 FR 68005, RIN 1506-AB41) is recorded as withdrawn 2025-04-16 in the Unified Agenda. [verify 2026-10-29]
  - **EU (TFR / MiCA):** No de minimis on inter-CASP transfers from 2024-12-30; self-hosted threshold EUR 1,000. [verify 2026-10-29]
  - **UK (FCA; MLRs 2017 reg. 64C):** no de minimis for the basic payload (originator / beneficiary names and account numbers, or a unique transaction identifier). Where any business in the chain is outside the UK, one further originator identifier must also accompany transfers ≥ £800 (linked transfers aggregated); £800 replaced EUR 1,000 from 2026-06-30 (SI 2026/621 reg. 32). [verify 2026-10-29]
  - **Singapore / Switzerland / Japan / South Korea:** thresholds and protocols vary; check the local FIU guidance.
- **Implementations:** IVMS101 is the common data-model standard; open protocols include TRP; commercial networks include Sygna Bridge, Notabene and Shyft Veriscope. Vendor lineup shifts; verify per engagement. [verify 2026-10-29]
- **Investigative use:** Travel Rule data is **not public** — it is held by participating VASPs. Subpoena / regulator request to a VASP can produce both the KYC record and the Travel Rule originator data. Knowing which VASPs participate in which networks shapes the request strategy.

### 7.5 Sanctions tradecraft

- **DCA matches are time-stamped facts.** Record the activity timestamp **and** the SDN-list state at that time. Sterlingov (§12) and the Tornado Cash trajectory both highlight time-of-activity vs time-of-report distinctions.
- **Cluster screening, not address screening.** A target wallet may not be SDN-listed itself but may belong to a cluster containing SDN addresses; that is sanctions exposure.
- **Layering through bridges.** Cross-chain bridge usage to launder out of an SDN-listed source does not break the sanctions taint under most regimes; report the routing and the jurisdictional implications.
- **Secondary sanctions exposure** — non-US persons facilitating SDN-designated counterparties can themselves attract enforcement. Compliance teams should treat SDN matches as escalations, not as routine alerts.

---

## 8. Commercial Analytics Tools

Commercial blockchain analytics tools provide cluster labels, entity attribution, risk scores, and case-management surfaces that significantly accelerate investigations. They are also expensive, opaque (proprietary heuristics), and have specific evidentiary limitations explored in §12.

### 8.1 Major vendors

- **[Chainalysis](https://www.chainalysis.com/)** — market-leading; products include **Reactor** (case-based investigation interface), **Rapid** (triage), **Wallet Scan** (seed-phrase asset discovery), **KYT** (transaction monitoring for VASPs / banks), **Address Screening** / **VASP Risking** (compliance), and **Alterya** (fraud prevention). Heaviest LE / regulator adoption. Defense bar has scrutinized Reactor heuristics in court (Sterlingov, §12). [verify 2026-10-29]
- **[TRM Labs](https://www.trmlabs.com/)** — TRM Forensics (investigation); wallet screening, real-time transaction monitoring and entity-risk products (compliance). Strong LE adoption, especially US federal. [verify 2026-10-29]
- **[Elliptic](https://www.elliptic.co/)** — Elliptic Investigator, Lens, Discovery. Strong UK / EU adoption. [verify 2026-10-29]
- **[Crystal Intelligence](https://crystalintelligence.com/)** — Bitfury-origin (developed inside Bitfury from 2015, public launch 2018); rebranded Crystal Intelligence 2024; Tether strategic investment 2025. Multi-chain analytics + sanctions screening. [verify 2026-10-29]
- **[Arkham](https://www.arkhamintelligence.com/)** — entity-labeled platform with a bounty marketplace (Intel Exchange) for attribution data; login required — confirm current access tiers per engagement. Treat labels as crowdsourced intelligence (variable quality), not vendor-attested attribution.
- **[Merkle Science](https://www.merklescience.com/)** — Tracker (investigation), Compass (VASP compliance). [verify 2026-10-29]
- **[Nansen](https://www.nansen.ai/)** — primarily DeFi analytics with smart-money labeling; useful for context, not core tracing. [verify 2026-10-29]

### 8.2 What commercial tools are good at

- **Pre-built clusters** spanning years of activity — replicating these from raw data takes weeks of work per cluster.
- **Entity labels** for thousands of exchanges, mixers, DeFi protocols, ransomware groups, scam infrastructure.
- **Risk scoring** for compliance workflows (KYT-style alerts at deposit / withdrawal time).
- **Case management** — investigation graphs, notes, sharing, audit trail.
- **Cross-chain views** in a single UI without manual chain-hopping.

### 8.3 What commercial tools are not good at

- **Reproducibility under adversarial scrutiny.** Vendor heuristics are proprietary and version-dependent. A defense expert cannot "rerun the analysis" the same way — only audit the vendor's documented method.
- **Edge cases and novel protocols.** New bridges, new privacy primitives, novel obfuscation patterns lag in tooling support. Open-source workflows are often faster on the bleeding edge.
- **Attribution beyond their telemetry.** Vendor knows what their telemetry knows; targets that have not interacted with vendor-instrumented surfaces may be mislabeled or unlabeled.
- **Independence in evidentiary contexts.** Relying solely on vendor output without independent corroboration is the brittleness exposed in §12.

### 8.4 Vendor-tradecraft discipline

- **Document the tool, version, query, and timestamp** for every vendor-derived finding.
- **Capture the underlying transaction data** alongside the cluster label. The transactions are facts; the cluster is the interpretation.
- **Cross-check with a second tool or open-source method** before publishing high-stakes findings.
- **Note the heuristic basis** in the vendor's documentation. Vendor methodology papers (Chainalysis publishes some; others are sparser) are the basis for cross-examination.
- **Be explicit about confidence.** Vendor "high-confidence" cluster labels are still heuristic; report them as such.

### 8.5 Discontinued / changed tools (situational awareness)

- **CipherTrace** — acquired by Mastercard 2021; Armada / Inspector / Sentry products discontinued March 2024. Treat any contemporary "CipherTrace" reference as legacy. [verify 2026-10-29]
- **Wallet Explorer** — long-standing free Bitcoin clustering site by Aleš Janda, who later joined Chainalysis (the site itself was not acquired); still online at [walletexplorer.com](https://www.walletexplorer.com/), but its wallet-name database has not been updated since 2016 and chain data lags 1–2 days. [verify 2026-10-29]
- **OXT.me** — Samourai-affiliated open Bitcoin analytics; offline (oxt.me does not respond) following the April 2024 Samourai enforcement action; Samourai's founders were sentenced November 2025. Treat as defunct. [verify 2026-10-29]
- **Coinfirm** — acquired by Lukka (announced 2024-05-21); coinfirm.com no longer responds. Treat contemporary references as legacy. [verify 2026-10-29]

---

## 9. Open-Source Analytics Workflows

Open-source tooling does not match commercial coverage, but it is **independently reproducible** — a critical evidentiary property (§12).

### 9.1 GraphSense

- **What it is:** Open-source crypto-asset analytics platform (AIT / Iknaio). Multi-chain support (BTC, BCH, LTC, ZEC, ETH). [verify 2026-10-29]
- **What it gives you:** Clustering, attribution tags, transaction graph, neighborhood analytics — same conceptual model as commercial tools.
- **Where:** [graphsense.info](https://graphsense.info/) [verify 2026-10-29]; documentation and self-hosted deployment guides available.
- **Tradeoff:** Significant infrastructure overhead (full-node ingest, ETL pipeline). Pays off for sustained investigation; overkill for one-off lookups.

### 9.2 Breadcrumbs

- **What it is:** Free-tier blockchain visualization with address labeling and graph navigation.
- **Where:** [breadcrumbs.app](https://www.breadcrumbs.app/) [verify 2026-10-29 — site bot-walled (HTTP 403); no shutdown notice found]
- **Use case:** Quick visual investigation, sharing graphs with non-analyst stakeholders.

### 9.3 BlockSci-style direct ledger queries

- **BlockSci** (Kalodner et al., Princeton; USENIX Security 2020 — full author list in §21) — academic Bitcoin analytics framework. GitHub repo inactive since 2021; replaced in many workflows by direct BigQuery / Erigon-traces / Reth queries. [verify 2026-10-29]
- **Approach:** Run a full archive node (Bitcoin Core + index, Erigon for ETH) and query directly. Highest fidelity, highest setup cost.
- **BigQuery alternative:** Google's [blockchain datasets](https://docs.cloud.google.com/blockchain-analytics/docs/supported-datasets) (Bitcoin, Ethereum, Polygon, Arbitrum, Optimism, Base, Avalanche, Tron, Solana and others) support SQL analytics over years of history; no refresh cadence is published, so record the snapshot date. [verify 2026-10-29]

### 9.4 Manual workflow with explorers + scripts

- For small investigations, the explorer-scrape + CSV-export + Python notebook workflow is sufficient.
- Etherscan, Blockchair, Tronscan, Solscan all expose CSV export and / or API endpoints (rate-limited; key required for higher tiers).
- Common library combinations: `web3.py` / `ethers.js` for EVM RPC, `python-bitcoinrpc` for Bitcoin RPC, `solana-py` for Solana, custom clients for Tron and others. [verify 2026-10-29]
- Notebook discipline: capture the input addresses, the queries, the responses, and the analytical reasoning. Notebooks are reproducible artifacts.

### 9.5 Address-labeling collaborative resources

- **[OFAC SDN](https://sanctionssearch.ofac.treas.gov/)** — sanctions addresses (authoritative for sanctions; use bulk feed). [verify 2026-10-29]
- **[Chainabuse](https://www.chainabuse.com/)** — community scam / abuse reporting. [verify 2026-10-29]
- **[Etherscan label cloud](https://etherscan.io/labelcloud)** — public labels for ETH / EVM addresses. [verify 2026-10-29]
- **[Arkham](https://platform.arkhamintelligence.com/)** — entity labels with crowdsourced bounty additions (variable provenance).
- **[Solscan labels](https://solscan.io/)** — Solana entity labels.
- **GitHub repos** — multiple analyst-maintained labeled-address lists (use with caution; vintage and provenance vary).

### 9.6 Reproducibility checklist

For any open-source workflow finding:

- [ ] Input addresses / transaction IDs documented.
- [ ] Tool versions captured (node version, library version, BigQuery dataset snapshot date).
- [ ] Query / script saved and hash-stamped.
- [ ] Response data captured (CSV / JSON exports).
- [ ] Analytical notes capture *why* a conclusion follows from the data, not just what the conclusion is.
- [ ] The artifact bundle survives the analyst leaving the project.

---

## 10. Exchange & VASP Pivots

Most illicit crypto flows eventually touch a VASP — fiat off-ramps require regulated entities in nearly every jurisdiction. The VASP pivot is often where investigation transitions from open-source to legal-process.

### 10.1 Recognizing exchange flow

- **Hot-wallet recognition:** centralized exchanges operate hot wallets that are heavily transacted. Vendor tools tag them; open-source clustering identifies them by transaction volume + characteristic transaction shapes.
- **Deposit-address pattern:** per-customer deposit addresses receive one or two inflows then sweep to the exchange hot wallet within hours.
- **Withdrawal-address pattern:** exchanges withdraw to user-specified addresses from hot-wallet treasury; withdrawals carry the exchange's signature transaction shape.
- **Memo / tag chains** (XRPL, Stellar, EOS, Cosmos): single shared address with destination tag / memo per customer. Tag-based pivots require subpoena to the VASP for tag-to-customer mapping.

### 10.2 Documenting an exchange pivot

For each exchange-side finding:

- **Exchange identification** — which VASP, which jurisdiction, which regulator (FCA, FinCEN, BaFin, MAS, etc.).
- **Address evidence** — the specific deposit / withdrawal address tied to the VASP cluster, with cluster basis.
- **Time window** — when the activity occurred (relevant for KYC vintage and for VASP retention windows).
- **Transaction list** — TX hashes, values, tokens.
- **Travel Rule applicability** — was the transfer above the originating-jurisdiction threshold? Was the destination a participating VASP? This shapes the data the VASP holds.

### 10.3 Subpoena / regulator pathway

- **US:** FinCEN MSB registration (money transmitters incl. VASPs; banks are excluded from the MSB definition); subpoena via DOJ, IRS-CI, FBI; international via MLAT. [verify 2026-10-29]
- **EU:** CASP authorisation under MiCA (ESMA register of authorised CASPs); data requests via national FIU + Europol; cross-border via judicial cooperation regulations. [verify 2026-10-29]
- **UK:** FCA register; SAR via NCA; international via MLAT.
- **Process discipline:** the analyst's job is to package the technical evidence cleanly so the requester (LE, regulator, civil litigator, MLRO) can issue a well-scoped request. Over-broad requests get refused; under-scoped ones miss.

### 10.4 Travel Rule data flow

When transfers cross participating VASPs:

- Originator VASP transmits originator name, account, address, and (depending on regime) ID information.
- Beneficiary VASP receives and stores per regulatory retention period.
- If the analyst is operating *inside* a VASP, MLRO has access to the Travel Rule data.
- If outside, the data is reachable via subpoena to either VASP.
- Self-hosted-wallet transfers (no participating VASP on one side) carry no Travel Rule data and require alternative attribution paths.

### 10.5 Non-VASP off-ramps

- **P2P platforms** (LocalBitcoins-successor sites, Bisq, RoboSats; Paxful wound down operations by 2025-11-01 and is now withdrawal-only) — variable KYC; some require none. [verify 2026-10-29]
- **OTC desks** — high-value, often light-KYC; jurisdiction-dependent.
- **Crypto ATMs** — KYC requirements vary by jurisdiction (US BSA-registered; EU MiCA-aligned; many jurisdictions inconsistent enforcement).
- **No-KYC swap services** — FixedFloat (now at ff.io), ChangeNOW, SimpleSwap; aggressive disclaimers that they do not collect identity data. (Some have been compelled to produce records under legal process anyway.) [verify 2026-10-29]
- **DEX aggregators** — 1inch, ParaSwap (rebranded Velora), OpenOcean, CoW Swap; pure on-chain swaps with no KYC. Trace continues on-chain. [verify 2026-10-29]

---

## 11. Investigation Workflow

A representative case lifecycle. Adapt to the specific engagement (LE investigation, regulator inquiry, internal AML alert, journalism, ISAC notification, civil litigation).

### 11.1 Step 1 — Scope and inputs

- Define target: address(es), transaction(s), entity, incident.
- Collect inputs: known wallet addresses, contract addresses, transaction hashes, timestamps, claimed amounts, victim reports, IOCs from related work.
- Confirm authorization scope.
- Open a [[sop-collection-log|Collection Log]] entry for the case.

### 11.2 Step 2 — Initial chain enumeration

- For each address, determine the chain(s) it lives on.
- Identify token holdings (ERC-20, TRC-20, SPL, etc.).
- Snapshot current state (balance, last activity, label if any) — capture explorer page + raw API response.

### 11.3 Step 3 — Sanctions / risk screen

- Cross-check every input address against SDN (OFAC), EU, UK Sanctions List, UN consolidated lists. [verify 2026-10-29]
- Cross-check against open-source label sources (Chainabuse, Etherscan labels, Arkham).
- Flag any cluster-level matches.

### 11.4 Step 4 — Address clustering

- For UTXO chains: apply common-input + change-address heuristics; merge addresses; document basis.
- For account chains: identify account neighborhoods via funding / gas / approval / interaction patterns.
- Capture the cluster (size, member addresses, total activity, time range).
- Document confidence per [[sop-entity-dossier|Entity Dossier]] §"Confidence Rating."

### 11.5 Step 5 — Inflow tracing

- Trace funds **into** the cluster from the time of the incident backward.
- Identify funding sources: exchanges, peers, prior incidents, mining, contract revenues.
- Note any bridge inflows — pair source-chain events per §6.

### 11.6 Step 6 — Outflow tracing

- Trace funds **out of** the cluster from the incident forward.
- Identify exit paths: exchange deposits, mixer entries (hand off to [[sop-mixer-tracing|Mixer & Privacy-Pool Tracing]]), bridge outflows (pair per §6), DeFi swaps, NFT mints, peer transfers.
- For each exit, capture the exit-side address, value, time, and likely destination type.
- **Stop at mixer entry.** Cluster the mixer-entry address; route the obfuscation-defeat work to [[sop-mixer-tracing|Mixer & Privacy-Pool Tracing]].

### 11.7 Step 7 — Off-ramp identification

- Where outflows reach VASPs, package the evidence per §10.2.
- Where outflows reach P2P / OTC / no-KYC services, document the platform and the available attribution surfaces (KYC tier, cooperation history, jurisdiction).
- Where outflows reach DEXes / DeFi protocols, continue on-chain to the next post-swap address.

### 11.8 Step 8 — Cross-platform pivot

- Cross-link any discovered identifiers (clearnet handles, emails, social profiles, PGP keys observed in [[sop-darkweb-investigation|Darkweb Investigation]] context, breach data) per §13.

### 11.9 Step 9 — Cluster mapping and visualization

- Build the entity-relationship graph (Maltego, Neo4j, draw.io, Breadcrumbs, Arkham, Chainalysis Reactor — match the deliverable). [verify 2026-10-29]
- Annotate edges with TX evidence and confidence labels.

### 11.10 Step 10 — Reporting

- Package per [[sop-reporting-packaging-disclosure|Reporting, Packaging & Disclosure]].
- Findings table: address / cluster, role, confidence, evidence, sanctions status (with timestamp).
- Flow diagram with annotated TX evidence.
- Methodology section explaining the heuristics applied — Daubert-ready (§12).
- Evidence bundle: hashed CSV exports, screenshots, vendor-tool exports, raw RPC responses.

---

## 12. Court-Admissibility & Evidentiary Tradecraft

Blockchain findings increasingly appear in court — sanctions enforcement, money-laundering prosecutions, asset-recovery actions, civil disputes. The evidentiary bar is rising, and the defense bar is sharpening. The Sterlingov case is the canonical reference point.

### 12.1 The Sterlingov / Bitcoin Fog case

- **Defendant:** Roman Sterlingov (Russian-Swedish dual national). [verify 2026-10-29]
- **Charges:** Operating Bitcoin Fog mixer 2011-2021; money-laundering conspiracy, money laundering, operating an unlicensed money transmitting business, and money transmission without a D.C. license (four counts; no sanctions count). [verify 2026-10-29]
- **Arrest:** 2021-04-27 at LAX. [verify 2026-10-29]
- **Conviction:** 2024-03-12, jury verdict on all four counts in the U.S. District Court for the District of Columbia (Judge Randolph D. Moss). [verify 2026-10-29]
- **Sentence:** 2024-11-08, 12 years 6 months imprisonment. [verify 2026-10-29]
- **Defense thesis:** Government's identification of Sterlingov as the Bitcoin Fog operator rested heavily on Chainalysis Reactor's heuristic clustering. Defense argued (with expert testimony and academic critique) that the clustering heuristics were probabilistic, error-prone, and inadequate to meet the criminal-conviction bar without independent corroboration. [verify 2026-10-29]
- **Court posture:** Pre-trial Daubert challenge to Chainalysis Reactor admissibility was largely resolved in the government's favor, with the court permitting Reactor analysis but allowing defense cross-examination on heuristic limitations (*United States v. Sterlingov*, 719 F. Supp. 3d 65 (D.D.C. 2024)). The conviction proceeded and was affirmed by the D.C. Circuit on 2026-09-25 (No. 24-3161), which held that admitting the Reactor-based expert testimony was not an abuse of discretion. [verify 2026-10-29]
- **What it changed:** Subsequent prosecutions and asset-recovery actions face a documented playbook for attacking heuristic-based clustering. Practitioners building court-bound findings should expect every cluster, label, and inference to be challenged on:
  - The specific heuristic applied
  - The vendor's documented error rate (where published)
  - Independent reproducibility
  - Counter-evidence within the cluster
  - Vendor-tool version and methodology version

### 12.2 Daubert posture

Under *Daubert v. Merrell Dow Pharmaceuticals* (US federal courts) and analogous standards (England & Wales: Civil Evidence Act 1972 s.3, Criminal Procedure Rules Part 19; Australia: *R v Bonython* (1984) 38 SASR 45; EU Member State equivalents), expert testimony must rest on: [verify 2026-10-29]

- Methodology that is testable.
- Methodology that has been peer-reviewed.
- Known error rate.
- Standards governing operation.
- General acceptance in the relevant scientific community.

Open-source heuristics (Meiklejohn 2013 and subsequent academic literature) satisfy peer-review criteria. Proprietary vendor heuristics are weaker on peer-review but satisfy general-acceptance via wide LE / regulator adoption. The gap is **error rate** — published vendor error rates are sparse, and that is where defense challenges concentrate. [verify 2026-10-29]

### 12.3 Tradecraft for court-bound findings

- **Document the heuristic basis** for every cluster claim. "Chainalysis Reactor identified" is not enough; specify the heuristic family.
- **Independently reproduce** key clusters using open-source methods. A finding corroborated by GraphSense + Chainalysis + manual common-input analysis is far stronger than a finding from any single source.
- **Capture raw on-chain data** — the underlying transactions are facts; cluster labels are interpretations. The factual record survives if interpretations are challenged.
- **Pin tool versions** — vendor heuristic outputs are version-dependent; record the version.
- **Disclose limitations** in your own report. Hidden weaknesses are more damaging in cross-examination than disclosed ones.
- **Time-stamp sanctions findings** — designations change; report the SDN posture at the time of activity.
- **Chain of custody** — apply [[sop-collection-log|Collection Log]] discipline. SHA-256 hash artifacts; preserve OpenTimestamps where appropriate; maintain an unbroken collection chain.

### 12.4 Expert-witness considerations

- The analyst preparing court-bound findings should be qualified to testify if called. Vendor-tool certifications (Chainalysis Certified Investigator / Certified Advanced Investigator; TRM Certified Investigator) carry weight; academic publications and operational case-history more. The CryptoCurrency Security Standard (CCSS) is a custody-security standard, not an investigator credential. [verify 2026-10-29]
- Know the methodology you are presenting. Cross-examination will probe the heuristic; "the tool said so" is a weak position.
- Distinguish between what the data shows and what the cluster label asserts. Conflating them is a recurring cross-examination opening.

### 12.5 Other notable cases (situational awareness)

- **Bitfinex 2016 hack — Heather Morgan / Ilya Lichtenstein:** ~$3.6B in BTC seized 2022-02-08, from the 119,754 BTC stolen in the 2016 Bitfinex hack (the full haul was valued at ~$4.5B at the time of the 2022 arrests). Both pleaded guilty August 2023; Lichtenstein sentenced 2024-11 to 5 years; Morgan sentenced 2024-11 to 18 months. [verify 2026-10-29] Demonstrates years-long tracing across address-laundering and exchange interactions.
- **Silk Road / Ulbricht:** 2013 takedown; subsequent civil forfeiture of seized BTC. Foundational case for crypto-asset forfeiture procedure.
- **DOJ asset-forfeiture proceedings** — civil and criminal forfeiture of crypto assets has become routine, with pleadings citing blockchain analytics as primary evidence.

---

## 13. Cross-Platform Pivots

### 13.1 Onion → blockchain (from darkweb observation)

- Receives hand-off from [[sop-darkweb-investigation|Darkweb Investigation]] §13 ("wallet address X observed on listing or post").
- Workflow: validate the address (correct format, exists on the claimed chain), cluster, screen for sanctions, trace inflow / outflow, attempt entity attribution.
- Annotate the source — *"address observed at [.onion URL] on [date], captured per Collection Log entry [ID]"* — in the finding.

### 13.2 Domain / SaaS / website → blockchain

- Donation-page wallet addresses, scam-site checkout addresses, ransomware-note addresses found via [[sop-web-dns-whois-osint|Web/DNS/WHOIS OSINT]].
- Workflow: extract address from page (HTML scrape, image OCR, QR decode); validate; trace.
- Track infrastructure pivots in parallel — operator domain reuse, hosting-provider links, certificate transparency logs.

### 13.3 Social / handle → blockchain

- Twitter / X profile address fields, Telegram channel pinned messages, Discord profile bios, ENS names tied to social accounts.
- ENS (`*.eth`) and Lens / Farcaster identifiers map directly to addresses; query the registry.
- Workflow: capture social-side context (handle history, bio, post containing the address); trace the address.

### 13.4 Breach / dump → blockchain

- Stolen-credential dumps occasionally include exchange-account credentials. **Do not validate** the credentials (unauthorized access). Instead:
  - Use the data to inform the investigation hypothesis (e.g., known association between handle and exchange account).
  - Route to [[sop-sensitive-crime-intake-escalation|Sensitive Crime Intake & Escalation]] for victim notification if appropriate.
- Email-to-wallet correlations from analytics-vendor labeling sometimes appear in breach corpora; treat as crowdsourced and corroborate.

### 13.5 Malware IOC → blockchain

- Receives hand-off from [[../../Security/Analysis/sop-malware-analysis|Malware Analysis]] for ransomware payment addresses, C2-infrastructure crypto receivables, drainer-kit wallet rotations.
- Workflow: trace the addresses; identify the laundering pattern; pair with sanctions where applicable; coordinate timing with incident-response posture.

### 13.6 Smart-contract exploit → blockchain (post-exploit)

- Hand-off from [[sop-smart-contract-audit|Smart Contract Audit]] for post-exploit fund tracing.
- Smart-contract audit identifies the vulnerability and the attacker's address; this SOP traces the funds from that point onward.
- Workflow per §11; document the exploit context (which protocol, which vulnerability class, which tx-of-exploit) so the trace is anchored to the inciting event.

---

## 14. Hand-off Boundaries (Scope Contract)

This SOP **stops** at the following boundaries. Each hand-off targets the canonical owner SOP.

| Observation                                                                              | Stops here. Routes to:                                                                                                                                                          |
| ---------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Mixer entry (Tornado Cash, Wasabi CoinJoin, JoinMarket, Whirlpool, Sinbad, etc.) [verify 2026-10-29] | [[sop-mixer-tracing|Mixer & Privacy-Pool Tracing]]                                                                                                                              |
| Cross-chain bridge **obfuscation defeat** (round-tripping, fragmentation, decoy bridges) | [[sop-mixer-tracing|Mixer & Privacy-Pool Tracing]]. Bridge **read-flow** is in scope here (§6).                                                                                  |
| Smart-contract source / bytecode review, vulnerability-class analysis                    | [[sop-smart-contract-audit|Smart Contract Audit]]. Post-exploit fund tracing is in scope here.                                                                                   |
| Ransomware payload analysis                                                              | [[../../Security/Analysis/sop-malware-analysis|Malware Analysis]]                                                                                                                |
| Banking / fiat AML, corporate UBO, PEP screening, payment-processor research             | [[sop-financial-aml-osint|Financial & AML OSINT]]                                                                                                                                |
| Darkweb listing / forum / leak-site observation that revealed the wallet                 | [[sop-darkweb-investigation|Darkweb Investigation]]                                                                                                                              |
| Sanctioned-entity infrastructure beyond on-chain (clearnet sites, CDN, hosting)          | [[sop-web-dns-whois-osint|Web/DNS/WHOIS OSINT]]                                                                                                                                  |
| Wallet operator's clearnet identity emerges                                              | [[sop-entity-dossier|Entity Dossier]] for structured profiling                                                                                                                   |
| Breach-data / leaked credential validation                                               | **Do not validate**. Route to [[sop-sensitive-crime-intake-escalation|Sensitive Crime Intake & Escalation]]                                                                       |
| CSAM funding addresses                                                                   | **Hard-stop on content.** Address may be traced; content is not viewed. Route per [[sop-sensitive-crime-intake-escalation|Sensitive Crime Intake & Escalation]]                  |
| Trafficking funding, terror funding, threat-to-life payment in progress                  | [[sop-sensitive-crime-intake-escalation|Sensitive Crime Intake & Escalation]]                                                                                                    |
| Cryptography / PGP / signature-scheme deep analysis                                      | [[../../Security/Analysis/sop-cryptography-analysis|Cryptography Analysis]]                                                                                                      |
| Hash-algorithm selection for evidence integrity                                          | [[../../Security/Analysis/sop-hash-generation-methods|Hash Generation Methods]]                                                                                                  |
| Final reporting                                                                          | [[sop-reporting-packaging-disclosure|Reporting, Packaging & Disclosure]]                                                                                                         |

The contract is bidirectional: when those owner SOPs reach a blockchain-tracing observation, they route **back here**.

---

## 15. Tools Reference

### 15.1 Public explorers

See §4.1 — per-chain canonical explorers — and §4.2 — multi-chain aggregators.

### 15.2 Bridge indexers

See §6.5 — major bridge indexers (wormholescan, layerzeroscan, Midgard, Across, Hop, Stargate, bungee / li.fi).

### 15.3 Sanctions feeds

| Source                           | Feed                                                       | Notes                                        |
| -------------------------------- | ---------------------------------------------------------- | -------------------------------------------- |
| OFAC SDN search (HTML)           | [sanctionssearch.ofac.treas.gov](https://sanctionssearch.ofac.treas.gov/) | Interactive search; page shows SDN / Non-SDN "last updated" timestamps — record them [verify 2026-10-29] |
| OFAC sanctions list service      | [sanctionslist.ofac.treas.gov](https://sanctionslist.ofac.treas.gov/Home/SdnList) | XML / CSV / fixed-width / PDF bulk files [verify 2026-10-29] |
| EU Sanctions Map                 | [sanctionsmap.eu](https://www.sanctionsmap.eu/)             | EU consolidated [verify 2026-10-29] |
| EU Financial Sanctions DB        | [webgate.ec.europa.eu/fsd/fsf](https://webgate.ec.europa.eu/fsd/fsf) | Machine-readable [verify 2026-10-29] |
| UK Sanctions List                | [gov.uk/government/publications/the-uk-sanctions-list](https://www.gov.uk/government/publications/the-uk-sanctions-list) | UK designations; sole source since 2026-01-28 (OFSI Consolidated List closed) [verify 2026-10-29] |
| UN Security Council Sanctions    | [main.un.org/securitycouncil/en/sanctions/information](https://main.un.org/securitycouncil/en/sanctions/information) | UN consolidated [verify 2026-10-29] |
| OpenSanctions                    | [opensanctions.org](https://www.opensanctions.org/)         | Aggregated multi-jurisdiction; CC BY-NC 4.0 — commercial use (incl. client screening) needs a paid data license [verify 2026-10-29] |

### 15.4 Commercial analytics

| Vendor            | Primary product               | URL                                                        |
| ----------------- | ----------------------------- | ---------------------------------------------------------- |
| Chainalysis       | Reactor / KYT                 | [chainalysis.com](https://www.chainalysis.com/) [verify 2026-10-29] |
| TRM Labs          | Forensics / screening & monitoring | [trmlabs.com](https://www.trmlabs.com/) [verify 2026-10-29] |
| Elliptic          | Investigator / Lens           | [elliptic.co](https://www.elliptic.co/) [verify 2026-10-29] |
| Crystal Intelligence | Multi-chain analytics      | [crystalintelligence.com](https://crystalintelligence.com/) [verify 2026-10-29] |
| Arkham            | Entity-labeled platform       | [arkhamintelligence.com](https://www.arkhamintelligence.com/) (redirects to info.arkm.com) [verify 2026-10-29] |
| Merkle Science    | Tracker / Compass             | [merklescience.com](https://www.merklescience.com/) [verify 2026-10-29] |
| Lukka (acquired Coinfirm 2024; see §8.5) | Blockchain Analytics & Compliance | [lukka.tech](https://lukka.tech/) [verify 2026-10-29] |
| Nansen            | DeFi smart-money labels       | [nansen.ai](https://www.nansen.ai/) [verify 2026-10-29] |

### 15.5 Open-source analytics

| Tool / Resource     | Purpose                                          | URL                                                |
| ------------------- | ------------------------------------------------ | -------------------------------------------------- |
| GraphSense          | Open-source multi-chain analytics + clustering   | [graphsense.info](https://graphsense.info/) [verify 2026-10-29] |
| Breadcrumbs         | Blockchain visualization (confirm current access tiers) | [breadcrumbs.app](https://www.breadcrumbs.app/) [verify 2026-10-29 — site bot-walled; access tiers not confirmed] |
| Wallet Explorer     | Bitcoin clustering UI (wallet-name DB frozen since 2016; see §8.5) | [walletexplorer.com](https://www.walletexplorer.com/) [verify 2026-10-29] |
| OXT.me              | Bitcoin analytics (Samourai-affiliated); defunct — see §8.5 | oxt.me does not respond (no live link) [verify 2026-10-29] |
| BigQuery public crypto datasets | Bulk SQL analytics over BTC/ETH/etc.    | [console.cloud.google.com](https://console.cloud.google.com/marketplace/browse?filter=solution-type:dataset) [verify 2026-10-29] |
| The Graph           | Subgraph indexing for protocol context           | [thegraph.com](https://thegraph.com/) [verify 2026-10-29] |
| Chainabuse          | Community scam/abuse reporting                   | [chainabuse.com](https://www.chainabuse.com/) [verify 2026-10-29] |

### 15.6 Node software (self-hosted RPC)

| Software        | Chain    | Notes                                                |
| --------------- | -------- | ---------------------------------------------------- |
| Bitcoin Core    | BTC      | Full node + `txindex=1` for arbitrary TX queries [verify 2026-10-29] |
| Erigon          | ETH      | Archive node with traces [verify 2026-10-29] |
| Reth            | ETH      | Rust-implemented archive node (newer) [verify 2026-10-29] |
| Geth            | ETH      | Reference EVM client [verify 2026-10-29] |
| Solana validator| Solana   | High disk I/O; consider RPC providers                |
| TRON node       | Tron     | `java-tron` [verify 2026-10-29] |

### 15.7 Forensics support

- See [[sop-collection-log|Collection Log]] for canonical capture / hash / timestamp toolset.
- See [[../../Security/Analysis/sop-hash-generation-methods|Hash Generation Methods]] for algorithm-selection guidance.
- See [[../../Security/Analysis/sop-cryptography-analysis|Cryptography Analysis]] for PGP / signature / key analysis.

---

## 16. Risks & Limitations

### 16.1 Heuristic limitations

- **Clustering is probabilistic.** Every heuristic has counter-examples. Treat cluster membership as a confidence-weighted finding, not as identity proof.
- **Vendor heuristics are proprietary.** Reproducibility is limited to vendor-published methodology.
- **CoinJoin and PayJoin** deliberately violate common-input ownership.
- **Address poisoning** can introduce attacker-controlled addresses into a target's transaction history with the goal of misleading clustering or copy-paste workflows.
- **Sterlingov-style cross-examination** has documented heuristic weaknesses; expect them to be cited.

### 16.2 Privacy-coin limitations

- **Monero RingCT** — on-chain tracing not feasible at current ring sizes; rely on off-chain pivots.
- **Zcash shielded** — shielded-to-shielded transfers are private; pool-internal-only users are statistically rare in published research, providing some attribution surface for those who cross the t↔z boundary.
- **Mixer-defeated traces** — research and tooling exist but are mixer-specific and version-dependent; routes to [[sop-mixer-tracing|Mixer & Privacy-Pool Tracing]].

### 16.3 Cross-chain bridge limitations

- **Protocol churn** — bridges are exploited, deprecated, redeployed. Multichain (2023), Wormhole (2022 exploit), Ronin (2022 exploit), Nomad (2022 exploit) all changed the trace landscape.
- **Indexer dependence** — many bridge traces depend on the bridge's own indexer being up-to-date; outages create blind spots.
- **Wrapped-asset reuse** — multi-bridge laundering can fragment a trace across many protocol-events; missing one breaks the chain.

### 16.4 OPSEC risks

- **Query attribution leak** — pasting a target wallet into a vendor or public service logs the analyst's interest.
- **Investigation-VPN reuse** — VPN exit IPs can correlate analyst queries across investigations if not rotated per [[sop-opsec-plan|OPSEC Plan]].
- **Address poisoning of analysts** — sending dust to a watch-only wallet to surface in the analyst's UI is a documented technique.
- **Vendor-side data sharing** — some vendors share customer query data with paying customers (or other LE / regulator clients); confirm the ToS for the engagement.

### 16.5 Volatility and rot

- **Sanctions trajectories shift** — Tornado Cash 2022→2024→2025 illustrates that the legal posture of a single contract has changed three times. Always time-stamp. [verify 2026-10-29]
- **Vendor product lineup shifts** — CipherTrace acquired and wound down; other vendors merge / re-brand. Tool capability at engagement time must be confirmed.
- **Bridge protocol updates** — event names and contract addresses change between versions; always verify against the current canonical deployment.
- **Exchange / VASP status** — exchanges fail, get sanctioned (Garantex), get acquired, exit jurisdictions. Relationships at the time of activity are what matter. [verify 2026-10-29]

### 16.6 Evidentiary fragility

- **Vendor-only findings** are challengeable. Independently reproduce.
- **Hand-rendered cluster diagrams** lose information; preserve raw queries and responses.
- **Tool versioning** matters; record it.
- **Time-of-activity vs time-of-report** matters for sanctions and for cluster membership (clusters grow over time).

---

## 17. Common Pitfalls

- ❌ **Treating cluster labels as identity proof.** Cluster = heuristic; identity proof = additional evidence (KYC record, off-chain pivot, confession, compelled testimony).
- ❌ **Using only one vendor.** Single-source findings are fragile under cross-examination.
- ❌ **Stopping at the mixer entry without recording the entry address and value.** That address is the seed for [[sop-mixer-tracing|Mixer & Privacy-Pool Tracing]] work.
- ❌ **Stopping at the first bridge.** Multi-bridge laundering is the modern norm; follow.
- ❌ **Pasting target wallets into ChatGPT or random analytics tools.** Operational leak; some surfaces store and reuse queries.
- ❌ **Transacting with target addresses** ("just a 1-satoshi probe to check"). Taints the cluster, alerts the subject, may be illegal.
- ❌ **Validating leaked credentials** for an exchange account tied to a target. Unauthorized access. Subpoena instead.
- ❌ **Reporting sanctions status without time-stamping.** Tornado Cash status changed three times; the legal posture at time of activity is what matters, not at time of report.
- ❌ **Attributing clusters to nation-state groups based on vendor labels alone.** Lazarus / APT38 / DPRK-cluster attribution typically requires multiple corroborating sources (Chainalysis + TRM + UN Panel of Experts reports to April 2024 / MSMT reports since + FBI/CISA joint advisories). [verify 2026-10-29]
- ❌ **Trusting Etherscan / explorer "comment" labels** on contracts — they can be user-submitted; verify provenance.
- ❌ **Ignoring internal transactions** on EVM chains. Many illicit flows are contract-mediated and invisible in the top-level TX list.
- ❌ **Confusing ENS / Lens / Farcaster handles with ownership proof.** ENS resolution at time T does not prove ownership at time T-1.
- ❌ **Using paid vendor-tool free trials with attribution-tied accounts.** Burn the burner email; never the analyst's real email.
- ❌ **Reporting USD values without recording the exchange-rate source and timestamp.** Crypto-USD conversion is volatile; the rate at time of activity vs time of report can differ by orders of magnitude.
- ❌ **Treating commercial-tool risk scores as compliance dispositive.** Risk scores are vendor-derived; regulator findings rest on facts, not scores.
- ❌ **Sharing investigation details on a vendor platform's public bounty / labels feature.** Some Arkham / labels surfaces are public; do not leak active investigation context.
- ❌ **Re-using the same investigator persona across unrelated cases.** Cross-case linkability via vendor-account history is a real attribution surface for skilled adversaries.

---

## 18. Real-World Scenarios

### Scenario 1: Ransomware payment trace (post-incident)

**Situation:** A ransomware affiliate breaches an organization; the organization pays the ransom (against advice) to a BTC address provided in the negotiation chat. Incident response asks: where did the funds go? Are they SDN-implicated?

**Approach:**

1. From the negotiation chat / ransom note, capture the receiving BTC address; validate format and chain.
2. Cluster the address — common-input + change-address heuristics across recent activity. Identify the wider wallet.
3. Sanctions screen against OFAC SDN, EU, UK Sanctions List; cluster-screen as well as address-screen. [verify 2026-10-29]
4. Trace the outflow forward — exchange deposit? Mixer entry (hand off to [[sop-mixer-tracing|Mixer & Privacy-Pool Tracing]])? Bridge to another chain (pair per §6 and continue)?
5. If outflow reaches a known VASP, package the evidence per §10.2 and route to LE for legal-process pursuit.
6. Coordinate with [[../../Security/Analysis/sop-malware-analysis|Malware Analysis]] on the binary IOCs — same actor, complementary evidence.
7. Time-stamp every sanctions finding — was the destination cluster SDN-listed at time of payment? OFAC has issued advisories on ransomware payments to designated groups (2020-10-01 advisory, superseded by the 2021-09-21 Updated Advisory). [verify 2026-10-29]

**Outcome:** Defensible evidence package supporting (a) potential sanctions exposure determination, (b) LE referral for asset recovery, (c) regulator notification if the payor is regulated.

### Scenario 2: DeFi exploit fund tracing (post-exploit)

**Situation:** A lending protocol is exploited via a flash-loan price-manipulation attack; ~$50M in stablecoins are drained to an attacker-controlled EVM address.

**Approach:**

1. From the exploit transaction (provided by protocol team or extracted from on-chain post-mortem), identify the attacker-controlled address(es).
2. Cluster on the receiving side — common-funding, gas-payer, interaction-pattern heuristics for the EVM account-cluster (§5.4).
3. Trace outflows: identify swap calls (Uniswap, 1inch, CowSwap), bridge calls (LayerZero, Wormhole, Across), mixer calls (Tornado-style — hand off to [[sop-mixer-tracing|Mixer & Privacy-Pool Tracing]]).
4. Pair every bridge call with the destination-chain event per §6.
5. Continue tracing on the destination chain.
6. Coordinate with the [[sop-smart-contract-audit|Smart Contract Audit]] SOP on the exploit-class analysis; this SOP focuses on fund movement from the moment of exploit forward.
7. If attacker exhibits negotiation behavior (bug-bounty-style on-chain message), capture the messaging context.
8. Annotate confidence — flash-loan exploit attribution has high-confidence on-chain technical evidence; identity attribution remains lower-confidence absent off-chain pivots.

**Outcome:** Comprehensive flow map supporting (a) coordinated exchange freezes if exit paths reach VASPs, (b) negotiation context for protocol team, (c) basis for civil / criminal action if identity attribution succeeds.

### Scenario 3: Sanctioned-group infrastructure pivot

**Situation:** Open-source intelligence identifies a hot wallet associated with a designated ransomware group's leak-site hosting payments. Question: what is the wallet's full activity, who are its counterparties, and what off-ramps does it use?

**Approach:**

1. Confirm the SDN designation and the address-to-group attribution (vendor labels + open-source corroboration + UN Panel of Experts (to April 2024) / MSMT / OFAC documentation). [verify 2026-10-29]
2. Cluster the address; identify the broader operational wallet.
3. Trace inflows — victim payments (each victim payment is an investigative thread), affiliate splits, conversion paths.
4. Trace outflows — identify the exit pattern. State-actor groups have historically used:
   - Cross-chain bridges (often THORChain) to Bitcoin [verify 2026-10-29]
   - OTC desks in jurisdictions with weak enforcement
   - DEX-only paths to avoid VASPs
5. For each non-mixer outflow, document. For mixer outflows, hand off to [[sop-mixer-tracing|Mixer & Privacy-Pool Tracing]].
6. Cross-check victim payments against ISAC / sector-specific advisories; identify victims who may not have publicly disclosed.
7. Package per [[sop-reporting-packaging-disclosure|Reporting, Packaging & Disclosure]]; route to OFAC / FIU / LE per the engagement scope.

**Outcome:** Operational view of designated-group infrastructure supporting sanctions enforcement, victim-notification, and threat-intelligence sharing. Note: state-actor attribution has high political surface; double-corroborate before publishing.

---

## 19. Emergency Procedures

Blockchain investigations rarely involve immediate threat-to-life, but several scenarios warrant immediate escalation.

### 19.1 Escalation triggers (immediate)

- **Ransomware payment in progress** — payor is mid-negotiation with a designated group. Sanctions exposure attaches at the moment of payment; pre-payment intervention can avert it.
- **Active exchange theft** — observed real-time exfiltration from a known exchange / DeFi protocol; coordinated freeze can recover.
- **Sanctions evasion in progress** — observed transfer through SDN-designated infrastructure that completes within minutes / hours.
- **CSAM funding addresses** observed during a tracing exercise (the addresses can be traced; the underlying content is hard-stop per [[sop-darkweb-investigation|Darkweb Investigation]]).
- **Trafficking funding** — payments connected to active trafficking operations.
- **Imminent threat-to-life payment** (kidnap / extortion) with identifiable victim.

### 19.2 Immediate actions

1. **Capture the on-chain state** — current TX hashes, addresses, values, timestamps. Preserve the ledger evidence; the chain itself is durable, but session capture is critical for chain-of-custody.
2. **Notify** through the appropriate channel:
   - **Exchange / VASP** — many maintain LE / fraud-notification channels for live freeze requests; some respond within hours under appropriate process.
   - **OFAC** — sanctions enforcement contact for live designated-group transfers.
   - **FIU** — SAR routing for in-progress money laundering.
   - **LE** — local cyber unit, FBI IC3, NCA, sector ISAC.
3. **Coordinate with the engagement principal** — this is rarely an analyst-unilateral action.
4. **Document the decision and the routing** — who notified, when, with what artifacts.
5. **Continue capture** through the resolution; in-progress operations evolve and the post-event record matters.

### 19.3 Specific pathway examples

- **US ransomware / sanctions exposure:** OFAC compliance hotline; FBI IC3 (`ic3.gov`); CISA incident reporting — `https://www.cisa.gov/report` (redirects to CISA's incident reporting form at `myservices.cisa.gov/irf`), `report@cisa.gov`, 1-844-Say-CISA (1-844-729-2472). [verify 2026-10-29]
- **EU:** Europol European Cybercrime Centre (EC3); national CERT; national FIU. [verify 2026-10-29]
- **UK:** Report Fraud (`reportfraud.police.uk`, 0300 123 2040; replaced Action Fraud 2025-12-04; Scotland: Police Scotland 101); NCA NCSC Reporting; FCA for regulated entities. [verify 2026-10-29]
- **Trafficking / CSAM funding:** route per [[sop-sensitive-crime-intake-escalation|Sensitive Crime Intake & Escalation]].
- **Exchange freeze requests:** maintain a contact list of active exchange LE-channels for the engagement; many require pre-existing relationships.

Cross-link [[sop-sensitive-crime-intake-escalation|Sensitive Crime Intake & Escalation]] for the canonical escalation matrix; this section is a pointer.

---

## 20. Related SOPs

- [[sop-legal-ethics|Legal & Ethics]] — canonical legal framework; review before every engagement
- [[sop-opsec-plan|OPSEC Plan]] — investigator OPSEC, environment isolation, query-attribution discipline
- [[sop-collection-log|Collection Log]] — chain-of-custody, hashing, timestamping, FRE 902(13)/(14) framing [verify 2026-10-29]
- [[sop-entity-dossier|Entity Dossier]] — structured profiling for wallet operator / cluster owner attribution; confidence-rating framework
- [[sop-financial-aml-osint|Financial & AML OSINT]] — fiat-side AML, corporate UBO, sanctions screening, PEP / adverse-media; current `§5 Cryptocurrency Tracing` is the migration source for this SOP and will be trimmed to AML-analyst quick-reference once #5 also lands
- [[sop-darkweb-investigation|Darkweb Investigation]] — receives wallet observations from this SOP; sends wallet observations to it (§13)
- [[sop-web-dns-whois-osint|Web/DNS/WHOIS OSINT]] — clearnet pivots when wallet operator's infrastructure surfaces
- [[sop-sensitive-crime-intake-escalation|Sensitive Crime Intake & Escalation]] — escalation routes for CSAM funding, trafficking funding, terror funding, threat-to-life payments
- [[sop-reporting-packaging-disclosure|Reporting, Packaging & Disclosure]] — final reporting, disclosure routes, evidentiary packaging
- [[../../Security/Analysis/sop-malware-analysis|Malware Analysis]] — ransomware payload IOCs paired with payment-address pivots
- [[../../Security/Analysis/sop-hash-generation-methods|Hash Generation Methods]] — algorithm selection for evidence integrity
- [[../../Security/Analysis/sop-cryptography-analysis|Cryptography Analysis]] — signature / key / ECDSA / EdDSA / hash-chain analysis when needed
- [[../Platforms/sop-platform-telegram|Telegram SOP]] — out-of-band negotiation channel for ransomware groups; address-disclosure pivot surface
- [[../Platforms/sop-platform-twitter-x|Twitter/X SOP]] — public address disclosure (donations, scams, ENS associations)
- [[sop-mixer-tracing|Mixer & Privacy-Pool Tracing]] — mixer / privacy-pool / cross-chain-bridge obfuscation defeat
- [[sop-smart-contract-audit|Smart Contract Audit]] — smart-contract source / bytecode review and exploit-class analysis (pre-exploit work; this SOP picks up post-exploit fund tracing)
- [[../../Security/Analysis/sop-cloud-forensics|Cloud Forensics]] — IaaS-plane forensics for exchange / VASP infrastructure investigations (where applicable)

## Legal & Ethical Considerations

Canonical legal framework: [[sop-legal-ethics|Legal & Ethics]]. Do not re-derive jurisdiction, statute, or authorization rules in this SOP — read them from the canonical source.

Blockchain-investigation-specific guardrails:

- **Authorization in writing.** Names blockchain analytics as in-scope; lists target wallets / contracts / chains where known. Sanctions-research carve-out should be explicit if SDN-designated entities are in scope (research is permitted in most jurisdictions; transactional engagement is not).
- **Observation-only.** No transactions to or from target addresses, no test sends, no "verification" of vendor cluster labels by interacting. The line between observation and participation is the legal line.
- **Cluster-as-heuristic discipline.** Report cluster membership with the heuristic basis and a confidence label per [[sop-entity-dossier|Entity Dossier]]. Do not assert identity from cluster membership alone.
- **Sanctions discipline.** Screen against OFAC, EU, UK Sanctions List, UN at minimum; many SDN crypto entries are not in non-US lists. Time-stamp every finding — sanctions designations change over time, and the legal posture at the time of activity is what matters. [verify 2026-10-29]
- **PII minimization.** Apply GDPR Art. 6 / 9 (or equivalent) minimization. Lawful basis (legitimate interest, legal claim, public task, regulator-mandated) per query class. Subpoena pathway for KYC data is the proper channel; vendor-aggregated identity data must be assessed for provenance.
- **Mandatory reporting.** If operating inside a regulated entity, route findings via MLRO. Outside, route serious findings (sanctions evasion, terrorism financing, child exploitation, trafficking) via the appropriate FIU / national authority — see [[sop-sensitive-crime-intake-escalation|Sensitive Crime Intake & Escalation]].
- **Court-admissibility tradecraft.** Pin tool versions; capture raw on-chain data; cross-corroborate vendor findings with open-source methods where the matter could go to court (§12).
- **Vendor query OPSEC.** Treat vendor-platform queries as logged. Burner accounts; no analyst-attribution leak; investigation-scoped persona discipline.
- **Log every query.** Chain, address / TX hash, tool, timestamp UTC, action, hash of saved artifact — per [[sop-collection-log|Collection Log]] format. Admissibility depends on the unbroken chain.

OPSEC for the investigator (cross-context separation, environment isolation, query-attribution discipline, address-poisoning resilience): [[sop-opsec-plan|OPSEC Plan]] is the canonical source. Crypto investigations leak more than typical OSINT; tighten OPSEC accordingly.

---

## 21. External / Reference Resources

### Bitcoin / EVM / multi-chain explorers

See §4.1 (per-chain explorers) and §4.2 (multi-chain aggregators).

### Sanctions feeds

See §15.3 (OFAC / EU / UK / UN / OpenSanctions).

### Bridge indexers

See §6.5 (wormholescan, layerzeroscan, Midgard, Across, Hop, Stargate, bungee / li.fi).

### Academic foundations

- Meiklejohn et al. 2013 — *A Fistful of Bitcoins: Characterizing Payments Among Men with No Names* (foundational clustering-heuristic paper). [verify 2026-10-29]
- Ron & Shamir 2013 — *Quantitative Analysis of the Full Bitcoin Transaction Graph*. [verify 2026-10-29]
- Kappos, Yousaf, Maller, Meiklejohn 2018 — *An Empirical Analysis of Anonymity in Zcash* (USENIX Security). [verify 2026-10-29]
- Quesnelle 2017 — *On the linkability of Zcash transactions*. [verify 2026-10-29]
- Möser et al. 2017 — *An Empirical Analysis of Traceability in the Monero Blockchain*. [verify 2026-10-29]
- Kalodner, Möser, Lee, Goldfeder, Plattner, Chator, Narayanan 2020 — *BlockSci: Design and applications of a blockchain analysis platform* (USENIX Security 2020; arXiv 1709.02489). GitHub repo inactive since 2021. [verify 2026-10-29]

### Standards and frameworks

- FATF — Recommendation 16 (Travel Rule; revised payment-transparency text adopted at the June 2025 Plenary); Updated Guidance for a Risk-Based Approach to Virtual Assets and VASPs (October 2021, predates the R.16 revision). [fatf-gafi.org](https://www.fatf-gafi.org/) [verify 2026-10-29]
- Egmont Group — FIU coordination. [verify 2026-10-29]
- Wolfsberg Group — financial-institution AML guidance. [verify 2026-10-29]
- IVMS101 — Travel Rule data interchange standard. [verify 2026-10-29]
- CCSS (CryptoCurrency Security Standard) — enterprise crypto security baseline. [verify 2026-10-29]
- NIST SP 800-86 — Integrating Forensic Techniques into Incident Response (see [[sop-collection-log|Collection Log]] §"Standards & Frameworks"). [verify 2026-10-29]
- Berkeley Protocol on Digital Open Source Investigations (UN OHCHR 2022) — see [[sop-legal-ethics|Legal & Ethics]] §"International framework." [verify 2026-10-29]

### Investigative journalism and research

- Chainalysis Crypto Crime Report (annual) — [chainalysis.com/blog](https://www.chainalysis.com/blog/) [verify 2026-10-29]
- TRM Labs annual report — [trmlabs.com/resources](https://www.trmlabs.com/resources) [verify 2026-10-29]
- Elliptic Typologies Report — [elliptic.co/insights/the-typologies-report](https://www.elliptic.co/insights/the-typologies-report/) [verify 2026-10-29]
- UN 1718 Committee Panel of Experts on DPRK — reports up to April 2024, when its mandate ended, document Lazarus / state-actor crypto activity (UN Security Council documents portal); since October 2024 the 11-state Multilateral Sanctions Monitoring Team (MSMT) monitors and reports DPRK sanctions evasion. [verify 2026-10-29]
- Krebs on Security — [krebsonsecurity.com](https://krebsonsecurity.com) [verify 2026-10-29]
- ZachXBT (open-source on-chain investigator) — Twitter/X feed; treat as crowdsourced intelligence with high signal but variable provenance. [verify 2026-10-29]
- The Block, CoinDesk, Coin Telegraph — industry press; useful for context.

### LE / regulator advisories

- OFAC Updated Advisory on Potential Sanctions Risks for Facilitating Ransomware Payments (2021-09-21; supersedes the 2020-10-01 advisory). [verify 2026-10-29]
- CISA #StopRansomware advisories — [cisa.gov/stopransomware](https://www.cisa.gov/stopransomware) [verify 2026-10-29]
- FinCEN advisories on convertible-virtual-currency — [fincen.gov](https://www.fincen.gov/) [verify 2026-10-29]
- FBI IC3 — [ic3.gov](https://www.ic3.gov/) [verify 2026-10-29]
- Europol IOCTA (annual Internet Organised Crime Threat Assessment) — [europol.europa.eu](https://www.europol.europa.eu/publications-events/main-reports/iocta-report) [verify 2026-10-29]
- NCA / NCSC UK — periodic advisories on crypto-asset crime.

### Vendor methodology references

- Chainalysis Reactor methodology pages — [chainalysis.com/blog](https://www.chainalysis.com/blog/) (search for "heuristics" and "clustering"). [verify 2026-10-29]
- TRM Labs methodology — [trmlabs.com/resources](https://www.trmlabs.com/resources) [verify 2026-10-29]
- Elliptic research and insights — [elliptic.co/insights](https://www.elliptic.co/insights/) [verify 2026-10-29]

---

**Version:** 1.0 (Initial)
**Last Updated:** 2026-10-29
**Review Frequency:** Quarterly (medium-rot — vendor product lineup, sanctions trajectory, bridge protocol churn, exchange / VASP status)
