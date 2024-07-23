class Value<T> {
  final T value;

  const Value(this.value);
}

class StringValue extends Value<String> {
  const StringValue(super.value);
}

class IntegerValue extends Value<int> {
  const IntegerValue(super.value);
}

class BooleanValue extends Value<bool> {
  const BooleanValue(super.value);
}
