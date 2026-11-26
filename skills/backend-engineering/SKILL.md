---
name: backend-engineering
description: "Hugo's task-scoped practices for implementing backend behavior. Load when the delegated task changes server-side domain logic, services, or handlers."
---

# Backend Engineering

## Activation
Load for changes to server-side behavior, domain rules, services, or backend handlers. Do not load for docs-only, infrastructure-only, or client-only tasks.

## Workflow
1. Trace the affected request/event path through handlers, domain logic, and data access.
2. Identify relevant invariants, authorization checks, state transitions, and failure behavior.
3. Follow the project's existing stack, boundaries, and conventions. Do not introduce architecture or dependencies without authorization.
4. Implement the smallest complete change within the approved scope.
5. Add or update tests for observable behavior and relevant failure paths.
6. Run the verification required by `execute-work`; report exact outcomes.

## Review focus
- Server-side authorization and ownership checks.
- Validation at trust boundaries.
- Transaction and retry behavior where relevant.
- Compatibility with existing consumers and stable error behavior.
- No secrets or sensitive data in logs.

## Handoff
Report changed paths, behavior, checks actually run, and unresolved risks. Do not create design documents unless required by the task.

## Foundation AI integration
This skill supplements Hugo Amaryl's `execute-work` workflow. It does not expand scope, authorize architecture decisions, replace independent review/security/QA gates, or authorize Git actions. Report material scope or risk changes to Daniel Olivaw.
