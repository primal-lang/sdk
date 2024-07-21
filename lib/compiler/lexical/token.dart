import 'package:dry/compiler/errors/lexical_error.dart';
import 'package:dry/compiler/input/location.dart';
import 'package:dry/compiler/lexical/lexical_analyzer.dart';
import 'package:dry/extensions/string_extensions.dart';

class Token<T> extends Localized {
  final T value;

  const Token({
    required this.value,
    required super.location,
  });

  static Token separator(Lexeme lexeme) {
    final String value = lexeme.value;

    if (value.isComma) {
      return CommaToken(lexeme);
    } else if (value.isEquals) {
      return EqualsToken(lexeme);
    } else if (value.isOpenParenthesis) {
      return OpenParenthesisToken(lexeme);
    } else if (value.isCloseParenthesis) {
      return CloseParenthesisToken(lexeme);
    } else {
      throw LexicalError.invalidLexeme(lexeme);
    }
  }

  @override
  String toString() => '$value at $location';
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
