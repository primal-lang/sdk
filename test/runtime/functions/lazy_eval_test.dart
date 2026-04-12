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
        'main() = if (true) 1 else error.throw(-1, "Error")',
      );
      checkResult(runtime, 1);
    });

    test('if false does not evaluate then branch', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = if (false) error.throw(-1, "Error") else 2',
      );
      checkResult(runtime, 2);
    });

    test('nested if with lazy outer else', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = if (true) (if (true) 1 else 2) else error.throw(-1, "Error")',
      );
      checkResult(runtime, 1);
    });

    test('nested if with lazy inner else', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = if (true) (if (true) 1 else error.throw(-1, "Error")) else 0',
      );
      checkResult(runtime, 1);
    });

    test('try does not propagate caught error', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = try(error.throw(-1, "Fail"), 42)',
      );
      checkResult(runtime, 42);
    });

    test('try returns value when no error', () {
      final RuntimeFacade runtime = getRuntime('main() = try(10, -1)');
      checkResult(runtime, 10);
    });

    test('try does not evaluate fallback when no error', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = try(42, error.throw(-1, "Should not evaluate"))',
      );
      checkResult(runtime, 42);
    });

    test('try fallback error propagates when primary fails', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = try(error.throw(-1, "Primary"), error.throw(-2, "Fallback"))',
      );
      expect(runtime.executeMain, throwsA(anything));
    });

    test('nested try with lazy inner fallback', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = try(try(1, 2), error.throw(-1, "Outer fallback"))',
      );
      checkResult(runtime, 1);
    });

    test('if returns then branch value when condition true', () {
      final RuntimeFacade runtime = getRuntime('main() = if (true) 42 else 0');
      checkResult(runtime, 42);
    });

    test('if returns else branch value when condition false', () {
      final RuntimeFacade runtime = getRuntime('main() = if (false) 0 else 99');
      checkResult(runtime, 99);
    });

    test('if with complex expression in then branch', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = if (true) (1 + 2 * 3) else 0',
      );
      checkResult(runtime, 7);
    });

    test('if with complex expression in else branch', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = if (false) 0 else (10 - 3)',
      );
      checkResult(runtime, 7);
    });

    test('if with string result', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = if (true) "yes" else "no"',
      );
      checkResult(runtime, '"yes"');
    });

    test('if with list result', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = if (false) [] else [1, 2, 3]',
      );
      checkResult(runtime, '[1, 2, 3]');
    });

    test('nested try with outer fallback used', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = try(try(error.throw(-1, "Inner"), error.throw(-2, "Inner fallback")), 100)',
      );
      checkResult(runtime, 100);
    });

    test('try with expression evaluation in primary', () {
      final RuntimeFacade runtime = getRuntime('main() = try(1 + 2 + 3, 0)');
      checkResult(runtime, 6);
    });

    test('try with expression evaluation in fallback', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = try(error.throw(-1, "Fail"), 10 * 5)',
      );
      checkResult(runtime, 50);
    });

    test('try preserves result type from primary', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = try("hello", "world")',
      );
      checkResult(runtime, '"hello"');
    });

    test('try preserves result type from fallback', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = try(error.throw(-1, "Fail"), "fallback")',
      );
      checkResult(runtime, '"fallback"');
    });

    test('try with list result', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = try(error.throw(-1, "Fail"), [1, 2, 3])',
      );
      checkResult(runtime, '[1, 2, 3]');
    });

    test('triple nested try all succeed', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = try(try(try(42, 0), 0), 0)',
      );
      checkResult(runtime, 42);
    });

    test('triple nested try innermost fails', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = try(try(try(error.throw(-1, "Fail"), 1), 2), 3)',
      );
      checkResult(runtime, 1);
    });
  });

  group('Short-Circuit Boolean Evaluation', () {
    test('and does not evaluate second argument when first is false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = false && error.throw(-1, "Should not evaluate")',
      );
      checkResult(runtime, false);
    });

    test('bool.and does not evaluate second argument when first is false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = bool.and(false, error.throw(-1, "Should not evaluate"))',
      );
      checkResult(runtime, false);
    });

    test('or does not evaluate second argument when first is true', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = true || error.throw(-1, "Should not evaluate")',
      );
      checkResult(runtime, true);
    });

    test('bool.or does not evaluate second argument when first is true', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = bool.or(true, error.throw(-1, "Should not evaluate"))',
      );
      checkResult(runtime, true);
    });

    test('and evaluates second argument when first is true', () {
      final RuntimeFacade runtime = getRuntime('main() = true && true');
      checkResult(runtime, true);
    });

    test('or evaluates second argument when first is false', () {
      final RuntimeFacade runtime = getRuntime('main() = false || true');
      checkResult(runtime, true);
    });

    test('nested and with lazy evaluation', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = false && (false && error.throw(-1, "Error"))',
      );
      checkResult(runtime, false);
    });

    test('nested or with lazy evaluation', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = true || (true || error.throw(-1, "Error"))',
      );
      checkResult(runtime, true);
    });

    test('chained and short-circuits at first false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = true && false && error.throw(-1, "Error")',
      );
      checkResult(runtime, false);
    });

    test('chained or short-circuits at first true', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = false || true || error.throw(-1, "Error")',
      );
      checkResult(runtime, true);
    });

    test('and returns second operand value when both true', () {
      final RuntimeFacade runtime = getRuntime('main() = true && true');
      checkResult(runtime, true);
    });

    test('and returns false when second operand is false', () {
      final RuntimeFacade runtime = getRuntime('main() = true && false');
      checkResult(runtime, false);
    });

    test('or returns second operand value when first is false', () {
      final RuntimeFacade runtime = getRuntime('main() = false || false');
      checkResult(runtime, false);
    });

    test('or returns true when second operand is true', () {
      final RuntimeFacade runtime = getRuntime('main() = false || true');
      checkResult(runtime, true);
    });

    test('bool.and returns second operand value when both true', () {
      final RuntimeFacade runtime = getRuntime('main() = bool.and(true, true)');
      checkResult(runtime, true);
    });

    test('bool.and returns false when second operand is false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = bool.and(true, false)',
      );
      checkResult(runtime, false);
    });

    test('bool.or returns second operand value when first is false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = bool.or(false, false)',
      );
      checkResult(runtime, false);
    });

    test('bool.or returns true when second operand is true', () {
      final RuntimeFacade runtime = getRuntime('main() = bool.or(false, true)');
      checkResult(runtime, true);
    });

    test('mixed and-or with lazy evaluation left to right', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = true || false && error.throw(-1, "Error")',
      );
      checkResult(runtime, true);
    });

    test('mixed or-and with lazy evaluation', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = false && true || true',
      );
      checkResult(runtime, true);
    });

    test('complex chained and all true', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = true && true && true && true',
      );
      checkResult(runtime, true);
    });

    test('complex chained or all false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = false || false || false || false',
      );
      checkResult(runtime, false);
    });

    test('and with expression as first operand', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = (1 == 1) && (2 == 2)',
      );
      checkResult(runtime, true);
    });

    test('or with expression as first operand', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = (1 == 2) || (2 == 2)',
      );
      checkResult(runtime, true);
    });

    test('and short-circuits when first expression is false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = (1 == 2) && error.throw(-1, "Error")',
      );
      checkResult(runtime, false);
    });

    test('or short-circuits when first expression is true', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = (1 == 1) || error.throw(-1, "Error")',
      );
      checkResult(runtime, true);
    });
  });

  group('Strict Boolean Evaluation', () {
    test('bool.andStrict evaluates both operands when first is false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = try(bool.andStrict(false, error.throw(-1, "Evaluated")), "caught")',
      );
      checkResult(runtime, '"caught"');
    });

    test('bool.orStrict evaluates both operands when first is true', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = try(bool.orStrict(true, error.throw(-1, "Evaluated")), "caught")',
      );
      checkResult(runtime, '"caught"');
    });

    test('bool.andStrict returns true when both true', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = bool.andStrict(true, true)',
      );
      checkResult(runtime, true);
    });

    test('bool.andStrict returns false when first false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = bool.andStrict(false, true)',
      );
      checkResult(runtime, false);
    });

    test('bool.andStrict returns false when second false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = bool.andStrict(true, false)',
      );
      checkResult(runtime, false);
    });

    test('bool.andStrict returns false when both false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = bool.andStrict(false, false)',
      );
      checkResult(runtime, false);
    });

    test('bool.orStrict returns true when both true', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = bool.orStrict(true, true)',
      );
      checkResult(runtime, true);
    });

    test('bool.orStrict returns true when first true', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = bool.orStrict(true, false)',
      );
      checkResult(runtime, true);
    });

    test('bool.orStrict returns true when second true', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = bool.orStrict(false, true)',
      );
      checkResult(runtime, true);
    });

    test('bool.orStrict returns false when both false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = bool.orStrict(false, false)',
      );
      checkResult(runtime, false);
    });
  });

  group('Combined Lazy Constructs', () {
    test('if with lazy and in condition', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = if (false && error.throw(-1, "Error")) 1 else 2',
      );
      checkResult(runtime, 2);
    });

    test('if with lazy or in condition', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = if (true || error.throw(-1, "Error")) 1 else 2',
      );
      checkResult(runtime, 1);
    });

    test('try inside if then branch not evaluated when condition false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = if (false) try(error.throw(-1, "A"), error.throw(-1, "B")) else 0',
      );
      checkResult(runtime, 0);
    });

    test('if inside try with error in then branch', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = try(if (true) error.throw(-1, "Error") else 0, 42)',
      );
      checkResult(runtime, 42);
    });

    test('deeply nested lazy if expressions', () {
      final RuntimeFacade runtime = getRuntime('''
main() = if (true)
         (if (true)
           (if (true) 1 else error.throw(-1, "E1"))
         else error.throw(-1, "E2"))
       else error.throw(-1, "E3")
''');
      checkResult(runtime, 1);
    });

    test('deeply nested lazy else expressions', () {
      final RuntimeFacade runtime = getRuntime('''
main() = if (false)
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
main() = safeDiv(10, 0)
''');
      checkResult(runtime, 0);
    });

    test('lazy evaluation with function call in unevaluated branch', () {
      final RuntimeFacade runtime = getRuntime('''
fail(x) = error.throw(-1, "Should not be called")
main() = if (true) 100 else fail(1)
''');
      checkResult(runtime, 100);
    });

    test('and in then branch not evaluated when condition false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = if (false) (true && error.throw(-1, "Error")) else 42',
      );
      checkResult(runtime, 42);
    });

    test('or in else branch not evaluated when condition true', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = if (true) 42 else (false || error.throw(-1, "Error"))',
      );
      checkResult(runtime, 42);
    });

    test('try with lazy and in primary', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = try(false && error.throw(-1, "Error"), "fallback")',
      );
      checkResult(runtime, false);
    });

    test('try with lazy or in primary', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = try(true || error.throw(-1, "Error"), "fallback")',
      );
      checkResult(runtime, true);
    });

    test('if condition with try', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = if (try(error.throw(-1, "Fail"), true)) 1 else 2',
      );
      checkResult(runtime, 1);
    });

    test('if condition with try returning false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = if (try(error.throw(-1, "Fail"), false)) 1 else 2',
      );
      checkResult(runtime, 2);
    });

    test('nested if with different result types', () {
      final RuntimeFacade runtime = getRuntime('''
main() = if (true)
         (if (false) 1 else "string")
       else 0
''');
      checkResult(runtime, '"string"');
    });

    test('lazy if preserves function result', () {
      final RuntimeFacade runtime = getRuntime('''
double(x) = x * 2
main() = if (true) double(21) else error.throw(-1, "Error")
''');
      checkResult(runtime, 42);
    });

    test('lazy evaluation in recursive function', () {
      final RuntimeFacade runtime = getRuntime('''
factorial(n) = if (n <= 1) 1 else n * factorial(n - 1)
main() = factorial(5)
''');
      checkResult(runtime, 120);
    });

    test('lazy evaluation prevents infinite recursion in guards', () {
      final RuntimeFacade runtime = getRuntime('''
safeRecurse(n) = if (n <= 0) 0 else safeRecurse(n - 1)
main() = safeRecurse(10)
''');
      checkResult(runtime, 0);
    });

    test('multiple try with chained fallbacks', () {
      final RuntimeFacade runtime = getRuntime('''
main() = try(
         try(
           error.throw(-1, "First"),
           error.throw(-2, "Second")
         ),
         try(
           error.throw(-3, "Third"),
           42
         )
       )
''');
      checkResult(runtime, 42);
    });

    test('boolean and with try in second operand', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = true && try(error.throw(-1, "Fail"), true)',
      );
      checkResult(runtime, true);
    });

    test('boolean or with try in second operand', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = false || try(error.throw(-1, "Fail"), true)',
      );
      checkResult(runtime, true);
    });

    test('complex expression with all lazy constructs', () {
      final RuntimeFacade runtime = getRuntime('''
main() = if (true || error.throw(-1, "E1"))
         try(
           if (false) error.throw(-1, "E2") else 42,
           error.throw(-1, "E3")
         )
       else error.throw(-1, "E4")
''');
      checkResult(runtime, 42);
    });

    test('lazy if with map result', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = if (true) {"key": "value"} else error.throw(-1, "Error")',
      );
      checkResult(runtime, '{"key": "value"}');
    });

    test('try with map result in fallback', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = try(error.throw(-1, "Fail"), {"a": 1})',
      );
      checkResult(runtime, '{"a": 1}');
    });
  });

  group('Error Handling in Lazy Evaluation', () {
    test('if throws when condition is not boolean', () {
      final RuntimeFacade runtime = getRuntime('main() = if (1) 1 else 2');
      expect(runtime.executeMain, throwsA(anything));
    });

    test('if throws when condition is string', () {
      final RuntimeFacade runtime = getRuntime('main() = if ("true") 1 else 2');
      expect(runtime.executeMain, throwsA(anything));
    });

    test('bool.and throws when first argument is not boolean', () {
      final RuntimeFacade runtime = getRuntime('main() = bool.and(1, true)');
      expect(runtime.executeMain, throwsA(anything));
    });

    test('bool.and throws when second argument is not boolean', () {
      final RuntimeFacade runtime = getRuntime('main() = bool.and(true, 1)');
      expect(runtime.executeMain, throwsA(anything));
    });

    test('bool.or throws when first argument is not boolean', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = bool.or("yes", false)',
      );
      expect(runtime.executeMain, throwsA(anything));
    });

    test('bool.or throws when second argument is not boolean', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = bool.or(false, "yes")',
      );
      expect(runtime.executeMain, throwsA(anything));
    });

    test('bool.andStrict throws when first argument is not boolean', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = bool.andStrict(1, true)',
      );
      expect(runtime.executeMain, throwsA(anything));
    });

    test('bool.andStrict throws when second argument is not boolean', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = bool.andStrict(true, 1)',
      );
      expect(runtime.executeMain, throwsA(anything));
    });

    test('bool.orStrict throws when first argument is not boolean', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = bool.orStrict("x", true)',
      );
      expect(runtime.executeMain, throwsA(anything));
    });

    test('bool.orStrict throws when second argument is not boolean', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = bool.orStrict(false, "x")',
      );
      expect(runtime.executeMain, throwsA(anything));
    });

    test('error in evaluated branch propagates', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = if (true) error.throw(-1, "Error") else 0',
      );
      expect(runtime.executeMain, throwsA(anything));
    });

    test('error in evaluated else branch propagates', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = if (false) 0 else error.throw(-1, "Error")',
      );
      expect(runtime.executeMain, throwsA(anything));
    });

    test('error in and second operand propagates when first is true', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = true && error.throw(-1, "Error")',
      );
      expect(runtime.executeMain, throwsA(anything));
    });

    test('error in or second operand propagates when first is false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = false || error.throw(-1, "Error")',
      );
      expect(runtime.executeMain, throwsA(anything));
    });

    test('nested error in evaluated branch propagates', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = if (true) (if (true) error.throw(-1, "Error") else 0) else 1',
      );
      expect(runtime.executeMain, throwsA(anything));
    });
  });

  group('Edge Cases', () {
    test('if with zero as then result', () {
      final RuntimeFacade runtime = getRuntime('main() = if (true) 0 else 1');
      checkResult(runtime, 0);
    });

    test('if with negative number as result', () {
      final RuntimeFacade runtime = getRuntime('main() = if (true) -42 else 0');
      checkResult(runtime, -42);
    });

    test('if with empty string as result', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = if (true) "" else "x"',
      );
      checkResult(runtime, '""');
    });

    test('if with empty list as result', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = if (true) [] else [1]',
      );
      checkResult(runtime, '[]');
    });

    test('if with empty map as result', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = if (true) {} else {"a": 1}',
      );
      checkResult(runtime, '{}');
    });

    test('try with zero as primary', () {
      final RuntimeFacade runtime = getRuntime('main() = try(0, 1)');
      checkResult(runtime, 0);
    });

    test('try with false as primary', () {
      final RuntimeFacade runtime = getRuntime('main() = try(false, true)');
      checkResult(runtime, false);
    });

    test('try with empty string as primary', () {
      final RuntimeFacade runtime = getRuntime('main() = try("", "default")');
      checkResult(runtime, '""');
    });

    test('try with empty list as primary', () {
      final RuntimeFacade runtime = getRuntime('main() = try([], [1, 2])');
      checkResult(runtime, '[]');
    });

    test('deeply nested and short-circuits early', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = false && (true && (true && (true && error.throw(-1, "Error"))))',
      );
      checkResult(runtime, false);
    });

    test('deeply nested or short-circuits early', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = true || (false || (false || (false || error.throw(-1, "Error"))))',
      );
      checkResult(runtime, true);
    });

    test('many sequential if expressions', () {
      final RuntimeFacade runtime = getRuntime('''
main() = if (true)
         (if (false)
           error.throw(-1, "E1")
         else (if (true)
                 (if (false)
                   error.throw(-1, "E2")
                 else 42)
               else error.throw(-1, "E3")))
       else error.throw(-1, "E4")
''');
      checkResult(runtime, 42);
    });

    test('if with boolean expression result', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = if (true) (1 == 1) else (2 == 3)',
      );
      checkResult(runtime, true);
    });

    test('try with boolean expression in both branches', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = try(1 < 2, 3 > 4)',
      );
      checkResult(runtime, true);
    });

    test('and with comparison expressions', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = (1 < 2) && (3 < 4)',
      );
      checkResult(runtime, true);
    });

    test('or with comparison expressions', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = (1 > 2) || (3 < 4)',
      );
      checkResult(runtime, true);
    });

    test('lazy evaluation with float values', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = if (true) 3.14159 else error.throw(-1, "Error")',
      );
      checkResult(runtime, 3.14159);
    });

    test('try with float fallback', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = try(error.throw(-1, "Fail"), 2.71828)',
      );
      checkResult(runtime, 2.71828);
    });
  });
}
