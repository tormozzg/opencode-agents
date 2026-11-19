# OpenCode Subagents Pack

A small, self-contained pack for OpenCode that adds ten focused agents and their
matching skills (thirteen in total - ten agent skills plus three extra worker skills). The pack only registers agents and skills; it does not modify
any other plugins, and it never auto-runs plans. Every plan and every code change stays
under your explicit control.

## What's inside

### Agents

| Agent | Role |
|-------|------|
| `plan` | "Plan: the pack's planner - turns a request into ONE brief, decision-complete work plan: bounded size, dependency-annotated task rows, resolved defaults recorded in the plan, acceptance criteria the executor can run. Explores before asking, delegates research to explore only - never dispatches worker, never implements, never starts execution. Runs a mandatory plan-reviewer audit of the written plan before handoff. Use for planning, designing, or breaking down work." |
| `build` | "Build: orchestrates execution of a plan or direct task by delegating everything. Loads the lead-work skill first, routes unclear topics to explore and ready work to worker, verifies every claim, runs a mandatory @code-reviewer review and @qa-inspector QA run before any commit, never writes code. Use for running a plan, coordinating waves, or driving work to completion." |
| `discuss` | "Discuss: a discussion partner that debates code and improvement proposals - grounds the dialogue in facts via @explore and @code-reviewer, critiques constructively, and hands converged outcomes to plan or build. Never edits project files, never builds plans. Use for talking through designs, weighing alternatives, or pressure-testing an idea before planning." |
| `worker` | "Worker: implements delegated tasks silently and verifies before declaring done. Loads the execute-work discipline first, then writes code, runs diagnostics/build/tests, and reports with evidence. Use for any delegated implementation work." |
| `explore` | "Explore: investigates a topic across code, docs, and the web with an evidence-demander stance. Cites every claim, returns numbered concise findings. Use for research, fact-finding, or grounding decisions." |
| `plan-reviewer` | "Plan reviewer: reviews draft work plans for executability and valid references. Loads the review-plan skill first, performs Momus + Metis review, returns blockers and notes. Never rewrites plans unless asked." |
| `code-reviewer` | "Code reviewer: reviews diffs and completed changes for correctness, quality, and plan fidelity. Loads the review-code skill first, classifies the work type, checks blockers vs notes, returns comments or approval. Never fixes code itself." |
| `qa-inspector` | "QA inspector: executes the plan's QA scenarios after code-reviewer approval, runs each scenario's commands for real, saves evidence under .opencode/evidence/<plan-name-or-task-slug>/, and returns per-scenario PASS/FAIL with an ALL PASS / N FAILED summary. Read-only to product code. Never fixes code itself. Use for 'run QA', 'QA gate', or 'прогонить QA-сценарии' requests before a commit." |
| `git-master` | "Git Master: handles atomic commits, rebase/squash/fixup (history rewrite), and history search (blame, bisect, log -S, reflog). Loads the git-master skill first, commits atomically in the pack's fixed commit message format, with the message language detected from history, and protects shared history. Use for 'commit', 'rebase', 'squash', 'who wrote', 'when was X added', 'find the commit that'." |
| `architect` | "Architect: designs the architecture for complex work - a new feature spanning multiple components, a whole project from zero, or server/infrastructure changes. Consulted by the plan agent; analyzes constraints and non-functional requirements, weighs alternatives with trade-offs, records key decisions, risks, and rollout/operations considerations, and writes ONE architecture evidence file under .opencode/evidence/. Read-only to product code: never writes code, never writes plan task rows. Use for 'design the architecture', 'спроектируй архитектуру', or when the planner hands off a complex design." |

### Skills

Each agent loads one skill on startup (the last three have no agent of their
own - `worker` loads them contextually during implementation):

- `plan-work` (plan)
- `lead-work` (build)
- `discuss-work` (discuss)
- `research-topic` (explore)
- `execute-work` (worker)
- `review-plan` (plan-reviewer)
- `review-code` (code-reviewer)
- `qa-inspect` (qa-inspector)
- `git-master` (git-master)
- `architect-work` (architect)
- `code-idiom` (worker, contextually)
- `refactor-code` (worker, contextually)
- `slop-cleanup` (worker, contextually)

The skill files live in `skills/`, the agent definitions in `agents/`, and the
registration snippet in `opencode.jsonc.snippet` (top-level `agent` key, plus
`skills.paths` entries).

### How agents and skills are structured

Each agent definition is intentionally short: it holds the agent's identity
(a couple of sentences) and one hard rule — load your discipline skill first
and follow it for the whole turn. The full operating discipline (gates,
routing rules, templates, checklists, verification bars) lives in the paired
skill file, and only there — instructions are never duplicated between an
agent file and its skill, so every rule is edited in exactly one place.

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
name must be one of the pack's 10 agents (`plan`, `worker`, `explore`,
`build`, `discuss`, `plan-reviewer`, `code-reviewer`, `qa-inspector`, `git-master`, `architect`), and the model
string must be non-empty with no whitespace; anything else is rejected with an
error before anything is installed. Omitting `--model` changes nothing.

You can also set the global default model — the top-level `"model"` key in
the merged config — with `--default-model <model>` (repeat the flag to
change it; the last value wins):

```bash
./install.sh --yes --default-model openai/gpt-4o
```

When the flag is given, the merged config's top-level `"model"` is set to
that value (overwriting any existing one); when it is omitted, the
top-level `"model"` is never touched. The value must be non-empty with no
whitespace; anything else is rejected with an error before anything is
installed.

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

- Copies the 10 agent files to `<config-dir>/agents/`.
- Copies the 13 skill directories to `<config-dir>/skills/`.
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

Three agents in this pack are **primary**: `plan`, `build` and `discuss`. You
select one as the active agent before typing your message; none can be spawned
by other agents. `plan` is primary by OpenCode's built-in default: its agent
file carries no `mode` field — OpenCode's built-in plan mode grants its
primary status. The remaining seven are subagents - you invoke them by naming
them in your prompt:

- `@explore` — "How does the auth flow work in this repo?"
- `@worker` — "Implement step 3 of the plan."
- `@plan-reviewer` — "Review the plan at ~/.opencode/plan/my-feature.md for blockers."
- `@code-reviewer` — "Review the diff for this branch."
- `@qa-inspector` — "Run the QA scenarios from the plan before we commit."
- `@git-master` — "Commit the current changes atomically."
- `@architect` — "Design the architecture for the new notification subsystem."

You can also select any of these as the active agent before typing your
message.

`plan`, `build` and `discuss` are primary agents, not subagents: select one as
the active agent first, then give it the work directly, e.g. "Plan a rate limit
for /login." (plan) or "Execute the plan at ~/.opencode/plan/my-feature.md."
(build). When the topic is not yet a task — say, weighing two approaches for a
migration — pick `discuss` and debate it: "Which of these designs should we
take to planning?" `plan` turns the request into a decision-complete plan and
hands off to implementation; `build` orchestrates by delegating to the `explore`
and `worker` subagents. None can be spawned by other agents. `plan`'s
primary status comes from OpenCode's built-in plan mode by default, so its
agent file has no `mode` field.

## Example workflow

A typical chain for a medium-sized change (optionally preceded by a `discuss`
session that debates the approach and converges on a design before planning):

1. `plan` writes a decision-complete plan and runs the mandatory `plan-reviewer` audit before handoff. For complex work (a new subsystem or feature with many moving parts, a project from zero, or server/infrastructure changes) `plan` first consults `architect`, and the plan references the architecture doc `architect` wrote under `.opencode/evidence/`.
2. `plan-reviewer` audits the plan and returns blockers or approval; `plan` resolves every blocker before handoff, and re-runs the audit after every plan revision - approval binds to the reviewed version.
3. `build` picks up the approved plan and coordinates the waves.
4. `explore` answers the open questions the plan flagged.
5. `worker` implements the delegated steps and verifies each one.
6. `code-reviewer` checks the resulting diff for correctness and plan fidelity.
7. `qa-inspector` runs the plan's QA scenarios for real, saves one evidence file per run, and reports PASS/FAIL; on FAIL, `worker` fixes and the cycle repeats before commit; a FAIL caused by a plan defect goes back to `plan` instead — `plan` revises and re-audits, and the cycle resumes from the revised plan.
8. `git-master` commits the work atomically using the pack's fixed commit message template — see git-master's skill (`skills/git-master/SKILL.md`) for its definition.

In short: `plan` → (`architect` for complex work) → `plan-reviewer` → `build` → `explore` →
`worker` → `code-reviewer` → `qa-inspector` → `git-master`.
A QA FAIL caused by a plan defect loops back from `build` to `plan` for revision and re-audit before execution resumes.

## Assigning a model to an agent

Every agent in this pack inherits the global default model (the top-level
`"model"` key in your OpenCode config) unless you override it. The quickest
way to set the global default is the installer's `--default-model` flag, and
the quickest way to pin a per-agent model is its `--model` flag (see
[Install](#install)); to pin one agent to a specific model by hand, edit
`~/.config/opencode/opencode.jsonc` after
installing and add a `"model"` property to that agent's entry under the
top-level `"agent"` key. For example, to make `plan` use a different
model than the rest (the `description` in this example is abridged, not a
verbatim quote of the agent's description):

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "model": "openai/gpt-4o",
  "agent": {
    "plan": {
      "description": "Plan: the pack's planner - turns a request into ONE decision-complete work plan. ...",
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
in two places — partly in the project root's `.opencode/` (not in the global
config directory), and partly in OpenCode's global Plan directory:

- Plan artifacts (the final plan and the durable draft) are written by `plan` into OpenCode's built-in Plan directory (`~/.opencode/plan`) — the built-in Plan mode restricts the plan agent's writes to that directory.
- `.opencode/notepads/` — per-plan learnings, issues, and decisions recorded during execution
- `.opencode/evidence/<plan-name-or-task-slug>/` — design and verification evidence saved by `explore`, `architect`, `qa-inspector`, and `discuss` (discussion ledgers and citable findings) (one file per run: citable findings, architecture docs, and gate verdicts); `worker` quotes its proof inline in the final report
- `.opencode/tmp/` — temporary/scratch verification files (throwaway repro scripts, one-off test scripts, temp fixtures) created by `worker` and `qa-inspector`; anything temporary created outside `.opencode/` is removed before the work is declared done

The agents and skills themselves still install globally to `~/.config/opencode/`;
run-time artifacts live in the project (`.opencode/`) and in OpenCode's global
Plan directory.

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
- Removes only the pack's own 10 agent files and 13 skill directories, by exact
  name. Nothing else in those folders is touched, and the source pack files in
  this directory are never removed.

It also supports interactive confirmation if you omit `--yes`, and it fails
cleanly if `HOME` is unset and no `--config-dir` was given.
