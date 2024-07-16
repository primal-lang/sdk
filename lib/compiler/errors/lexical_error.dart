import 'package:dry/compiler/input/character.dart';

class LexicalError implements Exception {
  final String message;

  const LexicalError(this.message);

  factory LexicalError.invalidCharacter(Character character) =>
      LexicalError('Invalid character $character');

  factory LexicalError.invalidSeparator(String value) =>
      LexicalError('Invalid separator $value');

  @override
  String toString() => message;
}
