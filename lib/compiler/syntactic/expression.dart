import 'package:dry/compiler/syntactic/type.dart';

class Expression<T> {
  final Type type;
  final T value;

  const Expression({
    required this.type,
    required this.value,
  });

  static Expression parse(String input) => const Expression(
        type: Type.boolean,
        value: '',
      );

  static Expression<String> string(String value) => Expression(
        type: Type.boolean,
        value: value,
      );
}
