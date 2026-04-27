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
updated: 2026-04-26
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
| Ethereum / EVM       | Ethereum, BSC, Polygon, Avalanche C-chain, Fantom              | Account      | Transparent          | Account-balance + internal-tx + token-tx   |
| EVM L2 (optimistic)  | Arbitrum, Optimism, Base                                       | Account (L2) | Transparent          | Pair via L1 deposit / withdrawal contracts  |
| EVM L2 (ZK)          | zkSync Era, Starknet, Scroll, Linea, Polygon zkEVM             | Account (L2) | Transparent          | Pair via L1 deposit / withdrawal contracts  |
| Non-EVM L1           | Solana, Tron (TRC-20), Aptos, Sui, NEAR, Cosmos (IBC zones)    | Account      | Transparent          | Chain-specific explorers; varied API depth  |
| Bitcoin-anchored     | XRPL, Stellar, Cardano, Polkadot relay + parachains            | Mixed        | Transparent          | Per-protocol explorer + ledger walk        |
| Privacy-default      | Monero (XMR), Zcash (z-addresses)                              | Ring / shield | Opaque on-chain      | Off-chain pivots only — see §3.4            |
| Optional-privacy     | Dash (PrivateSend), Decred (mixed)                             | UTXO + opt-in | Mixed                | Reduced clustering on opt-in, plain UTXO otherwise |

### 3.2 What changes when you switch chains

- **UTXO vs account.** UTXO chains (BTC family) require multi-input clustering and change-address detection to merge addresses into a wallet. Account chains (ETH family) treat each address as a wallet by default — clustering merges *addresses controlled by the same actor*, not "outputs that came from the same wallet." Different heuristic toolkit.
- **Token vs native value.** ERC-20 / TRC-20 / SPL token transfers are events emitted by token contracts, not native transfers. Etherscan's "Token Tracker" view, Tronscan's TRC-20 tab, and Solscan's SPL Token tab are required to see the value flow on tokenized chains. USDT (issued natively on TRC-20 and bridged to ETH, BSC, Solana, Polygon, Avalanche, etc.) is the dominant cross-chain stablecoin and frequent obfuscation vehicle.
- **Internal transactions.** EVM "internal" transactions are contract-call value transfers that do not appear in the top-level transaction list — they live in trace logs. Etherscan shows them under the "Internal Txns" tab; missing them misses contract-mediated flows.
- **L2 finality and bridging.** Optimistic rollups have a 7-day challenge window before withdrawals finalize on L1; ZK rollups finalize on each proof submission. Withdrawal flows therefore have very different on-chain timing patterns.
- **Block time and reorgs.** BTC ~10 min, ETH ~12 s, Solana ~400 ms, BSC ~3 s. Reorg risk for finality varies; for evidence purposes, wait for confirmations matching the chain's finality convention (BTC 6, ETH 32 / 2 epochs for finality, Solana 32 slots, etc.). [verify 2026-04-26]

### 3.3 Transparent vs privacy postures

Most chains are pseudonymous-but-transparent — every transaction, value, sender, recipient, and (on EVM) event log is in the public ledger forever. "Privacy" comes from *not knowing which real person controls a given address.* Investigation is fundamentally an attribution exercise.

Privacy-default chains are the exception:

- **Monero (XMR)** — RingCT (ring signatures + Pedersen commitments + stealth addresses). On-chain inputs ambiguous within a ring; values blinded; recipient one-time stealth addresses. Public reverse-engineering of Monero clustering has limited published success; assume on-chain tracing is **not** feasible for current ring sizes (16 by default, post-Bulletproofs+).  [verify 2026-04-26]
- **Zcash (z-addresses)** — sapling / orchard shielded pool. Shielded → shielded transactions are private; the bulk of historical Zcash usage is transparent (t-addresses) or shielded-to-transparent (z→t), which leaks the egress. Research (Kappos et al. 2018, Quesnelle 2017) demonstrated that pool-internal-only-transferring users were a small minority. [verify 2026-04-26]

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
| Avalanche C-chain      | [snowtrace.io](https://snowtrace.io/)                  | Etherscan-family                                                     |
| Solana                 | [solscan.io](https://solscan.io/) / [solana.fm](https://solana.fm/) | SPL token + program-call surfaces                       |
| Tron                   | [tronscan.org](https://tronscan.org/)                  | Critical for USDT-TRC20 flows                                        |
| XRPL                   | [xrpscan.com](https://xrpscan.com/) / [bithomp.com](https://bithomp.com/) | Account flagging, destination-tag analysis           |
| Cardano                | [cardanoscan.io](https://cardanoscan.io/)              | EUTxO model — different clustering shape                             |
| Polkadot               | [polkadot.subscan.io](https://polkadot.subscan.io/)    | Substrate-based; parachains have their own subscan deployments       |
| Cosmos hubs            | [mintscan.io](https://www.mintscan.io/)                | Multi-chain Cosmos / IBC                                             |
| NEAR                   | [nearblocks.io](https://nearblocks.io/)                | Account-based                                                        |
| Aptos / Sui            | [aptoscan.com](https://aptoscan.com/) / [suiscan.xyz](https://suiscan.xyz/) | Move-based chains                                       |

[verify 2026-04-26 — explorer URL stability]

### 4.2 Multi-chain aggregators

- **[Blockchair](https://blockchair.com/)** — universal search across BTC, ETH, BCH, LTC, DOGE, XLM, XRP, etc.; CSV export; query API (free tier rate-limited).
- **[Etherscan family](https://etherscan.io/)** — single login covers most EVM chains (ETH, BSC, Polygon, Arbitrum, Optimism, Base, Avalanche, Fantom, Cronos, etc.); shared API key.
- **[Arkham](https://platform.arkhamintelligence.com/)** — entity-labeled multi-chain explorer with profile pages on labeled wallets (DeFi protocols, exchanges, named individuals); free tier with login.
- **[DeBank](https://debank.com/)** — DeFi-portfolio aggregation per address across EVM chains; useful for "what is this wallet exposed to?" surface.
- **[Zapper](https://zapper.xyz/)** — similar DeFi aggregation surface.
- **[OnChainFX](https://messari.io/)** / **Messari** — protocol-level metrics; complement transaction-level work.

### 4.3 Public data feeds

- **Node-level RPC** — running a local archive node (Bitcoin Core full node + index, Erigon / Reth for Ethereum) gives query-side independence from explorers and removes the third-party log surface. High disk cost; appropriate for sustained investigation.
- **Public RPC endpoints** — Infura, Alchemy, QuickNode, Ankr publish RPC for major chains; useful for ad-hoc queries; logs requests against API keys (treat as an attribution surface).
- **Indexer APIs** — [The Graph](https://thegraph.com/), Subsquid, Goldsky for protocol-specific indexed data; less useful for raw tracing, more useful for protocol context.
- **Bulk data dumps** — [Google BigQuery public datasets](https://console.cloud.google.com/marketplace/browse?filter=solution-type:dataset) host BTC, ETH, BCH, LTC, DOGE, ZEC, polygon datasets refreshed near-real-time; ideal for SQL-style analytics on years of history at low marginal cost. [verify 2026-04-26]
- **Whale-alert / monitoring feeds** — [whale-alert.io](https://www.whale-alert.io) for large-transfer notifications; useful for situational awareness, not as primary evidence.

---

## 5. Address Clustering Heuristics

Clustering merges multiple on-chain addresses into a single hypothesized actor. Every heuristic is **probabilistic**; document confidence and the heuristic basis when reporting.

### 5.1 Common-input ownership (BTC / UTXO)

- **Heuristic:** addresses appearing as inputs in the same transaction are jointly controlled by the spender (common-input ownership).
- **Origin:** Meiklejohn et al. 2013 ("A Fistful of Bitcoins") — foundational paper formalizing this and other Bitcoin heuristics. [verify 2026-04-26]
- **Failure modes:** CoinJoin transactions (Wasabi, Samourai Whirlpool, JoinMarket) deliberately violate the assumption — multiple unrelated parties contribute inputs. Vendor tools mark CoinJoin transactions specifically; do not common-input-merge through them. PayJoin (BIP 78) similarly violates the heuristic.
- **Evidentiary weight:** moderate-to-high outside of CoinJoin contexts; commercial-tool clusters built on this assumption carry decades of operational confirmation but have been challenged in court (see §12).

### 5.2 Change-address detection (BTC / UTXO)

- **Heuristic:** of the outputs in a transaction, one is the recipient and one is "change" returning to the spender. Several sub-heuristics identify the change output:
  - **Fresh-address heuristic** — change goes to a previously-unseen address.
  - **Round-number heuristic** — recipient amount is a "human" round number; change is the remainder.
  - **Script-type heuristic** — change matches the input script type (P2PKH inputs → P2PKH change; P2WPKH inputs → P2WPKH change). Wallet software preserves type for change.
  - **Output-position heuristic** — many wallets place change first or last consistently.
- **Combination:** no single sub-heuristic is reliable in isolation; vendors combine multiple. Open-source frameworks (BlockSci, GraphSense) document their combinations.
- **Failure modes:** mixers, batched payment processors, exchange-internal sweeps, and modern wallet software with deliberate change-pattern obfuscation (Wasabi, Samourai) all break individual sub-heuristics.

### 5.3 Peeling chains (BTC / ETH)

- **Pattern:** a single large balance is repeatedly split into a small "peel" payment + the remaining balance, often hopping through fresh addresses each step.
- **Indicator:** chain of transactions where one output is small and one output is large; the large output becomes the next transaction's input.
- **Use:** a peel chain on the receiving side of a known illicit address suggests structuring or wallet-internal sweeping. Length and rhythm are signal — automated peel chains are very regular; manual ones are not.

### 5.4 Account clustering (ETH / EVM)

- **Heuristic:** EVM addresses controlled by the same EOA (externally owned account) cluster around interaction patterns:
  - **Common-funding heuristic** — a single funding source (often a CEX hot wallet) deposits into multiple addresses; if those addresses then transact among themselves, they likely share a controller.
  - **Gas-payer heuristic** — a sponsor address pays gas for multiple recipients (especially with EIP-4337 account abstraction or sponsored-transaction patterns) — gas-payer is not necessarily the controller, but is a strong signal.
  - **Token-approval heuristic** — addresses that grant unlimited token approvals to the same contract pair are probably operationally linked.
  - **Reused method-call patterns** — wallet "fingerprints" via the sequence of contract calls (DeFi-protocol routing, NFT mint patterns).
- **Cluster shape:** account chains rarely produce the dense merge you see on UTXO chains; clusters are often graph neighborhoods, not single super-clusters.

### 5.5 Exchange-deposit clustering

- **Pattern:** centralized exchanges issue per-customer deposit addresses. Funds deposited into a customer's address are swept into the exchange's hot-wallet system shortly after.
- **Identification:** the deposit address has one or two inflows and a single outflow to a known exchange hot-wallet cluster.
- **Use:** identifying that a target's funds entered via a specific exchange deposit address links the target to a (subpoena-able) exchange account. The exchange holds the KYC.
- **Caveat:** some exchanges (especially those using shared addresses with destination tags — XRPL, Stellar, EOS, BSC-with-memo) do **not** issue per-customer addresses; the destination tag / memo carries customer routing.

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
| Wormhole               | `LogMessagePublished` from core bridge            | `TransferRedeemed` on destination               | Sequence number + emitter chain + emitter addr    |
| LayerZero (v1 / v2)    | `Packet` (v1) / `PacketSent` (v2)                | `PacketReceived` / executor delivery            | Nonce + src chain + dst chain + sender / receiver  |
| Stargate (LayerZero-based) | OFT / pool token transfer                     | OFT mint on destination                         | LayerZero nonce + Stargate pool ID                |
| Synapse                | `TokenDeposit` / `TokenRedeem` on bridge router  | `TokenMint` / `TokenWithdraw` on destination    | Nonce + kappa hash                                |
| Across                 | `FundsDeposited` from spoke pool                  | `FilledRelay` (relayer fills)                  | Deposit ID + source chain + destination chain     |
| THORChain              | Inbound observation TX                            | Outbound observation TX                         | Inbound TX hash → outbound TX hash via Midgard / THORNode |
| Hop                    | `TransferSent` on source                          | `TransferFromL1Completed` / bonder relay        | Transfer ID                                       |
| cBridge (Celer)        | `Send` event                                      | `Relay` event                                   | Transfer ID                                       |
| Multichain (deprecated) | `LogAnySwapOut`                                  | `LogAnySwapIn`                                  | Swap ID (multichain dissolved 2023; legacy bridges still queryable) [verify 2026-04-26] |
| Ronin Bridge (Axie)    | `DepositRequested` on Ethereum                    | `Deposit` on Ronin                              | Receipt ID                                        |
| Polygon PoS bridge     | `LockedERC20` on Ethereum                         | `Deposit` (state sync) on Polygon               | Deposit count + state sync ID                     |
| Arbitrum native bridge | `OutboxTransactionExecuted` (withdrawal) / `MessageDelivered` (deposit) | matching L1 / L2 events             | Message index + sequencer batch                   |
| Optimism native bridge | `SentMessage` / `RelayedMessage`                  | matching cross-domain message                  | Message hash                                      |
| Hyperlane              | `Dispatch`                                        | `Process`                                       | Message ID + origin domain + destination domain   |

[verify 2026-04-26 — bridge contract addresses, event names, and protocol versions update frequently; treat the table as a starting point and verify event signature against the deployed contract before reporting.]

### 6.3 Practical pairing workflow

1. **Identify the bridge** by the source-side contract address. The bridge protocol's documentation lists official deployments per chain. Phishing / spoofed bridges exist; verify the contract address against the canonical list.
2. **Decode the source event** — extract the recipient (destination chain + destination address), value, token, and unique sequence / nonce / deposit ID.
3. **Locate the destination chain.** Bridge events typically encode the destination chain ID; look up the matching deployment.
4. **Search the destination contract** for the matching event using the sequence / nonce / deposit ID. Most bridges expose an indexer (Wormhole's [wormholescan.io](https://wormholescan.io/), LayerZeroscan, Stargate's explorer, THORChain's [thorchain.net](https://thorchain.net/) or Midgard).
5. **Document both events** — source TX hash, destination TX hash, value, token, sequence ID. Capture the bridge indexer page if used.
6. **Continue the trace on the destination chain.** The destination event identifies the receiving address; that address becomes the next clustering / pivot target.

### 6.4 Bridge-specific pitfalls

- **Wormhole guardian-network compromise (2022-02-02):** ~120K wETH minted from a forged guardian signature; destination-side mint exists with no legitimate source-side event. Always confirm the source-side event actually exists. [verify 2026-04-26]
- **Multichain (Anyswap) collapse (July 2023):** assets stranded; cross-references to legacy Multichain transfers may dead-end at the protocol's failure date. Note the protocol-status at observation time.
- **Ronin validator compromise (2022-03-23):** $625M USD stolen via 5/9 validator key compromise; outbound bridge events on Ronin without inbound deposit confirmations on Ethereum. Treasury / FBI attributed to DPRK (Lazarus). [verify 2026-04-26]
- **Nomad bridge exploit (2022-08-01):** "free-for-all" replay of a routine event after an initialization bug; subsequent in-and-out flows on both chains do not represent legitimate user transfers.
- **Bridge nonce collisions** (rare) — protocol versions or chain redeployments can produce duplicate sequence numbers; always disambiguate by chain-of-deployment + version.
- **Wrapped-asset reuse.** A single user transferring `wBTC` on Ethereum, bridging to Polygon, swapping to USDC on Polygon, bridging USDC to Arbitrum — produces five contract-event pairs to follow. Tooling that stops at the first hop loses the trail.

### 6.5 Useful bridge indexers

- [wormholescan.io](https://wormholescan.io/) — Wormhole transfers, queryable by sequence, token, address, chain pair. [verify 2026-04-26]
- [layerzeroscan.com](https://layerzeroscan.com/) — LayerZero packets across deployed chains. [verify 2026-04-26]
- [thorchain.net](https://thorchain.net/) / [Midgard API](https://midgard.ninerealms.com/) — THORChain swaps with inbound / outbound TX pairing. [verify 2026-04-26]
- [bungee.exchange](https://www.bungee.exchange/) (Socket) and [li.fi explorer](https://li.fi/) — multi-bridge / multi-DEX route surfaces; useful for understanding which bridges a route used. [verify 2026-04-26]
- [Across explorer](https://across.to/) — Across deposit / fill explorer.
- [Hop explorer](https://explorer.hop.exchange/) — Hop transfers.
- [Stargate explorer](https://stargate.finance/transfer) — Stargate (LayerZero) flows.

---

## 7. Sanctions Integration

### 7.1 OFAC SDN Digital Currency Address (DCA) regime

- **Authority:** US Treasury Office of Foreign Assets Control (OFAC) administers the Specially Designated Nationals (SDN) list. Since 2018, individual cryptocurrency addresses have been listed as DCA entries appended to SDN profiles, tagged by currency code (`XBT`, `ETH`, `USDT`, `USDC`, `XMR`, `BSV`, `ZEC`, `LTC`, `DASH`, `ETC`, `XRP`, etc.). [verify 2026-04-26]
- **Source feeds:**
  - HTML search: [sanctionssearch.ofac.treas.gov](https://sanctionssearch.ofac.treas.gov/)
  - Bulk data: [OFAC sanctions list service](https://sanctionslistservice.ofac.treas.gov/) (XML / CSV / JSON; daily updates) [verify 2026-04-26]
  - File finder (legacy): [ofac.treasury.gov/file-finder](https://ofac.treasury.gov/file-finder)
- **Investigative use:**
  - Screen every wallet observed in scope against the latest SDN feed (cache locally; refresh daily for active investigations).
  - Cluster screening — if any address in a cluster matches SDN, the **wallet** is sanctions-implicated; report cluster membership with evidence.
  - **Time-stamp every sanctions finding.** Designations are added and removed; the legal posture at the time of activity is what matters.
- **Notable trajectory: Tornado Cash.** Listed 2022-08-08 (the first smart-contract address designations); contested in court; 5th Circuit *Van Loon v. Treasury* ruled 2024-11-26 that immutable smart contracts are not "property" subject to OFAC blocking; Treasury removed the Tornado Cash sanctions 2025-03-21. [verify 2026-04-26] Tornado Cash addresses post-delist are no longer SDN, but historical activity during the listed period remains a sanctions exposure.

### 7.2 EU sanctions and TFR / MiCA

- **EU consolidated list:** [sanctionsmap.eu](https://www.sanctionsmap.eu/) (consolidated EU restrictive measures); [EU Financial Sanctions Database](https://webgate.ec.europa.eu/fsd/fsf) (machine-readable).
- **Transfer of Funds Regulation (TFR) / MiCA crypto-asset transfer rules:** since 2024-12-30, all crypto-asset transfers between Crypto-Asset Service Providers (CASPs) must carry originator and beneficiary information regardless of value (no de minimis). Self-hosted-wallet transfers above EUR 1,000 trigger additional verification by the CASP. [verify 2026-04-26]
- **MiCA broader:** Markets in Crypto-Assets Regulation (Regulation (EU) 2023/1114); titles applicable to issuers from June 2024, to CASPs from December 2024. Cross-border CASP supervision is via the home-state regulator with EBA / ESMA oversight.

### 7.3 UK OFSI and other regimes

- **UK:** Office of Financial Sanctions Implementation publishes the [UK Sanctions List](https://www.gov.uk/government/publications/financial-sanctions-consolidated-list-of-targets); FCA supervises crypto-AML registration under the Money Laundering Regulations 2017 (as amended).
- **UN:** UN Security Council [consolidated list](https://www.un.org/securitycouncil/sanctions/information).
- **Other major regimes:** Canada (OSFI / Global Affairs), Australia (DFAT consolidated list), Switzerland (SECO), Japan (METI), Singapore (MAS), South Korea (FIU).
- **OpenSanctions** ([opensanctions.org](https://www.opensanctions.org/)) aggregates the major lists and publishes a normalized data feed; useful for cross-jurisdiction screening.

### 7.4 FATF Travel Rule (Recommendation 16)

- Virtual Asset Service Providers (VASPs) — exchanges, custodial wallets, OTC desks — are required by FATF Recommendation 16 to collect and transmit originator / beneficiary information for crypto transfers above a jurisdiction-specific threshold.
  - **US (FinCEN):** USD 3,000 threshold; lower threshold proposals pending. [verify 2026-04-26]
  - **EU (TFR / MiCA):** No de minimis on inter-CASP transfers from 2024-12-30; self-hosted threshold EUR 1,000. [verify 2026-04-26]
  - **UK (FCA):** GBP 1,000 originator-side trigger.
  - **Singapore / Switzerland / Japan / South Korea:** thresholds and protocols vary; check the local FIU guidance.
- **Implementations:** TRP, IVMS101 data standard, Sygna Bridge, Notabene, Veriscope, Shyft. Vendor lineup shifts; verify per engagement. [verify 2026-04-26]
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

- **[Chainalysis](https://www.chainalysis.com/)** — market-leading; products include **Reactor** (case-based investigation interface), **KYT** (transaction monitoring for VASPs / banks), **Crypto Investigations Solution** (LE-tier), and **Storyline** (DeFi-flow visualization). Heaviest LE / regulator adoption. Defense bar has scrutinized Reactor heuristics in court (Sterlingov, §12).
- **[TRM Labs](https://www.trmlabs.com/)** — TRM Forensics (investigation), TRM Risk APIs (compliance integration). Strong LE adoption, especially US federal.
- **[Elliptic](https://www.elliptic.co/)** — Elliptic Investigator, Lens, Navigator. Strong UK / EU adoption.
- **[Crystal Intelligence](https://crystalintelligence.com/)** — formerly Bitfury-affiliated; spun out 2023. Multi-chain analytics + sanctions screening.
- **[Arkham](https://www.arkhamintelligence.com/)** — entity-labeled platform with bounty marketplace for attribution data; free tier available. Treat labels as crowdsourced intelligence (variable quality), not vendor-attested attribution.
- **[Merkle Science](https://www.merklescience.com/)** — Tracker (investigation), Compass (VASP compliance).
- **[Coinfirm](https://www.coinfirm.com/)** — AML Risk Reports.
- **[Nansen](https://www.nansen.ai/)** — primarily DeFi analytics with smart-money labeling; useful for context, not core tracing.

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

- **CipherTrace** — acquired by Mastercard 2021; product effectively wound down by 2024. Replaced internally by Mastercard Crypto Secure / Crypto Credential. Treat any contemporary "CipherTrace" reference as legacy. [verify 2026-04-26]
- **Wallet Explorer** — long-standing free Bitcoin clustering site by Aleš Janda; acquired by Chainalysis but still publicly accessible at [walletexplorer.com](https://www.walletexplorer.com/). [verify 2026-04-26]
- **OXT.me** — Samourai-affiliated open Bitcoin analytics; status uncertain post-2024 enforcement against Samourai founders. [verify 2026-04-26]

---

## 9. Open-Source Analytics Workflows

Open-source tooling does not match commercial coverage, but it is **independently reproducible** — a critical evidentiary property (§12).

### 9.1 GraphSense

- **What it is:** Open-source crypto-asset analytics platform (AIT / Iknaio). Multi-chain support (BTC, BCH, LTC, ZEC, ETH).
- **What it gives you:** Clustering, attribution tags, transaction graph, neighborhood analytics — same conceptual model as commercial tools.
- **Where:** [graphsense.info](https://graphsense.info/) [verify 2026-04-26]; documentation and self-hosted deployment guides available.
- **Tradeoff:** Significant infrastructure overhead (full-node ingest, ETL pipeline). Pays off for sustained investigation; overkill for one-off lookups.

### 9.2 Breadcrumbs

- **What it is:** Free-tier blockchain visualization with address labeling and graph navigation.
- **Where:** [breadcrumbs.app](https://www.breadcrumbs.app/) [verify 2026-04-26]
- **Use case:** Quick visual investigation, sharing graphs with non-analyst stakeholders.

### 9.3 BlockSci-style direct ledger queries

- **BlockSci** (Harrigan / Goldfeder / Narayanan, Princeton) — academic Bitcoin analytics framework. Project status post-2021 unclear; replaced in many workflows by direct BigQuery / Erigon-traces / Reth queries. [verify 2026-04-26]
- **Approach:** Run a full archive node (Bitcoin Core + index, Erigon for ETH) and query directly. Highest fidelity, highest setup cost.
- **BigQuery alternative:** Google's [public datasets for crypto](https://console.cloud.google.com/marketplace/browse?filter=solution-type:dataset) (BTC, BCH, LTC, DOGE, ZEC, ETH, Polygon) refresh near-real-time and support SQL analytics over years of history. [verify 2026-04-26]

### 9.4 Manual workflow with explorers + scripts

- For small investigations, the explorer-scrape + CSV-export + Python notebook workflow is sufficient.
- Etherscan, Blockchair, Tronscan, Solscan all expose CSV export and / or API endpoints (rate-limited; key required for higher tiers).
- Common library combinations: `web3.py` / `ethers.js` for EVM RPC, `python-bitcoinrpc` for Bitcoin RPC, `solana-py` for Solana, custom clients for Tron and others.
- Notebook discipline: capture the input addresses, the queries, the responses, and the analytical reasoning. Notebooks are reproducible artifacts.

### 9.5 Address-labeling collaborative resources

- **[OFAC SDN](https://sanctionssearch.ofac.treas.gov/)** — sanctions addresses (authoritative for sanctions; use bulk feed).
- **[Chainabuse](https://www.chainabuse.com/)** — community scam / abuse reporting.
- **[Etherscan label cloud](https://etherscan.io/labelcloud)** — public labels for ETH / EVM addresses.
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
- **Memo / tag chains** (XRPL, Stellar, EOS, Cosmos, BSC-with-memo): single shared address with destination tag / memo per customer. Tag-based pivots require subpoena to the VASP for tag-to-customer mapping.

### 10.2 Documenting an exchange pivot

For each exchange-side finding:

- **Exchange identification** — which VASP, which jurisdiction, which regulator (FCA, FinCEN, BaFin, MAS, etc.).
- **Address evidence** — the specific deposit / withdrawal address tied to the VASP cluster, with cluster basis.
- **Time window** — when the activity occurred (relevant for KYC vintage and for VASP retention windows).
- **Transaction list** — TX hashes, values, tokens.
- **Travel Rule applicability** — was the transfer above the originating-jurisdiction threshold? Was the destination a participating VASP? This shapes the data the VASP holds.

### 10.3 Subpoena / regulator pathway

- **US:** FinCEN MSB registration (banks / VASPs); subpoena via DOJ, IRS-CI, FBI; international via MLAT.
- **EU:** CASP registration under MiCA; data requests via national FIU + Europol; cross-border via judicial cooperation regulations.
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

- **P2P platforms** (LocalBitcoins-successor sites, Paxful, Bisq, RoboSats) — variable KYC; some require none.
- **OTC desks** — high-value, often light-KYC; jurisdiction-dependent.
- **Crypto ATMs** — KYC requirements vary by jurisdiction (US BSA-registered; EU MiCA-aligned; many jurisdictions inconsistent enforcement).
- **No-KYC swap services** — FixedFloat, ChangeNOW, SimpleSwap; aggressive disclaimers that they do not collect identity data. (Some have been compelled to produce records under legal process anyway.)
- **DEX aggregators** — 1inch, ParaSwap, OpenOcean, CoW Swap; pure on-chain swaps with no KYC. Trace continues on-chain.

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

- Cross-check every input address against SDN (OFAC), EU, UK OFSI, UN consolidated lists.
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

- Build the entity-relationship graph (Maltego, Neo4j, draw.io, Breadcrumbs, Arkham, Chainalysis Reactor — match the deliverable).
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

- **Defendant:** Roman Sterlingov (Russian-Swedish dual national).
- **Charge:** Operating Bitcoin Fog mixer 2011-2021; money laundering, conspiracy, sanctions, unlicensed money-transmission counts.
- **Arrest:** 2021-04-27 at LAX. [verify 2026-04-26]
- **Conviction:** 2024-03-12, SDNY federal jury verdict on all counts. [verify 2026-04-26]
- **Sentence:** 2024-11-08, 12 years 6 months imprisonment. [verify 2026-04-26]
- **Defense thesis:** Government's identification of Sterlingov as the Bitcoin Fog operator rested heavily on Chainalysis Reactor's heuristic clustering. Defense argued (with expert testimony and academic critique) that the clustering heuristics were probabilistic, error-prone, and inadequate to meet the criminal-conviction bar without independent corroboration.
- **Court posture:** Pre-trial Daubert challenge to Chainalysis Reactor admissibility was largely resolved in the government's favor, with the court permitting Reactor analysis but allowing defense cross-examination on heuristic limitations. The conviction proceeded.
- **What it changed:** Subsequent prosecutions and asset-recovery actions face a documented playbook for attacking heuristic-based clustering. Practitioners building court-bound findings should expect every cluster, label, and inference to be challenged on:
  - The specific heuristic applied
  - The vendor's documented error rate (where published)
  - Independent reproducibility
  - Counter-evidence within the cluster
  - Vendor-tool version and methodology version

### 12.2 Daubert posture

Under *Daubert v. Merrell Dow Pharmaceuticals* (US federal courts) and analogous standards (UK Civil Evidence Act / R v Bonython criteria; EU Member State equivalents), expert testimony must rest on:

- Methodology that is testable.
- Methodology that has been peer-reviewed.
- Known error rate.
- Standards governing operation.
- General acceptance in the relevant scientific community.

Open-source heuristics (Meiklejohn 2013 and subsequent academic literature) satisfy peer-review criteria. Proprietary vendor heuristics are weaker on peer-review but satisfy general-acceptance via wide LE / regulator adoption. The gap is **error rate** — published vendor error rates are sparse, and that is where defense challenges concentrate.

### 12.3 Tradecraft for court-bound findings

- **Document the heuristic basis** for every cluster claim. "Chainalysis Reactor identified" is not enough; specify the heuristic family.
- **Independently reproduce** key clusters using open-source methods. A finding corroborated by GraphSense + Chainalysis + manual common-input analysis is far stronger than a finding from any single source.
- **Capture raw on-chain data** — the underlying transactions are facts; cluster labels are interpretations. The factual record survives if interpretations are challenged.
- **Pin tool versions** — vendor heuristic outputs are version-dependent; record the version.
- **Disclose limitations** in your own report. Hidden weaknesses are more damaging in cross-examination than disclosed ones.
- **Time-stamp sanctions findings** — designations change; report the SDN posture at the time of activity.
- **Chain of custody** — apply [[sop-collection-log|Collection Log]] discipline. SHA-256 hash artifacts; preserve OpenTimestamps where appropriate; maintain an unbroken collection chain.

### 12.4 Expert-witness considerations

- The analyst preparing court-bound findings should be qualified to testify if called. Vendor-tool training and certifications (Chainalysis Cryptocurrency Investigations Certification, TRM Labs Cryptocurrency Investigator Certification, CryptoCurrency Security Standard) carry weight; academic publications and operational case-history more.
- Know the methodology you are presenting. Cross-examination will probe the heuristic; "the tool said so" is a weak position.
- Distinguish between what the data shows and what the cluster label asserts. Conflating them is a recurring cross-examination opening.

### 12.5 Other notable cases (situational awareness)

- **Bitfinex 2016 hack — Heather Morgan / Ilya Lichtenstein:** $4.5B BTC seized 2022-02-08 in connection with the 2016 Bitfinex hack of 119,754 BTC. Both pleaded guilty August 2023; Lichtenstein sentenced 2024-11 to 5 years; Morgan sentenced 2024-11 to 18 months. [verify 2026-04-26] Demonstrates years-long tracing across address-laundering and exchange interactions.
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
| Mixer entry (Tornado Cash, Wasabi CoinJoin, JoinMarket, Whirlpool, Sinbad, etc.)         | [[sop-mixer-tracing|Mixer & Privacy-Pool Tracing]]                                                                                                                              |
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
| OFAC SDN search (HTML)           | [sanctionssearch.ofac.treas.gov](https://sanctionssearch.ofac.treas.gov/) | Daily-refresh interactive search             |
| OFAC sanctions list service      | [sanctionslistservice.ofac.treas.gov](https://sanctionslistservice.ofac.treas.gov/) | XML / CSV / JSON bulk feed [verify 2026-04-26] |
| EU Sanctions Map                 | [sanctionsmap.eu](https://www.sanctionsmap.eu/)             | EU consolidated                              |
| EU Financial Sanctions DB        | [webgate.ec.europa.eu/fsd/fsf](https://webgate.ec.europa.eu/fsd/fsf) | Machine-readable                             |
| UK OFSI list                     | [gov.uk/government/publications/financial-sanctions-consolidated-list-of-targets](https://www.gov.uk/government/publications/financial-sanctions-consolidated-list-of-targets) | UK consolidated list                          |
| UN Security Council Sanctions    | [un.org/securitycouncil/sanctions/information](https://www.un.org/securitycouncil/sanctions/information) | UN consolidated                              |
| OpenSanctions                    | [opensanctions.org](https://www.opensanctions.org/)         | Aggregated multi-jurisdiction; open data     |

### 15.4 Commercial analytics

| Vendor            | Primary product               | URL                                                        |
| ----------------- | ----------------------------- | ---------------------------------------------------------- |
| Chainalysis       | Reactor / KYT                 | [chainalysis.com](https://www.chainalysis.com/)             |
| TRM Labs          | Forensics / Risk APIs         | [trmlabs.com](https://www.trmlabs.com/)                     |
| Elliptic          | Investigator / Lens           | [elliptic.co](https://www.elliptic.co/)                     |
| Crystal Intelligence | Multi-chain analytics      | [crystalintelligence.com](https://crystalintelligence.com/) |
| Arkham            | Entity-labeled platform       | [arkhamintelligence.com](https://www.arkhamintelligence.com/) |
| Merkle Science    | Tracker / Compass             | [merklescience.com](https://www.merklescience.com/)         |
| Coinfirm          | AML Risk Reports              | [coinfirm.com](https://www.coinfirm.com/)                   |
| Nansen            | DeFi smart-money labels       | [nansen.ai](https://www.nansen.ai/)                         |

### 15.5 Open-source analytics

| Tool / Resource     | Purpose                                          | URL                                                |
| ------------------- | ------------------------------------------------ | -------------------------------------------------- |
| GraphSense          | Open-source multi-chain analytics + clustering   | [graphsense.info](https://graphsense.info/) [verify 2026-04-26] |
| Breadcrumbs         | Free blockchain visualization                    | [breadcrumbs.app](https://www.breadcrumbs.app/)     |
| Wallet Explorer     | Bitcoin clustering UI                            | [walletexplorer.com](https://www.walletexplorer.com/) |
| OXT.me              | Bitcoin analytics (Samourai-affiliated; status uncertain) | [oxt.me](https://oxt.me/) [verify 2026-04-26]    |
| BigQuery public crypto datasets | Bulk SQL analytics over BTC/ETH/etc.    | [console.cloud.google.com](https://console.cloud.google.com/marketplace/browse?filter=solution-type:dataset) |
| The Graph           | Subgraph indexing for protocol context           | [thegraph.com](https://thegraph.com/)                |
| Chainabuse          | Community scam/abuse reporting                   | [chainabuse.com](https://www.chainabuse.com/)        |

### 15.6 Node software (self-hosted RPC)

| Software        | Chain    | Notes                                                |
| --------------- | -------- | ---------------------------------------------------- |
| Bitcoin Core    | BTC      | Full node + `txindex=1` for arbitrary TX queries     |
| Erigon          | ETH      | Archive node with traces                             |
| Reth            | ETH      | Rust-implemented archive node (newer)                |
| Geth            | ETH      | Reference EVM client                                 |
| Solana validator| Solana   | High disk I/O; consider RPC providers                |
| TRON node       | Tron     | `java-tron`                                          |

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

- **Sanctions trajectories shift** — Tornado Cash 2022→2024→2025 illustrates that the legal posture of a single contract has changed three times. Always time-stamp.
- **Vendor product lineup shifts** — CipherTrace acquired and wound down; other vendors merge / re-brand. Tool capability at engagement time must be confirmed.
- **Bridge protocol updates** — event names and contract addresses change between versions; always verify against the current canonical deployment.
- **Exchange / VASP status** — exchanges fail, get sanctioned (Garantex), get acquired, exit jurisdictions. Relationships at the time of activity are what matter.

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
- ❌ **Attributing clusters to nation-state groups based on vendor labels alone.** Lazarus / APT38 / DPRK-cluster attribution typically requires multiple corroborating sources (Chainalysis + TRM + UN PoE reporting + FBI/CISA joint advisories).
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
3. Sanctions screen against OFAC SDN, EU, UK OFSI; cluster-screen as well as address-screen.
4. Trace the outflow forward — exchange deposit? Mixer entry (hand off to [[sop-mixer-tracing|Mixer & Privacy-Pool Tracing]])? Bridge to another chain (pair per §6 and continue)?
5. If outflow reaches a known VASP, package the evidence per §10.2 and route to LE for legal-process pursuit.
6. Coordinate with [[../../Security/Analysis/sop-malware-analysis|Malware Analysis]] on the binary IOCs — same actor, complementary evidence.
7. Time-stamp every sanctions finding — was the destination cluster SDN-listed at time of payment? OFAC has issued advisories on ransomware payments to designated groups (2020 OFAC ransomware advisory, updated 2021 and beyond). [verify 2026-04-26]

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

1. Confirm the SDN designation and the address-to-group attribution (vendor labels + open-source corroboration + UN PoE / OFAC documentation).
2. Cluster the address; identify the broader operational wallet.
3. Trace inflows — victim payments (each victim payment is an investigative thread), affiliate splits, conversion paths.
4. Trace outflows — identify the exit pattern. State-actor groups have historically used:
   - Cross-chain bridges (often THORChain) to Bitcoin
   - OTC desks in jurisdictions with weak enforcement
   - DEX-only paths to avoid VASPs
   - Privacy-coin conversion (Monero) [verify 2026-04-26]
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

- **US ransomware / sanctions exposure:** OFAC compliance hotline; FBI IC3 (`ic3.gov`); CISA `report@cisa.gov`.
- **EU:** Europol European Cybercrime Centre (EC3); national CERT; national FIU.
- **UK:** Action Fraud (`actionfraud.police.uk`); NCA NCSC Reporting; FCA for regulated entities.
- **Trafficking / CSAM funding:** route per [[sop-sensitive-crime-intake-escalation|Sensitive Crime Intake & Escalation]].
- **Exchange freeze requests:** maintain a contact list of active exchange LE-channels for the engagement; many require pre-existing relationships.

Cross-link [[sop-sensitive-crime-intake-escalation|Sensitive Crime Intake & Escalation]] for the canonical escalation matrix; this section is a pointer.

---

## 20. Related SOPs

- [[sop-legal-ethics|Legal & Ethics]] — canonical legal framework; review before every engagement
- [[sop-opsec-plan|OPSEC Plan]] — investigator OPSEC, environment isolation, query-attribution discipline
- [[sop-collection-log|Collection Log]] — chain-of-custody, hashing, timestamping, FRE 902(13)/(14) framing
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
- **Sanctions discipline.** Screen against OFAC, EU, UK OFSI, UN at minimum; many SDN crypto entries are not in non-US lists. Time-stamp every finding — sanctions designations change over time, and the legal posture at the time of activity is what matters.
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

- Meiklejohn et al. 2013 — *A Fistful of Bitcoins: Characterizing Payments Among Men with No Names* (foundational clustering-heuristic paper). [verify 2026-04-26]
- Ron & Shamir 2013 — *Quantitative Analysis of the Full Bitcoin Transaction Graph*.
- Kappos, Yousaf, Maller, Meiklejohn 2018 — *An Empirical Analysis of Anonymity in Zcash*.
- Quesnelle 2017 — *On the linkability of Zcash transactions*.
- Möser et al. 2017 — *An Empirical Analysis of Traceability in the Monero Blockchain*.
- BlockSci (Harrigan / Kalodner / Moser / Goldfeder / Narayanan, Princeton) — academic Bitcoin analytics framework; project status post-2021 unclear. [verify 2026-04-26]

### Standards and frameworks

- FATF — Recommendation 16 (Travel Rule); Updated Guidance for a Risk-Based Approach to Virtual Assets and VASPs (2021). [fatf-gafi.org](https://www.fatf-gafi.org/) [verify 2026-04-26]
- Egmont Group — FIU coordination.
- Wolfsberg Group — financial-institution AML guidance.
- IVMS101 — Travel Rule data interchange standard.
- CCSS (CryptoCurrency Security Standard) — enterprise crypto security baseline.
- NIST SP 800-86 — Integrating Forensic Techniques into Incident Response (see [[sop-collection-log|Collection Log]] §"Standards & Frameworks").
- Berkeley Protocol on Digital Open Source Investigations (UN OHCHR 2022) — see [[sop-legal-ethics|Legal & Ethics]] §"International framework."

### Investigative journalism and research

- Chainalysis Crypto Crime Report (annual) — [chainalysis.com/blog](https://www.chainalysis.com/blog/) [verify 2026-04-26]
- TRM Labs annual report — [trmlabs.com/resources](https://www.trmlabs.com/resources) [verify 2026-04-26]
- Elliptic Typologies report — [elliptic.co/resources](https://www.elliptic.co/resources) [verify 2026-04-26]
- UN Panel of Experts on DPRK — annual reports document Lazarus / state-actor crypto activity; available via UN Security Council documents portal. [verify 2026-04-26]
- Krebs on Security — [krebsonsecurity.com](https://krebsonsecurity.com)
- ZachXBT (open-source on-chain investigator) — Twitter/X feed; treat as crowdsourced intelligence with high signal but variable provenance. [verify 2026-04-26]
- The Block, CoinDesk, Coin Telegraph — industry press; useful for context.

### LE / regulator advisories

- OFAC ransomware advisory (2020; updated 2021 and beyond) — sanctions risk for ransomware payments. [verify 2026-04-26]
- CISA #StopRansomware advisories — [cisa.gov/stopransomware](https://www.cisa.gov/stopransomware) [verify 2026-04-26]
- FinCEN advisories on convertible-virtual-currency — [fincen.gov](https://www.fincen.gov/)
- FBI IC3 — [ic3.gov](https://www.ic3.gov/)
- Europol IOCTA (annual Internet Organised Crime Threat Assessment) — [europol.europa.eu](https://www.europol.europa.eu/) [verify 2026-04-26]
- NCA / NCSC UK — periodic advisories on crypto-asset crime.

### Vendor methodology references

- Chainalysis Reactor methodology pages — [chainalysis.com/blog](https://www.chainalysis.com/blog/) (search for "heuristics" and "clustering"). [verify 2026-04-26]
- TRM Labs methodology — [trmlabs.com/resources](https://www.trmlabs.com/resources) [verify 2026-04-26]
- Elliptic — [elliptic.co/learn](https://www.elliptic.co/learn) [verify 2026-04-26]

---

**Version:** 1.0 (Initial)
**Last Updated:** 2026-04-26
**Review Frequency:** Quarterly (medium-rot — vendor product lineup, sanctions trajectory, bridge protocol churn, exchange / VASP status)
