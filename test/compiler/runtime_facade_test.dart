@Tags(['compiler'])
library;

import 'package:primal/compiler/semantic/intermediate_code.dart';
import 'package:primal/compiler/semantic/runtime_facade.dart';
import 'package:primal/compiler/syntactic/expression.dart';
import 'package:test/test.dart';
import '../helpers/pipeline_helpers.dart';

void main() {
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
        final RuntimeFacade runtime = RuntimeFacade(IntermediateCode.empty());
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
        final RuntimeFacade runtime = RuntimeFacade(IntermediateCode.empty());
        final Expression expression = getExpression('1 + 2');
        expect(runtime.evaluate(expression), '3');
      });

      test('evaluates expression using custom functions', () {
        final RuntimeFacade runtime = getRuntime('double(x) = x * 2');
        final Expression expression = getExpression('double(5)');
        expect(runtime.evaluate(expression), '10');
      });

      test('evaluates nested expressions', () {
        final RuntimeFacade runtime = RuntimeFacade(IntermediateCode.empty());
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
    });
  });
}
