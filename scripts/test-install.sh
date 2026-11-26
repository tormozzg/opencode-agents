#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INSTALL="$ROOT/install.sh"
UNINSTALL="$ROOT/uninstall.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# 1. Collision must abort without overwriting foreign data or creating state.
COLLISION="$TMP/collision"
mkdir -p "$COLLISION/agents"
printf 'foreign-agent\n' > "$COLLISION/agents/hari-seldon.md"
if bash "$INSTALL" --yes --config-dir "$COLLISION" >/dev/null 2>&1; then
  echo "FAIL: installer accepted an unowned name collision" >&2; exit 1
fi
[[ "$(cat "$COLLISION/agents/hari-seldon.md")" == "foreign-agent" ]] || { echo "FAIL: collision file changed" >&2; exit 1; }
[[ ! -e "$COLLISION/.foundation-ai-state" ]] || { echo "FAIL: collision created installer state" >&2; exit 1; }


# 2. A mid-install filesystem failure must roll back every file already installed.
ROLLBACK="$TMP/rollback"
mkdir -p "$ROLLBACK/foundation-ai"
printf 'protected-parent-file\n' > "$ROLLBACK/foundation-ai/protocols"
if bash "$INSTALL" --yes --config-dir "$ROLLBACK" > "$TMP/rollback.log" 2>&1; then
  echo "FAIL: installer unexpectedly succeeded with a blocking parent file" >&2; exit 1
fi
[[ ! -e "$ROLLBACK/agents/hari-seldon.md" ]] || { echo "FAIL: rollback left an agent behind" >&2; exit 1; }
[[ ! -e "$ROLLBACK/skills/plan-work" ]] || { echo "FAIL: rollback left a skill behind" >&2; exit 1; }
actual="$(cat "$ROLLBACK/foundation-ai/protocols")"
if [[ "$actual" != "protected-parent-file" ]]; then
  printf "FAIL: rollback changed blocking file; actual=%q\\n" "$actual" >&2
  cat "$TMP/rollback.log" >&2
  exit 1
fi
[[ ! -e "$ROLLBACK/.foundation-ai-state" ]] || { echo "FAIL: preflight rejection left installer state behind" >&2; exit 1; }

# 3. A one-shot mv failure during installation must roll back all installed paths.
INSTALL_MV_WRAPPER="$TMP/install-mv-wrapper"
mkdir -p "$INSTALL_MV_WRAPPER"
cat > "$INSTALL_MV_WRAPPER/mv" <<'MV'
#!/usr/bin/env bash
count=0
[[ ! -f "$MV_COUNT_FILE" ]] || count="$(cat "$MV_COUNT_FILE")"
count=$((count + 1))
printf '%s\n' "$count" > "$MV_COUNT_FILE"
if [[ "$count" -eq 4 && ! -e "$MV_FAILED_FILE" ]]; then
  : > "$MV_FAILED_FILE"
  exit 77
fi
exec /bin/mv "$@"
MV
chmod +x "$INSTALL_MV_WRAPPER/mv"
INSTALL_ROLLBACK="$TMP/install-rollback"
mkdir -p "$INSTALL_ROLLBACK"
if PATH="$INSTALL_MV_WRAPPER:$PATH" MV_COUNT_FILE="$TMP/install-mv-count" MV_FAILED_FILE="$TMP/install-mv-failed" bash "$INSTALL" --yes --config-dir "$INSTALL_ROLLBACK" > "$TMP/install-mv-rollback.log" 2>&1; then
  echo "FAIL: installer ignored injected move failure" >&2; exit 1
fi
[[ ! -e "$INSTALL_ROLLBACK/agents/hari-seldon.md" ]] || { echo "FAIL: installer rollback left an agent behind" >&2; exit 1; }
[[ ! -e "$INSTALL_ROLLBACK/skills/plan-work" ]] || { echo "FAIL: installer rollback left a skill behind" >&2; exit 1; }
[[ ! -e "$INSTALL_ROLLBACK/.foundation-ai-state" ]] || { echo "FAIL: installer rollback left state behind" >&2; exit 1; }

# 4. Reject symlinked managed parent directories before writing outside CONFIG_DIR.
SYMLINK_CONFIG="$TMP/symlink-config"
OUTSIDE="$TMP/outside"
mkdir -p "$SYMLINK_CONFIG" "$OUTSIDE"
printf 'protected\n' > "$OUTSIDE/hari-seldon.md"
ln -s "$OUTSIDE" "$SYMLINK_CONFIG/agents"
if bash "$INSTALL" --yes --config-dir "$SYMLINK_CONFIG" > "$TMP/symlink-install.log" 2>&1; then
  echo "FAIL: installer accepted a symlinked agents directory" >&2; exit 1
fi
[[ "$(cat "$OUTSIDE/hari-seldon.md")" == "protected" ]] || { echo "FAIL: installer changed data outside CONFIG_DIR" >&2; exit 1; }
[[ ! -e "$SYMLINK_CONFIG/.foundation-ai-state" ]] || { echo "FAIL: symlink rejection left installer state" >&2; exit 1; }

# 5. Install into a disposable config containing unrelated user data and JSONC.
CONFIG="$TMP/config"
mkdir -p "$CONFIG/agents" "$CONFIG/skills"
printf 'my-agent\n' > "$CONFIG/agents/my-agent.md"
printf '{\n  // user comment\n  "model": "example/model"\n}\n' > "$CONFIG/opencode.jsonc"
cp "$CONFIG/opencode.jsonc" "$TMP/config.before"

bash "$INSTALL" --yes --config-dir "$CONFIG"
[[ -f "$CONFIG/agents/hari-seldon.md" ]] || { echo "FAIL: agent not installed" >&2; exit 1; }
[[ -f "$CONFIG/agents/vasiliya-aliena.md" ]] || { echo "FAIL: Vasiliya agent not installed" >&2; exit 1; }
[[ -f "$CONFIG/skills/performance-optimization/SKILL.md" ]] || { echo "FAIL: performance optimization skill not installed" >&2; exit 1; }
[[ -f "$CONFIG/skills/security-review/SKILL.md" ]] || { echo "FAIL: security skill not installed" >&2; exit 1; }
[[ -f "$CONFIG/skills/security-advisory/SKILL.md" ]] || { echo "FAIL: planning advisory skill not installed" >&2; exit 1; }
[[ -f "$CONFIG/foundation-ai/protocols/security-policy.md" ]] || { echo "FAIL: protocol not installed" >&2; exit 1; }
[[ -f "$CONFIG/foundation-ai/opencode.jsonc.fragment" ]] || { echo "FAIL: config fragment not installed" >&2; exit 1; }
[[ "$(cat "$CONFIG/agents/my-agent.md")" == "my-agent" ]] || { echo "FAIL: unrelated agent was changed" >&2; exit 1; }
cmp -s "$CONFIG/opencode.jsonc" "$TMP/config.before" || { echo "FAIL: active JSONC config was modified" >&2; exit 1; }

# 6. Reinstall must be safe and preserve the original pre-install state.
bash "$INSTALL" --yes --config-dir "$CONFIG"
printf 'local-edit\n' > "$CONFIG/skills/security-review/USER.md"
# Reject symlinked parents before moving any managed files.
mv "$CONFIG/agents" "$CONFIG/agents.saved"
ln -s "$OUTSIDE" "$CONFIG/agents"
if bash "$UNINSTALL" --yes --config-dir "$CONFIG" > "$TMP/symlink-uninstall.log" 2>&1; then
  echo "FAIL: uninstaller accepted a symlinked agents directory" >&2; exit 1
fi
[[ -f "$CONFIG/.foundation-ai-state/manifest.txt" ]] || { echo "FAIL: symlink rejection damaged install state" >&2; exit 1; }
rm "$CONFIG/agents"
mv "$CONFIG/agents.saved" "$CONFIG/agents"

# Inject a one-shot mv failure after uninstall has moved several managed paths.
MV_WRAPPER="$TMP/mv-wrapper"
mkdir -p "$MV_WRAPPER"
cat > "$MV_WRAPPER/mv" <<'MV'
#!/usr/bin/env bash
count=0
[[ ! -f "$MV_COUNT_FILE" ]] || count="$(cat "$MV_COUNT_FILE")"
count=$((count + 1))
printf '%s\n' "$count" > "$MV_COUNT_FILE"
if [[ "$count" -eq 4 && ! -e "$MV_FAILED_FILE" ]]; then
  : > "$MV_FAILED_FILE"
  exit 77
fi
exec /bin/mv "$@"
MV
chmod +x "$MV_WRAPPER/mv"
if PATH="$MV_WRAPPER:$PATH" MV_COUNT_FILE="$TMP/mv-count" MV_FAILED_FILE="$TMP/mv-failed" bash "$UNINSTALL" --yes --config-dir "$CONFIG" > "$TMP/uninstall-rollback.log" 2>&1; then
  echo "FAIL: uninstaller ignored injected filesystem failure" >&2; exit 1
fi
[[ -f "$CONFIG/foundation-ai/opencode.jsonc.fragment" ]] || { echo "FAIL: uninstall rollback lost config fragment" >&2; exit 1; }
[[ -f "$CONFIG/foundation-ai/protocols/security-policy.md" ]] || { echo "FAIL: uninstall rollback lost protocol" >&2; exit 1; }
[[ -f "$CONFIG/skills/security-review/USER.md" ]] || { echo "FAIL: uninstall rollback lost local edit" >&2; exit 1; }
[[ -f "$CONFIG/.foundation-ai-state/manifest.txt" ]] || { echo "FAIL: uninstall rollback lost manifest" >&2; exit 1; }

bash "$UNINSTALL" --yes --config-dir "$CONFIG"
[[ ! -e "$CONFIG/agents/hari-seldon.md" ]] || { echo "FAIL: managed agent remained after uninstall" >&2; exit 1; }
[[ ! -e "$CONFIG/skills/security-review" ]] || { echo "FAIL: managed skill remained after uninstall" >&2; exit 1; }
[[ ! -e "$CONFIG/foundation-ai/protocols" ]] || { echo "FAIL: managed protocols remained after uninstall" >&2; exit 1; }
[[ "$(cat "$CONFIG/agents/my-agent.md")" == "my-agent" ]] || { echo "FAIL: user agent was not preserved" >&2; exit 1; }
cmp -s "$CONFIG/opencode.jsonc" "$TMP/config.before" || { echo "FAIL: active JSONC config changed" >&2; exit 1; }
[[ ! -f "$CONFIG/.foundation-ai-state/manifest.txt" ]] || { echo "FAIL: install manifest remained after uninstall" >&2; exit 1; }
[[ -f "$CONFIG/.foundation-ai-state/owner" ]] || { echo "FAIL: backup state lost its ownership marker" >&2; exit 1; }

# 7. A clean reinstall after uninstall must work and remain uninstallable.
bash "$INSTALL" --yes --config-dir "$CONFIG"
[[ -f "$CONFIG/agents/hari-seldon.md" ]] || { echo "FAIL: reinstall after uninstall did not restore managed files" >&2; exit 1; }
[[ -f "$CONFIG/agents/vasiliya-aliena.md" ]] || { echo "FAIL: reinstall omitted Vasiliya" >&2; exit 1; }
[[ -f "$CONFIG/skills/performance-optimization/SKILL.md" ]] || { echo "FAIL: reinstall omitted performance skill" >&2; exit 1; }
bash "$UNINSTALL" --yes --config-dir "$CONFIG"
[[ ! -e "$CONFIG/agents/hari-seldon.md" ]] || { echo "FAIL: second uninstall left managed files behind" >&2; exit 1; }
find "$CONFIG/.foundation-ai-state/uninstalled-current" -name USER.md -type f | grep -q . || { echo "FAIL: local edits inside managed content were not preserved" >&2; exit 1; }

echo "PASS: installer collision safety, rollback, install, repeat install, uninstall, and user-data preservation"
