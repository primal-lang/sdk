import 'package:primal/compiler/errors/generic_error.dart';
import 'package:primal/compiler/scanner/character.dart';

class LexicalError extends CompilationError {
  const LexicalError(super.message);
}

class InvalidCharacterError extends LexicalError {
  const InvalidCharacterError(Character character, [String? expected])
      : super(
            'Invalid character $character${(expected != null) ? '. Expected: $expected' : ''}');
}
