# Task State Protocol

Every work item maintains a durable, explicit state. State records must identify the exact plan and implementation revision they describe.

## States
- `PROPOSED`: requested but not yet scoped.
- `RESEARCHING`: facts are being gathered.
- `AWAITING_APPROVAL`: plan or material decision awaits Daniel/user.
- `APPROVED`: a specific reviewed plan version is approved and ready for implementation.
- `IN_PROGRESS`: assigned implementation is active.
- `IMPLEMENTED`: executor reports completion with evidence; not yet approved.
- `REVIEW_BLOCKED`: code or security review found blockers.
- `QA_BLOCKED`: one or more required scenarios failed.
- `READY_FOR_COMMIT`: all required independent gates passed for the exact current diff.
- `COMMITTED`: authorized commit completed and verified.
- `DONE`: final result accepted and reported.
- `ESCALATED`: material decision or risk requires Daniel/user.

## State record
Record task ID, plan path and version (plus content hash when available), approval reference, owner, current state, dependencies, changed paths, implementation diff/commit SHA, verification evidence, code-review verdict and reviewed SHA, security verdict and stable finding IDs when required, QA verdict and frozen scenario-set identity, commit SHA, and next action.

## Transitions
- No transition from PROPOSED to IN_PROGRESS without an approved plan or explicit approved direct-task scope.
- IMPLEMENTED does not imply READY_FOR_COMMIT.
- Any blocking review/QA/security finding returns the task to IN_PROGRESS for remediation, then to independent retest.
- Any plan change affecting execution invalidates the affected approval and returns the task to AWAITING_APPROVAL.
- Any change to the reviewed diff invalidates approvals for the changed surface; READY_FOR_COMMIT must be recalculated against the exact current diff.
- Only READY_FOR_COMMIT may transition to COMMITTED.
- Material scope or architecture change transitions to ESCALATED and suspends affected implementation.
