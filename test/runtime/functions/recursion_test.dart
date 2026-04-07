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

    test('try catches negative index error', () {
      final RuntimeFacade runtime = getRuntime('main = try([1, 2][-1], 99)');
      checkResult(runtime, 99);
    });

    test('try catches custom error.throw', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(error.throw(404, "not found"), "caught")',
      );
      checkResult(runtime, '"caught"');
    });

    test('try catches JSON parse error', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(json.decode("invalid"), "fallback")',
      );
      checkResult(runtime, '"fallback"');
    });

    test('try with nested try - inner catches error', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(try(1 / 0, 10) + 5, -1)',
      );
      checkResult(runtime, 15);
    });

    test('try with nested try - outer catches error when inner succeeds', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(try(10, 0) + true, -1)',
      );
      checkResult(runtime, -1);
    });

    test('try evaluates fallback expression only on error', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(10 / 2, 100 * 100)',
      );
      checkResult(runtime, 5.0);
    });

    test('try catches RecursionLimitError', () {
      final RuntimeFacade runtime = getRuntime('''
infinite(x) = infinite(x)
main = try(infinite(1), "caught recursion")
''');
      checkResult(runtime, '"caught recursion"');
    });

    test('try with conditional function that may error', () {
      final RuntimeFacade runtime = getRuntime('''
mayFail(shouldFail) = if (shouldFail) error.throw(0, "fail") else 42
main = try(mayFail(true), -1)
''');
      checkResult(runtime, -1);
    });

    test('try with conditional function that does not error', () {
      final RuntimeFacade runtime = getRuntime('''
mayFail(shouldFail) = if (shouldFail) error.throw(0, "fail") else 42
main = try(mayFail(false), -1)
''');
      checkResult(runtime, 42);
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

    test('fibonacci recursion (double recursive calls)', () {
      final RuntimeFacade runtime = getRuntime('''
fib(n) = if (n <= 1) n else fib(n - 1) + fib(n - 2)
main = fib(10)
''');
      checkResult(runtime, 55);
    });

    test('recursion with multiple parameters', () {
      final RuntimeFacade runtime = getRuntime('''
gcd(a, b) = if (b == 0) a else gcd(b, num.mod(a, b))
main = gcd(48, 18)
''');
      checkResult(runtime, 6);
    });

    test('recursion with accumulator pattern', () {
      final RuntimeFacade runtime = getRuntime('''
sumAcc(n, acc) = if (n <= 0) acc else sumAcc(n - 1, acc + n)
main = sumAcc(5, 0)
''');
      checkResult(runtime, 15);
    });

    test('tail recursion factorial', () {
      final RuntimeFacade runtime = getRuntime('''
factAcc(n, acc) = if (n <= 1) acc else factAcc(n - 1, n * acc)
factorial(n) = factAcc(n, 1)
main = factorial(5)
''');
      checkResult(runtime, 120);
    });

    test('mutual recursion with three functions', () {
      final RuntimeFacade runtime = getRuntime('''
a(n) = if (n <= 0) "a" else b(n - 1)
b(n) = if (n <= 0) "b" else c(n - 1)
c(n) = if (n <= 0) "c" else a(n - 1)
main = a(5)
''');
      checkResult(runtime, '"c"');
    });

    test('recursion in then branch', () {
      final RuntimeFacade runtime = getRuntime('''
countUp(n, limit) = if (n >= limit) n else countUp(n + 1, limit)
main = countUp(0, 5)
''');
      checkResult(runtime, 5);
    });

    test('recursion with list processing', () {
      final RuntimeFacade runtime = getRuntime('''
length(lst) = if (list.isEmpty(lst)) 0 else 1 + length(list.rest(lst))
main = length([1, 2, 3, 4, 5])
''');
      checkResult(runtime, 5);
    });

    test('nested recursion (A calls B which calls A)', () {
      final RuntimeFacade runtime = getRuntime('''
outer(n) = if (n <= 0) 0 else inner(n)
inner(n) = outer(n - 1) + 1
main = outer(3)
''');
      checkResult(runtime, 3);
    });

    test('recursion at depth 998 succeeds', () {
      final RuntimeFacade runtime = getRuntime('''
countdown(n) = if (n <= 0) 0 else countdown(n - 1)
main = countdown(998)
''');
      checkResult(runtime, 0);
    });

    test('recursion exceeding limit throws RecursionLimitError', () {
      final RuntimeFacade runtime = getRuntime('''
countdown(n) = if (n <= 0) 0 else countdown(n - 1)
main = countdown(1001)
''');
      expect(runtime.executeMain, throwsA(isA<RecursionLimitError>()));
    });

    test('RecursionLimitError message contains the limit value', () {
      final RuntimeFacade runtime = getRuntime('''
infinite(x) = infinite(x)
main = infinite(1)
''');
      expect(
        runtime.executeMain,
        throwsA(
          isA<RecursionLimitError>().having(
            (RecursionLimitError error) => error.toString(),
            'message',
            allOf(contains('1000'), contains('recursion')),
          ),
        ),
      );
    });

    test('recursion with string concatenation', () {
      final RuntimeFacade runtime = getRuntime('''
repeat(s, n) = if (n <= 0) "" else s + repeat(s, n - 1)
main = repeat("ab", 3)
''');
      checkResult(runtime, '"ababab"');
    });

    test('recursion returning different types based on depth', () {
      final RuntimeFacade runtime = getRuntime('''
mixed(n) = if (n <= 0) 0 else if (n == 1) true else mixed(n - 1)
main = mixed(5)
''');
      checkResult(runtime, true);
    });

    test('mutual recursion returns false for isOdd(0)', () {
      final RuntimeFacade runtime = getRuntime('''
isEven(n) = if (n == 0) true else isOdd(n - 1)
isOdd(n) = if (n == 0) false else isEven(n - 1)
main = isOdd(0)
''');
      checkResult(runtime, false);
    });

    test('mutual recursion returns true for isEven(0)', () {
      final RuntimeFacade runtime = getRuntime('''
isEven(n) = if (n == 0) true else isOdd(n - 1)
isOdd(n) = if (n == 0) false else isEven(n - 1)
main = isEven(0)
''');
      checkResult(runtime, true);
    });
  });
}
