# Quality Gates Protocol

Quality gates are independent, version-bound, and evidence-based.

## Planning gate
1. Giskard Reventlov researches through Elijah Baley as needed.
2. For complex work, Giskard applies architect-work and records architecture evidence.
3. Kelden Amadiro independently reviews the exact plan version and records its path/version (or content hash), verdict, findings, and evidence.
4. Giskard resolves blockers. Any plan content change invalidates the prior review and requires a fresh review of the new version.
5. Daniel Olivaw presents that exact reviewed version for user approval. Record the approved plan version and approval decision. No implementation begins before approval.
6. Any later change to scope, acceptance criteria, dependencies, or execution-affecting plan content returns to review and approval before affected work proceeds.

## Implementation gate
1. Susan Calvin decomposes the approved plan version and delegates bounded tasks.
2. Andrew Martin implements and verifies; he does not approve his own work.
3. Han Fastolfe independently reviews the complete proposed change set (read-only).
4. Jothan Leebig independently reviews security-sensitive work when risk triggers apply.
5. Golan Trevize executes the frozen QA scenario set (read-only).
6. Andrew fixes findings. Each reviewer independently retests their own findings; QA reruns the full frozen scenario set for the affected task scope after a fix.
7. Before commit, Susan confirms that the current diff still matches the exact reviewed state. Any post-review change invalidates affected approvals; rerun the relevant review, security, and QA gates against the new state.
8. Susan authorizes the commit workflow only after all required gates pass. Daniel/user approves material risk acceptance and the final result.

## Blocking rules
- Critical/High security findings block.
- Medium security findings require remediation or explicit Daniel/user risk acceptance with rationale and compensating controls.
- Code-review blockers and QA FAIL block.
- Every verdict identifies the exact plan version or diff/commit SHA it covers.
- No self-review, fabricated evidence, stale approval, or waived gate by convenience.
