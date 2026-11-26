---
name: performance-optimization
description: "Evidence-driven performance diagnosis and optimization for explicitly delegated tasks. Load only when the task specifically asks to investigate, measure, or improve performance."
---

# Performance Optimization

## Activation and authority

Load this skill **only when the delegated task explicitly asks for performance diagnosis, profiling, benchmarking, or optimization**. Do not activate it merely because code appears slow, a performance concern is noticed incidentally, or a project may eventually need to scale.

This skill supplements Hugo Amaryl's `execute-work` and the relevant domain skill (`backend-engineering`, `frontend-engineering`, or `database-engineering`). It does not expand the approved task, create performance objectives, authorize infrastructure changes, or replace independent review, security, and QA gates.

Work only within the delegated scope. If investigation reveals a material architectural, infrastructure, data, cost, or product trade-off outside that scope, stop before making that change and report evidence and options to Daniel Olivaw.

## Core rule: measure before changing

Do not claim a performance problem or improvement without evidence.

Before optimizing, establish as much of the following as the task and environment permit:

- **Target:** the user-visible or system-level behavior being investigated.
- **Metric:** a relevant measurement, such as latency (p50/p95/p99), throughput, error rate, CPU, memory, allocation rate, query time, bundle size, LCP, INP, or CLS.
- **Baseline:** the current value or a reproducible qualitative trace.
- **Method:** tool, command, environment, workload, data shape, sample size, and relevant configuration.
- **Variability:** repeat count, spread, and known sources of noise.

Use targets and budgets supplied by the user or approved plan. If none exist, characterize the baseline and report measured changes without inventing an SLO, acceptance threshold, or claim of meeting a target. If reliable measurement is unavailable, state that limitation and do not present an unverified optimization as proven.

## Diagnostic workflow

1. **Understand the real path.** Trace the user/request/job path and identify the suspected layer before selecting tools.
2. **Form a testable hypothesis.** Name the suspected cost and the evidence that would confirm or disprove it.
3. **Choose a proportionate measurement.** Use existing project tooling and the least intrusive profiler or benchmark that can answer the question.
4. **Locate the dominant contributor.** Distinguish CPU, allocation/GC, memory growth, I/O, network, queueing, lock contention, database work, rendering, and payload costs. Do not infer a bottleneck from a single metric alone.
5. **Change one meaningful factor at a time.** Prefer the smallest complete change that addresses the evidenced cause. Preserve correctness, security, accessibility, and maintainability.
6. **Re-run the same measurement.** Keep method, workload, environment, and data comparable to the baseline. Record sample size and variance.
7. **Check trade-offs and regressions.** Compare relevant neighboring metrics, including error rate, memory, CPU, database load, payload size, and tail latency where applicable.
8. **Report the result honestly.** Separate measured facts, interpretation, and remaining hypotheses.

## Diagnostic guide

Choose tools based on the observed symptom and the project's stack; these are examples, not mandatory dependencies:

| Symptom | Useful first investigation |
| --- | --- |
| Slow page rendering or interaction | Browser performance trace, Lighthouse/WebPageTest where available, Core Web Vitals |
| Slow API or job | Distributed traces, request timing, p50/p95/p99 split, queue wait, slow-query logs |
| High CPU under repeatable workload | CPU profiler and flame graph |
| Growing or excessive memory | Heap/allocation profile, retained-object analysis, GC behavior |
| Database-bound path | Query plan, query timing, rows scanned/returned, existing database statistics |
| Spiky latency or low CPU utilization | Queue depth, pool wait, lock contention, retries, GC pauses, dependency latency |
| Large frontend payload | Bundle analysis, duplicate dependencies, route/chunk sizes, transfer size |

Do not introduce a new monitoring or benchmarking platform merely to follow this guide. Use available project tooling unless the task explicitly authorizes additional dependencies or services.

## Optimization priorities

Prioritize only after evidence identifies the dominant cost. Potential approaches include:

1. Remove unnecessary work: redundant computation or requests, N+1 access, avoidable serialization, excess data retrieval.
2. Reduce work on the critical path: defer nonessential work or use existing asynchronous/background mechanisms where semantics permit.
3. Improve data access: appropriate batching, pagination, query shape, or indexing supported by query evidence.
4. Reduce transfer and rendering cost: payload selection, compression, image sizing, code splitting, and avoiding unnecessary client work.
5. Improve concurrency or caching only when the workload and correctness model justify it.
6. Add capacity or change infrastructure only when explicitly in scope and authorized.

This is not a mechanical prescription. Do not add caching to conceal a bad query, increase concurrency without checking downstream capacity, or tune runtime flags before measuring the underlying cause.

## Domain-specific checks

### Backend and services

- Examine critical-path spans, outbound calls, queueing, retries, and timeout behavior.
- Consider connection-pool wait and downstream capacity, not just pool utilization.
- For caching, account for TTL, invalidation, stampedes, consistency, and hit rate.
- Preserve authorization, transaction, idempotency, and failure semantics.
- Avoid logging secrets or sensitive payloads during profiling.

### Frontend

- Connect user-visible symptoms to LCP, INP, CLS, or another relevant measured behavior.
- Inspect long main-thread tasks, unnecessary renders, data-fetch waterfalls, bundle composition, and layout shifts.
- Validate the affected real entry point and relevant viewport/theme conditions under `execute-work`.
- Do not optimize a synthetic metric at the expense of actual user behavior or accessibility.

### Database and persistence

- Inspect actual query plans and representative query shapes before proposing indexes or rewrites.
- Consider rows scanned, cardinality, selectivity, lock time, connection wait, and write amplification.
- Validate changes against representative safe fixtures and the project's migration conventions.
- Do not run destructive, expensive, or production-impacting queries or migrations without explicit authorization.

## Safety and scope boundaries

- No load, stress, soak, or traffic-replay tests against production or shared environments unless explicitly authorized for that exact environment and workload.
- Do not generate uncontrolled traffic, use real personal data, or expose secrets in profiles, traces, fixtures, or reports.
- Use local, isolated, or explicitly approved test environments and synthetic or approved datasets.
- Do not change production configuration, autoscaling, infrastructure, cloud resources, schemas, or deployment settings unless the delegated task explicitly includes those changes and the required authorization is present.
- Do not weaken tests, validation, security controls, logging safeguards, or correctness guarantees to improve a benchmark.
- If the available environment cannot reproduce the relevant workload, state what the measurement can and cannot establish.

## Completion report

Report inline with the implementation handoff; do not create a separate performance evidence artifact unless the task explicitly requires one.

Use this structure:

- **Target and scope:** what was asked and what was measured.
- **Baseline:** metric, value/trace, method, environment, workload, sample size.
- **Hypothesis:** suspected bottleneck and supporting evidence.
- **Change:** exact paths and the change made, or state that no code change was justified.
- **Result:** same-method before/after measurements, sample size, variance, and relevant regressions/trade-offs.
- **Verification:** correctness tests and real-surface checks required by `execute-work`.
- **Limitations and follow-ups:** unmeasured conditions, remaining hypotheses, and next owner/action.

Never claim a speedup without comparable measurements. If the result is neutral, inconclusive, or worse, say so plainly. Performance measurements supplement—not replace—the normal diagnostics, build, tests, post-write review, and applicable independent quality gates.
