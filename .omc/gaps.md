## Gaps (no dedicated SOP yet)

Capabilities not covered by a dedicated SOP. Add a new SOP only on explicit user decision (no auto-promotion).

- **SaaS pentesting** — M365 / Workspace as a SaaS attack surface (offensive). Defensive side covered by `sop-saas-log-forensics`.
- **Container / k8s pentesting** — `(planned) sop-container-k8s-pentest` referenced as forward-link from `sop-cloud-pentest`, `sop-cloud-forensics`, `sop-email-bec-forensics`. Strong candidate for next buildout.
- **Mobile device forensics** — standalone (acquisition, decoding, app-data carving, trust-store analysis). Currently subsumed under `sop-forensics-investigation`.
- **Encrypted-messenger forensics** — Signal / Session / Matrix / WhatsApp.
- **Discord, YouTube, Mastodon, Facebook OSINT** — no platform SOPs yet.
- **LLM-assisted OSINT** — methodology + verification + bias-control.
- **Deepfake detection workflow** — image / video / audio synthetic-media verification.
- **Phishing-kit analysis** — kit-decomposition methodology covered defensively in `sop-email-bec-forensics` §12; deeper standalone SOP remains a gap.
- **ICS / OT** — industrial control / operational technology security.
- **Supply-chain compromise** — software supply-chain attack reconstruction.
- **BGP routing** — BGP hijacking / RPKI / route-leak investigation.
- **Threat-actor / TTP tracking** — MISP / OpenCTI workflows.
