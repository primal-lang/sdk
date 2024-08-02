import 'package:purified/compiler/models/type.dart';

class Parameter {
  final String name;
  final Type type;

  const Parameter._({
    required this.name,
    required this.type,
  });

  factory Parameter.string(String name) => Parameter._(
        name: name,
        type: const StringType(),
      );

  factory Parameter.number(String name) => Parameter._(
        name: name,
        type: const NumberType(),
      );

  factory Parameter.boolean(String name) => Parameter._(
        name: name,
        type: const BooleanType(),
      );

  factory Parameter.any(String name) => Parameter._(
        name: name,
        type: const AnyType(),
      );
}
