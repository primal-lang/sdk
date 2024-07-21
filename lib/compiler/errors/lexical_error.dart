import 'package:dry/compiler/errors/generic_error.dart';
import 'package:dry/compiler/input/character.dart';
import 'package:dry/compiler/lexical/lexical_analyzer.dart';

class LexicalError extends GenericError {
  const LexicalError(super.message);

  factory LexicalError.invalidCharacter(Character character) =>
      LexicalError('Invalid character $character');

  factory LexicalError.invalidLexeme(Lexeme lexeme) =>
      LexicalError('Invalid character $lexeme');
}
