# OpenCode Subagents Pack

A small, self-contained pack for OpenCode that adds seven focused agents and their
seven matching skills. The pack only registers agents and skills; it does not modify
any other plugins, and it never auto-runs plans. Every plan and every code change stays
under your explicit control.

## What's inside

### Agents

| Agent | Role |
|-------|------|
| `plan` | Built-in OpenCode agent, overridden with our discipline: turns a request into one decision-complete work plan under `.opencode/plans/`. Explores first, delegates research to `explore`, never implements. |
| `build` | Built-in OpenCode agent, overridden with our discipline: orchestrates execution of a plan or direct task by delegating everything. Routes unclear topics to `explore`, ready work to `worker`, runs a mandatory `code-reviewer` pass before any commit, never writes code. |
| `worker` | Implements delegated tasks: writes code, runs diagnostics/build/tests, verifies before declaring done. |
| `explore` | Investigates a topic across code, docs, and the web. Cites every claim and returns numbered findings. |
| `plan-reviewer` | Reviews draft work plans for executability and valid references, returning blockers and notes. Never rewrites plans unless asked. |
| `code-reviewer` | Reviews diffs and completed changes for correctness, quality, and plan fidelity. Never fixes code itself. |
| `git-master` | Handles any git operation: atomic commits, rebase/squash/fixup, and history search (blame, bisect, log -S). |

### Skills

Each agent loads one skill on startup:

- `plan-work` (plan)
- `lead-work` (build)
- `research-topic` (explore)
- `execute-work` (worker)
- `review-plan` (plan-reviewer)
- `review-code` (code-reviewer)
- `git-master` (git-master)

The skill files live in `skills/`, the agent definitions in `agents/`, and the
registration snippet in `opencode.jsonc.snippet` (top-level `agent` key, plus
`skills.paths` entries).

## Install

One command:

```bash
./install.sh --yes
```

Drop `--yes` if you want the interactive confirmation prompt instead.

You can also pin a per-agent model at install time with `--model <agent>=<model>`
(repeat the flag once per agent):

```bash
./install.sh --yes --model plan=anthropic/claude-3-5-sonnet --model build=openai/gpt-4o
```

This writes a `"model"` property into each named agent's entry in the merged
config, equivalent to editing the file by hand (see
[Assigning a model to an agent](#assigning-a-model-to-an-agent)). The agent
name must be one of the pack's 7 agents (`plan`, `worker`, `explore`,
`build`, `plan-reviewer`, `code-reviewer`, `git-master`), and the model
string must be non-empty with no whitespace; anything else is rejected with an
error before anything is installed. Omitting `--model` changes nothing.

By default everything is installed into the active user's
`~/.config/opencode`. To target a different OpenCode config directory instead
— for example a sandbox user's config — pass `--config-dir <path>`:

```bash
./install.sh --yes --config-dir /path/to/sandbox/home/.config/opencode
```

A leading `~` in the path is expanded to your `$HOME`, so
`--config-dir '~/somewhere/.config/opencode'` also works. All install
targets follow the flag: `<path>/agents/`, `<path>/skills/`, and
`<path>/opencode.jsonc` (or an existing `opencode.json`). The value must be
non-empty; a missing or empty value is rejected with a usage error (exit 2)
before anything is installed.

What the installer does:

- Copies the 7 agent files to `<config-dir>/agents/`.
- Copies the 7 skill directories to `<config-dir>/skills/`.
- Merges `opencode.jsonc.snippet` into `<config-dir>/opencode.jsonc` or
  `<config-dir>/opencode.json`, whichever already exists (`.jsonc` is
  preferred when both exist; `.jsonc` is created when neither does).

Here `<config-dir>` is `~/.config/opencode` by default, or the path given
with `--config-dir`.

- **Backs up each existing config file first**, to `<file>.backup-<timestamp>`,
  before writing anything (if both `opencode.jsonc` and `opencode.json` exist,
  both are backed up).

Safety notes: the script refuses to run if `HOME` is unset **and** no
`--config-dir` was given (a `--config-dir` value with a leading `~` still
needs `HOME` to expand), aborts rather than corrupting an unparseable config,
and never deletes the pack's own source files.
Because the merge uses a plain JSON writer, any JSONC comments in your existing
config are lost when the merge runs (the backup keeps the original).

## How to invoke each agent

Every agent except `build` is a subagent, so you invoke it by naming it
in your prompt:

- `@plan` — "Break this feature into a plan."
- `@explore` — "How does the auth flow work in this repo?"
- `@worker` — "Implement step 3 of the plan."
- `@plan-reviewer` — "Review .opencode/plans/my-feature.md for blockers."
- `@code-reviewer` — "Review the diff for this branch."
- `@git-master` — "Commit the current changes atomically."

You can also select any of these as the active agent before typing your
message.

`build` is a **primary agent**, not a subagent: select it as the active
agent first, then give it the work directly, e.g. "Execute the plan at
.opencode/plans/my-feature.md." It orchestrates by delegating to the
`explore` and `worker` subagents; other agents cannot spawn it.

## Example workflow

A typical chain for a medium-sized change:

1. `plan` writes a decision-complete plan to `.opencode/plans/`.
2. `plan-reviewer` audits that plan and returns blockers or approval.
3. `build` picks up the approved plan and coordinates the waves.
4. `explore` answers the open questions the plan flagged.
5. `worker` implements the delegated steps and verifies each one.
6. `code-reviewer` checks the resulting diff for correctness and plan fidelity.
7. `git-master` commits the work atomically in the repo's detected style.

In short: `plan` → `plan-reviewer` → `build` → `explore` →
`worker` → `code-reviewer` → `git-master`.

## Assigning a model to an agent

Every agent in this pack inherits the global default model (the top-level
`"model"` key in your OpenCode config) unless you override it. The quickest
way to set one is the installer's `--model` flag (see
[Install](#install)); to pin one agent to a specific model by hand, edit
`~/.config/opencode/opencode.jsonc` after
installing and add a `"model"` property to that agent's entry under the
top-level `"agent"` key. For example, to make `plan` use a different
model than the rest:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "model": "openai/gpt-4o",
  "agent": {
    "plan": {
      "description": "Plan: turns a request into ONE decision-complete work plan under .opencode/plans/. ...",
      "skill": "plan-work",
      "model": "anthropic/claude-3-5-sonnet"
    }
    // ... other agents unchanged
  }
}
```

Here `plan` gets `anthropic/claude-3-5-sonnet` while every other agent
keeps the global default. Any valid OpenCode model string works, such as
`openai/gpt-4o` or `anthropic/claude-3-5-sonnet`; pick one your OpenCode
installation actually supports (the full list lives in OpenCode's config
schema at `https://opencode.ai/config.json`).

OpenCode reads its config once at startup, so quit and restart OpenCode
after saving the file. The running session will keep using the old model
until then.

## Project artifacts

When the pack's agents run in your project, they write their working artifacts
under `.opencode/` in the project root (not in the global config directory):

- `.opencode/plans/` — decision-complete work plans written by `plan`
- `.opencode/drafts/` — durable planning drafts, the plan agent's resume point
- `.opencode/notepads/` — per-plan learnings, issues, and decisions recorded during execution
- `.opencode/evidence/` — verification evidence saved by `build` and `explore` (command output, screenshots, responses, cited findings)

The agents and skills themselves still install globally to `~/.config/opencode/`;
only these run-time artifacts live in the project.

## Uninstall

```bash
./uninstall.sh --yes
```

To roll back an install that targeted an alternative config directory, pass
the same `--config-dir <path>` (a leading `~` expands to `$HOME`; a missing
or empty value is rejected with a usage error, exit 2):

```bash
./uninstall.sh --yes --config-dir /path/to/sandbox/home/.config/opencode
```

The uninstaller is the exact inverse of the installer:

- Restores the most recent `opencode.jsonc.backup-*` over
  `<config-dir>/opencode.jsonc` and the most recent
  `opencode.json.backup-*` over `<config-dir>/opencode.json`
  (whenever such backups exist).
- Removes only the pack's own 7 agent files and 7 skill directories, by exact
  name. Nothing else in those folders is touched, and the source pack files in
  this directory are never removed.

It also supports interactive confirmation if you omit `--yes`, and it fails
cleanly if `HOME` is unset and no `--config-dir` was given.
