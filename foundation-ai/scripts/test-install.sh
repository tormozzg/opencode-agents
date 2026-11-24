#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
INSTALL="$ROOT/foundation-ai/install.sh"
UNINSTALL="$ROOT/foundation-ai/uninstall.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# 1. Collision must abort without overwriting foreign data or creating state.
COLLISION="$TMP/collision"
mkdir -p "$COLLISION/agents"
printf 'foreign-agent\n' > "$COLLISION/agents/daniel-olivaw.md"
if bash "$INSTALL" --yes --config-dir "$COLLISION" >/dev/null 2>&1; then
  echo "FAIL: installer accepted an unowned name collision" >&2; exit 1
fi
[[ "$(cat "$COLLISION/agents/daniel-olivaw.md")" == "foreign-agent" ]] || { echo "FAIL: collision file changed" >&2; exit 1; }
[[ ! -e "$COLLISION/.foundation-ai-state" ]] || { echo "FAIL: collision created installer state" >&2; exit 1; }


# 2. A mid-install filesystem failure must roll back every file already installed.
ROLLBACK="$TMP/rollback"
mkdir -p "$ROLLBACK/foundation-ai"
printf 'protected-parent-file\n' > "$ROLLBACK/foundation-ai/protocols"
if bash "$INSTALL" --yes --config-dir "$ROLLBACK" > "$TMP/rollback.log" 2>&1; then
  echo "FAIL: installer unexpectedly succeeded with a blocking parent file" >&2; exit 1
fi
[[ ! -e "$ROLLBACK/agents/daniel-olivaw.md" ]] || { echo "FAIL: rollback left an agent behind" >&2; exit 1; }
[[ ! -e "$ROLLBACK/skills/plan-work" ]] || { echo "FAIL: rollback left a skill behind" >&2; exit 1; }
actual="$(cat "$ROLLBACK/foundation-ai/protocols")"
if [[ "$actual" != "protected-parent-file" ]]; then
  printf "FAIL: rollback changed blocking file; actual=%q\\n" "$actual" >&2
  cat "$TMP/rollback.log" >&2
  exit 1
fi
[[ ! -f "$ROLLBACK/.foundation-ai-state/manifest.txt" ]] || { echo "FAIL: rollback left an install manifest" >&2; exit 1; }

# 3. Install into a disposable config containing unrelated user data and JSONC.
CONFIG="$TMP/config"
mkdir -p "$CONFIG/agents" "$CONFIG/skills"
printf 'my-agent\n' > "$CONFIG/agents/my-agent.md"
printf '{\n  // user comment\n  "model": "example/model"\n}\n' > "$CONFIG/opencode.jsonc"
cp "$CONFIG/opencode.jsonc" "$TMP/config.before"

bash "$INSTALL" --yes --config-dir "$CONFIG"
[[ -f "$CONFIG/agents/daniel-olivaw.md" ]] || { echo "FAIL: agent not installed" >&2; exit 1; }
[[ -f "$CONFIG/skills/security-review/SKILL.md" ]] || { echo "FAIL: security skill not installed" >&2; exit 1; }
[[ -f "$CONFIG/foundation-ai/protocols/security-policy.md" ]] || { echo "FAIL: protocol not installed" >&2; exit 1; }
[[ -f "$CONFIG/foundation-ai/opencode.jsonc.fragment" ]] || { echo "FAIL: config fragment not installed" >&2; exit 1; }
[[ "$(cat "$CONFIG/agents/my-agent.md")" == "my-agent" ]] || { echo "FAIL: unrelated agent was changed" >&2; exit 1; }
cmp -s "$CONFIG/opencode.jsonc" "$TMP/config.before" || { echo "FAIL: active JSONC config was modified" >&2; exit 1; }

# 4. Reinstall must be safe and preserve the original pre-install state.
bash "$INSTALL" --yes --config-dir "$CONFIG"
printf 'local-edit\n' > "$CONFIG/skills/security-review/USER.md"
bash "$UNINSTALL" --yes --config-dir "$CONFIG"
[[ ! -e "$CONFIG/agents/daniel-olivaw.md" ]] || { echo "FAIL: managed agent remained after uninstall" >&2; exit 1; }
[[ ! -e "$CONFIG/skills/security-review" ]] || { echo "FAIL: managed skill remained after uninstall" >&2; exit 1; }
[[ ! -e "$CONFIG/foundation-ai/protocols" ]] || { echo "FAIL: managed protocols remained after uninstall" >&2; exit 1; }
[[ "$(cat "$CONFIG/agents/my-agent.md")" == "my-agent" ]] || { echo "FAIL: user agent was not preserved" >&2; exit 1; }
cmp -s "$CONFIG/opencode.jsonc" "$TMP/config.before" || { echo "FAIL: active JSONC config changed" >&2; exit 1; }
[[ ! -f "$CONFIG/.foundation-ai-state/manifest.txt" ]] || { echo "FAIL: install manifest remained after uninstall" >&2; exit 1; }
find "$CONFIG/.foundation-ai-state/uninstalled-current" -name USER.md -type f | grep -q . || { echo "FAIL: local edits inside managed content were not preserved" >&2; exit 1; }

echo "PASS: installer collision safety, rollback, install, repeat install, uninstall, and user-data preservation"
