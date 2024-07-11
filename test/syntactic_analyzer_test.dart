import 'package:dry/compiler/lexical/lexical_analyzer.dart';
import 'package:dry/compiler/lexical/token.dart';
import 'package:dry/compiler/syntactic/function_definition.dart';
import 'package:dry/compiler/syntactic/syntactic_analyzer.dart';
import 'package:test/test.dart';

void main() {
  List<FunctionDefinition> _functions(String source) {
    final LexicalAnalyzer lexicalAnalyzer = LexicalAnalyzer(source: source);
    final List<Token> tokens = lexicalAnalyzer.analyze();

    final SyntacticAnalyzer syntacticAnalyzer =
        SyntacticAnalyzer(tokens: tokens);

    return syntacticAnalyzer.analyze();
  }

  group('Syntactic Analyzer', () {
    test('Function definition', () {
      final List<FunctionDefinition> functions =
          _functions('isZero(x) = eq(x, 0)');
      expect(1, equals(functions.length));
    });
  });
}
