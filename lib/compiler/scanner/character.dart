import 'package:primal/compiler/lexical/lexical_analyzer.dart';
import 'package:primal/compiler/models/location.dart';

class Character extends Localized {
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
  String toString() => '"$value" at $location';
}
