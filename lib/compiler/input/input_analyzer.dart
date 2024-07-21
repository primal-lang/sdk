import 'package:characters/characters.dart';
import 'package:dry/compiler/input/character.dart';
import 'package:dry/compiler/models/analyzer.dart';
import 'package:dry/compiler/models/location.dart';

class InputAnalyzer extends Analyzer<String, List<Character>> {
  const InputAnalyzer(super.input);

  @override
  List<Character> analyze() {
    final List<Character> result = [];
    final List<String> rows = input.split('\n');

    for (int i = 0; i < rows.length; i++) {
      final List<String> columns = rows[i].characters.toList();

      for (int j = 0; j < columns.length; j++) {
        result.add(Character(
          value: columns[j],
          location: Location(
            row: i + 1,
            column: j + 1,
          ),
        ));
      }

      result.add(Character(
        value: '\n',
        location: Location(
          row: i + 1,
          column: columns.length + 1,
        ),
      ));
    }

    return result;
  }
}
