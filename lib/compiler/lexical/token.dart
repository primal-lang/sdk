import 'package:dry/compiler/input/location.dart';
import 'package:dry/compiler/lexical/lexical_analyzer.dart';
import 'package:dry/extensions/string_extensions.dart';

class Token {
  final TokenType type;
  final String value;
  final Location location;

  const Token._({
    required this.type,
    required this.value,
    required this.location,
  });

  factory Token.string(Lexeme lexeme) => Token._(
        type: TokenType.string,
        value: lexeme.value,
        location: lexeme.location,
      );

  factory Token.number(Lexeme lexeme) => Token._(
        type: TokenType.number,
        value: lexeme.value,
        location: lexeme.location,
      );

  factory Token.boolean(Lexeme lexeme) {
    return Token._(
      type: TokenType.boolean,
      value: lexeme.value,
      location: lexeme.location,
    );
  }

  factory Token.symbol(Lexeme lexeme) => Token._(
        type: TokenType.symbol,
        value: lexeme.value,
        location: lexeme.location,
      );

  factory Token.comma(Lexeme lexeme) => Token._(
        type: TokenType.comma,
        value: lexeme.value,
        location: lexeme.location,
      );

  factory Token.equals(Lexeme lexeme) => Token._(
        type: TokenType.equals,
        value: lexeme.value,
        location: lexeme.location,
      );

  factory Token.openParenthesis(Lexeme lexeme) => Token._(
        type: TokenType.openParenthesis,
        value: lexeme.value,
        location: lexeme.location,
      );

  factory Token.closeParenthesis(Lexeme lexeme) => Token._(
        type: TokenType.closeParenthesis,
        value: lexeme.value,
        location: lexeme.location,
      );

  factory Token.separator(Lexeme lexeme) {
    final String value = lexeme.value;

    if (value.isComma) {
      return Token.comma(lexeme);
    } else if (value.isEquals) {
      return Token.equals(lexeme);
    } else if (value.isOpenParenthesis) {
      return Token.openParenthesis(lexeme);
    } else if (value.isCloseParenthesis) {
      return Token.closeParenthesis(lexeme);
    } else {
      throw Exception('Invalid separator');
    }
  }

  @override
  String toString() {
    return 'Token{type: ${type.name}, value: $value}';
  }
}

enum TokenType {
  string,
  number,
  boolean,
  symbol,
  comma,
  equals,
  openParenthesis,
  closeParenthesis,
}
