import 'package:characters/characters.dart';
import 'package:dry/extensions/string_extensions.dart';

class FileAnalyzer {
  final String source;

  const FileAnalyzer({required this.source});

  List<Character> analyze() {
    final List<Character> result = [];
    final List<String> rows = source.split('\n');

    for (int i = 0; i < rows.length; i++) {
      final List<String> columns = rows[i].characters.toList();

      for (int j = 0; j < columns.length; j++) {
        result.add(Character(
          value: columns[j],
          row: i + 1,
          column: j + 1,
        ));
      }
    }

    result.add(Character(
      value: '\n',
      row: rows.length + 1,
      column: 0,
    ));

    return result;
  }
}

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
