import 'package:dry/compiler/models/type.dart';

class Parameter {
  final String name;
  final Type type;

  const Parameter({
    required this.name,
    required this.type,
  });
}
