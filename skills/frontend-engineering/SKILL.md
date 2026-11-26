---
name: frontend-engineering
description: "Hugo's task-scoped practices for client-side behavior. Load for UI, client state, routing, data fetching, accessibility, or frontend performance changes."
---

# Frontend Engineering

## Activation
Load when the task changes client-side behavior, UI, routing, state, data fetching, accessibility, or frontend performance.

## Workflow
1. Inspect the relevant route, components, state ownership, data flow, and user interaction.
2. Preserve established patterns unless the task requires changing them.
3. Model relevant loading, empty, error, and success states.
4. Validate at boundaries and render untrusted content safely.
5. Check keyboard/focus, responsive, and theme behavior when affected.
6. Run project-defined formatter, lint, type, and test checks; report only checks actually executed.

## Review focus
- No duplicated or unnecessarily global state.
- Correct async cancellation/race behavior where relevant.
- Accessible interaction and clear failure states.
- No secrets in client-visible code or bundles.
- Performance claims require project measurements, not generic budgets.

## Handoff
Report changed behavior, relevant UI states exercised, checks run, and remaining issues. Do not invent performance targets or deliverable diagrams.

## Foundation AI integration
This skill supplements `execute-work`; it does not expand scope, replace independent review/security/QA gates, or authorize Git actions. Report material scope or user-impact changes to Daniel Olivaw.
