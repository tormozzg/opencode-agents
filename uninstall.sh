#!/usr/bin/env bash
#
# uninstall.sh - Safe rollback for the OpenCode subagents pack.
#
# Undoes what install.sh did (from <config-dir>, the OpenCode config
# directory; by default ~/.config/opencode, override with --config-dir <path>):
#   - Restores the most recent <config-dir>/opencode.jsonc.backup-* over
#     <config-dir>/opencode.jsonc and the most recent
#     <config-dir>/opencode.json.backup-* over
#     <config-dir>/opencode.json (whenever such backups exist).
#   - Removes exactly the 7 agent files and 7 skill directories installed
#     by this pack (identified by exact name list below).
#
# Safety:
#   - Requires --yes, or interactive confirmation, before removing anything.
#   - Supports --config-dir <path> to target an alternative OpenCode config
#     directory (e.g. a sandbox user's config); a leading ~ expands to $HOME.
#   - Fails with an explicit error if HOME is unset or empty (unless
#     --config-dir is given; a leading ~ still needs HOME to expand).
#   - Never removes the agents/ or skills/ directories themselves, so any
#     user-created files there are preserved.
#   - Does not fail if some of the pack's files are already missing.
#   - Never touches source pack files in this directory.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ASSUME_YES=0
CONFIG_DIR_ARG=""
CONFIG_DIR_SET=0
while [ $# -gt 0 ]; do
  case "$1" in
    --yes)
      ASSUME_YES=1
      ;;
    --config-dir)
      if [ $# -lt 2 ]; then
        echo "ERROR: --config-dir requires a path argument" >&2
        exit 2
      fi
      CONFIG_DIR_ARG="$2"
      CONFIG_DIR_SET=1
      shift
      ;;
    --config-dir=*)
      CONFIG_DIR_ARG="${1#--config-dir=}"
      CONFIG_DIR_SET=1
      ;;
    *)
      echo "Usage: $0 [--yes] [--config-dir <path>]" >&2
      exit 2
      ;;
  esac
  shift
done

# --- Validate --config-dir ---------------------------------------------------
if [ "${CONFIG_DIR_SET}" -eq 1 ] && [ -z "${CONFIG_DIR_ARG}" ]; then
  echo "ERROR: --config-dir requires a non-empty path" >&2
  exit 2
fi

# --- Determine the target config directory -----------------------------------
# Default: the active user's ~/.config/opencode (requires HOME to be set).
# With --config-dir <path>: that path, with a leading ~ expanded to $HOME
# (so an unset HOME only matters when the default path or a ~ is used).
if [ "${CONFIG_DIR_SET}" -eq 1 ]; then
  CONFIG_DIR="${CONFIG_DIR_ARG}"
  case "${CONFIG_DIR}" in
    '~'|'~'/*)
      if [ -z "${HOME:-}" ]; then
        echo "ERROR: cannot expand '~' in --config-dir: HOME is unset or empty." >&2
        exit 1
      fi
      CONFIG_DIR="${HOME}${CONFIG_DIR#'~'}"
      ;;
  esac
else
  if [ -z "${HOME:-}" ]; then
    echo "ERROR: HOME is unset or empty; cannot determine config directory." >&2
    exit 1
  fi
  CONFIG_DIR="${HOME}/.config/opencode"
fi

AGENTS_DST="${CONFIG_DIR}/agents"
SKILLS_DST="${CONFIG_DIR}/skills"
CONFIG_JSONC="${CONFIG_DIR}/opencode.jsonc"
CONFIG_JSON="${CONFIG_DIR}/opencode.json"

# --- Exact name lists (only these are removed; nothing else) ----------------
AGENT_FILES=(
  plan.md
  worker.md
  explore.md
  build.md
  plan-reviewer.md
  code-reviewer.md
  git-master.md
)

SKILL_DIRS=(
  plan-work
  lead-work
  research-topic
  execute-work
  review-plan
  review-code
  git-master
)

# --- Confirmation gate ------------------------------------------------------
if [ "${ASSUME_YES}" -ne 1 ]; then
  echo "This uninstaller will modify your OpenCode global config:"
  echo "  - restore the most recent opencode.jsonc.backup-* over ${CONFIG_JSONC}"
  echo "    and the most recent opencode.json.backup-* over ${CONFIG_JSON}"
  echo "    (whenever such backups exist; the backup files themselves are kept)"
  echo "  - remove these agent files from ${AGENTS_DST}:"
  echo "      ${AGENT_FILES[*]}"
  echo "  - remove these skill directories from ${SKILLS_DST}:"
  echo "      ${SKILL_DIRS[*]}"
  echo "  - leave everything else (including user-created files) untouched."
  printf 'Proceed? [yes/N] '
  read -r REPLY
  case "${REPLY}" in
    [yY]|[yY][eE][sS]) ;;
    *)
      echo "Aborted. No changes were made."
      exit 1
      ;;
  esac
fi

REMOVED_AGENTS=0
REMOVED_SKILLS=0

# --- Restore configs from the most recent backups ---------------------------
# Lexicographic max == chronological max because the timestamp format
# (YYYYmmdd-HHMMSS) sorts correctly as a string.
restore_latest() {
  local config_file="$1"
  local backup_glob="$2"
  local latest=""
  local candidate
  for candidate in ${backup_glob}; do
    [ -f "${candidate}" ] || continue
    if [ -z "${latest}" ] || [[ "${candidate}" > "${latest}" ]]; then
      latest="${candidate}"
    fi
  done
  if [ -n "${latest}" ]; then
    cp "${latest}" "${config_file}"
    echo "Restored config: ${latest} -> ${config_file}"
  else
    echo "No backup found (${backup_glob}); ${config_file} left as-is."
  fi
}

restore_latest "${CONFIG_JSONC}" "${CONFIG_DIR}/opencode.jsonc.backup-*"
restore_latest "${CONFIG_JSON}" "${CONFIG_DIR}/opencode.json.backup-*"

# --- Remove the 7 agent files (by exact name; tolerate missing) -------------
for name in "${AGENT_FILES[@]}"; do
  if [ -f "${AGENTS_DST}/${name}" ]; then
    rm -f "${AGENTS_DST}/${name}"
    REMOVED_AGENTS=$((REMOVED_AGENTS + 1))
  fi
done

# --- Remove the 7 skill directories (by exact name; tolerate missing) -------
for name in "${SKILL_DIRS[@]}"; do
  if [ -d "${SKILLS_DST}/${name}" ]; then
    rm -rf "${SKILLS_DST:?}/${name}"
    REMOVED_SKILLS=$((REMOVED_SKILLS + 1))
  fi
done

# --- Summary ----------------------------------------------------------------
echo ""
echo "Uninstall complete."
echo "  Agents : ${REMOVED_AGENTS}/7 file(s) removed from ${AGENTS_DST}"
echo "  Skills : ${REMOVED_SKILLS}/7 director(ies) removed from ${SKILLS_DST}"
echo "User-created files in ${AGENTS_DST} and ${SKILLS_DST} were preserved."
echo "Restart opencode for the restored config to take effect."
