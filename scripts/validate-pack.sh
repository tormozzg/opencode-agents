#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENTS="${ROOT}/.opencode/agents"
SKILLS="${ROOT}/.opencode/skills"
PROTOCOLS="${ROOT}/.opencode/protocols"
SNAPSHOT="${ROOT}/source-snapshot/skills"

fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "PASS: $*"; }

[[ -d "$AGENTS" ]] || fail "agents directory missing"
[[ -d "$SKILLS" ]] || fail "skills directory missing"
[[ -d "$PROTOCOLS" ]] || fail "protocols directory missing"
for script in "$ROOT/install.sh" "$ROOT/uninstall.sh" "$ROOT/scripts/test-install.sh"; do
  bash -n "$script" || fail "shell syntax error: $script"
done
pass "installer, uninstaller, and lifecycle-test shell syntax"

agent_count="$(find "$AGENTS" -maxdepth 1 -type f -name '*.md' | wc -l | tr -d ' ')"
skill_count="$(find "$SKILLS" -mindepth 2 -maxdepth 2 -type f -name 'SKILL.md' | wc -l | tr -d ' ')"
protocol_count="$(find "$PROTOCOLS" -maxdepth 1 -type f -name '*.md' | wc -l | tr -d ' ')"
snapshot_count="$(find "$SNAPSHOT" -mindepth 2 -maxdepth 2 -type f -name 'SKILL.md' | wc -l | tr -d ' ')"

[[ "$agent_count" == "9" ]] || fail "expected 9 agents, found $agent_count"
[[ "$skill_count" == "14" ]] || fail "expected 14 skills, found $skill_count"
[[ "$protocol_count" == "6" ]] || fail "expected 6 protocols, found $protocol_count"
[[ "$snapshot_count" == "13" ]] || fail "expected 13 upstream skill snapshots, found $snapshot_count"
pass "counts: 9 agents, 14 skills, 6 protocols, 13 source snapshots"

python3 - "$ROOT" <<'PY'
import json, pathlib, re, sys
root = pathlib.Path(sys.argv[1])
agents = root / ".opencode" / "agents"
skills = root / ".opencode" / "skills"
config = json.loads((root / "opencode.jsonc").read_text(encoding="utf-8"))
assert config.get("default_agent") == "daniel-olivaw", "default_agent must be daniel-olivaw"
assert config.get("subagent_depth") == 2, "subagent_depth must equal 2"

expected = {
    "plan-work", "architect-work", "lead-work", "discuss-work",
    "research-topic", "review-plan", "execute-work", "code-idiom",
    "refactor-code", "slop-cleanup", "review-code", "qa-inspect",
    "git-operations", "security-review",
}
actual = set()
for path in skills.glob("*/SKILL.md"):
    text = path.read_text(encoding="utf-8")
    m = re.search(r"(?m)^name:\s*([a-z0-9-]+)\s*$", text)
    assert m, f"{path}: missing skill name frontmatter"
    name = m.group(1)
    assert name == path.parent.name, f"{path}: name {name!r} does not match directory"
    assert re.search(r"(?m)^description:\s*.+$", text), f"{path}: missing description"
    actual.add(name)
assert actual == expected, f"skill set mismatch: missing={expected-actual}, extra={actual-expected}"


dispatches = set()
for skill_path in skills.glob("*/SKILL.md"):
    dispatches.update(re.findall(r"""subagent_type=["']([a-z0-9-]+)["']""", skill_path.read_text(encoding="utf-8")))
allowed_dispatches = {"elijah-baley", "kelden-amadiro", "andrew-martin", "han-fastolfe", "golan-trevize", "jothan-leebig"}
assert dispatches <= allowed_dispatches, f"unknown or removed subagent IDs in skills: {dispatches-allowed_dispatches}"

def frontmatter(name):
    text = (agents / f"{name}.md").read_text(encoding="utf-8")
    assert text.startswith("---\n"), f"{name}: missing YAML frontmatter"
    return text.split("---", 2)[1]

# Exact V1 Task allowlists; all other child IDs must be denied.
rules = {
    "daniel-olivaw": {"giskard-reventlov", "susan-calvin"},
    "giskard-reventlov": {"elijah-baley", "kelden-amadiro"},
    "susan-calvin": {"elijah-baley", "andrew-martin", "han-fastolfe", "golan-trevize", "jothan-leebig"},
}
for agent, allowed in rules.items():
    fm = frontmatter(agent)
    assert '"*": deny' in fm, f"{agent}: missing wildcard task deny"
    found = set(re.findall(r'(?m)^\s+"([a-z0-9-]+)": allow$', fm))
    assert found == allowed, f"{agent}: allowlist mismatch: expected {allowed}, got {found}"

tier2 = {"elijah-baley", "kelden-amadiro", "andrew-martin", "han-fastolfe", "golan-trevize", "jothan-leebig"}
for agent in tier2:
    fm = frontmatter(agent)
    assert '"*": deny' in fm, f"{agent}: Tier 2 must deny all task dispatch"
    assert not re.search(r'(?m)^\s+"[a-z0-9-]+": allow$', fm), f"{agent}: Tier 2 must not allow child agents"

for agent in tier2 - {"andrew-martin"}:
    fm = frontmatter(agent)
    assert re.search(r"(?m)^\s+edit: deny$", fm), f"{agent}: read-only agent must deny edit"


for agent, mode in {"daniel-olivaw": "primary", "giskard-reventlov": "all", "susan-calvin": "all"}.items():
    fm = frontmatter(agent)
    assert re.search(rf"(?m)^mode: {mode}$", fm), f"{agent}: expected mode {mode}"
assert "edit: deny" in frontmatter("daniel-olivaw"), "Daniel must not edit files"
assert 'edit:\n    "*": deny\n    ".opencode/plans/**": allow\n    ".opencode/evidence/**": allow' in frontmatter("giskard-reventlov"), "Giskard edit scope must be plans/evidence only"
assert 'edit:\n    "*": deny\n    ".opencode/evidence/**": allow\n    ".opencode/notepads/**": allow\n    ".opencode/task-state/**": allow' in frontmatter("susan-calvin"), "Susan edit scope must be coordination artifacts only"

print("PASS: OpenCode V1 JSON config, skill frontmatter, task allowlists, modes, and write boundaries")
PY

pass "Foundation AI structural validation complete"
