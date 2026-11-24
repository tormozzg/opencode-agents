# Git Safety Protocol

Andrew Martin owns Git operations through `git-operations`, but ownership does not waive authorization or quality gates.

## Commit gate
A commit is allowed only after:
- the approved scope and plan version are unchanged;
- Han Fastolfe has approved the exact complete diff to be committed;
- Jothan Leebig has returned PASS/PASS WITH NOTES for the exact diff when security review is triggered, with no unresolved blocking findings;
- Golan Trevize has returned QA PASS for the required frozen scenarios against the same implementation state;
- Susan Calvin has verified that the working-tree/index diff has not changed since the required verdicts and authorizes the commit;
- Daniel/user has accepted any material risk or scope decision.

A review approval is stale as soon as any covered file changes. Before committing, compare the staged diff with the reviewed diff (including paths, content, and relevant mode changes). If they differ, stop: obtain fresh review for the changed surface and rerun any affected security/QA checks. Do not infer that a small or documentation-only change is exempt.

## History safety
- Inspect status, branch, upstream, staged and unstaged diffs before destructive Git actions.
- Keep commits atomic and preserve repository message conventions.
- Never force-push or rewrite shared/published history without explicit authorization.
- Rebase/squash/fixup require a clearly stated target and recovery plan.
- Preserve recovery options; use reflog and backups where appropriate.
- Do not discard unrecognized user changes or clean files outside the task scope.
- Stop on unexpected dirty state, conflicts, detached HEAD, or uncertain ownership; report before proceeding.
