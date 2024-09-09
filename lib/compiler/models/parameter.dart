import 'package:primal/compiler/models/type.dart';

class Parameter {
  final String name;
  final Type type;

  const Parameter._({
    required this.name,
    required this.type,
  });

  factory Parameter.boolean(String name) => Parameter._(
        name: name,
        type: const BooleanType(),
      );

  factory Parameter.number(String name) => Parameter._(
        name: name,
        type: const NumberType(),
      );

  factory Parameter.string(String name) => Parameter._(
        name: name,
        type: const StringType(),
      );

  factory Parameter.timestamp(String name) => Parameter._(
        name: name,
        type: const TimestampType(),
      );

  factory Parameter.list(String name) => Parameter._(
        name: name,
        type: const ListType(),
      );

  factory Parameter.vector(String name) => Parameter._(
        name: name,
        type: const VectorType(),
      );

  factory Parameter.set(String name) => Parameter._(
        name: name,
        type: const SetType(),
      );

  factory Parameter.stack(String name) => Parameter._(
        name: name,
        type: const StackType(),
      );

  factory Parameter.map(String name) => Parameter._(
        name: name,
        type: const MapType(),
      );

  factory Parameter.function(String name) => Parameter._(
        name: name,
        type: const FunctionType(),
      );

  factory Parameter.any(String name) => Parameter._(
        name: name,
        type: const AnyType(),
      );

  @override
  String toString() => name;
}
