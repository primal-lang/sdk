class Type {
  const Type();
}

class BooleanType extends Type {
  const BooleanType();

  @override
  String toString() => 'Boolean';
}

class NumberType extends Type {
  const NumberType();

  @override
  String toString() => 'Number';
}

class StringType extends Type {
  const StringType();

  @override
  String toString() => 'String';
}

class FileType extends Type {
  const FileType();

  @override
  String toString() => 'File';
}

class DirectoryType extends Type {
  const DirectoryType();

  @override
  String toString() => 'Directory';
}

class TimestampType extends Type {
  const TimestampType();

  @override
  String toString() => 'Timestamp';
}

class VectorType extends Type {
  const VectorType();

  @override
  String toString() => 'Vector';
}

class StackType extends Type {
  const StackType();

  @override
  String toString() => 'Stack';
}

class QueueType extends Type {
  const QueueType();

  @override
  String toString() => 'Queue';
}

class SetType extends Type {
  const SetType();

  @override
  String toString() => 'Set';
}

class ListType extends Type {
  const ListType();

  @override
  String toString() => 'List';
}

class MapType extends Type {
  const MapType();

  @override
  String toString() => 'Map';
}

class FunctionCallType extends Type {
  const FunctionCallType();

  @override
  String toString() => 'FunctionCall';
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
