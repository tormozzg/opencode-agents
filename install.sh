#!/usr/bin/env bash
#
# install.sh - Safe global installer for the OpenCode subagents pack.
#
# Installs (into <config-dir>, the OpenCode config directory; by default
# ~/.config/opencode, override with --config-dir <path>):
#   - 10 agent files from ./agents/*.md       -> <config-dir>/agents/
#   - 13 skill directories from ./skills/*    -> <config-dir>/skills/
#   - Merges ./opencode.jsonc.snippet into    -> <config-dir>/opencode.jsonc
#     or <config-dir>/opencode.json (whichever already exists; .jsonc is
#     preferred when both exist, and .jsonc is created when neither does).
#     (each existing config file is backed up first to <file>.backup-<timestamp>)
#
# Safety:
#   - Requires --yes, or interactive confirmation, before touching the config.
#   - Supports --model <agent>=<model> to pin a per-agent model in the merged
#     config (repeatable; agent must be one of the pack's 10 agents).
#   - Supports --default-model <model> to set the top-level default "model"
#     key in the merged config (repeatable, last one wins; when the flag is
#     not given the existing top-level "model" is left untouched).
#   - Supports --config-dir <path> to target an alternative OpenCode config
#     directory (e.g. a sandbox user's config); a leading ~ expands to $HOME.
#   - Fails with an explicit error if HOME is unset or empty (unless
#     --config-dir is given; a leading ~ still needs HOME to expand).
#   - Never deletes source pack files.
#
# NOTE on JSONC: the merge uses Python 3's stdlib `json` module. Any JSONC
# comments present in the user's existing opencode.jsonc are LOST on merge
# (the merged output is pure JSON). The script aborts rather than corrupting
# the file if the existing config cannot be parsed as JSON.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_SRC="${SCRIPT_DIR}/agents"
SKILLS_SRC="${SCRIPT_DIR}/skills"
SNIPPET="${SCRIPT_DIR}/opencode.jsonc.snippet"

ASSUME_YES=0
MODEL_ARGS=()
DEFAULT_MODEL=""
DEFAULT_MODEL_SET=0
CONFIG_DIR_ARG=""
CONFIG_DIR_SET=0
while [ $# -gt 0 ]; do
  case "$1" in
    --yes)
      ASSUME_YES=1
      ;;
    --model)
      if [ $# -lt 2 ]; then
        echo "ERROR: --model requires an argument of the form <agent>=<model>" >&2
        exit 2
      fi
      MODEL_ARGS+=("$2")
      shift
      ;;
    --model=*)
      MODEL_ARGS+=("${1#--model=}")
      ;;
    --default-model)
      if [ $# -lt 2 ]; then
        echo "ERROR: --default-model requires a model argument" >&2
        exit 2
      fi
      DEFAULT_MODEL="$2"
      DEFAULT_MODEL_SET=1
      shift
      ;;
    --default-model=*)
      DEFAULT_MODEL="${1#--default-model=}"
      DEFAULT_MODEL_SET=1
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
      echo "Usage: $0 [--yes] [--model <agent>=<model>]... [--default-model <model>] [--config-dir <path>]" >&2
      exit 2
      ;;
  esac
  shift
done

# --- Validate --model overrides ---------------------------------------------
PACK_AGENTS="plan worker explore team-lead plan-reviewer code-reviewer git-master qa-inspector discuss architect"
MODEL_OVERRIDES=""
for pair in "${MODEL_ARGS[@]}"; do
  agent="${pair%%=*}"
  model="${pair#*=}"
  if [ "${pair}" = "${model}" ] || [ -z "${agent}" ] || [ -z "${model}" ]; then
    echo "ERROR: invalid --model argument '${pair}'; expected <agent>=<model>" >&2
    exit 2
  fi
  case " ${PACK_AGENTS} " in
    *" ${agent} "*) ;;
    *)
      echo "ERROR: unknown agent '${agent}' in --model; valid agents: ${PACK_AGENTS}" >&2
      exit 2
      ;;
  esac
  case "${model}" in
    *[[:space:]]*)
      echo "ERROR: invalid model '${model}' for agent '${agent}': must not contain whitespace" >&2
      exit 2
      ;;
  esac
  MODEL_OVERRIDES+="${agent}=${model}"$'\n'
done

# --- Validate --default-model ------------------------------------------------
# Repeatable with last-one-wins: the parse loop overwrites DEFAULT_MODEL.
if [ "${DEFAULT_MODEL_SET}" -eq 1 ]; then
  if [ -z "${DEFAULT_MODEL}" ]; then
    echo "ERROR: --default-model requires a non-empty model" >&2
    exit 2
  fi
  case "${DEFAULT_MODEL}" in
    *[[:space:]]*)
      echo "ERROR: invalid default model '${DEFAULT_MODEL}': must not contain whitespace" >&2
      exit 2
      ;;
  esac
fi

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

# Target config: prefer an existing opencode.jsonc, then an existing
# opencode.json; default to creating opencode.jsonc when neither exists.
if [ -f "${CONFIG_DIR}/opencode.jsonc" ]; then
  CONFIG_FILE="${CONFIG_DIR}/opencode.jsonc"
elif [ -f "${CONFIG_DIR}/opencode.json" ]; then
  CONFIG_FILE="${CONFIG_DIR}/opencode.json"
else
  CONFIG_FILE="${CONFIG_DIR}/opencode.jsonc"
fi

# --- Source pack sanity -----------------------------------------------------
if [ ! -d "${AGENTS_SRC}" ] || [ -z "$(ls -A "${AGENTS_SRC}"/*.md 2>/dev/null)" ]; then
  echo "ERROR: no agent files found in ${AGENTS_SRC}" >&2
  exit 1
fi
if [ ! -d "${SKILLS_SRC}" ] || [ -z "$(ls -A "${SKILLS_SRC}" 2>/dev/null)" ]; then
  echo "ERROR: no skill directories found in ${SKILLS_SRC}" >&2
  exit 1
fi
if [ ! -f "${SNIPPET}" ]; then
  echo "ERROR: snippet not found: ${SNIPPET}" >&2
  exit 1
fi

# --- Confirmation gate ------------------------------------------------------
if [ "${ASSUME_YES}" -ne 1 ]; then
  echo "This installer will modify your OpenCode global config:"
  echo "  - copy agents into ${CONFIG_DIR}/agents"
  echo "  - copy skills into ${CONFIG_DIR}/skills"
  echo "  - merge opencode.jsonc.snippet into ${CONFIG_FILE}"
  echo "    (a timestamped backup of the existing file is kept)"
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

# --- Install agents ---------------------------------------------------------
mkdir -p "${AGENTS_DST}"
for agent_file in "${AGENTS_SRC}"/*.md; do
  cp "${agent_file}" "${AGENTS_DST}/"
done
echo "Installed agents: $(ls -1 "${AGENTS_DST}" | wc -l) file(s) -> ${AGENTS_DST}"

# --- Install skills ---------------------------------------------------------
mkdir -p "${SKILLS_DST}"
for skill_dir in "${SKILLS_SRC}"/*/; do
  skill_name="$(basename "${skill_dir}")"
  rm -rf "${SKILLS_DST:?}/${skill_name}"
  cp -R "${skill_dir}" "${SKILLS_DST}/${skill_name}"
done
echo "Installed skills: $(ls -1 "${SKILLS_DST}" | wc -l) director(ies) -> ${SKILLS_DST}"

# --- Backup existing config -------------------------------------------------
# Back up the file being merged into (if it exists), and additionally back up
# opencode.json when the merge target is opencode.jsonc, so nothing is lost.
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_FILES=()
if [ -f "${CONFIG_FILE}" ]; then
  BACKUP_FILE="${CONFIG_FILE}.backup-${TIMESTAMP}"
  cp "${CONFIG_FILE}" "${BACKUP_FILE}"
  BACKUP_FILES+=("${BACKUP_FILE}")
  echo "Backup: existing $(basename "${CONFIG_FILE}") -> ${BACKUP_FILE}"
else
  echo "Backup: no existing $(basename "${CONFIG_FILE}") found; nothing to back up."
fi
if [ "${CONFIG_FILE}" != "${CONFIG_DIR}/opencode.json" ] && [ -f "${CONFIG_DIR}/opencode.json" ]; then
  JSON_BACKUP="${CONFIG_DIR}/opencode.json.backup-${TIMESTAMP}"
  cp "${CONFIG_DIR}/opencode.json" "${JSON_BACKUP}"
  BACKUP_FILES+=("${JSON_BACKUP}")
  echo "Backup: existing opencode.json -> ${JSON_BACKUP}"
fi

# --- Merge snippet into config (Python 3 stdlib json) -----------------------
# JSONC comments in the existing file are lost on merge (see header note).
PACK_MODEL_OVERRIDES="${MODEL_OVERRIDES}" PACK_DEFAULT_MODEL="${DEFAULT_MODEL}" python3 - "${SNIPPET}" "${CONFIG_FILE}" <<'PYEOF'
import json
import os
import sys
import tempfile

snippet_path, config_path = sys.argv[1], sys.argv[2]

with open(snippet_path, "r", encoding="utf-8") as f:
    snippet = json.load(f)

existing = {}
if os.path.exists(config_path):
    try:
        with open(config_path, "r", encoding="utf-8") as f:
            existing = json.load(f)
    except (json.JSONDecodeError, OSError) as exc:
        sys.stderr.write(
            "ERROR: existing %s is not valid JSON (%s); aborting merge.\n"
            % (config_path, exc)
        )
        sys.exit(1)
    if not isinstance(existing, dict):
        sys.stderr.write(
            "ERROR: existing %s is not a JSON object; aborting merge.\n" % config_path
        )
        sys.exit(1)

merged = dict(existing)

# Preserve the schema key from the snippet's top-level key `agent` (singular).
# Per-agent entries are merged key-by-key (not replaced wholesale), so user-set
# properties such as "model" survive a re-install; snippet keys win on conflict.
if "agent" in snippet:
    agent_block = dict(existing.get("agent") or {})
    for agent_name, snippet_entry in snippet["agent"].items():
        merged_entry = dict(agent_block.get(agent_name) or {})
        merged_entry.update(snippet_entry)
        agent_block[agent_name] = merged_entry
    merged["agent"] = agent_block

# Merge skills.paths: keep existing entries, add/update snippet entries.
if "skills" in snippet:
    skills_block = dict(existing.get("skills") or {})
    snippet_paths = list((snippet["skills"] or {}).get("paths") or [])
    existing_paths = list(skills_block.get("paths") or [])
    seen = set(existing_paths)
    merged_paths = existing_paths + [p for p in snippet_paths if not (p in seen or seen.add(p))]
    skills_block["paths"] = merged_paths
    merged["skills"] = skills_block

# Apply per-agent model overrides passed via PACK_MODEL_OVERRIDES
# (newline-separated <agent>=<model> entries from --model flags).
raw_overrides = os.environ.get("PACK_MODEL_OVERRIDES", "")
if raw_overrides.strip():
    agent_block = dict(merged.get("agent") or {})
    for line in raw_overrides.splitlines():
        line = line.strip()
        if not line:
            continue
        agent_name, _, model_value = line.partition("=")
        if not agent_name or not model_value:
            sys.stderr.write("ERROR: invalid model override %r\n" % line)
            sys.exit(1)
        entry = dict(agent_block.get(agent_name) or {})
        entry["model"] = model_value
        agent_block[agent_name] = entry
    merged["agent"] = agent_block

# Apply the top-level default model passed via PACK_DEFAULT_MODEL
# (the value of the --default-model flag; empty when the flag was not given,
# in which case the existing top-level "model" key is left untouched).
default_model = os.environ.get("PACK_DEFAULT_MODEL", "")
if default_model:
    merged["model"] = default_model

# Validate the merged result is valid JSON before writing.
payload = json.dumps(merged, indent=2, ensure_ascii=False) + "\n"
json.loads(payload)

fd, tmp_path = tempfile.mkstemp(
    dir=os.path.dirname(config_path) or ".", prefix=".opencode.jsonc.", suffix=".tmp"
)
try:
    with os.fdopen(fd, "w", encoding="utf-8") as f:
        f.write(payload)
    os.replace(tmp_path, config_path)
except BaseException:
    if os.path.exists(tmp_path):
        os.unlink(tmp_path)
    raise

print("Merged config written: %s" % config_path)
PYEOF

if [ $? -ne 0 ]; then
  echo "ERROR: config merge failed; agents/skills were installed but config was not modified." >&2
  exit 1
fi

# --- Summary ----------------------------------------------------------------
echo ""
echo "Install complete."
echo "  Agents : ${CONFIG_DIR}/agents  (from ${AGENTS_SRC})"
echo "  Skills : ${CONFIG_DIR}/skills  (from ${SKILLS_SRC})"
echo "  Config : ${CONFIG_FILE} (merged from opencode.jsonc.snippet)"
if [ -n "${MODEL_OVERRIDES}" ]; then
  while IFS= read -r pair; do
    [ -n "${pair}" ] || continue
    echo "  Model  : ${pair%%=*} -> ${pair#*=}"
  done <<< "${MODEL_OVERRIDES}"
fi
if [ "${DEFAULT_MODEL_SET}" -eq 1 ]; then
  echo "  Model  : (default) -> ${DEFAULT_MODEL}"
fi
if [ "${#BACKUP_FILES[@]}" -gt 0 ]; then
  for backup in "${BACKUP_FILES[@]}"; do
    echo "  Backup : ${backup}"
  done
else
  echo "  Backup : (none - no existing config file)"
fi
echo "Restart opencode for the new config to take effect."
