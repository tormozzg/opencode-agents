# Repository instructions — Foundation AI migration

## Project layout

This repository contains two distinct packs:

- **Foundation AI (active migration target):** `.opencode/agents/`, `.opencode/skills/`, `.opencode/protocols/`, and `opencode.jsonc`.
- **Upstream source snapshots:** `source-snapshot/agents/` and `source-snapshot/skills/`; the pinned source manifest records the original installer and config snippet hashes.

Do not install or modify the original pack when working on Foundation AI. The root `install.sh` and `uninstall.sh` are the canonical Foundation AI installer and uninstaller.

Read `foundation-ai/README.md` and `foundation-ai/OPENCODE_1_19_COMPATIBILITY.md` before changing the active pack. The source commit, file manifest, and migration audit are recorded under `foundation-ai/`; exact upstream skill snapshots are under `foundation-ai/source-snapshot/skills/`.

## Active architecture

Foundation AI has nine agents:

- Tier 0: Daniel Olivaw — primary coordinator and default entry point.
- Tier 1: Giskard Reventlov — planning; Susan Calvin — implementation lead.
- Tier 2: Elijah Baley, Kelden Amadiro, Andrew Martin, Han Fastolfe, Golan Trevize, and Jothan Leebig — specialist agents.

Tier 2 agents are leaf agents. Preserve the explicit `permission.task` allowlists and deny rules in agent frontmatter. The intended nesting depth is 2. Do not widen delegation permissions casually.

## Separation of duties

- Daniel coordinates and escalates material decisions; he does not implement.
- Giskard plans; Kelden independently reviews plans; Elijah investigates.
- Susan coordinates implementation; Andrew implements and owns permitted Git operations.
- Han performs independent read-only code review.
- Golan performs independent QA against defined scenarios.
- Jothan performs independent read-only security review and does not fix findings.
- Do not let an implementer approve their own work or silently bypass a quality gate.
- Critical/High security findings block completion. Medium findings require remediation or explicit risk acceptance by Daniel/user.

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
bash -n install.sh uninstall.sh foundation-ai/install.sh foundation-ai/uninstall.sh
bash foundation-ai/scripts/validate-pack.sh
bash foundation-ai/scripts/test-install.sh
```

The GitHub Actions workflow also validates Ubuntu/macOS installer lifecycle behavior and performs a pinned OpenCode 1.19.0 runtime smoke test. Passing structural checks does not by itself prove every nested orchestration route; report runtime coverage accurately.

## Release discipline

All Foundation AI migration work belongs on `foundation-ai/v1.0-migration` until the final audit and release approval. Keep `main` unchanged. Do not claim v1.0 is production-ready while required release gates remain open.
