@Tags(['runtime'])
library;

import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Main', () {
    test('parameterless main returns constant', () {
      final RuntimeFacade runtime = getRuntime('main = 42');
      checkResult(runtime, 42);
    });

    test('main with single argument', () {
      final RuntimeFacade runtime = getRuntime('main(a) = a');
      expect(runtime.executeMain(['hello']), '"hello"');
    });

    test('main with multiple arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main(a, b, c) = to.string(a) + to.string(b) + to.string(c)',
      );
      expect(runtime.executeMain(['aaa', 'bbb', 'ccc']), '"aaabbbccc"');
    });

    test('main calls custom helper function', () {
      final RuntimeFacade runtime = getRuntime(
        'double(x) = x * 2\nmain = double(5)',
      );
      checkResult(runtime, 10);
    });

    test('hasMain is true when main is defined', () {
      final RuntimeFacade runtime = getRuntime('main = 1');
      expect(runtime.hasMain, true);
    });

    test('hasMain is false when main is not defined', () {
      final RuntimeFacade runtime = getRuntime('f(x) = x');
      expect(runtime.hasMain, false);
    });

    group('return types', () {
      test('main returns boolean true', () {
        final RuntimeFacade runtime = getRuntime('main = true');
        checkResult(runtime, true);
      });

      test('main returns boolean false', () {
        final RuntimeFacade runtime = getRuntime('main = false');
        checkResult(runtime, false);
      });

      test('main returns string', () {
        final RuntimeFacade runtime = getRuntime('main = "hello world"');
        checkResult(runtime, '"hello world"');
      });

      test('main returns empty string', () {
        final RuntimeFacade runtime = getRuntime('main = ""');
        checkResult(runtime, '""');
      });

      test('main returns list', () {
        final RuntimeFacade runtime = getRuntime('main = [1, 2, 3]');
        checkResult(runtime, '[1, 2, 3]');
      });

      test('main returns empty list', () {
        final RuntimeFacade runtime = getRuntime('main = []');
        checkResult(runtime, '[]');
      });

      test('main returns nested list', () {
        final RuntimeFacade runtime = getRuntime('main = [[1, 2], [3, 4]]');
        checkResult(runtime, '[[1, 2], [3, 4]]');
      });

      test('main returns map', () {
        final RuntimeFacade runtime = getRuntime('main = {"a": 1, "b": 2}');
        checkResult(runtime, {'"a"': 1, '"b"': 2});
      });

      test('main returns empty map', () {
        final RuntimeFacade runtime = getRuntime('main = {}');
        checkResult(runtime, {});
      });

      test('main returns negative number', () {
        final RuntimeFacade runtime = getRuntime('main = -42');
        checkResult(runtime, -42);
      });

      test('main returns decimal number', () {
        final RuntimeFacade runtime = getRuntime('main = 3.14159');
        checkResult(runtime, 3.14159);
      });
    });

    group('conditionals', () {
      test('main uses if-else returning then branch', () {
        final RuntimeFacade runtime = getRuntime('main = if (true) 1 else 2');
        checkResult(runtime, 1);
      });

      test('main uses if-else returning else branch', () {
        final RuntimeFacade runtime = getRuntime('main = if (false) 1 else 2');
        checkResult(runtime, 2);
      });

      test('main uses nested conditionals', () {
        final RuntimeFacade runtime = getRuntime(
          'main = if (false) 1 else if (true) 2 else 3',
        );
        checkResult(runtime, 2);
      });

      test('main uses conditional with comparison', () {
        final RuntimeFacade runtime = getRuntime(
          'main = if (5 > 3) "greater" else "lesser"',
        );
        checkResult(runtime, '"greater"');
      });
    });

    group('function composition', () {
      test('main calls nested custom functions', () {
        final RuntimeFacade runtime = getRuntime(
          'add1(x) = x + 1\nadd2(x) = add1(add1(x))\nmain = add2(5)',
        );
        checkResult(runtime, 7);
      });

      test('main calls chain of three custom functions', () {
        final RuntimeFacade runtime = getRuntime(
          'f(x) = x * 2\ng(x) = f(x) + 1\nh(x) = g(x) * 3\nmain = h(5)',
        );
        checkResult(runtime, 33);
      });

      test('main calls recursive helper function', () {
        final RuntimeFacade runtime = getRuntime(
          'factorial(n) = if (n <= 1) 1 else n * factorial(n - 1)\nmain = factorial(5)',
        );
        checkResult(runtime, 120);
      });

      test('main uses mutually recursive functions', () {
        final RuntimeFacade runtime = getRuntime(
          'isEven(n) = if (n == 0) true else isOdd(n - 1)\nisOdd(n) = if (n == 0) false else isEven(n - 1)\nmain = isEven(10)',
        );
        checkResult(runtime, true);
      });
    });

    group('standard library integration', () {
      test('main calls standard library function directly', () {
        final RuntimeFacade runtime = getRuntime('main = num.add(10, 20)');
        checkResult(runtime, 30);
      });

      test('main uses string concatenation via standard library', () {
        final RuntimeFacade runtime = getRuntime(
          'main = str.concat("hello", " world")',
        );
        checkResult(runtime, '"hello world"');
      });

      test('main uses list operations', () {
        final RuntimeFacade runtime = getRuntime(
          'main = list.length([1, 2, 3])',
        );
        checkResult(runtime, 3);
      });
    });

    group('argument handling', () {
      test('main with empty arguments list passed explicitly', () {
        final RuntimeFacade runtime = getRuntime('main = 42');
        expect(runtime.executeMain([]), '42');
      });

      test('main with null arguments defaults to empty list', () {
        final RuntimeFacade runtime = getRuntime('main = 42');
        expect(runtime.executeMain(null), '42');
      });

      test('main argument is used in computation', () {
        final RuntimeFacade runtime = getRuntime(
          'main(x) = to.number(x) * 2',
        );
        expect(runtime.executeMain(['21']), '42');
      });

      test('main arguments preserve order', () {
        final RuntimeFacade runtime = getRuntime(
          'main(a, b, c) = [a, b, c]',
        );
        expect(runtime.executeMain(['x', 'y', 'z']), '["x", "y", "z"]');
      });

      test('main with argument containing spaces', () {
        final RuntimeFacade runtime = getRuntime('main(a) = a');
        expect(runtime.executeMain(['hello world']), '"hello world"');
      });
    });

    group('edge cases', () {
      test('main returns zero', () {
        final RuntimeFacade runtime = getRuntime('main = 0');
        checkResult(runtime, 0);
      });

      test('main with single element list', () {
        final RuntimeFacade runtime = getRuntime('main = [42]');
        checkResult(runtime, '[42]');
      });

      test('main with mixed type list', () {
        final RuntimeFacade runtime = getRuntime('main = [1, "two", true]');
        checkResult(runtime, '[1, "two", true]');
      });

      test('main computes expression inline', () {
        final RuntimeFacade runtime = getRuntime('main = 2 + 3 * 4');
        checkResult(runtime, 14);
      });

      test('main with large number', () {
        final RuntimeFacade runtime = getRuntime('main = 9999999999');
        checkResult(runtime, 9999999999);
      });
    });
  });
}
