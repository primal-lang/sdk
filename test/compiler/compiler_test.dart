@Tags(['compiler'])
library;

import 'package:primal/compiler/compiler.dart';
import 'package:primal/compiler/errors/semantic_error.dart';
import 'package:primal/compiler/errors/syntactic_error.dart';
import 'package:primal/compiler/semantic/intermediate_representation.dart';
import 'package:primal/compiler/syntactic/expression.dart';
import 'package:primal/compiler/syntactic/function_definition.dart';
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
  });
}
