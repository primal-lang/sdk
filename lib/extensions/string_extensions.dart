extension StringExtensions on String {
  static final RegExp REGEX_DIGIT = RegExp(r'\d');

  static final RegExp REGEX_LETTER = RegExp(r'[a-zA-Z]');

  static final RegExp REGEX_DELIMITER = RegExp(r'\s');

  bool get isDigit => REGEX_DIGIT.hasMatch(this);

  bool get isLetter => REGEX_LETTER.hasMatch(this);

  bool get isDelimiter => REGEX_DELIMITER.hasMatch(this);
}
