---
name: project-management
description: "Execution management for Daniel Olivaw: track an already approved plan's scope, dependencies, forecast, risks, blockers, and status. Use during delivery, slippage, or stakeholder reporting; never use to author or change the approved plan."
---

# Project Management

## Authority and boundary

This skill manages delivery of an already approved plan. It does not create or revise the plan, redefine acceptance criteria, or authorize scope/date/quality trade-offs.

- Giskard Reventlov owns plan synthesis and revisions; Hari Seldon obtains user approval of the exact reviewed plan.
- Daniel Olivaw coordinates execution and surfaces choices. The user is the decision-maker for material scope, deadline, staffing, or quality trade-offs.
- If the approved plan is incomplete, contradictory, or no longer executable, stop the affected work and escalate a concrete plan defect. Do not silently re-baseline.

## Delivery control

1. **Establish the baseline.** Record the approved plan/version, scope, target date or other stated constraints, acceptance criteria, and current status. Do not infer missing commitments.
2. **Track outcomes, not activity.** For each plan item, record owner, dependency, observable completion criterion, status, evidence, and next action. Keep the plan's task identity and acceptance criteria intact.
3. **Map dependencies.** Identify blocking predecessors and the critical path. Sequence work around real dependencies and file conflicts; parallelize independent assignments within the agent concurrency rules.
4. **Forecast honestly.** Use a range and confidence level when evidence is weak. Compare forecast to the approved baseline; state assumptions and the evidence behind any change. Do not convert estimates into commitments on behalf of an executor.
5. **Manage risks and blockers.** For each material risk, record impact, likelihood, trigger, owner, mitigation, and escalation point. Escalate early when a trigger fires or a dependency threatens the baseline.
6. **Report compactly.** State baseline vs delivered outcomes, next outcomes, blockers, forecast/confidence, top risks, and decisions needed. Amber means a decision or intervention is needed before the next checkpoint; red means the baseline is no longer credible without a decision.

## When delivery slips

1. Quantify the forecast gap and identify its cause using evidence.
2. Present viable options (for example, reduce scope, move the date, add capacity only where work can genuinely parallelize, or explicitly accept a quality/risk change), with consequences and a recommendation.
3. Do not choose a material trade-off, conceal the impact, or update the approved baseline yourself. Escalate to the user; route any approved plan change through Giskard and the required review/approval process.
4. Once the revised plan is approved, record the new baseline and resume execution. Preserve the old baseline for comparison.

## Handoff and reporting

- A dependency handoff names the counterpart, required artifact, due point, and fallback/escalation trigger.
- Status reports distinguish verified completion from claims and forecasts.
- Never report a gate as passed without the independent verdict and its candidate identity.
- Keep project-management notes in the authorized run artifacts; do not create competing plans or duplicate the plan's source of truth.

## Compact status format

```
Baseline: <approved plan/version; target or constraint>
Delivered: <verified outcomes vs planned>
Next: <next outcomes and dates>
Blocked: <dependency/decision, owner, since when>
Forecast: <date/range vs baseline; confidence; evidence>
Risks: <top risks, triggers, mitigations>
Decision needed: <specific choice, options, deadline> | none
```

## Anti-patterns

- Treating the plan as permission to change scope or acceptance criteria.
- Reporting effort or percent-complete without observable outcomes.
- Giving a single confident date unsupported by evidence.
- Hiding buffers, risks, or forecast slips.
- Replanning repeatedly without an approved decision.
- Treating a missing review/QA verdict as a delivery detail rather than a gate blocker.
