@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:primal/compiler/syntactic/expression.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Try/Catch Advanced', () {
    test('try catches empty list first', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(list.first([]), -1)',
      );
      checkResult(runtime, -1);
    });

    test('try catches missing map key', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(map.at({}, "x"), "default")',
      );
      checkResult(runtime, '"default"');
    });

    test('try catches type mismatch', () {
      final RuntimeFacade runtime = getRuntime('main = try(5 + true, 0)');
      checkResult(runtime, 0);
    });

    test('try catches out of bounds', () {
      final RuntimeFacade runtime = getRuntime('main = try([1, 2][5], -1)');
      checkResult(runtime, -1);
    });

    test('try returns value when no error', () {
      final RuntimeFacade runtime = getRuntime('main = try(1 + 2, 42)');
      checkResult(runtime, 3);
    });
  });

  group('Recursion', () {
    test('direct recursion countdown', () {
      final RuntimeFacade runtime = getRuntime('''
countdown(n) = if (n <= 0) 0 else countdown(n - 1)
main = countdown(5)
''');
      checkResult(runtime, 0);
    });

    test('recursive sum', () {
      final RuntimeFacade runtime = getRuntime('''
sum(n) = if (n <= 0) 0 else n + sum(n - 1)
main = sum(5)
''');
      checkResult(runtime, 15);
    });

    test('mutual recursion', () {
      final RuntimeFacade runtime = getRuntime('''
isEven(n) = if (n == 0) true else isOdd(n - 1)
isOdd(n) = if (n == 0) false else isEven(n - 1)
main = isEven(4)
''');
      checkResult(runtime, true);
    });

    test('mutual recursion odd', () {
      final RuntimeFacade runtime = getRuntime('''
isEven(n) = if (n == 0) true else isOdd(n - 1)
isOdd(n) = if (n == 0) false else isEven(n - 1)
main = isOdd(5)
''');
      checkResult(runtime, true);
    });

    test('throws RecursionLimitError for infinite recursion', () {
      final RuntimeFacade runtime = getRuntime('''
infinite(x) = infinite(x)
main = infinite(1)
''');
      expect(
        runtime.executeMain,
        throwsA(
          isA<RecursionLimitError>().having(
            (e) => e.toString(),
            'message',
            contains('1000'),
          ),
        ),
      );
    });

    test('deep recursion within limit succeeds', () {
      final RuntimeFacade runtime = getRuntime('''
countdown(n) = if (n <= 0) 0 else countdown(n - 1)
main = countdown(500)
''');
      checkResult(runtime, 0);
    });

    test('subsequent evaluation works after RecursionLimitError', () {
      final RuntimeFacade runtime = getRuntime('''
infinite(x) = infinite(x)
safe(x) = x + 1
main = infinite(1)
''');

      // First call triggers RecursionLimitError
      expect(runtime.executeMain, throwsA(isA<RecursionLimitError>()));

      // Subsequent evaluation should work correctly (depth reset)
      final Expression safeCall = getExpression('safe(41)');
      final String result = runtime.evaluate(safeCall);
      expect(result, equals('42'));
    });

    test('sequential evaluations each start at depth 0', () {
      final RuntimeFacade runtime = getRuntime('''
countdown(n) = if (n <= 0) 0 else countdown(n - 1)
main = countdown(500)
''');

      // First evaluation uses ~500 depth
      checkResult(runtime, 0);

      // Second evaluation should also succeed, proving depth was reset
      final Expression secondCall = getExpression('countdown(500)');
      final String result = runtime.evaluate(secondCall);
      expect(result, equals('0'));

      // Third evaluation at higher depth still within limit
      final Expression thirdCall = getExpression('countdown(800)');
      final String thirdResult = runtime.evaluate(thirdCall);
      expect(thirdResult, equals('0'));
    });
  });
}
