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

  bool get isQuote => value.isQuote;

  bool get isDot => value.isDot;

  bool get isSeparator => value.isSeparator;

  bool get isDelimiter => value.isDelimiter;

  @override
  String toString() => '$value at $location';
}
