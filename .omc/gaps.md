## Gaps (no dedicated SOP yet)

Capabilities not covered by a dedicated SOP. Add a new SOP only on explicit user decision (no auto-promotion).

- **SaaS pentesting** — M365 / Workspace as a SaaS attack surface (offensive). Defensive side covered by `sop-saas-log-forensics`.
- **Mobile device forensics** — standalone (acquisition, decoding, app-data carving, trust-store analysis). Currently subsumed under `sop-forensics-investigation`.
- **Encrypted-messenger forensics** — Signal / Session / Matrix / WhatsApp.
- **YouTube, Mastodon, Facebook OSINT** — no platform SOPs yet (Discord landed 2026-04-27).
- **LLM-assisted OSINT** — methodology + verification + bias-control.
- **Deepfake detection workflow** — image / video / audio synthetic-media verification.
- **Phishing-kit analysis** — kit-decomposition methodology covered defensively in `sop-email-bec-forensics` §12; deeper standalone SOP remains a gap.
- **ICS / OT** — industrial control / operational technology security.
- **Supply-chain compromise** — software supply-chain attack reconstruction.
- **BGP routing** — BGP hijacking / RPKI / route-leak investigation.
- **Threat-actor / TTP tracking** — MISP / OpenCTI workflows.
