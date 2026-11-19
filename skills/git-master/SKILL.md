---
name: git-master
description: "MUST USE for ANY git operations: atomic commits, rebase/squash/fixup, and history search (blame, bisect, log -S, reflog). Load it before running git yourself, or pass load_skills=['git-master'] to the task that commits. Triggers: 'commit', 'rebase', 'squash', 'who wrote', 'when was X added', 'find the commit that'."
---

# Git Master

Use this skill when the user asks you to operate on Git history or answer a Git-history question. Be exact, conservative, and evidence-led. Read the repository state before you infer anything: run the mode gate first, then gather ground truth before acting.

## Mode Gate

Classify the request first:

| Mode | Meaning |
|------|---------|
| `COMMIT` | Stage and commit local changes. |
| `REBASE` | Rebase, squash, fixup, autosquash, reorder, split, or otherwise rewrite branch history. |
| `HISTORY` | Answer when, where, who, why, or which commit changed something. |
| `STATUS` | Inspect branch, diff, or working-tree state without changing it. |

Do not commit, rebase, push, force-push, reset, stash-pop, or delete anything unless the user explicitly asked for that operation. When a workflow the user started mandates one of them (ulw-loop commits each verified unit, ulw-execute lands its branches), that workflow's instruction is the ask. If the request is only investigative, report findings and stop.

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
3. Build atomic groups by behavior, module, and revertability. Keep implementation and its direct tests together.
4. Prefer multiple commits for unrelated concerns. A single commit is acceptable only when the changed files form one indivisible behavior or the user explicitly asks for one commit.
5. Stage by path or hunk so each commit contains only its atomic group.
6. Before each commit, verify `git diff --staged --stat` and enough staged diff to prove the group is right.
7. Commit with the template. After each commit, verify `git log -1 --oneline`.

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

Before finishing:

- Run the most relevant verification available for the changed behavior or history operation.
- Report commands that passed and any command you could not run.
- Leave the worktree state explicit.
