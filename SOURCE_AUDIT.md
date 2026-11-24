# Foundation AI — Stage A source audit

Date: 2026-11-24
Repository: `tormozzg/opencode-agents`
Source commit: `85edc5cd01bb8c60d98e08cf696456eea502667f`
Working branch: `foundation-ai/v1.0-migration`

## 1. Source integrity and inventory

- Recursive Git tree was read at the pinned source commit; GitHub reported `truncated=false`.
- The tree contains 29 tracked files: 10 agent definitions, 13 skills, installer, uninstaller, OpenCode registration snippet, README, AGENTS.md, and .gitignore.
- All 10 agent definitions and all 13 skill files were fetched successfully from `main` and inspected for role boundaries, first-action skill loading, procedure headings, and references.
- No tracked nested templates, hooks, CI workflows, test suites, binary assets, or additional reference directories exist at this commit.
- See `SOURCE_MANIFEST.md` for blob SHAs and sizes.

## 2. Source architecture and behavior that must survive migration

### Planning path
- `plan-work`: sticky plan-only mode; research delegated to explore; architecture consult for complex work; two-filter question policy; affected-user/ideal-state analysis; decision-complete plan; durable drafts; explicit approval gate; task-row grammar; mandatory independent plan review; stop rules.
- `architect-work`: advisory/read-only to product code; seven-step workflow; structured architecture artifact with design overview, decisions, alternatives, NFRs, rollout/operations, and planner handoff.
- `review-plan`: reference verification, plan re-read rule, executability, QA scenario checks, blocker-vs-note classification; reviewer does not rewrite plans.

### Implementation path
- `lead-work`: start gate, receiving work, isolated Git worktrees, context-resume, routing, delegation prompts, parallel waves, claim verification, auto-continue and completion loop.
- `execute-work`: pre-write language gate; mandatory coding-discipline composition; scenario contract before coding; act/verify/inspect loop; mandatory 11-point post-write review; escalation; real-surface QA; temporary-file restrictions; evidence-based completion report.
- `code-idiom`: types-as-proofs, parse-don't-validate boundaries, YAGNI ladder, error handling, naming, documentation, language-specific conventions.
- `refactor-code`: lock behavior before change, bounded step loop, no improvised refactoring, preparatory refactoring, evidence.
- `slop-cleanup`: classify suspected generated-code slop, verify before deletion, protocol and reporting.

### Independent quality and research
- `research-topic`: read-only, evidence-demander stance; code/docs/web source territories; external content treated as claims; triangulation; two-empty-waves stop rule; numbered findings and evidence handoff.
- `review-code`: read-only diff review, input validation, work-type classification, plan fidelity, correctness/quality, AI-slop checklist, blocker/note verdict and re-review.
- `qa-inspect`: validates scenario input, freezes scenarios, executes real commands, saves evidence, reports per-scenario PASS/FAIL; FAIL blocks commit and triggers fix/retest; QA does not fix product code.
- `discuss-work`: separate discussion mode; fact-finding dispatches, discussion ledger, user-owned decisions, no edits/plans/commits.

### Git behavior
- `git-master` has explicit COMMIT / REBASE / HISTORY / STATUS mode gates.
- Preserve atomic commit grouping and message convention, history search (including blame/bisect/log -S/reflog), rebase golden rule, shared-history protection, and safety checks.
- Foundation AI maps Git ownership to Andrew Martin, but must retain approval and quality gates; implementation completion alone is not commit authorization.

## 3. Concrete upstream installer risks

1. `install.sh` removes an existing same-named destination skill directory before copying the pack version. That can destroy user content without a backup.
2. Existing agent files are overwritten without per-file backup.
3. Config merge uses Python's standard JSON parser/writer, so JSONC comments are lost. The config is backed up, but the merge is not comment-preserving.
4. If config merge fails after agents/skills have been copied, the installer reports partial installation; it does not roll back those copied files.
5. `uninstall.sh` restores the most recent config backup and removes exact agent/skill names. It does not restore overwritten agent/skill directories; its behavior assumes pack ownership of those names.
6. Upstream installer/uninstaller hardcode 10 agent names and 13 skill directories. All lists and documentation must be updated together in Foundation AI.

These are findings about the upstream implementation, not a recommendation to reuse it unchanged.

## 4. Starter scaffold comparison status

The previously generated starter is a scaffold, not a complete migration. Its agent/protocol layout reflects the approved Foundation AI hierarchy, but its skill bodies are abbreviated/initial drafts rather than verified full migrations of the upstream procedural content.

Known starter corrections already identified:
- It contains 14 skills (13 migrated names plus new `security-review`); README and validator incorrectly state/check 13.
- It names the Martin Git skill `git-operations`; it must explicitly preserve the full upstream `git-master` behavior and mode gates.
- The starter's OpenCode 1.19 configuration and frontmatter permissions require schema/runtime validation against the exact installed OpenCode 1.19 release.
- The starter's installer must be redesigned for backup, non-destructive collision handling, atomic install, and rollback; do not copy upstream destructive replacement behavior.
- The security-review skill is new Foundation AI functionality and must be reviewed independently; it is not an upstream skill.

The starter files were not present in the current execution workspace at audit time, so this report does not claim a line-by-line diff against those local files.

## 5. Migration acceptance checklist

- [ ] Fetch and preserve all 13 upstream skill bodies at the pinned commit before rewriting/adapting them.
- [ ] Migrate each procedure with an explicit source-to-target traceability map; no silent summarization or dropped rules.
- [ ] Add Leebig security-review as a clearly marked new skill, with risk triggers, severity, independent verdict, and retest.
- [ ] Ensure agents load their corresponding skills first and enforce read-only/write boundaries.
- [ ] Preserve planning approval, plan review, worktree isolation, delegated implementation, lead claim verification, independent code review, frozen-scenario QA, and commit gate.
- [ ] Preserve Git COMMIT / REBASE / HISTORY / STATUS functionality and safe-history policies for Martin.
- [ ] Reconcile all 9 agents, 14 skills, 6 protocols, configuration registration, installer, uninstaller, README, and validators.
- [ ] Validate OpenCode 1.19 schema, `subagent_depth`, `permission.task`, allowlists, and prohibition of task dispatch by Tier 2 agents in an actual 1.19 runtime.
- [ ] Test installer/uninstaller in disposable config directories, including collisions, pre-existing user files, JSONC comments, interrupted install, rollback, and repeated install.
- [ ] Run structural, orchestration, quality-gate, security-trigger, Git-gate, and release tests before requesting final approval.

## 6. Stage A conclusion

Source inventory and upstream behavior audit are complete. No upstream files were modified. The manifest and this audit are being committed only to the migration branch. Proceed to skill migration only with the full source contents retained and traceable; do not describe the current starter scaffold as production-ready or as a complete migration.


## 7. Implementation follow-up (2026-11-24)

The migration has progressed beyond the initial starter audit:

- All 13 upstream skill bodies are preserved verbatim under `source-snapshot/skills/`. Their Git blob SHAs were compared against the pinned source tree; all 13 are exact matches.
- All 13 source skills now have Foundation AI counterparts under `.opencode/skills/`; the new `security-review` makes 14 total. A heading-level audit found no dropped source sections. The plan-work architecture consult is intentionally converted into Giskard loading `architect-work`, and the Git Master heading is renamed for Andrew Martin's `git-operations` skill.
- Nine agent definitions, six protocols, the V1 config, and explicit task/edit permission scopes are present.
- The repository `.gitignore` now tracks only the pack-definition paths under `.opencode/` while keeping runtime artifacts ignored.
- Safe installer/uninstaller, structural validator, lifecycle tests, and a GitHub Actions matrix were added. CI has passed the structural and installer lifecycle tests on both Ubuntu and macOS; the latest Ubuntu and macOS lifecycle jobs both pass, and the pinned OpenCode 1.19.0 runtime smoke job passes.
- The pinned OpenCode 1.19.0 CLI smoke test passes agent discovery, permission parsing, and resolved-config checks. A real nested parent → child → grandchild task dispatch and disallowed-child rejection are still untested.

The upstream `main` branch remains untouched; all Foundation AI changes are confined to `foundation-ai/v1.0-migration`.


## 8. Foundation AI leadership revision

- Hari Seldon is the Tier 0 Grand Leader and default primary agent.
- Daniel Olivaw replaces Susan Calvin as Technical Lead / COO.
- Giskard Reventlov remains Planner.
- Dors Venabili is a read-only leadership-level Security Assistant; she does not replace Jothan Leebig's independent technical security review.
- The active roster is ten agents and fifteen skills. Upstream source snapshots remain unchanged.
- `default_agent` is `hari-seldon`; `subagent_depth: 2` is retained.
- Prior nine-agent CI evidence does not validate this revision; a fresh run is required.
