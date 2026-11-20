---
name: codegraph-sync
description: "Initialize and refresh the codegraph MCP index for a project: first-use initialization of the code graph, incremental reindex after code or doc changes, targeted file/directory indexing, force full reindex only when the graph is stale or corrupted, and when to do nothing. Load before any codegraph_* tool use, when graph results look stale or miss new symbols, and after branch switches, pulls, or refactors."
---

# Codegraph Sync

**The graph is only as good as its last index.** Codegraph answers (symbol search, call graphs, impact analysis, design verification) are computed from an index built once and then updated explicitly — a stale index silently returns wrong facts about the code. This skill governs when to initialize the index, when to update it, and when to leave it alone.

## Availability check

- **If no `codegraph_*` tools are exposed in the session, the MCP server is not configured — stop and say so.** Tell the user to add the codegraph server under the `mcp` key of their opencode config (`~/.config/opencode/opencode.jsonc`) and restart opencode; do not guess install commands or invent a server command.
- Do not work around a missing server by grepping "instead of codegraph" silently — say plainly that the graph tools are unavailable.

## Initialize (first use in a project)

- **Bring the graph current with one incremental `codegraph_reindex_workspace`** (default mode, no `force`). Incremental re-parses only files changed since the last index, so it is cheap — and its report doubles as a status check: an empty graph means first run, a report of changed files means the index existed but was stale, a no-op means it was already current.
- **Index the code, then the docs.** After the workspace, list indexed docs with `codegraph_list_doc_sources` and add project design docs (`ARCHITECTURE.md`, API specs, decision records) with `codegraph_index_markdown` when symbol or design verification is expected. Re-index the same path after the doc changes (re-indexing replaces previous chunks).
- New source directories outside the workspace root (vendored kernels, sibling libraries) go in via `codegraph_index_directory` — set `embed=true` only for code you will similarity-search; leave `embed=false` for reference-only code.

## Update triggers

| Trigger | Action |
|---|---|
| You (or a delegated worker) created, edited, or deleted a few files | `codegraph_index_files` for exactly those paths |
| Many files changed, or the set is unknown | incremental `codegraph_reindex_workspace` |
| Branch switch, pull, rebase, stash, checkout of an older state | incremental `codegraph_reindex_workspace` |
| Design doc edited and it matters for the next step | `codegraph_index_markdown` on that path |
| Refactor landed that renamed/moved many symbols, results look stale or miss new symbols, or the graph looks corrupted | `codegraph_reindex_workspace` with `force=true` |

- **Every trigger above fires before graph-dependent work, not after.** Update first, then search — searching a stale index to "save time" answers questions about code that no longer exists.
- **Incremental is the default; `force=true` is a declared exception.** Say in one sentence why the full re-parse is needed; it clears and re-parses everything.

## When to do nothing

- Nothing changed since the last index and results are trustworthy — do not reindex to "be safe"; incremental or not, a no-op call is wasted work.
- A graph fact about code you just edited reads as stale: reindex the touched files first, then re-ask. Never present a pre-edit graph fact as current.
- Generated or third-party trees (`node_modules`, `vendor`, build output) are never indexed deliberately; if they leak into results, scope queries to real source paths.

## Boundaries

- This skill owns the index lifecycle only. Reading the graph (`symbol_search`, call graphs, `verify_design`, memories) follows the task at hand; memories stored via `codegraph_memory_store` follow whatever discipline the calling agent's skill defines.
- Initialization and updates are side-effect-light index maintenance, not code changes — they need no review, no evidence file, and no QA run.
