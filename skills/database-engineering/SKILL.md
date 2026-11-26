---
name: database-engineering
description: "Hugo's task-scoped practices for schema, migration, query, and data-integrity changes. Load when the delegated task changes persistence behavior."
---

# Database Engineering

## Activation
Load when the task changes schema, migrations, SQL/queries, indexes, transactions, data integrity, or retention behavior. Do not load when code only uses existing persistence behavior without changing it.

## Workflow
1. Inspect schema, access paths, constraints, migration system, and data lifecycle.
2. Identify invariants and affected reads/writes before changing persistence.
3. Follow project migration and deployment conventions.
4. Use parameterized queries and preserve least-privilege access patterns.
5. Test relevant migration behavior and data integrity with safe fixtures.
6. Report operational or rollback concerns that cannot be verified locally.

## Review focus
- Persisted-data integrity and constraints.
- Migration safety for the project's deployment model.
- Query correctness and evidence-based indexing.
- Sensitive data excluded from fixtures and logs.
- No destructive production operation without explicit authorization.

## Handoff
Report schema/query changes, migration and test results, and unresolved deployment or integrity risks. Create a migration plan only when required by the task.

## Foundation AI integration
This skill supplements `execute-work`; it does not expand scope, authorize production actions, replace independent review/security/QA gates, or authorize Git actions. Report material data-loss or deployment risks to Daniel Olivaw.
