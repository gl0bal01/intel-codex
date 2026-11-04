---
type: sop
title: Smart Contract Audit SOP
description: "Smart contract audit lifecycle: threat modeling, defect taxonomy (SWC), vulnerability classes (reentrancy / oracle / MEV / upgrade / governance), tooling (Slither / Echidna / Foundry / Halmos), formal verification (Certora / SMTChecker / K), audit-report structure, remediation verification, and multi-chain coverage."
tags:
  - sop
  - smart-contract
  - audit
  - blockchain
  - defi
  - security-review
  - formal-verification
created: 2026-04-26
updated: 2026-11-04
template_version: 2026-04-26
---

# Smart Contract Audit SOP

> **Authorized environments only.** Smart contract security review is a defensive discipline. This SOP covers engagement-scoped audit work on code the auditor is paid or otherwise authorized to review, internal pre-deployment review of code your team owns, public audit-contest participation under platform terms, and academic / educational analysis of public source. It does **not** authorize unauthorized testing of deployed contracts, on-chain exploitation, weaponizing PoCs against live systems, or post-exploit fund movement. Cross-references: [[sop-legal-ethics|Legal & Ethics]] for jurisdictional framing, [[sop-opsec-plan|OPSEC]] for handling artifacts and infrastructure, [[../Pentesting/sop-vulnerability-research|Vulnerability Research]] for general offensive methodology, [[../Pentesting/sop-bug-bounty|Bug Bounty]] for program-specific submission rules. Post-exploit fund tracing routes to [[../../Investigations/Techniques/sop-blockchain-investigation|Blockchain Investigation]]; mixer-defeat methodology routes to [[../../Investigations/Techniques/sop-mixer-tracing|Mixer & Privacy-Pool Tracing]].

## Table of Contents

1. [Objectives & Scope](#1-objectives--scope)
2. [Pre-Engagement & Authorization](#2-pre-engagement--authorization)
3. [Audit Lifecycle](#3-audit-lifecycle)
4. [Threat Modeling for Smart Contracts](#4-threat-modeling-for-smart-contracts)
5. [Defect Taxonomy & SWC Registry](#5-defect-taxonomy--swc-registry)
6. [Vulnerability Classes](#6-vulnerability-classes)
7. [Static & Linting Tooling](#7-static--linting-tooling)
8. [Fuzzing & Property Testing](#8-fuzzing--property-testing)
9. [Formal Verification](#9-formal-verification)
10. [Audit Report Structure & Disclosure](#10-audit-report-structure--disclosure)
11. [Multi-Chain Coverage](#11-multi-chain-coverage)
12. [Hand-off Boundaries](#12-hand-off-boundaries)
13. [Tools Reference](#13-tools-reference)
14. [Risks & Limitations](#14-risks--limitations)
15. [Common Pitfalls](#15-common-pitfalls)
16. [Real-World Patterns & Scenarios](#16-real-world-patterns--scenarios)
17. [Related SOPs](#17-related-sops)
18. [External & Reference Resources](#18-external--reference-resources)

---

## 1. Objectives & Scope

A smart contract audit produces an evidence-based finding set, an exploit-class enumeration, and a remediation plan against a fixed code revision over a fixed time budget. The deliverable is a written report that names findings, severities, reproductions, suggested fixes, and explicit out-of-scope notes. This SOP covers the audit lifecycle, defect taxonomies, the vulnerability classes that produce most material findings, the tooling that supplements manual review, formal-verification posture, and the report structure conventions enforced by the major audit firms.

### What this SOP owns

- Audit engagement scoping (commit hash, in-scope contracts, time budget, deliverable shape).
- Threat modeling specific to on-chain code (actors, trust assumptions, asset flow, invariants, composability surface).
- The legacy Smart Contract Weakness Classification (SWC) registry and DASP Top 10, their maintained successors (EEA EthTrust Security Levels, OWASP Smart Contract Top 10), and finding-level catalogues such as Solodit.
- Vulnerability classes most often material in EVM contracts: reentrancy (single-function / cross-function / cross-contract / read-only), access-control gaps, oracle manipulation (spot-price, TWAP, governance), MEV / sandwich / front-running, signature replay, delegatecall confusion, storage collisions, upgrade-pattern pitfalls, governance attacks, flash-loan composability, token-integration assumptions (approve race, fee-on-transfer and rebasing tokens), ERC-4626 vault share inflation, and arithmetic issues (post-Solidity 0.8 baseline).
- Tooling: Slither, Aderyn, Wake, Mythril, Echidna, Foundry's `forge` / `cast` / `chisel`, ityfuzz, Medusa, Halmos, Certora Prover, K-framework (KEVM, Kontrol), SMTChecker.
- Formal verification: when to reach for it, what it proves, the practical Certora / Halmos / K / SMTChecker workflow, and how to document a verified property in the report.
- Audit-report structure conforming to the Trail of Bits, OpenZeppelin, and ConsenSys Diligence shapes.
- Remediation verification (the auditor's pass after the team patches).
- Multi-chain coverage: EVM (Ethereum mainnet; rollup L2s such as Arbitrum, Optimism and Base; EVM-compatible L1s and sidechains such as BNB Smart Chain and Polygon PoS) is the dominant case; Move (Sui, Aptos), Solana (rust-anchor / native), Cairo (Starknet), and CosmWasm (Cosmos SDK chains) are framed at the orientation level so the auditor knows what is recognizably different and where to seek chain-specific guidance.

### Hard exclusions (out of scope)

- **Post-exploit fund tracing.** Once funds leave the contract, the methodology is on-chain investigative tradecraft, not audit. Routes to [[../../Investigations/Techniques/sop-blockchain-investigation|Blockchain Investigation]].
- **Mixer / privacy-pool de-obfuscation.** Routes to [[../../Investigations/Techniques/sop-mixer-tracing|Mixer & Privacy-Pool Tracing]].
- **General offensive exploitation methodology.** Web3 web-application angles, off-chain server attacks, exploit-development discipline, fuzzing of native binaries, and ROP / heap / kernel work all live in [[../Pentesting/sop-vulnerability-research|Vulnerability Research]] and [[../Pentesting/sop-web-application-security|Web Application Security]].
- **Bug bounty and contest submission process.** Submission and disclosure mechanics for bounty programs (Immunefi, HackerOne crypto programs) and audit contests (Code4rena, Cantina, Immunefi audit competitions) follow each platform's current rules; the general bounty workflow is in [[../Pentesting/sop-bug-bounty|Bug Bounty]]. This SOP focuses on the technical findings the report contains, not the submission UX.
- **Live exploitation of deployed contracts.** No instructions for executing exploits against contracts you do not own or are not authorized to test. PoCs for findings live in audit-firm forks of mainnet (`forge test --fork-url`, with `--fork-block-number` pinned) or local test rigs, never against live state.
- **Cryptographic primitive analysis.** Curve choice, hash construction, ZK circuit soundness review, and cipher-suite analysis route to [[sop-cryptography-analysis|Cryptography Analysis]]. This SOP covers how primitives are *used* by contracts (signature replay, hash-collision-resistant identifiers), not whether the primitives themselves are sound.
- **Reverse engineering of unverified bytecode-only contracts.** Decompilation, IDA/Ghidra-style methodology, and lifted-IR analysis route to [[sop-reverse-engineering|Reverse Engineering]] and the relevant blockchain-investigation hand-off; this SOP assumes source-available review, and treats decompiler output (Heimdall-rs, the Dedaub decompiler; see §11.7) as a starting point only.

### Engagement types covered

- **Pre-deployment audit.** Code is feature-frozen at a commit hash; the audit deliverable gates a deployment.
- **Pre-upgrade audit.** Live contract upgrade (UUPS, Transparent Proxy, Beacon, Diamond) needs review of the new logic plus storage-layout compatibility with the live storage.
- **Continuous / retainer review.** Repeating PR-by-PR review for an active codebase.
- **Public audit contest.** Code4rena, Cantina and Immunefi audit competitions — same methodology, compressed timeline, public reporting. Check that a platform still runs open contests before planning around it: Sherlock's docs now file its contests under a section marked deprecated and replaced by its Audit Engine.
- **Internal pre-audit review.** Team's own security engineer doing the pass before paying for an external auditor.

---

## 2. Pre-Engagement & Authorization

### Authorization Checklist

- [ ] Written engagement letter or contest scope page identifying the **commit hash**, the **files in scope**, and the **time window**. Audit reviews drift if the codebase moves under the auditor; pin the SHA and refuse to follow `main` mid-engagement.
- [ ] Out-of-scope contracts and integrations are enumerated. Off-chain backend, signer infrastructure, oracle deployment scripts, frontend, and operational runbooks are explicitly in or out.
- [ ] Test environment authority: confirm the auditor may run forks against any RPC the engagement references, and that the engagement covers reading mainnet state via `forge test --fork-url` and similar tooling.
- [ ] Disclosure pathway: who receives the draft, who receives the final, what the public-disclosure timeline looks like, and whether the team will publish the report. Public-contest platforms have platform-managed disclosure clocks.
- [ ] Private repo access: read-only credentials, separate from any personal account. Rotate at engagement end.
- [ ] Sample data and deployment scripts, where the engagement covers a live system: confirm the auditor receives them under NDA terms compatible with the report deliverable.
- [ ] Jurisdictional constraints reviewed — see [[sop-legal-ethics|Legal & Ethics]] for CFAA / Computer Misuse Act / Cybercrime Directive framing. Public-contest scopes are narrower than full audits; do not pivot from a contest scope into adjacent contracts even if the broader codebase looks tempting.
- [ ] If the engagement is a pre-deployment audit, confirm whether the deliverable gates the deployment (the team will not deploy until findings of severity X or above are addressed). This shapes what counts as "blocker" severity in the report.

### Lab Environment Requirements

- Engagement-specific repo clone, isolated from personal work; no shared secrets between engagements.
- Foundry (`foundryup` install), Hardhat (npm), and Slither in a versioned virtual environment per engagement so toolchain drift between engagements does not corrupt findings.
- Mainnet fork RPC endpoint (Alchemy / Infura / QuickNode / public RPC) on a dedicated key per engagement; rotate when the engagement ends so leaked keys do not bleed across clients.
- Solidity version pinning matched to the engagement target. The compiler version is part of the threat model; many findings are version-conditional: 0.4.x wrapping arithmetic; the `constructor` keyword from 0.4.22 (name-matched constructors removed in 0.5.0); the `receive` / `fallback` split and `virtual` / `override` in 0.6.0; checked arithmetic and ABI coder v2 by default in 0.8.0; default EVM `shanghai` in 0.8.20 (emits `PUSH0`, which fails on chains without Shanghai support); inline-assembly `tload` / `tstore` from 0.8.24 and `transient` state variables from 0.8.28; default EVM `cancun` from 0.8.25, `prague` from 0.8.30 and `osaka` from 0.8.31; deprecation warnings for `send` / `transfer` from 0.8.31. Check that the target chain supports the compiler's `evmVersion`, and check the pinned version against the [Solidity known-bugs list](https://docs.soliditylang.org/en/latest/bugs.html). Latest release: 0.8.38 (2026-10-22) [verify 2026-11-04].
- Local crash / artifact storage encrypted at rest. Audit findings are pre-disclosure material; treat them with the same OPSEC discipline as a 0-day per [[sop-opsec-plan|OPSEC]].
- Reproducible PoC scripts checked in to the engagement repo. The team needs them to verify the fix; a PoC that lives only in your terminal scrollback is a defect.

### Disclosure-Ready Posture

Before findings turn into a draft report, line up: the team's security contact (SECURITY.md, security@, on-chain multisig signer who controls the upgrade key), an encrypted-channel option (PGP, Signal, platform-managed inbox for contests), the public-disclosure timeline, and a private artifact repo for PoC scripts. Auditors who treat the report as a one-shot delivery often find live exploitation in the wild during the patch window — pre-stage the comms so a critical-severity surprise can move fast without leaking on the way through.

For competitive contests, the platform owns the clock: do not negotiate side-channel disclosure; route through the platform's triage queue. For private engagements, the team owns the clock; the auditor's job is to recommend a defensible window and stop.

---

## 3. Audit Lifecycle

A defensible audit progresses through six phases. Skipping the early phases leads to deep but unfocused review; skipping the late phases leads to findings the team cannot act on.

### 3.1 Engagement Scoping

Pin the commit hash. Read the README, the deployment scripts, the test suite, and any existing security documentation. Identify the privileged actors, the externally-callable surface, the integrations (oracles, bridges, AMMs, lending markets), and the upgrade authority. Build a one-page system map before reading any contract logic. The map drives the threat model in §4.

A reasonable scoping deliverable to the team before review begins includes: counted lines of in-scope Solidity (or equivalent), enumerated external dependencies, the privileged actors, the upgrade architecture, and a list of open questions whose answers will shape the review.

### 3.2 Threat Modeling

See §4. The output is a written list of system invariants the audit will look for violations against, plus a written list of trust assumptions the audit will question. Both go into the report appendix in firm-style audits.

### 3.3 Manual Review

The bulk of audit findings come from manual reading paired with running examples. Approaches that travel well:

- **Per-contract walk:** read each contract top-to-bottom, then per public function, asking "what changes? what trust does this require? what could go wrong?"
- **State-change-driven walk:** identify every state variable, then enumerate every code path that writes it. State variables that are read by many code paths and written by few are high-leverage; the inverse pattern often hides bugs.
- **External-call-driven walk:** mark every external call (`.call`, `.transfer`, `.send`, ERC-20 / ERC-721 / ERC-1155 transfers, oracle reads, contract-to-contract via interfaces), then check the call site for reentrancy, return-value handling, gas limits, and trust on the callee.
- **Invariant-driven walk:** for each invariant (e.g. "total supply equals sum of balances"), enumerate the code paths that could violate it.
- **Diff-driven walk** (re-audit / continuous review): focus on the diff against the previously-reviewed commit. Touched code first, then expand to anything that consumes touched code's output.

### 3.4 Tooling-Assisted Review

Static analysis (Slither, Aderyn, Wake) finds the cheap wins: missing `view` / `pure`, suspicious external calls, public state vars that should be internal, missing zero-address checks. Run early; triage; fold confirmed issues into manual-review notes; mark false positives so they don't recur.

Symbolic execution (Mythril, whose maintenance has stalled, see §7.4; Halmos and hevm for property-level symbolic tests) finds reachable bug states; output is a list of paths the auditor must verify. Trail of Bits' Manticore is archived and no longer maintained. Coverage-guided fuzzers (Echidna, Foundry's `forge test --fuzz-runs`, ityfuzz, Medusa) find counterexamples to invariants the auditor encodes.

Formal verification (Certora, Halmos, K, SMTChecker) proves an encoded property over all inputs (within configured bounds). It complements but does not replace fuzzing — both find different bug shapes.

### 3.5 Reporting

See §10. The report enumerates findings with consistent severity, reproduction, recommendation; lists the threat model; lists recommended-but-non-blocking improvements; lists explicit out-of-scope notes; and includes an executive summary the non-engineering reader can act on.

### 3.6 Remediation Verification

After the team patches, the auditor reviews the fix commit. Outcomes are: **Fixed** (the patch addresses the root cause), **Partially Fixed** (the patch addresses the symptom but the root cause may resurface elsewhere), **Not Fixed** (the patch is insufficient or introduces a new issue), **Acknowledged** (the team accepts the risk and documents it). The remediation pass is a discrete deliverable; do not bundle it silently into the original report.

---

## 4. Threat Modeling for Smart Contracts

Smart-contract threat modeling adapts the standard STRIDE / actor-asset-trust shape to on-chain semantics. The high-leverage shifts:

### 4.1 Actors

- **Owner / Admin / Multisig signer.** Holds upgrade key, parameter-change authority, treasury withdrawal capability. The audit asks "what can the admin do that they shouldn't, and what can they not do that they should?"
- **Privileged role holders.** OpenZeppelin AccessControl roles, custom role systems. Each role is its own actor for threat-modeling purposes.
- **Routine user.** Calls public functions in nominal flows.
- **Adversarial user.** Calls public functions with crafted inputs, in crafted ordering, possibly in a single transaction with flash-loaned capital, possibly via a contract that re-enters the protocol.
- **Searcher / MEV bot.** Observes pending transactions and front-runs / back-runs / sandwiches them; reorders within a block where the protocol's economic design lets them.
- **Oracle operator.** Off-chain entity supplying price feeds, randomness, or external state. The audit treats the oracle as semi-trusted at best.
- **Bridge / cross-chain message sender.** External messaging-protocol relay claiming a message originated on another chain; trust depends on the bridge's security model.
- **Liquidity-provider / depositor.** Supplies capital expecting yield; their interests sometimes conflict with other actor classes (especially under emergency-pause logic).
- **Governor / token-holder voter.** Casts on-chain votes that change parameters. Treated as adversarial when vote-buying or flash-loaned voting is feasible.

### 4.2 Trust Assumptions

Write them down before reading code. Examples:

- "The deployer EOA is trusted at deploy time; thereafter, all deployer-only functions must be migrated to the multisig before any user funds are deposited."
- "The Chainlink price feed is trusted to publish updates within heartbeat parameters and to not deviate from market price by more than X bps."
- "The admin multisig is 3-of-5; any 3 of `{names}` can move treasury."
- "The bridge relayer is trusted to deliver a message exactly once and only when the source-chain event finalized."

Each trust assumption is a question the audit must verify against the code: does the code enforce the assumption, fail safely if the assumption breaks, or silently rely on it?

### 4.3 Asset Flow

Diagram the flows. Where do tokens enter? Where do they exit? Which contracts hold balances on behalf of users? Which contracts hold protocol-owned balances? Each flow is a path the audit walks.

### 4.4 Invariants

Write them down before testing. Examples:

- "The contract's ERC-20 balance equals the sum of `deposits[user]` across all users."
- "After any state-changing function returns, `totalSupply() == sum_of(balances)`."
- "No user can withdraw more than they deposited plus their share of yield."
- "The contract reverts on any reentrant call into `withdraw`."
- "Governance proposals execute only after a timelock delay of at least N blocks."

Invariants drive both the manual review (every function violation hunt) and the fuzz suite (encoded as Foundry `invariant_*` test functions run by `forge test`, or Echidna / Medusa properties).

### 4.5 Composability Surface

What does the protocol assume about its callers? About the protocols it calls? Composability is the on-chain attack surface that has produced most of the largest losses in DeFi: an integration that worked safely with version 1 of an upstream protocol can be unsafe against version 2. Each external integration is a trust boundary; document it in the threat model and re-verify each engagement.

---

## 5. Defect Taxonomy & SWC Registry

### 5.1 SWC (Smart Contract Weakness Classification)

The [SWC Registry](https://swcregistry.io) (SWC-100 through SWC-136) is the historical EVM-defect taxonomy. It is **no longer actively maintained**: its maintainers state the content has not been thoroughly updated since 2020 and is known to be incomplete, and they point readers to the [EEA EthTrust Security Levels specification](https://entethalliance.org/specs/ethtrust-sl/) for current guidance [verify 2026-11-04]. The GitHub repository is not archived, but no new entries are added. Each entry lists a CWE parent, a description, remediation, references, and code samples.

Because the registry is unmaintained, treat SWC IDs as a legacy cross-reference rather than a current taxonomy. Maintained references are the EEA EthTrust Security Levels specification (v3, March 2025), which draws on the SWC registry among other sources, and the [OWASP Smart Contract Top 10](https://scs.owasp.org/sctop10/) (2026 edition). For finding-level comparison, practitioners use the [Solodit](https://solodit.cyfrin.io) aggregate of public audit findings. Many audit reports and some tools (Mythril, for example) still emit SWC IDs, so keep citing them alongside an EthTrust requirement or OWASP SC category [verify 2026-11-04].

High-frequency SWC entries to know cold:

| SWC ID | Title | Notes |
|--------|-------|-------|
| SWC-101 | Integer Overflow / Underflow | Default before 0.8.0. From 0.8.0, arithmetic reverts on overflow / underflow except inside `unchecked { }`; bitwise shifts, explicit narrowing casts and inline-assembly arithmetic are never checked. |
| SWC-104 | Unchecked Call Return Value | Low-level `call` / `send` return value not checked. |
| SWC-105 | Unprotected Ether Withdrawal | Public withdrawal without access control. |
| SWC-106 | Unprotected Self-Destruct | Public `selfdestruct` reachable. Since Cancun (EIP-6780, Ethereum mainnet 2024-03-13 [verify 2026-11-04]), `SELFDESTRUCT` deletes code and storage only when executed in the same transaction that created the contract; otherwise it only sends the whole balance to the target. This applies to every contract, including those deployed before Cancun; pre-Cancun semantics matter only for historical analysis and for EVM chains that have not adopted EIP-6780. Solidity has warned that `selfdestruct` is deprecated since 0.8.18. |
| SWC-107 | Reentrancy | The classic. See §6.1. |
| SWC-112 | Delegatecall to Untrusted Callee | Storage-layout corruption, full takeover. |
| SWC-114 | Transaction Order Dependence | MEV / front-running. |
| SWC-115 | Authorization through tx.origin | Use `msg.sender`, not `tx.origin`, for authorization. |
| SWC-116 | Block-Values as Time | `block.timestamp` and `block.number` as randomness or precise timing. |
| SWC-118 | Incorrect Constructor Name (Solidity < 0.5.0) | Name-matched constructors were the only form before 0.4.22 and were removed in 0.5.0; legacy contracts only. |
| SWC-119 | Shadowing State Variables | Inheritance pitfall. |
| SWC-120 | Weak Sources of Randomness | `block.timestamp`, `blockhash`, `block.difficulty` (now `block.prevrandao` post-merge) as randomness. |
| SWC-124 | Write to Arbitrary Storage | Unbounded storage write primitives. |
| SWC-128 | DoS with Block Gas Limit | Unbounded loop or storage iteration. |
| SWC-132 | Unexpected Ether Balance | Logic that depends on `address(this).balance` rather than internal accounting. |
| SWC-133 | Hash Collisions with Multiple Variable-Length Arguments | `abi.encodePacked` hash-collision pitfalls. |
| SWC-136 | Unencrypted Private Data On-Chain | `private` Solidity keyword does not equal "secret on-chain". |

### 5.2 DASP Top 10

The Decentralized Application Security Project Top 10 (DASP, an NCC Group initiative, 2018) was the first widely cited smart-contract defect taxonomy. dasp.co is no longer publicly served; read the [archived copy](https://web.archive.org/web/20240102011402/https://dasp.co/). It is dated and not actively maintained, but its categories shaped how the field talks about issues: 1) Reentrancy, 2) Access Control, 3) Arithmetic Issues, 4) Unchecked Return Values, 5) Denial of Service, 6) Bad Randomness, 7) Front-Running, 8) Time Manipulation, 9) Short Address Attack (largely mitigated by modern web3 libs), 10) Unknown Unknowns. Most of these are subsumed by SWC entries. Cite DASP only for historical context.

### 5.3 Modern Catalogues

Beyond SWC, current practice references:

- **[EEA EthTrust Security Levels](https://entethalliance.org/specs/ethtrust-sl/)** — maintained, Solidity-specific requirement catalogue (v3, March 2025) at three levels, [S], [M] and [Q]; the SWC registry's notice points readers to it for currently maintained guidance.
- **[OWASP Smart Contract Top 10](https://scs.owasp.org/sctop10/)** — awareness ranking, 2026 edition (SC01 Access Control Vulnerabilities through SC10 Proxy & Upgradeability Vulnerabilities).
- **[Solodit](https://solodit.cyfrin.io)** — aggregated public audit-finding database from Cyfrin, filterable by impact, protocol category, report tags and source; Cyfrin describes it as the largest public dataset of smart-contract findings [verify 2026-11-04].
- **[Trail of Bits "Building Secure Smart Contracts"](https://github.com/crytic/building-secure-contracts)** — patterns, tooling guidance, training material. Authoritative for Slither / Echidna / Medusa workflow.
- **[OpenZeppelin Contracts security advisories](https://github.com/OpenZeppelin/openzeppelin-contracts/security/advisories)** and the **[OpenZeppelin Forum security category](https://forum.openzeppelin.com/c/security/25)** — advisories on the OZ libraries, which are widely inherited, so their advisories propagate widely. (OpenZeppelin announced Defender's final shutdown for 2026-07-01, as part of phasing it out in favour of open-source tooling.)
- **[ConsenSys Diligence "Ethereum Smart Contract Best Practices"](https://consensys.github.io/smart-contract-best-practices/)** — pattern catalogue and known-attacks list. Complements SWC.
- **[Code4rena Reports](https://code4rena.com/reports)**, the **[Sherlock contest archive](https://audits.sherlock.xyz/contests)** (historical: Sherlock's docs now mark contests as replaced by its Audit Engine), and **[Cantina](https://cantina.security)** — public competitive-audit findings; useful for seeing what recent findings look like in practice.
- **[Rekt News](https://rekt.news)** — incident write-ups for post-mortem study; not technical taxonomy but useful for "what did the actual exploits look like" [verify 2026-11-04].
- **[DeFiLlama Hacks](https://defillama.com/hacks)** — incident catalogue with loss figures.

The taxonomy you cite in the audit report should match the audience: SWC IDs (legacy) or EthTrust requirement IDs for downstream consumers who index reports, OWASP SC Top 10 categories for executive summaries, firm-internal severity labels for the team's triage workflow, and Solodit category labels for cross-engagement comparability.

---

## 6. Vulnerability Classes

The classes below are the categories that have produced most material findings in EVM-chain audits in the 2020-2026 window. Each subsection describes the pattern, the auditor's check, the remediation shape, and, where a snippet helps, a short illustrative (intentionally abstract) one. Working exploit code against deployed contracts is intentionally omitted — see [[../Pentesting/sop-vulnerability-research|Vulnerability Research]] for the ethics of PoC publication.

### 6.1 Reentrancy

**Pattern.** A contract makes an external call before updating its own state. The callee re-enters the contract and observes / acts on stale state, draining funds or corrupting accounting.

**Variants.**
- **Single-function reentrancy.** Same function re-entered. The original 2016 DAO bug. Mitigated by checks-effects-interactions (CEI) ordering or the `nonReentrant` modifier.
- **Cross-function reentrancy.** Function A is called; A calls out; the callee re-enters function B that shares state with A. CEI in A alone is insufficient; B must also be guarded.
- **Cross-contract reentrancy.** Two contracts in the same protocol share state via a registry, accounting library, or token. An external call from contract X re-enters contract Y, which sees stale shared state.
- **Read-only reentrancy.** External integrators read view functions that compute over state mid-update. Even when the protocol's own writes are CEI-safe, view functions can return inconsistent values during the brief window an external call is in flight, and downstream protocols using those view functions for pricing or accounting are corrupted. ChainSecurity's disclosure popularized this class: on 2022-04-14 it privately informed Curve and affected integrators that Curve pools' `get_virtual_price` could be read mid-`remove_liquidity`, which exposed price feeds at MakerDAO, Enzyme, Abracadabra, TribeDAO and Opyn; the public post-mortem followed on 2022-10-11 [verify 2026-11-04].

**Auditor's check.** For every external call (low-level `.call`, ERC-20 transfer where the token may have hooks like ERC-777 / ERC-1363, ERC-721 `safeTransferFrom` triggering `onERC721Received`, ERC-1155 `onERC1155Received` / `onERC1155BatchReceived` hooks, native ETH `.call{value:}`), enumerate all functions that share state with the calling function and verify each is reentrancy-safe, including cross-contract integrators that read computed view functions. For transient-storage guards (EIP-1153 `TSTORE` / `TLOAD`, Solidity `transient` variables from 0.8.28), confirm the lock is cleared before the function returns: transient slots persist until the end of the *transaction*, not the call, so a lock left set blocks legitimate re-entry from multicall / batch flows, and stale transient values leak between calls in the same transaction.

**Remediation.** Checks-effects-interactions ordering. `nonReentrant` modifier (OpenZeppelin's `ReentrancyGuard`, or `ReentrancyGuardTransient`, its EIP-1153 variant from 5.1) on functions that make external calls or share state with such functions. Read-only-reentrancy guards on view functions that compute over mutable state: OpenZeppelin's `nonReentrantView` (5.5+) or a check on `_reentrancyGuardEntered()` (4.9+). Integrators that price off another protocol's view function must confirm that protocol is not mid-call; after the Curve disclosure, most affected integrators triggered the pool's reentrancy lock by calling a cheap state-changing function (`withdraw_admin_fees`) before reading the price. Pull-payment patterns where users withdraw owed balances rather than the contract pushing. Do not treat `transfer` / `send` and their 2300-gas stipend as reentrancy protection: both are deprecated since Solidity 0.8.31, the Solidity docs say the stipend "no longer holds its original meaning due to changing opcode costs", and EIP-1153 `TSTORE` is exempt from the stipend check. Use `call{value: ...}("")` with CEI and a reentrancy guard, and check its return value.

```solidity
// Vulnerable: external call before state update.
function withdraw() external {
    uint256 amount = balances[msg.sender];
    (bool ok, ) = msg.sender.call{value: amount}("");
    require(ok);
    balances[msg.sender] = 0;
}

// Mitigated: state update first, then external call, with reentrancy guard.
function withdraw() external nonReentrant {
    uint256 amount = balances[msg.sender];
    balances[msg.sender] = 0;
    (bool ok, ) = msg.sender.call{value: amount}("");
    require(ok);
}
```

### 6.2 Access Control

**Pattern.** A privileged function lacks a sender check, the check is wrong, or the role wiring is inconsistent.

**Common shapes.**
- Missing `onlyOwner` / `onlyRole` modifier on a function that mutates protocol parameters, mints tokens, withdraws fees, or upgrades the implementation.
- `tx.origin` used for authorization (SWC-115); a user signs a transaction to a malicious contract, which then calls the protected function and passes the `tx.origin` check.
- Function visibility wrong: `public` or `external` where `internal` was intended, exposing helpers as the public API.
- Role mis-wiring: function checks role A but the role-granting function only grants role B; admin role granted to the wrong address at construction; admin role retained by deployer after multisig hand-off.
- Initializer functions reachable post-deployment: a `function initialize() public` (no `initializer` modifier or with a mis-coded one) is callable by any address after deployment, taking ownership.
- Two-step ownership transfer skipped: single-step `transferOwnership` to the wrong address bricks the contract; OZ's `Ownable2Step` two-step pattern is the safer default.

**Auditor's check.** Enumerate every state-changing function. For each, determine the intended caller. For each intended caller, verify the modifier or check exists, is correct, and cannot be bypassed. Verify role-granting paths: who can grant role X? Who has it at deployment? Is there a route to escalate?

**Remediation.** OZ `AccessControl` or `Ownable2Step`. Avoid `tx.origin`. Prefer explicit modifiers over inlined checks. Pin initializer functions with the `initializer` modifier from `Initializable.sol`. Document the role hierarchy in the README so the auditor and the user can both verify.

### 6.3 Oracle Manipulation

**Pattern.** A contract reads a price (or other external state) from an on-chain source that an attacker can manipulate within a single transaction.

**Common shapes.**
- **Spot-price oracle from a thinly-traded AMM pool.** Attacker flash-loans capital, swaps to skew the pool, calls the victim contract (which reads the now-manipulated price), profits, swaps back, repays the flash loan. The bZx 2020 incidents popularized this class.
- **Single-block price reads.** Even on deeper pools, reading the price within the same block as a swap allows sandwich-style manipulation.
- **TWAP windows too short.** Time-weighted-average-price oracles with too-short windows (e.g. 5 minutes on a block-time-of-12-seconds chain = ~25 samples) are still manipulable with sustained pressure.
- **Stale Chainlink reads.** Chainlink's `AggregatorV3Interface` returns `(roundId, answer, startedAt, updatedAt, answeredInRound)`. Failing to compare `updatedAt` with `block.timestamp` against the feed's heartbeat lets stale prices drive logic: the protocol thinks the price is current, but the oracle stopped publishing. Also check `answer > 0` and any min / max bounds. (`answeredInRound` is deprecated per Chainlink's API reference; a missing `answeredInRound >= roundId` check is not a finding on its own.)
- **Sequencer-down on L2s.** Arbitrum / Optimism / Base sequencer outages stop new blocks from being produced, freezing the oracle. Failing to consult the L2 sequencer-uptime feed (Chainlink publishes it) makes the protocol mis-price during outages. Also check the protocol waits for a grace period after the sequencer comes back before allowing liquidations.
- **Custom oracle aggregator with un-validated inputs.** Median-of-N sources where N includes a low-quality feed; weighted-average where weights are owner-mutable.

**Auditor's check.** For every price read, identify the source. AMM-based? Has the protocol enforced sufficient depth, sufficient time-weighting, and circuit-breaker logic? Chainlink? Are `updatedAt` vs heartbeat, `answer > 0` and value bounds checked? Is the sequencer-uptime feed checked on L2? Is the price used for liquidations or for accounting? Liquidation prices need tighter freshness than display prices.

**Remediation.** TWAP with a window and pool depth that make multi-block manipulation cost-prohibitive: size it from the pool's liquidity, not a fixed number of minutes, and assume a post-Merge proposer can control consecutive blocks (proposers know their slots up to one epoch ahead). Multiple-source medianization. Circuit breakers that pause on oracle deviations beyond N basis points. Check `updatedAt` against the heartbeat, `answer > 0` and value bounds on every read. Document the oracle threat model in the protocol README.

### 6.4 MEV, Front-Running & Sandwich Attacks

**Pattern.** The mempool is public; a searcher observes a pending transaction and reorders / inserts their own transactions to extract value.

**Common shapes.**
- **Front-running.** Observe a victim's pending swap; submit your own swap with higher priority gas (or via a builder bundle) to be included first; profit from the price impact the victim's swap will then have.
- **Back-running.** Observe an opportunity-creating transaction (e.g. a large liquidation, an arbitrage opening); submit a back-runner to capture.
- **Sandwich.** Front-run a victim's swap with a buy, let the victim's swap push the price further, back-run with a sell. The victim experiences worse-than-expected slippage; the searcher pockets the spread.
- **JIT (just-in-time) liquidity.** A searcher provides concentrated liquidity right before a large swap and removes it immediately after, capturing fees a passive LP would have earned.
- **Reorg / time-bandit attacks.** On chains where reorgs are feasible (or under post-merge MEV-Boost validator-collusion scenarios), a searcher rewrites history to their benefit. Less common in practice but in scope for high-stakes systems.

**Auditor's check.** Does the protocol design assume transactions execute in a specific order? Does it expose a value extractable by front-running (uncapped slippage on user trades, uncapped withdrawal in a depegged stablecoin, undercut of governance vote?) Does it use commit-reveal where ordering matters?

**Remediation.** Slippage parameters set by the user, with sensible UI defaults. Commit-reveal schemes for orderings. Auctions (sealed-bid, batch-auction) for actions where ordering equals value. Private mempool routing (Flashbots Protect, MEV Blocker, MEV-Share) at the wallet / app layer. Acceptable-loss framing in the threat model — most protocols cannot eliminate MEV, only bound it. CoW Protocol's fair combinatorial batch auction (uniform directed clearing prices, coincidence of wants) and intent-based designs such as UniswapX and 1inch Fusion mitigate MEV at the protocol level rather than per transaction [verify 2026-11-04].

### 6.5 Signature & Cryptographic Pitfalls

**Pattern.** Off-chain signed messages are accepted on-chain as authorization, but the verification has gaps.

**Common shapes.**
- **Signature replay across chains.** Same chain ID is not bound into the signed message; a signature valid on chain A is replayable on chain B. EIP-712 domain-separator binding mitigates if the domain separator includes `chainid` and the contract address.
- **Signature replay within a chain.** No nonce or expiration; the same signature is replayable until the signer rotates keys.
- **Signature malleability.** ECDSA signatures `(r, s, v)` have a paired `(r, -s mod n, v')` form that verifies the same message; allowing both lets an attacker mutate a signature without invalidating it. Use OpenZeppelin's `ECDSA.recover`, which rejects high-s values and reverts instead of returning `address(0)`, or enforce `s <= secp256k1n / 2` yourself. EIP-2's low-s rule applies only to transaction signatures; the `ecrecover` precompile still accepts high-s signatures. Never use a signature's bytes as a replay key or unique ID; use a nonce or the signed message digest.
- **`ecrecover` returning the zero address on invalid input.** Treat zero-address as a non-recovery; otherwise an attacker who can produce malformed input can claim signing as the zero address.
- **`abi.encodePacked` collision.** Concatenating multiple variable-length arguments without separators allows collisions; e.g. `abi.encodePacked("a", "bc")` and `abi.encodePacked("ab", "c")` produce the same byte string. Use `abi.encode` for hash inputs that mix dynamic types.
- **Permit / ERC-2612 / ERC-3009 (Draft) / EIP-7702 misuse.** *Token side:* `permit` must check `deadline`, consume `nonces[owner]`, and reject `owner == address(0)`; prefer a domain separator rebuilt when `block.chainid` changes. *Integrator side:* anyone can submit a permit signature first, so wrap `permit` in `try` / `catch` (OpenZeppelin `IERC20Permit` guidance) and do not let the flow depend on it succeeding. Contracts that accept ERC-3009 authorizations should call `receiveWithAuthorization`, not `transferWithAuthorization`. *EIP-7702 delegate contracts:* the delegate must enforce its own replay protection and have the account sign over value, gas, target and calldata; initialization must be authorized by the EOA's signature because it can be front-run; storage should be namespaced (ERC-7201) so re-delegation does not collide; authorizations with `chain_id = 0` are valid on every chain; and delegated EOAs break `require(msg.sender == tx.origin)` checks [verify 2026-11-04].
- **Schnorr / BLS / threshold signatures.** Used in some L2s, validator sets, and cross-chain bridges. Audits of these systems require the auditor to read the specific scheme paper and reference implementation; defer to [[sop-cryptography-analysis|Cryptography Analysis]] for primitive-level review.

**Auditor's check.** Every place a signature is accepted: domain-separator includes chain-id and verifying contract? Nonce included and incremented atomically with use? Expiration included and checked? Recovery handles malformed input? Hash construction non-collision? Signer authority bound to the action (not just any-signer)?

**Remediation.** EIP-712 with proper domain separator. Per-signer monotonic nonces. OpenZeppelin's `ECDSA.recover` (low-s enforcement built in). `abi.encode` not `abi.encodePacked` for hash inputs that mix dynamic types. Test vectors covering replay across chain forks (mainnet vs testnet vs L2s with the same chain-id-derivation issues).

### 6.6 Delegatecall, Storage Collisions & Proxy Hazards

**Pattern.** `delegatecall` runs callee code in the caller's storage context. Wrong storage layout, wrong callee, or wrong delegation discipline corrupts state or hands the caller's storage to the callee.

**Common shapes.**
- **Storage collision in upgradeable proxies.** UUPS / Transparent Proxy / Beacon proxies put the implementation (or, for Beacon proxies, the beacon) address in pseudo-random ERC-1967 slots (`implementation`, `admin`, `beacon`) so it does not collide with the implementation's sequential layout. New implementation versions must preserve storage layout: a removed variable, a re-ordered variable, or an added variable in the wrong slot corrupts state.
- **Diamond / multi-facet storage collisions.** EIP-2535 Diamond proxies route different selectors to different facets that share storage. Two facets defining a state variable at the same slot collide.
- **`delegatecall` to attacker-controlled address.** A function `delegatecall(addr, data)` where `addr` is user-supplied gives the user a write primitive over the caller's entire storage.
- **`delegatecall` into code that can `SELFDESTRUCT`.** `delegatecall` runs the callee's code in the caller's context, so a `SELFDESTRUCT` reached in the callee acts on the caller (through a proxy, it targets the proxy). Before Cancun (EIP-6780), a reachable `SELFDESTRUCT` deleted code: through a proxy it destroyed the proxy, and called directly on an unprotected implementation it destroyed the shared code every proxy depends on (the 2017 Parity multisig library freeze, next item). On EIP-6780 chains, `SELFDESTRUCT` outside the creation transaction only moves the balance, so code is no longer deleted. Still flag it: the balance moves, and chains without EIP-6780 keep the old behaviour.
- **Initializer in implementation.** If the implementation contract's `initialize()` is callable directly (rather than only through the proxy), an attacker takes ownership of the bare implementation, which can matter for uninitialized-implementation chains where the implementation itself becomes a target. The reference case is the November 2017 Parity multisig incident: an uninitialized Parity wallet library was claimed and self-destructed, freezing every wallet that delegated to it. Post-Cancun, `SELFDESTRUCT` no longer deletes code, but an attacker-owned implementation is still a finding: the attacker can move any balance the implementation holds and act with any privileges granted to the implementation's address. (OpenZeppelin's UUPS `upgradeToAndCall` is `onlyProxy`, so it cannot be called on the bare implementation; custom upgrade paths may lack that guard.)

**Auditor's check.** For every upgrade path: storage-layout diff between V1 and V2 (use `forge inspect` or OpenZeppelin's `@openzeppelin/upgrades-core` storage-layout checker). For every `delegatecall`: is the target trusted? Is it pinned? For Diamond architectures: facet storage is in named-slot pattern (ERC-7201 / "Diamond Storage")? Implementation contracts have `_disableInitializers()` in the constructor (OpenZeppelin Initializable post-4.6)?

**Remediation.** Use OpenZeppelin Upgrades plugin + storage-layout linter. Diamond Storage / namespaced storage (ERC-7201 [verify 2026-11-04]) for new diamonds. Pin `delegatecall` targets. Disable initializers on implementations.

### 6.7 Arithmetic & Integer Issues

**Pattern.** Pre-Solidity 0.8.0, arithmetic wrapped silently; post-0.8.0, arithmetic reverts on overflow / underflow except inside `unchecked { }` blocks. Bitwise shifts, explicit down-casts and inline assembly (Yul) arithmetic are not checked even outside `unchecked`. The class shifted shape but did not disappear.

**Common shapes (post-0.8).**
- **`unchecked { }` blocks for gas optimization.** Every `unchecked` block is a place the auditor must reason about manually. Solidity's arithmetic is checked by default. The only opt-out is an `unchecked { }` block in the source; there is no compiler flag. It covers only the operations written inside the block, not functions called from it, and division or modulo by zero still reverts.
- **Precision loss in division.** `(a * b) / c` versus `a * (b / c)`: the former preserves precision, the latter loses it. Solidity's `/` is integer division.
- **Down-casting truncation.** `uint128(uint256(x))` silently truncates; Solidity emits no warning. SafeCast (OpenZeppelin) reverts on lossy down-cast.
- **Order-of-operations in fixed-point math.** PRBMath / Solady `FixedPointMathLib` / OpenZeppelin's `Math.mulDiv` are the canonical helpers; rolling your own usually introduces precision errors.
- **Rounding direction.** Every rounding should favor the protocol: round **down** what the user receives (shares minted for deposited assets, assets paid out for redeemed shares) and round **up** what the user must provide (shares burned to withdraw a given amount of assets, assets pulled in to mint a given number of shares). This is the ERC-4626 rule. Inverting any one of these leaks value, and a repeatable 1-wei leak can be looped.
- **Token-decimal mismatch.** USDC has 6 decimals, WETH has 18, WBTC has 8. Treating a `uint256` amount as inherently 18-decimal silently breaks accounting.

**Auditor's check.** Read every `unchecked { }` block and verify the bounds claim. Read every cast-down. Verify rounding direction matches the protocol's economic intent. Verify token-decimal handling at every boundary.

**Remediation.** Avoid `unchecked` unless gas-critical and provably-bounded. SafeCast for down-casts. PRBMath / Solady / OZ Math for fixed-point. Document rounding direction at every share-issuance / redemption point. Normalize token amounts to a canonical decimal base before arithmetic.

### 6.8 Upgradeability Patterns & Initialization

**Pattern.** Upgradeable contracts have lifecycle pitfalls absent from immutable contracts.

**Common shapes.**
- **Uninitialized storage on a fresh proxy.** A proxy points at an implementation; initialization is a separate transaction. Front-running the initialization lets the front-runner take ownership. Check the deployment script passes the initializer calldata to the proxy constructor (`ERC1967Proxy(impl, data)`) so deploy and initialize happen in one transaction.
- **Re-initializable.** OZ's `initializer` modifier allows one-time init; `reinitializer(version)` allows additional init steps per version. Wiring these wrong (missing modifier, wrong version number, mis-ordered upgrade steps) leaves init reachable.
- **UUPS authorization missing.** UUPS proxies keep the upgrade logic in the implementation. OpenZeppelin's `_authorizeUpgrade` is declared without a body, so it must be overridden; an override without an access check (e.g. `function _authorizeUpgrade(address) internal override {}`) lets anyone upgrade. Also check every new implementation still inherits the UUPS upgrade path and the `proxiableUUID` check; otherwise one upgrade can permanently remove upgradeability.
- **Storage-gap omission (pre-5.0 OZ pattern).** Before OpenZeppelin Contracts 5.0, upgradeable base contracts reserved a `uint256[N] __gap` so later versions could add state variables without shifting the child contract's slots. Without a gap, or if the gap is not shrunk to match added variables, a base-contract change silently collides with child storage. OZ Contracts Upgradeable 5.0+ uses ERC-7201 namespaced storage instead (`@custom:storage-location erc7201:<id>`; the Upgrades plugins need Solidity 0.8.20 or later to validate it). Check which convention the project's OZ version uses and run the plugin's layout validation [verify 2026-11-04].
- **Implementation without code (custom proxies).** A hand-rolled proxy that does not check `implementation.code.length > 0` can point at the zero address or an EOA; delegatecalls then succeed silently and do nothing. OpenZeppelin's `ERC1967Utils` rejects this.

**Auditor's check.** Run OpenZeppelin Upgrades plugin's storage-layout checker against V1 → V2 diff. Verify init modifiers exist on every initializable function. Verify `_disableInitializers()` is called in implementation constructor. For UUPS, verify `_authorizeUpgrade` is restricted. For Diamond, verify facet replacement does not orphan storage.

### 6.9 Governance Attacks

**Pattern.** On-chain governance lets token-holders change protocol parameters, upgrade contracts, or move treasury. Adversaries with enough voting power (acquired, borrowed, or rented) hijack the protocol.

**Common shapes.**
- **Flash-loan governance.** If voting power is sampled at the moment a vote is cast (rather than a checkpoint before the proposal), an attacker flash-loans tokens, votes, repays. Mitigated by checkpointed voting power read at a fixed past timepoint (Compound GovernorBravo / OpenZeppelin Governor use proposal creation + `votingDelay`), so tokens borrowed after the snapshot carry no votes, and by minimum-token-holding-time requirements.
- **Vote-buying / Curve-wars / bribery.** Governance tokens with vote-escrow (veCRV, veBAL) accrue voting power based on lockup duration. Bribery markets (e.g. Votium in the Convex ecosystem) commodify voting; not a vulnerability per se but a threat-model factor.
- **Insufficient timelock.** Governance proposals execute immediately or near-immediately, leaving no window for users to exit. Best practice is a multi-day timelock plus a guardian veto for emergency.
- **Quorum too low.** Low-quorum governance lets a small token-holder coalition pass arbitrary proposals.
- **Proposal payload not auditable.** Proposals are encoded as `(target, value, signature, calldata)` tuples; obscure encoding lets a malicious proposal hide a privileged call.
- **Compromised guardian.** Guardian / multisig with veto-or-pause power is a single point of failure.

**Auditor's check.** Token voting power source: checkpointed at a fixed past timepoint (e.g. proposal creation + `votingDelay`), or read live at vote time? Timelock duration? Quorum threshold? Guardian / pauser identity and process? Does the proposal-execution path allow arbitrary calldata to arbitrary targets? Are there anti-vote-buying mechanisms?

**Remediation.** Checkpointed vote weights fixed at the proposal snapshot (creation + `votingDelay`), not read live at vote time. Timelock of days, not hours. Guardian-veto rather than guardian-execute (the guardian can stop, not start). Separation of treasury / parameter-change / upgrade authorities (don't let one proposal type change all three).

### 6.10 Flash Loans & Composability Attacks

**Pattern.** Flash loans give any user up-to-protocol-liquidity capital for one transaction. Many DeFi exploits since 2020 have used flash loans as an "atomic capital amplifier" — not the bug itself, but the leverage that turns a small bug into a large loss.

**Common shapes.**
- Oracle manipulation (§6.3) amplified by flash-loaned capital.
- Governance attacks (§6.9) amplified by flash-loaned voting power (now widely mitigated by snapshot checkpointing).
- Liquidation manipulation: borrow against an asset, manipulate the price, self-liquidate at a profit, or trigger another user's liquidation.
- Composability bug between two protocols: protocol A's invariant assumes protocol B will not be re-entered mid-call; flash loan sets up the re-entry.
- Atomic batched arbitrage that happens to also corrupt accounting because of a bug in the protocol's reentrancy guard (e.g. cross-contract guards missing).

**Auditor's check.** "What is the largest single-transaction action this protocol allows?" If the answer is "anything an attacker with $1B of flash-loaned capital can do," the protocol's invariants must hold under that adversary. Test invariants under flash-loan-amplified scenarios. Document the protocol's tolerance for flash-loan-driven price impact.

**Remediation.** Defense-in-depth: oracle TWAP windows and pool depth sized so that a multi-block manipulation by a validator holding consecutive slots is unprofitable (post-Merge proposers know their slots up to one epoch ahead), governance snapshots, reentrancy guards across the entire protocol surface (not per-contract), liquidation incentives that align with attacker incentives.

### 6.11 Token Integration Assumptions

**Pattern.** The protocol assumes every token it handles behaves like a textbook ERC-20: the amount argument equals the amount received, balances change only through transfers, `approve` can be called with any value, and every call returns `true`. Real tokens break each of these assumptions.

**Common shapes.**
- **Approve race.** Changing a non-zero allowance to another non-zero value lets the spender front-run the change and spend both the old and the new allowance. [ERC-20](https://eips.ethereum.org/EIPS/eip-20) tells clients to set the allowance to `0` before setting a new value for the same spender, and [ERC-2612](https://eips.ethereum.org/EIPS/eip-2612) notes the same race applies to `permit`. Some tokens, USDT among them, go further and revert unless the current allowance is zero, so a protocol that calls `approve` with a new value directly can lock up on them.
- **Missing return values.** Some tokens return nothing from `transfer` / `transferFrom` / `approve`, and some return `false` instead of reverting. Code that calls the bare `IERC20` interface reverts on the first kind and silently ignores failures from the second.
- **Fee-on-transfer tokens.** The token burns or diverts part of each transfer, so the recipient receives less than the `amount` argument. A protocol that credits `amount` on deposit over-credits the depositor, and its books then show more than it holds.
- **Rebasing tokens.** Balances change without any transfer. Cached balances and internal accounting drift from `balanceOf`: a positive rebase leaves an unaccounted surplus that a third party may capture, and a negative rebase leaves a deficit that the next user to transact absorbs.

**Auditor's check.** List every token the protocol may receive, including user-supplied tokens in permissionless markets. For each entry point that moves tokens, check whether accounting uses the `amount` argument or the measured balance change, how return values are handled, how allowances are set, and whether the code caches balances that a rebase can change. Confirm the documentation states which token behaviours are unsupported, and that the code enforces it (e.g. an allowlist) where it matters.

**Remediation.** OpenZeppelin [`SafeERC20`](https://docs.openzeppelin.com/contracts/5.x/api/token/erc20#SafeERC20): `safeTransfer` / `safeTransferFrom` revert on a `false` return and accept tokens that return no value; `forceApprove` (4.9+) handles tokens that require the allowance to be set to zero first; `safeIncreaseAllowance` / `safeDecreaseAllowance` change an allowance relative to its current value. Where fee-on-transfer tokens are allowed, credit the measured balance delta (`balanceAfter - balanceBefore`), not the argument. Account rebasing tokens in shares, require a non-rebasing wrapper, or reject them explicitly. Uniswap's [v2 troubleshooting notes](https://developers.uniswap.org/docs/protocols/v2/guides/troubleshooting) document how fee-on-transfer and rebasing tokens break pool accounting.

### 6.12 ERC-4626 Vault Share Inflation (First Depositor)

**Pattern.** An [ERC-4626](https://eips.ethereum.org/EIPS/eip-4626) vault converts between assets and shares at a rate set by the vault's assets and share supply. On an empty or nearly empty vault, an attacker who holds the first shares donates assets directly to the vault (a plain token transfer, not a `deposit`), inflating the price of a share so that the next depositor's shares round down to zero or close to it. The attacker typically front-runs the first real deposit, then redeems their shares for the vault's assets, including most or all of the victim's deposit. OpenZeppelin calls this the inflation (or donation) attack.

**Auditor's check.** Work out what a depositor receives when the share supply is zero or tiny and the vault's assets have been inflated by a donation. Check whether `totalAssets()` reads the raw token balance (donations count) or internal accounting. Check rounding on every conversion against the ERC-4626 rule (§6.7). Check how the vault is seeded at deployment, and whether user-facing entry points let depositors set a minimum number of shares out.

**Remediation.** OpenZeppelin's `ERC4626` (4.9+) adds virtual shares and virtual assets to the exchange-rate computation, with `_decimalsOffset()` setting the offset between the asset's and the vault's decimals. Per OpenZeppelin's `ERC4626` documentation and [ERC-4626 guide](https://docs.openzeppelin.com/contracts/5.x/erc4626), this does not fully prevent the attack, but even the default offset (0) makes it unprofitable and larger offsets make it far more costly. Other mitigations OpenZeppelin documents: an initial deposit of a non-trivial amount by the deployer, and depositor-side slippage checks on the shares received (e.g. through a router such as `ERC4626Router`). ERC-4626 also warns that the `preview*` functions are manipulable and not always safe as price oracles.

---

## 7. Static & Linting Tooling

The static-tooling layer is where cheap wins live: missing visibility modifiers, unprotected functions, suspicious external calls, dead code, gas-wasteful patterns. Run early; triage; fold into manual-review notes.

### 7.1 Slither

[Slither](https://github.com/crytic/slither) (Trail of Bits) is the de facto standard. Detector-based, fast, reads Solidity ASTs and lifts them to the SlithIR intermediate representation.

```bash
# Install
pip install slither-analyzer

# Basic run
slither .                                  # auto-detects framework
slither contracts/MyContract.sol           # single file

# Exclude results from test / dependency paths
slither . --filter-paths "test/|lib/|node_modules/"

# Markdown report for the engagement repo
slither . --checklist > slither-report.md
# Same, with finding locations linked to the GitHub source at the audited commit
slither . --checklist --markdown-root https://github.com/ORG/REPO/blob/COMMIT/ > slither-report.md

# Specific detectors only
slither . --detect reentrancy-eth,reentrancy-no-eth,reentrancy-benign

# Slither Printers — system-overview helpers, not bug detectors
slither . --print human-summary           # contract-by-contract summary
slither . --print inheritance-graph       # produces a .dot file
slither . --print call-graph              # call relationships
slither . --print function-summary        # per-function modifiers, state vars touched
```

Slither 0.11.6 ships 100 detectors [verify 2026-11-04]; each carries an impact (High / Medium / Low / Informational / Optimization) and a confidence rating. False-positive rate is non-trivial for the more aggressive detectors; triage is mandatory. The `slither-mutate` and `slither-flat` companion tools support mutation testing and flattening for tooling that wants single-file input.

### 7.2 Aderyn

[Aderyn](https://github.com/Cyfrin/aderyn) (Cyfrin) is a Rust-based static analyzer covering an overlapping but distinct detector set. Currently in active development and gaining detector coverage; pair with Slither rather than replacing.

```bash
# Install (one of). The crates.io package is stale (0.1.9, 2024), so skip `cargo install`.
curl --proto '=https' --tlsv1.2 -LsSf https://github.com/cyfrin/aderyn/releases/latest/download/aderyn-installer.sh | bash
brew install cyfrin/tap/aderyn

# Run (writes report.md)
aderyn .
```

### 7.3 Wake

[Wake](https://github.com/Ackee-Blockchain/wake) (Ackee Blockchain) is a Python-based development and testing framework that bundles a static analyzer, fuzzer, and IDE-server (LSP) features. The detector set complements Slither / Aderyn, and the framework pairs naturally with Python-based test suites. [verify 2026-11-04]

```bash
pip install eth-wake
wake detect all
```

### 7.4 Mythril

[Mythril](https://github.com/ConsenSysDiligence/mythril) (Consensys Diligence) is symbolic-execution-based; reachability of bug states rather than syntactic patterns. Slower than Slither, finds different classes of bug. Maintenance has stalled (last release v0.24.8, March 2024; no commits since January 2025): expect dependency friction with current Python and solc versions, and treat it as a supplementary pass rather than a primary tool.

```bash
# Install
pip install mythril

# Analyze
myth analyze contracts/MyContract.sol
myth analyze --execution-timeout 600 --max-depth 22 contracts/MyContract.sol
```

Mythril output is per-finding with the symbolic path that triggers it; verify each finding manually against the source.

### 7.5 Other Notable

- **[Semgrep](https://semgrep.dev)** — pattern-based linting; community Solidity rule packs exist (e.g. [Decurity/semgrep-smart-contracts](https://github.com/Decurity/semgrep-smart-contracts)). Cheap to write engagement-specific rules.
- **[Solhint](https://github.com/protofire/solhint)** — Solidity linter with security, style-guide and best-practice rule sets; a cheap CI gate, not a bug finder.
- **[Cloc-style scoping helpers](https://github.com/AlDanial/cloc)** — count in-scope lines for engagement scoping.
- **[Surya](https://github.com/ConsenSysDiligence/surya)** — call-graph and inheritance visualization; older but still useful for orientation.

---

## 8. Fuzzing & Property Testing

Fuzzing finds counterexamples to invariants. The auditor encodes the invariant; the fuzzer tries to break it. Pair with formal verification (§9) — they cover different bug shapes.

### 8.1 Foundry's `forge test`

[Foundry](https://getfoundry.sh) is a Solidity-native testing toolkit (stable since v1.0.0, February 2025; v1.9.0 as of 2026-11) [verify 2026-11-04]. Native Solidity tests, fuzzing, and invariant testing built in.

```bash
# Install
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Project layout
forge init my-audit
cd my-audit
```

```solidity
// Standard fuzz test — randomized inputs to a single function
function testFuzz_Withdraw(uint256 amount) public {
    amount = bound(amount, 1, 1e30);
    vault.deposit{value: amount}();
    vault.withdraw(amount);
    assertEq(address(vault).balance, 0);
}

// Invariant test — random call sequences against the contract surface
contract VaultInvariantTest is Test {
    Vault vault;
    Handler handler;

    function setUp() public {
        vault = new Vault();
        handler = new Handler(vault);
        targetContract(address(handler));
    }

    function invariant_TotalSupplyEqualsSumOfBalances() public {
        assertEq(vault.totalSupply(), handler.sumOfBalances());
    }
}
```

```bash
# Run the fuzz test
forge test --match-test testFuzz_Withdraw --fuzz-runs 10000

# Run invariant tests. The run count comes from `runs` under [invariant] in
# foundry.toml (default 256) or FOUNDRY_INVARIANT_RUNS; call depth per run from
# `depth` (default 500) or --invariant-depth.
FOUNDRY_INVARIANT_RUNS=1000 forge test --match-test invariant_

# Fork tests — run against mainnet state at a specific block
forge test --fork-url $RPC_URL --fork-block-number 19000000

# Coverage
forge coverage --report lcov
```

Invariant tests with **handler contracts** are the high-leverage pattern: the handler bounds calls to realistic ranges, tracks ghost variables, and prevents the fuzzer from exploring useless paths. The Foundry [Invariant Testing guide](https://getfoundry.sh/guides/invariant-testing) documents the handler pattern (`targetContract`, bounded handlers, ghost variables); Trail of Bits' ["Building Secure Smart Contracts" program-analysis material](https://github.com/crytic/building-secure-contracts/tree/master/program-analysis) covers the equivalent Echidna and Medusa setups [verify 2026-11-04].

### 8.2 Echidna

[Echidna](https://github.com/crytic/echidna) (Trail of Bits) is a property-based fuzzer that has predated Foundry's invariant feature and remains the deepest-coverage option for complex protocols.

```bash
# Install
brew install echidna   # or download release from GitHub
echidna --version
```

```solidity
// Property example
contract TestVault {
    Vault vault = new Vault();

    function echidna_balance_never_negative() public view returns (bool) {
        return address(vault).balance >= 0;  // always true, but typical scaffold
    }

    function echidna_total_supply_equals_balances() public view returns (bool) {
        return vault.totalSupply() == vault.sumOfBalances();
    }
}
```

```bash
# Run
echidna . --contract TestVault --config echidna.yaml
```

Echidna's `seqLen`, `testLimit`, `coverage`, `corpusDir` config options drive depth. Maintain a reusable corpus across audit revisions to avoid re-discovering the same bug shapes.

### 8.3 Medusa

[Medusa](https://github.com/crytic/medusa) (Trail of Bits) is a go-ethereum-based fuzzer inspired by Echidna that fuzzes in parallel across workers. Its default property prefix is `property_`; add `echidna_` to `testPrefixes` to reuse Echidna properties. Use when Echidna is the bottleneck. [verify 2026-11-04]

[Chimera](https://github.com/Recon-Fuzz/chimera) (Recon) is a property-testing harness that lets one invariant suite run under Foundry, Echidna, Medusa and Halmos.

### 8.4 ityfuzz

[ityfuzz](https://github.com/fuzzland/ityfuzz) is a bytecode-level hybrid fuzzer that combines symbolic execution and fuzzing, for EVM and MoveVM contracts. It ships as nightly pre-release builds installed with `ityfuzzup` (latest nightly May 2025). [verify 2026-11-04]

### 8.5 Differential Fuzzing

When two implementations should behave equivalently (e.g. an audited reference implementation and an optimized production version), differential fuzzing runs the same input through both and asserts equivalence. Patterns: math-library refactors, gas-optimized rewrites of OZ libraries, cross-language ports (Vyper ↔ Solidity).

### 8.6 Stateful vs Stateless

- **Stateless fuzzing** (`testFuzz_*`): random inputs to a single function, contract starts fresh each run. Cheap; finds input-validation bugs.
- **Stateful fuzzing** (`invariant_*`, Echidna, Medusa): random call sequences across the full contract surface, with carry-over state. Expensive; finds composition bugs.

Most material findings come from stateful fuzzing with handler contracts. Allocate audit fuzz budget accordingly.

---

## 9. Formal Verification

Formal verification proves a property holds over all inputs (within configured bounds). It complements fuzzing — fuzzing finds counterexamples; formal verification finds the absence of counterexamples *for the property as encoded*. The "as encoded" caveat is load-bearing: if the auditor encoded the wrong property, the proof is useless.

### 9.1 When to Reach for Formal Verification

- Critical accounting invariants (total-supply equals sum-of-balances; no withdrawal exceeds deposit).
- Authorization invariants (only the admin can call X; only the holder can move Y).
- Mathematical properties of math libraries (mulDiv preserves precision within ±1 wei; the curve formula is monotonic).
- Bridge / cross-chain message-validity properties.
- Properties that fuzzing cannot cover in reasonable time — large state spaces, deep call sequences, properties involving symbolic addresses.

### 9.2 SMTChecker (Built into Solidity)

The [Solidity SMTChecker](https://docs.soliditylang.org/en/latest/smtchecker.html) is a built-in formal checker that runs at compile time. It uses z3, cvc5 (BMC engine only) or Eldarica (CHC engine only) as backends, or emits SMT-LIB2 queries for an external solver; cvc5 replaced CVC4 in Solidity 0.8.27. Free, but limited in what it can prove; mostly catches arithmetic and assertion violations.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
// Enable the checker by selecting an engine (solc --model-checker-engine chc,
// or foundry.toml below). `pragma experimental SMTChecker;` is deprecated and
// will be removed in Solidity 0.9.0.
// [profile.default.model_checker]
// engine = "chc"   # BMC, and "all" which includes it, deprecated since 0.8.37
// targets = ["assert", "underflow", "overflow", "divByZero", "balance", "constantCondition", "popEmptyArray", "outOfBounds"]
// timeout = 30000
```

Use SMTChecker as a first pass; reach for Certora / Halmos when SMTChecker can't express the property.

### 9.3 Halmos

[Halmos](https://github.com/a16z/halmos) (a16z) is a symbolic-testing tool for EVM contracts: bounded symbolic execution over Foundry-style tests. Write a test with symbolic inputs, Halmos proves the assertion holds for all inputs in the bound. Development has been quiet since v0.3.3 (2025-07-31); check the repo's status before relying on it with a current Foundry toolchain.

```bash
uv tool install --python 3.12 halmos   # or: pip install halmos
halmos
```

Halmos is the lowest-friction path for adding formal verification to an existing Foundry project: tests written for `forge test` often Halmos-ify with minimal changes.

### 9.4 Certora Prover

[Certora Prover](https://github.com/Certora/CertoraProver) is a formal-verification tool with a custom specification language (CVL — Certora Verification Language). Used by major protocols (Aave, Compound, Maker historically, Uniswap, OpenZeppelin's library) for high-assurance verification. The prover has been open source under GPL-3.0 since 2025; Certora also runs a cloud platform for users who prefer not to build it locally, so check that platform's current access terms when budgeting the engagement.

CVL specs sit alongside Solidity and encode invariants, hooks, and rules. Contract methods called without an `env` argument must be declared `envfree` in the `methods` block:

```text
methods {
    function balanceOf(address) external returns (uint256) envfree;
}

rule withdrawDecreasesBalance(address user, uint256 amount) {
    env e;
    require e.msg.sender == user;
    uint256 balanceBefore = balanceOf(user);
    withdraw(e, amount);
    uint256 balanceAfter = balanceOf(user);
    assert balanceAfter == balanceBefore - amount;
}
```

Certora's value is in the spec library it ships with each engagement (template invariants for ERC-20, ERC-4626, AccessControl, etc.) and in the prover's depth on EVM-specific reasoning.

### 9.5 K-framework (KEVM)

[KEVM](https://github.com/runtimeverification/evm-semantics) (Runtime Verification) is a formal semantics of the EVM in the K framework; supports proofs at the bytecode level. Used for high-stakes proofs such as Runtime Verification's 2018 bytecode-level verification of the Casper FFG contract. Runtime Verification's Foundry-facing front end is [Kontrol](https://github.com/runtimeverification/kontrol), which runs existing Foundry tests symbolically on KEVM; [hevm](https://github.com/argotorg/hevm) is a separate symbolic and concrete EVM execution engine. Higher friction than Halmos / Certora; reach for it when bytecode-level proofs are required (e.g. compiler-bug-resistant properties). [verify 2026-11-04]

### 9.6 Documenting Formal-Verification Findings

In the audit report, distinguish:

- **Verified property.** Stated in plain English, with the spec ID. The audit guarantees the property holds within the configured bounds.
- **Unverified property.** Stated, but the proof failed or was out of scope. The audit does not guarantee the property.
- **Out-of-scope property.** The team's stated invariant that the audit did not attempt to verify. List explicitly so the team and downstream consumers know what is and is not covered.

---

## 10. Audit Report Structure & Disclosure

The audit report is the audit. A complete review with no report is a missed engagement. Modern firms converge on a similar shape — Trail of Bits, OpenZeppelin, ConsenSys Diligence, Spearbit, Cantina, Cyfrin, Halborn, Zellic, Sigma Prime, Quantstamp — that this section summarizes.

### 10.1 Report Sections

1. **Executive Summary.** One page. Audience: non-engineering reader (founder, board). Scope, dates, headline findings, recommendation. Severity counts. Whether the audit's recommendations have been addressed.
2. **Project Summary.** What the protocol does, in plain terms. The team's threat model. What was in and out of scope. What integrations matter.
3. **Audit Scope.** Commit hash. Files in scope (with line counts). Files out of scope. Stated assumptions. Test-coverage snapshot at the audited commit.
4. **System Overview.** The auditor's understanding of the system, written. Often the most valuable section for the team — it surfaces ambiguities that drove findings.
5. **Findings.** Each finding gets: title, severity, status (Open / Acknowledged / Fixed / Partially Fixed), description, affected code location with line numbers, exploit scenario or impact narrative, recommendation, references (SWC ID, prior public similar finding). Sort by severity descending.
6. **Recommendations.** Non-finding suggestions. Often code-quality and gas-optimization items. Marked "Informational" or "Optional"; clearly distinct from security findings.
7. **Test Coverage Notes.** What the audit's test suite revealed. Gaps in the team's test coverage. PoCs the audit added.
8. **Threat Model Summary.** Trust assumptions, actor list, asset flows, invariants — the writeup from §4.
9. **Appendices.** Tooling output (Slither summary, Echidna corpus stats), formal-verification spec listing, glossary.

### 10.2 Severity Rubric

Severity scales differ by publisher: Immunefi's bug-bounty scale ([VSCS v2.3](https://immunefi.com/immunefi-vulnerability-severity-classification-system-v2-3/)) has four tiers (Critical / High / Medium / Low), and contest platforms are narrower (below). This SOP normalizes private-engagement reports to five tiers [verify 2026-11-04]:

| Severity | Definition |
|----------|------------|
| Critical | Direct loss of user funds or protocol funds in realistic conditions; total protocol failure; admin-key compromise pathway. |
| High | Fund loss or protocol failure under specific (but realistic) conditions; significant DoS; recoverable only by upgrade or off-chain intervention. |
| Medium | Conditional fund loss (requires specific market conditions, attacker capital, or timing); recoverable issues; impact bounded. |
| Low | Negligible fund impact; code-quality issues that could become severe under future changes; non-critical DoS. |
| Informational | Code-quality, naming, optimization. No security impact. |

Contest platforms judge on their own scales. [Code4rena](https://docs.code4rena.com/competitions/severity-categorization) rates security findings High or Medium; Low-risk and governance / centralization items go into a QA report, and informational items are discouraged. [Sherlock's judging guidelines](https://docs.sherlock.xyz/audit-contests-deprecated-replaced-by-audit-engine/judging/guidelines) reward only High and Medium and set numeric loss thresholds (High: loss of more than 1% and more than $10 of principal, yield or fees without extensive external conditions; Medium: more than 0.01% and more than $10, or broken core functionality); Sherlock's docs now file contests under a section marked deprecated and replaced by its "Audit Engine". [Cantina](https://docs.cantina.security/standards/severity/competition) derives High / Medium / Low / Informational from an impact × likelihood matrix. [verify 2026-11-04]

The severity of a finding is a function of impact × likelihood, not impact alone. A "Critical impact, near-zero likelihood" finding is reported but typically rated lower than a "Medium impact, certain occurrence" finding. Document both axes in the finding writeup.

### 10.3 Finding Writeup Shape

Example writeup for a High finding (the Curve reference dates come from ChainSecurity's 2022-10-11 post-mortem [verify 2026-11-04]):

```text
[H-01] Reentrancy in Vault.withdraw() drains contract via cross-function path

Severity: High
Status: Open
Affected: contracts/Vault.sol#L142-L168

Description:
Vault.withdraw() makes an external call to msg.sender before zeroing the
caller's balance. A malicious contract can re-enter Vault.transferShare()
during the external call. transferShare() reads the not-yet-zeroed balance
and credits it to a second address controlled by the attacker. Repeating
the pattern drains the vault.

Exploit Scenario:
1. Attacker deploys MaliciousReceiver.
2. Attacker deposits 100 ETH to Vault from MaliciousReceiver.
3. Attacker calls Vault.withdraw(100 ETH).
4. Vault.withdraw issues msg.sender.call{value: 100}, transferring control
   to MaliciousReceiver.fallback().
5. fallback() calls Vault.transferShare(addr2, 100). transferShare reads
   balance[MaliciousReceiver] (still 100), debits it (=0), credits balance[addr2] (=100).
6. fallback() returns. withdraw zeroes balance[MaliciousReceiver] (=0; no
   change). MaliciousReceiver has 100 ETH and addr2 has a 100-share credit.
7. Attacker calls Vault.withdraw(100) from addr2 and repeats.

Recommendation:
Apply the checks-effects-interactions pattern: zero the caller's balance
before the external call. Add the OpenZeppelin nonReentrant modifier to
withdraw() and transferShare() (and any other function that reads or
writes balances).

References:
- SWC-107 (Reentrancy)
- The DAO 2016
- Curve read-only reentrancy (get_virtual_price): ChainSecurity disclosure
  to Curve 2022-04-14, public post-mortem 2022-10-11
```

### 10.4 Disclosure & Public Reporting

For private engagements: draft to client → revisions → final → mutually-agreed public version (sometimes weeks or months later, sometimes never). Some clients publish; some do not; respect contractual terms.

For public-contest reporting: the platform owns the disclosure timeline. Code4rena / Cantina publish post-judging; Sherlock's past contest reports remain in its public archive.

For findings discovered in-the-wild during the audit (the auditor finds an active exploit on a deployed contract that is in scope): immediately escalate to the client's security contact via the agreed encrypted channel. Do not commit details to the engagement repo. Preserve PoC artifacts under the engagement OPSEC posture per [[sop-opsec-plan|OPSEC]]. The protocol team typically coordinates with chain-level emergency response (validator outreach, sequencer pause if the chain has a privileged sequencer, exchange notifications) — the auditor's role is technical, not operational, unless explicitly extended. If the client is unreachable or the exploit is already live, [SEAL 911](https://securityalliance.org/our-work/seal-911) (Security Alliance) provides 24/7 incident response for the crypto ecosystem. A whitehat intervention is pre-authorized only where the protocol has adopted the [SEAL Whitehat Safe Harbor](https://github.com/security-alliance/safe-harbor) agreement (v3.0, February 2026) and the auditor follows its terms; otherwise do not touch funds. Legal framing: [[sop-legal-ethics|Legal & Ethics]].

### 10.5 Remediation Verification

After the team patches, the auditor reviews fix commits. Typical posture:

- Per finding, mark status: **Fixed** / **Partially Fixed** / **Not Fixed** / **Acknowledged** / **Won't Fix**.
- For Fixed: cite the fix commit hash and verify the fix addresses the root cause, not just the reported symptom.
- For Partially Fixed: explain what is and is not addressed. Suggest follow-up work.
- For Acknowledged / Won't Fix: document the team's stated rationale; the auditor may or may not concur and should say so.
- The remediation pass produces a remediation appendix or a delta report. Tag the report version (V1 / V2) so downstream consumers can tell which version they are reading.

---

## 11. Multi-Chain Coverage

EVM dominates the audit market (Ethereum mainnet, Arbitrum, Optimism, Base, Polygon, BNB Chain, Avalanche C-chain, zkSync, Linea, Scroll, Mantle, etc.); the same Solidity / Vyper review methodology travels across L1s and L2s with chain-specific caveats. Non-EVM chains require chain-specific tooling and different bug shapes.

### 11.1 EVM Mainnet vs L2 Caveats

- **Sequencer trust.** Optimism / Arbitrum / Base have a sequencer that orders transactions; if the sequencer is centralized (Arbitrum's documentation, for example, lists decentralized sequencing as a long-term goal [verify 2026-11-04]), the chain inherits the sequencer's liveness and ordering trust. Protocols on these L2s should consult the sequencer-uptime feed before liquidations or other timing-sensitive actions.
- **L1 → L2 message latency.** Cross-domain messengers have multi-hour or multi-day delays for L2-to-L1 (Optimistic Rollups, ~7-day challenge window) or seconds-to-minutes (ZK-rollups). Protocols that assume same-block messaging across L1↔L2 are broken.
- **EIP support drift.** Not all L2s support all opcodes at all times. `PUSH0` (emitted by default since Solidity 0.8.20) arrived on Arbitrum One only with ArbOS 11 (shipped in Nitro v2.2.0 in December 2023, activated after a DAO vote in late January 2024), about nine months after mainnet's Shanghai upgrade in April 2023 [verify 2026-11-04]. Compiler version selection is part of the threat model.
- **Gas pricing differences.** L2s have L1-data-cost components that affect gas optimization decisions. Calldata is more expensive on L2s than mainnet (relatively); storage is cheaper.
- **Reorg properties.** L1 mainnet has finality after ~13-15 minutes (two epochs of 32 twelve-second slots post-merge); some L2s have soft finality at sequencer level and hard finality only when batches post to L1. Protocols sensitive to reorgs (oracles, bridges) should encode the chain-specific finality assumption.

### 11.2 Vyper

[Vyper](https://docs.vyperlang.org) is a Pythonic EVM language with major production deployments, Curve's pools among them. Audit methodology is the same as Solidity at the bytecode level; the bug shapes are mostly the same. Vyper-specific pitfalls have produced large incidents — on 2023-07-30 several Curve pools were exploited through a compiler bug that misallocated `@nonreentrant` locks in Vyper 0.2.15, 0.2.16 and 0.3.0 (GHSA-5824-cm3x-3c38, fixed in 0.3.1) [verify 2026-11-04]. Pin the compiler version explicitly and check it against the [Vyper security advisories](https://github.com/vyperlang/vyper/security/advisories).

### 11.3 Move (Sui, Aptos)

Move is the language of Sui and Aptos. Move's resource-oriented type system ("resources cannot be copied or implicitly discarded") eliminates several EVM bug classes by construction (double-spend of in-memory token objects, accidental drop of valuable resources). Different bug classes appear: capability-pattern misuse (the equivalent of access-control), object-ownership confusion, epoch-boundary effects on Sui-specific timing assumptions, on-chain resource exhaustion patterns specific to Move's storage model.

Tooling: on Aptos, the [Move Prover](https://aptos.dev/build/smart-contracts/prover) runs from the Aptos CLI (`aptos move prove`, after a separate prover install step), alongside `aptos move compile` / `aptos move test`. The Sui CLI has no prover (`sui move build` / `sui move test`); formal verification on Sui uses the separate [Sui Prover](https://github.com/asymptotic-code/sui-prover) from Asymptotic. Audit firms maintain Move-specific guides; cite the chain-specific guide for engagement-specific patterns. [verify 2026-11-04]

### 11.4 Solana

Solana programs are written in Rust (native or Anchor-framework). Audit methodology shifts: account-model rather than contract-model (a Solana program does not own state; state lives in accounts the program operates on); program-derived addresses (PDAs) and seed derivations are correctness-critical; CPI (cross-program invocation) is the equivalent of external calls and has its own reentrancy / authority pitfalls; rent and account-size semantics matter.

Bug classes specific to Solana: missing signer checks, missing owner checks, account-substitution attacks, PDA-seed collisions, integer-overflow in `u64` math (Rust's native overflow behavior depends on `release` vs `debug`), CPI authority confusion, lamport-balance-not-checked-after-CPI.

Tooling: [Anchor](https://www.anchor-lang.com/docs) (v1.x; 2.0 in release candidate), whose built-in `anchor verify <program-id>` checks on-chain bytecode against the local build; [solana-verifiable-build](https://github.com/solana-foundation/solana-verifiable-build) for deterministic builds and on-chain verification; `cargo test`; [Trident](https://github.com/Ackee-Blockchain/trident) (Ackee Blockchain) for fuzzing; and [sec3 X-ray](https://github.com/sec3-product/x-ray) for static analysis. [verify 2026-11-04]

### 11.5 Cairo / Starknet

Cairo is the language of Starknet (and was used historically for ZK-STARK provable computation). Cairo 1.x (Rust-like syntax, post-2023) replaced Cairo 0.x. Different memory model (immutable memory + Felt252 field-element arithmetic), different ABI, different bug shapes. Underlying ZK-VM correctness is part of the trust assumption.

Bug classes specific to Starknet / Cairo: storage-slot collisions (slot addresses derive from `sn_keccak` of the variable name, Pedersen-hashed with the keys for mappings, so two components reusing a storage name collide), syscall misuse (e.g. `library_call` with a user-controlled class hash), L1 handlers that do not check the sender's `from_address` (L1↔L2 message handling, same as L2 caveats above but with Starknet-specific semantics), and `felt252` arithmetic, which is not overflow / underflow safe. [Caracal](https://github.com/crytic/caracal) (Trail of Bits) has detectors for the last three, but has been unmaintained since January 2024; check its output against current Cairo versions. [verify 2026-11-04]

### 11.6 CosmWasm

CosmWasm contracts are Rust compiled to Wasm and run on Cosmos SDK chains. They follow an actor model: a contract does not call another contract mid-execution but returns messages for the chain to dispatch, and results come back through the `reply` entry point, which avoids EVM-style reentrancy into a half-finished execution. Review focus shifts to message dispatch and `reply` handling and, for IBC-enabled contracts, the packet entry points (`ibc_packet_receive`, `ibc_packet_ack`, `ibc_packet_timeout`). Unit tests run under `cargo test`; [cw-multi-test](https://github.com/CosmWasm/cw-multi-test) covers multi-contract interactions. [verify 2026-11-04]

### 11.7 Bytecode-Only Audits

For deployed contracts whose source is not verified, decompilation is the entry point. [Heimdall-rs](https://github.com/Jon-Becker/heimdall-rs) and the [Dedaub](https://dedaub.com) Security Suite decompiler lift bytecode to readable pseudo-Solidity; [Panoramix](https://github.com/palkeo/panoramix) does the same but is unmaintained (last release 2020, last commit June 2023). Differential review against the pseudo-Solidity is significantly higher-friction than source review; the audit cost is larger and the confidence is lower. This SOP recommends bytecode-only audits be staffed by RE-strong reviewers and explicitly flagged in the engagement letter as a different-confidence deliverable.

---

## 12. Hand-off Boundaries

| When the audit observes... | Routes to... |
|----------------------------|--------------|
| Suspicious withdrawal pattern in the post-deployment monitoring window | [[../../Investigations/Techniques/sop-blockchain-investigation|Blockchain Investigation]] for fund tracing |
| Funds entering Tornado Cash, a WabiSabi / Wasabi-style CoinJoin round (zkSNACKs' coordinator closed 2024-06-01; independent coordinators continue), historical Samourai Whirlpool outputs (service seized April 2024), or a cross-chain bridge for obfuscation | [[../../Investigations/Techniques/sop-mixer-tracing|Mixer & Privacy-Pool Tracing]] |
| Off-chain backend / signer infrastructure / web frontend vulnerability | [[../Pentesting/sop-web-application-security|Web Application Security]] / [[../Pentesting/sop-vulnerability-research|Vulnerability Research]] |
| Mobile-wallet or hardware-wallet integration issue | [[../Pentesting/sop-mobile-security|Mobile Security]] |
| Cryptographic primitive concern (curve choice, hash construction, ZK-circuit soundness, threshold-signature scheme) | [[sop-cryptography-analysis|Cryptography Analysis]] |
| Bytecode-only deployed contract requiring decompilation / lifted-IR review | [[sop-reverse-engineering|Reverse Engineering]] (with this SOP's review methodology applied to the lifted output) |
| Bug bounty or audit-contest submission (Immunefi, HackerOne crypto programs, Code4rena / Cantina contests) | [[../Pentesting/sop-bug-bounty|Bug Bounty]] |
| Disclosure / coordinated-publication mechanics, vendor encrypted comms, CERT routing | [[../../Investigations/Techniques/sop-reporting-packaging-disclosure|Reporting, Packaging & Disclosure]] |
| Live-incident triage where funds are moving and patches are needed in minutes-to-hours | Hand-off to the protocol's security-response process; this SOP covers technical findings, not operational incident command |
| Protocol-team OPSEC concerns (multisig signer device hygiene, deployment-key rotation, incident-response drills) | [[sop-opsec-plan|OPSEC]] |
| Authorized engagement contract / safe-harbor language / jurisdictional questions about audit scope | [[sop-legal-ethics|Legal & Ethics]] |

The audit deliverable stops at the boundary of the protocol's source code. Where on-chain consequences leave the protocol's contracts (funds move, attackers cross chains, mixers wash flows), the methodology hands off to the investigations track.

---

## 13. Tools Reference

### Static Analysis & Linting

| Tool | Purpose | Link |
|------|---------|------|
| Slither | Detector-based static analysis (Solidity, Vyper) | https://github.com/crytic/slither |
| Aderyn | Rust-based static analysis (Solidity) | https://github.com/Cyfrin/aderyn |
| Wake | Python-based dev framework + static analysis | https://github.com/Ackee-Blockchain/wake |
| Mythril | Symbolic execution (bytecode level) | https://github.com/ConsenSysDiligence/mythril |
| Semgrep | Pattern-based linting (multi-language, Solidity rule packs) | https://semgrep.dev |
| Solhint | Solidity linter (security, style-guide, best-practice rules) | https://github.com/protofire/solhint |
| Surya | Call-graph and inheritance visualization | https://github.com/ConsenSysDiligence/surya |

### Fuzzing & Property Testing

| Tool | Purpose | Link |
|------|---------|------|
| Foundry (`forge`) | Solidity testing, fuzzing, invariant testing, fork testing | https://getfoundry.sh |
| Echidna | Property-based fuzzer for Solidity | https://github.com/crytic/echidna |
| Medusa | Go-based parallel fuzzer inspired by Echidna (property prefix `property_`; add `echidna_` to `testPrefixes` to port Echidna tests) | https://github.com/crytic/medusa |
| ityfuzz | Hybrid symbolic-execution + fuzzing (EVM, MoveVM) | https://github.com/fuzzland/ityfuzz |
| Hardhat | JS-based dev framework (alt to Foundry) | https://hardhat.org |

### Formal Verification

| Tool | Purpose | Link |
|------|---------|------|
| SMTChecker | Built-in Solidity formal checker (z3 / cvc5 / Eldarica) | https://docs.soliditylang.org/en/latest/smtchecker.html |
| Halmos | Symbolic testing over Foundry-style tests (no release since v0.3.3, 2025-07-31; confirm maintenance status before relying on it) | https://github.com/a16z/halmos |
| Certora Prover | Formal-verification prover (CVL spec lang); open source under GPL-3.0 since 2025, plus a Certora-run cloud platform | https://www.certora.com (source: https://github.com/Certora/CertoraProver) |
| KEVM | K-framework EVM semantics (bytecode-level proofs) | https://github.com/runtimeverification/evm-semantics |
| Move Prover | Formal verification for Aptos Move (`aptos move prove`) | https://aptos.dev/build/smart-contracts/prover |
| Sui Prover | Formal verification for Sui Move (Asymptotic) | https://github.com/asymptotic-code/sui-prover |

### Decompilation & Bytecode

| Tool | Purpose | Link |
|------|---------|------|
| Panoramix | EVM bytecode decompiler (unmaintained; last commit 2023-06; prefer Heimdall-rs) | https://github.com/palkeo/panoramix |
| Heimdall-rs | Rust EVM decompiler / disassembler | https://github.com/Jon-Becker/heimdall-rs |
| Dedaub Security Suite | Web-hosted bytecode decompilation + analysis | https://dedaub.com |
| evm.codes | EVM opcode reference + interactive playground | https://www.evm.codes |

### Audit Repositories & Reference

| Resource | Purpose | Link |
|----------|---------|------|
| SWC Registry | Smart Contract Weakness Classification (no longer actively maintained; content not thoroughly updated since 2020; the site points to the EEA EthTrust Security Levels for current guidance) | https://swcregistry.io |
| Solodit | Aggregated public audit findings (Cyfrin) | https://solodit.cyfrin.io |
| Trail of Bits "Building Secure Contracts" | Patterns + tooling guidance | https://github.com/crytic/building-secure-contracts |
| Consensys Smart Contract Best Practices | Pattern catalogue + known attacks | https://consensys.github.io/smart-contract-best-practices/ |
| OpenZeppelin Forum (Security) | OZ library advisories + patterns | https://forum.openzeppelin.com/c/security/25 |
| Code4rena Reports | Public competitive-audit findings | https://code4rena.com/reports |
| Sherlock Audits | Public competitive-audit findings (Sherlock's docs mark contests as replaced by its Audit Engine; the public contest archive remains here) | https://audits.sherlock.xyz/contests |
| Cantina Reports | Public competitive-audit findings | https://cantina.security |
| Rekt News | Incident catalogue for post-mortem study | https://rekt.news |
| DeFiLlama Hacks | Incident catalogue + losses | https://defillama.com/hacks |

---

## 14. Risks & Limitations

- **Audit ≠ guarantee of safety.** An audit is evidence of professional review at a specific commit hash within a specific time budget against a specific scope. Code that compiles to the same bytecode but deployed under different storage / parameters / integrations is no longer covered. Audits frequently report this in the executive summary; downstream consumers (insurers, integrators, exchanges deciding to list a token) sometimes ignore it.
- **Tooling false-negatives.** Slither / Aderyn / Wake / Mythril / Echidna / Halmos all miss bug classes the auditor must catch by reading. Tooling is necessary but not sufficient. Conversely, tooling false-positives consume audit budget; triage discipline matters.
- **Test-suite gaps the audit inherits.** If the team's existing test suite has 40% line coverage, the audit either spends budget building coverage (which slows finding-discovery) or accepts the gap (which weakens the deliverable). Document the test-coverage state in the report so downstream consumers can interpret.
- **Composability surface that changes after the audit.** The audited protocol can be safe in isolation but unsafe against an upstream integration deployed weeks later. Ongoing review (continuous-audit retainer, monitoring) is the only mitigation; one-shot audits cannot promise composability safety against future integrations.
- **Re-audit drift.** A single auditor seeing the same codebase twice may anchor on prior findings and miss new ones. Multi-firm audits, rotating auditor pairs within a firm, and contest-style competitive auditing mitigate.
- **Severity disagreement.** Severity is a judgment call. Different auditors will rate the same finding differently. Document the rationale; expect the team to push back on Highs that are realistically Medium and to want to see Mediums escalated when the team perceives reputational risk.
- **Time-budget framing.** "We audited for 3 person-weeks" is a stronger claim than "We audited" with no time disclosure. Report the time budget; downstream consumers calibrate trust on it.
- **Public-contest reliance.** Code4rena / Cantina / Immunefi contests find different bug shapes than firm engagements (more eyeballs, less time per eyeball, contest-incentive distortions). Pair, don't substitute: combine a contest with a firm or internal review rather than using it as the sole pre-deployment gate.
- **Formal-verification scope.** A verified property is valuable; an unverified or out-of-scope property is not. The audit must explicitly state which properties were verified, with what tool, against what bound. Vague "we ran formal verification" claims are worse than no claim.
- **Audit-firm reputation laundering.** A logo on a website ≠ a passing report. Insurers, exchanges, and downstream protocols should read the report, not the logo. Auditors should resist the demand to publish a "summary" that omits unfixed findings; a report missing its findings is a marketing artifact, not an audit.
- **Court-admissibility of audit findings.** In post-incident litigation (theft, regulatory action, lender-borrower disputes), audit reports are sometimes introduced as evidence. The auditor's name, time budget, methodology disclosure, and severity rationale all become subject to expert-witness scrutiny. Document accordingly.

---

## 15. Common Pitfalls

- **Skipping the threat model.** Findings without a threat model are findings without context; severity becomes guesswork.
- **Single-pass review.** A first read finds the bugs you expect; a second read finds the bugs you didn't. Budget for at least two passes per major component.
- **Treating tooling output as the audit.** Slither / Mythril / Echidna are a starting point. The report's value is in the manual reading.
- **Over-reliance on one tool's coverage.** Slither + Echidna + Halmos + manual reading covers more than any one of them alone.
- **Reporting low-severity items as informational.** Items below Low severity belong in a separate "Recommendations" section, not in the security findings count. Inflating findings counts erodes auditor credibility.
- **Severity inconsistency across the report.** A Critical in one section and a Medium in another for the same impact class confuses readers and the team's triage queue.
- **Reporting without reproductions.** Every High / Critical should have a reproducible PoC (Foundry test, Echidna config, or step-by-step). The team needs them to verify the fix.
- **Missing remediation pass.** The audit is incomplete without verifying the patches. Schedule the remediation pass at engagement intake.
- **Disclosing publicly before the team patches.** For private engagements, the team owns the disclosure timeline. Public-contest disclosure runs through the platform's clock.
- **Citing only SWC IDs.** SWC is a legacy, unmaintained taxonomy; pair it with EthTrust requirement IDs or OWASP SC Top 10 categories, and use Solodit and firm-internal labels for precision.
- **Mixing audit findings with code-quality nits.** Code-quality is "Recommendations." Security findings are "Findings." A reader who can't tell the two apart can't act on either.
- **Out-of-scope creep.** Audit time spent on out-of-scope code is time not spent on in-scope code. If the team wants out-of-scope coverage, scope it explicitly and bill it.
- **Reporting CVSS scores for smart-contract findings.** CVSS is calibrated for traditional software; on-chain impact does not map cleanly. Use the smart-contract-firm severity rubrics (§10.2). If a CNA assigns a CVE, the CNA may produce a CVSS; the auditor's report severity is separate.
- **Trusting the team's stated invariants without verification.** Teams sometimes mis-state their own invariants. The audit verifies; it does not just transcribe.
- **Skipping fork testing on protocols with major integrations.** If the protocol depends on Uniswap V3, Aave, Curve, or Chainlink, mainnet-fork tests against real integration state catch bugs unit tests miss.
- **Pasting Mythril / Slither output verbatim into the report.** Tooling output is for the appendix; findings are for the report body and require auditor judgment.
- **Acknowledging "Won't Fix" without rationale.** "Acknowledged" with no team-stated reason is uncomfortable for downstream readers. Capture the rationale.
- **Using "100% test coverage" as the audit deliverable.** Coverage is necessary but not sufficient; an audit's value is in finding what coverage missed.
- **Conflating "deployed and used" with "audited and safe."** Many large protocols run un-audited or partially-audited code; downstream integrators must verify, not assume.
- **Auditing from a forked branch instead of the deployed bytecode-equivalent commit.** The audit must match what gets deployed. Pin the bytecode-equivalent commit; verify the deployed bytecode matches.
- **Skipping the gas-DoS analysis.** Unbounded loops, unbounded storage iteration, and per-user state proliferation can DoS the protocol once usage scales. Include in the audit, even when not exploitable for direct theft.

---

## 16. Real-World Patterns & Scenarios

The scenarios below abstract published-incident patterns to illustrate how the methodology in this SOP catches them. They are pattern catalogues, not exploit walkthroughs; see the cited Rekt News / DeFiLlama Hacks entries for incident detail.

### 16.1 Scenario — Lending Protocol with Read-Only Reentrancy in a Pool's Price Function

A lending protocol uses a Curve-style stable pool's `get_virtual_price()` view function as part of its collateral-pricing logic. Curve's read-only reentrancy class (ChainSecurity disclosed it to Curve on 2022-04-14; subsequent incidents followed) [verify 2026-11-04] means that during `remove_liquidity` (mid-call), `get_virtual_price()` returns an inconsistent value to integrators that read it from within that call's external-call window.

**Audit catch.** §6.1 read-only reentrancy variant. The auditor checks every external integration's view function and asks "could this be called mid-update from upstream?" Mitigation is the read-only-reentrancy-guard pattern (`require(!_lock)` on the view function) or caching the value pre-call on the consumer side.

**Ownership.** Findings of this class are smart-contract audit territory. Once an exploit drains funds, downstream tracing of the withdrawn funds routes to [[../../Investigations/Techniques/sop-blockchain-investigation|Blockchain Investigation]]; if the attacker mixes via Tornado Cash or a CoinJoin coordinator, deobfuscation routes to [[../../Investigations/Techniques/sop-mixer-tracing|Mixer & Privacy-Pool Tracing]].

### 16.2 Scenario — Oracle Manipulation Amplified by Flash Loan

A lending market accepts an LP token as collateral and prices it via the underlying pool's spot price. An attacker flash-loans large capital, swaps to push the spot price 30%, deposits the now-overpriced LP token, borrows the maximum against it, and lets the swap reverse, leaving the protocol with under-collateralized debt.

**Audit catch.** §6.3 oracle manipulation, §6.10 flash-loan amplification. The auditor identifies every price source, walks the manipulation cost (cost to move the price by N% × the amount of collateral the attacker can deposit at the manipulated price), and asks "does the protocol's borrowing cap and oracle smoothing make this unprofitable for any realistic flash-loaned capital?" Mitigation is TWAP windows and pool depth sized so multi-block manipulation is unprofitable (§6.3), multi-source medianization, deviation circuit-breakers, and per-asset borrow caps that limit blast radius.

### 16.3 Scenario — Upgradeable Proxy with Storage-Layout Drift

V1 of a protocol's UUPS-upgradeable contract has state variables `(uint256 totalSupply, mapping(address => uint256) balances)`. V2 adds a new variable `(address admin)` at slot 0, intending to push `totalSupply` to slot 1 and `balances` to slot 2. The deployed proxy still has `totalSupply` value at slot 0; after upgrade, the proxy reads slot 0 as `admin`, slot 1 as `totalSupply`, slot 2 as `balances` — corrupting all three.

**Audit catch.** §6.6 storage collision. The auditor runs OpenZeppelin Upgrades' storage-layout checker on the V1 → V2 diff at engagement intake; the tool flags any layout-incompatible change. Mitigation is to never reorder, only append; or to use namespaced storage (ERC-7201) [verify 2026-11-04] to insulate facets from layout drift.

### 16.4 Scenario — Governance Attack with Flash-Loaned Voting Power

A governance system samples voting power at the moment a vote is cast. An attacker flash-loans the governance token, votes "yes" on a proposal that grants their address admin authority, repays the flash loan in the same transaction. Total cost: gas + flash-loan fee. The attacker now controls the protocol.

**Audit catch.** §6.9 flash-loan governance. The auditor checks the voting-power checkpoint: snapshot at a block fixed before voting opens, e.g. proposal creation + `votingDelay` (mitigates), snapshot at vote-cast block (does not mitigate), live read (does not mitigate). The Compound Governor Bravo pattern — `getPriorVotes` at the proposal's `startBlock` (creation block + `votingDelay`), fixed before voting opens — is the canonical mitigation.

---

## 17. Related SOPs

**Investigations (post-exploit and tracing):**
- [[../../Investigations/Techniques/sop-blockchain-investigation|Blockchain Investigation]] — multi-chain tracing methodology, post-exploit fund tracing, court-admissibility tradecraft. Receives hand-offs from this SOP when funds leave a contract.
- [[../../Investigations/Techniques/sop-mixer-tracing|Mixer & Privacy-Pool Tracing]] — CoinJoin / Tornado Cash / cross-chain-bridge obfuscation defeat. Receives hand-offs when post-exploit funds enter a mixer.
- [[../../Investigations/Techniques/sop-financial-aml-osint|Financial & AML OSINT]] — fiat AML, banking pivots, corporate UBO; AML-analyst quick-reference for crypto.
- [[../../Investigations/Techniques/sop-collection-log|Collection Log]] — defensible activity-log format for audit-engagement testing sessions and PoC artifacts.
- [[../../Investigations/Techniques/sop-reporting-packaging-disclosure|Reporting, Packaging & Disclosure]] — coordinated-disclosure mechanics for findings that touch external parties.

**Analysis:**
- [[sop-cryptography-analysis|Cryptography Analysis]] — cryptographic primitive evaluation (curve choice, hash construction, ZK-circuit soundness, threshold-signature schemes).
- [[sop-malware-analysis|Malware Analysis]] — when smart-contract findings tie into broader malware operations (drainer kits, malicious npm packages targeting crypto devs).
- [[sop-reverse-engineering|Reverse Engineering]] — bytecode-only audits, decompilation, lifted-IR review.
- [[sop-forensics-investigation|Forensics Investigation]] — incident-response artifact handling for breach scenarios.
- [[sop-hash-generation-methods|Hash Generation Methods]] — evidence-integrity hashing for audit artifacts.

**Pentesting & Security:**
- [[../Pentesting/sop-vulnerability-research|Vulnerability Research]] — general offensive methodology (native-binary fuzzing, exploit development, CVE process); smart-contract findings stay in this SOP.
- [[../Pentesting/sop-bug-bounty|Bug Bounty]] — general submission workflow for bounty programs and audit contests (Immunefi, HackerOne crypto, Code4rena, Cantina); platform-specific rules come from each platform.
- [[../Pentesting/sop-web-application-security|Web Application Security]] — web3 frontend, signing-UX, off-chain backend findings.
- [[../Pentesting/sop-mobile-security|Mobile Security]] — wallet-app / hardware-wallet integration findings.

**Cross-cutting:**
- [[sop-legal-ethics|Legal & Ethics]] — canonical jurisdictional framework for engagement contracts and disclosure.
- [[sop-opsec-plan|OPSEC]] — auditor infrastructure, artifact hygiene, and pre-disclosure handling discipline.

---

## Legal & Ethical Considerations

> Canonical jurisdictional framework lives in [[sop-legal-ethics|Legal & Ethics]]. The summary below is operational guidance for smart-contract audit engagements specifically; do not substitute it for the cross-referenced source.

### Engagement Authorization

A signed engagement letter (or, for public contests, the platform's published rules + scope page accepted at registration) is the legal authorization. Key elements an auditor verifies before the first contract is read:

- **Identity and authority.** The signing entity is the entity that owns the code or has the authority to authorize a review. For DAOs, this can require an on-chain governance vote authorizing the engagement.
- **Scope (commit hash, files, integrations).** Written; pinned; not subject to mid-engagement expansion without an explicit amendment.
- **Time budget and deliverable.** What the report covers, what it does not, and the schedule.
- **Disclosure terms.** Who receives the draft; who receives the final; whether the team will publish; how findings affecting third parties (oracle providers, integrators) are coordinated.
- **Warranty and liability framing.** Most engagement contracts disclaim warranty (the audit does not guarantee safety) and limit liability. Verify the language matches your firm's standard or insurer's requirements.
- **Safe-harbor analog.** Code4rena's [Terms of Service](https://docs.code4rena.com/legal/terms-of-service) contain an explicit "Safe Harbor (Authorization to Test)" clause scoped by each contest's program materials; other platforms' terms differ, so read the current terms for each contest and apply the safe-harbor checklist in [[../Pentesting/sop-bug-bounty|Bug Bounty]]. SEAL's Whitehat Safe Harbor covers rescues during live exploits, not contest testing. Private engagements rely on contract terms; verify they cover the auditor's actions.

### Anti-Hacking Statute Framing

Smart-contract audits operate against code, not deployed state, so the CFAA / Computer Misuse Act / Cybercrime Directive concerns that apply to live-system pentesting are reduced — but not absent; see [[sop-legal-ethics|Legal & Ethics]] for the statute-level framing. Specifically:

- **Mainnet-fork testing** against the engagement's RPC endpoint executes locally against a state snapshot and sends no transactions. The engagement letter's RPC authorization (§2) and the RPC provider's terms cover it.
- **Active sending of transactions to deployed contracts the engagement does not authorize** is the line. Reads via `eth_call` create no transaction and touch no state, but they still go through an RPC provider under its terms; a view function invoked inside a signed transaction is on-chain. When in doubt, route through a fork.
- **Probing testnet deployments the team operates** is generally authorized within the engagement; verify in the engagement letter.
- **Probing mainnet deployments of the protocol under audit** is a gray area in many jurisdictions; verify explicit authorization in the engagement letter for any mainnet interaction. Bug-bounty programs sometimes authorize specific mainnet probing under safe-harbor; audit engagements usually do not.

### Disclosure Discipline

- Pre-disclosure findings are restricted to the engagement team and the client per the contract.
- Public-contest findings follow the platform's clock.
- Findings affecting third parties (Chainlink, Uniswap, oracle providers, bridge protocols) are escalated through the affected party's security contact, not embedded silently in the client's report.
- Live-incident findings (the audit discovers an active exploit) trigger immediate client escalation; subsequent operational response is the client's, not the auditor's, unless explicitly contracted.

### Conflict-of-Interest Posture

- The auditor does not hold the audited protocol's tokens during the engagement (or holds in a documented, disclosed, recused capacity).
- The auditor does not trade the protocol's tokens during or immediately after the engagement window.
- The auditor does not publish independent commentary on the protocol's security during the engagement.
- For DAO governance proposals affecting the audited protocol, the auditor abstains.

### Post-Engagement Records

- The engagement repo is retained per the contract terms (often 1-5 years).
- PoC scripts are retained encrypted at rest per [[sop-opsec-plan|OPSEC]].
- Litigation-hold provisions: if the protocol is later subject to litigation, prior audit material can become discoverable. Document accordingly.

### Ethical Research Checklist

**Before engagement:**
- [ ] Written engagement contract covering scope, time, deliverable, disclosure
- [ ] Public-contest scope page reviewed and accepted (for contests)
- [ ] Conflict-of-interest disclosure complete

**During engagement:**
- [ ] Only test in-scope code at the pinned commit
- [ ] Mainnet-fork testing authorized; live-mainnet probing only where explicitly authorized
- [ ] Findings tracked with reproductions in the engagement repo
- [ ] No trading of the protocol's tokens

**After engagement:**
- [ ] Report delivered per contract
- [ ] Remediation pass scheduled / completed
- [ ] PoC artifacts retained per OPSEC
- [ ] Disclosure-clock obligations met

---

## 18. External & Reference Resources

**Defect taxonomies and audit-finding catalogues:**
- SWC Registry (no longer actively maintained; content not thoroughly updated since 2020; the site points to the EEA EthTrust Security Levels for current guidance) — https://swcregistry.io
- Solodit — https://solodit.cyfrin.io
- DASP Top 10 (historical; dasp.co is offline behind HTTP authentication as of 2026-11) — archived copy: https://web.archive.org/web/20240102011402/https://dasp.co/
- Trail of Bits "Building Secure Smart Contracts" — https://github.com/crytic/building-secure-contracts
- Consensys Smart Contract Best Practices — https://consensys.github.io/smart-contract-best-practices/
- OpenZeppelin Forum — https://forum.openzeppelin.com/c/security/25

**Public competitive-audit reports:**
- Code4rena — https://code4rena.com/reports
- Sherlock (past-contest archive) — https://audits.sherlock.xyz/contests
- Cantina — https://cantina.security
- Cyfrin — https://github.com/Cyfrin/cyfrin-audit-reports (public report archive; service page: https://www.cyfrin.io/services/audits)

**Standards and EIPs:**
- Ethereum Improvement Proposals — https://eips.ethereum.org
- ERC-20 / ERC-721 / ERC-1155 / ERC-4626 (token standards)
- ERC-1967 (Proxy Storage Slots)
- ERC-2535 (Diamonds, Multi-Facet Proxy)
- ERC-7201 (Namespaced Storage Layout)
- EIP-712 (Typed Structured Data Hashing and Signing)
- ERC-2612 (Permit Extension for EIP-20 Signed Approvals)

**Tooling and frameworks:**
- Foundry — https://getfoundry.sh
- Hardhat — https://hardhat.org
- Slither — https://github.com/crytic/slither
- Aderyn — https://github.com/Cyfrin/aderyn
- Wake — https://github.com/Ackee-Blockchain/wake
- Mythril — https://github.com/ConsenSysDiligence/mythril
- Echidna — https://github.com/crytic/echidna
- Medusa — https://github.com/crytic/medusa
- Halmos (no release since v0.3.3, 2025-07-31) — https://github.com/a16z/halmos
- Certora — https://www.certora.com (prover source, GPL-3.0: https://github.com/Certora/CertoraProver)
- KEVM — https://github.com/runtimeverification/evm-semantics

**Incident catalogues for post-mortem study:**
- Rekt News — https://rekt.news
- DeFiLlama Hacks — https://defillama.com/hacks
- Chainalysis Crypto Crime Reports — https://www.chainalysis.com/reports/
- TRM Labs Resources (reports, research) — https://www.trmlabs.com/resources

**Audit firm methodology references:**
- Trail of Bits Blog — https://blog.trailofbits.com
- OpenZeppelin News — https://www.openzeppelin.com/news
- Consensys Diligence Blog — https://diligence.security/blog
- Spearbit — https://spearbit.com
- Cantina Research — https://cantina.security/research
- Zellic — https://www.zellic.io/blog
- Sigma Prime — https://sigmaprime.io/blog/

**Academic and primary sources:**
- Solidity Documentation — https://docs.soliditylang.org
- Vyper Documentation — https://docs.vyperlang.org
- Move Language (legacy book; upstream repo archived 2024-05, prefer the chain-specific docs below) — https://move-language.github.io/move/
- Aptos Move (smart contracts) — https://aptos.dev/build/smart-contracts
- Sui Move concepts — https://docs.sui.io/develop/write-move/sui-move-concepts
- Solana Anchor — https://www.anchor-lang.com/docs
- CosmWasm — https://cosmwasm.github.io
- Cairo / Starknet — https://docs.starknet.io
- evm.codes — https://www.evm.codes

---

**Version:** 1.0
**Last Updated:** 2026-11-04
**Review Frequency:** Quarterly (tooling, EIPs, defect-taxonomy entries, and audit-firm methodology drift on a months-to-quarters cadence; vulnerability-class fundamentals are slower)
