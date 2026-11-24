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
    *) echo "Usage: bash foundation-ai/uninstall.sh [--yes] [--config-dir PATH]" >&2; exit 2 ;;
  esac
  shift
done

[[ -n "$CONFIG_DIR" ]] || { echo "ERROR: empty config directory" >&2; exit 2; }
if [[ "$CONFIG_DIR" == "~" || "$CONFIG_DIR" == "~/"* ]]; then
  [[ -n "${HOME:-}" ]] || { echo "ERROR: HOME required to expand ~" >&2; exit 1; }
  if [[ "$CONFIG_DIR" == "~" ]]; then CONFIG_DIR="$HOME"; else CONFIG_DIR="$HOME/${CONFIG_DIR:2}"; fi
fi

STATE_DIR="$CONFIG_DIR/foundation-ai"
MANIFEST="$STATE_DIR/manifest.txt"
POINTER="$STATE_DIR/last-backup"
[[ -f "$MANIFEST" && -f "$POINTER" ]] || { echo "ERROR: no Foundation AI install manifest found in $STATE_DIR" >&2; exit 1; }

BACKUP_DIR="$(cat "$POINTER")"
case "$BACKUP_DIR" in
  "$STATE_DIR"/backups/*) ;;
  *) echo "ERROR: invalid backup pointer; refusing to remove files" >&2; exit 1 ;;
esac
[[ -d "$BACKUP_DIR" ]] || { echo "ERROR: recorded backup directory is missing: $BACKUP_DIR" >&2; exit 1; }

declare -a RELS=()\nwhile IFS= read -r rel; do RELS+=("$rel"); done < "$MANIFEST"
for rel in "${RELS[@]}"; do
  [[ -n "$rel" && "$rel" != /* && "$rel" != *".."* ]] || { echo "ERROR: unsafe manifest path: $rel" >&2; exit 1; }
  case "$rel" in
    agents/*.md|skills/*|foundation-ai/protocols/*.md|foundation-ai/opencode.jsonc.fragment) ;;
    *) echo "ERROR: unexpected managed path in manifest: $rel" >&2; exit 1 ;;
  esac
done

if [[ "$ASSUME_YES" -ne 1 ]]; then
  echo "Uninstall only the paths listed in:"
  echo "  $MANIFEST"
  echo "Previously existing managed files will be restored from:"
  echo "  $BACKUP_DIR"
  read -r -p "Proceed? [yes/N] " reply
  [[ "$reply" == "yes" || "$reply" == "YES" ]] || { echo "Aborted."; exit 1; }
fi

for ((i=${#RELS[@]}-1; i>=0; i--)); do
  rel="${RELS[$i]}"
  target="$CONFIG_DIR/$rel"
  if [[ -e "$target" || -L "$target" ]]; then rm -rf "$target"; fi
  if [[ -e "$BACKUP_DIR/$rel" || -L "$BACKUP_DIR/$rel" ]]; then
    mkdir -p "$(dirname "$target")"
    mv "$BACKUP_DIR/$rel" "$target"
  fi
done

# Restore the previous ownership state if this was an upgrade/reinstall.
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

echo "Foundation AI managed files removed/restored."
echo "Backups retained at: $BACKUP_DIR"
echo "Your OpenCode configuration file was never modified."
