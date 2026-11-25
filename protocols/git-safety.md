# Git Safety Protocol

Hugo Amaryl owns Git operations through `git-operations`, but ownership does not waive the quality gates or the limits on history-changing operations.

## Commit gate
A commit of the final cohesive Daniel-coordinated implementation scope is allowed only after:
- the approved scope and plan version (or direct-task scope) are unchanged;
- Han Fastolfe has approved the exact complete diff to be committed;
- Jothan Leebig has returned PASS/PASS WITH NOTES for the exact diff when security review is triggered, with no unresolved blocking findings;
- Golan Trevize has returned QA ALL PASS for the required frozen scenarios against the same implementation state;
- Hugo has verified that the staged candidate matches the exact reviewed and tested candidate, including paths, content, and relevant mode changes.

Daniel coordinates and must explicitly dispatch Hugo a separate final Git task to perform the exact-candidate check and commit. No separate Daniel, Hari, or user commit authorization is required after these gates pass. Do not commit each implementation subtask by default. Hugo returns the commit hash and final status. If the candidate differs from the reviewed/tested state, stop and obtain fresh affected verdicts before committing.

A review approval is stale as soon as any covered file changes. Before committing, compare the staged diff with the reviewed diff (including paths, content, and relevant mode changes). If they differ, stop: obtain fresh review for the changed surface and rerun any affected security/QA checks. Do not infer that a small or documentation-only change is exempt.

Push to any remote always requires the user's explicit authorization. Merge, rebase/squash/fixup, shared-history rewrite, force-push, and worktree/branch cleanup remain separate operations governed by their own explicit authorization rules. Never commit directly to `main` during migration work.

## History safety
- Inspect status, branch, upstream, staged and unstaged diffs before destructive Git actions.
- Keep commits atomic and preserve repository message conventions.
- Never force-push or rewrite shared/published history without explicit authorization.
- Rebase/squash/fixup require a clearly stated target and recovery plan.
- Preserve recovery options; use reflog and backups where appropriate.
- Do not discard unrecognized user changes or clean files outside the task scope.
- Stop on unexpected dirty state, conflicts, detached HEAD, or uncertain ownership; report before proceeding.
