---
title: Runtime Type Checking
tags: [architecture, runtime]
sources:
  [
    lib/compiler/runtime/term.dart,
    lib/compiler/errors/runtime_error.dart,
    lib/compiler/library/,
  ]
---

# Runtime Type Checking

**TLDR**: Primal uses dynamic typing with runtime type validation. Native functions check argument types during evaluation by testing term instances with Dart `is` checks, throwing `InvalidArgumentTypesError` on mismatch. Type guards follow a consistent pattern: reduce arguments, verify types, compute result.

## When Type Checking Occurs

Type checking in Primal happens at runtime during function application, not at compile time. The semantic analyzer validates that referenced functions exist and that argument counts match, but argument types are validated when the function body executes.

Type checking occurs at these points:

1. **Native function application**: When a native function's `reduce()` method executes.
2. **Higher-order function callbacks**: When a passed function returns a value that must satisfy a type constraint.
3. **Collection operations**: When elements are accessed or modified.

## The Type Guard Pattern

Native functions follow a consistent pattern for type validation. The implementation is split across two classes:

1. **Definition class**: Extends `NativeFunctionTerm`, declares the function signature.
2. **Evaluation class**: Extends `NativeFunctionTermWithArguments`, implements the logic with type guards.

### Basic Pattern

```dart
// From lib/compiler/library/arithmetic/num_add.dart
class NumAdd extends NativeFunctionTerm {
  const NumAdd()
    : super(
        name: 'num.add',
        parameters: const [
          Parameter.number('a'),
          Parameter.number('b'),
        ],
      );

  @override
  Term term(List<Term> arguments) => TermWithArguments(
    name: name,
    parameters: parameters,
    arguments: arguments,
  );
}

class TermWithArguments extends NativeFunctionTermWithArguments {
  const TermWithArguments({
    required super.name,
    required super.parameters,
    required super.arguments,
  });

  @override
  Term reduce() {
    final Term a = arguments[0].reduce();
    final Term b = arguments[1].reduce();

    if ((a is NumberTerm) && (b is NumberTerm)) {
      return NumberTerm(a.value + b.value);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
```

Key elements:

1. **Reduce first**: Call `reduce()` on each argument to get the evaluated term.
2. **Type check with `is`**: Use Dart's `is` operator to test term types.
3. **Compute on success**: Access `.value` and perform the operation.
4. **Throw on failure**: Throw `InvalidArgumentTypesError` with expected and actual types.

### Multi-Argument Validation

For functions with multiple typed arguments, combine checks with `&&`:

```dart
if ((a is StringTerm) && (b is StringTerm)) {
  return BooleanTerm(a.value.contains(b.value));
} else {
  throw InvalidArgumentTypesError(
    function: name,
    expected: parameterTypes,
    actual: [a.type, b.type],
  );
}
```

### Higher-Order Functions

Functions accepting function arguments must validate both the argument type and any callback results:

```dart
// From lib/compiler/library/list/list_filter.dart
@override
Term reduce() {
  final Term a = arguments[0].reduce();
  final Term b = arguments[1].reduce();

  if ((a is ListTerm) && (b is FunctionTerm)) {
    final List<Term> result = [];

    for (final Term element in a.value) {
      final Term value = b.apply([element]);

      // Validate callback return type
      if (value is! BooleanTerm) {
        throw InvalidArgumentTypesError(
          function: name,
          expected: [const BooleanType()],
          actual: [value.type],
        );
      }

      if (value.value) {
        result.add(element);
      }
    }

    return ListTerm(result);
  } else {
    throw InvalidArgumentTypesError(
      function: name,
      expected: parameterTypes,
      actual: [a.type, b.type],
    );
  }
}
```

This pattern validates:

1. The list argument is a `ListTerm`.
2. The function argument is a `FunctionTerm`.
3. Each callback invocation returns a `BooleanTerm`.

### Short-Circuit Evaluation

Lazy operators check types incrementally to support short-circuit semantics:

```dart
// From lib/compiler/library/logic/bool_and.dart
static BooleanTerm execute({
  required FunctionTerm function,
  required List<Term> arguments,
}) {
  final Term a = arguments[0].reduce();

  if (a is BooleanTerm) {
    if (a.value) {
      // Only evaluate second argument if first is true
      final Term b = arguments[1].reduce();

      if (b is BooleanTerm) {
        return b;
      } else {
        throw InvalidArgumentTypesError(
          function: function.name,
          expected: function.parameterTypes,
          actual: [a.type, b.type],
        );
      }
    } else {
      return const BooleanTerm(false);
    }
  } else {
    throw InvalidArgumentTypesError(
      function: function.name,
      expected: function.parameterTypes,
      actual: [a.type],
    );
  }
}
```

## Error Types

Runtime type mismatches throw specific error types defined in `lib/compiler/errors/runtime_error.dart`:

### InvalidArgumentTypesError

Thrown when argument types do not match the function signature:

```dart
class InvalidArgumentTypesError extends RuntimeError {
  InvalidArgumentTypesError({
    required String function,
    required List<Type> expected,
    required List<Type> actual,
  }) : super(
         'Invalid argument types for function "$function". '
         'Expected: (${expected.join(', ')}). '
         'Actual: (${actual.join(', ')})',
       );
}
```

Example error message:

```
Runtime error: Invalid argument types for function "num.add". Expected: (Number, Number). Actual: (String, Number)
```

### InvalidArgumentCountError

Thrown when the number of arguments does not match the parameter count:

```dart
class InvalidArgumentCountError extends RuntimeError {
  InvalidArgumentCountError({
    required String function,
    required int expected,
    required int actual,
  }) : super(
         'Invalid argument count for function "$function". '
         'Expected: $expected. Actual: $actual',
       );
}
```

This is thrown by `FunctionTerm.apply()` before type checking occurs.

### Other Runtime Errors

Additional errors for specific runtime conditions:

| Error Class                    | Cause                                           |
| ------------------------------ | ----------------------------------------------- |
| `InvalidValueError`            | Value cannot be formatted for output            |
| `InvalidLiteralValueError`     | Value cannot be converted to a term             |
| `InvalidMapIndexError`         | Map key not found                               |
| `ElementNotFoundError`         | Index out of bounds                             |
| `NotFoundInScopeError`         | Variable or function not in scope               |
| `InvalidFunctionError`         | Non-function value used as callee               |
| `EmptyCollectionError`         | Operation on empty collection                   |
| `IndexOutOfBoundsError`        | Numeric index exceeds bounds                    |
| `NegativeIndexError`           | Negative index where not allowed                |
| `DivisionByZeroError`          | Division or modulo by zero                      |
| `InvalidNumericOperationError` | Invalid math operation (e.g., sqrt of negative) |
| `ParseError`                   | String cannot be parsed to target type          |
| `JsonParseError`               | Invalid JSON input                              |
| `Base64ParseError`             | Invalid Base64 input                            |
| `RecursionLimitError`          | Maximum recursion depth exceeded                |

## Type Classes in Type Checking

When a parameter uses a type class (e.g., `Parameter.ordered('value')`), the type guard must check against all member types:

```dart
if (a is NumberTerm || a is StringTerm || a is TimestampTerm) {
  // Handle ordered types
}
```

Alternatively, use `TypeClass.accepts()`:

```dart
if (const OrderedType().accepts(a.type)) {
  // Handle ordered types
}
```

## The Term.type Property

Every term provides its type through the `type` getter:

```dart
abstract class Term {
  Type get type;
  // ...
}

class NumberTerm extends ValueTerm<num> {
  @override
  Type get type => const NumberType();
}
```

This property is used to:

1. Construct the `actual` list for `InvalidArgumentTypesError`.
2. Compare against expected types in type class checks.
3. Report types in error messages.

## Why Runtime Type Checking?

Primal uses runtime type checking for several reasons:

1. **Dynamic typing**: Parameter types declared in the standard library are for documentation and runtime validation, not static type inference.
2. **Polymorphic functions**: Functions using `AnyType` or type classes accept multiple types, requiring runtime dispatch.
3. **Higher-order functions**: Callback return types cannot be determined statically.
4. **Simplicity**: The type system avoids complex type inference while still providing type safety through runtime checks.

The tradeoff is that type errors are detected at runtime rather than compile time. Error messages include the function name and expected/actual types to help diagnose issues.
