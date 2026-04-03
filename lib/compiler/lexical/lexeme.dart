import 'package:primal/compiler/models/location.dart';

class Lexeme extends Located {
  final String value;

  const Lexeme({
    required this.value,
    required super.location,
  });

  Lexeme add(String charValue) => Lexeme(
    value: value + charValue,
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
