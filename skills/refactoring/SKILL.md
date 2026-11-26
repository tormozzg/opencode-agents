---
name: refactoring
description: "Hugo's task-scoped practices for behavior-preserving structural changes. Load for explicitly delegated refactoring or a necessary scoped refactor."
---

# Refactoring

## Activation
Use for a delegated refactoring task or when a localized structural change is necessary to implement the approved behavior safely. Do not use as permission for incidental cleanup outside scope.

## Workflow
1. Identify observable behavior that must remain unchanged.
2. Inspect existing tests; add characterization coverage when needed and in scope.
3. Make small, reviewable structural changes and verify after meaningful steps.
4. Keep behavior changes separate where practical. If behavior or scope must change, stop and report it.
5. Remove temporary scaffolding and inspect the final diff.

## Limits
- No broad cleanup or rewrite as an incidental improvement.
- No abstraction without a concrete use case.
- No generic PR-size or coverage target unless the project defines one.
- Do not change public interfaces or data formats without authorization.
- Follow `execute-work` for the mandatory verification and post-write review loop.

## Handoff
Describe preserved behavior, structural changes, verification, and separately identified behavior work.

## Foundation AI integration
This skill supplements `execute-work`; it does not override the approved scope, authorize behavior changes, replace independent review/security/QA gates, or authorize Git actions. Report material scope changes to Daniel Olivaw.
