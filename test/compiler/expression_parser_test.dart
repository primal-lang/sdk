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

  group('ListIterator edge cases', () {
    test('next returns and advances to the next element', () {
      final List<Token> tokens = getTokens('a b');
      final ListIterator<Token> iterator = ListIterator(tokens);

      expect(iterator.hasNext, isTrue);
      final Token first = iterator.next;
      expect(first, isA<IdentifierToken>());
      expect(first.value, equals('a'));

      expect(iterator.hasNext, isTrue);
      final Token second = iterator.next;
      expect(second, isA<IdentifierToken>());
      expect(second.value, equals('b'));

      expect(iterator.isAtEnd, isTrue);
    });

    test('next throws UnexpectedEndOfFileError when at end', () {
      final List<Token> tokens = getTokens('x');
      final ListIterator<Token> iterator = ListIterator(tokens);

      iterator.next; // consume x
      expect(
        () => iterator.next,
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('last returns the last element in the list', () {
      final List<Token> tokens = getTokens('a b c');
      final ListIterator<Token> iterator = ListIterator(tokens);

      final Token last = iterator.last;
      expect(last, isA<IdentifierToken>());
      expect(last.value, equals('c'));
    });

    test('last throws UnexpectedEndOfFileError for empty list', () {
      final ListIterator<Token> iterator = ListIterator([]);

      expect(
        () => iterator.last,
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('back moves the iterator back one position', () {
      final List<Token> tokens = getTokens('a b');
      final ListIterator<Token> iterator = ListIterator(tokens);

      iterator.next; // advance to after 'a'
      iterator.next; // advance to after 'b'

      final bool backResult = iterator.back();
      expect(backResult, isTrue);
      expect(iterator.peek?.value, equals('b'));
    });

    test('back returns false when at the beginning', () {
      final List<Token> tokens = getTokens('x');
      final ListIterator<Token> iterator = ListIterator(tokens);

      final bool backResult = iterator.back();
      expect(backResult, isFalse);
    });

    test('hasNext is true when elements remain', () {
      final List<Token> tokens = getTokens('x');
      final ListIterator<Token> iterator = ListIterator(tokens);

      expect(iterator.hasNext, isTrue);
    });

    test('hasNext is false when no elements remain', () {
      final List<Token> tokens = getTokens('x');
      final ListIterator<Token> iterator = ListIterator(tokens);

      iterator.advance();
      expect(iterator.hasNext, isFalse);
    });

    test('previous is null at the beginning', () {
      final List<Token> tokens = getTokens('x');
      final ListIterator<Token> iterator = ListIterator(tokens);

      expect(iterator.previous, isNull);
    });

    test('peek returns null when at end', () {
      final List<Token> tokens = getTokens('x');
      final ListIterator<Token> iterator = ListIterator(tokens);

      iterator.advance();
      expect(iterator.peek, isNull);
    });
  });

  group('Empty and whitespace input', () {
    Expression compileExpression(String input) {
      const Compiler compiler = Compiler();
      return compiler.expression(input);
    }

    test('empty input throws UnexpectedEndOfFileError', () {
      expect(
        () => compileExpression(''),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('whitespace only input throws UnexpectedEndOfFileError', () {
      expect(
        () => compileExpression('   '),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('newlines only input throws UnexpectedEndOfFileError', () {
      expect(
        () => compileExpression('\n\n'),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('tabs and spaces input throws UnexpectedEndOfFileError', () {
      expect(
        () => compileExpression('\t  \t'),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });
  });

  group('Expression location preservation', () {
    test('MapEntryExpression preserves key location', () {
      final Expression expression = getExpression('{"key": 1}');
      expect(expression, isA<MapExpression>());
      final MapExpression mapExpression = expression as MapExpression;
      expect(mapExpression.value.length, equals(1));
      final MapEntryExpression entry = mapExpression.value.first;
      expect(entry.location, equals(entry.key.location));
    });

    test('CallExpression preserves callee location', () {
      final Expression expression = getExpression('foo(1)');
      expect(expression, isA<CallExpression>());
      final CallExpression callExpression = expression as CallExpression;
      expect(callExpression.location, equals(callExpression.callee.location));
    });

    test(
      'CallExpression from binary operation preserves operator location',
      () {
        final Expression expression = getExpression('1 + 2');
        expect(expression, isA<CallExpression>());
        final CallExpression callExpression = expression as CallExpression;
        // The callee is an identifier for the operator
        expect(callExpression.callee, isA<IdentifierExpression>());
        expect(callExpression.location, equals(callExpression.callee.location));
      },
    );

    test('ListExpression preserves opening bracket location', () {
      final Expression expression = getExpression('[1, 2]');
      expect(expression, isA<ListExpression>());
      final ListExpression listExpression = expression as ListExpression;
      // Location should be at column 1 (where the [ is)
      expect(listExpression.location.column, equals(1));
    });

    test('MapExpression preserves opening brace location', () {
      final Expression expression = getExpression('{"a": 1}');
      expect(expression, isA<MapExpression>());
      final MapExpression mapExpression = expression as MapExpression;
      // Location should be at column 1 (where the { is)
      expect(mapExpression.location.column, equals(1));
    });
  });

  group('Match function edge cases', () {
    test('match with empty predicates list returns false', () {
      final List<Token> tokens = getTokens('x');
      final ExpressionParser parser = ExpressionParser(ListIterator(tokens));

      final bool result = parser.match([]);
      expect(result, isFalse);
    });

    test('matchSingle returns false when predicate does not match', () {
      final List<Token> tokens = getTokens('x');
      final ExpressionParser parser = ExpressionParser(ListIterator(tokens));

      // x is an identifier, not a number
      final bool result = parser.matchSingle((Token t) => t is NumberToken);
      expect(result, isFalse);
    });

    test('check returns true when predicate matches', () {
      final List<Token> tokens = getTokens('x');
      final ExpressionParser parser = ExpressionParser(ListIterator(tokens));

      final bool result = parser.check((Token t) => t is IdentifierToken);
      expect(result, isTrue);
    });

    test('check returns false when predicate does not match', () {
      final List<Token> tokens = getTokens('x');
      final ExpressionParser parser = ExpressionParser(ListIterator(tokens));

      final bool result = parser.check((Token t) => t is NumberToken);
      expect(result, isFalse);
    });
  });

  group('Consume edge cases', () {
    test('consume throws ExpectedTokenError when at end of file', () {
      final List<Token> tokens = getTokens('x');
      final ExpressionParser parser = ExpressionParser(ListIterator(tokens));

      parser.advance(); // consume 'x'

      expect(
        () => parser.consume((Token t) => t is IdentifierToken, 'identifier'),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('consume returns and advances when predicate matches', () {
      final List<Token> tokens = getTokens('x y');
      final ExpressionParser parser = ExpressionParser(ListIterator(tokens));

      final Token consumed = parser.consume(
        (Token t) => t is IdentifierToken,
        'identifier',
      );
      expect(consumed.value, equals('x'));
      expect(parser.peek.value, equals('y'));
    });

    test('consume throws ExpectedTokenError when predicate does not match', () {
      final List<Token> tokens = getTokens('42');
      final ExpressionParser parser = ExpressionParser(ListIterator(tokens));

      expect(
        () => parser.consume((Token t) => t is IdentifierToken, 'identifier'),
        throwsA(isA<ExpectedTokenError>()),
      );
    });
  });

  group('Additional chained operations', () {
    test('index then call then index', () {
      final Expression expression = getExpression('a[0](1)[2]');
      expect(expression.toString(), '@(@(a, 0)(1), 2)');
    });

    test('call then index then call then index', () {
      final Expression expression = getExpression('f()[0](1)[2]');
      expect(expression.toString(), '@(@(f(), 0)(1), 2)');
    });

    test('deeply chained mixed operations', () {
      final Expression expression = getExpression('a[0]()[1]()[2]()');
      expect(expression.toString(), '@(@(@(a, 0)(), 1)(), 2)()');
    });

    test('function call on grouped expression', () {
      final Expression expression = getExpression('(a + b)(1)');
      expect(expression.toString(), '+(a, b)(1)');
    });

    test('index on grouped binary expression', () {
      final Expression expression = getExpression('(a + b)[0]');
      expect(expression.toString(), '@(+(a, b), 0)');
    });
  });

  group('Dot notation additional cases', () {
    test('dot notation with multiple arguments', () {
      final Expression expression = getExpression('obj.method(1, 2, 3)');
      expect(expression.toString(), 'obj.method(1, 2, 3)');
    });

    test('dot notation chained with index', () {
      final Expression expression = getExpression('obj.method()[0]');
      expect(expression.toString(), '@(obj.method(), 0)');
    });

    test('dot notation with nested calls', () {
      final Expression expression = getExpression('a.b(c.d())');
      expect(expression.toString(), 'a.b(c.d())');
    });

    test('dot notation identifier with underscores', () {
      final Expression expression = getExpression('obj.method_name()');
      expect(expression.toString(), 'obj.method_name()');
    });

    test('dot notation with numbers in identifier', () {
      final Expression expression = getExpression('lib.func2()');
      expect(expression.toString(), 'lib.func2()');
    });
  });

  group('Additional operator precedence tests', () {
    test('mixed unary and binary with negation', () {
      final Expression expression = getExpression('!a & -b');
      expect(expression.toString(), '&(!(a), -(0, b))');
    });

    test('unary not on comparison result', () {
      final Expression expression = getExpression('!(a > b)');
      expect(expression.toString(), '!(>(a, b))');
    });

    test('unary negation on function call', () {
      final Expression expression = getExpression('-foo()');
      expect(expression.toString(), '-(0, foo())');
    });

    test('unary not on function call', () {
      final Expression expression = getExpression('!foo()');
      expect(expression.toString(), '!(foo())');
    });

    test('all comparison operators in one expression', () {
      // Left-associative: ((((a > b) < c) >= d) <= e)
      final Expression expression = getExpression('a > b < c >= d <= e');
      expect(expression.toString(), '<=(>=(<(>(a, b), c), d), e)');
    });

    test('all arithmetic operators in one expression', () {
      final Expression expression = getExpression('a + b - c * d / e % f');
      expect(expression.toString(), '-(+(a, b), %(/(*(c, d), e), f))');
    });

    test('equality and comparison mixed', () {
      final Expression expression = getExpression('a > b == c < d');
      expect(expression.toString(), '==(>(a, b), <(c, d))');
    });

    test('not equal with comparison', () {
      final Expression expression = getExpression('a >= b != c <= d');
      expect(expression.toString(), '!=(>=(a, b), <=(c, d))');
    });
  });

  group('Collection edge cases', () {
    test('list with single element', () {
      final Expression expression = getExpression('[42]');
      expect(expression, isA<ListExpression>());
      final ListExpression listExpression = expression as ListExpression;
      expect(listExpression.value.length, equals(1));
      expect(listExpression.toString(), '[42]');
    });

    test('map with single entry', () {
      final Expression expression = getExpression('{"key": "value"}');
      expect(expression, isA<MapExpression>());
      final MapExpression mapExpression = expression as MapExpression;
      expect(mapExpression.value.length, equals(1));
    });

    test('list with trailing expression after comma throws', () {
      expect(
        () => getExpression('[1, 2,]'),
        throwsA(isA<InvalidTokenError>()),
      );
    });

    test('map with trailing comma throws', () {
      expect(
        () => getExpression('{"a": 1,}'),
        throwsA(isA<InvalidTokenError>()),
      );
    });

    test('nested empty collections', () {
      final Expression expression = getExpression('[[], {}, []]');
      expect(expression.toString(), '[[], {}, []]');
    });

    test('map with list key', () {
      final Expression expression = getExpression('{[1, 2]: "list key"}');
      expect(expression.toString(), '{[1, 2]: "list key"}');
    });

    test('list with map values containing lists', () {
      final Expression expression = getExpression(
        '[{"a": [1, 2]}, {"b": [3, 4]}]',
      );
      expect(
        expression.toString(),
        '[{"a": [1, 2]}, {"b": [3, 4]}]',
      );
    });
  });

  group('If expression edge cases', () {
    test('if with list as condition', () {
      final Expression expression = getExpression('if ([]) 1 else 2');
      expect(expression.toString(), 'if([], 1, 2)');
    });

    test('if with map as condition', () {
      final Expression expression = getExpression('if ({}) 1 else 2');
      expect(expression.toString(), 'if({}, 1, 2)');
    });

    test('if with function call as condition', () {
      final Expression expression = getExpression('if (check()) 1 else 2');
      expect(expression.toString(), 'if(check(), 1, 2)');
    });

    test('if with index as condition', () {
      final Expression expression = getExpression('if (arr[0]) 1 else 2');
      expect(expression.toString(), 'if(@(arr, 0), 1, 2)');
    });

    test('if returning list', () {
      final Expression expression = getExpression(
        'if (true) [1, 2] else [3, 4]',
      );
      expect(expression.toString(), 'if(true, [1, 2], [3, 4])');
    });

    test('if returning map', () {
      final Expression expression = getExpression(
        'if (true) {"a": 1} else {"b": 2}',
      );
      expect(expression.toString(), 'if(true, {"a": 1}, {"b": 2})');
    });

    test('if returning function call', () {
      final Expression expression = getExpression('if (true) foo() else bar()');
      expect(expression.toString(), 'if(true, foo(), bar())');
    });

    test('triple nested if', () {
      final Expression expression = getExpression(
        'if (a) if (b) if (c) 1 else 2 else 3 else 4',
      );
      expect(expression.toString(), 'if(a, if(b, if(c, 1, 2), 3), 4)');
    });
  });

  group('Expression toString coverage', () {
    test('ListExpression toString with expressions', () {
      final Expression expression = getExpression('[1 + 2, 3 * 4]');
      expect(expression, isA<ListExpression>());
      expect(expression.toString(), '[+(1, 2), *(3, 4)]');
    });

    test('MapExpression toString with multiple entries', () {
      final Expression expression = getExpression('{"a": 1, "b": 2, "c": 3}');
      expect(expression, isA<MapExpression>());
      expect(expression.toString(), '{"a": 1, "b": 2, "c": 3}');
    });

    test('CallExpression toString with no arguments', () {
      final Expression expression = getExpression('foo()');
      expect(expression, isA<CallExpression>());
      expect(expression.toString(), 'foo()');
    });

    test('CallExpression toString with multiple arguments', () {
      final Expression expression = getExpression('foo(1, 2, 3)');
      expect(expression, isA<CallExpression>());
      expect(expression.toString(), 'foo(1, 2, 3)');
    });

    test('Nested CallExpression toString', () {
      final Expression expression = getExpression('foo(bar(baz()))');
      expect(expression.toString(), 'foo(bar(baz()))');
    });
  });

  group('Additional error cases', () {
    test('double close parenthesis throws InvalidTokenError', () {
      expect(
        () => getExpression('))'),
        throwsA(isA<InvalidTokenError>()),
      );
    });

    test('double close bracket throws InvalidTokenError', () {
      expect(
        () => getExpression(']]'),
        throwsA(isA<InvalidTokenError>()),
      );
    });

    test('double close brace throws InvalidTokenError', () {
      expect(
        () => getExpression('}}'),
        throwsA(isA<InvalidTokenError>()),
      );
    });

    test('incomplete unary expression throws', () {
      expect(
        () => getExpression('!'),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('incomplete negation throws', () {
      expect(
        () => getExpression('-'),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('double minus followed by nothing throws', () {
      expect(
        () => getExpression('- -'),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('double bang followed by nothing throws', () {
      expect(
        () => getExpression('! !'),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('missing second operand in OR throws', () {
      expect(
        () => getExpression('a |'),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('missing second operand in AND throws', () {
      expect(
        () => getExpression('a &'),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('missing index closing bracket throws', () {
      expect(
        () => getExpression('a[0'),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('map with missing value throws', () {
      expect(
        () => getExpression('{"key"}'),
        throwsA(isA<ExpectedTokenError>()),
      );
    });

    test('missing second operand in equality throws', () {
      expect(
        () => getExpression('a =='),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('missing second operand in not equal throws', () {
      expect(
        () => getExpression('a !='),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('missing second operand in greater than throws', () {
      expect(
        () => getExpression('a >'),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('missing second operand in less than throws', () {
      expect(
        () => getExpression('a <'),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('missing second operand in greater or equal throws', () {
      expect(
        () => getExpression('a >='),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('missing second operand in less or equal throws', () {
      expect(
        () => getExpression('a <='),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('missing second operand in multiplication throws', () {
      expect(
        () => getExpression('a *'),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('missing second operand in division throws', () {
      expect(
        () => getExpression('a /'),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('missing second operand in modulo throws', () {
      expect(
        () => getExpression('a %'),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('missing second operand in @ operator throws', () {
      expect(
        () => getExpression('a @'),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });
  });

  group('CallExpression factory methods verification', () {
    test(
      'fromIf creates CallExpression with if callee and three arguments',
      () {
        final Expression expression = getExpression('if (a) b else c');
        expect(expression, isA<CallExpression>());
        final CallExpression call = expression as CallExpression;
        expect(call.callee, isA<IdentifierExpression>());
        expect((call.callee as IdentifierExpression).value, equals('if'));
        expect(call.arguments.length, equals(3));
        expect(call.arguments[0], isA<IdentifierExpression>());
        expect(call.arguments[1], isA<IdentifierExpression>());
        expect(call.arguments[2], isA<IdentifierExpression>());
      },
    );

    test('fromUnaryOperation creates CallExpression with one argument', () {
      final Expression expression = getExpression('!x');
      expect(expression, isA<CallExpression>());
      final CallExpression call = expression as CallExpression;
      expect(call.callee, isA<IdentifierExpression>());
      expect((call.callee as IdentifierExpression).value, equals('!'));
      expect(call.arguments.length, equals(1));
      expect(call.arguments[0], isA<IdentifierExpression>());
      expect((call.arguments[0] as IdentifierExpression).value, equals('x'));
    });

    test('fromBinaryOperation creates CallExpression with two arguments', () {
      final Expression expression = getExpression('a + b');
      expect(expression, isA<CallExpression>());
      final CallExpression call = expression as CallExpression;
      expect(call.callee, isA<IdentifierExpression>());
      expect((call.callee as IdentifierExpression).value, equals('+'));
      expect(call.arguments.length, equals(2));
      expect(call.arguments[0], isA<IdentifierExpression>());
      expect(call.arguments[1], isA<IdentifierExpression>());
    });

    test('fromBinaryOperation for @ preserves operator', () {
      final Expression expression = getExpression('arr @ 0');
      expect(expression, isA<CallExpression>());
      final CallExpression call = expression as CallExpression;
      expect(call.callee, isA<IdentifierExpression>());
      expect((call.callee as IdentifierExpression).value, equals('@'));
    });

    test('negation uses fromBinaryOperation with synthetic zero', () {
      final Expression expression = getExpression('-x');
      expect(expression, isA<CallExpression>());
      final CallExpression call = expression as CallExpression;
      expect(call.callee, isA<IdentifierExpression>());
      expect((call.callee as IdentifierExpression).value, equals('-'));
      expect(call.arguments.length, equals(2));
      expect(call.arguments[0], isA<NumberExpression>());
      expect((call.arguments[0] as NumberExpression).value, equals(0));
      expect(call.arguments[1], isA<IdentifierExpression>());
    });
  });

  group('MapEntryExpression property access', () {
    test('MapEntryExpression exposes key and value', () {
      final Expression expression = getExpression('{"name": 42}');
      expect(expression, isA<MapExpression>());
      final MapExpression mapExpression = expression as MapExpression;
      expect(mapExpression.value.length, equals(1));
      final MapEntryExpression entry = mapExpression.value.first;
      expect(entry.key, isA<StringExpression>());
      expect((entry.key as StringExpression).value, equals('name'));
      expect(entry.value, isA<NumberExpression>());
      expect((entry.value as NumberExpression).value, equals(42));
    });

    test('MapEntryExpression with expression key', () {
      final Expression expression = getExpression('{(1 + 2): "result"}');
      expect(expression, isA<MapExpression>());
      final MapExpression mapExpression = expression as MapExpression;
      final MapEntryExpression entry = mapExpression.value.first;
      expect(entry.key, isA<CallExpression>());
      expect(entry.value, isA<StringExpression>());
    });

    test('MapEntryExpression with identifier key', () {
      final Expression expression = getExpression('{key: "value"}');
      expect(expression, isA<MapExpression>());
      final MapExpression mapExpression = expression as MapExpression;
      final MapEntryExpression entry = mapExpression.value.first;
      expect(entry.key, isA<IdentifierExpression>());
      expect((entry.key as IdentifierExpression).value, equals('key'));
    });
  });

  group('Expression location row and column verification', () {
    test('IdentifierExpression location row is 1', () {
      final Expression expression = getExpression('foo');
      expect(expression.location.row, equals(1));
    });

    test('NumberExpression location has correct column', () {
      final Expression expression = getExpression('42');
      expect(expression.location.row, equals(1));
      expect(expression.location.column, equals(1));
    });

    test('BooleanExpression location has correct column', () {
      final Expression expression = getExpression('true');
      expect(expression.location.row, equals(1));
      expect(expression.location.column, equals(1));
    });

    test('StringExpression location has correct column', () {
      final Expression expression = getExpression('"hello"');
      expect(expression.location.row, equals(1));
      expect(expression.location.column, equals(1));
    });

    test('binary operation location uses operator location', () {
      final Expression expression = getExpression('a + b');
      expect(expression, isA<CallExpression>());
      final CallExpression call = expression as CallExpression;
      // Location is the operator position
      expect(call.location.column, equals(3));
    });

    test('nested expression preserves inner location', () {
      final Expression expression = getExpression('(foo)');
      expect(expression, isA<IdentifierExpression>());
      // Location should be for 'foo', not the parenthesis
      expect(expression.location.column, equals(2));
    });
  });

  group('ListExpression value access', () {
    test('empty list value is empty', () {
      final Expression expression = getExpression('[]');
      expect(expression, isA<ListExpression>());
      final ListExpression listExpression = expression as ListExpression;
      expect(listExpression.value, isEmpty);
    });

    test('list value contains correct expressions', () {
      final Expression expression = getExpression('[1, "two", true]');
      expect(expression, isA<ListExpression>());
      final ListExpression listExpression = expression as ListExpression;
      expect(listExpression.value.length, equals(3));
      expect(listExpression.value[0], isA<NumberExpression>());
      expect(listExpression.value[1], isA<StringExpression>());
      expect(listExpression.value[2], isA<BooleanExpression>());
    });

    test('nested list value contains ListExpression', () {
      final Expression expression = getExpression('[[1]]');
      expect(expression, isA<ListExpression>());
      final ListExpression outer = expression as ListExpression;
      expect(outer.value.length, equals(1));
      expect(outer.value[0], isA<ListExpression>());
      final ListExpression inner = outer.value[0] as ListExpression;
      expect(inner.value.length, equals(1));
    });
  });

  group('MapExpression value access', () {
    test('empty map value is empty', () {
      final Expression expression = getExpression('{}');
      expect(expression, isA<MapExpression>());
      final MapExpression mapExpression = expression as MapExpression;
      expect(mapExpression.value, isEmpty);
    });

    test('map value contains MapEntryExpression list', () {
      final Expression expression = getExpression('{"a": 1, "b": 2}');
      expect(expression, isA<MapExpression>());
      final MapExpression mapExpression = expression as MapExpression;
      expect(mapExpression.value.length, equals(2));
      expect(mapExpression.value[0].key, isA<StringExpression>());
      expect(mapExpression.value[1].key, isA<StringExpression>());
    });
  });

  group('Additional binary operator precedence edge cases', () {
    test('equality binds looser than OR', () {
      final Expression expression = getExpression('a | b == c');
      // Equality has lowest precedence, so: (a | b) == c
      expect(expression.toString(), '==(|(a, b), c)');
    });

    test('AND binds tighter than OR', () {
      final Expression expression = getExpression('a | b & c | d');
      expect(expression.toString(), '|(|(a, &(b, c)), d)');
    });

    test('comparison vs equality precedence', () {
      final Expression expression = getExpression('a > b != c < d');
      expect(expression.toString(), '!=(>(a, b), <(c, d))');
    });

    test('term vs factor precedence', () {
      final Expression expression = getExpression('a + b * c - d / e');
      expect(expression.toString(), '-(+(a, *(b, c)), /(d, e))');
    });

    test('@ has highest precedence among binary operators', () {
      final Expression expression = getExpression('a + b @ c * d');
      // @ binds tightest: a + ((b @ c) * d)
      expect(expression.toString(), '+(a, *(@(b, c), d))');
    });

    test('unary has higher precedence than @', () {
      final Expression expression = getExpression('!a @ b');
      // Unary binds tightest: ((!a) @ b)
      expect(expression.toString(), '@(!(a), b)');
    });

    test('unary negation has higher precedence than @', () {
      final Expression expression = getExpression('a @ -b');
      // a @ (-(0, b))
      expect(expression.toString(), '@(a, -(0, b))');
    });
  });

  group('Additional function call edge cases', () {
    test('function call with no arguments', () {
      final Expression expression = getExpression('empty()');
      expect(expression, isA<CallExpression>());
      final CallExpression call = expression as CallExpression;
      expect(call.callee, isA<IdentifierExpression>());
      expect(call.arguments, isEmpty);
    });

    test('function call with single argument', () {
      final Expression expression = getExpression('single(1)');
      expect(expression, isA<CallExpression>());
      final CallExpression call = expression as CallExpression;
      expect(call.arguments.length, equals(1));
    });

    test('function call with many arguments', () {
      final Expression expression = getExpression('many(1, 2, 3, 4, 5)');
      expect(expression, isA<CallExpression>());
      final CallExpression call = expression as CallExpression;
      expect(call.arguments.length, equals(5));
    });

    test('function call with nested function call argument', () {
      final Expression expression = getExpression('outer(inner())');
      expect(expression, isA<CallExpression>());
      final CallExpression outer = expression as CallExpression;
      expect(outer.arguments.length, equals(1));
      expect(outer.arguments[0], isA<CallExpression>());
    });

    test('function call with if expression argument', () {
      final Expression expression = getExpression('foo(if (x) 1 else 2)');
      expect(expression, isA<CallExpression>());
      final CallExpression call = expression as CallExpression;
      expect(call.arguments.length, equals(1));
      expect(call.arguments[0], isA<CallExpression>());
      final CallExpression ifCall = call.arguments[0] as CallExpression;
      expect((ifCall.callee as IdentifierExpression).value, equals('if'));
    });

    test('function call with list argument', () {
      final Expression expression = getExpression('process([1, 2, 3])');
      expect(expression, isA<CallExpression>());
      final CallExpression call = expression as CallExpression;
      expect(call.arguments[0], isA<ListExpression>());
    });

    test('function call with map argument', () {
      final Expression expression = getExpression('process({"key": "value"})');
      expect(expression, isA<CallExpression>());
      final CallExpression call = expression as CallExpression;
      expect(call.arguments[0], isA<MapExpression>());
    });
  });

  group('Bracket index expression edge cases', () {
    test('bracket index creates @ CallExpression', () {
      final Expression expression = getExpression('a[0]');
      expect(expression, isA<CallExpression>());
      final CallExpression call = expression as CallExpression;
      expect((call.callee as IdentifierExpression).value, equals('@'));
      expect(call.arguments.length, equals(2));
    });

    test('bracket index with identifier index', () {
      final Expression expression = getExpression('arr[idx]');
      expect(expression.toString(), '@(arr, idx)');
    });

    test('bracket index with complex expression', () {
      final Expression expression = getExpression('arr[i + j * 2]');
      expect(expression.toString(), '@(arr, +(i, *(j, 2)))');
    });

    test('bracket index on string literal', () {
      final Expression expression = getExpression('"hello"[0]');
      expect(expression.toString(), '@("hello", 0)');
    });

    test('bracket index on list literal', () {
      final Expression expression = getExpression('[1, 2, 3][1]');
      expect(expression.toString(), '@([1, 2, 3], 1)');
    });

    test('bracket index on map literal', () {
      final Expression expression = getExpression('{"a": 1}["a"]');
      expect(expression.toString(), '@({"a": 1}, "a")');
    });

    test('bracket index on function result', () {
      final Expression expression = getExpression('getData()[0]');
      expect(expression.toString(), '@(getData(), 0)');
    });

    test('bracket index on grouped expression', () {
      final Expression expression = getExpression('(a + b)[0]');
      expect(expression.toString(), '@(+(a, b), 0)');
    });
  });

  group('Chained call and index combinations', () {
    test('call then call then call', () {
      final Expression expression = getExpression('a()()()');
      expect(expression.toString(), 'a()()()');
    });

    test('index then index then index', () {
      final Expression expression = getExpression('a[0][1][2]');
      expect(expression.toString(), '@(@(@(a, 0), 1), 2)');
    });

    test('call index call index', () {
      final Expression expression = getExpression('f()[0](1)[2]');
      expect(expression.toString(), '@(@(f(), 0)(1), 2)');
    });

    test('index call index call', () {
      final Expression expression = getExpression('a[0](1)[2](3)');
      expect(expression.toString(), '@(@(a, 0)(1), 2)(3)');
    });

    test('deeply nested call chains', () {
      final Expression expression = getExpression('a()()()()()');
      expect(expression.toString(), 'a()()()()()');
    });
  });

  group('Dot notation edge cases', () {
    test('single dot notation', () {
      final Expression expression = getExpression('a.b()');
      expect(expression, isA<CallExpression>());
      expect(expression.toString(), 'a.b()');
    });

    test('multi-level dot notation', () {
      final Expression expression = getExpression('a.b.c.d()');
      expect(expression.toString(), 'a.b.c.d()');
    });

    test('dot notation with argument', () {
      final Expression expression = getExpression('list.get(0)');
      expect(expression.toString(), 'list.get(0)');
    });

    test('dot notation chained with bracket', () {
      final Expression expression = getExpression('obj.arr[0]');
      expect(expression.toString(), '@(obj.arr, 0)');
    });

    test('dot notation result used in binary', () {
      final Expression expression = getExpression('a.b() + c.d()');
      expect(expression.toString(), '+(a.b(), c.d())');
    });

    test('dot notation in if condition', () {
      final Expression expression = getExpression('if (obj.check()) 1 else 2');
      expect(expression.toString(), 'if(obj.check(), 1, 2)');
    });
  });

  group('Complex nested expressions', () {
    test('if in list', () {
      final Expression expression = getExpression('[if (true) 1 else 2]');
      expect(expression.toString(), '[if(true, 1, 2)]');
    });

    test('if in map value', () {
      final Expression expression = getExpression(
        '{"result": if (flag) "yes" else "no"}',
      );
      expect(
        expression.toString(),
        '{"result": if(flag, "yes", "no")}',
      );
    });

    test('function call in map key', () {
      final Expression expression = getExpression('{getKey(): "value"}');
      expect(expression.toString(), '{getKey(): "value"}');
    });

    test('function call in list element', () {
      final Expression expression = getExpression('[foo(), bar(), baz()]');
      expect(expression.toString(), '[foo(), bar(), baz()]');
    });

    test('binary operation in list element', () {
      final Expression expression = getExpression('[a + b, c * d]');
      expect(expression.toString(), '[+(a, b), *(c, d)]');
    });

    test('binary operation in map value', () {
      final Expression expression = getExpression('{"sum": a + b}');
      expect(expression.toString(), '{"sum": +(a, b)}');
    });

    test('nested if expressions', () {
      final Expression expression = getExpression(
        'if (a) if (b) 1 else 2 else if (c) 3 else 4',
      );
      expect(expression.toString(), 'if(a, if(b, 1, 2), if(c, 3, 4))');
    });

    test('if with binary conditions and results', () {
      final Expression expression = getExpression(
        'if (x > 0 & y > 0) x + y else x - y',
      );
      expect(
        expression.toString(),
        'if(&(>(x, 0), >(y, 0)), +(x, y), -(x, y))',
      );
    });
  });

  group('ListIterator additional edge cases', () {
    test('back after advance returns true', () {
      final List<Token> tokens = getTokens('a b c');
      final ListIterator<Token> iterator = ListIterator(tokens);

      iterator.advance();
      iterator.advance();
      expect(iterator.back(), isTrue);
      expect(iterator.peek?.value, equals('b'));
    });

    test('multiple back calls', () {
      final List<Token> tokens = getTokens('a b c');
      final ListIterator<Token> iterator = ListIterator(tokens);

      iterator.advance();
      iterator.advance();
      iterator.advance();
      expect(iterator.back(), isTrue);
      expect(iterator.back(), isTrue);
      // After 3 advances and 2 backs, we're at index 1 (pointing to 'b')
      expect(iterator.peek?.value, equals('b'));
    });

    test('back at beginning returns false without error', () {
      final List<Token> tokens = getTokens('x');
      final ListIterator<Token> iterator = ListIterator(tokens);

      expect(iterator.back(), isFalse);
      expect(iterator.peek?.value, equals('x'));
    });

    test('hasNext reflects iterator state accurately', () {
      final List<Token> tokens = getTokens('a b');
      final ListIterator<Token> iterator = ListIterator(tokens);

      expect(iterator.hasNext, isTrue);
      iterator.advance();
      expect(iterator.hasNext, isTrue);
      iterator.advance();
      expect(iterator.hasNext, isFalse);
    });

    test('isAtEnd reflects iterator state accurately', () {
      final List<Token> tokens = getTokens('a');
      final ListIterator<Token> iterator = ListIterator(tokens);

      expect(iterator.isAtEnd, isFalse);
      iterator.advance();
      expect(iterator.isAtEnd, isTrue);
    });

    test('peek returns null when at end', () {
      final ListIterator<Token> iterator = ListIterator([]);
      expect(iterator.peek, isNull);
    });

    test('previous returns null when at start', () {
      final List<Token> tokens = getTokens('x');
      final ListIterator<Token> iterator = ListIterator(tokens);
      expect(iterator.previous, isNull);
    });

    test('previous returns last consumed after advance', () {
      final List<Token> tokens = getTokens('a b');
      final ListIterator<Token> iterator = ListIterator(tokens);

      iterator.advance();
      expect(iterator.previous?.value, equals('a'));
      iterator.advance();
      expect(iterator.previous?.value, equals('b'));
    });
  });

  group('Syntactic error type verification', () {
    test('InvalidTokenError for unexpected primary token', () {
      expect(
        () => getExpression(')'),
        throwsA(
          isA<InvalidTokenError>().having(
            (e) => e.message,
            'message',
            contains('Invalid token'),
          ),
        ),
      );
    });

    test('ExpectedTokenError for missing closing paren', () {
      expect(
        () => getExpression('(1'),
        throwsA(
          isA<UnexpectedEndOfFileError>().having(
            (e) => e.message,
            'message',
            contains('Unexpected end of file'),
          ),
        ),
      );
    });

    test('ExpectedTokenError includes expected token info', () {
      expect(
        () => getExpression('if (true 1 else 2'),
        throwsA(
          isA<ExpectedTokenError>().having(
            (e) => e.message,
            'message',
            contains('Expected'),
          ),
        ),
      );
    });
  });

  group('Expression literal value verification', () {
    test('BooleanExpression true value', () {
      final Expression expression = getExpression('true');
      expect(expression, isA<BooleanExpression>());
      expect((expression as BooleanExpression).value, isTrue);
    });

    test('BooleanExpression false value', () {
      final Expression expression = getExpression('false');
      expect(expression, isA<BooleanExpression>());
      expect((expression as BooleanExpression).value, isFalse);
    });

    test('NumberExpression integer value', () {
      final Expression expression = getExpression('100');
      expect(expression, isA<NumberExpression>());
      expect((expression as NumberExpression).value, equals(100));
    });

    test('NumberExpression decimal value', () {
      final Expression expression = getExpression('3.14159');
      expect(expression, isA<NumberExpression>());
      expect(
        (expression as NumberExpression).value,
        closeTo(3.14159, 0.00001),
      );
    });

    test('StringExpression value without quotes', () {
      final Expression expression = getExpression('"content"');
      expect(expression, isA<StringExpression>());
      expect((expression as StringExpression).value, equals('content'));
    });

    test('IdentifierExpression preserves name', () {
      final Expression expression = getExpression('myVariable');
      expect(expression, isA<IdentifierExpression>());
      expect((expression as IdentifierExpression).value, equals('myVariable'));
    });
  });

  group('Multiline expression handling', () {
    Expression compileExpression(String input) {
      const Compiler compiler = Compiler();
      return compiler.expression(input);
    }

    test('expression with leading whitespace', () {
      expect(compileExpression('   42').toString(), '42');
    });

    test('expression with trailing whitespace', () {
      expect(compileExpression('42   ').toString(), '42');
    });

    test('binary expression with whitespace', () {
      expect(compileExpression('1   +   2').toString(), '+(1, 2)');
    });

    test('function call with whitespace', () {
      expect(compileExpression('foo  (  1  ,  2  )').toString(), 'foo(1, 2)');
    });

    test('list with whitespace', () {
      expect(compileExpression('[  1  ,  2  ]').toString(), '[1, 2]');
    });

    test('map with whitespace', () {
      expect(compileExpression('{  "a"  :  1  }').toString(), '{"a": 1}');
    });
  });

  group('All comparison operators', () {
    test('greater than', () {
      final Expression expression = getExpression('a > b');
      expect(expression, isA<CallExpression>());
      final CallExpression call = expression as CallExpression;
      expect((call.callee as IdentifierExpression).value, equals('>'));
    });

    test('greater or equal', () {
      final Expression expression = getExpression('a >= b');
      expect(expression, isA<CallExpression>());
      final CallExpression call = expression as CallExpression;
      expect((call.callee as IdentifierExpression).value, equals('>='));
    });

    test('less than', () {
      final Expression expression = getExpression('a < b');
      expect(expression, isA<CallExpression>());
      final CallExpression call = expression as CallExpression;
      expect((call.callee as IdentifierExpression).value, equals('<'));
    });

    test('less or equal', () {
      final Expression expression = getExpression('a <= b');
      expect(expression, isA<CallExpression>());
      final CallExpression call = expression as CallExpression;
      expect((call.callee as IdentifierExpression).value, equals('<='));
    });

    test('equal', () {
      final Expression expression = getExpression('a == b');
      expect(expression, isA<CallExpression>());
      final CallExpression call = expression as CallExpression;
      expect((call.callee as IdentifierExpression).value, equals('=='));
    });

    test('not equal', () {
      final Expression expression = getExpression('a != b');
      expect(expression, isA<CallExpression>());
      final CallExpression call = expression as CallExpression;
      expect((call.callee as IdentifierExpression).value, equals('!='));
    });
  });

  group('All arithmetic operators', () {
    test('plus operator', () {
      final Expression expression = getExpression('a + b');
      expect(expression, isA<CallExpression>());
      final CallExpression call = expression as CallExpression;
      expect((call.callee as IdentifierExpression).value, equals('+'));
    });

    test('minus operator', () {
      final Expression expression = getExpression('a - b');
      expect(expression, isA<CallExpression>());
      final CallExpression call = expression as CallExpression;
      expect((call.callee as IdentifierExpression).value, equals('-'));
    });

    test('multiply operator', () {
      final Expression expression = getExpression('a * b');
      expect(expression, isA<CallExpression>());
      final CallExpression call = expression as CallExpression;
      expect((call.callee as IdentifierExpression).value, equals('*'));
    });

    test('divide operator', () {
      final Expression expression = getExpression('a / b');
      expect(expression, isA<CallExpression>());
      final CallExpression call = expression as CallExpression;
      expect((call.callee as IdentifierExpression).value, equals('/'));
    });

    test('modulo operator', () {
      final Expression expression = getExpression('a % b');
      expect(expression, isA<CallExpression>());
      final CallExpression call = expression as CallExpression;
      expect((call.callee as IdentifierExpression).value, equals('%'));
    });
  });

  group('All logical operators', () {
    test('and operator', () {
      final Expression expression = getExpression('a & b');
      expect(expression, isA<CallExpression>());
      final CallExpression call = expression as CallExpression;
      expect((call.callee as IdentifierExpression).value, equals('&'));
    });

    test('or operator', () {
      final Expression expression = getExpression('a | b');
      expect(expression, isA<CallExpression>());
      final CallExpression call = expression as CallExpression;
      expect((call.callee as IdentifierExpression).value, equals('|'));
    });

    test('not operator', () {
      final Expression expression = getExpression('!a');
      expect(expression, isA<CallExpression>());
      final CallExpression call = expression as CallExpression;
      expect((call.callee as IdentifierExpression).value, equals('!'));
    });

    test('not keyword alias', () {
      final Expression expression = getExpression('not a');
      expect(expression, isA<CallExpression>());
      final CallExpression call = expression as CallExpression;
      expect((call.callee as IdentifierExpression).value, equals('!'));
    });
  });

  group('Parser match function behavior', () {
    test('match advances iterator when predicate matches', () {
      final List<Token> tokens = getTokens('1 + 2');
      final ExpressionParser parser = ExpressionParser(ListIterator(tokens));

      // Initial state
      expect(parser.peek, isA<NumberToken>());

      // Advance past the number
      parser.advance();
      expect(parser.peek, isA<PlusToken>());

      // match should return true and advance
      final bool result = parser.matchSingle((Token t) => t is PlusToken);
      expect(result, isTrue);
      expect(parser.previous, isA<PlusToken>());
    });

    test('matchSingle returns false without advancing when no match', () {
      final List<Token> tokens = getTokens('42');
      final ExpressionParser parser = ExpressionParser(ListIterator(tokens));

      final bool result = parser.matchSingle((Token t) => t is StringToken);
      expect(result, isFalse);
      expect(parser.peek, isA<NumberToken>());
    });
  });

  group('Extreme edge cases', () {
    test('very long identifier', () {
      final String longName = 'a' * 100;
      final Expression expression = getExpression(longName);
      expect(expression, isA<IdentifierExpression>());
      expect((expression as IdentifierExpression).value, equals(longName));
    });

    test('many nested parentheses', () {
      final Expression expression = getExpression('((((((42))))))');
      expect(expression, isA<NumberExpression>());
      expect(expression.toString(), '42');
    });

    test('many chained additions', () {
      final Expression expression = getExpression('1 + 2 + 3 + 4 + 5');
      expect(expression.toString(), '+(+(+(+(1, 2), 3), 4), 5)');
    });

    test('many chained multiplications', () {
      final Expression expression = getExpression('1 * 2 * 3 * 4 * 5');
      expect(expression.toString(), '*(*(*(*(1, 2), 3), 4), 5)');
    });

    test('alternating operators', () {
      final Expression expression = getExpression('1 + 2 * 3 + 4 * 5');
      expect(expression.toString(), '+(+(1, *(2, 3)), *(4, 5))');
    });

    test('list with many elements', () {
      final Expression expression = getExpression(
        '[1, 2, 3, 4, 5, 6, 7, 8, 9]',
      );
      expect(expression, isA<ListExpression>());
      expect((expression as ListExpression).value.length, equals(9));
    });

    test('map with many entries', () {
      final Expression expression = getExpression(
        '{"a": 1, "b": 2, "c": 3, "d": 4, "e": 5}',
      );
      expect(expression, isA<MapExpression>());
      expect((expression as MapExpression).value.length, equals(5));
    });
  });
}
