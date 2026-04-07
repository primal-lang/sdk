@Tags(['compiler'])
library;

import 'package:primal/compiler/compiler.dart';
import 'package:primal/compiler/errors/lexical_error.dart';
import 'package:primal/compiler/errors/semantic_error.dart';
import 'package:primal/compiler/errors/syntactic_error.dart';
import 'package:primal/compiler/semantic/intermediate_representation.dart';
import 'package:primal/compiler/syntactic/expression.dart';
import 'package:primal/compiler/syntactic/function_definition.dart';
import 'package:primal/compiler/warnings/semantic_warning.dart';
import 'package:test/test.dart';

void main() {
  const Compiler compiler = Compiler();

  group('Compiler.compile()', () {
    test('Simple program returns IntermediateRepresentation with main', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('main = 42');
      expect(intermediateRepresentation.containsFunction('main'), isTrue);
    });

    test('Function definitions create correct functions', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile(
            'double(x) = x * 2\nmain = double(5)',
          );
      expect(intermediateRepresentation.containsFunction('double'), isTrue);
      expect(intermediateRepresentation.containsFunction('main'), isTrue);
    });

    test('Invalid syntax throws a compilation error', () {
      expect(
        () => compiler.compile('main = = ='),
        throwsA(isA<SyntacticError>()),
      );
    });

    test('Semantic error throws appropriate error', () {
      expect(
        () => compiler.compile('main = undefined_function(1)'),
        throwsA(isA<UndefinedFunctionError>()),
      );
    });

    test('Warnings are populated for unused parameters', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile(
            'f(x, y) = x\nmain = f(1, 2)',
          );
      expect(intermediateRepresentation.warnings.length, equals(1));
    });

    test('Program without main compiles successfully', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('f(x) = x * 2');
      expect(intermediateRepresentation.containsFunction('f'), isTrue);
    });

    test(
      'Empty input compiles to representation with only standard library',
      () {
        final IntermediateRepresentation intermediateRepresentation = compiler
            .compile('');
        expect(intermediateRepresentation.customFunctions, isEmpty);
        expect(
          intermediateRepresentation.standardLibrarySignatures,
          isNotEmpty,
        );
      },
    );

    test('Multiple function definitions are all accessible', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile(
            'add(x, y) = x + y\nmul(x, y) = x * y\nmain = add(1, mul(2, 3))',
          );
      expect(intermediateRepresentation.containsFunction('add'), isTrue);
      expect(intermediateRepresentation.containsFunction('mul'), isTrue);
      expect(intermediateRepresentation.containsFunction('main'), isTrue);
    });

    test('Nested function calls compile successfully', () {
      final IntermediateRepresentation
      intermediateRepresentation = compiler.compile(
        'double(x) = x * 2\nquadruple(x) = double(double(x))\nmain = quadruple(3)',
      );
      expect(intermediateRepresentation.containsFunction('double'), isTrue);
      expect(intermediateRepresentation.containsFunction('quadruple'), isTrue);
    });

    test('Recursive function definition compiles successfully', () {
      final IntermediateRepresentation
      intermediateRepresentation = compiler.compile(
        'countdown(n) = if (n <= 0) 0 else countdown(n - 1)\nmain = countdown(10)',
      );
      expect(intermediateRepresentation.containsFunction('countdown'), isTrue);
      expect(intermediateRepresentation.warnings, isEmpty);
    });

    test('Function with if/else expression compiles successfully', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('abs(x) = if (x < 0) -x else x\nmain = abs(-5)');
      expect(intermediateRepresentation.containsFunction('abs'), isTrue);
    });

    test('Function with list literal compiles successfully', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('main = [1, 2, 3]');
      expect(intermediateRepresentation.containsFunction('main'), isTrue);
    });

    test('Function with map literal compiles successfully', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('main = {"a": 1, "b": 2}');
      expect(intermediateRepresentation.containsFunction('main'), isTrue);
    });

    test('Duplicated function throws DuplicatedFunctionError', () {
      expect(
        () => compiler.compile('f(x) = x\nf(y) = y'),
        throwsA(isA<DuplicatedFunctionError>()),
      );
    });

    test('Duplicated parameter throws DuplicatedParameterError', () {
      expect(
        () => compiler.compile('f(x, x) = x'),
        throwsA(isA<DuplicatedParameterError>()),
      );
    });

    test('Invalid argument count throws InvalidNumberOfArgumentsError', () {
      expect(
        () => compiler.compile('f(x) = x\nmain = f(1, 2)'),
        throwsA(isA<InvalidNumberOfArgumentsError>()),
      );
    });

    test('Too few arguments throws InvalidNumberOfArgumentsError', () {
      expect(
        () => compiler.compile('f(x, y) = x + y\nmain = f(1)'),
        throwsA(isA<InvalidNumberOfArgumentsError>()),
      );
    });

    test('Calling non-callable literal throws NotCallableError', () {
      expect(
        () => compiler.compile('main = 5(1)'),
        throwsA(isA<NotCallableError>()),
      );
    });

    test('Indexing non-indexable literal throws NotIndexableError', () {
      expect(
        () => compiler.compile('main = 5[0]'),
        throwsA(isA<NotIndexableError>()),
      );
    });

    test('Undefined identifier throws UndefinedIdentifierError', () {
      expect(
        () => compiler.compile('main = x'),
        throwsA(isA<UndefinedIdentifierError>()),
      );
    });

    test('Multiple unused parameters generate multiple warnings', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('f(x, y, z) = 42\nmain = f(1, 2, 3)');
      expect(intermediateRepresentation.warnings.length, equals(3));
      expect(
        intermediateRepresentation.warnings.every(
          (warning) => warning is UnusedParameterWarning,
        ),
        isTrue,
      );
    });

    test('No warnings when all parameters are used', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('add(x, y) = x + y\nmain = add(1, 2)');
      expect(intermediateRepresentation.warnings, isEmpty);
    });

    test('Parameterless constant has empty parameter list', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('pi = 3.14');
      expect(
        intermediateRepresentation.customFunctions['pi']!.parameters,
        isEmpty,
      );
    });

    test('Standard library functions are accessible', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('main = num.add(1, 2)');
      expect(
        intermediateRepresentation.standardLibrarySignatures.containsKey(
          'num.add',
        ),
        isTrue,
      );
    });

    test('Mutual recursion compiles successfully', () {
      final IntermediateRepresentation
      intermediateRepresentation = compiler.compile(
        'isEven(n) = if (n == 0) true else isOdd(n - 1)\nisOdd(n) = if (n == 0) false else isEven(n - 1)\nmain = isEven(4)',
      );
      expect(intermediateRepresentation.containsFunction('isEven'), isTrue);
      expect(intermediateRepresentation.containsFunction('isOdd'), isTrue);
    });

    test('Function with nested list expressions compiles successfully', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('main = [[1, 2], [3, 4]]');
      expect(intermediateRepresentation.containsFunction('main'), isTrue);
    });

    test('Function with nested map expressions compiles successfully', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('main = {"outer": {"inner": 1}}');
      expect(intermediateRepresentation.containsFunction('main'), isTrue);
    });

    test('Function body has correct location information', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('main = 42');
      expect(
        intermediateRepresentation.customFunctions['main']!.location.row,
        equals(1),
      );
    });
  });

  group('Compiler.expression()', () {
    test('Number literal returns NumberExpression', () {
      final Expression expression = compiler.expression('42');
      expect(expression, isA<NumberExpression>());
      expect((expression as NumberExpression).value, equals(42));
    });

    test('String literal returns StringExpression', () {
      final Expression expression = compiler.expression('"hello"');
      expect(expression, isA<StringExpression>());
      expect((expression as StringExpression).value, equals('hello'));
    });

    test('Boolean literal returns BooleanExpression', () {
      final Expression expressionTrue = compiler.expression('true');
      expect(expressionTrue, isA<BooleanExpression>());
      expect((expressionTrue as BooleanExpression).value, isTrue);

      final Expression expressionFalse = compiler.expression('false');
      expect(expressionFalse, isA<BooleanExpression>());
      expect((expressionFalse as BooleanExpression).value, isFalse);
    });

    test('Binary operation returns CallExpression', () {
      final Expression expression = compiler.expression('1 + 2');
      expect(expression, isA<CallExpression>());
      expect(expression.toString(), equals('+(1, 2)'));
    });

    test('Function call returns CallExpression', () {
      final Expression expression = compiler.expression('foo(1, 2)');
      expect(expression, isA<CallExpression>());
      expect(expression.toString(), equals('foo(1, 2)'));
    });

    test('List literal returns ListExpression', () {
      final Expression expression = compiler.expression('[1, 2, 3]');
      expect(expression, isA<ListExpression>());
      expect((expression as ListExpression).value.length, equals(3));
    });

    test('Map literal returns MapExpression', () {
      final Expression expression = compiler.expression('{"a": 1, "b": 2}');
      expect(expression, isA<MapExpression>());
      expect((expression as MapExpression).value.length, equals(2));
    });

    test('If/else returns CallExpression', () {
      final Expression expression = compiler.expression('if (true) 1 else 2');
      expect(expression, isA<CallExpression>());
      expect(expression.toString(), equals('if(true, 1, 2)'));
    });

    test('Invalid input throws error', () {
      expect(
        () => compiler.expression('= = ='),
        throwsA(isA<SyntacticError>()),
      );
    });

    test('Empty list returns ListExpression with no elements', () {
      final Expression expression = compiler.expression('[]');
      expect(expression, isA<ListExpression>());
      expect((expression as ListExpression).value, isEmpty);
    });

    test('Empty map returns MapExpression with no entries', () {
      final Expression expression = compiler.expression('{}');
      expect(expression, isA<MapExpression>());
      expect((expression as MapExpression).value, isEmpty);
    });

    test('Nested list returns ListExpression with nested elements', () {
      final Expression expression = compiler.expression('[[1, 2], [3, 4]]');
      expect(expression, isA<ListExpression>());
      final ListExpression listExpression = expression as ListExpression;
      expect(listExpression.value.length, equals(2));
      expect(listExpression.value[0], isA<ListExpression>());
      expect(listExpression.value[1], isA<ListExpression>());
    });

    test('Nested map returns MapExpression with nested entries', () {
      final Expression expression = compiler.expression(
        '{"outer": {"inner": 1}}',
      );
      expect(expression, isA<MapExpression>());
      final MapExpression mapExpression = expression as MapExpression;
      expect(mapExpression.value.length, equals(1));
      expect(mapExpression.value[0].value, isA<MapExpression>());
    });

    test('Identifier returns IdentifierExpression', () {
      final Expression expression = compiler.expression('foo');
      expect(expression, isA<IdentifierExpression>());
      expect((expression as IdentifierExpression).value, equals('foo'));
    });

    test('Unary negation returns CallExpression', () {
      final Expression expression = compiler.expression('-5');
      expect(expression, isA<CallExpression>());
      expect(expression.toString(), equals('-(0, 5)'));
    });

    test('Logical not returns CallExpression', () {
      final Expression expression = compiler.expression('!true');
      expect(expression, isA<CallExpression>());
      expect(expression.toString(), equals('!(true)'));
    });

    test('Complex nested binary operations', () {
      final Expression expression = compiler.expression('1 + 2 * 3 - 4');
      expect(expression, isA<CallExpression>());
    });

    test('Comparison operations return CallExpression', () {
      final Expression expression = compiler.expression('1 < 2');
      expect(expression, isA<CallExpression>());
      expect(expression.toString(), equals('<(1, 2)'));
    });

    test('Equality operations return CallExpression', () {
      final Expression expression = compiler.expression('1 == 2');
      expect(expression, isA<CallExpression>());
      expect(expression.toString(), equals('==(1, 2)'));
    });

    test('Logical and returns CallExpression', () {
      final Expression expression = compiler.expression('true && false');
      expect(expression, isA<CallExpression>());
      expect(expression.toString(), equals('&(true, false)'));
    });

    test('Logical or returns CallExpression', () {
      final Expression expression = compiler.expression('true || false');
      expect(expression, isA<CallExpression>());
      expect(expression.toString(), equals('|(true, false)'));
    });

    test('Parenthesized expression parses correctly', () {
      final Expression expression = compiler.expression('(1 + 2) * 3');
      expect(expression, isA<CallExpression>());
    });

    test('Function call with no arguments', () {
      final Expression expression = compiler.expression('foo()');
      expect(expression, isA<CallExpression>());
      final CallExpression callExpression = expression as CallExpression;
      expect(callExpression.arguments, isEmpty);
    });

    test('Decimal number literal returns NumberExpression', () {
      final Expression expression = compiler.expression('3.14');
      expect(expression, isA<NumberExpression>());
      expect((expression as NumberExpression).value, equals(3.14));
    });

    test('Negative decimal number literal', () {
      final Expression expression = compiler.expression('-3.14');
      expect(expression, isA<CallExpression>());
    });

    test('String with escape sequences', () {
      final Expression expression = compiler.expression('"hello\\nworld"');
      expect(expression, isA<StringExpression>());
    });

    test('Empty string literal', () {
      final Expression expression = compiler.expression('""');
      expect(expression, isA<StringExpression>());
      expect((expression as StringExpression).value, equals(''));
    });

    test('List with mixed types', () {
      final Expression expression = compiler.expression('[1, "two", true]');
      expect(expression, isA<ListExpression>());
      final ListExpression listExpression = expression as ListExpression;
      expect(listExpression.value.length, equals(3));
      expect(listExpression.value[0], isA<NumberExpression>());
      expect(listExpression.value[1], isA<StringExpression>());
      expect(listExpression.value[2], isA<BooleanExpression>());
    });

    test('Map with number keys', () {
      final Expression expression = compiler.expression('{1: "one", 2: "two"}');
      expect(expression, isA<MapExpression>());
      final MapExpression mapExpression = expression as MapExpression;
      expect(mapExpression.value.length, equals(2));
    });

    test('Index expression returns CallExpression', () {
      final Expression expression = compiler.expression('[1, 2, 3][0]');
      expect(expression, isA<CallExpression>());
    });

    test('Chained index expressions', () {
      final Expression expression = compiler.expression(
        '[[1, 2], [3, 4]][0][1]',
      );
      expect(expression, isA<CallExpression>());
    });

    test('Unexpected token after expression throws UnexpectedTokenError', () {
      expect(
        () => compiler.expression('1 2'),
        throwsA(isA<UnexpectedTokenError>()),
      );
    });

    test('Unclosed parenthesis throws SyntacticError', () {
      expect(
        () => compiler.expression('(1 + 2'),
        throwsA(isA<SyntacticError>()),
      );
    });

    test('Unclosed list throws SyntacticError', () {
      expect(
        () => compiler.expression('[1, 2, 3'),
        throwsA(isA<SyntacticError>()),
      );
    });

    test('Unclosed map throws SyntacticError', () {
      expect(
        () => compiler.expression('{"a": 1'),
        throwsA(isA<SyntacticError>()),
      );
    });

    test('Unclosed string throws LexicalError', () {
      expect(
        () => compiler.expression('"hello'),
        throwsA(isA<LexicalError>()),
      );
    });

    test('Single element list', () {
      final Expression expression = compiler.expression('[42]');
      expect(expression, isA<ListExpression>());
      expect((expression as ListExpression).value.length, equals(1));
    });

    test('Single entry map', () {
      final Expression expression = compiler.expression('{"key": 42}');
      expect(expression, isA<MapExpression>());
      expect((expression as MapExpression).value.length, equals(1));
    });

    test('Nested function calls', () {
      final Expression expression = compiler.expression('foo(bar(baz(1)))');
      expect(expression, isA<CallExpression>());
    });

    test('Function call with multiple arguments', () {
      final Expression expression = compiler.expression('foo(1, 2, 3, 4, 5)');
      expect(expression, isA<CallExpression>());
      final CallExpression callExpression = expression as CallExpression;
      expect(callExpression.arguments.length, equals(5));
    });

    test('If/else with complex condition', () {
      final Expression expression = compiler.expression(
        'if (x > 0 && x < 10) 1 else 0',
      );
      expect(expression, isA<CallExpression>());
    });

    test('Zero literal', () {
      final Expression expression = compiler.expression('0');
      expect(expression, isA<NumberExpression>());
      expect((expression as NumberExpression).value, equals(0));
    });

    test('Large number literal', () {
      final Expression expression = compiler.expression('999999999999');
      expect(expression, isA<NumberExpression>());
    });
  });

  group('Compiler.functionDefinition()', () {
    test('returns FunctionDefinition for constant definition', () {
      final FunctionDefinition? definition = compiler.functionDefinition(
        'pi = 3.14',
      );

      expect(definition, isNotNull);
      expect(definition!.name, equals('pi'));
      expect(definition.parameters, isEmpty);
    });

    test('returns FunctionDefinition for function with parameters', () {
      final FunctionDefinition? definition = compiler.functionDefinition(
        'double(x) = x * 2',
      );

      expect(definition, isNotNull);
      expect(definition!.name, equals('double'));
      expect(definition.parameters, equals(['x']));
    });

    test(
      'returns FunctionDefinition for function with multiple parameters',
      () {
        final FunctionDefinition? definition = compiler.functionDefinition(
          'add(a, b, c) = a + b + c',
        );

        expect(definition, isNotNull);
        expect(definition!.name, equals('add'));
        expect(definition.parameters, equals(['a', 'b', 'c']));
      },
    );

    test('returns null for simple expression', () {
      final FunctionDefinition? definition = compiler.functionDefinition('42');

      expect(definition, isNull);
    });

    test('returns null for function call expression', () {
      final FunctionDefinition? definition = compiler.functionDefinition(
        'add(1, 2)',
      );

      expect(definition, isNull);
    });

    test('returns null for binary operation', () {
      final FunctionDefinition? definition = compiler.functionDefinition(
        '1 + 2',
      );

      expect(definition, isNull);
    });

    test('returns null for identifier expression', () {
      final FunctionDefinition? definition = compiler.functionDefinition('foo');

      expect(definition, isNull);
    });

    test('returns null for invalid syntax', () {
      final FunctionDefinition? definition = compiler.functionDefinition(
        '= = =',
      );

      expect(definition, isNull);
    });

    test('returns null for multiple function definitions', () {
      final FunctionDefinition? definition = compiler.functionDefinition(
        'a = 1\nb = 2',
      );

      expect(definition, isNull);
    });

    test('returns null for empty input', () {
      final FunctionDefinition? definition = compiler.functionDefinition('');

      expect(definition, isNull);
    });

    test('returns FunctionDefinition for function with if/else body', () {
      final FunctionDefinition? definition = compiler.functionDefinition(
        'abs(x) = if (x < 0) -x else x',
      );

      expect(definition, isNotNull);
      expect(definition!.name, equals('abs'));
      expect(definition.parameters, equals(['x']));
    });

    test('returns FunctionDefinition for function with list body', () {
      final FunctionDefinition? definition = compiler.functionDefinition(
        'items = [1, 2, 3]',
      );

      expect(definition, isNotNull);
      expect(definition!.name, equals('items'));
      expect(definition.parameters, isEmpty);
    });

    test('returns FunctionDefinition for function with map body', () {
      final FunctionDefinition? definition = compiler.functionDefinition(
        'config = {"key": "value"}',
      );

      expect(definition, isNotNull);
      expect(definition!.name, equals('config'));
      expect(definition.parameters, isEmpty);
    });

    test('returns FunctionDefinition for function with nested call body', () {
      final FunctionDefinition? definition = compiler.functionDefinition(
        'composed(x) = foo(bar(x))',
      );

      expect(definition, isNotNull);
      expect(definition!.name, equals('composed'));
      expect(definition.parameters, equals(['x']));
    });

    test(
      'returns FunctionDefinition for function with binary operation body',
      () {
        final FunctionDefinition? definition = compiler.functionDefinition(
          'sum(a, b, c) = a + b + c',
        );

        expect(definition, isNotNull);
        expect(definition!.name, equals('sum'));
        expect(definition.parameters, equals(['a', 'b', 'c']));
      },
    );

    test('returns FunctionDefinition for function with string body', () {
      final FunctionDefinition? definition = compiler.functionDefinition(
        'greeting = "hello"',
      );

      expect(definition, isNotNull);
      expect(definition!.name, equals('greeting'));
      expect(definition.expression, isA<StringExpression>());
    });

    test('returns FunctionDefinition for function with boolean body', () {
      final FunctionDefinition? definition = compiler.functionDefinition(
        'flag = true',
      );

      expect(definition, isNotNull);
      expect(definition!.name, equals('flag'));
      expect(definition.expression, isA<BooleanExpression>());
    });

    test('returns null for list literal expression', () {
      final FunctionDefinition? definition = compiler.functionDefinition(
        '[1, 2, 3]',
      );

      expect(definition, isNull);
    });

    test('returns null for map literal expression', () {
      final FunctionDefinition? definition = compiler.functionDefinition(
        '{"a": 1}',
      );

      expect(definition, isNull);
    });

    test('returns null for if/else expression without assignment', () {
      final FunctionDefinition? definition = compiler.functionDefinition(
        'if (true) 1 else 2',
      );

      expect(definition, isNull);
    });

    test('returns null for whitespace only input', () {
      final FunctionDefinition? definition = compiler.functionDefinition(
        '   ',
      );

      expect(definition, isNull);
    });

    test('returns FunctionDefinition with expression location', () {
      final FunctionDefinition? definition = compiler.functionDefinition(
        'main = 42',
      );

      expect(definition, isNotNull);
      expect(definition!.expression, isA<NumberExpression>());
    });
  });
}
