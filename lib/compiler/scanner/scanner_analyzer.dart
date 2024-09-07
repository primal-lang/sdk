import 'package:primal/compiler/models/analyzer.dart';
import 'package:primal/compiler/models/location.dart';
import 'package:primal/compiler/scanner/character.dart';

class Scanner extends Analyzer<String, List<Character>> {
  const Scanner(super.input);

  @override
  List<Character> analyze() {
    final List<Character> result = [];
    final List<String> rows = input.split('\n');

    for (int i = 0; i < rows.length; i++) {
      if ((i == 0) && rows[i].startsWith('#!')) {
        continue;
      }

      final List<String> columns =
          rows[i].runes.map(String.fromCharCode).toList();

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
