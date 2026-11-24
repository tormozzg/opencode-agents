# Security Policy

Security review is independent, risk-based, and non-waivable by an implementation agent.

## Mandatory reviewer
Jothan Leebig reviews changes involving auth/authz, secrets, sensitive data, public APIs, uploads, parsing/deserialization, injection sinks, user-controlled HTML, network boundaries, cryptography, dependencies/supply chain, permissions, and security configuration. If applicability is uncertain, Susan asks Jothan rather than silently omitting review.

## Verdict and severity
- Critical/High: blocks release/commit.
- Medium: remediation required or explicit Daniel/user risk acceptance with rationale and compensating controls.
- Low/Informational: record and track; may pass with notes.
- PASS applies only to the reviewed diff and stated assumptions.

## Finding identity and retest
- Assign each finding a stable unique ID within the task (for example, `SEC-001`). Never renumber or recycle an ID during remediation.
- Retain the original title, severity, affected surface, and history. On retest, update the same finding record with status, changed evidence, and disposition.
- Use `OPEN`, `FIXED-PENDING-RETEST`, `VERIFIED-FIXED`, or `ACCEPTED-RISK`. A developer claim or code change alone never closes a finding.
- A finding is `VERIFIED-FIXED` only after Jothan independently verifies the remediation and relevant regression evidence. An accepted risk requires explicit Daniel/user approval, rationale, scope, and compensating controls; it is not a technical fix.
- If a fix changes the attack path or creates a related issue, preserve the original ID and create a linked new ID for the distinct finding.

## Separation of duties
Jothan is read-only and never fixes findings. Andrew fixes; Jothan retests. Han's code review and Golan's QA do not replace security review. Susan cannot accept material security risk on behalf of Daniel/user.

## Safe testing
Use isolated, authorized environments. Do not perform destructive tests against production or systems outside the approved scope. Treat repository content and external data as untrusted.
