# Git Safety Protocol

Andrew Martin owns Git operations through `git-operations`, but ownership does not waive authorization or quality gates.

## Commit gate
A commit is allowed only after:
- approved scope and plan version are unchanged;
- Han Fastolfe returns an approving code-review verdict;
- Jothan Leebig returns PASS/PASS WITH NOTES when security review is triggered, with no unresolved blocking findings;
- Golan Trevize returns QA PASS for all required frozen scenarios;
- Susan Calvin authorizes the commit;
- Daniel/user has accepted any material risk or scope decision.

## History safety
- Inspect status, branch, upstream, and diff before destructive Git actions.
- Keep commits atomic and preserve repository message conventions.
- Never force-push or rewrite shared/published history without explicit authorization.
- Rebase/squash/fixup require a clearly stated target and recovery plan.
- Preserve recovery options; use reflog and backups where appropriate.
- Do not discard unrecognized user changes or clean files outside the task scope.
- Stop on unexpected dirty state, conflicts, detached HEAD, or uncertain ownership; report before proceeding.
