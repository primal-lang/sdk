import 'package:primal/compiler/models/location.dart';
import 'package:primal/compiler/reader/character.dart';

class Lexeme extends Located {
  final String value;

  const Lexeme({
    required this.value,
    required super.location,
  });

  Lexeme add(Character character) => Lexeme(
    value: value + character.value,
    location: location,
  );

  Lexeme addValue(String value) => Lexeme(
    value: this.value + value,
    location: location,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Lexeme && value == other.value && location == other.location;

  @override
  int get hashCode => Object.hash(value, location);

  @override
  String toString() => '"$value" at $location';
}
