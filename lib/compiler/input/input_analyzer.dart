import 'package:characters/characters.dart';
import 'package:dry/compiler/input/lexeme.dart';
import 'package:dry/compiler/models/analyzer.dart';

class InputAnalyzer extends Analyzer<String, List<Lexeme>> {
  const InputAnalyzer(super.input);

  @override
  List<Lexeme> analyze() {
    final List<Lexeme> result = [];
    final List<String> rows = input.split('\n');

    for (int i = 0; i < rows.length; i++) {
      final List<String> columns = rows[i].characters.toList();

      for (int j = 0; j < columns.length; j++) {
        result.add(Lexeme(
          value: columns[j],
          row: i + 1,
          column: j + 1,
        ));
      }
    }

    result.add(Lexeme(
      value: '\n',
      row: rows.length + 1,
      column: 0,
    ));

    return result;
  }
}
