# Testing Assertions

This document reviews the current testing-function draft against the existing
Primal language and compiler, then proposes a revised specification.

## 1. Short Summary Of Feature Intent

The original draft proposes standard-library helpers for writing assertions
directly in Primal code so that test expectations can be expressed in the
language itself.

The main valid need is an assertion mechanism, especially one that can assert
that an expression throws. Most of the other proposed helpers overlap heavily
with functionality that already exists in the language.

## 2. Pros, Cons, And Technical Inconsistencies

### Pros

- Dotted names such as `assert.true` and `assert.equal` are
  syntactically valid function names in Primal.
- Adding assertions as standard-library functions fits the current
  language philosophy better than introducing new assertion syntax.
- A library-based design fits the existing compiler pipeline
  cleanly, because ordinary function calls already pass through lexical,
  syntactic, semantic, lowering, and runtime evaluation stages.

### Technical Inconsistencies In The Draft

- The draft does not define what successful assertions return.
- The draft does not define how failed assertions are represented at
  runtime.
- The draft does not define whether assertion messages are evaluated
  eagerly or lazily.
- The draft does not define whether `assert.throws` catches all
  runtime errors or only a narrower subset.
- The draft does not define map semantics for `assert.contains`.
- `assert.closeTo` is underspecified for a dynamically typed
  language because it does not define number-only behavior, NaN or infinity
  behavior, or failure semantics when given non-numeric values.

## 3. Assumptions And Specification Gaps

### Confirmed Observations

- Primal has first-class functions.
- Primal does not currently expose lambda or anonymous-function syntax.
- `if` and `try` are special native functions with lazy evaluation behavior.
- Runtime type validation is performed by native functions at evaluation time.

### Inference

- If Primal gains a language-level assertion library, it should be minimal and
  orthogonal rather than mirroring every convenience helper found in external
  test frameworks.

### Gaps In The Original Draft

- It does not say whether this is only an assertion library or part of a wider
  test framework.
- It does not specify assertion-failure runtime behavior.
- It does not specify success return values.
- It does not specify lazy versus eager evaluation of messages.
- It does not specify exact interaction with existing runtime errors.
- It does not specify whether invalid helper usage should become assertion
  failures or ordinary runtime argument errors.

## 4. Revised Specification

### Final Scope

Add only these two standard-library functions:

```primal
assert.that(condition, message)
assert.throws(expression, message)
```

Do not add these as built-ins:

- `assert.equal`
- `assert.true`
- `assert.false`
- `assert.match`
- `assert.contains`
- `assert.closeTo`

Those cases should be written using existing Primal expressions.

### Why This Revision Is Better

- It keeps the feature minimal.
- It avoids duplicating existing equality, regex, and containment APIs.
- It preserves the current language preference for composition over large
  convenience surfaces.
- It isolates the genuinely new capability: asserting that an expression throws
  under Primal's eager call model.

### Informal Pseudo-Grammar

No new syntax is added.

```ebnf
assert_call ::= "assert.that" "(" expression "," expression ")"
              | "assert.throws" "(" expression "," expression ")"
```

These are ordinary function calls with ordinary identifiers.

### Semantic Rules

#### `assert.that(condition, message)`

- Evaluate `condition`.
- If `condition` reduces to `true`, return `true`.
- If `condition` reduces to `false`, evaluate `message`.
- `message` must reduce to a string.
- Raise an assertion failure with that message.

#### `assert.throws(expression, message)`

- Evaluate `expression`.
- If evaluating `expression` throws at runtime, return `true`.
- If evaluating `expression` completes normally, evaluate `message`.
- `message` must reduce to a string.
- Raise an assertion failure with that message.

### Runtime And Type Behavior

- Success return value: `true`
- `assert.that` requires the evaluated first argument to be a boolean.
- `assert.throws` accepts any first argument expression.
- In both functions, `message` is lazy and is evaluated only on failure.
- Failed assertions should reuse the existing custom-error mechanism rather than
  requiring a separate assertion-specific runtime error type.
- The recommended failure representation is:

```primal
error.throw("assertion", message)
```

This means a failed assertion is represented as a `CustomError` whose code is
`"assertion"` and whose message is the supplied string.

### Error Conditions

- `assert.that` with a non-boolean condition:
  - `InvalidArgumentTypesError`
- `assert.that` with a failing condition and non-string message:
  - `InvalidArgumentTypesError`
- `assert.throws` with a non-throwing expression:
  - assertion failure
- `assert.throws` with a non-string message on the failing path:
  - `InvalidArgumentTypesError`
- Errors from nested expressions such as invalid regex patterns:
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

- Add two standard-library signatures
- Preserve ordinary arity checking and function-resolution behavior

#### Lowering

- No structural lowering changes required
- Both assertions lower as ordinary calls to standard-library functions

#### Runtime Evaluation

- `assert.that` must be implemented as a native function
- `assert.throws` must be implemented as a lazy native function
- `assert.throws` cannot be modeled correctly as an eager custom function

### Performance Considerations

- Runtime overhead is low for `assert.that`
- Runtime overhead is low to medium for `assert.throws` because it requires
  evaluation under error interception
- Avoiding redundant assertion wrappers keeps the standard library smaller and
  reduces documentation and maintenance cost

## 5. Examples

### Valid Examples

```primal
assert.that(1 + 1 == 2, "math failed")
```

```primal
assert.that(str.match("hello123", "[a-z]+[0-9]+"), "pattern mismatch")
```

```primal
assert.that(list.contains([1, 2, 3], 2), "missing element")
```

```primal
assert.that(num.abs(actual - expected) <= delta, "not close enough")
```

```primal
assert.throws(to.number("not a number"), "expected parsing to fail")
```

```primal
assert.that(true, error.throw(-1, "message should not evaluate"))
```

### Invalid Examples With Expected Errors

```primal
assert.that(1, "expected boolean")
```

Expected error:

```text
InvalidArgumentTypesError
```

```primal
assert.that(false, 123)
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

```primal
assert.that(str.match("abc", "["), "bad regex")
```

Expected error:

```text
ParseError
```

### Concrete Edge Cases

#### Edge Case 1: Lazy Message Evaluation

```primal
assert.that(true, error.throw(-1, "unused"))
```

This must succeed without evaluating the message.

#### Edge Case 2: `assert.throws` Around A Successful Expression

```primal
assert.throws(1 + 2, "expected a throw")
```

This must fail with an assertion failure, not succeed.

#### Edge Case 3: Underlying Predicate Error

```primal
assert.that(str.match("abc", "["), "pattern should be valid")
```

This should propagate the regex parse error rather than convert it into a
false condition.

#### Edge Case 4: Message Type Error On Failure Path Only

```primal
assert.that(false, 42)
```

This should throw `InvalidArgumentTypesError`.

#### Edge Case 5: `assert.throws` Catches A Custom Error

```primal
assert.throws(error.throw(404, "not found"), "should throw")
```

This should succeed.

## 6. High-Value Open Questions

1. Is the goal only an assertion library, or should this later expand into a
   full test-runner design?
2. Should failed assertions always reuse `CustomError`, or is a dedicated
   assertion-specific runtime error still desired?
3. Should `assert.throws` catch every runtime failure that `try` catches, or a
   narrower subset?
4. Is lazy evaluation of assertion messages required by design?
5. Should assertion helpers be available in all programs, or only in a future
   testing-oriented environment?

## 7. Post-Implementation

- Update documentation in `docs/`
- Implement tests

## 8. Implementation Complexity

Medium

Justification:

- The surface area is small if reduced to two functions.
- No lexer or parser work should be required.
- The main complexity is correct lazy runtime behavior for `assert.throws` and
  consistent assertion-failure reporting.

## 9. Final Recommendation

Revise

Do not accept the original draft as written. Adopt the reduced two-function
design centered on `assert.that` and `assert.throws`, and leave the rest to be
expressed through existing Primal operators and library functions.
