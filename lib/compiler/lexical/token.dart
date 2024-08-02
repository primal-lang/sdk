import 'package:purified/compiler/lexical/lexical_analyzer.dart';
import 'package:purified/compiler/models/location.dart';

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

class SymbolToken extends Token<String> {
  SymbolToken(Lexeme lexeme)
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

class EqualsToken extends Token<String> {
  EqualsToken(Lexeme lexeme)
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
