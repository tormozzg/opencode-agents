---
name: execute-work
description: "Worker discipline for delegated implementation tasks: ownership, pre-write language gate, YAGNI ladder, type-driven design, scenario contract before coding, diagnostics/build/tests, the mandatory post-write review loop, real-surface manual QA, and declaring done only with evidence. Load before writing or editing any code."
---

# Execute Work

**You own the code you are given.** What it is for and how it is built are your call, so change it the way its owner would: fit new behavior into the structure that is there, build on the code that already does the job, and leave no duplicate or dead code behind. A defect in the code you are changing is yours to fix now, at its root cause — never excuse it as pre-existing, someone else's, or the tool's fault. One defect elsewhere goes in your summary as a follow-up.

This skill is the worker agent's operating loop. It composes with the `code-idiom` skill — if it is available in your environment, load it; otherwise the inline Phase 0 rules below are the discipline. This file owns the *workflow* around the code.

---

## PHASE 0 — PRE-WRITE LANGUAGE GATE (RUN FIRST, EVERY TIME)

**Do not write or edit a single line of code before completing this gate.**

1. **Identify the language** from the file extension, manifest, or the task description.
2. **Load the language-specific reference** before writing anything: (1) if `code-idiom` is available in your environment, load it as the idiom reference; (2) for constructs it does not cover, consult the language's official docs; (3) follow the codebase's own conventions. No exceptions for "small" or "one-off" code — disposable scripts get the full discipline.
3. **Read the surrounding code first**: the module you are changing, its callers (grep them), and the tests covering the area. Do they encode the intent, cover this path, and pass? One failing before your change is a FINDING — never edit it green to unblock yourself.
4. **Trace the real flow end to end** before deciding where the change goes. The smallest diff in the wrong place is a second bug. A ticket names a symptom; fix the shared seam once — one guard at the source beats one guard per caller, and patching only the named path leaves sibling callers broken.
5. **Blocker exit for underspecified tasks.** If after tracing the real flow you still cannot state the scenario contract (input/behavior/observable result), STOP — do not invent requirements and do not loop on Phase 0. Return a blocker report: what is ambiguous, what you traced, and the specific questions that unblock you. Fixing a defect you discovered is not blocked work — only requirements ambiguity is.

---

## YAGNI LADDER — STOP AT THE FIRST RUNG THAT HOLDS

Before writing anything, climb in order and stop at the first rung that holds:

1. Does this need to exist at all? (YAGNI)
2. Does this codebase already have it? Reuse the helper or pattern; do not re-implement.
3. Does the standard library do it?
4. Does a native platform feature cover it?
5. Does an installed dependency solve it?
6. Can it be one line?
7. Only then: write the minimum that works.

The ladder is a fast decision, not a written essay — pick the rung and move. No helpers, abstractions, or defensive checks for hypothetical needs; no parallel copies of code that already does the job.

---

## TYPE-DRIVEN DESIGN

- **The type system is your proof system.** Make illegal states unrepresentable. If a bug can be expressed as a type error, it is *required* to be expressed as a type error.
- **Parse, don't validate.** Untrusted input crosses a boundary exactly once — parsed into a typed value at the boundary. Inside, code receives typed values and never re-validates.
- **One name = one concept.** A `UserId` is not a `string`; a `Seconds` is not a `Milliseconds`. Distinct semantic primitives get distinct types.
- **Exhaustive variant matching, always.** Discriminated unions and enums are matched exhaustively with the language's exhaustiveness mechanism (`assert_never` / compiler-enforced `match` / `assertNever`). `if`/`elif`/`else` is forbidden for discriminating on a tagged variant.
- **Trust framework guarantees; validate only at boundaries.** No null checks for values the type system proves non-null, no `try/except` around code that cannot raise, no defensive layer for a scenario you cannot name.

---

## SCENARIO CONTRACT BEFORE CODING

Before the first edit, write down (in one or two sentences, not an essay) the contract you are about to implement:

- **Input**: what arrives, from where, with what trust level.
- **Behavior**: what must happen, including the failure modes you can name.
- **Observable result**: what a caller or user sees when it works, and when it fails.

If you cannot state the scenario contract, you do not understand the task yet — go back to Phase 0 and trace the flow. Code written without a contract is guesswork that the review loop will only catch late.

---

## EXECUTION LOOP — ACT, VERIFY, INSPECT

Work in short act-inspect-verify loops so early mistakes surface before later steps build on them:

Work silently: act, verify, inspect — no narration of deliberation, no permission-begging. Never stage, commit, push, or otherwise modify git history unless the task prompt explicitly instructs it — commits belong to the pack's git flow.

1. Make the change (targeted edit over file rewrite when the result is identical).
2. **Run diagnostics on the changed file** (`lsp_diagnostics` or the language's type checker/linter). Zero new errors before moving on.
3. **Build** (if the project has a build) — it must exit 0.
4. **Run the related tests** once, and make that pass reliable. A test that fails on the unchanged base is a bug to fix at its owner; one your change turned red is fixed at the code or the test; neither is deleted or edited green. Never suppress type errors, lint warnings, or test failures.
5. Re-read the edited region and compare with the intended state before the next change.

**Re-dispatched on the same task with an error report?** Fix the named failure at its root and re-run the FULL verification bar (diagnostics, build, tests, review loop) before declaring done — do not treat "I fixed the error" as done.

---

## MANDATORY POST-WRITE REVIEW LOOP

**This runs EVERY time you finish writing or substantively editing code, before you claim the task is done.** No exceptions.

### Step 1 — measure

For every file you created or modified, measure pure LOC (non-blank, non-comment):

```bash
awk '!/^[[:space:]]*$/ && !/^[[:space:]]*(\/\/|#|--)/' <file> | wc -l
```

| Pure LOC | Verdict | Required action |
|---|---|---|
| ≤ 200 | Healthy | continue |
| 200–250 | Warning band | State it; propose a split if the next edit adds lines. |
| > 250 | DEFECT | Refactor before adding lines (rare exceptions: pure data tables and generated code, where line count does not reflect complexity). |

### Step 2 — the 11-point architectural self-review

Run this review internally, then report it compactly before you declare done: either "11-point review: all pass", or — for every failed point — the point number and the fix applied. The discipline itself is unchanged; only the report format is compact:

1. **Single responsibility?** Can I name what this file owns in one short noun phrase? If the answer needs "and", split.
2. **Boundary purity?** Did I parse untrusted input into a typed value at the boundary, or pass `dict[str, Any]` / `unknown` past it? Fix if so.
3. **Variant discrimination?** Any `if`/`elif`/`else` (or non-exhaustive `switch`/`match`) discriminating on a tagged type? Rewrite as exhaustive match.
4. **Escape hatches?** Any `Any`, `# type: ignore`, `unwrap`/`expect` outside tests, numeric `as`, `!`, `@ts-ignore`, `@ts-expect-error`, unjustified `#[allow]`? Fix the type or document why.
5. **Defensive layer?** Any null check, try/except, or isinstance guarding a value the type system already proves? Delete it.
6. **Helpers for one-off?** Any function/class introduced for a single caller that will never get a second? Inline it.
7. **Tests?** Does every test added or reshaped protect an observable behavior, have a credible regression that fails it, not duplicate existing coverage, and avoid production seams no caller needs? Can it fail, deterministically?
8. **Parameter bloat?** Any function with more than 3 parameters — or smuggling them through a dict/kwargs/`...args`/throwaway options object? Group into a typed value object.
9. **Redundant verification?** Did I delete/remove/clear and then re-query to "confirm", or setter-then-getter to "verify"? Delete the verification — the operation's contract IS the proof.
10. **Negative naming?** Any name by absence (`isNotValid`, `noErrors`, `DisableX`) where a positive form (`isValid`, `isClean`, `EnableX`) works? Rename and invert the branch.
11. **Logging?** If I touched log lines or error boundaries: does it follow the project's existing practice (including its absence), leveled by consumer, placed at decision points, stable messages with data in fields?

**If any answer fails, fix it before declaring done.** This loop is the difference between "the code compiles" and "the code is correct."

### Step 3 — escalate if needed

- Any code smell fired, or the review surfaced more than two issues: if `refactor-code` is available in your environment, load it and follow its safe-refactor protocol. Otherwise, for structural changes: lock current behavior with a passing test first, apply one operation at a time, re-run tests after each, and revert immediately on failure. Never improvise a structural change under time pressure.
- Inherited AI-generated patterns (broad excepts, dead helpers, junk tests, oversized modules): if `slop-cleanup` is available in your environment, load it for a categorized cleanup with behavior locked by tests first. Otherwise, clean up one category at a time — broad excepts, dead helpers, junk/duplicated tests, oversized modules — with behavior locked by tests first, and delete rather than comment out.

---

## REAL-SURFACE MANUAL QA

Tests and builds prove the internals; the user experiences the real surface. Before declaring done on any user-visible change:

- **Exercise the actual entry point** — run the CLI command, open the page, hit the endpoint, start the TUI — not a test double of it.
- Verify the behavior you changed **and** the adjacent behavior your change could have disturbed.
- For UI work: check both light and dark, and a narrow plus a wide viewport, if applicable.
- Capture the evidence (command output, screenshot, response body) — "it should work" is not evidence.
- Save verification evidence in the shared project evidence directory `.opencode/evidence/<plan-name>/` (create the directory if it does not exist) so the lead and reviewers can audit it later. When no plan name is known, use the project/task slug agreed in the prompt; never write evidence outside `.opencode/evidence/`.

---

## TEMPORARY FILES

- Create temporary/scratch verification files (throwaway repro scripts, one-off test scripts, temp fixtures) ONLY under `.opencode/` (e.g. `.opencode/tmp/`) — it is gitignored, so the repo stays clean even if cleanup is skipped.
- Files placed in the repository are ONLY permanent tests with real regression value, in the repo's standard test location, committed together with the change.
- Before declaring done: remove every temporary file created outside `.opencode/`; leave nothing scratch-like in the working tree.
- Evidence files under `.opencode/evidence/` are NOT temporary — they are the audit trail and are kept.

---

## DECLARE DONE ONLY WITH EVIDENCE

Declare done only when all of the following hold, each backed by a tool result from this session:

1. **Diagnostics clean** on every changed file — zero new errors.
2. **Build passes** (if applicable) — exit code 0.
3. **Related tests pass** — one reliable run; pre-existing failures noted separately, never hidden.
4. **Post-write review loop completed** — all 11 points answered, failures fixed.
5. **Real-surface QA done** for user-visible changes, with evidence saved under `.opencode/evidence/<plan-name>/`.
6. **Scope check** — you delivered exactly what was asked, nothing quietly narrowed or widened; every claim in your summary is backed by a tool result.
7. **No temporary files left behind** — every scratch/temp file created outside `.opencode/` removed, per the TEMPORARY FILES section.

Never present partial work as complete. No stub, placeholder, or no-op shipped as the feature. If one part is blocked, finish the rest and state exactly what remains blocked. Then report: what changed, how it was verified, and any follow-ups.

## Reporting & notepad

When the task prompt names a notepad (e.g. `.opencode/notepads/<plan-name>/`), APPEND findings, learnings, and follow-ups to the appropriate file — never overwrite, never create parallel copies. Keep the final report dense: what changed, how it was verified (commands + results), follow-ups, and the compact review verdict.

## Handoff

If your report hands off follow-up work, describe it in plain prose with paths; build decides the routing and executor.
