extension StringExtensions on String {
  bool get isDigit => RegExp(r'\d').hasMatch(this);

  bool get isLetter => RegExp(r'[a-zA-Z]').hasMatch(this);

  bool get isWhitespace => RegExp(r'\s').hasMatch(this);

  bool get isNewLine => RegExp(r'\n').hasMatch(this);

  bool get isDoubleQuote => RegExp(r'"').hasMatch(this);

  bool get isSingleQuote => RegExp(r"'").hasMatch(this);

  bool get isMinus => RegExp(r'-').hasMatch(this);

  bool get isPlus => RegExp(r'\+').hasMatch(this);

  bool get isEquals => RegExp(r'=').hasMatch(this);

  bool get isGreater => RegExp(r'>').hasMatch(this);

  bool get isLess => RegExp(r'<').hasMatch(this);

  bool get isPipe => RegExp(r'\|').hasMatch(this);

  bool get isAmpersand => RegExp(r'&').hasMatch(this);

  bool get isBang => RegExp(r'!').hasMatch(this);

  bool get isForwardSlash => RegExp(r'/').hasMatch(this);

  bool get isAsterisk => RegExp(r'\*').hasMatch(this);

  bool get isPercent => RegExp(r'%').hasMatch(this);

  bool get isUnderscore => RegExp(r'_').hasMatch(this);

  bool get isDot => RegExp(r'\.').hasMatch(this);

  bool get isComma => RegExp(r',').hasMatch(this);

  bool get isOpenParenthesis => RegExp(r'\(').hasMatch(this);

  bool get isCloseParenthesis => RegExp(r'\)').hasMatch(this);

  bool get isBoolean => RegExp(r'true|false').hasMatch(this);

  bool get isIf => RegExp(r'if').hasMatch(this);

  bool get isElse => RegExp(r'else').hasMatch(this);

  bool get isOperandDelimiter =>
      isWhitespace ||
      isBinaryOperator ||
      isComma ||
      isOpenParenthesis ||
      isCloseParenthesis;

  bool get isOperatorDelimiter =>
      isWhitespace ||
      isDigit ||
      isLetter ||
      isDoubleQuote ||
      isSingleQuote ||
      isOpenParenthesis;

  bool get isCommaDelimiter =>
      isWhitespace ||
      isDigit ||
      isLetter ||
      isDoubleQuote ||
      isSingleQuote ||
      isOpenParenthesis ||
      isUnaryOperator;

  bool get isOpenParenthesisDelimiter =>
      isWhitespace ||
      isDigit ||
      isLetter ||
      isDoubleQuote ||
      isSingleQuote ||
      isOpenParenthesis ||
      isCloseParenthesis ||
      isUnaryOperator;

  bool get isCloseParenthesisDelimiter =>
      isWhitespace ||
      isComma ||
      isOpenParenthesis ||
      isCloseParenthesis ||
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
