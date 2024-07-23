abstract class Value<T> {
  final T value;

  const Value(this.value);

  String get type;

  @override
  String toString() => value.toString();
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
