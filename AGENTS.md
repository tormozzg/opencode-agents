# Repository instructions — Foundation AI

## Project layout

- Active Foundation AI agents, skills, and protocols: `.opencode/`.
- OpenCode project configuration: `opencode.jsonc`.
- Installer and uninstaller: `install.sh`, `uninstall.sh`.
- Validation scripts: `scripts/`.
- Upstream source snapshots: `source-snapshot/agents/` and `source-snapshot/skills/`.
- Compatibility contract, source manifest, source audit, and release notes are maintained at repository root.

Read `README.md` and `OPENCODE_1_19_COMPATIBILITY.md` before changing the active pack. Do not install or modify upstream source snapshots.

## Active architecture

Foundation AI has ten agents:

- Tier 0: Hari Seldon — Grand Leader and default entry point.
- Tier 1: Daniel Olivaw — Technical Lead / COO; Giskard Reventlov — Planner.
- Tier 2: Dors Venabili — Giskard's read-only Planning Advisor, alongside independent formal Plan Reviewer Kelden Amadiro and Daniel's technical specialists.
- Tier 2: Elijah Baley, Kelden Amadiro, Andrew Martin, Han Fastolfe, Golan Trevize, and Jothan Leebig.

Tier 2 agents are leaf agents. Preserve the explicit `permission.task` allowlists and deny rules in agent frontmatter. The intended nesting depth is 2. Do not widen delegation permissions casually.

## Tier 2 evidence artifact permissions
All Tier 2 agents may create directories and write their own task/run evidence under `.opencode/evidence/<plan-name-or-task-slug>/**`; temporary verification artifacts may go under `.opencode/tmp/**`. This is a narrow exception to read-only duties: read-only applies to product/source files, tests, configuration, plans owned by another agent, and Git history—not to the agent's own evidence deliverables. Reviewer and advisor agents must not modify the artifacts they assess. Evidence permissions do not authorize implementation or commits. Each agent must follow its skill's evidence naming/one-file-per-run convention and verify the artifact exists and is non-empty before reporting it.

## Tier 2 concurrency policy
Each Tier 2 agent may have at most one active delegated assignment globally. This is a per-agent limit shared across all Tier 1 callers: Elijah's slot is shared by Daniel and Giskard. Different Tier 2 agents may work in parallel when their assignments are independent. Tier 1 callers must consolidate related requests, track outstanding assignments, and wait for a Tier 2 agent's result before dispatching another task to that same agent. Tier 2 agents remain leaf agents and must not spawn or fork additional work. This is an instruction-level coordination rule, not a runtime-enforced mutex.

## Discussion and review routing

- Hari may call Elijah directly for conversational, read-only codebase discussion and preliminary investigation. This is not a formal code review, security audit, QA verdict, or implementation task.
- Elijah's one-active-task slot remains global across Hari, Daniel, and Giskard. If occupied, Hari waits; do not bypass the concurrency rule.
- Formal review-only requests route through Hari to Daniel. Daniel coordinates Han Fastolfe for independent code review and Jothan Leebig for a separate security review when requested or triggered. Review-only work does not dispatch Andrew Martin, modify files, or begin implementation.
- Findings and recommendations return to Hari. Any fixes require a separate explicit implementation request and the normal planning/approval gates.

## Separation of duties

- Hari owns strategy, user-facing plan approval, and material risk decisions.
- Daniel coordinates approved implementation; he does not implement.
- Giskard plans; Kelden independently reviews plans; Elijah investigates.
- Dors advises Giskard on plan completeness, assumptions, dependencies, human/operational factors, failure modes, maintainability, rollout/rollback, and strategic consequences. She does not perform technical security review.
- Jothan performs independent technical security review for Daniel's implementation stream.
- Andrew implements and owns permitted Git operations.
- Han performs independent read-only code review.
- Golan performs independent QA against defined scenarios.
- Do not let an implementer approve their own work or silently bypass a quality gate.
- Critical/High security findings block completion. Medium findings require remediation or explicit risk acceptance by Hari/user.

Follow the detailed workflows in the relevant skill and protocol files; do not create conflicting duplicate rules in agent prompts.

## Change discipline

1. Preserve the approved architecture and user-approved plan. Escalate changes to goals, architecture, scope, or material risk.
2. Keep source snapshots byte-for-byte unchanged. Make adaptations only in `.opencode/skills/`.
3. Keep agent names, skill frontmatter names, dispatch IDs, task allowlists, installer manifests, documentation, and tests consistent.
4. Keep reviewers and QA independent and read-only. Record evidence for verification claims.
5. Git commits are gated on required code review, security review when triggered, and QA. Never commit directly to `main` during migration work.
6. Installer changes must preserve unowned user files, support rollback, and be tested using disposable config directories. Never silently rewrite a user's active `opencode.jsonc`.

## Validation

Run these from the repository root:

```bash
bash -n install.sh uninstall.sh
bash scripts/validate-pack.sh
bash scripts/test-install.sh
```

The GitHub Actions workflow validates Ubuntu/macOS installer lifecycle behavior and runs a pinned OpenCode 1.19.0 CLI smoke test. Passing structural checks does not by itself prove every nested orchestration route; report runtime coverage accurately.

## Release discipline

All Foundation AI migration work belongs on `foundation-ai/v1.0-migration` until the final audit and release approval. Keep `main` unchanged. Do not claim v1.0 is production-ready while required release gates remain open.
