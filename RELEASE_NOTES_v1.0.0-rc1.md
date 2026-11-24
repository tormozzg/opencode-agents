# Foundation AI v1.0.0-rc1 — release candidate notes

**Status:** release-candidate preparation; not yet approved for production release  
**Target:** OpenCode 1.19.0 (V1 configuration model)  
**Branch:** `foundation-ai/v1.0-migration`  
**Audited base:** `main` at `85edc5cd01bb8c60d98e08cf696456eea502667f`  
**Candidate baseline before these documentation-only audit updates:** `063ae15187a0a72fd0cbdc3c8d872fa0e77d08bd`

## What is included

- Ten coordinated agents across three tiers, with Hari Seldon as Grand Leader and default primary coordinator; Daniel Olivaw is Technical Lead / COO.
- Fifteen skills: all thirteen upstream skills migrated, plus `security-review` and the new leadership-level `security-advisory` skill.
- Six operating protocols covering handoffs, task state, quality gates, escalation, Git safety, and security policy.
- OpenCode 1.19 V1 configuration using `default_agent`, `subagent_depth: 2`, and explicit `permission.task` allowlists.
- Original upstream skill bodies retained verbatim under `source-snapshot/skills/`, with source manifest and migration audit.
- Non-destructive global installer and manifest-scoped uninstaller, including backup, rollback, collision protection, and preservation of user edits.
- Structural validation, installer lifecycle tests, and GitHub Actions validation workflow.

## Validation evidence

The previous CI run on candidate baseline `063ae15187a0a72fd0cbdc3c8d872fa0e77d08bd` completed successfully:

- Ubuntu structural and installer lifecycle tests — PASS
- macOS structural and installer lifecycle tests — PASS
- OpenCode 1.19.0 CLI smoke test — PASS

Run: https://github.com/tormozzg/opencode-agents/actions/runs/45455955322

The runtime smoke test verifies exact CLI version, discovery of the previous nine-agent roster and their modes, permission parsing, resolved project configuration, and global installation/discovery.

## Remaining release blockers

The smoke test does not execute real model-driven task dispatch. Before production release, the following must be tested against OpenCode 1.19.0:

1. Daniel dispatches to Giskard and Susan, and no other child.
2. Giskard dispatches only to Elijah and Kelden.
3. Susan dispatches only to the five approved specialists.
4. Tier 2 agents cannot dispatch further tasks.
5. A real Tier 1 → Tier 2 nested task succeeds with `subagent_depth: 2`.
6. Disallowed-child dispatch is rejected by the runtime.
7. Representative end-to-end planning approval, independent review, security trigger, QA freeze/retest, and Git commit gates behave as specified.

No live end-to-end model orchestration test is claimed by the current CI.

## Installation

Project-local: use the repository's `.opencode/` directory and merge the two root settings from `opencode.jsonc` into the project's existing config.

Global:

```bash
./install.sh --yes --config-dir ~/.config/opencode
```

The installer does not rewrite an existing `opencode.jsonc`; it provides a fragment for manual merging. See [the installation guide](README.md).

## Scope and release safety

- All changes remain on `foundation-ai/v1.0-migration`.
- `main` remains unchanged.
- No pull request, merge, release tag, or published release has been created.
- The branch contains a detailed iterative commit history. For a clean review, consider a squash merge after the PR diff and final end-to-end evidence have been approved.
