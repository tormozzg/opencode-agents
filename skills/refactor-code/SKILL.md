---
name: refactor-code
description: "Safe-refactor protocol for the worker: behavior-preserving definition, lock behavior with a passing test before touching structure, small steps with the system kept fully working after each one, tests after every step, immediate rollback on failure, no improvised refactoring, and preparatory refactoring (make the change easy, then make the easy change). Load before any structural change."
---

# Refactor Code

**You change structure, never behavior.**

Refactoring is changing the internal structure of code to make it easier to understand and cheaper to modify **without changing its observable behavior**. If observable behavior changes, it is a bug fix or a rewrite — do not call it refactoring and do not smuggle it into a refactoring pass.

## What this is not

- **Not feature work.** Adding behavior during a refactoring pass breaks the "same observable behavior" premise — no test can lock it.
- **Not performance work by accident.** Speed changes often come out of refactoring, but a pass whose *goal* is performance is a different task with different verification; do not run the two at once.
- **Not a rewrite.** A rewrite replaces the safety net's subject; a refactoring keeps it valid the whole way through.

## Lock behavior first

- **Before the first structural edit, behavior is locked by a passing test.**
  - The tests covering the area pass on the unchanged base; one failing before your change is a FINDING to fix at its owner first — never edit it green to unblock yourself.
  - This is the same lock the slop-cleanup protocol requires before any deletion.
- **No coverage = no refactoring.** If the area has no test that would catch a behavior change, write one first: a characterization test asserting what the code does today.
  - The self-testing-code suite is the safety net; refactoring without it is structural change on faith.
- **Pin observable behavior, not implementation details.** Tests that assert public inputs → outputs permit every safe move; tests that mirror internals block refactoring and must be rewritten before structure changes.

## The step loop

**One named operation at a time**: rename, extract, inline, move, change signature. A "step" that bundles several operations cannot be reverted to a good intermediate state.

| Step | Action | On failure |
|---|---|---|
| 1 | Apply ONE small behavior-preserving transformation. | — |
| 2 | Run the related tests immediately. | — |
| 3 | Green → proceed to the next step. | Red → **revert immediately**; never debug a broken refactoring forward. |
| 4 | The system is kept fully working after each step — this is the invariant, not a goal state. | — |

- **Revert, then shrink.** After a revert, retry with a smaller step. A step too big to land is information about the size, not about the tests.
- **Run the whole relevant suite, not just the touched test.** A shared helper moved can break a distant caller; the point of small steps is that a failure names the step that caused it.
- Commit checkpoints follow the pack's git flow (git-master); never let unverified structure accumulate.

## No improvised refactoring

- **Never improvise a structural change under time pressure.** This mirrors execute-work review Step 3: follow this protocol or don't restructure at all.
- "I'll clean it up as I go" mid-feature is exactly how behavior changes sneak in.
- **A refactor riding along with a feature change stays behavior-locked and separately testable.** If it grows beyond the named change, stop and split it out — scope creep into adjacent code is a review blocker, not a favor.
- **Escalate what cannot be stepped.** Structural rewrites that cannot be done in small verified steps (e.g. a cross-cutting type change) go to the lead as a planned task, not executed opportunistically.

## Preparatory refactoring

- **Make the change easy, then make the easy change.**
  - Before adding a feature to a tangled spot, do small behavior-preserving reshaping until the insertion point is obvious.
  - Then make the feature change with its own test.
- **Prepare only enough to make the *named* change easy.** Preparatory refactoring is a license to reshape the path you are about to modify, not to rewrite the module.
- **Signal to prepare**: the insertion point resists — you keep circling the seam, or the natural feature placement would touch half the file. That resistance is the smell; prepare until it is gone.
- The preparation pass obeys the full protocol: locked behavior, small steps, tests after each.

## Evidence

Save the verification trail for each pass — pre-lock test output, post-step test runs, and the final green run — under the shared evidence directory `.opencode/evidence/<plan-name>/` (or the task slug when no plan name is known), per execute-work's evidence discipline.
