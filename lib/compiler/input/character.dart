import 'package:dry/extensions/string_extensions.dart';

class Character {
  final String value;
  final int row;
  final int column;

  const Character({
    required this.value,
    required this.row,
    required this.column,
  });

  bool get isDigit => value.isDigit;

  bool get isLetter => value.isLetter;

  bool get isQuote => value.isQuote;

  bool get isDot => value.isDot;

  bool get isSeparator => value.isSeparator;

  bool get isDelimiter => value.isDelimiter;

  String get location => '[$row, $column]';

  @override
  String toString() => '$value at $location';
}
