# Foundation AI for OpenCode 1.19

Foundation AI is a nine-agent, three-tier orchestration system built on OpenCode V1 agent nesting.

## Architecture

```text
TIER 0
└── R. DANIEL OLIVAW — Superchief (default entry point)
    ├── TIER 1: R. GISKARD REVENTLOV — Planner
    │   ├── ELIJAH BALEY — Shared Investigator
    │   └── KELDEN AMADIRO — Independent Plan Reviewer
    │
    └── TIER 1: SUSAN CALVIN — Technical Lead
        ├── ELIJAH BALEY — Shared Investigator
        ├── ANDREW MARTIN — Implementer + Git
        ├── HAN FASTOLFE — Independent Code Reviewer
        ├── GOLAN TREVIZE — Independent QA
        └── JOTHAN LEEBIG — Independent Security Engineer
```

Daniel is the default entry point. Giskard and Susan are also directly selectable. Tier 2 agents are child-only and cannot dispatch further tasks.

## Included

- **9 agents** in `.opencode/agents/`
- **14 skills** in `.opencode/skills/` (13 migrated from the upstream pack plus the new `security-review`)
- **6 protocols** in `.opencode/protocols/`
- OpenCode 1.19 project config: `opencode.jsonc`
- Original upstream skills preserved verbatim under `foundation-ai/source-snapshot/skills/`
- Source manifest and audit under `foundation-ai/`

## Install in a project

For project-local use, copy the `.opencode/` directory and `opencode.jsonc` into the target project, or use this repository as the project. OpenCode discovers project-local agents and skills from these locations.

For global use, run `bash foundation-ai/install.sh --yes --config-dir ~/.config/opencode` from this repository. The installer stages files, refuses to overwrite unowned name collisions, backs up previously Foundation AI-managed files, and records a manifest for the matching uninstaller. It does not edit your active `opencode.jsonc`; it writes a config fragment under `~/.config/opencode/foundation-ai/opencode.jsonc.fragment` for manual merging. Run `bash foundation-ai/uninstall.sh` to remove only manifest-listed files and restore the previous managed versions.

If the target project already has an `opencode.jsonc`, merge these two root settings into its existing JSONC object without deleting existing settings or comments:

```json
{
  "default_agent": "daniel-olivaw",
  "subagent_depth": 2
}
```

Do not replace the user's existing configuration wholesale. The project configuration file in this repository is a minimal example, not a universal drop-in replacement for an existing config.

Restart OpenCode after installing or changing agent files.

## OpenCode 1.19 requirements

This pack targets the OpenCode V1 configuration model:
- `default_agent` is `daniel-olivaw`.
- `subagent_depth: 2` permits Tier 1 → Tier 2 nested delegation.
- Agent frontmatter uses singular `permission:` and `permission.task` allowlists.
- Tier 2 agents explicitly deny all task dispatch.
- Do not use OpenCode 2.x `permissions[]` / `subagent` syntax.

See [OpenCode 1.19 compatibility](OPENCODE_1_19_COMPATIBILITY.md). The V1 schema has been checked against version-specific source research, but the full runtime matrix must still be executed against an installed OpenCode 1.19.x before release.

## Workflow

### Planning
Giskard researches through Elijah, applies `architect-work` for complex designs, prepares a decision-complete plan, and sends it to Kelden for independent review. Daniel obtains explicit user approval before implementation begins.

### Implementation
Susan decomposes the approved plan and delegates to Andrew. Han performs independent code review. Jothan performs risk-triggered security review. Golan executes frozen QA scenarios. Andrew fixes findings and independently reviewed gates are repeated. Susan authorizes Git commit only after all required gates pass.

### Security triggers
Jothan must review changes involving authentication/authorization, secrets, sensitive data, public APIs, uploads, parsing/deserialization, injection sinks, user-controlled HTML, network boundaries, cryptography, dependencies/supply chain, permissions, or security configuration.

Critical/High findings block. Medium requires remediation or explicit Daniel/user risk acceptance. Jothan is read-only and does not fix findings.

## Skills

| Skill | Owner / use |
|---|---|
| `plan-work` | Giskard |
| `architect-work` | Giskard's architecture capability |
| `review-plan` | Kelden |
| `research-topic` | Elijah |
| `lead-work` | Susan |
| `execute-work` | Andrew |
| `discuss-work` | Shared discussion mode; no separate agent |
| `code-idiom` | Andrew, companion |
| `refactor-code` | Andrew, companion |
| `slop-cleanup` | Andrew, companion |
| `review-code` | Han |
| `qa-inspect` | Golan |
| `git-operations` | Andrew |
| `security-review` | Jothan |

## Safety and release status

The installer/uninstaller and validator still need to be completed and tested in disposable config directories. Do not treat this migration branch as a production release until:
- OpenCode 1.19 runtime delegation tests pass;
- installer/uninstaller collision, backup, rollback, repeat-install, and preservation tests pass;
- all structural and quality-gate tests pass;
- final audit and release approval are complete.

## Source traceability

Upstream repository: https://github.com/tormozzg/opencode-agents

Pinned source commit: `85edc5cd01bb8c60d98e08cf696456eea502667f`

The exact original 13 skill bodies are retained in `source-snapshot/skills/`. Migration changes are in the active `.opencode/skills/` tree.
