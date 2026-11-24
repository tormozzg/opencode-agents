# Quality Gates Protocol

Quality gates are independent, version-bound, and evidence-based.

## Planning gate
1. Giskard Reventlov researches through Elijah Baley as needed.
2. For complex work, Giskard applies architect-work and records architecture evidence.
3. Kelden Amadiro independently reviews the exact plan version and records its path/version (or content hash), verdict, findings, and evidence.
4. Giskard resolves blockers. Any plan content change invalidates the prior review and requires a fresh review of the new version.
5. Daniel Olivaw presents that exact reviewed version for user approval. Record the approved plan version and approval decision. No implementation begins before approval.
6. Any later change to scope, acceptance criteria, dependencies, or execution-affecting plan content returns to review and approval before affected work proceeds.

## Implementation and commit gate
This sequence applies to every implementation scope, whether plan-based or a direct task.
1. Daniel coordinates implementation; Andrew Martin implements and verifies. Andrew does not approve his own work and does not commit implementation subtasks.
2. After implementation is complete, Daniel dispatches Han Fastolfe to independently review the complete candidate (read-only) and waits for the verdict.
3. Daniel dispatches Jothan Leebig for independent security review when risk triggers apply and waits for the verdict. Critical/High block; Medium requires remediation or explicit risk acceptance by Hari/user.
4. After Han approval and the applicable security gate, Daniel dispatches Golan Trevize to execute the frozen QA scenario set (read-only) and waits for ALL PASS. Direct tasks must include an explicit runnable scenario list.
5. Andrew fixes findings. Daniel sends the new candidate through fresh Han review, applicable Jothan review, and a full rerun of the frozen QA scenarios as required. No gate may be skipped or self-certified.
6. Daniel dispatches Andrew a separate final Git task to exact-candidate-check and commit the single cohesive Daniel-coordinated scope only after all applicable gates pass. Andrew verifies the staged candidate matches the reviewed/tested candidate, commits, and returns the commit hash and status. No separate Daniel/Hari/user commit authorization is required. Do not commit each subtask by default.
7. Push to any remote requires explicit user authorization. Merge, rebase, history rewrite, and cleanup operations retain their separate authorization requirements.

## Blocking rules
- Critical/High security findings block.
- Medium security findings require remediation or explicit Hari/user risk acceptance with rationale and compensating controls.
- Code-review blockers and QA FAIL block.
- Every verdict identifies the exact plan version or diff/commit SHA it covers.
- No self-review, fabricated evidence, stale approval, or waived gate by convenience.
- Daniel must not report implementation complete until the final Andrew commit task succeeds and the commit is verified. If a required dispatch or commit is blocked, report the blocker rather than silently skipping it.
