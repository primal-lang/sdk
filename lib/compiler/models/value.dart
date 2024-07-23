class Value<T> {
  final T value;

  const Value(this.value);
}

class StringValue extends Value<String> {
  const StringValue(super.value);
}

class NumberValue extends Value<int> {
  const NumberValue(super.value);
}

class BooleanValue extends Value<bool> {
  const BooleanValue(super.value);
}
