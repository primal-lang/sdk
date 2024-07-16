import 'package:characters/characters.dart';
import 'package:dry/compiler/input/character.dart';
import 'package:dry/compiler/input/location.dart';
import 'package:dry/compiler/models/analyzer.dart';

class InputAnalyzer extends Analyzer<String, List<Character>> {
  const InputAnalyzer(super.input);

  @override
  List<Character> analyze() {
    final List<Character> result = [];
    final List<String> rows = input.split('\n');
    int lastRow = 1;
    int lastColumn = 1;

    for (int i = 0; i < rows.length; i++) {
      final List<String> columns = rows[i].characters.toList();

      for (int j = 0; j < columns.length; j++) {
        lastRow = i + 1;
        lastColumn = j + 1;

        result.add(Character(
          value: columns[j],
          location: Location(
            row: lastRow,
            column: lastColumn,
          ),
        ));
      }
    }

    if (!result.last.isNewLine) {
      result.add(Character(
        value: '\n',
        location: Location(
          row: lastRow,
          column: lastColumn + 1,
        ),
      ));
    }

    return result;
  }
}
