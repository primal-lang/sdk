@Tags(['runtime'])
library;

import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Lazy Evaluation', () {
    test('if true does not evaluate else branch', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (true) 1 else error.throw(-1, "Error")',
      );
      checkResult(runtime, 1);
    });

    test('if false does not evaluate then branch', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (false) error.throw(-1, "Error") else 2',
      );
      checkResult(runtime, 2);
    });

    test('nested if with lazy outer else', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (true) (if (true) 1 else 2) else error.throw(-1, "Error")',
      );
      checkResult(runtime, 1);
    });

    test('nested if with lazy inner else', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (true) (if (true) 1 else error.throw(-1, "Error")) else 0',
      );
      checkResult(runtime, 1);
    });

    test('try does not propagate caught error', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(error.throw(-1, "Fail"), 42)',
      );
      checkResult(runtime, 42);
    });

    test('try returns value when no error', () {
      final RuntimeFacade runtime = getRuntime('main = try(10, -1)');
      checkResult(runtime, 10);
    });

    test('try does not evaluate fallback when no error', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(42, error.throw(-1, "Should not evaluate"))',
      );
      checkResult(runtime, 42);
    });

    test('try fallback error propagates when primary fails', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(error.throw(-1, "Primary"), error.throw(-2, "Fallback"))',
      );
      expect(runtime.executeMain, throwsA(anything));
    });

    test('nested try with lazy inner fallback', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(try(1, 2), error.throw(-1, "Outer fallback"))',
      );
      checkResult(runtime, 1);
    });
  });

  group('Short-Circuit Boolean Evaluation', () {
    test('and does not evaluate second argument when first is false', () {
      final RuntimeFacade runtime = getRuntime(
        'main = false && error.throw(-1, "Should not evaluate")',
      );
      checkResult(runtime, false);
    });

    test('bool.and does not evaluate second argument when first is false', () {
      final RuntimeFacade runtime = getRuntime(
        'main = bool.and(false, error.throw(-1, "Should not evaluate"))',
      );
      checkResult(runtime, false);
    });

    test('or does not evaluate second argument when first is true', () {
      final RuntimeFacade runtime = getRuntime(
        'main = true || error.throw(-1, "Should not evaluate")',
      );
      checkResult(runtime, true);
    });

    test('bool.or does not evaluate second argument when first is true', () {
      final RuntimeFacade runtime = getRuntime(
        'main = bool.or(true, error.throw(-1, "Should not evaluate"))',
      );
      checkResult(runtime, true);
    });

    test('and evaluates second argument when first is true', () {
      final RuntimeFacade runtime = getRuntime('main = true && true');
      checkResult(runtime, true);
    });

    test('or evaluates second argument when first is false', () {
      final RuntimeFacade runtime = getRuntime('main = false || true');
      checkResult(runtime, true);
    });

    test('nested and with lazy evaluation', () {
      final RuntimeFacade runtime = getRuntime(
        'main = false && (false && error.throw(-1, "Error"))',
      );
      checkResult(runtime, false);
    });

    test('nested or with lazy evaluation', () {
      final RuntimeFacade runtime = getRuntime(
        'main = true || (true || error.throw(-1, "Error"))',
      );
      checkResult(runtime, true);
    });

    test('chained and short-circuits at first false', () {
      final RuntimeFacade runtime = getRuntime(
        'main = true && false && error.throw(-1, "Error")',
      );
      checkResult(runtime, false);
    });

    test('chained or short-circuits at first true', () {
      final RuntimeFacade runtime = getRuntime(
        'main = false || true || error.throw(-1, "Error")',
      );
      checkResult(runtime, true);
    });
  });

  group('Combined Lazy Constructs', () {
    test('if with lazy and in condition', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (false && error.throw(-1, "Error")) 1 else 2',
      );
      checkResult(runtime, 2);
    });

    test('if with lazy or in condition', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (true || error.throw(-1, "Error")) 1 else 2',
      );
      checkResult(runtime, 1);
    });

    test('try inside if then branch not evaluated when condition false', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (false) try(error.throw(-1, "A"), error.throw(-1, "B")) else 0',
      );
      checkResult(runtime, 0);
    });

    test('if inside try with error in then branch', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(if (true) error.throw(-1, "Error") else 0, 42)',
      );
      checkResult(runtime, 42);
    });

    test('deeply nested lazy if expressions', () {
      final RuntimeFacade runtime = getRuntime('''
main = if (true)
         (if (true)
           (if (true) 1 else error.throw(-1, "E1"))
         else error.throw(-1, "E2"))
       else error.throw(-1, "E3")
''');
      checkResult(runtime, 1);
    });

    test('deeply nested lazy else expressions', () {
      final RuntimeFacade runtime = getRuntime('''
main = if (false)
         error.throw(-1, "E1")
       else (if (false)
               error.throw(-1, "E2")
             else (if (false)
                     error.throw(-1, "E3")
                   else 42))
''');
      checkResult(runtime, 42);
    });

    test('custom function with lazy if', () {
      final RuntimeFacade runtime = getRuntime('''
safeDiv(a, b) = if (b == 0) 0 else a / b
main = safeDiv(10, 0)
''');
      checkResult(runtime, 0);
    });

    test('lazy evaluation with function call in unevaluated branch', () {
      final RuntimeFacade runtime = getRuntime('''
fail(x) = error.throw(-1, "Should not be called")
main = if (true) 100 else fail(1)
''');
      checkResult(runtime, 100);
    });
  });
}
