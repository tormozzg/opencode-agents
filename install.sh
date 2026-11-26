#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$SCRIPT_DIR"
CONFIG_DIR="${HOME:-}/.config/opencode"
ASSUME_YES=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --yes) ASSUME_YES=1 ;;
    --config-dir)
      [[ $# -ge 2 && -n "$2" ]] || { echo "ERROR: --config-dir requires a path" >&2; exit 2; }
      CONFIG_DIR="$2"; shift ;;
    --config-dir=*) CONFIG_DIR="${1#*=}" ;;
    *) echo "Usage: bash install.sh [--yes] [--config-dir PATH]" >&2; exit 2 ;;
  esac
  shift
done

[[ -n "$CONFIG_DIR" ]] || { echo "ERROR: empty config directory" >&2; exit 2; }
if [[ "$CONFIG_DIR" == "~" || "$CONFIG_DIR" == "~/"* ]]; then
  [[ -n "${HOME:-}" ]] || { echo "ERROR: HOME required to expand ~" >&2; exit 1; }
  if [[ "$CONFIG_DIR" == "~" ]]; then CONFIG_DIR="$HOME"; else CONFIG_DIR="$HOME/${CONFIG_DIR:2}"; fi
fi

AGENT_SRC="$ROOT/agents"
SKILL_SRC="$ROOT/skills"
PROTOCOL_SRC="$ROOT/protocols"
FRAGMENT_SRC="$ROOT/opencode.jsonc.fragment"
mkdir -p "$CONFIG_DIR"
CONFIG_DIR="$(cd "$CONFIG_DIR" && pwd -P)"
STATE_DIR="$CONFIG_DIR/.foundation-ai-state"
OWNER_MARKER="$STATE_DIR/owner"
MANIFEST="$STATE_DIR/manifest.txt"
POINTER="$STATE_DIR/last-backup"
ORIGIN="$STATE_DIR/original-backup"

[[ -d "$AGENT_SRC" && -d "$SKILL_SRC" && -d "$PROTOCOL_SRC" && -f "$FRAGMENT_SRC" ]] || {
  echo "ERROR: Foundation AI source files are incomplete." >&2; exit 1;
}

[[ ! -L "$STATE_DIR" ]] || { echo "ERROR: refusing symlink state directory: $STATE_DIR" >&2; exit 1; }
[[ ! -L "$OWNER_MARKER" && ! -L "$MANIFEST" && ! -L "$POINTER" && ! -L "$ORIGIN" ]] || { echo "ERROR: refusing symlink installer state files" >&2; exit 1; }
if [[ -e "$STATE_DIR" && ! -f "$OWNER_MARKER" ]]; then
  echo "ERROR: refusing to use existing unowned state directory: $STATE_DIR" >&2; exit 1
fi
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR=""
STATE_DIR_EXISTED=0
[[ ! -e "$STATE_DIR" ]] || STATE_DIR_EXISTED=1
STAGE_DIR="$(mktemp -d "$CONFIG_DIR/.foundation-ai-stage-$TIMESTAMP.XXXXXX")"

declare -a RELS=()
shopt -s nullglob
for f in "$AGENT_SRC"/*.md; do [[ -f "$f" ]] && RELS+=("agents/$(basename "$f")"); done
for d in "$SKILL_SRC"/*; do [[ -d "$d" ]] && RELS+=("skills/$(basename "$d")"); done
for f in "$PROTOCOL_SRC"/*.md; do [[ -f "$f" ]] && RELS+=("foundation-ai/protocols/$(basename "$f")"); done
RELS+=("foundation-ai/opencode.jsonc.fragment")

is_previous() {
  [[ -f "$MANIFEST" ]] && grep -Fqx "$1" "$MANIFEST"
}

assert_safe_parents() {
  local rel="$1" current="$CONFIG_DIR" part
  local -a parts=()
  IFS='/' read -r -a parts <<< "$rel"
  for ((i=0; i<${#parts[@]}-1; i++)); do
    part="${parts[$i]}"
    current="$current/$part"
    [[ ! -L "$current" ]] || { echo "ERROR: refusing symlink parent directory: $current" >&2; return 1; }
    [[ ! -e "$current" || -d "$current" ]] || { echo "ERROR: expected directory but found non-directory: $current" >&2; return 1; }
  done
}

preflight_cleanup() {
  local status=$?
  trap - ERR INT TERM
  [[ -z "$STAGE_DIR" ]] || rm -rf "$STAGE_DIR"
  if [[ -n "$BACKUP_DIR" ]]; then rm -rf "$BACKUP_DIR"; fi
  if [[ "$STATE_DIR_EXISTED" -eq 0 ]]; then rm -rf "$STATE_DIR"; fi
  exit "$status"
}
trap preflight_cleanup ERR INT TERM

# Preflight all collisions and stage every source before changing installed files.
for rel in "${RELS[@]}"; do
  assert_safe_parents "$rel"
  target="$CONFIG_DIR/$rel"
  if [[ ( -e "$target" || -L "$target" ) ]] && ! is_previous "$rel"; then
    echo "ERROR: refusing to overwrite unowned path: $target" >&2
    echo "Move it yourself or back it up and remove it before installing." >&2
  [[ -n "$STAGE_DIR" ]] && rm -rf "$STAGE_DIR"
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
  agent_count="$(find "$AGENT_SRC" -maxdepth 1 -type f -name '*.md' | wc -l | tr -d ' ')"
skill_count="$(find "$SKILL_SRC" -mindepth 2 -maxdepth 2 -type f -name 'SKILL.md' | wc -l | tr -d ' ')"
protocol_count="$(find "$PROTOCOL_SRC" -maxdepth 1 -type f -name '*.md' | wc -l | tr -d ' ')"
echo "Install $agent_count agents, $skill_count skills, $protocol_count protocols, and a config fragment into:"
  echo "  $CONFIG_DIR"
  echo "Existing Foundation AI-managed paths will be backed up to:"
  echo "  $STATE_DIR/backups/"
  echo "Unowned paths will NOT be overwritten."
  read -r -p "Proceed? [yes/N] " reply
  [[ "$reply" == "yes" || "$reply" == "YES" ]] || { rm -rf "$STAGE_DIR"; echo "Aborted."; exit 1; }
fi

[[ ! -L "$STATE_DIR/backups" ]] || { echo "ERROR: refusing symlink backup directory" >&2; exit 1; }
mkdir -p "$STATE_DIR/backups"
BACKUP_DIR="$(mktemp -d "$STATE_DIR/backups/$TIMESTAMP.XXXXXX")"
printf 'foundation-ai-managed-v1\n' > "$OWNER_MARKER"
mkdir -p "$BACKUP_DIR/.state"
[[ ! -f "$MANIFEST" ]] || cp "$MANIFEST" "$BACKUP_DIR/.state/manifest.txt"
[[ ! -f "$POINTER" ]] || cp "$POINTER" "$BACKUP_DIR/.state/last-backup"
[[ ! -f "$ORIGIN" ]] || cp "$ORIGIN" "$BACKUP_DIR/.state/original-backup"
[[ ! -f "$OWNER_MARKER" ]] || cp "$OWNER_MARKER" "$BACKUP_DIR/.state/owner"

declare -a DONE=()
rollback() {
  trap - ERR INT TERM
  set +e
  local rel
  for ((i=${#DONE[@]}-1; i>=0; i--)); do
    rel="${DONE[$i]}"
    if [[ -e "$CONFIG_DIR/$rel" || -L "$CONFIG_DIR/$rel" ]]; then rm -rf "$CONFIG_DIR/$rel"; fi
    if [[ -e "$BACKUP_DIR/$rel" || -L "$BACKUP_DIR/$rel" ]]; then
      mkdir -p "$(dirname "$CONFIG_DIR/$rel")"
      mv "$BACKUP_DIR/$rel" "$CONFIG_DIR/$rel"
    fi
  done
  if [[ -f "$BACKUP_DIR/.state/manifest.txt" ]]; then
    cp "$BACKUP_DIR/.state/manifest.txt" "$MANIFEST"
  else
    rm -f "$MANIFEST"
  fi
  if [[ -f "$BACKUP_DIR/.state/last-backup" ]]; then
    cp "$BACKUP_DIR/.state/last-backup" "$POINTER"
  else
    rm -f "$POINTER"
  fi
  if [[ -f "$BACKUP_DIR/.state/original-backup" ]]; then
    cp "$BACKUP_DIR/.state/original-backup" "$ORIGIN"
  else
    rm -f "$ORIGIN"
  fi
  if [[ -f "$BACKUP_DIR/.state/owner" ]]; then
    cp "$BACKUP_DIR/.state/owner" "$OWNER_MARKER"
  else
    rm -f "$OWNER_MARKER"
  fi
  rm -rf "$STAGE_DIR"
  if [[ "$STATE_DIR_EXISTED" -eq 1 ]]; then
    rm -rf "$BACKUP_DIR"
  else
    rm -rf "$STATE_DIR"
  fi
}
trap 'rollback; exit 1' ERR INT TERM

for rel in "${RELS[@]}"; do
  assert_safe_parents "$rel"
  target="$CONFIG_DIR/$rel"
  mkdir -p "$(dirname "$target")"
  if [[ -e "$target" || -L "$target" ]]; then
    mkdir -p "$(dirname "$BACKUP_DIR/$rel")"
    mv "$target" "$BACKUP_DIR/$rel"
  fi
  DONE+=("$rel")
  mv "$STAGE_DIR/$rel" "$target"
done

printf '%s\n' "${RELS[@]}" > "$STAGE_DIR/manifest.txt"
printf '%s\n' "$BACKUP_DIR" > "$STAGE_DIR/last-backup"
mv "$STAGE_DIR/manifest.txt" "$MANIFEST"
mv "$STAGE_DIR/last-backup" "$POINTER"
if [[ ! -f "$ORIGIN" ]]; then printf '%s\n' "$BACKUP_DIR" > "$STAGE_DIR/original-backup"; mv "$STAGE_DIR/original-backup" "$ORIGIN"; fi
rm -rf "$STAGE_DIR"
trap - ERR INT TERM

echo "Foundation AI files installed."
echo "Config fragment: $CONFIG_DIR/foundation-ai/opencode.jsonc.fragment"
echo "Merge default_agent and subagent_depth into your existing opencode.jsonc manually."
echo "Restart OpenCode after merging the config fragment."
