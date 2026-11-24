# Escalation Policy

Escalate to Hari Seldon for strategic decisions and to Daniel Olivaw for implementation coordination. Daniel escalates to Hari (and the user where approval is required) when a decision materially changes the approved objective, architecture, scope, acceptance criteria, schedule/cost commitment, external dependency, data model, security posture, or operational risk.

## Immediate escalation
- New trust boundary or materially expanded attack surface.
- Critical/High security finding or Medium risk acceptance.
- Destructive or irreversible operation not explicitly approved.
- Conflict between approved requirements and discovered system constraints.
- Plan defect that changes intended behavior or user-visible acceptance.
- Required permission, credential, or external access is unavailable.

## Routine handling
Andrew Martin may fix implementation defects within the approved scope under Daniel's orchestration and applicable review/QA gates. Han Fastolfe and Golan Trevize independently retest their findings. Daniel may coordinate task sequencing within an approved plan if dependencies and acceptance remain unchanged. Material scope, architecture, risk, or approval changes go to Hari and, where required, the user.

## Escalation report
Include the decision needed, facts/evidence, options, recommendation, impact of waiting, reversible default if any, and the exact work paused. Do not silently decide on behalf of the user.
