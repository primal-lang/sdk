import 'package:primal/compiler/lexical/lexeme.dart';
import 'package:primal/compiler/models/located.dart';

class Token<T> extends Located {
  final T value;

  const Token({
    required this.value,
    required super.location,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Token<T> &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          location == other.location;

  @override
  int get hashCode => Object.hash(runtimeType, value, location);

  @override
  String toString() => '"$value" at $location';
}

class StringToken extends Token<String> {
  StringToken(Lexeme lexeme)
    : super(
        value: lexeme.value,
        location: lexeme.location,
      );
}

/// The lexeme value must contain only digits and optional decimal/exponent
/// notation. Underscores in source (e.g., `1_000`) are stripped by the lexer.
class NumberToken extends Token<num> {
  NumberToken(Lexeme lexeme)
    : super(
        value: num.parse(lexeme.value),
        location: lexeme.location,
      );
}

class BooleanToken extends Token<bool> {
  BooleanToken(Lexeme lexeme)
    : super(
        value: bool.parse(lexeme.value),
        location: lexeme.location,
      );
}

class IdentifierToken extends Token<String> {
  IdentifierToken(Lexeme lexeme)
    : super(
        value: lexeme.value,
        location: lexeme.location,
      );
}

class IfToken extends Token<String> {
  IfToken(Lexeme lexeme)
    : super(
        value: lexeme.value,
        location: lexeme.location,
      );
}

class ElseToken extends Token<String> {
  ElseToken(Lexeme lexeme)
    : super(
        value: lexeme.value,
        location: lexeme.location,
      );
}

class MinusToken extends Token<String> {
  MinusToken(Lexeme lexeme)
    : super(
        value: lexeme.value,
        location: lexeme.location,
      );
}

class PlusToken extends Token<String> {
  PlusToken(Lexeme lexeme)
    : super(
        value: lexeme.value,
        location: lexeme.location,
      );
}

class ForwardSlashToken extends Token<String> {
  ForwardSlashToken(Lexeme lexeme)
    : super(
        value: lexeme.value,
        location: lexeme.location,
      );
}

class AsteriskToken extends Token<String> {
  AsteriskToken(Lexeme lexeme)
    : super(
        value: lexeme.value,
        location: lexeme.location,
      );
}

class PercentToken extends Token<String> {
  PercentToken(Lexeme lexeme)
    : super(
        value: lexeme.value,
        location: lexeme.location,
      );
}

class AtToken extends Token<String> {
  AtToken(Lexeme lexeme)
    : super(
        value: lexeme.value,
        location: lexeme.location,
      );
}

class PipeToken extends Token<String> {
  PipeToken(Lexeme lexeme)
    : super(
        value: lexeme.value,
        location: lexeme.location,
      );
}

class AmpersandToken extends Token<String> {
  AmpersandToken(Lexeme lexeme)
    : super(
        value: lexeme.value,
        location: lexeme.location,
      );
}

class BangToken extends Token<String> {
  BangToken(Lexeme lexeme)
    : super(
        value: lexeme.value,
        location: lexeme.location,
      );
}

class EqualToken extends Token<String> {
  EqualToken(Lexeme lexeme)
    : super(
        value: lexeme.value,
        location: lexeme.location,
      );
}

class NotEqualToken extends Token<String> {
  NotEqualToken(Lexeme lexeme)
    : super(
        value: lexeme.value,
        location: lexeme.location,
      );
}

class GreaterThanToken extends Token<String> {
  GreaterThanToken(Lexeme lexeme)
    : super(
        value: lexeme.value,
        location: lexeme.location,
      );
}

class GreaterOrEqualToken extends Token<String> {
  GreaterOrEqualToken(Lexeme lexeme)
    : super(
        value: lexeme.value,
        location: lexeme.location,
      );
}

class LessThanToken extends Token<String> {
  LessThanToken(Lexeme lexeme)
    : super(
        value: lexeme.value,
        location: lexeme.location,
      );
}

class LessOrEqualToken extends Token<String> {
  LessOrEqualToken(Lexeme lexeme)
    : super(
        value: lexeme.value,
        location: lexeme.location,
      );
}

class AssignToken extends Token<String> {
  AssignToken(Lexeme lexeme)
    : super(
        value: lexeme.value,
        location: lexeme.location,
      );
}

class CommaToken extends Token<String> {
  CommaToken(Lexeme lexeme)
    : super(
        value: lexeme.value,
        location: lexeme.location,
      );
}

class ColonToken extends Token<String> {
  ColonToken(Lexeme lexeme)
    : super(
        value: lexeme.value,
        location: lexeme.location,
      );
}

class OpenParenthesisToken extends Token<String> {
  OpenParenthesisToken(Lexeme lexeme)
    : super(
        value: lexeme.value,
        location: lexeme.location,
      );
}

class CloseParenthesisToken extends Token<String> {
  CloseParenthesisToken(Lexeme lexeme)
    : super(
        value: lexeme.value,
        location: lexeme.location,
      );
}

class OpenBracketToken extends Token<String> {
  OpenBracketToken(Lexeme lexeme)
    : super(
        value: lexeme.value,
        location: lexeme.location,
      );
}

class CloseBracketToken extends Token<String> {
  CloseBracketToken(Lexeme lexeme)
    : super(
        value: lexeme.value,
        location: lexeme.location,
      );
}

class OpenBracesToken extends Token<String> {
  OpenBracesToken(Lexeme lexeme)
    : super(
        value: lexeme.value,
        location: lexeme.location,
      );
}

class CloseBracesToken extends Token<String> {
  CloseBracesToken(Lexeme lexeme)
    : super(
        value: lexeme.value,
        location: lexeme.location,
      );
}
