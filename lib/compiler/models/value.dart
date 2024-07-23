import 'package:dry/compiler/models/reducible.dart';
import 'package:dry/compiler/models/scope.dart';

abstract class Value<T> implements Reducible {
  final T value;

  const Value(this.value);

  @override
  String toString() => value.toString();

  @override
  Reducible evaluate(List<Reducible> arguments, Scope scope) => this;
}

class StringValue extends Value<String> {
  const StringValue(super.value);

  @override
  String get type => 'String';

  @override
  String toString() => '"$value"';
}

class NumberValue extends Value<num> {
  const NumberValue(super.value);

  @override
  String get type => 'Number';
}

class BooleanValue extends Value<bool> {
  const BooleanValue(super.value);

  @override
  String get type => 'Boolean';
}
