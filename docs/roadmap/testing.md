# Testing Assertions

This document reviews the testing-function draft against the existing Primal
language and compiler, then proposes a revised specification for a focused
assertion library.

## 1. Short Summary Of Feature Intent

The feature should provide standard-library helpers for writing assertions
directly in Primal code so that test expectations can be expressed in the
language itself.

The library should include these assertion helpers:

- `assert.throws`
- `assert.equal`
- `assert.true`
- `assert.false`

`assert.throws` is the most implementation-sensitive helper because it must
intercept runtime failures under Primal's eager call model. The other helpers
still provide value because they make tests easier to read and standardize how
assertion failures are represented.

## 2. Pros, Costs, And Technical Considerations

### Pros

- Dotted names such as `assert.true` and `assert.equal` are
  syntactically valid function names in Primal.
- Adding assertions as standard-library functions fits the current
  language philosophy better than introducing new assertion syntax.
- A library-based design fits the existing compiler pipeline
  cleanly, because ordinary function calls already pass through lexical,
  syntactic, semantic, lowering, and runtime evaluation stages.
- Convenience helpers can improve test readability even when they mirror
  existing equality or boolean checks.
- A shared failure representation makes assertion behavior predictable across
  all helpers.

### Costs

- Several helpers overlap with functionality that already exists in the
  language.
- The standard library surface becomes larger than the bare minimum.
- Lazy message evaluation means these helpers are not trivial wrappers over
  existing functions under Primal's eager call model.

### Technical Considerations

- The specification must define one common success return value.
- The specification must define one common assertion-failure runtime
  representation.
- The specification must define whether `assert.throws` catches every runtime
  error that `try` catches.

## 3. Assumptions And Scope

### Confirmed Observations

- Primal has first-class functions.
- `if` and `try` are special native functions with lazy evaluation behavior.
- Runtime type validation is performed by native functions at evaluation time.
- Existing language and library behavior already provide the underlying
  predicates needed by these helpers, especially ordinary equality and boolean
  expressions.

### Scope Of This Proposal

- This is an assertion library specification, not a full test-runner design.
- Assertion helpers should be available as standard-library functions.
- No new syntax is added.
- Some helpers intentionally mirror existing language operations in order to
  make test code clearer and more consistent.

## 4. Revised Specification

### Final Scope

Add these standard-library functions:

```primal
assert.throws(expression, message)
assert.equal(actual, expected, message)
assert.true(condition, message)
assert.false(condition, message)
```

### Why This Revision Is Better

- It preserves the goal of keeping assertions inside the language rather than
  adding assertion syntax.
- It keeps the assertion surface small while still covering the main testing
  needs.
- It standardizes how assertion failures are represented and reported.
- It keeps the implementation inside the existing compiler and runtime model.

### Informal Pseudo-Grammar

No new syntax is added.

```ebnf
assert_call ::= "assert.throws" "(" expression "," expression ")"
              | "assert.equal" "(" expression "," expression "," expression ")"
              | "assert.true" "(" expression "," expression ")"
              | "assert.false" "(" expression "," expression ")"
```

These are ordinary function calls with ordinary identifiers.

### Common Assertion Behavior

- Success return value: `true`
- In every helper, `message` is lazy and is evaluated only on failure.
- On a failing path, `message` must reduce to a string.
- Failed assertions should reuse the existing custom-error mechanism rather
  than introducing a separate assertion-specific runtime error type.
- The recommended failure representation is:

```primal
error.throw("assertion", message)
```

This means a failed assertion is represented as a `CustomError` whose code is
`"assertion"` and whose message is the supplied string.

If evaluating the predicate or helper-specific operation itself throws before
the assertion outcome is known, that error should propagate unchanged unless
the helper explicitly defines that thrown error as success, as `assert.throws`
does.

### Semantic Rules

#### `assert.throws(expression, message)`

- Evaluate `expression` under runtime error interception.
- If evaluating `expression` throws any runtime error that `try` would catch,
  return `true`.
- If evaluating `expression` completes normally, evaluate `message`.
- `message` must reduce to a string.
- Raise an assertion failure with that message.

#### `assert.equal(actual, expected, message)`

- Evaluate `actual`.
- Evaluate `expected`.
- Compare them using Primal's ordinary equality semantics, equivalent to `==`
  or `comp.eq`.
- If the comparison reduces to `true`, return `true`.
- If the comparison reduces to `false`, evaluate `message`.
- `message` must reduce to a string.
- Raise an assertion failure with that message.

#### `assert.true(condition, message)`

- Evaluate `condition`.
- `condition` must reduce to a boolean.
- If `condition` reduces to `true`, return `true`.
- If `condition` reduces to `false`, evaluate `message`.
- `message` must reduce to a string.
- Raise an assertion failure with that message.

This is a readability helper for asserting truth directly.

#### `assert.false(condition, message)`

- Evaluate `condition`.
- `condition` must reduce to a boolean.
- If `condition` reduces to `false`, return `true`.
- If `condition` reduces to `true`, evaluate `message`.
- `message` must reduce to a string.
- Raise an assertion failure with that message.

### Runtime And Type Behavior

- Success return value: `true`
- All assertion helpers use lazy message evaluation.
- `assert.true` and `assert.false` require a boolean condition.
- `assert.equal` follows the same runtime type rules as ordinary equality.
- `assert.throws` catches any runtime error that `try` would catch.

### Error Conditions

- `assert.true` with a non-boolean condition:
  - `InvalidArgumentTypesError`
- `assert.false` with a non-boolean condition:
  - `InvalidArgumentTypesError`
- Any assertion helper with a failing condition and non-string message:
  - `InvalidArgumentTypesError`
- `assert.equal` with arguments rejected by ordinary equality:
  - propagate the underlying runtime error unchanged
- `assert.throws` with a non-throwing expression:
  - assertion failure
- Errors from nested expressions:
  - propagate unchanged unless they are the error being intentionally caught by
    `assert.throws`

### Compiler Impact

#### Lexical Analysis

- No new tokens
- No new keywords
- No keyword conflicts expected

#### Syntactic Analysis

- No grammar changes
- Parsed as ordinary function calls

#### Semantic Analysis

- Add four standard-library signatures
- Preserve ordinary arity checking and function-resolution behavior

#### Lowering

- No structural lowering changes required
- All assertions lower as ordinary calls to standard-library functions

#### Runtime Evaluation

- All assertion helpers must be implemented as native functions or an
  equivalent runtime mechanism that preserves lazy message evaluation.
- `assert.throws` must additionally evaluate its first argument under runtime
  error interception.
- These helpers cannot be modeled correctly as ordinary eager custom functions
  if lazy failure messages are required.

### Performance Considerations

- Runtime overhead is low for `assert.equal`, `assert.true`, and
  `assert.false`.
- Runtime overhead is low to medium for `assert.throws` because it requires
  evaluation under error interception.

## 5. Examples

### Valid Examples

```primal
assert.equal(1 + 1, 2, "math failed")
```

```primal
assert.true(str.match("hello123", "[a-z]+[0-9]+"), "pattern mismatch")
```

```primal
assert.throws(to.number("not a number"), "expected parsing to fail")
```

```primal
assert.equal(true, true, error.throw(-1, "message should not evaluate"))
```

### Invalid Examples With Expected Errors

```primal
assert.true(1, "expected boolean")
```

Expected error:

```text
InvalidArgumentTypesError
```

```primal
assert.false(true, 123)
```

Expected error:

```text
InvalidArgumentTypesError
```

```primal
assert.equal("1", 1, "expected equal")
```

Expected error:

```text
InvalidArgumentTypesError
```

```primal
assert.throws(42, "expected failure")
```

Expected result:

```text
Assertion failure via CustomError(code = "assertion", message = "expected failure")
```

## 6. Concrete Edge Cases

### Edge Case 1: Lazy Message Evaluation

```primal
assert.equal(true, true, error.throw(-1, "unused"))
```

This must succeed without evaluating the message.

### Edge Case 2: `assert.throws` Around A Successful Expression

```primal
assert.throws(1 + 2, "expected a throw")
```

This must fail with an assertion failure, not succeed.

### Edge Case 3: Underlying Equality Type Error

```primal
assert.equal("1", 1, "should not coerce types")
```

This should propagate `InvalidArgumentTypesError` rather than convert it into
an assertion failure.

### Edge Case 4: `assert.throws` Catches A Custom Error

```primal
assert.throws(error.throw(404, "not found"), "should throw")
```

This should succeed.

## 7. High-Value Open Questions

1. Is the long-term goal still only an assertion library, or should this later
   expand into a full test-runner design?
2. Should assertion helpers be available in all programs, or only in a future
   testing-oriented environment?
3. Should future work add richer failure payloads or formatted diagnostics
   while keeping the same helper surface?

## 8. Post-Implementation

- Update documentation in `docs/`
- Implement runtime coverage for all four helpers
- Implement tests for lazy message behavior, equality type errors, and
  `assert.throws` error interception

## 9. Implementation Complexity

Medium

Justification:

- No lexer or parser work should be required.
- The surface area is small and cohesive.
- The main complexity is preserving lazy message behavior across all helpers
  and implementing error interception for `assert.throws`.

## 10. Final Recommendation

Adopt

Adopt the focused four-function assertion library centered on
`assert.throws`, `assert.equal`, `assert.true`, and `assert.false`. Those
helpers cover the main testing use cases while keeping the surface smaller than
the earlier expanded designs.
