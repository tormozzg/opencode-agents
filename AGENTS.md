# AGENTS.md

## What this repo is

Installable OpenCode pack: 7 agents in `agents/*.md`
+ 7 skills in `skills/<name>/SKILL.md`, installed globally into the OpenCode
config dir. It is not an app or library — there is no build, test, or lint here;
there is also no `package.json`, no CI, no `.github/`.

| Agent (`agents/*.md`) | Mode | Skill (`skills/*/SKILL.md`) |
|---|---|---|
| `plan` | primary | `plan-work` |
| `build` | primary | `lead-work` |
| `explore` | subagent | `research-topic` |
| `worker` | subagent | `execute-work` |
| `plan-reviewer` | subagent | `review-plan` |
| `code-reviewer` | subagent | `review-code` |
| `git-master` | subagent | `git-master` |

`plan` and `build` are primary agents - select one as the active agent; they
cannot be spawned by others; all the rest are invoked as subagents
(`@worker`, `@explore`, …).

## Three-place invariant

Adding/renaming an agent or skill touches three files, all of which must agree:
`agents/<name>.md` (frontmatter `description` + `mode`), `skills/<name>/SKILL.md`
(frontmatter `name`), and `opencode.jsonc.snippet` (`agent.<name>` entry +
`skills.paths` entry). `uninstall.sh` removes by hardcoded exact-name lists
(`AGENT_FILES`, `SKILL_DIRS`) — a rename without updating those lists leaves
orphans in the user's config dir. Same for the matching skill reference in each
agent file and the agent description in the snippet (README quotes them).

## Install / verify

```bash
bash -n install.sh && bash -n uninstall.sh      # shell syntax check
python3 -m json.tool opencode.jsonc.snippet     # snippet is pure JSON
./install.sh --yes                              # install locally
```

Installer flags: `--yes`, `--model <agent>=<model>` (repeatable; agent must be
one of the 7 pack agents, model must be whitespace-free, else exit 2 before
anything is installed), `--default-model <model>` (repeatable, last value
wins; model must be whitespace-free, else exit 2 before anything is
installed), `--config-dir <path>` (also `--flag=value` form; `~`
expands to `$HOME`). Default target: `~/.config/opencode`.

Installer behavior (verified against `install.sh`):
- Copies `agents/*.md` → `<config-dir>/agents/`, each `skills/*/` dir →
  `<config-dir>/skills/<name>/` (replaces same-named skill dirs).
- Merges `opencode.jsonc.snippet` into `<config-dir>/opencode.jsonc` (or an
  existing `opencode.json`; `.jsonc` preferred/created). Existing config gets a
  `<file>.backup-<timestamp>` first.
- Merge is per-key: user-set per-agent `"model"` keys survive re-install
  (snippet keys win on conflict); the top-level `"model"` is never touched
  UNLESS `--default-model <model>` is given, in which case it is set to that
  value (overwriting any existing top-level `"model"`).
- The merge uses python3 stdlib `json`: JSONC comments in an existing config
  are LOST on merge (the backup keeps the original). Unparseable existing
  config aborts the merge, not corrupts it.
- OpenCode reads its config at startup — restart after install to apply.

`./uninstall.sh --yes [--config-dir <path>]` is the exact inverse: restores the
most recent `opencode.jsonc.backup-*` / `opencode.json.backup-*` over the
configs, then removes exactly the 7 agent files and 7 skill dirs by name.
Everything else in `agents/`/`skills/` is preserved.

## Repo conventions

- Run-time artifacts live in two places. Plan artifacts (`plan`'s final plan
  and durable draft) go into OpenCode's built-in Plan directory
  (`~/.opencode/plan`), because the built-in Plan mode restricts the plan
  agent's writes to it. Notepads and evidence live under `.opencode/` in the
  project root, created on demand by the other agents. That directory
  is gitignored — never commit its contents; save verification
  evidence under `.opencode/evidence/`.
- `opencode.jsonc.snippet` is the single config unit; keep it pure JSON so
  `python3 -m json.tool` keeps passing.
- README.md is the user-facing source of truth — update it whenever flags,
  behavior, or agent/skill content change; keep prose in sync, not duplicated.
