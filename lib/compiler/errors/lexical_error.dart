import 'package:dry/compiler/input/character.dart';
import 'package:dry/compiler/lexical/lexical_analyzer.dart';

class LexicalError implements Exception {
  final String message;

  const LexicalError(this.message);

  factory LexicalError.invalidCharacter(Character character) =>
      LexicalError('Invalid character $character');

  factory LexicalError.invalidLexeme(Lexeme lexeme) =>
      LexicalError('Invalid character $lexeme');

  @override
  String toString() => message;
}
