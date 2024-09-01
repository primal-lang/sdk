import 'package:primal/compiler/models/location.dart';
import 'package:primal/compiler/models/type.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

abstract class Reducible {
  const Reducible();

  Type get type;

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

class BooleanReducibleValue extends ReducibleValue<bool> {
  const BooleanReducibleValue(super.value);

  @override
  Type get type => const BooleanType();
}

class NumberReducibleValue extends ReducibleValue<num> {
  const NumberReducibleValue(super.value);

  @override
  Type get type => const NumberType();
}

class StringReducibleValue extends ReducibleValue<String> {
  const StringReducibleValue(super.value);

  @override
  Type get type => const StringType();
}

class ListReducibleValue extends ReducibleValue<List<Reducible>> {
  const ListReducibleValue(super.value);

  @override
  Type get type => const ListType();

  @override
  Reducible substitute(Scope<Reducible> arguments) =>
      ListReducibleValue(value.map((e) => e.substitute(arguments)).toList());
}

class IdentifierReducible extends Reducible {
  final String value;
  final Location location;

  const IdentifierReducible({
    required this.value,
    required this.location,
  });

  @override
  Reducible substitute(Scope<Reducible> arguments) => arguments.get(value);

  @override
  Reducible reduce() => this;

  @override
  Type get type => const AnyType();

  @override
  String toString() => value;
}

class CallReducible extends Reducible {
  final String name;
  final List<Reducible> arguments;
  final Location location;

  const CallReducible({
    required this.name,
    required this.arguments,
    required this.location,
  });

  @override
  Reducible substitute(Scope<Reducible> arguments) => CallReducible(
        name: name,
        arguments: this.arguments.map((e) => e.substitute(arguments)).toList(),
        location: location,
      );

  @override
  Reducible reduce() {
    final FunctionPrototype function = Runtime.SCOPE.get(name);
    final Scope<Reducible> newScope = Scope.from(
      functionName: name,
      parameters: function.parameters,
      arguments: arguments,
      location: location,
    );

    return function.substitute(newScope).reduce();
  }

  @override
  Type get type => const FunctionType();

  @override
  String toString() => '$name(${arguments.join(', ')})';
}
