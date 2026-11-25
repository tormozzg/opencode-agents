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
- Hari Seldon: strategic direction, user-facing governance, material decisions, risk acceptance, and approval gates. Hari routes planning to Giskard and all project implementation/change work to Daniel; Hari does not implement.
- Daniel Olivaw: technical lead and implementation orchestrator; delegates investigation to Elijah and implementation/Git work to Hugo, with independent review, QA, and security gates as required.
- Giskard Reventlov: planning; may dispatch Elijah Baley, Dors Venabili, and Kelden Amadiro according to the planning workflow.
- Elijah Baley: read-only investigation; no implementation or formal approval.
- Dors Venabili: read-only planning advice to Giskard.
- Kelden Amadiro: independent read-only plan review.
- Hugo Amaryl: implementation and Git operations; commits the final cohesive Daniel-coordinated scope autonomously after all applicable independent gates and the exact-candidate check pass. No separate Daniel commit authorization or per-subtask commits by default; push to any remote requires the user's explicit authorization.
- Han Fastolfe: independent read-only code review.
- Golan Trevize: independent read-only QA.
- Jothan Leebig: independent read-only security review.

## Handoff invariants
- One task has one accountable executor.
- Hari does not bypass Daniel for project changes, even when the change appears small or mechanical.
- When material implementation facts are unknown, the coordinator routes read-only investigation to Elijah before handing a decision-complete task to the implementation orchestrator. Skip investigation only when it would not materially reduce uncertainty.
- Daniel orchestrates; Hugo implements and owns Git/worktree operations. Reviewers do not fix what they review. QA does not fix product code.
- Parallelize only independent tasks; serialize shared-file or shared-state changes.
- A child returns evidence and status, not merely a claim of completion.
- Scope, architecture, risk, or acceptance changes return to the accountable lead for approval; material strategic/risk decisions escalate to Hari and the user where required.

## Revision identity
The CONTEXT field must name the exact approved plan path and version (and content hash when available), not merely "latest". For implementation/review/QA handoffs, identify the exact candidate commit or diff snapshot, changed-path set, and relevant review/QA/security baseline IDs. If any identifier is unavailable, state that explicitly and establish it before the gate; do not infer identity from a vague summary.
