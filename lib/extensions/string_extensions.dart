extension StringExtensions on String {
  static final RegExp REGEX_DIGIT = RegExp(r'\d');

  static final RegExp REGEX_DELIMITER = RegExp(r'\s');

  bool get isDigit => REGEX_DIGIT.hasMatch(this);

  bool get isDelimiter => REGEX_DELIMITER.hasMatch(this);
}
