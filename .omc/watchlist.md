## Watchlist (field-evolution rot speed)

Recommended review cadence per tier. SOPs in **Fast** rotate fastest (platform APIs, attacker TTPs, enforcement landscape); **Slow** are fundamentals (legal, OPSEC, evidence discipline) that change on the order of years.

### Fast — quarterly review

- All `Investigations/Platforms/*` (7 SOPs: bluesky, instagram, linkedin, reddit, telegram, tiktok, twitter-x) — platform APIs, scraping surfaces, ToS, and attacker TTPs rotate frequently
- `sop-ad-pentest`
- `sop-cloud-pentest`
- `sop-container-k8s-pentest` — k8s minor-version cycle, admission-controller projects (Gatekeeper / Kyverno / kubewarden), runtime CVEs (runc / containerd / CRI-O), Pod Security Standards drift, and managed-k8s feature drift across EKS / AKS / GKE rotate quarterly; cluster-RBAC and IAM-bridge fundamentals are slower
- `sop-darkweb-investigation` — marketplace / leak-site / forum landscape rotates monthly (quarterly review); Tor / I2P / PGP fundamentals are slower
- `sop-detection-evasion-testing`
- `sop-mixer-tracing` — mixer enforcement timeline, prosecution outcomes (Pertsev appeal, Storm trial, Samourai prosecution) and vendor heuristic implementations rotate quarterly; CoinJoin / Tornado heuristic methodology is slower
- `sop-mobile-security`
- `sop-firmware-reverse-engineering`
- `sop-wireless-rf-pentest` — Wi-Fi / Bluetooth / Matter portions rotate quarterly; SDR / NFC fundamentals are slower
- `sop-ai-vulnerability-evasion` — quarterly review

### Medium — semi-annual review

- `sop-vulnerability-research`
- `sop-bug-bounty`
- `sop-linux-pentest`
- `sop-financial-aml-osint`
- `sop-web-dns-whois-osint`
- `sop-image-video-osint`
- `sop-forensics-investigation`
- `sop-cryptography-analysis`
- `sop-malware-analysis`
- `sop-web-application-security`
- `sop-blockchain-investigation` — vendor product lineup, sanctions trajectory, bridge-protocol churn rotate quarterly; clustering-heuristic methodology and Daubert posture are slower
- `sop-smart-contract-audit` — audit tooling (Slither / Aderyn / Wake / Echidna / Halmos), EIP / opcode / L2 support drift on a quarterly cadence; vulnerability-class fundamentals are slower
- `sop-cloud-forensics` — CSP control-plane API field renames, retention defaults, managed-Kubernetes audit-log structure, cloud-native threat-detection product feature drift on a quarterly cadence; classical DFIR fundamentals and evidence-discipline are slower
- `sop-saas-log-forensics` — M365 / Workspace / Okta / Slack / Salesforce / GitHub API field renames, retention defaults, license-tier feature drift, OAuth-consent abuse TTPs evolve on a quarterly cadence; classical eDiscovery / chain-of-custody fundamentals are slower
- `sop-email-bec-forensics` — BEC TTPs, AiTM kit landscape, lookalike-domain registrar patterns, M365 / Workspace / SEG message-trace API field renames, IC3 / FFKC threshold guidance evolve on a quarterly cadence; RFC-level SPF / DKIM / DMARC / ARC fundamentals and chain-of-custody discipline are slower

### Slow — annual review

- `sop-legal-ethics`
- `sop-opsec-plan`
- `sop-sensitive-crime-intake-escalation`
- `sop-collection-log`
- `sop-entity-dossier`
- `sop-hash-generation-methods`
- `sop-reverse-engineering`
