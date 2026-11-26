---
name: technical-writing
description: "Hugo's task-scoped standard for writing or editing technical prose such as READMEs, RFCs, ADRs, runbooks, API docs, and postmortems."
---

# Technical Writing

## Activation
Load when Hugo is asked to author or edit technical prose. For documentation maintenance without substantive prose drafting, use `technical-documentation` instead.

## Workflow
1. Identify the reader and the task the text should help them complete.
2. State purpose and required action near the beginning.
3. Prefer concrete terms, concise paragraphs, and examples that match the system.
4. Preserve technical meaning; do not invent facts to make prose sound complete.
5. Remove repetition and unsupported certainty.
6. Check terminology and claims against implementation or supplied sources.

## Limits
- Improve wording without changing technical requirements or making architecture decisions.
- Add sections, owner/date fields, or templates only when required by document type or project convention.
- Do not duplicate documentation that already has a source of truth.

## Handoff
Summarize the text changed and any factual gaps that remain unresolved.

## Foundation AI integration
This skill supplements `execute-work`; it does not expand scope, replace independent review/QA gates, or authorize Git actions. Report unresolved factual or requirement gaps to Daniel Olivaw.
