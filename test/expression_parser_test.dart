import 'package:dry/compiler/input/character.dart';
import 'package:dry/compiler/input/input_analyzer.dart';
import 'package:dry/compiler/lexical/lexical_analyzer.dart';
import 'package:dry/compiler/lexical/token.dart';
import 'package:dry/compiler/syntactic/expression.dart';
import 'package:dry/compiler/syntactic/expression_parser.dart';
import 'package:dry/utils/list_iterator.dart';
import 'package:test/test.dart';

void main() {
  Expression _expression(String source) {
    final InputAnalyzer inputAnalyzer = InputAnalyzer(source);
    final List<Character> characters = inputAnalyzer.analyze();
    final LexicalAnalyzer lexicalAnalyzer = LexicalAnalyzer(characters);
    final List<Token> tokens = lexicalAnalyzer.analyze();
    final ExpressionParser parser = ExpressionParser(ListIterator(tokens));

    return parser.expression;
  }

  void _checkExpressions(Expression actual, Expression expected) {
    expect(actual.toString(), equals(expected.toString()));
    expect(actual.type, equals(expected.type));

    if ((actual is LiteralExpression) && (expected is LiteralExpression)) {
      expect(actual.value, equals(expected.value));
    } else if ((actual is FunctionCallExpression) &&
        (expected is FunctionCallExpression)) {
      expect(actual.name, equals(expected.name));
      expect(actual.arguments.length, equals(expected.arguments.length));

      for (int i = 0; i < actual.arguments.length; i++) {
        _checkExpressions(actual.arguments[i], expected.arguments[i]);
      }
    } else {
      fail('Expression types do not match');
    }
  }

  group('Expression Parser', () {
    test('String expression', () {
      final Expression expression = _expression('"Hello, world!"');
      _checkExpressions(expression, LiteralExpression.string('Hello, world!'));
    });

    test('Number expression', () {
      final Expression expression = _expression('123');
      _checkExpressions(expression, LiteralExpression.number(123));
    });

    test('Boolean expression', () {
      final Expression expression = _expression('true');
      _checkExpressions(expression, LiteralExpression.boolean(true));
    });

    test('Symbol expression', () {
      final Expression expression = _expression('isEven');
      _checkExpressions(expression, LiteralExpression.symbol('isEven'));
    });

    test('Function call expression with one parameter', () {
      final Expression expression = _expression('isEven(x)');
      _checkExpressions(
        expression,
        FunctionCallExpression(
          name: 'isEven',
          arguments: [LiteralExpression.symbol('x')],
        ),
      );
    });

    test('Function call expression with several parameters', () {
      final Expression expression = _expression('if(true, 1.23, "hello")');
      _checkExpressions(
        expression,
        FunctionCallExpression(
          name: 'if',
          arguments: [
            LiteralExpression.boolean(true),
            LiteralExpression.number(1.23),
            LiteralExpression.string('hello'),
          ],
        ),
      );
    });

    test('Chained function calls expression 1', () {
      final Expression expression = _expression('eq(mod(x, 2), 0)');
      _checkExpressions(
        expression,
        FunctionCallExpression(
          name: 'eq',
          arguments: [
            FunctionCallExpression(
              name: 'mod',
              arguments: [
                LiteralExpression.symbol('x'),
                LiteralExpression.number(2),
              ],
            ),
            LiteralExpression.number(0),
          ],
        ),
      );
    });

    test('Chained function calls expression 2', () {
      final Expression expression = _expression('not(isEven(positive(x)))');
      _checkExpressions(
        expression,
        FunctionCallExpression(
          name: 'not',
          arguments: [
            FunctionCallExpression(
              name: 'isEven',
              arguments: [
                FunctionCallExpression(
                  name: 'positive',
                  arguments: [
                    LiteralExpression.symbol('x'),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    });

    test('Chained function calls expression 3', () {
      final Expression expression =
          _expression('if(eq(n, 0), 1, mul(n, factorial(sub(n, 1))))');
      _checkExpressions(
        expression,
        FunctionCallExpression(
          name: 'if',
          arguments: [
            FunctionCallExpression(
              name: 'eq',
              arguments: [
                LiteralExpression.symbol('n'),
                LiteralExpression.number(0),
              ],
            ),
            LiteralExpression.number(1),
            FunctionCallExpression(
              name: 'mul',
              arguments: [
                LiteralExpression.symbol('n'),
                FunctionCallExpression(
                  name: 'factorial',
                  arguments: [
                    FunctionCallExpression(
                      name: 'sub',
                      arguments: [
                        LiteralExpression.symbol('n'),
                        LiteralExpression.number(1),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    });
  });
}
