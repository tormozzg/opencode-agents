---
name: git-operations
description: "MUST USE for atomic commits, rebase/squash/fixup, and history search (blame, bisect, log -S, reflog). Load this skill before running any Git operation. It is Andrew Martin's own skill, not a separately registered agent. Triggers: 'commit', 'rebase', 'squash', 'who wrote', 'when was X added', 'find the commit that'."
---

# Git Operations

Use this skill when the user asks you to operate on Git history or answer a Git-history question. Be exact, conservative, and evidence-led. Read the repository state before you infer anything: run the mode gate first, then gather ground truth before acting.

## Mode Gate

Classify the request first:

| Mode | Meaning |
|------|---------|
| `COMMIT` | Stage and commit local changes. |
| `REBASE` | Rebase, squash, fixup, autosquash, reorder, split, or otherwise rewrite branch history. |
| `HISTORY` | Answer when, where, who, why, or which commit changed something. |
| `STATUS` | Inspect branch, diff, or working-tree state without changing it. |

Do not perform a Git write operation unless this skill's applicable gate permits it. In Foundation AI, Andrew commits the final cohesive implementation scope autonomously after Han Fastolfe's independent code-review approval, Jothan Leebig's security verdict when triggered, Golan Trevize's QA PASS, and confirmation that the staged candidate exactly matches the reviewed and tested candidate. Daniel coordinates the full scope and gates but does not separately authorize the commit. Do not commit each implementation subtask by default; commit at the end of the coordinated scope. Push to any remote, including tags and force-pushes, requires the user's explicit authorization. Rebase or other history rewrites require separate explicit authorization and must obey the shared-history golden rule. Reset, stash-pop, and deletion remain subject to their applicable safety/authorization requirements. Material risk or scope decisions escalate to Hari Seldon/user. If the request is only investigative, report findings and stop.

## Ground Truth

Gather independent facts in parallel when the tools allow it:

```bash
git status --short
git diff --stat
git diff --staged --stat
git branch --show-current
git log -30 --oneline
git log -30 --pretty=format:%s
git rev-parse --abbrev-ref @{upstream}
git merge-base HEAD origin/main
git merge-base HEAD origin/master
```

Missing upstream or missing `main`/`master` is normal. Fall back to the best available branch or report the missing fact. Never treat a failed lookup as proof.

## Commit Mode

Commit only the user's requested changes. Preserve unrelated dirty work.

1. Apply the commit message template (see below). The format is fixed; detect only the message language from recent history and match the repo's dominant language.
2. Inspect the full diff, not only filenames. Separate unrelated user edits from the requested commit.
3. Scan the staged diff for secrets, credentials, and tokens before every commit. If any are found, stop, report them to the user or orchestrator, and do not commit.
4. Build atomic groups by behavior, module, and revertability. Keep implementation and its direct tests together.
5. Prefer multiple commits for unrelated concerns. A single commit is acceptable only when the changed files form one indivisible behavior or the user explicitly asks for one commit.
6. Stage by path or hunk so each commit contains only its atomic group.
7. Before each commit, verify `git diff --staged --stat` and enough staged diff to prove the group is right.
8. Commit with the template. After each commit, verify `git log -1 --oneline`.

### Commit message template

Every commit message follows this fixed format:

```
<type>: <short description>

<short body>
```

- `<type>` is exactly one of: `feat`, `fix`, `chore`, `docs`, `refactor`, `cicd`, `test`. Use these exact spellings — no `refactoring` or `ci`. If none fits the change, pick the closest one.
- `<short description>` is at most 100 characters.
- One blank line, then `<short body>`: a more detailed but still brief description, without deep details.
- The template fixes the format only. Write the message text in the repo's or user's dominant language.

Grouping rules:

- Split different features, modules, generated artifacts, config, docs, and test-only changes unless they are inseparable.
- Keep generated files with the source change that produced them when omitting them would leave the repo inconsistent.
- Never hide failing or unrelated changes inside a broad commit.

Final report: list commit hashes, messages, and any remaining uncommitted files.

## Rebase Mode

History rewriting is a shared-impact operation.

Golden rule (the rebase golden rule): rewrite only history you own. Never rewrite commits that may already be pushed or shared without the user's explicit instruction and a confirmed recovery path.

- Never rebase or rewrite `main`, `master`, `dev`, release branches, or a protected branch unless the user explicitly named that exact operation.
- If commits may already be pushed, ask before force-pushing. Use `--force-with-lease`, never plain `--force`.
- If the worktree is dirty, preserve it intentionally before rebasing. Do not stash-pop over conflicts without checking what changed.
- For fixups, prefer `git commit --fixup=<hash>` followed by `GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash <base>`.
- For conflicts, read the conflicting files and resolve by intent. Do not choose ours/theirs blindly.
- If a rebase goes wrong, use `git rebase --abort` first. Use reflog only after explaining the recovery path.

After rewriting, run the relevant tests or at least the project's cheapest smoke check, then show the new branch log from base to HEAD.

## History Mode

Choose the Git tool by the question:

- `git log -S "text"`: when the count of an exact string changed.
- `git log -G "regex"`: when diffs touched lines matching a pattern.
- `git blame -L start,end -- file`: who last changed specific lines.
- `git log --follow -- file`: history across renames for one file.
- `git show <hash>`: inspect the commit that appears relevant.
- `git bisect`: find the first bad commit when there is a deterministic pass/fail command and known good/bad bounds.
- `git reflog`: recover or explain recent local history movement.

Always cite the exact command evidence in the answer: commit hash, subject, file path, and line or diff context when relevant. If the evidence is ambiguous, say what remains unproven.

## Safety Checks

Before any write to Git history:

- Current branch is known.
- Dirty work is accounted for.
- Upstream/pushed status is known or explicitly unknown.
- The operation matches the user's request.
- Recovery path is known (`rebase --abort`, reflog hash, or untouched worktree).
- Pre-commit/pre-push hooks are not bypassed (`--no-verify`) without the user's explicit request.

Before finishing:

- Run the most relevant verification available for the changed behavior or history operation.
- Report commands that passed and any command you could not run.
- Leave the worktree state explicit.


## Worktree operations

Andrew Martin owns the complete worktree lifecycle when delegated by Daniel: create the requested `.worktrees/<name>` directory and `wt/<name>` branch before implementation, verify with `git worktree list` and `git branch --show-current`, report exact paths, and preserve the worktree on failure. Remove a worktree or delete its branch only after Daniel confirms the run is complete and all applicable quality gates and explicit cleanup authorization are satisfied. Never merge into `main` merely because a worktree task is complete. Daniel coordinates but must not execute Git commands or create/manage worktrees.

## Foundation AI integration

- Owner: Andrew Martin. Git ownership is consolidated with implementation, but Git actions remain distinct modes and must follow this skill's COMMIT / REBASE / HISTORY / STATUS gates.
- Commit the final cohesive implementation scope autonomously only after Han Fastolfe's independent approval, Jothan Leebig's security verdict when triggered, Golan Trevize's QA PASS, and the exact-candidate check below. Daniel coordinates the gates but does not separately authorize the commit. No per-subtask commits by default. Push to any remote requires the user's explicit authorization.
- Andrew may investigate history and report Git status without a commit. Rebase/squash/fixup operations that rewrite history require separate explicit authorization and must follow the golden rule; never rewrite shared/published history without explicit approval.
- Keep commits atomic and use the source-defined message format and language convention. Preserve reflog and recovery safety.
- Do not treat being both implementer and Git operator as permission to waive independent review. Andrew cannot review or QA his own implementation.
## Foundation AI exact-candidate commit check

Before COMMIT, identify the exact approved plan version and the candidate diff reviewed by Han (and Jothan when triggered) and tested by Golan. Inspect staged, unstaged, and untracked changes; ensure no path or content/mode change has appeared since those verdicts. The staged commit content must match the reviewed candidate exactly. If the index differs, do not commit: route the new complete candidate for affected independent review and QA/security retest. Never treat a review of only the incremental patch as approval of the final staged tree. Record the candidate identity and reviewer verdict references in the commit handoff. Do not stage unrelated or unrecognized user changes.
