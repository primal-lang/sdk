import 'package:primal/compiler/errors/generic_error.dart';
import 'package:primal/compiler/models/location.dart';
import 'package:primal/compiler/scanner/character.dart';

class LexicalError extends CompilationError {
  const LexicalError(super.message);
}

class InvalidCharacterError extends LexicalError {
  const InvalidCharacterError(Character character, [String? expected])
    : super(
        'Invalid character $character${(expected != null) ? '. Expected: $expected' : ''}',
      );
}

class UnterminatedStringError extends LexicalError {
  const UnterminatedStringError(Location location)
    : super('Unterminated string starting at $location');
}

class UnterminatedCommentError extends LexicalError {
  const UnterminatedCommentError() : super('Unterminated multi-line comment');
}

class InvalidEscapeSequenceError extends LexicalError {
  InvalidEscapeSequenceError(Character character)
    : super(
        "Invalid escape sequence '\\${character.value}' at ${character.location}",
      );
}

class InvalidHexEscapeError extends LexicalError {
  InvalidHexEscapeError(Character character, String escapeType, int expected)
    : super(
        'Invalid hex escape: expected $expected hex digits after '
        "'\\$escapeType', got '${character.value}' at ${character.location}",
      );
}

class InvalidBracedEscapeError extends LexicalError {
  const InvalidBracedEscapeError(String message, Location location)
    : super('$message at $location');
}

class InvalidCodePointError extends LexicalError {
  InvalidCodePointError(int codePoint, Location location)
    : super(
        'Invalid code point U+${codePoint.toRadixString(16).toUpperCase().padLeft(4, '0')}: '
        'exceeds maximum U+10FFFF at $location',
      );
}
