import 'package:primal/compiler/lexical/lexeme.dart';
import 'package:primal/compiler/models/location.dart';

class Character extends Located {
  final String value;

  const Character({
    required this.value,
    required super.location,
  });

  Lexeme get lexeme => Lexeme(
    value: value,
    location: location,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Character && value == other.value && location == other.location;

  @override
  int get hashCode => Object.hash(value, location);

  @override
  String toString() => '"$value" at $location';
}
