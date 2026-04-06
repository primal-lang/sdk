@Tags(['compiler'])
library;

import 'package:primal/compiler/compiler.dart';
import 'package:primal/compiler/errors/semantic_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:primal/compiler/semantic/intermediate_representation.dart';
import 'package:primal/compiler/syntactic/expression.dart';
import 'package:primal/compiler/syntactic/function_definition.dart';
import 'package:test/test.dart';
import '../helpers/pipeline_helpers.dart';

void main() {
  const Compiler compiler = Compiler();

  group('RuntimeFacade', () {
    group('hasMain', () {
      test('returns true when main is defined', () {
        final RuntimeFacade runtime = getRuntime('main = 42');
        expect(runtime.hasMain, true);
      });

      test('returns false when main is not defined', () {
        final RuntimeFacade runtime = getRuntime('f(x) = x');
        expect(runtime.hasMain, false);
      });

      test('returns false for empty intermediate code', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        expect(runtime.hasMain, false);
      });
    });

    group('executeMain', () {
      test('executes parameterless main', () {
        final RuntimeFacade runtime = getRuntime('main = 42');
        expect(runtime.executeMain(), '42');
      });

      test('executes main with arguments', () {
        final RuntimeFacade runtime = getRuntime('main(a) = a');
        expect(runtime.executeMain(['hello']), '"hello"');
      });

      test('executes main with multiple arguments', () {
        final RuntimeFacade runtime = getRuntime(
          'main(a, b) = to.string(a) + to.string(b)',
        );
        expect(runtime.executeMain(['foo', 'bar']), '"foobar"');
      });
    });

    group('evaluate', () {
      test('evaluates simple expression', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final Expression expression = getExpression('1 + 2');
        expect(runtime.evaluate(expression), '3');
      });

      test('evaluates expression using custom functions', () {
        final RuntimeFacade runtime = getRuntime('double(x) = x * 2');
        final Expression expression = getExpression('double(5)');
        expect(runtime.evaluate(expression), '10');
      });

      test('evaluates nested expressions', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final Expression expression = getExpression('(1 + 2) * (3 + 4)');
        expect(runtime.evaluate(expression), '21');
      });
    });

    group('mainExpression', () {
      test('returns main() call for parameterless main', () {
        final RuntimeFacade runtime = getRuntime('main = 42');
        final Expression expression = runtime.mainExpression([]);
        expect(expression.toString(), 'main()');
      });

      test('returns main call with arguments for parameterized main', () {
        final RuntimeFacade runtime = getRuntime('main(a, b) = a + b');
        final Expression expression = runtime.mainExpression(['x', 'y']);
        expect(expression.toString(), 'main("x", "y")');
      });

      test('escapes double quotes in arguments', () {
        final RuntimeFacade runtime = getRuntime('main(a) = a');
        final String result = runtime.executeMain(['hello "world"']);
        expect(result, '"hello "world""');
      });

      test('escapes backslashes in arguments', () {
        final RuntimeFacade runtime = getRuntime('main(a) = a');
        final String result = runtime.executeMain([r'path\to\file']);
        expect(result, r'"path\to\file"');
      });

      test('escapes both quotes and backslashes in arguments', () {
        final RuntimeFacade runtime = getRuntime('main(a) = a');
        final String result = runtime.executeMain([r'say "hello\" world']);
        expect(result, r'"say "hello\" world"');
      });
    });

    group('defineFunction', () {
      test('defines a constant that can be evaluated', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition definition = compiler.functionDefinition(
          'pi = 3.14',
        )!;

        runtime.defineFunction(definition);

        // Constants are zero-argument functions, so call with ()
        final Expression expression = getExpression('pi()');
        expect(runtime.evaluate(expression), '3.14');
      });

      test('defines a function that can be called', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition definition = compiler.functionDefinition(
          'double(x) = x * 2',
        )!;

        runtime.defineFunction(definition);

        final Expression expression = getExpression('double(5)');
        expect(runtime.evaluate(expression), '10');
      });

      test('defines a function with multiple parameters', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition definition = compiler.functionDefinition(
          'add(a, b, c) = a + b + c',
        )!;

        runtime.defineFunction(definition);

        final Expression expression = getExpression('add(1, 2, 3)');
        expect(runtime.evaluate(expression), '6');
      });

      test('allows redefining user-defined functions', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition definition1 = compiler.functionDefinition(
          'value = 1',
        )!;
        final FunctionDefinition definition2 = compiler.functionDefinition(
          'value = 2',
        )!;

        runtime.defineFunction(definition1);
        // Constants are zero-argument functions
        expect(runtime.evaluate(getExpression('value()')), '1');

        runtime.defineFunction(definition2);
        expect(runtime.evaluate(getExpression('value()')), '2');
      });

      test('supports recursive functions', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        // Primal uses "if (cond) then else" syntax
        final FunctionDefinition definition = compiler.functionDefinition(
          'factorial(n) = if (n <= 1) 1 else n * factorial(n - 1)',
        )!;

        runtime.defineFunction(definition);

        final Expression expression = getExpression('factorial(5)');
        expect(runtime.evaluate(expression), '120');
      });

      test('throws when trying to redefine standard library function', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        // Use a real standard library function name
        final FunctionDefinition definition = compiler.functionDefinition(
          'num.add = 1',
        )!;

        expect(
          () => runtime.defineFunction(definition),
          throwsA(isA<CannotRedefineStandardLibraryError>()),
        );
      });

      test('throws for duplicate parameters', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition definition = compiler.functionDefinition(
          'bad(x, x) = x',
        )!;

        expect(
          () => runtime.defineFunction(definition),
          throwsA(isA<DuplicatedParameterError>()),
        );
      });

      test('throws for undefined identifier in function body', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition definition = compiler.functionDefinition(
          'bad(x) = y',
        )!;

        expect(
          () => runtime.defineFunction(definition),
          throwsA(isA<UndefinedIdentifierError>()),
        );
      });

      test('can use previously defined functions in new definitions', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        final FunctionDefinition double = compiler.functionDefinition(
          'double(x) = x * 2',
        )!;
        final FunctionDefinition quadruple = compiler.functionDefinition(
          'quadruple(x) = double(double(x))',
        )!;

        runtime.defineFunction(double);
        runtime.defineFunction(quadruple);

        expect(runtime.evaluate(getExpression('quadruple(3)')), '12');
      });

      test('can use standard library functions in definitions', () {
        final RuntimeFacade runtime = RuntimeFacade(
          IntermediateRepresentation.empty(),
          compiler.expression,
        );
        // Use num.mul which is the standard library multiply function
        final FunctionDefinition definition = compiler.functionDefinition(
          'double(x) = num.mul(x, 2)',
        )!;

        runtime.defineFunction(definition);

        expect(runtime.evaluate(getExpression('double(5)')), '10');
      });
    });
  });
}
