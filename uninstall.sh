#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="${HOME:-}/.config/opencode"
ASSUME_YES=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --yes) ASSUME_YES=1 ;;
    --config-dir)
      [[ $# -ge 2 && -n "$2" ]] || { echo "ERROR: --config-dir requires a path" >&2; exit 2; }
      CONFIG_DIR="$2"; shift ;;
    --config-dir=*) CONFIG_DIR="${1#*=}" ;;
    *) echo "Usage: bash uninstall.sh [--yes] [--config-dir PATH]" >&2; exit 2 ;;
  esac
  shift
done

[[ -n "$CONFIG_DIR" ]] || { echo "ERROR: empty config directory" >&2; exit 2; }
if [[ "$CONFIG_DIR" == "~" || "$CONFIG_DIR" == "~/"* ]]; then
  [[ -n "${HOME:-}" ]] || { echo "ERROR: HOME required to expand ~" >&2; exit 1; }
  if [[ "$CONFIG_DIR" == "~" ]]; then CONFIG_DIR="$HOME"; else CONFIG_DIR="$HOME/${CONFIG_DIR:2}"; fi
fi

[[ -d "$CONFIG_DIR" ]] || { echo "ERROR: config directory does not exist: $CONFIG_DIR" >&2; exit 1; }
CONFIG_DIR="$(cd "$CONFIG_DIR" && pwd -P)"
STATE_DIR="$CONFIG_DIR/.foundation-ai-state"
OWNER_MARKER="$STATE_DIR/owner"
MANIFEST="$STATE_DIR/manifest.txt"
POINTER="$STATE_DIR/last-backup"
ORIGIN="$STATE_DIR/original-backup"
[[ ! -L "$STATE_DIR" && ! -L "$OWNER_MARKER" && ! -L "$MANIFEST" && ! -L "$ORIGIN" ]] || { echo "ERROR: refusing symlink installer state" >&2; exit 1; }
[[ -f "$OWNER_MARKER" && "$(cat "$OWNER_MARKER")" == "foundation-ai-managed-v1" && -f "$MANIFEST" && -f "$ORIGIN" ]] || { echo "ERROR: no Foundation AI install manifest found in $STATE_DIR" >&2; exit 1; }

BACKUP_DIR="$(cat "$ORIGIN")"
case "$BACKUP_DIR" in
  "$STATE_DIR"/backups/*) ;;
  *) echo "ERROR: invalid backup pointer; refusing to remove files" >&2; exit 1 ;;
esac
[[ -d "$BACKUP_DIR" && ! -L "$BACKUP_DIR" ]] || { echo "ERROR: recorded backup directory is missing or unsafe: $BACKUP_DIR" >&2; exit 1; }
[[ -d "$STATE_DIR/backups" && ! -L "$STATE_DIR/backups" ]] || { echo "ERROR: refusing missing or symlink backup root" >&2; exit 1; }
BACKUP_ROOT="$(cd "$STATE_DIR/backups" && pwd -P)"
BACKUP_DIR="$(cd "$BACKUP_DIR" && pwd -P)"
case "$BACKUP_DIR" in
  "$BACKUP_ROOT"/*) ;;
  *) echo "ERROR: backup directory resolves outside the managed backup root" >&2; exit 1 ;;
esac

declare -a RELS=()
while IFS= read -r rel; do RELS+=("$rel"); done < "$MANIFEST"
assert_safe_tree_parents() {
  local root="$1" rel="$2" current="$root" part
  local -a parts=()
  IFS='/' read -r -a parts <<< "$rel"
  for ((i=0; i<${#parts[@]}-1; i++)); do
    part="${parts[$i]}"
    current="$current/$part"
    [[ ! -L "$current" ]] || { echo "ERROR: refusing symlink parent directory: $current" >&2; return 1; }
    [[ ! -e "$current" || -d "$current" ]] || { echo "ERROR: expected directory but found non-directory: $current" >&2; return 1; }
  done
}

for rel in "${RELS[@]}"; do
  [[ -n "$rel" && "$rel" != /* && "$rel" != *".."* ]] || { echo "ERROR: unsafe manifest path: $rel" >&2; exit 1; }
  case "$rel" in
    agents/*.md|skills/*|foundation-ai/protocols/*.md|foundation-ai/opencode.jsonc.fragment) ;;
    *) echo "ERROR: unexpected managed path in manifest: $rel" >&2; exit 1 ;;
  esac
  assert_safe_tree_parents "$CONFIG_DIR" "$rel"
  assert_safe_tree_parents "$BACKUP_DIR" "$rel"
  [[ ! -L "$BACKUP_DIR/$rel" ]] || { echo "ERROR: backup contains symlink path: $rel" >&2; exit 1; }
done

if [[ "$ASSUME_YES" -ne 1 ]]; then
  echo "Uninstall only the paths listed in:"
  echo "  $MANIFEST"
  echo "Previously existing managed files will be restored from:"
  echo "  $BACKUP_DIR"
  read -r -p "Proceed? [yes/N] " reply
  [[ "$reply" == "yes" || "$reply" == "YES" ]] || { echo "Aborted."; exit 1; }
fi

[[ ! -L "$STATE_DIR/uninstalled-current" ]] || { echo "ERROR: refusing symlink uninstall archive directory" >&2; exit 1; }
mkdir -p "$STATE_DIR/uninstalled-current"
UNINSTALL_DIR="$(mktemp -d "$STATE_DIR/uninstalled-current/$(date +%Y%m%d-%H%M%S).XXXXXX")"
declare -a CURRENT_MOVED=() ORIGINAL_MOVED=()

rollback_uninstall() {
  local status=$?
  trap - ERR INT TERM
  set +e
  local rel
  for ((i=${#ORIGINAL_MOVED[@]}-1; i>=0; i--)); do
    rel="${ORIGINAL_MOVED[$i]}"
    if [[ -e "$CONFIG_DIR/$rel" || -L "$CONFIG_DIR/$rel" ]]; then
      mkdir -p "$(dirname "$BACKUP_DIR/$rel")"
      mv "$CONFIG_DIR/$rel" "$BACKUP_DIR/$rel"
    fi
  done
  for ((i=${#CURRENT_MOVED[@]}-1; i>=0; i--)); do
    rel="${CURRENT_MOVED[$i]}"
    if [[ -e "$UNINSTALL_DIR/$rel" || -L "$UNINSTALL_DIR/$rel" ]]; then
      mkdir -p "$(dirname "$CONFIG_DIR/$rel")"
      mv "$UNINSTALL_DIR/$rel" "$CONFIG_DIR/$rel"
    fi
  done
  rm -rf "$UNINSTALL_DIR"
  exit "$status"
}
trap rollback_uninstall ERR INT TERM

for ((i=${#RELS[@]}-1; i>=0; i--)); do
  rel="${RELS[$i]}"
  assert_safe_tree_parents "$CONFIG_DIR" "$rel"
  assert_safe_tree_parents "$BACKUP_DIR" "$rel"
  target="$CONFIG_DIR/$rel"
  if [[ -e "$target" || -L "$target" ]]; then
    mkdir -p "$(dirname "$UNINSTALL_DIR/$rel")"
    mv "$target" "$UNINSTALL_DIR/$rel"
    CURRENT_MOVED+=("$rel")
  fi
  if [[ -e "$BACKUP_DIR/$rel" || -L "$BACKUP_DIR/$rel" ]]; then
    mkdir -p "$(dirname "$target")"
    mv "$BACKUP_DIR/$rel" "$target"
    ORIGINAL_MOVED+=("$rel")
  fi
done

# Remove only empty directories created by the installer; never remove user content.
rmdir "$CONFIG_DIR/foundation-ai/protocols" 2>/dev/null || true
rmdir "$CONFIG_DIR/foundation-ai" 2>/dev/null || true

# File restoration is complete; commit before cleaning state pointers.
trap - ERR INT TERM
rm -f "$MANIFEST" "$POINTER" "$ORIGIN"

echo "Foundation AI managed files removed/restored."
echo "Original files restored from: $BACKUP_DIR"
echo "Current installed files (including any local edits) preserved at: $UNINSTALL_DIR"
echo "Your OpenCode configuration file was never modified."
