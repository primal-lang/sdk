extension StringExtensions on String {
  static final RegExp REGEX_DIGIT = RegExp(r'\d');

  static final RegExp REGEX_LETTER = RegExp(r'[a-zA-Z]');

  static final RegExp REGEX_WHITESPACE = RegExp(r'\s');

  static final RegExp REGEX_NEW_LINE = RegExp(r'\n');

  static final RegExp REGEX_DOUBLE_QUOTE = RegExp(r'"');

  static final RegExp REGEX_SINGLE_QUOTE = RegExp(r"'");

  static final RegExp REGEX_DASH = RegExp(r'-');

  static final RegExp REGEX_UNDERSCORE = RegExp(r'_');

  static final RegExp REGEX_DOT = RegExp(r'\.');

  static final RegExp REGEX_COMMA = RegExp(r',');

  static final RegExp REGEX_EQUALS = RegExp(r'=');

  static final RegExp REGEX_OPEN_PARENTHESIS = RegExp(r'\(');

  static final RegExp REGEX_CLOSE_PARENTHESIS = RegExp(r'\)');

  static final RegExp REGEX_SLASH = RegExp(r'/');

  static final RegExp REGEX_BOOLEAN = RegExp(r'true|false');

  bool get isDigit => REGEX_DIGIT.hasMatch(this);

  bool get isLetter => REGEX_LETTER.hasMatch(this);

  bool get isWhitespace => REGEX_WHITESPACE.hasMatch(this);

  bool get isDoubleQuote => REGEX_DOUBLE_QUOTE.hasMatch(this);

  bool get isSingleQuote => REGEX_SINGLE_QUOTE.hasMatch(this);

  bool get isDash => REGEX_DASH.hasMatch(this);

  bool get isUnderscore => REGEX_UNDERSCORE.hasMatch(this);

  bool get isDot => REGEX_DOT.hasMatch(this);

  bool get isComma => REGEX_COMMA.hasMatch(this);

  bool get isEquals => REGEX_EQUALS.hasMatch(this);

  bool get isOpenParenthesis => REGEX_OPEN_PARENTHESIS.hasMatch(this);

  bool get isCloseParenthesis => REGEX_CLOSE_PARENTHESIS.hasMatch(this);

  bool get isSlash => REGEX_SLASH.hasMatch(this);

  bool get isBoolean => REGEX_BOOLEAN.hasMatch(this);

  bool get isNewLine => REGEX_NEW_LINE.hasMatch(this);

  bool get isSeparator =>
      isComma || isEquals || isOpenParenthesis || isCloseParenthesis;

  bool get isDelimiter => isWhitespace || isSeparator;
}
