import 'package:dry/compiler/errors/syntactic_error.dart';
import 'package:dry/compiler/input/character.dart';
import 'package:dry/compiler/input/input_analyzer.dart';
import 'package:dry/compiler/lexical/lexical_analyzer.dart';
import 'package:dry/compiler/lexical/token.dart';
import 'package:dry/compiler/syntactic/expression.dart';
import 'package:dry/compiler/syntactic/function_definition.dart';
import 'package:dry/compiler/syntactic/syntactic_analyzer.dart';
import 'package:test/test.dart';

void main() {
  List<FunctionDefinition> _functions(String source) {
    final InputAnalyzer inputAnalyzer = InputAnalyzer(source);
    final List<Character> characters = inputAnalyzer.analyze();
    final LexicalAnalyzer lexicalAnalyzer = LexicalAnalyzer(characters);
    final List<Token> tokens = lexicalAnalyzer.analyze();
    final SyntacticAnalyzer syntacticAnalyzer = SyntacticAnalyzer(tokens);

    return syntacticAnalyzer.analyze();
  }

  void _checkFunctions(
      List<FunctionDefinition> actual, List<FunctionDefinition> expected) {
    expect(actual.length, equals(expected.length));

    for (int i = 0; i < actual.length; i++) {
      expect(actual[i].name, equals(expected[i].name));

      final List<String> actualParameters = actual[i].parameters;
      final List<String> expectedParameters = expected[i].parameters;

      expect(actualParameters.length, equals(expectedParameters.length));

      for (int j = 0; j < actualParameters.length; j++) {
        expect(actualParameters[i], equals(expectedParameters[i]));
      }
    }
  }

  group('Syntactic Analyzer', () {
    test('Invalid function definition 1', () {
      try {
        _functions('123');
      } catch (e) {
        expect(e, isA<SyntacticError>());
      }
    });

    test('Invalid function definition 2', () {
      try {
        _functions('isEven ,');
      } catch (e) {
        expect(e, isA<SyntacticError>());
      }
    });

    test('Invalid function definition 3', () {
      try {
        _functions('isEven()');
      } catch (e) {
        expect(e, isA<SyntacticError>());
      }
    });

    test('Invalid function definition 4', () {
      try {
        _functions('isEven(1');
      } catch (e) {
        expect(e, isA<SyntacticError>());
      }
    });

    test('Invalid function definition 5', () {
      try {
        _functions('isEven(a(');
      } catch (e) {
        expect(e, isA<SyntacticError>());
      }
    });

    test('Invalid function definition 6', () {
      try {
        _functions('isEvent(x),');
      } catch (e) {
        expect(e, isA<SyntacticError>());
      }
    });

    test('Literal string definition', () {
      final List<FunctionDefinition> functions =
          _functions('greeting = "Hello, world!"');
      _checkFunctions(functions, [
        FunctionDefinition(
          name: 'greeting',
          parameters: [],
          expression: LiteralExpression.string('Hello, world!'),
        ),
      ]);
    });

    test('Literal number definition', () {
      final List<FunctionDefinition> functions = _functions('pi = 3.14');
      _checkFunctions(functions, [
        FunctionDefinition(
          name: 'pi',
          parameters: [],
          expression: LiteralExpression.number(3.14),
        ),
      ]);
    });

    test('Literal boolean definition', () {
      final List<FunctionDefinition> functions = _functions('enabled = true');
      _checkFunctions(functions, [
        FunctionDefinition(
          name: 'enabled',
          parameters: [],
          expression: LiteralExpression.boolean(true),
        ),
      ]);
    });

    test('Function with one parameter', () {
      final List<FunctionDefinition> functions = _functions('test(a) = true');
      _checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: ['a'],
          expression: LiteralExpression.boolean(true),
        ),
      ]);
    });

    test('Function with several parameters', () {
      final List<FunctionDefinition> functions =
          _functions('test(a, b, c) = true');
      _checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: ['a', 'b', 'c'],
          expression: LiteralExpression.boolean(true),
        ),
      ]);
    });
  });
}
