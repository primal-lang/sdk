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

abstract class LiteralTerm<T> implements Term {
  final T value;

  const LiteralTerm(this.value);

  @override
  String toString() => value.toString();

  @override
  Term substitute(Bindings bindings) => this;

  @override
  Term reduce() => this;

  @override
  dynamic native() => value;

  static LiteralTerm from(dynamic value) {
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

class BooleanTerm extends LiteralTerm<bool> {
  const BooleanTerm(super.value);

  @override
  Type get type => const BooleanType();
}

class NumberTerm extends LiteralTerm<num> {
  const NumberTerm(super.value);

  @override
  Type get type => const NumberType();
}

class StringTerm extends LiteralTerm<String> {
  const StringTerm(super.value);

  @override
  Type get type => const StringType();
}

class FileTerm extends LiteralTerm<File> {
  const FileTerm(super.value);

  @override
  Type get type => const FileType();
}

class DirectoryTerm extends LiteralTerm<Directory> {
  const DirectoryTerm(super.value);

  @override
  Type get type => const DirectoryType();
}

class TimestampTerm extends LiteralTerm<DateTime> {
  const TimestampTerm(super.value);

  @override
  Type get type => const TimestampType();
}

class ListTerm extends LiteralTerm<List<Term>> {
  const ListTerm(super.value);

  @override
  Type get type => const ListType();

  @override
  Term substitute(Bindings bindings) =>
      ListTerm(value.map((e) => e.substitute(bindings)).toList());

  @override
  List native() => value.map((e) => e.native()).toList();
}

class VectorTerm extends LiteralTerm<List<Term>> {
  const VectorTerm(super.value);

  @override
  Type get type => const VectorType();

  @override
  Term substitute(Bindings bindings) =>
      VectorTerm(value.map((e) => e.substitute(bindings)).toList());

  @override
  List native() => value.map((e) => e.native()).toList();
}

class SetTerm extends LiteralTerm<Set<Term>> {
  const SetTerm(super.value);

  @override
  Type get type => const SetType();

  @override
  Term substitute(Bindings bindings) =>
      SetTerm(value.map((e) => e.substitute(bindings)).toSet());

  @override
  Set native() => value.map((e) => e.native()).toSet();
}

class StackTerm extends LiteralTerm<List<Term>> {
  const StackTerm(super.value);

  @override
  Type get type => const StackType();

  @override
  Term substitute(Bindings bindings) =>
      StackTerm(value.map((e) => e.substitute(bindings)).toList());

  @override
  List native() => value.map((e) => e.native()).toList();
}

class QueueTerm extends LiteralTerm<List<Term>> {
  const QueueTerm(super.value);

  @override
  Type get type => const QueueType();

  @override
  Term substitute(Bindings bindings) =>
      QueueTerm(value.map((e) => e.substitute(bindings)).toList());

  @override
  List native() => value.map((e) => e.native()).toList();
}

class MapTerm extends LiteralTerm<Map<Term, Term>> {
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
    if (callee is CallTerm) {
      return getFunctionTerm(callee.reduce());
    } else if (callee is FunctionReferenceTerm) {
      return callee.reduce();
    } else if (callee is FunctionTerm) {
      return callee;
    } else {
      throw InvalidFunctionError(callee.toString());
    }
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
class FunctionTerm extends Term {
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
      final Bindings bindings = Bindings.from(
        parameters: parameters,
        arguments: arguments,
      );
      return substitute(bindings).reduce();
    } finally {
      FunctionTerm.decrementDepth();
    }
  }

  @override
  Term substitute(Bindings bindings) => term.substitute(bindings);
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

class NativeFunctionTermWithArguments extends FunctionTerm {
  final List<Term> arguments;

  const NativeFunctionTermWithArguments({
    required super.name,
    required super.parameters,
    required this.arguments,
  });
}
