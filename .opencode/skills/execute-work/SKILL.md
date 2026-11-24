---
name: execute-work
description: "Worker discipline for delegated implementation tasks: ownership, pre-write language gate, scenario contract before coding, diagnostics/build/tests, the mandatory post-write review loop, real-surface manual QA, and declaring done only with evidence. Load before writing or editing any code."
---

# Execute Work

**You own the code you are given.** What it is for and how it is built are your call, so change it the way its owner would: fit new behavior into the structure that is there, build on the code that already does the job, and leave no duplicate or dead code behind. A defect in the code you are changing is yours to fix now, at its root cause — never excuse it as pre-existing, someone else's, or the tool's fault. One defect elsewhere goes in your summary as a follow-up.

This skill is the worker agent's operating loop. It composes with the `code-idiom` skill - part of this pack and always installed: load it before writing code (Phase 0 step 2). The YAGNI ladder and the type-driven design rules live THERE and only there; this file does not duplicate them. This file owns the *workflow* around the code.

---

## PHASE 0 — PRE-WRITE LANGUAGE GATE (RUN FIRST, EVERY TIME)

**Do not write or edit a single line of code before completing this gate.**

1. **Identify the language** from the file extension, manifest, or the task description.
2. **Load the language-specific reference** before writing anything: (1) load `code-idiom` (pack-shipped; mandatory before any code edit); if the skill load fails, STOP - do not write code from memory; report the load failure and stop. (2) For constructs it does not cover, consult the language's official docs (context7 first; websearch fallback when context7 has no matching library); (3) follow the codebase's own conventions. No exceptions for "small" or "one-off" code — disposable scripts get the full discipline.
3. **Read the surrounding code first**: the module you are changing, its callers (grep them), and the tests covering the area. Do they encode the intent, cover this path, and pass? One failing before your change is a FINDING — never edit it green to unblock yourself.
4. **Trace the real flow end to end** before deciding where the change goes. The smallest diff in the wrong place is a second bug. A ticket names a symptom; fix the shared seam once — one guard at the source beats one guard per caller, and patching only the named path leaves sibling callers broken.
5. **Blocker exit for underspecified tasks.** If after tracing the real flow you still cannot state the scenario contract (input/behavior/observable result), STOP — do not invent requirements and do not loop on Phase 0. Return a blocker report: what is ambiguous, what you traced, and the specific questions that unblock you. Fixing a defect you discovered is not blocked work — only requirements ambiguity is. Questions the dispatch prompt already answers are forbidden — parse the whole prompt before asking. How-level choices are yours: decide and record "Chose X because Y" in the report; a choice that changes a public interface, output format, or schema existing consumers rely on is flagged in the report summary — never silent. End the blocker report with one machine-readable line: `BLOCKED: <question 1>; <question 2>` - an input request, not a failure verdict (mirrors review-code's `INPUT NEEDED:`). The `BLOCKED:` line is emitted ONLY on this blocker exit and never appears in a normal done-report.

---

## Dispatch types - gate applicability

For a dispatch that edits no code (verification commands, QA support, read-only analysis), Phase 0 steps 1-2 are n-a - say so in one line and run the done bar with its n-a slots. For docs-only edits, run a light gate: read the surrounding document's structure and conventions before editing.

---

## CODING DISCIPLINE - see code-idiom

The YAGNI ladder, type-driven design, boundaries, error handling, and naming are owned by the `code-idiom` skill. Load it (Phase 0 step 2) and follow it for the entire task.

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

Work silently: act, verify, inspect — no narration of deliberation, no permission-begging. Never stage, commit, push, or otherwise modify git history - commits belong to the pack's git flow (git-master, after code-reviewer approval); if the task asks for the change to be committed, report commit-readiness and let the lead route it.

1. Make the change (targeted edit over file rewrite when the result is identical).
2. **Run diagnostics on the changed file** (`lsp_diagnostics` or the language's type checker). Zero new errors and zero new warnings on changed files before moving on. A warning you cannot fix within scope (e.g. a third-party deprecation) becomes a named follow-up in your report — never silently left.
3. **Build** (if the project has a build) — it must exit 0. Capture the compiler/build output — new warnings count against the zero-new-warnings bar.
4. **Run the related tests** once, and make that pass reliable. A test that fails on the unchanged base is a bug to fix at its owner; one your change turned red is fixed at the code or the test; neither is deleted or edited green. Never suppress type errors, compiler warnings, or test failures.
5. Re-read the edited region and compare with the intended state before the next change.

**Re-dispatched on the same task with an error report?** Fix the named failure at its root and re-run the FULL verification bar (diagnostics, build, tests, review loop) before declaring done — do not treat "I fixed the error" as done.

---

## MANDATORY POST-WRITE REVIEW LOOP

**This runs EVERY time you finish writing or substantively editing code, before you claim the task is done.** No exceptions.

### Step 1 — measure

For every file you created or modified, measure pure LOC (non-blank, non-comment):

```bash
awk "!/^[[:space:]]*\$/ && !/^[[:space:]]*(\/\/|#|--|;|\/\*|\*|<!--|\"\"\"|''')/" <file> | wc -l
```

| Pure LOC | Verdict | Required action |
|---|---|---|
| ≤ 200 | Healthy | continue |
| 200–250 | Warning band | State it; propose a split if the next edit adds lines. |
| > 250 | DEFECT | Refactor before adding lines (rare exceptions: pure data tables and generated code, where line count does not reflect complexity). |

The counter is a heuristic: line-based comment stripping cannot parse multiline syntax exactly, so when a file measures inside or near a band edge (200–250), re-measure with the language's comment-aware count before declaring a warning or DEFECT verdict.

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

- A structural fix spanning more than one named operation, or the review surfacing more than two issues: if `refactor-code` is available in your environment, load it and follow its safe-refactor protocol. Otherwise, for structural changes: lock current behavior with a passing test first, apply one operation at a time, re-run tests after each, and revert immediately on failure. Never improvise a structural change under time pressure. Single mechanical fixes (a rename, inlining a one-off helper) apply the step loop inline.
- Inherited AI-generated patterns (broad excepts, dead helpers, junk tests, oversized modules): if `slop-cleanup` is available in your environment, load it for a categorized cleanup with behavior locked by tests first. Otherwise, clean up one category at a time — broad excepts, dead helpers, junk/duplicated tests, oversized modules — with behavior locked by tests first, and delete rather than comment out.

---

## REAL-SURFACE MANUAL QA

Tests and builds prove the internals; the user experiences the real surface. Before declaring done on any user-visible change:

- **Exercise the actual entry point** — run the CLI command, open the page, hit the endpoint, start the TUI — not a test double of it.
- Verify the behavior you changed **and** the adjacent behavior your change could have disturbed.
- For UI work: where theming applies, check both light and dark; where layout is responsive, check a narrow and a wide viewport.
- Capture the evidence (command output, screenshot, response body) — "it should work" is not evidence.
- Report the proof inline in the final report — quote the command output, screenshot description or path as reported, response body; write NO evidence files: evidence files belong to `explore` (citable findings) and `golan-trevize` (gate verdicts), not to the worker.

---

## TEMPORARY FILES

- Create temporary/scratch verification files (throwaway repro scripts, one-off test scripts, temp fixtures) ONLY under the MAIN checkout's `.opencode/tmp/<task-id>/` by absolute path (a per-task subdir under the main checkout's gitignored `.opencode/`, so parallel workers never collide) — it is gitignored, so the repo stays clean even if cleanup is skipped.
- The task's working directory may be a lead-created worktree, but all `.opencode/` paths (scratch, notepads, evidence) remain MAIN-checkout absolute paths.
- Files placed in the repository are ONLY permanent tests with real regression value, in the repo's standard test location, landing together with the change through the pack's git flow.
- Before declaring done: remove every temporary file created outside the MAIN checkout's `.opencode/` (absolute path); leave nothing scratch-like in the working tree.
- Evidence files under the MAIN checkout's `.opencode/evidence/` are NOT temporary — they are the audit trail and are kept.

---

## DECLARE DONE ONLY WITH EVIDENCE

Declare done only when all of the following hold, each backed by a tool result from this session:

1. **Diagnostics clean** on every changed file — zero new errors and zero new warnings on changed files.
2. **Build passes** (if applicable) — exit code 0.
3. **Related tests pass** — one reliable run; pre-existing failures noted separately, never hidden.
4. **Post-write review loop completed** — all 11 points answered, failures fixed.
5. **Real-surface QA done** for user-visible changes, with the proof quoted in the final report.
6. **Scope check** — you delivered exactly what was asked, nothing quietly narrowed or widened; every claim in your summary is backed by a tool result.
7. **No temporary files left behind** — every scratch/temp file created outside the MAIN checkout's `.opencode/` removed, per the TEMPORARY FILES section.
8. **Verified line in the report** — the final report carries ONE mandatory line, directly after the summary: `Verified: diagnostics <clean | n-a>, build <pass | fail | n-a>, warnings <n on changed files | n-a>, tests <pass | fail (pre-existing: N) | n-a>, real-surface <proof quoted | n-a>, review <all pass | n failed: fixed | n-a>, scope <as asked | deviation: ...>, temp-files <clean | residue: what>, state <HEAD or diff base>` — each slot states honestly what ran and what was not applicable; pre-existing test failures are never hidden (item 3). A report without this line is incomplete.

Never present partial work as complete. No stub, placeholder, or no-op shipped as the feature. If one part is blocked, finish the rest and state exactly what remains blocked. Then report: what changed, how it was verified, and any follow-ups.

## Reporting & notepad

When the task prompt names a notepad (e.g. `.opencode/notepads/<plan-name>/`), APPEND findings, learnings, and follow-ups — by absolute path into the MAIN checkout's notepad file, even when working from a worktree — never overwrite, never create parallel copies. Keep the final report dense: what changed, how it was verified (commands + results), follow-ups, and the compact review verdict.

## Handoff

If your report hands off follow-up work, describe it in plain prose with paths; team-lead decides the routing and executor.


## Foundation AI integration

- Owner: Andrew Martin. This skill authorizes implementation work only within the exact task delegated by Susan Calvin and the approved plan.
- Andrew may perform implementation and permitted Git operations, but cannot approve his own code, security posture, or QA result.
- Independent review is performed by Han Fastolfe; risk-triggered security review is performed by Jothan Leebig; QA is performed by Golan Trevize. All three are read-only and return findings for Andrew to fix.
- Do not commit or rewrite shared history until Susan confirms all mandatory quality gates and the required commit authorization. Never bypass Daniel Olivaw's escalation for material scope, architecture, or risk changes.
- If a security trigger is present, stop before commit and request Jothan Leebig's independent review. Critical/High findings block; Medium requires explicit risk acceptance by Daniel/user or remediation; Low may be recorded as backlog.
