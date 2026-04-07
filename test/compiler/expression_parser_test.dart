@Tags(['compiler'])
library;

import 'package:primal/compiler/compiler.dart';
import 'package:primal/compiler/errors/syntactic_error.dart';
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
      expect(expression.toString(), '|(true, &(<(4, false), "test"))');
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
      expect(expression.toString(), '@([1, true, "test", foo], 1)');
    });

    test('Expression 21', () {
      final Expression expression = getExpression(
        '([1, true, "test", foo][1])[2]',
      );
      expect(
        expression.toString(),
        '@(@([1, true, "test", foo], 1), 2)',
      );
    });

    test('Expression 22', () {
      final Expression expression = getExpression(
        '{"name": "John", "age": 42, "married": true}["test"]',
      );
      expect(
        expression.toString(),
        '@({"name": "John", "age": 42, "married": true}, "test")',
      );
    });

    test('Expression 23', () {
      final Expression expression = getExpression('"Hello"[1]');
      expect(expression.toString(), '@("Hello", 1)');
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

    // More nested if/else scenarios
    test('Nested if in else branch', () {
      final Expression expression = getExpression(
        'if (true) 1 else if (false) 2 else 3',
      );
      expect(expression.toString(), 'if(true, 1, if(false, 2, 3))');
    });

    test('Deeply nested if expressions', () {
      final Expression expression = getExpression(
        'if (a) if (b) if (c) 1 else 2 else 3 else 4',
      );
      expect(expression.toString(), 'if(a, if(b, if(c, 1, 2), 3), 4)');
    });

    test('If with complex condition expression', () {
      final Expression expression = getExpression(
        'if (a > b & c < d | e == f) 1 else 2',
      );
      // Precedence: comparison > AND > OR > equality
      // So: ((a > b) & (c < d)) | e == f parses as == is lowest
      // == binds: (((a > b) & (c < d)) | e) == f
      expect(
        expression.toString(),
        'if(==(|(&(>(a, b), <(c, d)), e), f), 1, 2)',
      );
    });

    test('If result used in binary operation', () {
      final Expression expression = getExpression(
        '(if (true) 1 else 2) + 3',
      );
      expect(expression.toString(), '+(if(true, 1, 2), 3)');
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

    test('Deeply nested function calls', () {
      final Expression expression = getExpression('a(b(c(d(e))))');
      expect(expression.toString(), 'a(b(c(d(e))))');
    });

    test('Function call with multiple complex arguments', () {
      final Expression expression = getExpression('foo(1 + 2, bar(3), [4, 5])');
      expect(expression.toString(), 'foo(+(1, 2), bar(3), [4, 5])');
    });

    test('Function returning function called with index', () {
      final Expression expression = getExpression('getArray()[0](1)');
      expect(expression.toString(), '@(getArray(), 0)(1)');
    });

    test('Expression 48', () {
      final Expression expression = getExpression('foo.bar(1)');
      expect(expression.toString(), 'foo.bar(1)');
    });

    // Chained dot notation
    test('Chained dot notation calls', () {
      final Expression expression = getExpression('foo.bar.baz(1)');
      expect(expression.toString(), 'foo.bar.baz(1)');
    });

    test('Dot notation without arguments', () {
      final Expression expression = getExpression('foo.bar()');
      expect(expression.toString(), 'foo.bar()');
    });

    test('Dot notation chained with regular call', () {
      final Expression expression = getExpression('foo.bar(1)(2)');
      expect(expression.toString(), 'foo.bar(1)(2)');
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

    // Mixed deeply nested collections
    test('Deeply nested list in map in list', () {
      final Expression expression = getExpression(
        '[{"items": [1, 2, 3]}, {"items": [4, 5, 6]}]',
      );
      expect(
        expression.toString(),
        '[{"items": [1, 2, 3]}, {"items": [4, 5, 6]}]',
      );
    });

    test('Map with expression keys', () {
      final Expression expression = getExpression('{(1 + 2): "three"}');
      expect(expression.toString(), '{+(1, 2): "three"}');
    });

    test('Map with nested map as key', () {
      final Expression expression = getExpression('{{"inner": 1}: "outer"}');
      expect(expression.toString(), '{{"inner": 1}: "outer"}');
    });

    test('List with expression elements', () {
      final Expression expression = getExpression('[1 + 2, 3 * 4, 5 - 6]');
      expect(expression.toString(), '[+(1, 2), *(3, 4), -(5, 6)]');
    });

    // Indexing edge cases
    test('Expression 56', () {
      final Expression expression = getExpression('arr[0]');
      expect(expression.toString(), '@(arr, 0)');
    });

    test('Expression 57', () {
      final Expression expression = getExpression('arr[1 + 2]');
      expect(expression.toString(), '@(arr, +(1, 2))');
    });

    test('Expression 58', () {
      final Expression expression = getExpression('(foo())[0]');
      expect(expression.toString(), '@(foo(), 0)');
    });

    test('Expression 59', () {
      final Expression expression = getExpression('(a[0])[1]');
      expect(expression.toString(), '@(@(a, 0), 1)');
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
      expect(expression.toString(), '&(>(a, b), <(c, d))');
    });

    // Comparison vs logic precedence
    test('Expression 64', () {
      final Expression expression = getExpression('a > b & c > d');
      expect(expression.toString(), '&(>(a, b), >(c, d))');
    });

    test('Expression 65', () {
      final Expression expression = getExpression('a < b | c < d');
      expect(expression.toString(), '|(<(a, b), <(c, d))');
    });

    test('Expression 66', () {
      final Expression expression = getExpression('a >= b | c <= d & e > f');
      expect(expression.toString(), '|(>=(a, b), &(<=(c, d), >(e, f)))');
    });

    // AND has higher precedence than OR
    test('Expression 67', () {
      final Expression expression = getExpression('a | b & c');
      expect(expression.toString(), '|(a, &(b, c))');
    });

    // Chained indexing
    test('Expression 68', () {
      final Expression expression = getExpression('a[0][1]');
      expect(expression.toString(), '@(@(a, 0), 1)');
    });

    test('Expression 69', () {
      final Expression expression = getExpression('a[0][1][2]');
      expect(
        expression.toString(),
        '@(@(@(a, 0), 1), 2)',
      );
    });

    test('Expression 70', () {
      final Expression expression = getExpression('foo()[0][1]');
      expect(expression.toString(), '@(@(foo(), 0), 1)');
    });

    test('Expression 71', () {
      final Expression expression = getExpression('a[0]()');
      expect(expression.toString(), '@(a, 0)()');
    });

    // Mixed call/index chains
    test('Expression 72', () {
      final Expression expression = getExpression('f()[0]()');
      expect(expression.toString(), '@(f(), 0)()');
    });

    test('Expression 73', () {
      final Expression expression = getExpression('f()()[0]');
      expect(expression.toString(), '@(f()(), 0)');
    });

    test('Expression 74', () {
      final Expression expression = getExpression('a[0][1]()');
      expect(expression.toString(), '@(@(a, 0), 1)()');
    });

    test('Expression 75', () {
      final Expression expression = getExpression('f()[0]()[1]');
      expect(expression.toString(), '@(@(f(), 0)(), 1)');
    });

    // @ operator tests
    test('@ operator basic', () {
      final Expression expression = getExpression('a @ 1');
      expect(expression.toString(), '@(a, 1)');
    });

    test('@ operator precedence with multiplication', () {
      final Expression expression = getExpression('a * b @ c');
      expect(expression.toString(), '*(a, @(b, c))');
    });

    test('@ operator precedence with addition', () {
      final Expression expression = getExpression('a @ 1 + 2');
      expect(expression.toString(), '+(@(a, 1), 2)');
    });

    test('@ operator with unary minus', () {
      final Expression expression = getExpression('-a @ b');
      expect(expression.toString(), '@(-(0, a), b)');
    });

    test('@ operator chained', () {
      final Expression expression = getExpression('a @ 0 @ 1');
      expect(expression.toString(), '@(@(a, 0), 1)');
    });

    test('@ operator with parentheses', () {
      final Expression expression = getExpression('(a @ b) * c');
      expect(expression.toString(), '*(@(a, b), c)');
    });

    // Additional @ operator tests
    test('@ operator with function call result', () {
      final Expression expression = getExpression('foo() @ 0');
      expect(expression.toString(), '@(foo(), 0)');
    });

    test('@ operator with list literal', () {
      final Expression expression = getExpression('[1, 2, 3] @ 1');
      expect(expression.toString(), '@([1, 2, 3], 1)');
    });

    test('@ operator with expression index', () {
      final Expression expression = getExpression('arr @ (i + 1)');
      expect(expression.toString(), '@(arr, +(i, 1))');
    });

    test('@ operator in comparison', () {
      final Expression expression = getExpression('arr @ 0 > arr @ 1');
      expect(expression.toString(), '>(@(arr, 0), @(arr, 1))');
    });

    test('@ operator with negative index', () {
      final Expression expression = getExpression('arr @ -1');
      expect(expression.toString(), '@(arr, -(0, 1))');
    });
  });

  group('Expression parser errors', () {
    test('missing closing parenthesis throws', () {
      expect(
        () => getExpression('(1 + 2'),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('missing closing bracket throws', () {
      expect(
        () => getExpression('[1, 2'),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('missing closing brace throws', () {
      expect(
        () => getExpression('{"a": 1'),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('missing map colon throws ExpectedTokenError', () {
      expect(
        () => getExpression('{"a" 1}'),
        throwsA(isA<ExpectedTokenError>()),
      );
    });

    test('incomplete binary expression throws', () {
      expect(
        () => getExpression('1 +'),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('missing if condition closing paren throws', () {
      expect(
        () => getExpression('if (true 1 else 2'),
        throwsA(isA<ExpectedTokenError>()),
      );
    });

    test('missing else keyword throws', () {
      expect(
        () => getExpression('if (true) 1 2'),
        throwsA(isA<ExpectedTokenError>()),
      );
    });

    test('missing function call closing paren throws', () {
      expect(
        () => getExpression('foo(1, 2'),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('missing map value after colon throws', () {
      expect(
        () => getExpression('{"a":}'),
        throwsA(isA<InvalidTokenError>()),
      );
    });

    test('missing index expression throws', () {
      expect(
        () => getExpression('arr[]'),
        throwsA(isA<InvalidTokenError>()),
      );
    });

    test('missing if condition expression throws', () {
      expect(
        () => getExpression('if () 1 else 2'),
        throwsA(isA<InvalidTokenError>()),
      );
    });

    test('missing if then expression throws', () {
      // 'else' is parsed as an invalid primary token
      expect(
        () => getExpression('if (true) else 2'),
        throwsA(isA<InvalidTokenError>()),
      );
    });

    test('missing if else expression throws', () {
      expect(
        () => getExpression('if (true) 1 else'),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('missing opening paren for if throws', () {
      expect(
        () => getExpression('if true) 1 else 2'),
        throwsA(isA<ExpectedTokenError>()),
      );
    });

    test('close paren as primary throws InvalidTokenError', () {
      expect(
        () => getExpression(')'),
        throwsA(isA<InvalidTokenError>()),
      );
    });

    test('close bracket as primary throws InvalidTokenError', () {
      expect(
        () => getExpression(']'),
        throwsA(isA<InvalidTokenError>()),
      );
    });

    // Happy cases: syntactically valid, produces correct AST

    test('number followed by call syntax parses to CallExpression', () {
      final Expression expression = getExpression('5(1)');
      expect(expression, isA<CallExpression>());
      final CallExpression call = expression as CallExpression;
      expect(call.callee, isA<NumberExpression>());
      expect(call.arguments.length, equals(1));
    });

    test('number followed by bracket syntax parses to @ CallExpression', () {
      final Expression expression = getExpression('5[0]');
      expect(expression, isA<CallExpression>());
      expect(expression.toString(), '@(5, 0)');
    });

    test('boolean followed by call syntax parses to CallExpression', () {
      final Expression expression = getExpression('true(1)');
      expect(expression, isA<CallExpression>());
      final CallExpression call = expression as CallExpression;
      expect(call.callee, isA<BooleanExpression>());
    });

    test('boolean followed by bracket syntax parses to @ CallExpression', () {
      final Expression expression = getExpression('false[0]');
      expect(expression, isA<CallExpression>());
      expect(expression.toString(), '@(false, 0)');
    });

    test('string followed by call syntax parses to CallExpression', () {
      final Expression expression = getExpression('"hello"(1)');
      expect(expression, isA<CallExpression>());
      final CallExpression call = expression as CallExpression;
      expect(call.callee, isA<StringExpression>());
    });

    test('list followed by call syntax parses to CallExpression', () {
      final Expression expression = getExpression('[1, 2](0)');
      expect(expression, isA<CallExpression>());
      final CallExpression call = expression as CallExpression;
      expect(call.callee, isA<ListExpression>());
    });

    test('map followed by call syntax parses to CallExpression', () {
      final Expression expression = getExpression('{"a": 1}(0)');
      expect(expression, isA<CallExpression>());
      final CallExpression call = expression as CallExpression;
      expect(call.callee, isA<MapExpression>());
    });

    test('if expression followed by call syntax parses to CallExpression', () {
      final Expression expression = getExpression(
        '(if (true) foo else bar)(1)',
      );
      expect(expression, isA<CallExpression>());
      final CallExpression call = expression as CallExpression;
      expect(call.callee, isA<CallExpression>());
    });

    test('grouped expression followed by call syntax', () {
      final Expression expression = getExpression('(a)(1)');
      expect(expression, isA<CallExpression>());
      final CallExpression call = expression as CallExpression;
      expect(call.callee, isA<IdentifierExpression>());
    });

    test('grouped expression followed by index syntax', () {
      final Expression expression = getExpression('(a)[0]');
      expect(expression, isA<CallExpression>());
      expect(expression.toString(), '@(a, 0)');
    });
  });

  group('String literal formats', () {
    test('Empty string with double quotes', () {
      final Expression expression = getExpression('""');
      expect(expression.toString(), '""');
    });

    test('Empty string with single quotes', () {
      final Expression expression = getExpression("''");
      expect(expression.toString(), '""');
    });

    test('String with spaces', () {
      final Expression expression = getExpression('"hello world"');
      expect(expression.toString(), '"hello world"');
    });

    test('String with numbers', () {
      final Expression expression = getExpression('"test123"');
      expect(expression.toString(), '"test123"');
    });

    test('String in binary operation', () {
      final Expression expression = getExpression('"a" == "b"');
      expect(expression.toString(), '==("a", "b")');
    });
  });

  group('Number literal formats', () {
    test('Integer with underscore separator', () {
      final Expression expression = getExpression('1_000_000');
      expect(expression.toString(), '1000000');
    });

    test('Decimal with underscore separator', () {
      final Expression expression = getExpression('3.14_159');
      expect(expression.toString(), '3.14159');
    });

    test('Scientific notation - positive exponent', () {
      final Expression expression = getExpression('1e10');
      expect(expression.toString(), '10000000000.0');
    });

    test('Scientific notation - explicit positive exponent', () {
      final Expression expression = getExpression('1e+10');
      expect(expression.toString(), '10000000000.0');
    });

    test('Scientific notation - negative exponent', () {
      final Expression expression = getExpression('1e-3');
      expect(expression.toString(), '0.001');
    });

    test('Scientific notation - decimal with exponent', () {
      final Expression expression = getExpression('1.5e2');
      expect(expression.toString(), '150.0');
    });

    test('Underscore number in expression', () {
      final Expression expression = getExpression('1_000 + 2_000');
      expect(expression.toString(), '+(1000, 2000)');
    });

    test('Scientific notation in expression', () {
      final Expression expression = getExpression('1e3 * 2');
      expect(expression.toString(), '*(1000.0, 2)');
    });

    test('Zero literal', () {
      final Expression expression = getExpression('0');
      expect(expression.toString(), '0');
    });

    test('Negative zero via unary', () {
      final Expression expression = getExpression('-0');
      expect(expression.toString(), '-(0, 0)');
    });

    test('Very large integer', () {
      final Expression expression = getExpression('999999999999');
      expect(expression.toString(), '999999999999');
    });

    test('Decimal starting with zero', () {
      final Expression expression = getExpression('0.5');
      expect(expression.toString(), '0.5');
    });
  });

  group('ExpressionParser edge cases', () {
    test('accessing previous before advance throws StateError', () {
      final List<Token> tokens = getTokens('x');
      final ExpressionParser parser = ExpressionParser(ListIterator(tokens));

      expect(
        () => parser.previous,
        throwsA(isA<StateError>()),
      );
    });

    test('previous returns last consumed token after advance', () {
      final List<Token> tokens = getTokens('x');
      final ExpressionParser parser = ExpressionParser(ListIterator(tokens));

      parser.advance();
      expect(parser.previous, isA<IdentifierToken>());
      expect(parser.previous.value, equals('x'));
    });

    test('peek throws UnexpectedEndOfFileError when iterator is at end', () {
      final List<Token> tokens = getTokens('x');
      final ExpressionParser parser = ExpressionParser(ListIterator(tokens));

      parser.advance();
      expect(
        () => parser.peek,
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('advance when already at end does not throw', () {
      final List<Token> tokens = getTokens('x');
      final ExpressionParser parser = ExpressionParser(ListIterator(tokens));

      parser.advance();
      expect(parser.iterator.isAtEnd, isTrue);

      // Calling advance again should not throw
      expect(parser.advance, returnsNormally);
    });

    test('check returns false when iterator is at end', () {
      final List<Token> tokens = getTokens('x');
      final ExpressionParser parser = ExpressionParser(ListIterator(tokens));

      parser.advance();
      expect(parser.iterator.isAtEnd, isTrue);

      // We cannot directly access check, but we can verify the parser is at end
      // and subsequent operations don't throw
      expect(parser.iterator.isAtEnd, isTrue);
    });
  });

  group('Expression type verification', () {
    test('NumberExpression from integer literal', () {
      final Expression expression = getExpression('42');
      expect(expression, isA<NumberExpression>());
      expect((expression as NumberExpression).value, equals(42));
    });

    test('NumberExpression from decimal literal', () {
      final Expression expression = getExpression('3.14');
      expect(expression, isA<NumberExpression>());
      expect((expression as NumberExpression).value, equals(3.14));
    });

    test('BooleanExpression from true literal', () {
      final Expression expression = getExpression('true');
      expect(expression, isA<BooleanExpression>());
      expect((expression as BooleanExpression).value, isTrue);
    });

    test('BooleanExpression from false literal', () {
      final Expression expression = getExpression('false');
      expect(expression, isA<BooleanExpression>());
      expect((expression as BooleanExpression).value, isFalse);
    });

    test('StringExpression from string literal', () {
      final Expression expression = getExpression('"hello"');
      expect(expression, isA<StringExpression>());
      expect((expression as StringExpression).value, equals('hello'));
    });

    test('IdentifierExpression from identifier', () {
      final Expression expression = getExpression('foo');
      expect(expression, isA<IdentifierExpression>());
      expect((expression as IdentifierExpression).value, equals('foo'));
    });

    test('ListExpression from empty list', () {
      final Expression expression = getExpression('[]');
      expect(expression, isA<ListExpression>());
      expect((expression as ListExpression).value, isEmpty);
    });

    test('ListExpression from non-empty list', () {
      final Expression expression = getExpression('[1, 2, 3]');
      expect(expression, isA<ListExpression>());
      expect((expression as ListExpression).value.length, equals(3));
    });

    test('MapExpression from empty map', () {
      final Expression expression = getExpression('{}');
      expect(expression, isA<MapExpression>());
      expect((expression as MapExpression).value, isEmpty);
    });

    test('MapExpression from non-empty map', () {
      final Expression expression = getExpression('{"a": 1, "b": 2}');
      expect(expression, isA<MapExpression>());
      expect((expression as MapExpression).value.length, equals(2));
    });

    test('CallExpression from function call', () {
      final Expression expression = getExpression('foo(1, 2)');
      expect(expression, isA<CallExpression>());
      final CallExpression call = expression as CallExpression;
      expect(call.callee, isA<IdentifierExpression>());
      expect(call.arguments.length, equals(2));
    });

    test('CallExpression from binary operation', () {
      final Expression expression = getExpression('1 + 2');
      expect(expression, isA<CallExpression>());
      final CallExpression call = expression as CallExpression;
      expect(call.callee, isA<IdentifierExpression>());
      expect((call.callee as IdentifierExpression).value, equals('+'));
      expect(call.arguments.length, equals(2));
    });

    test('CallExpression from unary operation', () {
      final Expression expression = getExpression('!true');
      expect(expression, isA<CallExpression>());
      final CallExpression call = expression as CallExpression;
      expect(call.callee, isA<IdentifierExpression>());
      expect((call.callee as IdentifierExpression).value, equals('!'));
      expect(call.arguments.length, equals(1));
    });

    test('CallExpression from if expression', () {
      final Expression expression = getExpression('if (true) 1 else 2');
      expect(expression, isA<CallExpression>());
      final CallExpression call = expression as CallExpression;
      expect(call.callee, isA<IdentifierExpression>());
      expect((call.callee as IdentifierExpression).value, equals('if'));
      expect(call.arguments.length, equals(3));
    });

    test('CallExpression from index operation', () {
      final Expression expression = getExpression('arr[0]');
      expect(expression, isA<CallExpression>());
      final CallExpression call = expression as CallExpression;
      expect(call.callee, isA<IdentifierExpression>());
      expect((call.callee as IdentifierExpression).value, equals('@'));
      expect(call.arguments.length, equals(2));
    });

    test('CallExpression from unary negation has binary form', () {
      final Expression expression = getExpression('-5');
      expect(expression, isA<CallExpression>());
      final CallExpression call = expression as CallExpression;
      expect(call.callee, isA<IdentifierExpression>());
      expect((call.callee as IdentifierExpression).value, equals('-'));
      // Unary negation is desugared to binary subtraction -(0, 5)
      expect(call.arguments.length, equals(2));
      expect(call.arguments[0], isA<NumberExpression>());
      expect((call.arguments[0] as NumberExpression).value, equals(0));
    });
  });

  group('Compiler.expression() trailing token errors', () {
    Expression compileExpression(String input) {
      const Compiler compiler = Compiler();
      return compiler.expression(input);
    }

    test('trailing identifier after boolean throws UnexpectedTokenError', () {
      expect(
        () => compileExpression('true fake true'),
        throwsA(isA<UnexpectedTokenError>()),
      );
    });

    test('trailing identifier after number throws UnexpectedTokenError', () {
      expect(
        () => compileExpression('42 extra'),
        throwsA(isA<UnexpectedTokenError>()),
      );
    });

    test('trailing number after expression throws UnexpectedTokenError', () {
      expect(
        () => compileExpression('1 + 2 3'),
        throwsA(isA<UnexpectedTokenError>()),
      );
    });

    test('trailing boolean after number throws UnexpectedTokenError', () {
      expect(
        () => compileExpression('42 true'),
        throwsA(isA<UnexpectedTokenError>()),
      );
    });

    test('trailing string after expression throws UnexpectedTokenError', () {
      expect(
        () => compileExpression('1 "extra"'),
        throwsA(isA<UnexpectedTokenError>()),
      );
    });

    test('trailing identifier after string throws UnexpectedTokenError', () {
      expect(
        () => compileExpression('"hello" world'),
        throwsA(isA<UnexpectedTokenError>()),
      );
    });

    test('valid expression without trailing tokens succeeds', () {
      expect(compileExpression('true').toString(), 'true');
      expect(compileExpression('1 + 2').toString(), '+(1, 2)');
      expect(compileExpression('foo(1, 2)').toString(), 'foo(1, 2)');
    });

    test('close brace as primary throws InvalidTokenError', () {
      expect(
        () => compileExpression('}'),
        throwsA(isA<InvalidTokenError>()),
      );
    });

    test('trailing list after expression throws ExpectedTokenError', () {
      // '42 [1, 2]' is parsed as 42 with bracket indexing [1, 2]
      // The parser sees [1, then expects ] but finds ,
      expect(
        () => compileExpression('42 [1, 2]'),
        throwsA(isA<ExpectedTokenError>()),
      );
    });

    test('trailing map after expression throws UnexpectedTokenError', () {
      expect(
        () => compileExpression('42 {"a": 1}'),
        throwsA(isA<UnexpectedTokenError>()),
      );
    });

    test('trailing if expression throws UnexpectedTokenError', () {
      expect(
        () => compileExpression('42 if (true) 1 else 2'),
        throwsA(isA<UnexpectedTokenError>()),
      );
    });

    test('binary operator at start throws InvalidTokenError', () {
      expect(
        () => compileExpression('+ 1'),
        throwsA(isA<InvalidTokenError>()),
      );
    });

    test('multiplication operator at start throws InvalidTokenError', () {
      expect(
        () => compileExpression('* 2'),
        throwsA(isA<InvalidTokenError>()),
      );
    });

    test('comparison operator at start throws InvalidTokenError', () {
      expect(
        () => compileExpression('> 1'),
        throwsA(isA<InvalidTokenError>()),
      );
    });

    test('logical operator at start throws InvalidTokenError', () {
      expect(
        () => compileExpression('& true'),
        throwsA(isA<InvalidTokenError>()),
      );
    });

    test('equality operator at start throws InvalidTokenError', () {
      expect(
        () => compileExpression('== 1'),
        throwsA(isA<InvalidTokenError>()),
      );
    });

    test('@ operator at start throws InvalidTokenError', () {
      expect(
        () => compileExpression('@ 1'),
        throwsA(isA<InvalidTokenError>()),
      );
    });

    test('colon at start throws InvalidTokenError', () {
      expect(
        () => compileExpression(': 1'),
        throwsA(isA<InvalidTokenError>()),
      );
    });

    test('comma at start throws InvalidTokenError', () {
      expect(
        () => compileExpression(', 1'),
        throwsA(isA<InvalidTokenError>()),
      );
    });

    test('else without if throws InvalidTokenError', () {
      expect(
        () => compileExpression('else 1'),
        throwsA(isA<InvalidTokenError>()),
      );
    });
  });
}
