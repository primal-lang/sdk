import 'package:primal/compiler/errors/lexical_error.dart';
import 'package:primal/compiler/lexical/lexical_analyzer.dart';
import 'package:primal/compiler/lexical/token.dart';
import 'package:primal/compiler/models/location.dart';
import 'package:primal/extensions/string_extensions.dart';

class Character extends Localized {
  final String value;

  const Character({
    required this.value,
    required super.location,
  });

  Lexeme get lexeme => Lexeme(
        value: value,
        location: location,
      );

  Token get separator {
    if (value.isComma) {
      return CommaToken(lexeme);
    } else if (value.isEquals) {
      return EqualsToken(lexeme);
    } else if (value.isOpenParenthesis) {
      return OpenParenthesisToken(lexeme);
    } else if (value.isCloseParenthesis) {
      return CloseParenthesisToken(lexeme);
    } else {
      throw InvalidLexemeError(lexeme);
    }
  }

  bool get isDigit => value.isDigit;

  bool get isLetter => value.isLetter;

  bool get isDoubleQuote => value.isDoubleQuote;

  bool get isSingleQuote => value.isSingleQuote;

  bool get isDash => value.isDash;

  bool get isUnderscore => value.isUnderscore;

  bool get isDot => value.isDot;

  bool get isSlash => value.isSlash;

  bool get isNewLine => value.isNewLine;

  bool get isSeparator => value.isSeparator;

  bool get isDelimiter => value.isDelimiter;

  @override
  String toString() => '"$value" at $location';
}
