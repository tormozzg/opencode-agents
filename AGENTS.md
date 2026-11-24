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
bash -n install.sh uninstall.sh
bash scripts/validate-pack.sh
bash scripts/test-install.sh
```

The GitHub Actions workflow validates Ubuntu/macOS installer lifecycle behavior and runs a pinned OpenCode 1.19.0 CLI smoke test. Passing structural checks does not by itself prove every nested orchestration route; report runtime coverage accurately.

## Release discipline

All Foundation AI migration work belongs on `foundation-ai/v1.0-migration` until the final audit and release approval. Keep `main` unchanged. Do not claim v1.0 is production-ready while required release gates remain open.
