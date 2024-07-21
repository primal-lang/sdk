import 'package:dry/compiler/input/location.dart';
import 'package:dry/extensions/string_extensions.dart';

class Character extends Localized {
  final String value;

  const Character({
    required this.value,
    required super.location,
  });

  bool get isDigit => value.isDigit;

  bool get isLetter => value.isLetter;

  bool get isDoubleQuote => value.isDoubleQuote;

  bool get isSingleQuote => value.isSingleQuote;

  bool get isDash => value.isDash;

  bool get isUnderscore => value.isUnderscore;

  bool get isDot => value.isDot;

  bool get isHashtag => value.isHashtag;

  bool get isNewLine => value.isNewLine;

  bool get isSeparator => value.isSeparator;

  bool get isDelimiter => value.isDelimiter;

  @override
  String toString() => '$value at $location';
}
