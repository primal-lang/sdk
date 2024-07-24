import 'package:dry/compiler/models/location.dart';
import 'package:dry/compiler/runtime/runtime.dart';
import 'package:dry/compiler/runtime/scope.dart';
import 'package:dry/compiler/semantic/function_prototype.dart';

abstract class Reducible {
  const Reducible();

  String get type;

  Reducible bind(Scope<Reducible> arguments);

  Reducible evaluate();
}

abstract class ReducibleValue<T> implements Reducible {
  final T value;

  const ReducibleValue(this.value);

  @override
  String toString() => value.toString();

  @override
  Reducible bind(Scope<Reducible> arguments) => this;

  @override
  Reducible evaluate() => this;
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
  Reducible bind(Scope<Reducible> arguments) => arguments.get(value);

  @override
  Reducible evaluate() {
    /*final Reducible reducible = scope.get(value);

    if (reducible is FunctionPrototype) {
      return reducible.evaluate(arguments, scope);
    } else if (reducible is ExpressionReducible) {
      return reducible.evaluate(arguments, scope);
    } else if (reducible is ReducibleValue) {
      return reducible;
    } else {
      throw FunctionInvocationError(value);
    }*/

    return this;
  }

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
  Reducible bind(Scope<Reducible> arguments) => ExpressionReducible(
        name: name,
        arguments: this.arguments.map((e) => e.bind(arguments)).toList(),
        location: location,
      );

  @override
  Reducible evaluate() {
    final FunctionPrototype function = Runtime.SCOPE.get(name);
    final Scope<Reducible> newScope = Runtime.SCOPE.from(
      functionName: name,
      parameters: function.parameters,
      arguments: arguments,
    );

    return function.bind(newScope).evaluate();
  }

  @override
  String get type => '$name(${arguments.join(', ')})';

  @override
  String toString() => '$name(${arguments.join(', ')})';
}
