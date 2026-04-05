@Tags(['compiler'])
library;

import 'package:primal/compiler/compiler.dart';
import 'package:primal/compiler/errors/semantic_error.dart';
import 'package:primal/compiler/errors/syntactic_error.dart';
import 'package:primal/compiler/semantic/intermediate_representation.dart';
import 'package:primal/compiler/syntactic/expression.dart';
import 'package:test/test.dart';

void main() {
  const Compiler compiler = Compiler();

  group('Compiler.compile()', () {
    test('Simple program returns IntermediateRepresentation with main', () {
      final IntermediateRepresentation code = compiler.compile('main = 42');
      expect(code.containsFunction('main'), isTrue);
    });

    test('Function definitions create correct functions', () {
      final IntermediateRepresentation code = compiler.compile(
        'double(x) = x * 2\nmain = double(5)',
      );
      expect(code.containsFunction('double'), isTrue);
      expect(code.containsFunction('main'), isTrue);
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
      final IntermediateRepresentation code = compiler.compile(
        'f(x, y) = x\nmain = f(1, 2)',
      );
      expect(code.warnings.length, equals(1));
    });

    test('Program without main compiles successfully', () {
      final IntermediateRepresentation code = compiler.compile('f(x) = x * 2');
      expect(code.containsFunction('f'), isTrue);
    });
  });

  group('Compiler.expression()', () {
    test('Number literal returns NumberExpression', () {
      final Expression expr = compiler.expression('42');
      expect(expr, isA<NumberExpression>());
      expect((expr as NumberExpression).value, equals(42));
    });

    test('String literal returns StringExpression', () {
      final Expression expr = compiler.expression('"hello"');
      expect(expr, isA<StringExpression>());
      expect((expr as StringExpression).value, equals('hello'));
    });

    test('Boolean literal returns BooleanExpression', () {
      final Expression exprTrue = compiler.expression('true');
      expect(exprTrue, isA<BooleanExpression>());
      expect((exprTrue as BooleanExpression).value, isTrue);

      final Expression exprFalse = compiler.expression('false');
      expect(exprFalse, isA<BooleanExpression>());
      expect((exprFalse as BooleanExpression).value, isFalse);
    });

    test('Binary operation returns CallExpression', () {
      final Expression expr = compiler.expression('1 + 2');
      expect(expr, isA<CallExpression>());
      expect(expr.toString(), equals('+(1, 2)'));
    });

    test('Function call returns CallExpression', () {
      final Expression expr = compiler.expression('foo(1, 2)');
      expect(expr, isA<CallExpression>());
      expect(expr.toString(), equals('foo(1, 2)'));
    });

    test('List literal returns ListExpression', () {
      final Expression expr = compiler.expression('[1, 2, 3]');
      expect(expr, isA<ListExpression>());
      expect((expr as ListExpression).value.length, equals(3));
    });

    test('Map literal returns MapExpression', () {
      final Expression expr = compiler.expression('{"a": 1, "b": 2}');
      expect(expr, isA<MapExpression>());
      expect((expr as MapExpression).value.length, equals(2));
    });

    test('If/else returns CallExpression', () {
      final Expression expr = compiler.expression('if (true) 1 else 2');
      expect(expr, isA<CallExpression>());
      expect(expr.toString(), equals('if(true, 1, 2)'));
    });

    test('Invalid input throws error', () {
      expect(
        () => compiler.expression('= = ='),
        throwsA(isA<SyntacticError>()),
      );
    });
  });
}
