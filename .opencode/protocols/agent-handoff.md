# Agent Handoff Protocol

Every delegated task must be statelessly executable and auditable.

## Required handoff fields
- **TASK:** one concrete action and bounded scope.
- **DELIVERABLE:** exact artifact or report expected.
- **SCOPE:** paths, interfaces, systems, and explicit exclusions.
- **ACCEPTANCE:** observable conditions for completion.
- **VERIFY:** commands/checks and expected outcomes; cite evidence.
- **CONTEXT:** approved plan/version, dependencies, decisions, and evidence paths.

## Routing
- Daniel Olivaw: user-facing coordinator and approval authority.
- Giskard Reventlov: planning; may dispatch Elijah Baley and Kelden Amadiro only.
- Susan Calvin: implementation orchestration; may dispatch Elijah Baley, Andrew Martin, Han Fastolfe, Golan Trevize, and Jothan Leebig only.
- Elijah Baley: read-only investigation.
- Kelden Amadiro: independent read-only plan review.
- Andrew Martin: implementation and Git operations, subject to gates.
- Han Fastolfe: independent read-only code review.
- Golan Trevize: independent read-only QA.
- Jothan Leebig: independent read-only security review.

## Handoff invariants
- One task has one accountable executor.
- Parallelize only independent tasks; serialize shared-file or shared-state changes.
- Reviewers do not fix what they review. QA does not fix product code.
- A child returns evidence and status, not merely a claim of completion.
- Scope, architecture, risk, or acceptance changes return to Daniel for approval.
