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

    test('recursion with zero iterations returns base case immediately', () {
      final RuntimeFacade runtime = getRuntime('''
countdown(n) = if (n <= 0) "done" else countdown(n - 1)
main = countdown(0)
''');
      checkResult(runtime, '"done"');
    });

    test('recursion with single iteration', () {
      final RuntimeFacade runtime = getRuntime('''
countdown(n) = if (n <= 0) 0 else countdown(n - 1)
main = countdown(1)
''');
      checkResult(runtime, 0);
    });

    test('recursion with floating-point accumulator', () {
      final RuntimeFacade runtime = getRuntime('''
sumHalves(n, accumulator) = if (n <= 0) accumulator else sumHalves(n - 1, accumulator + 0.5)
main = sumHalves(4, 0.0)
''');
      checkResult(runtime, 2.0);
    });

    test('recursion with boolean result accumulation', () {
      final RuntimeFacade runtime = getRuntime('''
allTrue(n) = if (n <= 0) true else (n > 0) && allTrue(n - 1)
main = allTrue(5)
''');
      checkResult(runtime, true);
    });

    test('recursion building a list', () {
      final RuntimeFacade runtime = getRuntime('''
buildList(n) = if (n <= 0) [] else list.insertStart(buildList(n - 1), n)
main = buildList(3)
''');
      checkResult(runtime, [3, 2, 1]);
    });

    test('recursion at depth 997 succeeds', () {
      final RuntimeFacade runtime = getRuntime('''
countdown(n) = if (n <= 0) 0 else countdown(n - 1)
main = countdown(997)
''');
      checkResult(runtime, 0);
    });

    test('recursion at depth exactly at limit throws RecursionLimitError', () {
      final RuntimeFacade runtime = getRuntime('''
countdown(n) = if (n <= 0) 0 else countdown(n - 1)
main = countdown(1000)
''');
      expect(runtime.executeMain, throwsA(isA<RecursionLimitError>()));
    });

    test('mutual recursion hitting limit throws RecursionLimitError', () {
      final RuntimeFacade runtime = getRuntime('''
ping(n) = pong(n)
pong(n) = ping(n)
main = ping(1)
''');
      expect(runtime.executeMain, throwsA(isA<RecursionLimitError>()));
    });

    test('three-way mutual recursion hitting limit', () {
      final RuntimeFacade runtime = getRuntime('''
funcA(n) = funcB(n)
funcB(n) = funcC(n)
funcC(n) = funcA(n)
main = funcA(1)
''');
      expect(runtime.executeMain, throwsA(isA<RecursionLimitError>()));
    });

    test('recursion with map building', () {
      final RuntimeFacade runtime = getRuntime('''
buildMap(n, accumulator) = if (n <= 0) accumulator else buildMap(n - 1, map.set(accumulator, to.string(n), n))
main = buildMap(3, {})
''');
      checkResult(runtime, '{"3": 3, "2": 2, "1": 1}');
    });

    test('recursion summing list elements', () {
      final RuntimeFacade runtime = getRuntime('''
sumList(items) = if (list.isEmpty(items)) 0 else list.first(items) + sumList(list.rest(items))
main = sumList([1, 2, 3, 4, 5])
''');
      checkResult(runtime, 15);
    });

    test('recursion with empty list returns zero', () {
      final RuntimeFacade runtime = getRuntime('''
sumList(items) = if (list.isEmpty(items)) 0 else list.first(items) + sumList(list.rest(items))
main = sumList([])
''');
      checkResult(runtime, 0);
    });

    test('recursion with single element list', () {
      final RuntimeFacade runtime = getRuntime('''
sumList(items) = if (list.isEmpty(items)) 0 else list.first(items) + sumList(list.rest(items))
main = sumList([42])
''');
      checkResult(runtime, 42);
    });

    test('recursion returning list of lists', () {
      final RuntimeFacade runtime = getRuntime('''
nest(n) = if (n <= 0) [] else list.insertStart(nest(n - 1), [n])
main = nest(3)
''');
      checkResult(runtime, [
        [3],
        [2],
        [1],
      ]);
    });

    test('recursive power function', () {
      final RuntimeFacade runtime = getRuntime('''
power(base, exponent) = if (exponent <= 0) 1 else base * power(base, exponent - 1)
main = power(2, 10)
''');
      checkResult(runtime, 1024);
    });

    test('recursion with negative starting value', () {
      final RuntimeFacade runtime = getRuntime('''
countToZero(n) = if (n >= 0) n else countToZero(n + 1)
main = countToZero(-5)
''');
      checkResult(runtime, 0);
    });

    test('recursion with string building', () {
      final RuntimeFacade runtime = getRuntime('''
buildString(n, accumulator) = if (n <= 0) accumulator else buildString(n - 1, str.concat(accumulator, to.string(n)))
main = buildString(5, "")
''');
      checkResult(runtime, '"54321"');
    });

    test('recursion with conditional accumulator update', () {
      final RuntimeFacade runtime = getRuntime('''
sumEvens(n, accumulator) = if (n <= 0) accumulator else sumEvens(n - 1, if (n % 2 == 0) accumulator + n else accumulator)
main = sumEvens(10, 0)
''');
      checkResult(runtime, 30);
    });

    test('recursive find in list', () {
      final RuntimeFacade runtime = getRuntime('''
contains(items, target) = if (list.isEmpty(items)) false else if (list.first(items) == target) true else contains(list.rest(items), target)
main = contains([1, 2, 3, 4, 5], 3)
''');
      checkResult(runtime, true);
    });

    test('recursive find not in list', () {
      final RuntimeFacade runtime = getRuntime('''
contains(items, target) = if (list.isEmpty(items)) false else if (list.first(items) == target) true else contains(list.rest(items), target)
main = contains([1, 2, 3, 4, 5], 10)
''');
      checkResult(runtime, false);
    });

    test('recursion with list reversal', () {
      final RuntimeFacade runtime = getRuntime('''
reverseHelper(items, accumulator) = if (list.isEmpty(items)) accumulator else reverseHelper(list.rest(items), list.insertStart(accumulator, list.first(items)))
reverse(items) = reverseHelper(items, [])
main = reverse([1, 2, 3])
''');
      checkResult(runtime, [3, 2, 1]);
    });

    test('recursion with maximum depth tracking', () {
      final RuntimeFacade runtime = getRuntime('''
countDepth(n, maxDepth) = if (n <= 0) maxDepth else countDepth(n - 1, maxDepth + 1)
main = countDepth(100, 0)
''');
      checkResult(runtime, 100);
    });

    test('mutual recursion with value transformation', () {
      final RuntimeFacade runtime = getRuntime('''
increment(n) = if (n >= 10) n else decrement(n + 2)
decrement(n) = if (n <= 0) 0 else increment(n - 1)
main = increment(0)
''');
      checkResult(runtime, 10);
    });

    test('recursion combining multiple data types', () {
      final RuntimeFacade runtime = getRuntime('''
process(n, text, items) = if (n <= 0) [text, items] else process(n - 1, str.concat(text, "x"), list.insertEnd(items, n))
main = process(3, "", [])
''');
      checkResult(runtime, [
        '"xxx"',
        [3, 2, 1],
      ]);
    });
  });

  group('Try/Catch Edge Cases', () {
    test('try with empty string as fallback', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(1 / 0, "")',
      );
      checkResult(runtime, '""');
    });

    test('try with empty list as fallback', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(1 / 0, [])',
      );
      checkResult(runtime, []);
    });

    test('try with empty map as fallback', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(1 / 0, {})',
      );
      checkResult(runtime, '{}');
    });

    test('try with zero as fallback', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(1 / 0, 0)',
      );
      checkResult(runtime, 0);
    });

    test('try with false as fallback', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(1 / 0, false)',
      );
      checkResult(runtime, false);
    });

    test('try with true as fallback', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(1 / 0, true)',
      );
      checkResult(runtime, true);
    });

    test('try catching deeply nested recursive error', () {
      final RuntimeFacade runtime = getRuntime('''
level3(n) = level3(n)
level2(n) = level3(n)
level1(n) = level2(n)
main = try(level1(1), "caught deep recursion")
''');
      checkResult(runtime, '"caught deep recursion"');
    });

    test('try with mutual recursion error', () {
      final RuntimeFacade runtime = getRuntime('''
ping(n) = pong(n)
pong(n) = ping(n)
main = try(ping(1), "mutual recursion caught")
''');
      checkResult(runtime, '"mutual recursion caught"');
    });

    test('try catches error in recursive function before limit', () {
      final RuntimeFacade runtime = getRuntime('''
failAt(n, target) = if (n == target) error.throw(0, "reached target") else failAt(n + 1, target)
main = try(failAt(0, 5), "caught before limit")
''');
      checkResult(runtime, '"caught before limit"');
    });

    test('try with recursive fallback that succeeds', () {
      final RuntimeFacade runtime = getRuntime('''
sum(n) = if (n <= 0) 0 else n + sum(n - 1)
main = try(1 / 0, sum(5))
''');
      checkResult(runtime, 15);
    });

    test('try with negative number as fallback', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(1 / 0, -999)',
      );
      checkResult(runtime, -999);
    });

    test('try with floating point as fallback', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(1 / 0, 3.14159)',
      );
      checkResult(runtime, 3.14159);
    });

    test('try with list containing error value as fallback', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(1 / 0, ["error", -1])',
      );
      checkResult(runtime, ['"error"', -1]);
    });

    test('try with map containing error info as fallback', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(1 / 0, {"status": "error", "code": -1})',
      );
      checkResult(runtime, '{"status": "error", "code": -1}');
    });

    test('try catches IndexOutOfBoundsError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(list.at([1, 2, 3], 100), "out of bounds")',
      );
      checkResult(runtime, '"out of bounds"');
    });

    test('try catches NegativeIndexError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(list.at([1, 2, 3], -5), "negative index")',
      );
      checkResult(runtime, '"negative index"');
    });

    test('try catches EmptyCollectionError from stack.pop', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(stack.pop(stack.new([])), "empty stack")',
      );
      checkResult(runtime, '"empty stack"');
    });

    test('try catches DivisionByZeroError from modulo', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(num.mod(10, 0), "modulo by zero")',
      );
      checkResult(runtime, '"modulo by zero"');
    });

    test('try catches InvalidNumericOperationError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(num.sqrt(-4), "invalid sqrt")',
      );
      checkResult(runtime, '"invalid sqrt"');
    });

    test('try with triple nested try', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(try(try(1 / 0, error.throw(0, "inner")), error.throw(0, "middle")), "outer")',
      );
      checkResult(runtime, '"outer"');
    });

    test('try with triple nested try where inner succeeds', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(try(try(42, 0), 0), 0)',
      );
      checkResult(runtime, 42);
    });

    test('try catches ParseError from to.number', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(to.number("not a number"), 0)',
      );
      checkResult(runtime, 0);
    });

    test('try with recursion in primary that succeeds', () {
      final RuntimeFacade runtime = getRuntime('''
fib(n) = if (n <= 1) n else fib(n - 1) + fib(n - 2)
main = try(fib(8), -1)
''');
      checkResult(runtime, 21);
    });

    test('try does not catch when primary succeeds with zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(0, 999)',
      );
      checkResult(runtime, 0);
    });

    test('try does not catch when primary succeeds with empty string', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try("", "fallback")',
      );
      checkResult(runtime, '""');
    });

    test('try does not catch when primary succeeds with empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try([], [1, 2, 3])',
      );
      checkResult(runtime, []);
    });

    test('try does not catch when primary succeeds with false', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(false, true)',
      );
      checkResult(runtime, false);
    });
  });

  group('Recursion Error Recovery', () {
    test('depth resets after RecursionLimitError in try', () {
      final RuntimeFacade runtime = getRuntime('''
infinite(n) = infinite(n)
countdown(n) = if (n <= 0) 0 else countdown(n - 1)
main = countdown(try(infinite(1), 10))
''');
      checkResult(runtime, 0);
    });

    test('multiple recursive calls in sequence', () {
      final RuntimeFacade runtime = getRuntime('''
sum(n) = if (n <= 0) 0 else n + sum(n - 1)
main = sum(10) + sum(10) + sum(10)
''');
      checkResult(runtime, 165);
    });

    test(
      'recursive function called with result of another recursive function',
      () {
        final RuntimeFacade runtime = getRuntime('''
factorial(n) = if (n <= 1) 1 else n * factorial(n - 1)
fib(n) = if (n <= 1) n else fib(n - 1) + fib(n - 2)
main = factorial(fib(5))
''');
        checkResult(runtime, 120);
      },
    );

    test('try catches error then recursive function succeeds', () {
      final RuntimeFacade runtime = getRuntime('''
sum(n) = if (n <= 0) 0 else n + sum(n - 1)
main = try(1 / 0, 0) + sum(5)
''');
      checkResult(runtime, 15);
    });

    test('recursion in both branches of conditional', () {
      final RuntimeFacade runtime = getRuntime('''
process(n, flag) = if (n <= 0) 0 else if (flag) process(n - 1, false) + 1 else process(n - 1, true) + 2
main = process(4, true)
''');
      checkResult(runtime, 6);
    });

    test('recursive function with error handling inside', () {
      final RuntimeFacade runtime = getRuntime('''
safeFirst(items) = try(list.first(items), -1)
countValid(items) = if (list.isEmpty(items)) 0 else (if (safeFirst(items) >= 0) 1 else 0) + countValid(list.rest(items))
main = countValid([1, 2, 3])
''');
      checkResult(runtime, 3);
    });
  });
}
