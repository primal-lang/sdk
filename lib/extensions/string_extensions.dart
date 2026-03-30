extension StringExtensions on String {
  bool get isDigit => RegExp(r'\d').hasMatch(this);

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

  bool get isAsterisk => this == '*';

  bool get isPercent => this == '%';

  bool get isUnderscore => this == '_';

  bool get isDot => this == '.';

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
      isOpenBraces;

  bool get isCommaDelimiter =>
      isWhitespace ||
      isDigit ||
      isLetter ||
      isDoubleQuote ||
      isSingleQuote ||
      isOpenParenthesis ||
      isOpenBracket ||
      isOpenBraces ||
      isUnaryOperator;

  bool get isColonDelimiter =>
      isWhitespace ||
      isDigit ||
      isLetter ||
      isDoubleQuote ||
      isSingleQuote ||
      isOpenParenthesis ||
      isOpenBracket ||
      isOpenBraces ||
      isUnaryOperator;

  bool get isOpenParenthesisDelimiter =>
      isWhitespace ||
      isDigit ||
      isLetter ||
      isDoubleQuote ||
      isSingleQuote ||
      isOpenParenthesis ||
      isCloseParenthesis ||
      isOpenBracket ||
      isOpenBraces ||
      isUnaryOperator;

  bool get isCloseParenthesisDelimiter =>
      isWhitespace ||
      isComma ||
      isColon ||
      isLetter ||
      isOpenParenthesis ||
      isCloseParenthesis ||
      isOpenBracket ||
      isCloseBracket ||
      isBinaryOperator;

  bool get isOpenBracketDelimiter =>
      isWhitespace ||
      isDigit ||
      isLetter ||
      isDoubleQuote ||
      isSingleQuote ||
      isOpenParenthesis ||
      isOpenBracket ||
      isCloseBracket ||
      isOpenBraces ||
      isUnaryOperator;

  bool get isCloseBracketDelimiter =>
      isWhitespace ||
      isComma ||
      isColon ||
      isLetter ||
      isOpenParenthesis ||
      isCloseParenthesis ||
      isOpenBracket ||
      isCloseBracket ||
      isCloseBraces ||
      isBinaryOperator;

  bool get isOpenBracesDelimiter =>
      isWhitespace ||
      isDigit ||
      isLetter ||
      isDoubleQuote ||
      isSingleQuote ||
      isOpenParenthesis ||
      isOpenBracket ||
      isOpenBraces ||
      isCloseBraces ||
      isUnaryOperator;

  bool get isCloseBracesDelimiter =>
      isWhitespace ||
      isComma ||
      isColon ||
      isLetter ||
      isCloseParenthesis ||
      isOpenBracket ||
      isCloseBracket ||
      isCloseBraces ||
      isBinaryOperator;

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
      isPercent;

  bool get isUnaryOperator => isMinus || isBang;
}
