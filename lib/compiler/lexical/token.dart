import 'package:primal/compiler/lexical/lexical_analyzer.dart';
import 'package:primal/compiler/models/location.dart';

class Token<T> extends Localized {
  final T value;

  const Token({
    required this.value,
    required super.location,
  });

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

class GreaterEqualThanToken extends Token<String> {
  GreaterEqualThanToken(Lexeme lexeme)
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

class LessEqualThanToken extends Token<String> {
  LessEqualThanToken(Lexeme lexeme)
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
