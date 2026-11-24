# Foundation AI for OpenCode 1.19

Foundation AI is a ten-agent, three-tier orchestration system built on OpenCode V1 agent nesting.

## Architecture

```text
TIER 0
└── HARI SELDON — Grand Leader (default entry point)
    ├── TIER 1: R. DANIEL OLIVAW — Technical Lead / COO
    │   ├── ELIJAH BALEY — Shared Investigator
    │   ├── ANDREW MARTIN — Implementer + Git
    │   ├── HAN FASTOLFE — Independent Code Reviewer
    │   ├── GOLAN TREVIZE — Independent QA
    │   └── JOTHAN LEEBIG — Independent Security Engineer
    ├── TIER 1: R. GISKARD REVENTLOV — Planner
    │   ├── ELIJAH BALEY — Shared Investigator
    │   ├── DORS VENABILI — Planning Advisor (read-only)
    │   └── KELDEN AMADIRO — Independent Plan Reviewer
```

Hari is the default entry point. Daniel and Giskard are directly selectable. Dors is Giskard's read-only planning advisor; she is not a security assistant. Tier 2 agents are child-only and cannot dispatch further tasks.

## Included

- **10 agents** in `.opencode/agents/`
- **15 skills** in `.opencode/skills/` (13 migrated from the upstream pack plus `security-review` and `security-advisory` for planning critique)
- **6 protocols** in `.opencode/protocols/`
- OpenCode 1.19 project config: `opencode.jsonc`
- Original upstream skills preserved verbatim under `source-snapshot/skills/`
- Source manifest and audit at repository root

## Install in a project

For project-local use, copy the `.opencode/` directory and `opencode.jsonc` into the target project, or use this repository as the project. OpenCode discovers project-local agents and skills from these locations.

For global use, run `bash ./install.sh --yes --config-dir ~/.config/opencode` from this repository. The installer stages files, refuses to overwrite unowned name collisions, backs up previously Foundation AI-managed files, and records a manifest for the matching uninstaller. It does not edit your active `opencode.jsonc`; it writes a config fragment under `~/.config/opencode/foundation-ai/opencode.jsonc.fragment` for manual merging. Run `bash ./uninstall.sh` to remove only manifest-listed files and restore the original pre-install files.

If the target project already has an `opencode.jsonc`, merge these two root settings into its existing JSONC object without deleting existing settings or comments:

```json
{
  "default_agent": "hari-seldon",
  "subagent_depth": 2
}
```

Do not replace the user's existing configuration wholesale. The project configuration file in this repository is a minimal example, not a universal drop-in replacement for an existing config.

Restart OpenCode after installing or changing agent files.

## OpenCode 1.19 requirements

This pack targets the OpenCode V1 configuration model:
- `default_agent` is `hari-seldon`.
- `subagent_depth: 2` permits Tier 1 → Tier 2 nested delegation.
- Agent frontmatter uses singular `permission:` and `permission.task` allowlists.
- Tier 2 agents explicitly deny all task dispatch.
- Do not use OpenCode 2.x `permissions[]` / `subagent` syntax.

See [OpenCode 1.19 compatibility](OPENCODE_1_19_COMPATIBILITY.md). The V1 schema has been checked against version-specific source research, but the full runtime matrix must still be executed against an installed OpenCode 1.19.x before release.

## Workflow

### Planning
Giskard researches through Elijah, consults Dors for substantive planning critique, applies `architect-work` for complex designs, prepares a decision-complete plan, and sends it to Kelden for independent formal review. Hari obtains explicit user approval of that exact reviewed plan before authorizing Daniel to begin implementation.

### Implementation
Daniel decomposes the approved plan and delegates to Andrew. Han performs independent code review. Jothan performs risk-triggered security review. Golan executes frozen QA scenarios. Andrew fixes findings and independently reviewed gates are repeated. Daniel authorizes Git commit only after all required gates pass.

### Security triggers
Jothan must review changes involving authentication/authorization, secrets, sensitive data, public APIs, uploads, parsing/deserialization, injection sinks, user-controlled HTML, network boundaries, cryptography, dependencies/supply chain, permissions, or security configuration.

Critical/High findings block. Medium requires remediation or explicit Hari/user risk acceptance. Jothan is read-only and does not fix findings.

## Skills

| Skill | Owner / use |
|---|---|
| `plan-work` | Giskard |
| `architect-work` | Giskard's architecture capability |
| `review-plan` | Kelden |
| `research-topic` | Elijah |
| `lead-work` | Daniel |
| `execute-work` | Andrew |
| `discuss-work` | Shared discussion mode; no separate agent |
| `code-idiom` | Andrew, companion |
| `refactor-code` | Andrew, companion |
| `slop-cleanup` | Andrew, companion |
| `review-code` | Han |
| `qa-inspect` | Golan |
| `git-operations` | Andrew |
| `security-review` | Jothan |
| `security-advisory` | Dors — planning critique for Giskard |

## Safety and release status

The installer, uninstaller, structural validator, and disposable lifecycle tests are implemented. CI has passed structural validation and installer lifecycle tests on both Ubuntu and macOS. The revised ten-agent roster passed CI on Ubuntu and macOS, including the pinned OpenCode 1.19.0 agent-discovery, permission, resolved-config, and global-install smoke tests. Real model-driven nested dispatch remains untested. Do not treat this migration branch as a production release until:
- the Ubuntu and macOS lifecycle test matrix passes;
- nested Tier 1 → Tier 2 task dispatch and disallowed-child rejection pass end-to-end against OpenCode 1.19.0 (config parsing and agent discovery already pass);
- quality-gate, security-trigger, and end-to-end orchestration tests pass;
- final audit and release approval are complete.

## Source traceability

Upstream repository: https://github.com/tormozzg/opencode-agents

Pinned source commit: `85edc5cd01bb8c60d98e08cf696456eea502667f`

The exact original 13 skill bodies are retained in `source-snapshot/skills/`. Migration changes are in the active `.opencode/skills/` tree.
