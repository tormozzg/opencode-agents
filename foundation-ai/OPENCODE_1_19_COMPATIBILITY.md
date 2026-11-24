# OpenCode 1.19 compatibility contract

Status: schema/source review complete; runtime verification pending.
Target: OpenCode 1.19.x (V1 configuration and Task tool, not OpenCode 2.x).

## Version-specific choices

Foundation AI intentionally uses the OpenCode V1 shape:

- Top-level `default_agent` selects `daniel-olivaw`.
- Top-level `subagent_depth: 2` permits the primary coordinator to call Tier 1 and Tier 1 to call Tier 2.
- Markdown agent frontmatter uses singular `permission:` and the V1 permission map.
- Nested delegation uses the V1 `task` permission/action.
- Agent `mode` values are `primary`, `all`, and `subagent`.
- Skills live under `.opencode/skills/<name>/SKILL.md`; the V1 skill tool is explicitly allowed in each agent's permission map.

Do NOT silently convert this configuration to OpenCode 2.x syntax. In particular, do not replace V1 `permission.task` with the V2 `permissions[]` / `subagent` form, do not move nesting to `experimental.subagent_depth`, and do not rename the top-level V1 `agent` config key if one is added later.

## Delegation matrix

| Caller | Allowed Task children |
|---|---|
| Daniel Olivaw | Giskard Reventlov, Susan Calvin |
| Giskard Reventlov | Elijah Baley, Kelden Amadiro |
| Susan Calvin | Elijah Baley, Andrew Martin, Han Fastolfe, Golan Trevize, Jothan Leebig |
| Tier 2 specialists | None |

Every caller's V1 permission map starts with `"*": "deny"`, then adds exact allowed child IDs. Tier 2 agents explicitly deny all `task` dispatch. This is important because `subagent_depth` controls maximum nesting but does not define which child agent a parent may call.

## Modes

- `daniel-olivaw`: `primary` — default entry point.
- `giskard-reventlov`, `susan-calvin`: `all` — user-selectable and callable as subagents.
- All specialists: `subagent` — child-only.

## Evidence and runtime validation

The OpenCode V1 mechanics were checked directly against the immutable `v1.19.0` source tag (tag commit `add9b4ba5adfb895934cb1bf46f590342cec68d2`). The key schema and CLI source files are `packages/core/src/v1/config/config.ts`, `packages/core/src/v1/config/agent.ts`, `packages/core/src/v1/config/permission.ts`, and `packages/opencode/src/cli/cmd/agent.ts`. These confirm `default_agent`, top-level `subagent_depth`, V1 agent modes (`all`, `primary`, `subagent`), singular `permission`, and the `task`, `edit`, and `skill` permission keys. `default_agent` must identify a primary agent; Daniel is configured as `primary`. See:
- https://github.com/ecmwf/ecmwf-multi-agents/blob/main/docs/research/opencode-v1.md
- https://github.com/anomalyco/opencode/tree/v1.19.0

The OpenCode V1 docs also describe `permission.task` allowlists and `mode` behavior:
- https://opencode.ai/docs/agents/
- https://opencode.ai/docs/config/

This repository has not yet been executed inside an installed OpenCode 1.19 runtime. Before release, run the exact target version and verify:
1. `opencode --version` reports 1.19.x.
2. `opencode agent list` shows all nine agents and their expected modes.
3. The default agent is Daniel Olivaw.
4. Daniel can dispatch only Giskard and Susan.
5. Giskard can dispatch only Elijah and Kelden.
6. Susan can dispatch only Elijah, Andrew, Han, Golan, and Jothan.
7. Tier 2 agents have no Task children.
8. Nested Tier 1 → Tier 2 dispatch succeeds at `subagent_depth: 2`.
9. All 14 skills are discoverable and load by exact name.
10. Invalid or disallowed dispatches are rejected by the runtime, not merely discouraged by prompts.

Do not mark OpenCode 1.19 compatibility as fully verified until this runtime checklist passes.


## Runtime smoke-test status

**Passed — OpenCode 1.19.0**

The GitHub Actions smoke test downloaded the pinned `v1.19.0` Linux CLI and verified:

- The binary reports exactly `1.19.0`.
- `opencode agent list` discovers all nine Foundation AI agents with their configured modes.
- The CLI successfully parses and displays the agent permission maps, including task allowlists and edit boundaries.
- `opencode debug config` resolves `default_agent = daniel-olivaw` and `subagent_depth = 2`.

This verifies configuration parsing and agent discovery on the exact target release. It does **not** yet execute a real parent → child → grandchild `task()` dispatch, nor prove that every disallowed child dispatch is rejected during a live agent run. Those remain end-to-end runtime tests before release.
