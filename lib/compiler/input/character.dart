import 'package:dry/compiler/input/location.dart';
import 'package:dry/extensions/string_extensions.dart';

class Character {
  final String value;
  final Location location;

  const Character({
    required this.value,
    required this.location,
  });

  bool get isDigit => value.isDigit;

  bool get isLetter => value.isLetter;

  bool get isDoubleQuote => value.isDoubleQuote;

  bool get isSingleQuote => value.isSingleQuote;

  bool get isDash => value.isDash;

  bool get isUnderscore => value.isUnderscore;

  bool get isSemicolon => value.isSemicolon;

  bool get isDot => value.isDot;

  bool get isHashtag => value.isHashtag;

  bool get isNewLine => value.isNewLine;

  bool get isSeparator => value.isSeparator;

  bool get isDelimiter => value.isDelimiter;

  @override
  String toString() => '$value at $location';
}
