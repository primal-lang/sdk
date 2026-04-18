import 'package:primal/compiler/models/type.dart';

class Parameter {
  final String name;
  final Type type;

  const Parameter._({
    required this.name,
    required this.type,
  });

  const Parameter.boolean(String name)
    : this._(name: name, type: const BooleanType());

  const Parameter.number(String name)
    : this._(name: name, type: const NumberType());

  const Parameter.string(String name)
    : this._(name: name, type: const StringType());

  const Parameter.file(String name)
    : this._(name: name, type: const FileType());

  const Parameter.directory(String name)
    : this._(name: name, type: const DirectoryType());

  const Parameter.timestamp(String name)
    : this._(name: name, type: const TimestampType());

  const Parameter.duration(String name)
    : this._(name: name, type: const DurationType());

  const Parameter.list(String name)
    : this._(name: name, type: const ListType());

  const Parameter.vector(String name)
    : this._(name: name, type: const VectorType());

  const Parameter.set(String name) : this._(name: name, type: const SetType());

  const Parameter.stack(String name)
    : this._(name: name, type: const StackType());

  const Parameter.queue(String name)
    : this._(name: name, type: const QueueType());

  const Parameter.map(String name) : this._(name: name, type: const MapType());

  const Parameter.function(String name)
    : this._(name: name, type: const FunctionType());

  const Parameter.any(String name) : this._(name: name, type: const AnyType());

  const Parameter.ordered(String name)
    : this._(name: name, type: const OrderedType());

  const Parameter.equatable(String name)
    : this._(name: name, type: const EquatableType());

  const Parameter.hashable(String name)
    : this._(name: name, type: const HashableType());

  const Parameter.indexable(String name)
    : this._(name: name, type: const IndexableType());

  const Parameter.collection(String name)
    : this._(name: name, type: const CollectionType());

  const Parameter.iterable(String name)
    : this._(name: name, type: const IterableType());

  const Parameter.addable(String name)
    : this._(name: name, type: const AddableType());

  const Parameter.subtractable(String name)
    : this._(name: name, type: const SubtractableType());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Parameter && name == other.name && type == other.type;

  @override
  int get hashCode => Object.hash(name, type);

  @override
  String toString() => name;
}
