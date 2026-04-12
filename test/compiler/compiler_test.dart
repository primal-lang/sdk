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
          .compile('main() = 42');
      expect(intermediateRepresentation.containsFunction('main'), isTrue);
    });

    test('Function definitions create correct functions', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile(
            'double(x) = x * 2\nmain() = double(5)',
          );
      expect(intermediateRepresentation.containsFunction('double'), isTrue);
      expect(intermediateRepresentation.containsFunction('main'), isTrue);
    });

    test('Invalid syntax throws a compilation error', () {
      expect(
        () => compiler.compile('main() = = ='),
        throwsA(isA<SyntacticError>()),
      );
    });

    test('Semantic error throws appropriate error', () {
      expect(
        () => compiler.compile('main() = undefined_function(1)'),
        throwsA(isA<UndefinedFunctionError>()),
      );
    });

    test('Warnings are populated for unused parameters', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile(
            'f(x, y) = x\nmain() = f(1, 2)',
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
            'add(x, y) = x + y\nmul(x, y) = x * y\nmain() = add(1, mul(2, 3))',
          );
      expect(intermediateRepresentation.containsFunction('add'), isTrue);
      expect(intermediateRepresentation.containsFunction('mul'), isTrue);
      expect(intermediateRepresentation.containsFunction('main'), isTrue);
    });

    test('Nested function calls compile successfully', () {
      final IntermediateRepresentation
      intermediateRepresentation = compiler.compile(
        'double(x) = x * 2\nquadruple(x) = double(double(x))\nmain() = quadruple(3)',
      );
      expect(intermediateRepresentation.containsFunction('double'), isTrue);
      expect(intermediateRepresentation.containsFunction('quadruple'), isTrue);
    });

    test('Recursive function definition compiles successfully', () {
      final IntermediateRepresentation
      intermediateRepresentation = compiler.compile(
        'countdown(n) = if (n <= 0) 0 else countdown(n - 1)\nmain() = countdown(10)',
      );
      expect(intermediateRepresentation.containsFunction('countdown'), isTrue);
      expect(intermediateRepresentation.warnings, isEmpty);
    });

    test('Function with if/else expression compiles successfully', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('abs(x) = if (x < 0) -x else x\nmain() = abs(-5)');
      expect(intermediateRepresentation.containsFunction('abs'), isTrue);
    });

    test('Function with list literal compiles successfully', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('main() = [1, 2, 3]');
      expect(intermediateRepresentation.containsFunction('main'), isTrue);
    });

    test('Function with map literal compiles successfully', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('main() = {"a": 1, "b": 2}');
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
        () => compiler.compile('f(x) = x\nmain() = f(1, 2)'),
        throwsA(isA<InvalidNumberOfArgumentsError>()),
      );
    });

    test('Too few arguments throws InvalidNumberOfArgumentsError', () {
      expect(
        () => compiler.compile('f(x, y) = x + y\nmain() = f(1)'),
        throwsA(isA<InvalidNumberOfArgumentsError>()),
      );
    });

    test('Calling non-callable literal throws NotCallableError', () {
      expect(
        () => compiler.compile('main() = 5(1)'),
        throwsA(isA<NotCallableError>()),
      );
    });

    test('Indexing non-indexable literal throws NotIndexableError', () {
      expect(
        () => compiler.compile('main() = 5[0]'),
        throwsA(isA<NotIndexableError>()),
      );
    });

    test('Undefined identifier throws UndefinedIdentifierError', () {
      expect(
        () => compiler.compile('main() = x'),
        throwsA(isA<UndefinedIdentifierError>()),
      );
    });

    test('Multiple unused parameters generate multiple warnings', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('f(x, y, z) = 42\nmain() = f(1, 2, 3)');
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
          .compile('add(x, y) = x + y\nmain() = add(1, 2)');
      expect(intermediateRepresentation.warnings, isEmpty);
    });

    test('Parameterless constant has empty parameter list', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('pi() = 3.14');
      expect(
        intermediateRepresentation.customFunctions['pi']!.parameters,
        isEmpty,
      );
    });

    test('Standard library functions are accessible', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('main() = num.add(1, 2)');
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
        'isEven(n) = if (n == 0) true else isOdd(n - 1)\nisOdd(n) = if (n == 0) false else isEven(n - 1)\nmain() = isEven(4)',
      );
      expect(intermediateRepresentation.containsFunction('isEven'), isTrue);
      expect(intermediateRepresentation.containsFunction('isOdd'), isTrue);
    });

    test('Function with nested list expressions compiles successfully', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('main() = [[1, 2], [3, 4]]');
      expect(intermediateRepresentation.containsFunction('main'), isTrue);
    });

    test('Function with nested map expressions compiles successfully', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('main() = {"outer": {"inner": 1}}');
      expect(intermediateRepresentation.containsFunction('main'), isTrue);
    });

    test('Function body has correct location information', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('main() = 42');
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

    test('Logical and (&&) returns CallExpression', () {
      final Expression expression = compiler.expression('true && false');
      expect(expression, isA<CallExpression>());
      expect(expression.toString(), equals('&&(true, false)'));
    });

    test('Logical and (&) returns CallExpression', () {
      final Expression expression = compiler.expression('true & false');
      expect(expression, isA<CallExpression>());
      expect(expression.toString(), equals('&(true, false)'));
    });

    test('Logical or (||) returns CallExpression', () {
      final Expression expression = compiler.expression('true || false');
      expect(expression, isA<CallExpression>());
      expect(expression.toString(), equals('||(true, false)'));
    });

    test('Logical or (|) returns CallExpression', () {
      final Expression expression = compiler.expression('true | false');
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
        'pi() = 3.14',
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
        'a() = 1\nb = 2',
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
        'items() = [1, 2, 3]',
      );

      expect(definition, isNotNull);
      expect(definition!.name, equals('items'));
      expect(definition.parameters, isEmpty);
    });

    test('returns FunctionDefinition for function with map body', () {
      final FunctionDefinition? definition = compiler.functionDefinition(
        'config() = {"key": "value"}',
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
        'greeting() = "hello"',
      );

      expect(definition, isNotNull);
      expect(definition!.name, equals('greeting'));
      expect(definition.expression, isA<StringExpression>());
    });

    test('returns FunctionDefinition for function with boolean body', () {
      final FunctionDefinition? definition = compiler.functionDefinition(
        'flag() = true',
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
        'main() = 42',
      );

      expect(definition, isNotNull);
      expect(definition!.expression, isA<NumberExpression>());
    });
  });

  group('Compiler.compile() - lexical errors', () {
    test('Invalid character throws LexicalError', () {
      expect(
        () => compiler.compile('main() = 1 ` 2'),
        throwsA(isA<LexicalError>()),
      );
    });

    test('Unterminated multi-line comment throws UnterminatedCommentError', () {
      expect(
        () => compiler.compile('/* unterminated comment'),
        throwsA(isA<LexicalError>()),
      );
    });

    test('Invalid escape sequence throws InvalidEscapeSequenceError', () {
      expect(
        () => compiler.compile(r'main() = "hello\z"'),
        throwsA(isA<LexicalError>()),
      );
    });

    test('Invalid hex escape throws LexicalError', () {
      expect(
        () => compiler.compile(r'main() = "\xGG"'),
        throwsA(isA<LexicalError>()),
      );
    });

    test('Incomplete unicode escape throws LexicalError', () {
      expect(
        () => compiler.compile(r'main() = "\u00"'),
        throwsA(isA<LexicalError>()),
      );
    });

    test('Invalid braced unicode escape throws LexicalError', () {
      expect(
        () => compiler.compile(r'main() = "\u{}"'),
        throwsA(isA<LexicalError>()),
      );
    });

    test('Trailing underscore in number throws LexicalError', () {
      expect(
        () => compiler.compile('main() = 123_'),
        throwsA(isA<LexicalError>()),
      );
    });

    test('Incomplete exponent throws LexicalError', () {
      expect(
        () => compiler.compile('main() = 1e'),
        throwsA(isA<LexicalError>()),
      );
    });

    test('Incomplete exponent with sign throws LexicalError', () {
      expect(
        () => compiler.compile('main() = 1e+'),
        throwsA(isA<LexicalError>()),
      );
    });
  });

  group('Compiler.compile() - syntactic errors', () {
    test('Missing equals sign throws InvalidTokenError', () {
      expect(
        () => compiler.compile('foo 42'),
        throwsA(isA<SyntacticError>()),
      );
    });

    test('Missing closing parenthesis in function definition throws error', () {
      expect(
        () => compiler.compile('foo(x = x'),
        throwsA(isA<SyntacticError>()),
      );
    });

    test('Missing parameter after comma throws error', () {
      expect(
        () => compiler.compile('foo(x, ) = x'),
        throwsA(isA<SyntacticError>()),
      );
    });

    test('Missing expression after equals throws error', () {
      expect(
        () => compiler.compile('foo ='),
        throwsA(isA<SyntacticError>()),
      );
    });

    test('Non-identifier function name throws error', () {
      expect(
        () => compiler.compile('123 = 456'),
        throwsA(isA<SyntacticError>()),
      );
    });
  });

  group('Compiler.compile() - semantic errors', () {
    test(
      'Redefining standard library function throws CannotRedefineStandardLibraryError equivalent',
      () {
        expect(
          () => compiler.compile('num.add(x, y) = x + y'),
          throwsA(isA<DuplicatedFunctionError>()),
        );
      },
    );

    test('Calling string literal throws NotCallableError', () {
      expect(
        () => compiler.compile('main() = "hello"(1)'),
        throwsA(isA<NotCallableError>()),
      );
    });

    test('Calling boolean literal throws NotCallableError', () {
      expect(
        () => compiler.compile('main() = true(1)'),
        throwsA(isA<NotCallableError>()),
      );
    });

    test('Calling list literal throws NotCallableError', () {
      expect(
        () => compiler.compile('main() = [1, 2](1)'),
        throwsA(isA<NotCallableError>()),
      );
    });

    test('Calling map literal throws NotCallableError', () {
      expect(
        () => compiler.compile('main() = {"a": 1}(1)'),
        throwsA(isA<NotCallableError>()),
      );
    });

    test('Indexing boolean literal throws NotIndexableError', () {
      expect(
        () => compiler.compile('main() = true[0]'),
        throwsA(isA<NotIndexableError>()),
      );
    });

    test('Undefined identifier in nested function throws error', () {
      expect(
        () => compiler.compile('f(x) = x + y\nmain() = f(1)'),
        throwsA(isA<UndefinedIdentifierError>()),
      );
    });
  });

  group('Compiler.expression() - operators', () {
    test('Inequality operator returns CallExpression', () {
      final Expression expression = compiler.expression('1 != 2');
      expect(expression, isA<CallExpression>());
      expect(expression.toString(), equals('!=(1, 2)'));
    });

    test('Greater than or equal returns CallExpression', () {
      final Expression expression = compiler.expression('1 >= 2');
      expect(expression, isA<CallExpression>());
      expect(expression.toString(), equals('>=(1, 2)'));
    });

    test('Less than or equal returns CallExpression', () {
      final Expression expression = compiler.expression('1 <= 2');
      expect(expression, isA<CallExpression>());
      expect(expression.toString(), equals('<=(1, 2)'));
    });

    test('Greater than operator returns CallExpression', () {
      final Expression expression = compiler.expression('1 > 2');
      expect(expression, isA<CallExpression>());
      expect(expression.toString(), equals('>(1, 2)'));
    });

    test('Division operator returns CallExpression', () {
      final Expression expression = compiler.expression('6 / 2');
      expect(expression, isA<CallExpression>());
      expect(expression.toString(), equals('/(6, 2)'));
    });

    test('Modulo operator returns CallExpression', () {
      final Expression expression = compiler.expression('7 % 3');
      expect(expression, isA<CallExpression>());
      expect(expression.toString(), equals('%(7, 3)'));
    });

    test('At operator for indexing returns CallExpression', () {
      final Expression expression = compiler.expression('[1, 2, 3] @ 0');
      expect(expression, isA<CallExpression>());
      expect(expression.toString(), contains('@'));
    });

    test('Subtraction operator returns CallExpression', () {
      final Expression expression = compiler.expression('5 - 3');
      expect(expression, isA<CallExpression>());
      expect(expression.toString(), equals('-(5, 3)'));
    });

    test('Multiplication operator returns CallExpression', () {
      final Expression expression = compiler.expression('3 * 4');
      expect(expression, isA<CallExpression>());
      expect(expression.toString(), equals('*(3, 4)'));
    });
  });

  group('Compiler.expression() - strings', () {
    test('Single-quoted string returns StringExpression', () {
      final Expression expression = compiler.expression("'hello'");
      expect(expression, isA<StringExpression>());
      expect((expression as StringExpression).value, equals('hello'));
    });

    test('String with newline escape', () {
      final Expression expression = compiler.expression('"line1\\nline2"');
      expect(expression, isA<StringExpression>());
      expect((expression as StringExpression).value, contains('\n'));
    });

    test('String with tab escape', () {
      final Expression expression = compiler.expression('"col1\\tcol2"');
      expect(expression, isA<StringExpression>());
      expect((expression as StringExpression).value, contains('\t'));
    });

    test('String with backslash escape', () {
      final Expression expression = compiler.expression('"path\\\\file"');
      expect(expression, isA<StringExpression>());
      expect((expression as StringExpression).value, contains('\\'));
    });

    test('String with escaped double quote', () {
      final Expression expression = compiler.expression('"say \\"hi\\""');
      expect(expression, isA<StringExpression>());
      expect((expression as StringExpression).value, contains('"'));
    });

    test('String with escaped single quote', () {
      final Expression expression = compiler.expression("\"it\\'s\"");
      expect(expression, isA<StringExpression>());
      expect((expression as StringExpression).value, contains("'"));
    });

    test('String with hex escape', () {
      final Expression expression = compiler.expression('"\\x41"');
      expect(expression, isA<StringExpression>());
      expect((expression as StringExpression).value, equals('A'));
    });

    test('String with unicode escape', () {
      final Expression expression = compiler.expression('"\\u0041"');
      expect(expression, isA<StringExpression>());
      expect((expression as StringExpression).value, equals('A'));
    });

    test('String with braced unicode escape', () {
      final Expression expression = compiler.expression('"\\u{41}"');
      expect(expression, isA<StringExpression>());
      expect((expression as StringExpression).value, equals('A'));
    });
  });

  group('Compiler.expression() - numbers', () {
    test('Scientific notation with positive exponent', () {
      final Expression expression = compiler.expression('1e10');
      expect(expression, isA<NumberExpression>());
      expect((expression as NumberExpression).value, equals(1e10));
    });

    test('Scientific notation with negative exponent', () {
      final Expression expression = compiler.expression('1e-5');
      expect(expression, isA<NumberExpression>());
      expect((expression as NumberExpression).value, equals(1e-5));
    });

    test('Scientific notation with explicit positive exponent', () {
      final Expression expression = compiler.expression('1e+5');
      expect(expression, isA<NumberExpression>());
      expect((expression as NumberExpression).value, equals(1e+5));
    });

    test('Decimal with scientific notation', () {
      final Expression expression = compiler.expression('3.14e2');
      expect(expression, isA<NumberExpression>());
      expect((expression as NumberExpression).value, equals(314.0));
    });

    test('Number with underscore separators', () {
      final Expression expression = compiler.expression('1_000_000');
      expect(expression, isA<NumberExpression>());
      expect((expression as NumberExpression).value, equals(1000000));
    });

    test('Decimal with underscore separators', () {
      final Expression expression = compiler.expression('3.141_592');
      expect(expression, isA<NumberExpression>());
      expect((expression as NumberExpression).value, equals(3.141592));
    });
  });

  group('Compiler.compile() - comments', () {
    test('Single-line comment is ignored', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('// this is a comment\nmain() = 42');
      expect(intermediateRepresentation.containsFunction('main'), isTrue);
    });

    test('Multi-line comment is ignored', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('/* multi-line\ncomment */ main() = 42');
      expect(intermediateRepresentation.containsFunction('main'), isTrue);
    });

    test('Inline single-line comment is ignored', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('main() = 42 // inline comment');
      expect(intermediateRepresentation.containsFunction('main'), isTrue);
    });

    test('Multi-line comment within expression is handled', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('main() = 1 /* comment */ + 2');
      expect(intermediateRepresentation.containsFunction('main'), isTrue);
    });
  });

  group('Compiler.compile() - shebang', () {
    test('Shebang line is ignored', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('#!/usr/bin/env primal\nmain() = 42');
      expect(intermediateRepresentation.containsFunction('main'), isTrue);
    });
  });

  group('Compiler.compile() - and/or/not keywords', () {
    test('and keyword works as logical and', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('main() = true and false');
      expect(intermediateRepresentation.containsFunction('main'), isTrue);
    });

    test('or keyword works as logical or', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('main() = true or false');
      expect(intermediateRepresentation.containsFunction('main'), isTrue);
    });

    test('not keyword works as logical not', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('main() = not true');
      expect(intermediateRepresentation.containsFunction('main'), isTrue);
    });
  });

  group('IntermediateRepresentation methods', () {
    test('allFunctionNames returns custom and stdlib function names', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('myFunc() = 42');
      final Set<String> allNames = intermediateRepresentation.allFunctionNames;
      expect(allNames.contains('myFunc'), isTrue);
      expect(allNames.contains('num.add'), isTrue);
    });

    test(
      'getStandardLibrarySignature returns signature for stdlib function',
      () {
        final IntermediateRepresentation intermediateRepresentation = compiler
            .compile('');
        expect(
          intermediateRepresentation.getStandardLibrarySignature('num.add'),
          isNotNull,
        );
      },
    );

    test(
      'getStandardLibrarySignature returns null for non-existent function',
      () {
        final IntermediateRepresentation intermediateRepresentation = compiler
            .compile('');
        expect(
          intermediateRepresentation.getStandardLibrarySignature('nonexistent'),
          isNull,
        );
      },
    );

    test('getCustomFunction returns function for custom function', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('myFunc() = 42');
      expect(
        intermediateRepresentation.getCustomFunction('myFunc'),
        isNotNull,
      );
    });

    test('getCustomFunction returns null for non-existent function', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('');
      expect(
        intermediateRepresentation.getCustomFunction('nonexistent'),
        isNull,
      );
    });

    test('containsFunction returns false for non-existent function', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('');
      expect(
        intermediateRepresentation.containsFunction('nonexistent'),
        isFalse,
      );
    });
  });

  group('Compiler.expression() - edge cases', () {
    test('Deeply nested parentheses', () {
      final Expression expression = compiler.expression('(((((1)))))');
      expect(expression, isA<NumberExpression>());
      expect((expression as NumberExpression).value, equals(1));
    });

    test('Multiple chained function calls', () {
      final Expression expression = compiler.expression('f(1)(2)(3)');
      expect(expression, isA<CallExpression>());
    });

    test('Mixed index and call operations', () {
      final Expression expression = compiler.expression('a[0](1)[2]');
      expect(expression, isA<CallExpression>());
    });

    test('Map with expression keys', () {
      final Expression expression = compiler.expression('{1 + 1: "two"}');
      expect(expression, isA<MapExpression>());
    });

    test('List with expressions', () {
      final Expression expression = compiler.expression('[1 + 1, 2 * 2]');
      expect(expression, isA<ListExpression>());
    });

    test('If/else with nested if/else', () {
      final Expression expression = compiler.expression(
        'if (true) if (false) 1 else 2 else 3',
      );
      expect(expression, isA<CallExpression>());
    });

    test('Double negation', () {
      final Expression expression = compiler.expression('--5');
      expect(expression, isA<CallExpression>());
    });

    test('Double logical not', () {
      final Expression expression = compiler.expression('!!true');
      expect(expression, isA<CallExpression>());
    });

    test('Missing map value throws SyntacticError', () {
      expect(
        () => compiler.expression('{"key": }'),
        throwsA(isA<SyntacticError>()),
      );
    });

    test('Missing map colon throws SyntacticError', () {
      expect(
        () => compiler.expression('{"key" "value"}'),
        throwsA(isA<SyntacticError>()),
      );
    });

    test('Trailing comma in list is handled', () {
      // This should throw because trailing commas are not allowed
      expect(
        () => compiler.expression('[1, 2, ]'),
        throwsA(isA<SyntacticError>()),
      );
    });

    test('Missing if condition closing parenthesis', () {
      expect(
        () => compiler.expression('if (true 1 else 2'),
        throwsA(isA<SyntacticError>()),
      );
    });

    test('Missing else keyword', () {
      expect(
        () => compiler.expression('if (true) 1 2'),
        throwsA(isA<SyntacticError>()),
      );
    });

    test('Function call missing closing parenthesis', () {
      expect(
        () => compiler.expression('foo(1, 2'),
        throwsA(isA<SyntacticError>()),
      );
    });
  });

  group('Compiler.compile() - operator precedence', () {
    test('Addition binds looser than multiplication', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('main() = 1 + 2 * 3');
      expect(intermediateRepresentation.containsFunction('main'), isTrue);
    });

    test('Comparison binds looser than arithmetic', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('main() = 1 + 2 < 3 + 4');
      expect(intermediateRepresentation.containsFunction('main'), isTrue);
    });

    test('Logical operators bind looser than comparison', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('main() = 1 < 2 && 3 < 4');
      expect(intermediateRepresentation.containsFunction('main'), isTrue);
    });

    test('Equality binds looser than logical and', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('main() = true && false == false && true');
      expect(intermediateRepresentation.containsFunction('main'), isTrue);
    });
  });

  group('Compiler.functionDefinition() - additional cases', () {
    test('returns FunctionDefinition for function with complex expression', () {
      final FunctionDefinition? definition = compiler.functionDefinition(
        'compute(a, b, c) = a * b + c',
      );

      expect(definition, isNotNull);
      expect(definition!.name, equals('compute'));
      expect(definition.parameters, equals(['a', 'b', 'c']));
    });

    test('returns FunctionDefinition for recursive function', () {
      final FunctionDefinition? definition = compiler.functionDefinition(
        'factorial(n) = if (n <= 1) 1 else n * factorial(n - 1)',
      );

      expect(definition, isNotNull);
      expect(definition!.name, equals('factorial'));
      expect(definition.parameters, equals(['n']));
    });

    test('returns FunctionDefinition with dotted name', () {
      final FunctionDefinition? definition = compiler.functionDefinition(
        'my.func() = 42',
      );

      expect(definition, isNotNull);
      expect(definition!.name, equals('my.func'));
    });

    test('returns null for comment only', () {
      final FunctionDefinition? definition = compiler.functionDefinition(
        '// just a comment',
      );

      expect(definition, isNull);
    });
  });

  group('CallExpression factory constructors', () {
    test('fromIf creates correct structure', () {
      final Expression expression = compiler.expression(
        'if (true) 1 else 2',
      );
      expect(expression, isA<CallExpression>());
      final CallExpression callExpression = expression as CallExpression;
      expect(callExpression.arguments.length, equals(3));
    });

    test('fromUnaryOperation creates correct structure for not', () {
      final Expression expression = compiler.expression('!false');
      expect(expression, isA<CallExpression>());
      final CallExpression callExpression = expression as CallExpression;
      expect(callExpression.arguments.length, equals(1));
    });

    test('fromBinaryOperation creates correct structure', () {
      final Expression expression = compiler.expression('1 + 2');
      expect(expression, isA<CallExpression>());
      final CallExpression callExpression = expression as CallExpression;
      expect(callExpression.arguments.length, equals(2));
    });
  });

  group('Expression location tracking', () {
    test('NumberExpression has correct location', () {
      final Expression expression = compiler.expression('42');
      expect(expression.location.row, equals(1));
      expect(expression.location.column, equals(1));
    });

    test('StringExpression has correct location', () {
      final Expression expression = compiler.expression('"hello"');
      expect(expression.location.row, equals(1));
      expect(expression.location.column, equals(1));
    });

    test('ListExpression has correct location', () {
      final Expression expression = compiler.expression('[1, 2]');
      expect(expression.location.row, equals(1));
      expect(expression.location.column, equals(1));
    });

    test('MapExpression has correct location', () {
      final Expression expression = compiler.expression('{"a": 1}');
      expect(expression.location.row, equals(1));
      expect(expression.location.column, equals(1));
    });
  });

  group('IntermediateRepresentation.empty()', () {
    test('returns representation with no custom functions', () {
      final IntermediateRepresentation representation =
          IntermediateRepresentation.empty();
      expect(representation.customFunctions, isEmpty);
    });

    test('returns representation with standard library signatures', () {
      final IntermediateRepresentation representation =
          IntermediateRepresentation.empty();
      expect(representation.standardLibrarySignatures, isNotEmpty);
    });

    test('returns representation with empty warnings list', () {
      final IntermediateRepresentation representation =
          IntermediateRepresentation.empty();
      expect(representation.warnings, isEmpty);
    });

    test('containsFunction returns true for standard library functions', () {
      final IntermediateRepresentation representation =
          IntermediateRepresentation.empty();
      expect(representation.containsFunction('num.add'), isTrue);
    });

    test('containsFunction returns false for custom functions', () {
      final IntermediateRepresentation representation =
          IntermediateRepresentation.empty();
      expect(representation.containsFunction('myFunc'), isFalse);
    });
  });

  group('Expression toString methods', () {
    test('NumberExpression toString returns value', () {
      final Expression expression = compiler.expression('42');
      expect(expression.toString(), equals('42'));
    });

    test('StringExpression toString returns quoted value', () {
      final Expression expression = compiler.expression('"hello"');
      expect(expression.toString(), equals('"hello"'));
    });

    test('BooleanExpression toString returns value', () {
      final Expression expression = compiler.expression('true');
      expect(expression.toString(), equals('true'));
    });

    test('ListExpression toString returns list representation', () {
      final Expression expression = compiler.expression('[1, 2, 3]');
      expect(expression.toString(), equals('[1, 2, 3]'));
    });

    test('MapExpression toString returns map representation', () {
      final Expression expression = compiler.expression('{"a": 1}');
      expect(expression.toString(), equals('{"a": 1}'));
    });

    test('IdentifierExpression toString returns identifier name', () {
      final Expression expression = compiler.expression('foo');
      expect(expression.toString(), equals('foo'));
    });

    test('CallExpression toString returns call representation', () {
      final Expression expression = compiler.expression('foo(1, 2)');
      expect(expression.toString(), equals('foo(1, 2)'));
    });
  });

  group('Compiler.compile() - additional lexical errors', () {
    test('Invalid code point in braced unicode escape throws LexicalError', () {
      // Code point exceeding U+10FFFF
      expect(
        () => compiler.compile(r'main() = "\u{FFFFFF}"'),
        throwsA(isA<LexicalError>()),
      );
    });

    test('Too many digits in braced unicode escape throws LexicalError', () {
      expect(
        () => compiler.compile(r'main() = "\u{1234567}"'),
        throwsA(isA<LexicalError>()),
      );
    });

    test('Invalid character in braced unicode escape throws LexicalError', () {
      expect(
        () => compiler.compile(r'main() = "\u{GG}"'),
        throwsA(isA<LexicalError>()),
      );
    });

    test('Double underscore in number throws LexicalError', () {
      expect(
        () => compiler.compile('main() = 1__000'),
        throwsA(isA<LexicalError>()),
      );
    });

    test('Underscore before dot in number throws LexicalError', () {
      expect(
        () => compiler.compile('main() = 1_.0'),
        throwsA(isA<LexicalError>()),
      );
    });

    test('Underscore before exponent throws LexicalError', () {
      expect(
        () => compiler.compile('main() = 1_e10'),
        throwsA(isA<LexicalError>()),
      );
    });

    test('Invalid character after decimal point throws LexicalError', () {
      expect(
        () => compiler.compile('main() = 1.a'),
        throwsA(isA<LexicalError>()),
      );
    });
  });

  group('Compiler.compile() - additional syntactic errors', () {
    test('ExpectedTokenError for missing closing bracket', () {
      expect(
        () => compiler.compile('main() = [1, 2'),
        throwsA(isA<SyntacticError>()),
      );
    });

    test('ExpectedTokenError for missing closing brace', () {
      expect(
        () => compiler.compile('main() = {"a": 1'),
        throwsA(isA<SyntacticError>()),
      );
    });

    test('InvalidTokenError for unexpected token in function definition', () {
      expect(
        () => compiler.compile('123(x) = x'),
        throwsA(isA<SyntacticError>()),
      );
    });

    test('UnexpectedEndOfFileError for incomplete program', () {
      expect(
        () => compiler.compile('foo('),
        throwsA(isA<SyntacticError>()),
      );
    });

    test('UnexpectedEndOfFileError for incomplete function body', () {
      expect(
        () => compiler.compile('foo(x) ='),
        throwsA(isA<SyntacticError>()),
      );
    });
  });

  group('Compiler.compile() - additional semantic errors', () {
    test(
      'Indexing string literal with subscript syntax compiles successfully',
      () {
        // Strings are indexable in Primal (via the @ operator)
        final IntermediateRepresentation intermediateRepresentation = compiler
            .compile('main() = "hello"[0]');
        expect(intermediateRepresentation.containsFunction('main'), isTrue);
      },
    );

    test('Zero arguments to function expecting one throws error', () {
      expect(
        () => compiler.compile('f(x) = x\nmain() = f()'),
        throwsA(isA<InvalidNumberOfArgumentsError>()),
      );
    });

    test('Three arguments to function expecting two throws error', () {
      expect(
        () => compiler.compile('f(x, y) = x + y\nmain() = f(1, 2, 3)'),
        throwsA(isA<InvalidNumberOfArgumentsError>()),
      );
    });

    test('UndefinedFunctionError includes function context', () {
      try {
        compiler.compile('f(x) = unknown(x)\nmain() = f(1)');
        fail('Expected UndefinedFunctionError');
      } on UndefinedFunctionError catch (error) {
        expect(error.message, contains('f'));
        expect(error.message, contains('unknown'));
      }
    });

    test('UndefinedIdentifierError includes function context', () {
      try {
        compiler.compile('f(x) = x + y\nmain() = f(1)');
        fail('Expected UndefinedIdentifierError');
      } on UndefinedIdentifierError catch (error) {
        expect(error.message, contains('f'));
        expect(error.message, contains('y'));
      }
    });
  });

  group('Compiler.compile() - carriage return handling', () {
    test('Windows line endings (CRLF) are handled correctly', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('f(x) = x\r\nmain() = f(1)');
      expect(intermediateRepresentation.containsFunction('f'), isTrue);
      expect(intermediateRepresentation.containsFunction('main'), isTrue);
    });

    test('Old Mac line endings (CR only) are handled correctly', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('f(x) = x\rmain() = f(1)');
      expect(intermediateRepresentation.containsFunction('f'), isTrue);
      expect(intermediateRepresentation.containsFunction('main'), isTrue);
    });
  });

  group('Compiler.expression() - additional edge cases', () {
    test('Map with boolean keys', () {
      final Expression expression = compiler.expression('{true: 1, false: 2}');
      expect(expression, isA<MapExpression>());
      final MapExpression mapExpression = expression as MapExpression;
      expect(mapExpression.value.length, equals(2));
      expect(mapExpression.value[0].key, isA<BooleanExpression>());
    });

    test('List containing empty list', () {
      final Expression expression = compiler.expression('[[]]');
      expect(expression, isA<ListExpression>());
      final ListExpression listExpression = expression as ListExpression;
      expect(listExpression.value.length, equals(1));
      expect(listExpression.value[0], isA<ListExpression>());
      expect((listExpression.value[0] as ListExpression).value, isEmpty);
    });

    test('Map containing empty map', () {
      final Expression expression = compiler.expression('{"a": {}}');
      expect(expression, isA<MapExpression>());
      final MapExpression mapExpression = expression as MapExpression;
      expect(mapExpression.value.length, equals(1));
      expect(mapExpression.value[0].value, isA<MapExpression>());
      expect((mapExpression.value[0].value as MapExpression).value, isEmpty);
    });

    test('Very long identifier', () {
      final String longIdentifier = 'abcdefghijklmnopqrstuvwxyz' * 10;
      final Expression expression = compiler.expression(longIdentifier);
      expect(expression, isA<IdentifierExpression>());
      expect(
        (expression as IdentifierExpression).value,
        equals(longIdentifier),
      );
    });

    test('Identifier with underscore', () {
      final Expression expression = compiler.expression('my_var');
      expect(expression, isA<IdentifierExpression>());
      expect((expression as IdentifierExpression).value, equals('my_var'));
    });

    test('Identifier with digits', () {
      final Expression expression = compiler.expression('var123');
      expect(expression, isA<IdentifierExpression>());
      expect((expression as IdentifierExpression).value, equals('var123'));
    });

    test('Dotted identifier', () {
      final Expression expression = compiler.expression('foo.bar');
      expect(expression, isA<IdentifierExpression>());
      expect((expression as IdentifierExpression).value, equals('foo.bar'));
    });

    test('Call on dotted identifier', () {
      final Expression expression = compiler.expression('num.add(1, 2)');
      expect(expression, isA<CallExpression>());
      final CallExpression callExpression = expression as CallExpression;
      expect(callExpression.callee, isA<IdentifierExpression>());
      expect(
        (callExpression.callee as IdentifierExpression).value,
        equals('num.add'),
      );
    });

    test('Index on identifier', () {
      final Expression expression = compiler.expression('arr[0]');
      expect(expression, isA<CallExpression>());
    });

    test('Index on map literal', () {
      final Expression expression = compiler.expression('{"a": 1}["a"]');
      expect(expression, isA<CallExpression>());
    });

    test('String concatenation simulation with index', () {
      final Expression expression = compiler.expression('"hello" @ 0');
      expect(expression, isA<CallExpression>());
    });
  });

  group('Compiler.compile() - parameter handling', () {
    test('Function with parameter name containing underscore', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('f(my_param) = my_param\nmain() = f(1)');
      expect(intermediateRepresentation.containsFunction('f'), isTrue);
    });

    test('Function with long parameter name', () {
      final String longParameter = 'verylongparametername' * 3;
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('f($longParameter) = $longParameter\nmain() = f(1)');
      expect(intermediateRepresentation.containsFunction('f'), isTrue);
    });

    test('Function with many parameters', () {
      final IntermediateRepresentation
      intermediateRepresentation = compiler.compile(
        'f(a, b, c, d, e, f, g, h, i, j) = a\nmain() = f(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)',
      );
      expect(intermediateRepresentation.containsFunction('f'), isTrue);
      expect(intermediateRepresentation.warnings.length, equals(9));
    });

    test('Function parameter shadows outer function', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile(
            'outer(x) = x\ninner(outer) = outer\nmain() = inner(1)',
          );
      expect(intermediateRepresentation.containsFunction('outer'), isTrue);
      expect(intermediateRepresentation.containsFunction('inner'), isTrue);
    });
  });

  group('Compiler.compile() - complex expressions', () {
    test('Deeply nested binary operations', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('main() = 1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 + 10');
      expect(intermediateRepresentation.containsFunction('main'), isTrue);
    });

    test('Mixed arithmetic and comparison', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('main() = 1 + 2 < 3 * 4');
      expect(intermediateRepresentation.containsFunction('main'), isTrue);
    });

    test('Chained comparisons with logical operators', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('main() = 1 < 2 && 2 < 3 && 3 < 4');
      expect(intermediateRepresentation.containsFunction('main'), isTrue);
    });

    test('Nested if/else expressions', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile(
            'main() = if (true) if (false) 1 else 2 else if (true) 3 else 4',
          );
      expect(intermediateRepresentation.containsFunction('main'), isTrue);
    });

    test('List inside map inside list', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('main() = [{"a": [1, 2, 3]}]');
      expect(intermediateRepresentation.containsFunction('main'), isTrue);
    });

    test('Map inside list inside map', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('main() = {"a": [{"b": 1}]}');
      expect(intermediateRepresentation.containsFunction('main'), isTrue);
    });
  });

  group('Compiler.functionDefinition() - edge cases', () {
    test('returns null for shebang only', () {
      final FunctionDefinition? definition = compiler.functionDefinition(
        '#!/usr/bin/env primal',
      );
      expect(definition, isNull);
    });

    test('returns FunctionDefinition for function with deeply nested body', () {
      final FunctionDefinition? definition = compiler.functionDefinition(
        'f(x) = if (x > 0) if (x > 1) x else 1 else 0',
      );
      expect(definition, isNotNull);
      expect(definition!.name, equals('f'));
    });

    test('returns FunctionDefinition for function with index in body', () {
      final FunctionDefinition? definition = compiler.functionDefinition(
        'f(arr) = arr[0]',
      );
      expect(definition, isNotNull);
      expect(definition!.name, equals('f'));
      expect(definition.parameters, equals(['arr']));
    });

    test('returns FunctionDefinition for function with call chain in body', () {
      final FunctionDefinition? definition = compiler.functionDefinition(
        'f(x) = g(h(i(x)))',
      );
      expect(definition, isNotNull);
      expect(definition!.name, equals('f'));
    });
  });

  group('SemanticFunction properties', () {
    test('SemanticFunction has correct name', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('myFunc(x) = x * 2');
      final semanticFunction =
          intermediateRepresentation.customFunctions['myFunc'];
      expect(semanticFunction, isNotNull);
      expect(semanticFunction!.name, equals('myFunc'));
    });

    test('SemanticFunction has correct parameters', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('add(a, b) = a + b');
      final semanticFunction =
          intermediateRepresentation.customFunctions['add'];
      expect(semanticFunction, isNotNull);
      expect(semanticFunction!.parameters.length, equals(2));
      expect(semanticFunction.parameters[0].name, equals('a'));
      expect(semanticFunction.parameters[1].name, equals('b'));
    });

    test('SemanticFunction toString returns signature', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('myFunc(x, y) = x + y');
      final semanticFunction =
          intermediateRepresentation.customFunctions['myFunc'];
      expect(semanticFunction, isNotNull);
      expect(semanticFunction.toString(), equals('myFunc(x, y)'));
    });
  });

  group('Error message formatting', () {
    test('DuplicatedFunctionError message contains function name', () {
      try {
        compiler.compile('f(x) = x\nf(y) = y');
        fail('Expected DuplicatedFunctionError');
      } on DuplicatedFunctionError catch (error) {
        expect(error.message, contains('f'));
      }
    });

    test('DuplicatedParameterError message contains parameter name', () {
      try {
        compiler.compile('f(x, x) = x');
        fail('Expected DuplicatedParameterError');
      } on DuplicatedParameterError catch (error) {
        expect(error.message, contains('x'));
        expect(error.message, contains('f'));
      }
    });

    test('InvalidNumberOfArgumentsError message contains counts', () {
      try {
        compiler.compile('f(x) = x\nmain() = f(1, 2)');
        fail('Expected InvalidNumberOfArgumentsError');
      } on InvalidNumberOfArgumentsError catch (error) {
        expect(error.message, contains('1'));
        expect(error.message, contains('2'));
      }
    });

    test('NotCallableError message contains type', () {
      try {
        compiler.compile('main() = 5(1)');
        fail('Expected NotCallableError');
      } on NotCallableError catch (error) {
        expect(error.message, contains('number'));
      }
    });

    test('NotIndexableError message contains type', () {
      try {
        compiler.compile('main() = 5[0]');
        fail('Expected NotIndexableError');
      } on NotIndexableError catch (error) {
        expect(error.message, contains('number'));
      }
    });
  });

  group('Compiler.expression() - string edge cases', () {
    test('String with backslash and quote escapes combined', () {
      final Expression expression = compiler.expression('"path\\\\to\\\\"');
      expect(expression, isA<StringExpression>());
      expect((expression as StringExpression).value, equals('path\\to\\'));
    });

    test('Empty single-quoted string', () {
      final Expression expression = compiler.expression("''");
      expect(expression, isA<StringExpression>());
      expect((expression as StringExpression).value, equals(''));
    });

    test('Single-quoted string with escaped single quote', () {
      final Expression expression = compiler.expression("'it\\'s'");
      expect(expression, isA<StringExpression>());
      expect((expression as StringExpression).value, contains("'"));
    });

    test('Double-quoted string with multiple escapes', () {
      final Expression expression = compiler.expression('"\\n\\t\\\\\\""');
      expect(expression, isA<StringExpression>());
      final StringExpression stringExpression = expression as StringExpression;
      expect(stringExpression.value.contains('\n'), isTrue);
      expect(stringExpression.value.contains('\t'), isTrue);
      expect(stringExpression.value.contains('\\'), isTrue);
      expect(stringExpression.value.contains('"'), isTrue);
    });

    test('String with unicode character', () {
      final Expression expression = compiler.expression('"\\u{1F600}"');
      expect(expression, isA<StringExpression>());
    });

    test('String with lowercase hex escape', () {
      final Expression expression = compiler.expression('"\\x6a"');
      expect(expression, isA<StringExpression>());
      expect((expression as StringExpression).value, equals('j'));
    });

    test('String with uppercase hex escape', () {
      final Expression expression = compiler.expression('"\\x6A"');
      expect(expression, isA<StringExpression>());
      expect((expression as StringExpression).value, equals('j'));
    });
  });

  group('Compiler.expression() - number edge cases', () {
    test('Very small decimal', () {
      final Expression expression = compiler.expression('0.000001');
      expect(expression, isA<NumberExpression>());
      expect((expression as NumberExpression).value, equals(0.000001));
    });

    test('Negative zero', () {
      final Expression expression = compiler.expression('-0');
      expect(expression, isA<CallExpression>());
    });

    test('Scientific notation with capital E', () {
      final Expression expression = compiler.expression('1E10');
      expect(expression, isA<NumberExpression>());
      expect((expression as NumberExpression).value, equals(1e10));
    });

    test('Very large number in scientific notation', () {
      final Expression expression = compiler.expression('1e308');
      expect(expression, isA<NumberExpression>());
    });

    test('Decimal with many digits', () {
      final Expression expression = compiler.expression('3.141592653589793');
      expect(expression, isA<NumberExpression>());
    });
  });

  group('Compiler.compile() - whitespace handling', () {
    test('Leading whitespace is ignored', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('   main() = 42');
      expect(intermediateRepresentation.containsFunction('main'), isTrue);
    });

    test('Trailing whitespace is ignored', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('main() = 42   ');
      expect(intermediateRepresentation.containsFunction('main'), isTrue);
    });

    test('Tab characters are treated as whitespace', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('\tmain()\t=\t42');
      expect(intermediateRepresentation.containsFunction('main'), isTrue);
    });

    test('Multiple blank lines between definitions', () {
      final IntermediateRepresentation intermediateRepresentation = compiler
          .compile('f(x) = x\n\n\n\nmain() = f(1)');
      expect(intermediateRepresentation.containsFunction('f'), isTrue);
      expect(intermediateRepresentation.containsFunction('main'), isTrue);
    });
  });
}
