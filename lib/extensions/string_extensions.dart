extension StringExtensions on String {
  static final RegExp REGEX_DIGIT = RegExp(r'\d');

  static final RegExp REGEX_LETTER = RegExp(r'[a-zA-Z]');

  static final RegExp REGEX_WHITESPACE = RegExp(r'\s');

  static final RegExp REGEX_DASH = RegExp(r'-');

  static final RegExp REGEX_COMMA = RegExp(r',');

  static final RegExp REGEX_EQUALS = RegExp(r'=');

  static final RegExp REGEX_OPEN_PARENTHESIS = RegExp(r'\(');

  static final RegExp REGEX_CLOSE_PARENTHESIS = RegExp(r'\)');

  bool get isDigit => REGEX_DIGIT.hasMatch(this);

  bool get isLetter => REGEX_LETTER.hasMatch(this);

  bool get isWhitespace => REGEX_WHITESPACE.hasMatch(this);

  bool get isDash => REGEX_DASH.hasMatch(this);

  bool get isComma => REGEX_COMMA.hasMatch(this);

  bool get isEquals => REGEX_EQUALS.hasMatch(this);

  bool get isOpenParenthesis => REGEX_OPEN_PARENTHESIS.hasMatch(this);

  bool get isCloseParenthesis => REGEX_CLOSE_PARENTHESIS.hasMatch(this);

  bool get isDelimiter =>
      isWhitespace ||
      isDash ||
      isComma ||
      isEquals ||
      isOpenParenthesis ||
      isCloseParenthesis;
}
