import 'package:dry/compiler/errors/runtime_error.dart';
import 'package:dry/compiler/models/location.dart';
import 'package:dry/compiler/models/scope.dart';
import 'package:dry/compiler/semantic/function_prototype.dart';

abstract class Reducible {
  const Reducible();

  String get type;

  Reducible evaluate(Scope arguments, Scope scope);
}

abstract class ReducibleValue<T> implements Reducible {
  final T value;

  const ReducibleValue(this.value);

  @override
  String toString() => value.toString();

  @override
  Reducible evaluate(Scope arguments, Scope scope) => this;
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
  Reducible evaluate(Scope arguments, Scope scope) {
    final Reducible reducible = scope.get(value);

    if (reducible is FunctionPrototype) {
      return reducible.evaluate(arguments, scope);
    } else if (reducible is ExpressionReducible) {
      return reducible.evaluate(arguments, scope);
    } else if (reducible is ReducibleValue) {
      return reducible;
    } else {
      throw FunctionInvocationError(value);
    }
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
  Reducible evaluate(Scope arguments, Scope scope) {
    final Reducible reducible = scope.get(name);

    if (reducible is CustomFunctionPrototype) {
      final Scope newScope = Scope.from(
        functionName: name,
        parameters: reducible.parameters,
        arguments: this.arguments,
      );

      return reducible.evaluate(newScope, scope);
    } else if (reducible is NativeFunctionPrototype) {
      final Scope newScope = Scope.from(
        functionName: name,
        parameters: reducible.parameters,
        arguments: this.arguments,
      );

      return reducible.evaluate(newScope, scope);
    } else {
      throw FunctionInvocationError(name);
    }
  }

  @override
  String get type => '$name(${arguments.join(', ')})';

  @override
  String toString() => '$name(${arguments.join(', ')})';
}
