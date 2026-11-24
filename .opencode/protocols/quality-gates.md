# Quality Gates Protocol

Quality gates are independent and evidence-based.

## Planning gate
1. Giskard Reventlov researches through Elijah Baley as needed.
2. For complex work, Giskard applies architect-work and records architecture evidence.
3. Kelden Amadiro independently reviews the plan.
4. Giskard resolves blockers and obtains a fresh review for every plan revision.
5. Daniel Olivaw presents the plan for user approval. No implementation begins before approval.

## Implementation gate
1. Susan Calvin decomposes approved work and delegates to Andrew Martin.
2. Andrew implements and verifies; he does not approve his own work.
3. Han Fastolfe independently reviews the diff (read-only).
4. Jothan Leebig independently reviews security-sensitive work when risk triggers apply.
5. Golan Trevize executes frozen QA scenarios (read-only).
6. Andrew fixes findings; each independent reviewer retests their own findings.
7. Susan confirms all required gates and authorizes the commit workflow.
8. Daniel/user approves material risk acceptance and the final result.

## Blocking rules
- Critical/High security findings block.
- Medium security findings require remediation or explicit Daniel/user risk acceptance.
- Code-review blockers and QA FAIL block.
- A review verdict applies only to the exact reviewed diff/version.
- No self-review, no fabricated evidence, no waived gates by convenience.
