---
name: slop-cleanup
description: "Categorized cleanup discipline for AI-generated slop — inherited from the codebase or produced during the current task: a category checklist (broad excepts, dead helpers, junk and tautological tests, weak-value tests, copy-paste duplicates, needless pass-through abstractions, oversized modules, placeholder stubs) plus the safe protocol — lock behavior with tests first, write the cleanup plan before editing, one category per pass, delete rather than comment out, re-verify after each pass, and back out risky cleanup. Load before touching inherited AI-generated patterns or cleaning up patterns that slipped into freshly written code."
---

# Slop Cleanup

**You remove what should never have been generated — by category, with behavior locked.**

Inherited AI-generated code carries predictable defect patterns: duplication grows while moved code shrinks in AI-assisted codebases — expect copy-paste as the top category. This skill tells the worker how to clean them without changing behavior.

It composes with execute-work (whose review Step 3 escalates here) and refactor-code (whose lock-and-step protocol this extends to deletions).

## The categories

Hunt one pattern at a time. Signature → first move:

| Category | Signature | First move |
|---|---|---|
| **Broad excepts** | `except Exception`, bare `except:`, `catch (Exception)` that names no recovery | Replace with the specific types you can recover from — or delete the handler and let it propagate. |
| **Dead helpers** | Unused functions, imports, config, commented-out code, vague TODOs | Delete. No callers after grep = no callers. |
| **Junk tests** | Cannot fail: tautological assertions ("can never fail"), mock echoes, implementation mirrors, source greps, change certificates pinning the diff | Delete, or rewrite to assert observable behavior with a credible regression. |
| **Weak-value tests** | Pass on a default/bogus input even with broken code — e.g. a test on an identity/default value that also matches the bug | Assert a value only correct output would produce; make the input non-trivial. |
| **Copy-paste duplicates** | The same block repeated with small edits | Keep one implementation, reuse it — for the second real caller, not a hypothetical one. |
| **Needless pass-through abstractions** | Wrapper delegating 1:1 with no second caller and no added meaning | Inline it. |
| **Oversized modules** | Pure LOC in execute-work's DEFECT band (> 250, Step 1 measurement); the 200-250 warning band is reported, not acted on | Split by responsibility — each part still single-responsibility-named. |
| **Placeholder stubs** | Empty handlers, `not implemented` paths shipped as complete | Implement for real or remove + report as unfinished — never leave as "done". |

- **Junk test is the most dangerous category.** A green suite with junk tests is *less* safety net than no suite: it manufactures false confidence while protecting nothing. Delete-then-rewrite beats patching.
- **Tautological assertion**, spelled out: if the assertion would also hold for the broken code, it "can never fail" — it is a checklist item, not a test.
- **Weak-value test, spelled out**: the test passes both because the code is right and because it is broken — the input is so default (empty string, zero, identity value) that any implementation produces the asserted value. Non-trivial input is the fix.

## First, confirm it is actually slop

- **Check the dispatch intent and out-of-scope decisions before deleting anything.** What looks like a needless abstraction may be a seam the lead planned to fill; what looks dead may have a caller you have not grepped. Verify callers with search, not assumption.
- **Odd-but-working code with named callers is not in scope** — slop means generated-and-unjustified, not merely unfamiliar. If in doubt, list it in the report instead of removing it.
- The review-code AI Slop Checklist flags these same patterns in a diff under review; this skill is the *cleanup* counterpart for the patterns it flags — review flags, cleanup fixes — wherever they came from: inherited AI-generated code already in the codebase, or AI-generated patterns produced during the current task. A worker's own fresh code normally should not need the full discipline (it was written under this pack's gates); the widened scope exists so patterns that slipped into its diff can be cleaned by the same protocol. Use the same names so findings map one to one.

## The protocol

1. **Lock behavior first.** Passing tests cover the area before any deletion — the refactor-code lock rule, unchanged. A cleanup with no lock is not a cleanup, it is a gamble.
2. **Write the cleanup plan before the first edit.** List the categories found, per file, with the intended move for each. The plan is what gets reviewed; improvisation is how behavior changes sneak into "just deleting dead code".
3. **One category per pass.**
   - A single pass that mixes dead-code deletion, test rewrites, and module splits cannot be verified as behavior-preserving.
   - Small steps, tests after each, revert on red — the refactor-code step loop.
4. **Delete, never comment out.** Commented-out code is the same dead weight plus noise, and version control already remembers. The same applies to `#[allow(dead_code)]`-style suppressions that hide the dead helper instead of removing it.
5. **Re-verify after every pass.** Run the related tests (and build) after each pass; quote the pre/post test trail in the final report — no evidence files (those belong to Elijah Baley and `golan-trevize`).
6. **Back out risky cleanup.**
   - A pass whose equivalence you cannot verify, or whose tests changed outcomes, is reverted — not pushed forward with a shrug.
   - Report what you backed out and why; the lead decides if it becomes a planned task.

## When deletion is the answer

Prefer deletion over repair. A helper with no caller, a test that cannot fail, an abstraction with one delegating caller — repairing them preserves the slop with better manners. The judgment is against the callers that exist today, not the ones someone imagines.

## Report

End with: categories found per file, moves applied, passes reverted, and the pre/post test trail quoted inline — every claim about what was deleted is backed by the quoted test runs; write no evidence files (those belong to Elijah Baley and `golan-trevize`).


## Foundation AI integration

This companion skill is used by Andrew Martin during implementation when its subject applies. Susan Calvin may require it as part of a delegated task. It does not grant authority to change scope, bypass independent review, or commit changes. Preserve the approved task boundary and report material findings to Susan.
