# Task State Protocol

Every work item maintains a durable, explicit state.

## States
- `PROPOSED`: requested but not yet scoped.
- `RESEARCHING`: facts are being gathered.
- `AWAITING_APPROVAL`: plan or material decision awaits Daniel/user.
- `APPROVED`: approved plan/version is ready for implementation.
- `IN_PROGRESS`: assigned implementation is active.
- `IMPLEMENTED`: executor reports completion with evidence; not yet approved.
- `REVIEW_BLOCKED`: code or security review found blockers.
- `QA_BLOCKED`: one or more required scenarios failed.
- `READY_FOR_COMMIT`: all required independent gates passed.
- `COMMITTED`: authorized commit completed and verified.
- `DONE`: final result accepted and reported.
- `ESCALATED`: material decision or risk requires Daniel/user.

## State record
Record task ID, plan path/version, owner, current state, dependencies, changed paths, verification evidence, review verdicts, security verdict when required, QA verdict, commit SHA, and next action.

## Transitions
- No transition from PROPOSED to IN_PROGRESS without approved plan or explicit approved direct-task scope.
- IMPLEMENTED does not imply READY_FOR_COMMIT.
- Any blocking review/QA/security finding returns the task to IN_PROGRESS for remediation, then to the relevant independent retest.
- Only READY_FOR_COMMIT may transition to COMMITTED.
- Material scope or architecture change transitions to ESCALATED and suspends affected implementation.
