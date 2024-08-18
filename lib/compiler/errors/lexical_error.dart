import 'package:primal/compiler/errors/generic_error.dart';
import 'package:primal/compiler/input/character.dart';

class LexicalError extends GenericError {
  const LexicalError(super.message);
}

class InvalidCharacterError extends LexicalError {
  const InvalidCharacterError(Character character)
      : super('Invalid character $character');
}
