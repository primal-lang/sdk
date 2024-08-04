import 'package:primal/compiler/errors/generic_error.dart';
import 'package:primal/compiler/input/character.dart';
import 'package:primal/compiler/lexical/lexical_analyzer.dart';

class LexicalError extends GenericError {
  const LexicalError(super.message);
}

class InvalidCharacterError extends LexicalError {
  const InvalidCharacterError(Character character)
      : super('Invalid character $character');
}

class InvalidLexemeError extends LexicalError {
  const InvalidLexemeError(Lexeme lexeme) : super('Invalid character $lexeme');
}
