import 'package:characters/characters.dart';
import 'package:dry/compiler/input/character.dart';

class InputAnalyzer {
  final String input;

  const InputAnalyzer({required this.input});

  List<Character> analyze() {
    final List<Character> result = [];
    final List<String> rows = input.split('\n');

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
