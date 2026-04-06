extension StringExtensions on String {
  bool get isDigit => RegExp(r'\d').hasMatch(this);

  bool get isHexDigit => RegExp(r'[0-9a-fA-F]').hasMatch(this);

  bool get isLetter => RegExp(r'[a-zA-Z]').hasMatch(this);

  bool get isWhitespace =>
      this == ' ' || this == '\t' || this == '\n' || this == '\r';

  bool get isNewLine => this == '\n';

  bool get isDoubleQuote => this == '"';

  bool get isSingleQuote => this == "'";

  bool get isMinus => this == '-';

  bool get isPlus => this == '+';

  bool get isEquals => this == '=';

  bool get isGreater => this == '>';

  bool get isLess => this == '<';

  bool get isPipe => this == '|';

  bool get isAmpersand => this == '&';

  bool get isBang => this == '!';

  bool get isForwardSlash => this == '/';

  bool get isBackslash => this == '\\';

  bool get isAsterisk => this == '*';

  bool get isPercent => this == '%';

  bool get isAt => this == '@';

  bool get isUnderscore => this == '_';

  bool get isDot => this == '.';

  bool get isExponent => this == 'e' || this == 'E';

  bool get isComma => this == ',';

  bool get isColon => this == ':';

  bool get isOpenParenthesis => this == '(';

  bool get isCloseParenthesis => this == ')';

  bool get isOpenBracket => this == '[';

  bool get isCloseBracket => this == ']';

  bool get isOpenBraces => this == '{';

  bool get isCloseBraces => this == '}';

  bool get isBoolean => this == 'true' || this == 'false';

  bool get isIf => this == 'if';

  bool get isElse => this == 'else';

  bool get isAnd => this == 'and';

  bool get isOr => this == 'or';

  bool get isOperandDelimiter =>
      isWhitespace ||
      isBinaryOperator ||
      isComma ||
      isColon ||
      isOpenParenthesis ||
      isCloseParenthesis ||
      isOpenBracket ||
      isCloseBracket ||
      isOpenBraces ||
      isCloseBraces;

  bool get isOperatorDelimiter =>
      isWhitespace ||
      isDigit ||
      isLetter ||
      isDoubleQuote ||
      isSingleQuote ||
      isOpenParenthesis ||
      isOpenBracket ||
      isOpenBraces ||
      isUnaryOperator;

  bool get isIdentifier => isLetter || isDigit || isDot || isUnderscore;

  bool get isBinaryOperator =>
      isMinus ||
      isPlus ||
      isEquals ||
      isGreater ||
      isLess ||
      isPipe ||
      isAmpersand ||
      isBang ||
      isForwardSlash ||
      isAsterisk ||
      isPercent ||
      isAt;

  bool get isUnaryOperator => isMinus || isBang;
}
