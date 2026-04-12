import 'dart:io';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/function_signature.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/models/type.dart';
import 'package:primal/compiler/runtime/bindings.dart';

abstract class Term {
  const Term();

  Type get type;

  Term substitute(Bindings bindings) => this;

  Term reduce() => this;

  dynamic native();
}

abstract class ValueTerm<T> implements Term {
  final T value;

  const ValueTerm(this.value);

  @override
  String toString() => value.toString();

  @override
  Term substitute(Bindings bindings) => this;

  @override
  Term reduce() => this;

  @override
  dynamic native() => value;

  static ValueTerm from(dynamic value) {
    if (value is bool) {
      return BooleanTerm(value);
    } else if (value is num) {
      return NumberTerm(value);
    } else if (value is String) {
      return StringTerm(value);
    } else if (value is DateTime) {
      return TimestampTerm(value);
    } else if (value is File) {
      return FileTerm(value);
    } else if (value is Directory) {
      return DirectoryTerm(value);
    } else if (value is Set<Term>) {
      return SetTerm(value);
    } else if (value is List<Term>) {
      return ListTerm(value);
    } else if (value is Map<Term, Term>) {
      return MapTerm(value);
    } else {
      throw InvalidLiteralValueError(value.toString());
    }
  }
}

class BooleanTerm extends ValueTerm<bool> {
  const BooleanTerm(super.value);

  @override
  Type get type => const BooleanType();
}

class NumberTerm extends ValueTerm<num> {
  const NumberTerm(super.value);

  @override
  Type get type => const NumberType();
}

class StringTerm extends ValueTerm<String> {
  const StringTerm(super.value);

  @override
  Type get type => const StringType();
}

class FileTerm extends ValueTerm<File> {
  const FileTerm(super.value);

  @override
  Type get type => const FileType();
}

class DirectoryTerm extends ValueTerm<Directory> {
  const DirectoryTerm(super.value);

  @override
  Type get type => const DirectoryType();
}

class TimestampTerm extends ValueTerm<DateTime> {
  const TimestampTerm(super.value);

  @override
  Type get type => const TimestampType();
}

class ListTerm extends ValueTerm<List<Term>> {
  const ListTerm(super.value);

  @override
  Type get type => const ListType();

  @override
  Term substitute(Bindings bindings) =>
      ListTerm(value.map((e) => e.substitute(bindings)).toList());

  @override
  List native() => value.map((e) => e.native()).toList();
}

class VectorTerm extends ValueTerm<List<Term>> {
  const VectorTerm(super.value);

  @override
  Type get type => const VectorType();

  @override
  Term substitute(Bindings bindings) =>
      VectorTerm(value.map((e) => e.substitute(bindings)).toList());

  @override
  List native() => value.map((e) => e.native()).toList();
}

class SetTerm extends ValueTerm<Set<Term>> {
  const SetTerm(super.value);

  @override
  Type get type => const SetType();

  @override
  Term substitute(Bindings bindings) =>
      SetTerm(value.map((e) => e.substitute(bindings)).toSet());

  @override
  Set native() => value.map((e) => e.native()).toSet();
}

class StackTerm extends ValueTerm<List<Term>> {
  const StackTerm(super.value);

  @override
  Type get type => const StackType();

  @override
  Term substitute(Bindings bindings) =>
      StackTerm(value.map((e) => e.substitute(bindings)).toList());

  @override
  List native() => value.map((e) => e.native()).toList();
}

class QueueTerm extends ValueTerm<List<Term>> {
  const QueueTerm(super.value);

  @override
  Type get type => const QueueType();

  @override
  Term substitute(Bindings bindings) =>
      QueueTerm(value.map((e) => e.substitute(bindings)).toList());

  @override
  List native() => value.map((e) => e.native()).toList();
}

class MapTerm extends ValueTerm<Map<Term, Term>> {
  const MapTerm(super.value);

  @override
  Type get type => const MapType();

  @override
  Term substitute(Bindings bindings) {
    final Iterable<MapEntry<Term, Term>> entries = value.entries.map(
      (e) => MapEntry(e.key.substitute(bindings), e.value.substitute(bindings)),
    );

    return MapTerm(Map.fromEntries(entries));
  }

  Map<dynamic, Term> asMapWithKeys() {
    final Map<dynamic, Term> map = {};

    for (final MapEntry<Term, Term> entry in value.entries) {
      map[entry.key.native()] = entry.value;
    }

    return map;
  }

  @override
  Map<dynamic, dynamic> native() {
    final Map<dynamic, dynamic> map = {};

    for (final MapEntry<Term, Term> entry in value.entries) {
      final dynamic key = entry.key.native();
      final dynamic value = entry.value.native();
      map[key] = value;
    }

    return map;
  }
}

/// A resolved function reference.
///
/// Holds a function name and a reference to the functions map. Resolution
/// happens at evaluation time, enabling forward references and mutual recursion
/// while avoiding global mutable state.
class FunctionReferenceTerm extends Term {
  final String name;
  final Map<String, FunctionTerm> functions;

  const FunctionReferenceTerm(this.name, this.functions);

  @override
  FunctionTerm reduce() {
    final FunctionTerm? function = functions[name];
    if (function == null) {
      throw NotFoundInScopeError(name);
    }
    return function;
  }

  @override
  Type get type => const FunctionType();

  @override
  String toString() => name;

  @override
  dynamic native() => reduce().native();
}

/// A reference to a bound parameter within a function body.
///
/// During function application, [substitute] replaces this term with the
/// corresponding argument value from the [Bindings].
class BoundVariableTerm extends Term {
  final String name;

  const BoundVariableTerm(this.name);

  @override
  Term substitute(Bindings bindings) => bindings.get(name);

  @override
  Type get type => const AnyType();

  @override
  String toString() => name;

  @override
  dynamic native() =>
      throw StateError('BoundVariableTerm cannot be converted to native');
}

/// A reference to a let-bound variable within a let expression body.
///
/// Unlike [BoundVariableTerm] (for function parameters), this term supports
/// partial substitution—it returns itself when the name is not found in
/// bindings, allowing function parameter substitution to pass through
/// without affecting let binding references.
class LetBoundVariableTerm extends Term {
  final String name;

  const LetBoundVariableTerm(this.name);

  @override
  Term substitute(Bindings bindings) =>
      bindings.data.containsKey(name) ? bindings.data[name]! : this;

  @override
  Term reduce() => this;

  @override
  Type get type => const AnyType();

  @override
  String toString() => name;

  @override
  dynamic native() =>
      throw StateError('LetBoundVariableTerm "$name" was not substituted');
}

/// A reference to a lambda parameter within a lambda body.
///
/// Unlike [BoundVariableTerm] (for function parameters), this term supports
/// partial substitution—it returns itself when the name is not found in
/// bindings, allowing outer scope substitution to pass through without
/// affecting lambda parameter references.
class LambdaBoundVariableTerm extends Term {
  final String name;

  const LambdaBoundVariableTerm(this.name);

  @override
  Term substitute(Bindings bindings) =>
      bindings.data.containsKey(name) ? bindings.data[name]! : this;

  @override
  Term reduce() => this; // Cannot reduce further; must be substituted first

  @override
  Type get type => const AnyType();

  @override
  String toString() => name;

  @override
  dynamic native() =>
      throw StateError('LambdaBoundVariableTerm "$name" was not substituted');
}

/// A let expression that introduces local variable bindings.
///
/// Bindings are evaluated sequentially in declaration order (call-by-value).
/// Each binding is fully evaluated before the next, and previous bindings
/// are visible to subsequent bindings and the body.
class LetTerm extends Term {
  final List<(String, Term)> bindings;
  final Term body;

  const LetTerm({
    required this.bindings,
    required this.body,
  });

  @override
  Type get type => const AnyType();

  @override
  Term substitute(Bindings bindings) {
    // Since shadowing is disallowed, no let binding name can conflict with
    // incoming bindings. Simply propagate substitutions through.
    return LetTerm(
      bindings: this.bindings
          .map((b) => (b.$1, b.$2.substitute(bindings)))
          .toList(),
      body: body.substitute(bindings),
    );
  }

  @override
  Term reduce() {
    // Build binding map incrementally. We use Bindings(map) directly instead
    // of Bindings.from() because:
    // 1. Bindings.from() takes List<Parameter> + List<Term> for function calls
    // 2. Here we build the map incrementally as each binding is evaluated
    // 3. Each binding must see only previously evaluated bindings, not all
    final Map<String, Term> bindingMap = {};
    for (final (String name, Term term) in bindings) {
      // Create a snapshot of current bindings for substitution.
      // This ensures each binding only sees previously evaluated bindings.
      final Term substituted = term.substitute(
        Bindings(Map<String, Term>.of(bindingMap)),
      );
      final Term value = substituted.reduce();
      bindingMap[name] = value;
    }
    return body.substitute(Bindings(bindingMap)).reduce();
  }

  @override
  dynamic native() => reduce().native();

  @override
  String toString() {
    final String bindingString = bindings
        .map((b) => '${b.$1} = ${b.$2}')
        .join(', ');
    return 'let $bindingString in $body';
  }
}

class CallTerm extends Term {
  final Term callee;
  final List<Term> arguments;

  const CallTerm({
    required this.callee,
    required this.arguments,
  });

  @override
  Term substitute(Bindings bindings) => CallTerm(
    callee: callee.substitute(bindings),
    arguments: arguments.map((e) => e.substitute(bindings)).toList(),
  );

  @override
  Term reduce() {
    final FunctionTerm function = getFunctionTerm(callee);

    return function.apply(arguments);
  }

  FunctionTerm getFunctionTerm(Term callee) {
    final Term reduced = callee.reduce();
    if (reduced is FunctionTerm) {
      return reduced;
    }
    throw InvalidFunctionError(callee.toString());
  }

  @override
  Type get type => const FunctionCallType();

  @override
  String toString() => '$callee(${arguments.join(', ')})';

  @override
  dynamic native() => reduce().native();
}

/// Represents a function in the runtime.
///
/// **Threading assumption**: The static recursion tracking (`_currentDepth`)
/// assumes single-threaded execution. The Primal runtime is designed for
/// single-threaded use only. Do not share a [RuntimeFacade] across threads
/// or call evaluation methods concurrently, as this will cause incorrect
/// recursion limit enforcement.
abstract class FunctionTerm extends Term {
  static const int maxRecursionDepth = 1000;
  static int _currentDepth = 0;

  final String name;
  final List<Parameter> parameters;

  const FunctionTerm({
    required this.name,
    required this.parameters,
  });

  List<Type> get parameterTypes => parameters.map((e) => e.type).toList();

  bool equalSignature(FunctionTerm function) => function.name == name;

  /// Returns a phase-agnostic signature for this function.
  FunctionSignature toSignature() => FunctionSignature(
    name: name,
    parameters: parameters,
  );

  /// Resets the recursion depth counter. Call this before starting evaluation.
  static void resetDepth() {
    _currentDepth = 0;
  }

  /// Increments recursion depth, throwing if limit exceeded.
  /// Returns true if depth was incremented (caller must decrement).
  static bool incrementDepth() {
    if (_currentDepth >= maxRecursionDepth) {
      throw RecursionLimitError(limit: maxRecursionDepth);
    }
    _currentDepth++;
    return true;
  }

  /// Decrements recursion depth.
  static void decrementDepth() {
    _currentDepth--;
  }

  Term apply(List<Term> arguments) {
    if (parameters.length != arguments.length) {
      throw InvalidArgumentCountError(
        function: name,
        expected: parameters.length,
        actual: arguments.length,
      );
    }

    final Bindings bindings = Bindings.from(
      parameters: parameters,
      arguments: arguments,
    );

    return substitute(bindings).reduce();
  }

  @override
  Type get type => const FunctionType();

  @override
  String toString() =>
      '$name(${parameters.map((e) => '${e.name}: ${e.type}').join(', ')})';

  @override
  dynamic native() => toString();
}

class CustomFunctionTerm extends FunctionTerm {
  final Term term;

  const CustomFunctionTerm({
    required super.name,
    required super.parameters,
    required this.term,
  });

  @override
  Term apply(List<Term> arguments) {
    if (parameters.length != arguments.length) {
      throw InvalidArgumentCountError(
        function: name,
        expected: parameters.length,
        actual: arguments.length,
      );
    }

    FunctionTerm.incrementDepth();
    try {
      // Eagerly evaluate all arguments once before binding (call-by-value).
      final List<Term> evaluatedArguments = arguments
          .map((argument) => argument.reduce())
          .toList();

      final Bindings bindings = Bindings.from(
        parameters: parameters,
        arguments: evaluatedArguments,
      );

      // Directly substitute into body and reduce.
      return term.substitute(bindings).reduce();
    } finally {
      FunctionTerm.decrementDepth();
    }
  }

  // Custom functions are closed values - external substitution doesn't affect
  // them. The function's internal variables are bound at application time via
  // apply(), not during external substitution. This prevents variable capture
  // bugs when a function is captured by a lambda that uses the same variable
  // names.
  @override
  Term substitute(Bindings bindings) => this;
}

/// A lambda function term (anonymous inline function).
///
/// Lambdas are first-class values that capture their definition environment.
/// They support closures—captured variables from outer scope are substituted
/// into the body at creation time, while lambda parameters remain as
/// [LambdaBoundVariableTerm] references until the lambda is applied.
class LambdaTerm extends FunctionTerm {
  final Term body;

  const LambdaTerm({
    required super.name,
    required super.parameters,
    required this.body,
  });

  @override
  Term substitute(Bindings bindings) {
    // Propagate substitution through the body.
    // LambdaBoundVariableTerm references survive (partial substitution).
    // Other bound variables (captured from outer scope) get substituted.
    //
    // IMPORTANT: Remove bindings for this lambda's own parameters before
    // substituting into the body. This prevents outer substitutions from
    // affecting inner lambda parameters with the same names. For example,
    // in `((x) -> (x) -> x)(1)`, substituting {x: 1} into the outer lambda
    // should NOT affect the inner lambda's parameter x.
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

  @override
  Term reduce() => this; // Lambdas are values; they don't reduce further

  // Why we override apply() instead of using FunctionTerm.apply():
  //
  // FunctionTerm.apply() uses: substitute(bindings).reduce()
  // CustomFunctionTerm.substitute() returns: term.substitute(bindings) [unwrapped body]
  // LambdaTerm.substitute() returns: LambdaTerm(..., body.substitute(bindings)) [preserves wrapper]
  //
  // If we used the base class pattern:
  //   1. substitute(bindings) → returns a LambdaTerm (wrapper preserved)
  //   2. reduce() on LambdaTerm → returns this (lambdas are values)
  //   3. Result: a LambdaTerm, NOT the evaluated body!
  //
  // So we must substitute directly into the body and reduce that result.
  // This is analogous to CustomFunctionTerm.apply() which also overrides
  // to add call-by-value argument evaluation.
  @override
  Term apply(List<Term> arguments) {
    if (arguments.length != parameters.length) {
      throw InvalidArgumentCountError(
        function: name,
        expected: parameters.length,
        actual: arguments.length,
      );
    }
    FunctionTerm.incrementDepth();
    try {
      // Evaluate arguments (call-by-value)
      final List<Term> evaluatedArguments = arguments
          .map((argument) => argument.reduce())
          .toList();

      // Create bindings and substitute into body
      final Bindings bindings = Bindings.from(
        parameters: parameters,
        arguments: evaluatedArguments,
      );
      final Term substituted = body.substitute(bindings);
      return substituted.reduce();
    } finally {
      FunctionTerm.decrementDepth();
    }
  }

  @override
  dynamic native() => toString();

  // Override to print parameter names only (no types).
  // Lambda parameters are always untyped in source, so showing ": any" is noise.
  // Named functions print "f(x: Number)" but lambdas print "<lambda@1:1>(x)".
  @override
  String toString() =>
      '$name(${parameters.map((parameter) => parameter.name).join(', ')})';
}

abstract class NativeFunctionTerm extends FunctionTerm {
  const NativeFunctionTerm({
    required super.name,
    required super.parameters,
  });

  @override
  Term substitute(Bindings bindings) {
    final List<Term> arguments = parameters
        .map((e) => bindings.get(e.name))
        .toList();

    return term(arguments);
  }

  Term term(List<Term> arguments);
}

abstract class NativeFunctionTermWithArguments extends FunctionTerm {
  final List<Term> arguments;

  const NativeFunctionTermWithArguments({
    required super.name,
    required super.parameters,
    required this.arguments,
  });

  @override
  Term reduce();
}
