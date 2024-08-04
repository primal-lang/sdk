import 'package:primal/compiler/models/location.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

abstract class Reducible {
  const Reducible();

  String get type;

  Reducible substitute(Scope<Reducible> arguments);

  Reducible reduce();
}

abstract class ReducibleValue<T> implements Reducible {
  final T value;

  const ReducibleValue(this.value);

  @override
  String toString() => value.toString();

  @override
  Reducible substitute(Scope<Reducible> arguments) => this;

  @override
  Reducible reduce() => this;
}

class StringReducibleValue extends ReducibleValue<String> {
  const StringReducibleValue(super.value);

  @override
  String get type => 'String';

  @override
  String toString() => '"$value"';
}

class NumberReducibleValue extends ReducibleValue<num> {
  const NumberReducibleValue(super.value);

  @override
  String get type => 'Number';
}

class BooleanReducibleValue extends ReducibleValue<bool> {
  const BooleanReducibleValue(super.value);

  @override
  String get type => 'Boolean';
}

class SymbolReducible extends Reducible {
  final String value;
  final Location location;

  const SymbolReducible({
    required this.value,
    required this.location,
  });

  @override
  Reducible substitute(Scope<Reducible> arguments) => arguments.get(value);

  @override
  Reducible reduce() => this;

  @override
  String get type => 'Symbol';

  @override
  String toString() => value;
}

class ExpressionReducible extends Reducible {
  final String name;
  final List<Reducible> arguments;
  final Location location;

  const ExpressionReducible({
    required this.name,
    required this.arguments,
    required this.location,
  });

  @override
  Reducible substitute(Scope<Reducible> arguments) => ExpressionReducible(
        name: name,
        arguments: this.arguments.map((e) => e.substitute(arguments)).toList(),
        location: location,
      );

  @override
  Reducible reduce() {
    final FunctionPrototype function =
        Runtime.SCOPE.get('$name/${arguments.length}');
    final Scope<Reducible> newScope = Scope.from(
      functionName: name,
      parameters: function.parameters,
      arguments: arguments,
      location: location,
    );

    return function.substitute(newScope).reduce();
  }

  @override
  String get type => 'Function';

  @override
  String toString() => '$name(${arguments.join(', ')})';
}
