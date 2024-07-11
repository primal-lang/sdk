import 'package:dry/extensions/string_extensions.dart';

class Token {
  final TokenType type;
  final String value;

  const Token._({
    required this.type,
    required this.value,
  });

  factory Token.string(String value) => Token._(
        type: TokenType.string,
        value: value,
      );

  factory Token.number(String value) => Token._(
        type: TokenType.number,
        value: value,
      );

  factory Token.boolean(String value) {
    return Token._(
      type: TokenType.boolean,
      value: value,
    );
  }

  factory Token.symbol(String value) => Token._(
        type: TokenType.symbol,
        value: value,
      );

  factory Token.comma(String value) => Token._(
        type: TokenType.comma,
        value: value,
      );

  factory Token.equals(String value) => Token._(
        type: TokenType.equals,
        value: value,
      );

  factory Token.openParenthesis(String value) => Token._(
        type: TokenType.openParenthesis,
        value: value,
      );

  factory Token.closeParenthesis(String value) => Token._(
        type: TokenType.closeParenthesis,
        value: value,
      );

  factory Token.separator(String value) {
    if (value.isComma) {
      return Token.comma(value);
    } else if (value.isEquals) {
      return Token.equals(value);
    } else if (value.isOpenParenthesis) {
      return Token.openParenthesis(value);
    } else if (value.isCloseParenthesis) {
      return Token.closeParenthesis(value);
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
