class Type {
  const Type();
}

class StringType extends Type {
  const StringType();

  @override
  String toString() => 'String';
}

class NumberType extends Type {
  const NumberType();

  @override
  String toString() => 'Number';
}

class BooleanType extends Type {
  const BooleanType();

  @override
  String toString() => 'Boolean';
}

class ListType extends Type {
  const ListType();

  @override
  String toString() => 'List';
}

class FunctionType extends Type {
  const FunctionType();

  @override
  String toString() => 'Function';
}

class AnyType extends Type {
  const AnyType();

  @override
  String toString() => 'Any';
}
