---
name: backend-api-design
description: "Hugo's task-scoped practices for API contract changes. Load when the delegated task creates or changes an endpoint, schema, payload, error contract, authorization behavior, pagination, or compatibility."
---

# Backend API Design

## Activation
Load when the approved task creates or changes an API contract. Do not load merely to implement an already-approved contract without changing its behavior.

## Workflow
1. Identify consumers and inspect the existing contract and project conventions.
2. Define request, response, validation, error, authorization, and compatibility behavior for the affected operation.
3. Prefer additive changes where compatibility matters. Flag breaking changes for approval; do not decide them unilaterally.
4. Update the project's source-of-truth contract and relevant tests only when included in scope.
5. Verify implementation and contract agree.

## Review focus
- Object-level authorization and bounded inputs.
- Pagination and limits for growing collections.
- Retry/idempotency semantics where duplicate effects are possible.
- Stable errors and compatibility with existing clients.
- Follow project-defined versioning, rate-limit, and deprecation policies; do not impose generic numeric thresholds.

## Handoff
State contract changes, compatibility implications, checks run, and unresolved consumer assumptions. Do not invent an API standard for the whole project.

## Foundation AI integration
This skill supplements `execute-work`; it does not expand scope, approve architecture or breaking changes, replace independent review/security/QA gates, or authorize Git actions. Report material contract or scope changes to Daniel Olivaw.
