---
name: code-idiom
description: "Language-independent coding discipline for the worker: types as proofs (make illegal states unrepresentable), boundaries that parse instead of validate, the YAGNI ladder with its applicability boundary, catch-only-recoverable error handling, positive naming, and where language specifics come from. Load before writing code in any language."
---

# Code Idiom

**You write code the type system and the tests can vouch for.**

This skill is the language-independent coding discipline the worker loads contextually. It composes with execute-work: that skill owns the *workflow* (language gate, scenario contract, execution loop, review) — this file owns how the code itself is shaped once you know where and what to write.

Where execute-work states a rule inline, its rule and this one are the same rule; never resolve a conflict by deviating from execute-work.

## Types as proofs

- **The type system is your proof system.** Make illegal states unrepresentable: if a bug can be expressed as a type error, it is *required* to be expressed as a type error.
- **Model the state space, not the fields.** Sum types over independent flags:
  - `EmailOnly | PostOnly | EmailAndPost` instead of two optionals whose illegal combination the compiler cannot rule out.
  - A map keyed by an identifier instead of a list of pairs that can hold a duplicate.
- **Code for exhaustiveness.** Discriminated unions and enums are matched exhaustively with the language's exhaustiveness mechanism (`assert_never` / compiler-enforced `match` / `assertNever`).
  - No wildcard matches — a new variant must break the build, not fall through silently.
  - `if`/`elif`/`else` is forbidden for discriminating on a tagged variant.
- **One name = one concept.** A `UserId` is not a `string`; a `Seconds` is not a `Milliseconds`. Distinct semantic primitives get distinct types.

## Boundaries: parse, don't validate

- **Untrusted input crosses the boundary exactly once** — parsed there into a typed value that carries the proof. Inside, code receives typed values and never re-validates.
- **A parser returns a proof-carrying value; a validator returns nothing.**
  - After `validate(x)` the compiler still lets you pass unvalidated `x` downstream; after `parse(x)` the type is the receipt.
  - Validation scattered through the call tree is *shotgun parsing*: the check fires unpredictably late, so the failure state depends on which caller hit it first. Parse at the source instead.
- **Trust framework guarantees; no defensive layer for a scenario you cannot name.**
  - No null checks for values the type system proves non-null.
  - No `try/except` around code that cannot raise.

## YAGNI — the ladder and its boundary

- **Climb the YAGNI ladder in execute-work and stop at the first rung that holds.** No helpers, abstractions, or defensive checks for hypothetical needs.
- **Know what presumptive features cost**: build + delay + carry + repair.
  - Code that exists to serve a guess must be read, tested, and updated forever.
  - Only a minority of hypothetical features ever pay off.
- **The ladder has a boundary: it does NOT apply to making the code easy to change.** Refactoring and self-testing code are enabling practices, not speculative features — investing in them is never YAGNI.
- What IS YAGNI: *generic structure for a hypothetical requirement* — a second way to do the same thing, a plugin point with no plugin, a config knob nobody sets.

## Error handling

- **Catch only what you can recover from.** If the handler cannot put the system back into a sane state or meaningfully proceed, do not catch — let it propagate to a boundary that can.
- **Catch the specific type.** A broad `except Exception` that names nothing recoverable is a bug factory: it swallows the failure you needed to see. If you cannot name the types, you cannot name the recovery.
- **Leave the state consistent.** An operation that fails leaves the object/system as it was (or as documented), never half-mutated — the caller's recovery depends on it.
- **Validation failures are not exceptions.**
  - User input can be invalid in several ways at once: collect the failures into a notification (a structured list of problems) and answer them together.
  - Throw-on-first-error forces the user to re-discover each remaining problem one round-trip at a time.
  - Throwing is for the *unrecoverable*, not the *expected and answerable*.
- **Log at error boundaries per project practice**, leveled by consumer, stable message with data in fields — see execute-work review point 11.

## Naming: positive over negative

- Name what the thing **is**, not what it is not: `isValid` over `isNotValid`, `isActive` over `isNotInactive`. Double negatives force the reader to compute the meaning.
- **Positive conditions branch readably**: `if isActive` over `if !isDisabled`. Keep both names when both states are real (`ACTIVE`/`INACTIVE`), and make the positive form the default branch.
- Names match what the thing does; a name you have to apologize for in a comment is the wrong name.

## Language specifics come from the language

This skill is deliberately language-independent — it governs the *discipline*, not the dialect.

- Syntax, standard-library idioms, framework patterns, and per-language error/typing conventions come from the language's official docs and the codebase's own conventions, exactly as execute-work Phase 0 step 2 requires.
- Never substitute this file for the language reference.
