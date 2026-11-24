#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
CONFIG_DIR="${HOME:-}/.config/opencode"
ASSUME_YES=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --yes) ASSUME_YES=1 ;;
    --config-dir)
      [[ $# -ge 2 && -n "$2" ]] || { echo "ERROR: --config-dir requires a path" >&2; exit 2; }
      CONFIG_DIR="$2"; shift ;;
    --config-dir=*) CONFIG_DIR="${1#*=}" ;;
    *) echo "Usage: bash foundation-ai/install.sh [--yes] [--config-dir PATH]" >&2; exit 2 ;;
  esac
  shift
done

[[ -n "$CONFIG_DIR" ]] || { echo "ERROR: empty config directory" >&2; exit 2; }
case "$CONFIG_DIR" in
  "~") [[ -n "${HOME:-}" ]] || { echo "ERROR: HOME required to expand ~" >&2; exit 1; }; CONFIG_DIR="$HOME" ;;
  "~/"*) [[ -n "${HOME:-}" ]] || { echo "ERROR: HOME required to expand ~" >&2; exit 1; }; CONFIG_DIR="$HOME/${CONFIG_DIR#~/}" ;;
esac

AGENT_SRC="$ROOT/.opencode/agents"
SKILL_SRC="$ROOT/.opencode/skills"
PROTOCOL_SRC="$ROOT/.opencode/protocols"
FRAGMENT_SRC="$SCRIPT_DIR/opencode.jsonc.fragment"
STATE_DIR="$CONFIG_DIR/foundation-ai"
MANIFEST="$STATE_DIR/manifest.txt"
POINTER="$STATE_DIR/last-backup"

[[ -d "$AGENT_SRC" && -d "$SKILL_SRC" && -d "$PROTOCOL_SRC" && -f "$FRAGMENT_SRC" ]] || {
  echo "ERROR: Foundation AI source files are incomplete." >&2; exit 1;
}

mkdir -p "$CONFIG_DIR"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$STATE_DIR/backups/$TIMESTAMP"
STAGE_DIR="$CONFIG_DIR/.foundation-ai-stage-$TIMESTAMP"
mkdir -p "$BACKUP_DIR" "$STAGE_DIR"

declare -a RELS=()
while IFS= read -r f; do RELS+=("agents/$f"); done < <(find "$AGENT_SRC" -maxdepth 1 -type f -name '*.md' -printf '%f\n' | sort)
while IFS= read -r d; do RELS+=("skills/$d"); done < <(find "$SKILL_SRC" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)
while IFS= read -r f; do RELS+=("foundation-ai/protocols/$f"); done < <(find "$PROTOCOL_SRC" -maxdepth 1 -type f -name '*.md' -printf '%f\n' | sort)
RELS+=("foundation-ai/opencode.jsonc.fragment")

declare -A PREVIOUS=()
if [[ -f "$MANIFEST" ]]; then
  while IFS= read -r rel; do [[ -n "$rel" ]] && PREVIOUS["$rel"]=1; done < "$MANIFEST"
fi

# Stage all payloads before touching the destination.
for rel in "${RELS[@]}"; do
  target="$CONFIG_DIR/$rel"
  if [[ -e "$target" && -z "${PREVIOUS[$rel]+x}" ]]; then
    echo "ERROR: refusing to overwrite unowned path: $target" >&2
    echo "Move it yourself or back it up and remove it before installing." >&2
    rm -rf "$STAGE_DIR" "$BACKUP_DIR"
    exit 1
  fi
  mkdir -p "$(dirname "$STAGE_DIR/$rel")"
  case "$rel" in
    agents/*) cp "$AGENT_SRC/${rel#agents/}" "$STAGE_DIR/$rel" ;;
    skills/*) cp -R "$SKILL_SRC/${rel#skills/}" "$STAGE_DIR/$rel" ;;
    foundation-ai/protocols/*) cp "$PROTOCOL_SRC/${rel#foundation-ai/protocols/}" "$STAGE_DIR/$rel" ;;
    foundation-ai/opencode.jsonc.fragment) cp "$FRAGMENT_SRC" "$STAGE_DIR/$rel" ;;
  esac
done

if [[ "$ASSUME_YES" -ne 1 ]]; then
  echo "Install 9 agents, 14 skills, 6 protocols, and a config fragment into:"
  echo "  $CONFIG_DIR"
  echo "Existing Foundation AI-managed paths will be backed up to:"
  echo "  $BACKUP_DIR"
  echo "Existing paths not recorded as Foundation AI-managed will NOT be overwritten."
  read -r -p "Proceed? [yes/N] " reply
  [[ "$reply" == "yes" || "$reply" == "YES" ]] || { rm -rf "$STAGE_DIR" "$BACKUP_DIR"; echo "Aborted."; exit 1; }
fi

declare -a DONE=()
rollback() {
  local rel
  for ((i=${#DONE[@]}-1; i>=0; i--)); do
    rel="${DONE[$i]}"
    rm -rf "$CONFIG_DIR/$rel"
    if [[ -e "$BACKUP_DIR/$rel" ]]; then
      mkdir -p "$(dirname "$CONFIG_DIR/$rel")"
      mv "$BACKUP_DIR/$rel" "$CONFIG_DIR/$rel"
    fi
  done
  rm -rf "$STAGE_DIR"
}
trap 'rollback' ERR INT TERM

for rel in "${RELS[@]}"; do
  target="$CONFIG_DIR/$rel"
  mkdir -p "$(dirname "$target")"
  if [[ -e "$target" ]]; then
    mkdir -p "$(dirname "$BACKUP_DIR/$rel")"
    mv "$target" "$BACKUP_DIR/$rel"
  fi
  mv "$STAGE_DIR/$rel" "$target"
  DONE+=("$rel")
done

# Atomically replace the ownership manifest and backup pointer.
mkdir -p "$STATE_DIR"
printf '%s\n' "${RELS[@]}" > "$STAGE_DIR/manifest.txt"
printf '%s\n' "$BACKUP_DIR" > "$STAGE_DIR/last-backup"
mv "$STAGE_DIR/manifest.txt" "$MANIFEST"
mv "$STAGE_DIR/last-backup" "$POINTER"
rm -rf "$STAGE_DIR"
trap - ERR INT TERM

echo "Foundation AI files installed."
echo "Config fragment: $CONFIG_DIR/foundation-ai/opencode.jsonc.fragment"
echo "Merge default_agent and subagent_depth into your existing opencode.jsonc manually."
echo "Restart OpenCode after merging the config fragment."
