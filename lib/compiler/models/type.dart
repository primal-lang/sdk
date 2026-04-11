class Type {
  const Type();

  /// Returns true if this type specification accepts the given actual type.
  bool accepts(Type actualType) => this == actualType;

  @override
  bool operator ==(Object other) => runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
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
  bool accepts(Type actualType) => true;

  @override
  String toString() => 'Any';
}

// Type Classes

abstract class TypeClass extends Type {
  const TypeClass();

  List<Type> get memberTypes;

  @override
  bool accepts(Type actualType) =>
      memberTypes.any((Type type) => type == actualType);
}

class OrderedType extends TypeClass {
  const OrderedType();

  @override
  List<Type> get memberTypes => const [
    NumberType(),
    StringType(),
    TimestampType(),
  ];

  @override
  String toString() => 'Ordered';
}

class EquatableType extends TypeClass {
  const EquatableType();

  @override
  List<Type> get memberTypes => const [
    BooleanType(),
    NumberType(),
    StringType(),
    FileType(),
    DirectoryType(),
    TimestampType(),
    VectorType(),
    StackType(),
    QueueType(),
    SetType(),
    ListType(),
    MapType(),
  ];

  @override
  String toString() => 'Equatable';
}

class HashableType extends TypeClass {
  const HashableType();

  @override
  List<Type> get memberTypes => const [
    NumberType(),
    StringType(),
    BooleanType(),
    TimestampType(),
  ];

  @override
  String toString() => 'Hashable';
}

class IndexableType extends TypeClass {
  const IndexableType();

  @override
  List<Type> get memberTypes => const [
    StringType(),
    ListType(),
    MapType(),
  ];

  @override
  String toString() => 'Indexable';
}

class CollectionType extends TypeClass {
  const CollectionType();

  @override
  List<Type> get memberTypes => const [
    ListType(),
    SetType(),
    StackType(),
    QueueType(),
    MapType(),
  ];

  @override
  String toString() => 'Collection';
}

class IterableType extends TypeClass {
  const IterableType();

  @override
  List<Type> get memberTypes => const [
    StringType(),
    ListType(),
    SetType(),
    StackType(),
    QueueType(),
  ];

  @override
  String toString() => 'Iterable';
}

class AddableType extends TypeClass {
  const AddableType();

  @override
  List<Type> get memberTypes => const [
    NumberType(),
    StringType(),
    VectorType(),
    ListType(),
    SetType(),
  ];

  @override
  String toString() => 'Addable';
}

class SubtractableType extends TypeClass {
  const SubtractableType();

  @override
  List<Type> get memberTypes => const [
    NumberType(),
    VectorType(),
    SetType(),
  ];

  @override
  String toString() => 'Subtractable';
}
