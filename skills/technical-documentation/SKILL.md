---
name: technical-documentation
description: "Hugo's task-scoped practices for accurate project documentation. Load when docs are in the approved task or implementation changes make relevant docs stale."
---

# Technical Documentation

## Activation
Load when documentation is an explicit deliverable or a code/configuration change makes relevant documentation stale. Do not create docs merely to satisfy a generic deliverable list.

## Workflow
1. Identify the reader, task, and authoritative source of truth.
2. Inspect current implementation and documentation structure.
3. Update only relevant documentation within approved scope and project conventions.
4. Make commands, examples, configuration, and compatibility claims match verified behavior.
5. Check links and examples when feasible; label unverified claims.

## Limits
- No templates, decision logs, or standalone docs unless useful and required.
- Do not claim tests, compatibility, or operational behavior that was not verified.
- Do not duplicate an existing source of truth.

## Handoff
List documentation paths changed and checks actually performed.

## Foundation AI integration
This skill supplements `execute-work`; it does not expand scope, replace independent review/QA gates, or authorize Git actions. Report missing or conflicting requirements to Daniel Olivaw.
