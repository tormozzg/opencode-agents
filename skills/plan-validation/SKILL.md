---
name: plan-validation
description: "Mechanical preflight for Giskard Reventlov's completed plan candidate before Kelden Amadiro's independent audit. Checks plan structure, internal consistency, executability signals, and verification coverage; does not replace review or approve plans."
---

# plan-validation

Run this skill on the exact persisted final plan candidate after Dors Venabili's advice has been incorporated or dispositioned, and immediately before submitting it to Kelden Amadiro. Re-run after every subsequent plan edit. This is a planner's preflight, not an independent review or approval gate.

## Inputs and boundary

- Read exactly the final plan path and version supplied by Giskard.
- Confirm the file's self-identifying header names that path, a version, and `reviewed: no`.
- Inspect the plan itself and its explicitly cited references only. Do not launch discovery, edit the plan, dispatch agents, or execute implementation/QA commands.
- Report observable checks and concrete findings. Do not issue `[OKAY]`, `[REJECT]`, or any approval verdict; Kelden owns the independent audit.

## Preflight checklist

Check the candidate for:

1. **Scope and decision closure:** the plan states the intended outcome and affected users, closes known gaps, records resolved defaults, and leaves no execution-critical owner decision unresolved.
2. **Task structure:** executable work appears as column-zero task rows in the required sections; each implementation row has a valid executor, dependency declaration, runnable verification command, acceptance criteria, and required QA scenarios.
3. **Dependencies and conflicts:** dependency references point to existing rows, ordering is coherent, and tasks that write the same file or shared name list are not scheduled as independent parallel work.
4. **Verification coverage:** each task has concrete success and failure scenarios with observable outcomes and the required evidence directory; commands state working directory/setup where needed and expected results are grounded rather than guessed.
5. **Scope boundaries:** plan-level and per-task exclusions are explicit where required; documentation impacts, user-visible status, and warning-baseline requirements are not omitted where applicable.
6. **Version and handoff integrity:** the candidate is marked `reviewed: no`; references to architecture/evidence artifacts are specific; no statement implies that this preflight authorizes execution.

Treat the checklist as a way to find omissions and contradictions in the written plan, not as a reason to inflate the plan with unnecessary detail. A criterion that genuinely does not apply should be reported as not applicable with a brief reason.

## Output

Return a concise report with:

- **Candidate:** exact path and version.
- **Checks:** pass / not applicable / finding for each checklist item.
- **Findings:** specific, actionable issues, prioritized by whether they could stop or misdirect execution.
- **Next step:** fix the listed findings and re-run this preflight, or submit the unchanged candidate to Kelden.

Do not edit the plan. Giskard owns revisions; Kelden independently determines whether the plan passes review.
