---
title: Bindings and Substitution
tags: [architecture, evaluation]
sources: [lib/compiler/runtime/bindings.dart, lib/compiler/runtime/term.dart]
---

# Bindings and Substitution

**TLDR**: The `Bindings` class maps parameter names to argument values, and `substitute()` replaces variable references with their bound values throughout the term tree, with different variable term types supporting either strict or partial substitution.

## Overview

Primal's evaluation model is based on substitution: when a function is applied to arguments, the function body's parameter references are replaced with the corresponding argument values. The `Bindings` class holds these name-to-value mappings, and each `Term` type defines how substitution propagates through it.

## The Bindings Class

```dart
// From lib/compiler/runtime/bindings.dart
class Bindings {
  final Map<String, Term> data;

  const Bindings(this.data);

  Term get(String name) {
    if (data.containsKey(name)) {
      return data[name]!;
    } else {
      throw NotFoundInScopeError(name);
    }
  }

  factory Bindings.from({
    required List<Parameter> parameters,
    required List<Term> arguments,
  }) {
    final Map<String, Term> bindings = {};

    for (int i = 0; i < parameters.length; i++) {
      bindings[parameters[i].name] = arguments[i];
    }

    return Bindings(bindings);
  }
}
```

### Creating Bindings

Bindings are typically created via the `Bindings.from()` factory, which pairs each parameter name with its corresponding argument value by index:

```dart
final Bindings bindings = Bindings.from(
  parameters: [Parameter.number('x'), Parameter.number('y')],
  arguments: [NumberTerm(1), NumberTerm(2)],
);
// Creates: {'x': NumberTerm(1), 'y': NumberTerm(2)}
```

### Accessing Bindings

The `get()` method retrieves a bound value by name. If the name is not found, it throws `NotFoundInScopeError`. This strict behavior is appropriate for `BoundVariableTerm`, which must always resolve to a value.

For let bindings and lambda parameters, code accesses `data` directly to check for presence before substituting, enabling partial substitution.

## Substitution Patterns

Different term types implement substitution differently based on their semantics.

### Value Terms: No Substitution Needed

Value terms (`BooleanTerm`, `NumberTerm`, etc.) contain no variable references and return themselves unchanged:

```dart
@override
Term substitute(Bindings bindings) => this;
```

### BoundVariableTerm: Strict Substitution

Function parameter references must be resolved. The `substitute()` method uses `bindings.get()`, which throws if the name is missing:

```dart
class BoundVariableTerm extends Term {
  final String name;

  @override
  Term substitute(Bindings bindings) => bindings.get(name);
}
```

This enforces that all function parameters are bound before the body is evaluated.

### LetBoundVariableTerm: Partial Substitution

Let binding references use partial substitution. If the name exists in bindings, the value is returned; otherwise, the term returns itself:

```dart
class LetBoundVariableTerm extends Term {
  final String name;

  @override
  Term substitute(Bindings bindings) =>
      bindings.data.containsKey(name) ? bindings.data[name]! : this;
}
```

This pattern is necessary because:

1. Let bindings are evaluated sequentially, so earlier bindings are not yet available when processing later ones.
2. Function parameter substitution should not affect let binding references.

### LambdaBoundVariableTerm: Partial Substitution for Closures

Lambda parameter references also use partial substitution to support closures:

```dart
class LambdaBoundVariableTerm extends Term {
  final String name;

  @override
  Term substitute(Bindings bindings) =>
      bindings.data.containsKey(name) ? bindings.data[name]! : this;
}
```

When a lambda captures variables from an outer scope, those variables are substituted into the lambda body. But the lambda's own parameters remain as `LambdaBoundVariableTerm` references until the lambda is applied.

### Collection Terms: Recursive Substitution

Collections recurse into their elements:

```dart
// ListTerm example
@override
Term substitute(Bindings bindings) =>
    ListTerm(value.map((e) => e.substitute(bindings)).toList());

// MapTerm example
@override
Term substitute(Bindings bindings) {
  final Iterable<MapEntry<Term, Term>> entries = value.entries.map(
    (e) => MapEntry(e.key.substitute(bindings), e.value.substitute(bindings)),
  );
  return MapTerm(Map.fromEntries(entries));
}
```

### CallTerm: Recursive Substitution

Function calls substitute into both the callee and arguments:

```dart
@override
Term substitute(Bindings bindings) => CallTerm(
  callee: callee.substitute(bindings),
  arguments: arguments.map((e) => e.substitute(bindings)).toList(),
);
```

### LetTerm: Recursive Substitution

Let expressions substitute into binding values and the body:

```dart
@override
Term substitute(Bindings bindings) {
  return LetTerm(
    bindings: this.bindings
        .map((b) => (b.$1, b.$2.substitute(bindings)))
        .toList(),
    body: body.substitute(bindings),
  );
}
```

### LambdaTerm: Capture-Aware Substitution

Lambda substitution is more complex because it must avoid capturing the lambda's own parameters:

```dart
@override
Term substitute(Bindings bindings) {
  // Remove bindings for this lambda's own parameters
  final Map<String, Term> filteredBindings = Map.of(bindings.data);
  for (final Parameter parameter in parameters) {
    filteredBindings.remove(parameter.name);
  }

  return LambdaTerm(
    name: name,
    parameters: parameters,
    body: body.substitute(Bindings(filteredBindings)),
  );
}
```

This prevents outer substitutions from affecting inner lambda parameters with the same names. For example, in `((x) -> (x) -> x)(1)`, substituting `{x: 1}` into the outer lambda should not affect the inner lambda's parameter `x`.

### CustomFunctionTerm: Closed Substitution

Custom functions return themselves during external substitution:

```dart
@override
Term substitute(Bindings bindings) => this;
```

Custom functions are "closed values" - their internal variables are bound at application time via `apply()`, not during external substitution. This prevents variable capture bugs when a function is captured by a lambda.

## Scope Handling

### Sequential Let Bindings

Let bindings are evaluated sequentially, with each binding able to reference earlier ones:

```dart
// From LetTerm.reduce()
@override
Term reduce() {
  final Map<String, Term> bindingMap = {};
  for (final (String name, Term term) in bindings) {
    // Each binding sees only previously evaluated bindings
    final Term substituted = term.substitute(
      Bindings(Map<String, Term>.of(bindingMap)),
    );
    final Term value = substituted.reduce();
    bindingMap[name] = value;
  }
  return body.substitute(Bindings(bindingMap)).reduce();
}
```

This enables patterns like:

```primal
let x = 1, y = x + 1 in y  // y can reference x
```

### Shadowing Prevention

The semantic analyzer prevents shadowing of function parameters by let bindings or lambda parameters. This simplifies substitution because names are guaranteed to be unique within their scope.

However, let bindings and lambda parameters may shadow function names (both custom and standard library). When this happens, the binding takes precedence within its scope.

## Evaluation Flow with Substitution

Here is the complete flow for evaluating a function call:

1. **Reduce callee**: `callee.reduce()` returns a `FunctionTerm`.

2. **For `CustomFunctionTerm.apply()`**:
   - Increment recursion depth
   - Eagerly evaluate all arguments: `arguments.map((a) => a.reduce())`
   - Create bindings: `Bindings.from(parameters, evaluatedArguments)`
   - Substitute into body: `term.substitute(bindings)`
   - Reduce substituted body: `substituted.reduce()`
   - Decrement recursion depth

3. **For `NativeFunctionTerm.substitute()`**:
   - Resolve arguments from bindings (not reduced yet)
   - Return `NativeFunctionTermWithArguments` holding the arguments

4. **For `NativeFunctionTermWithArguments.reduce()`**:
   - Selectively reduce arguments as needed
   - Perform computation and return result

## Variable Term Summary

| Term Type                 | Substitution Behavior            | Use Case                    |
| ------------------------- | -------------------------------- | --------------------------- |
| `BoundVariableTerm`       | Strict (throws if not found)     | Function parameters         |
| `LetBoundVariableTerm`    | Partial (returns self if absent) | Let binding references      |
| `LambdaBoundVariableTerm` | Partial (returns self if absent) | Lambda parameter references |
