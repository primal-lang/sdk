import 'package:primal/compiler/lexical/token.dart';
import 'package:primal/compiler/syntactic/expression.dart';
import 'package:primal/compiler/syntactic/expression_parser.dart';
import 'package:primal/utils/list_iterator.dart';
import 'package:test/test.dart';
import '../helpers/pipeline_helpers.dart';

void main() {
  Expression getExpression(String input) {
    final List<Token> tokens = getTokens(input);
    final ExpressionParser parser = ExpressionParser(ListIterator(tokens));

    return parser.expression();
  }

  group('Expression parser', () {
    test('Expression 1', () {
      final Expression expression = getExpression('2 - 1 * 3');
      expect(expression.toString(), '-(2, *(1, 3))');
    });

    test('Expression 2', () {
      final Expression expression = getExpression('2 * 1 - 3');
      expect(expression.toString(), '-(*(2, 1), 3)');
    });

    test('Expression 3', () {
      final Expression expression = getExpression('(2 - 1) * 3');
      expect(expression.toString(), '*(-(2, 1), 3)');
    });

    test('Expression 4', () {
      final Expression expression = getExpression('(2 - 1) != 3 * 4');
      expect(expression.toString(), '!=(-(2, 1), *(3, 4))');
    });

    test('Expression 5', () {
      final Expression expression = getExpression('2 * 4 % 3 == 1 + 3 / 4');
      expect(expression.toString(), '==(%(*(2, 4), 3), +(1, /(3, 4)))');
    });

    test('Expression 6', () {
      final Expression expression = getExpression('2 + !5 > !7 * 3');
      expect(expression.toString(), '>(+(2, !(5)), *(!(7), 3))');
    });

    test('Expression 7', () {
      final Expression expression = getExpression('!2 + 5 >= 7 * !3');
      expect(expression.toString(), '>=(+(!(2), 5), *(7, !(3)))');
    });

    test('Expression 8', () {
      final Expression expression = getExpression('2 + -5 < -7 * 3');
      expect(expression.toString(), '<(+(2, -(0, 5)), *(-(0, 7), 3))');
    });

    test('Expression 9', () {
      final Expression expression = getExpression('-2 + 5 <= 7 * -3');
      expect(expression.toString(), '<=(+(-(0, 2), 5), *(7, -(0, 3)))');
    });

    test('Expression 10', () {
      final Expression expression = getExpression('true | 4 < false & "test"');
      expect(expression.toString(), '<(|(true, 4), &(false, "test"))');
    });

    test('Expression 11', () {
      final Expression expression = getExpression('foo(4 + 1)');
      expect(expression.toString(), 'foo(+(4, 1))');
    });

    test('Expression 12', () {
      final Expression expression = getExpression('foo(bar + 1)');
      expect(expression.toString(), 'foo(+(bar, 1))');
    });

    test('Expression 13', () {
      final Expression expression = getExpression('foo(bar() + 1)');
      expect(expression.toString(), 'foo(+(bar(), 1))');
    });

    test('Expression 14', () {
      final Expression expression = getExpression('foo(bar()() + 1)()');
      expect(expression.toString(), 'foo(+(bar()(), 1))()');
    });

    test('Expression 15', () {
      final Expression expression = getExpression('if (true) 1 else 2');
      expect(expression.toString(), 'if(true, 1, 2)');
    });

    test('Expression 16', () {
      final Expression expression = getExpression('if (a > b) 1 else 2');
      expect(expression.toString(), 'if(>(a, b), 1, 2)');
    });

    test('Expression 17', () {
      final Expression expression = getExpression('[]');
      expect(expression.toString(), '[]');
    });

    test('Expression 18', () {
      final Expression expression = getExpression('[1, true, "test", foo]');
      expect(expression.toString(), '[1, true, "test", foo]');
    });

    test('Expression 19', () {
      final Expression expression = getExpression(
        '{"name": "John", "age": 42, "married": true}',
      );
      expect(
        expression.toString(),
        '{"name": "John", "age": 42, "married": true}',
      );
    });

    test('Expression 20', () {
      final Expression expression = getExpression('[1, true, "test", foo][1]');
      expect(expression.toString(), 'element.at([1, true, "test", foo], 1)');
    });

    test('Expression 21', () {
      final Expression expression = getExpression(
        '([1, true, "test", foo][1])[2]',
      );
      expect(
        expression.toString(),
        'element.at(element.at([1, true, "test", foo], 1), 2)',
      );
    });

    test('Expression 22', () {
      final Expression expression = getExpression(
        '{"name": "John", "age": 42, "married": true}["test"]',
      );
      expect(
        expression.toString(),
        'element.at({"name": "John", "age": 42, "married": true}, "test")',
      );
    });

    test('Expression 23', () {
      final Expression expression = getExpression('"Hello"[1]');
      expect(expression.toString(), 'element.at("Hello", 1)');
    });

    // Primitive literals
    test('Expression 24', () {
      final Expression expression = getExpression('42');
      expect(expression.toString(), '42');
    });

    test('Expression 25', () {
      final Expression expression = getExpression('3.14');
      expect(expression.toString(), '3.14');
    });

    test('Expression 26', () {
      final Expression expression = getExpression('"hello"');
      expect(expression.toString(), '"hello"');
    });

    test('Expression 27', () {
      final Expression expression = getExpression("'hello'");
      expect(expression.toString(), '"hello"');
    });

    test('Expression 28', () {
      final Expression expression = getExpression('true');
      expect(expression.toString(), 'true');
    });

    test('Expression 29', () {
      final Expression expression = getExpression('false');
      expect(expression.toString(), 'false');
    });

    test('Expression 30', () {
      final Expression expression = getExpression('foo');
      expect(expression.toString(), 'foo');
    });

    // Left-associativity of binary operators
    test('Expression 31', () {
      final Expression expression = getExpression('1 - 2 - 3');
      expect(expression.toString(), '-(-(1, 2), 3)');
    });

    test('Expression 32', () {
      final Expression expression = getExpression('8 / 4 / 2');
      expect(expression.toString(), '/(/(8, 4), 2)');
    });

    test('Expression 33', () {
      final Expression expression = getExpression('a & b & c');
      expect(expression.toString(), '&(&(a, b), c)');
    });

    test('Expression 34', () {
      final Expression expression = getExpression('a | b | c');
      expect(expression.toString(), '|(|(a, b), c)');
    });

    test('Expression 35', () {
      final Expression expression = getExpression('a == b == c');
      expect(expression.toString(), '==(==(a, b), c)');
    });

    test('Expression 36', () {
      final Expression expression = getExpression('a < b < c');
      expect(expression.toString(), '<(<(a, b), c)');
    });

    // Unary edge cases
    test('Expression 37', () {
      final Expression expression = getExpression('! !true');
      expect(expression.toString(), '!(!(true))');
    });

    test('Expression 38', () {
      final Expression expression = getExpression('- -5');
      expect(expression.toString(), '-(0, -(0, 5))');
    });

    test('Expression 39', () {
      final Expression expression = getExpression('!(a + b)');
      expect(expression.toString(), '!(+(a, b))');
    });

    test('Expression 40', () {
      final Expression expression = getExpression('-(a + b)');
      expect(expression.toString(), '-(0, +(a, b))');
    });

    // Nested if/else
    test('Expression 41', () {
      final Expression expression = getExpression(
        'if (true) if (false) 1 else 2 else 3',
      );
      expect(expression.toString(), 'if(true, if(false, 1, 2), 3)');
    });

    test('Expression 42', () {
      final Expression expression = getExpression('if (a & b) 1 else 2');
      expect(expression.toString(), 'if(&(a, b), 1, 2)');
    });

    test('Expression 43', () {
      final Expression expression = getExpression('foo(if (true) 1 else 2)');
      expect(expression.toString(), 'foo(if(true, 1, 2))');
    });

    // Function calls
    test('Expression 44', () {
      final Expression expression = getExpression('foo()');
      expect(expression.toString(), 'foo()');
    });

    test('Expression 45', () {
      final Expression expression = getExpression('foo(1, 2, 3)');
      expect(expression.toString(), 'foo(1, 2, 3)');
    });

    test('Expression 46', () {
      final Expression expression = getExpression('foo(bar(1))');
      expect(expression.toString(), 'foo(bar(1))');
    });

    test('Expression 47', () {
      final Expression expression = getExpression('foo()()');
      expect(expression.toString(), 'foo()()');
    });

    test('Expression 48', () {
      final Expression expression = getExpression('foo.bar(1)');
      expect(expression.toString(), 'foo.bar(1)');
    });

    // Collections
    test('Expression 49', () {
      final Expression expression = getExpression('{}');
      expect(expression.toString(), '{}');
    });

    test('Expression 50', () {
      final Expression expression = getExpression('[1]');
      expect(expression.toString(), '[1]');
    });

    test('Expression 51', () {
      final Expression expression = getExpression('[[1, 2], [3, 4]]');
      expect(expression.toString(), '[[1, 2], [3, 4]]');
    });

    test('Expression 52', () {
      final Expression expression = getExpression('{"a": {"b": 1}}');
      expect(expression.toString(), '{"a": {"b": 1}}');
    });

    test('Expression 53', () {
      final Expression expression = getExpression('{1: "one", true: "yes"}');
      expect(expression.toString(), '{1: "one", true: "yes"}');
    });

    test('Expression 54', () {
      final Expression expression = getExpression('{"items": [1, 2]}');
      expect(expression.toString(), '{"items": [1, 2]}');
    });

    test('Expression 55', () {
      final Expression expression = getExpression('[{"a": 1}]');
      expect(expression.toString(), '[{"a": 1}]');
    });

    // Indexing edge cases
    test('Expression 56', () {
      final Expression expression = getExpression('arr[0]');
      expect(expression.toString(), 'element.at(arr, 0)');
    });

    test('Expression 57', () {
      final Expression expression = getExpression('arr[1 + 2]');
      expect(expression.toString(), 'element.at(arr, +(1, 2))');
    });

    test('Expression 58', () {
      final Expression expression = getExpression('(foo())[0]');
      expect(expression.toString(), 'element.at(foo(), 0)');
    });

    test('Expression 59', () {
      final Expression expression = getExpression('(a[0])[1]');
      expect(expression.toString(), 'element.at(element.at(a, 0), 1)');
    });

    // Deeply nested grouping
    test('Expression 60', () {
      final Expression expression = getExpression('((1 + 2))');
      expect(expression.toString(), '+(1, 2)');
    });

    test('Expression 61', () {
      final Expression expression = getExpression('(((42)))');
      expect(expression.toString(), '42');
    });

    // Mixed precedence
    test('Expression 62', () {
      final Expression expression = getExpression('a & b | c');
      expect(expression.toString(), '|(&(a, b), c)');
    });

    test('Expression 63', () {
      final Expression expression = getExpression('a > b & c < d');
      expect(expression.toString(), '<(>(a, &(b, c)), d)');
    });
  });
}
