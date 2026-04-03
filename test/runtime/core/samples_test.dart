@Tags(['runtime'])
library;

import 'package:primal/compiler/library/error/throw.dart';
import 'package:primal/compiler/semantic/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';
import '../../helpers/resource_helpers.dart';

void main() {
  group('Samples', () {
    test('balanced_parenthesis', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/balanced_parentheses.prm'),
      );
      checkResult(runtime, true);
    });

    test('binary_search', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/binary_search.prm'),
      );
      checkResult(runtime, false);
    });

    test('divisors', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/divisors.prm'),
      );
      checkResult(runtime, [1, 2, 5, 10]);
    });

    test('factorial', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/factorial.prm'),
      );
      checkResult(runtime, 120);
    });

    test('fibonacci', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/fibonacci.prm'),
      );
      checkResult(runtime, [1, 1, 2, 3, 5, 8, 13, 21, 34, 55]);
    });

    test('find_max', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/find_max.prm'),
      );
      checkResult(runtime, 9);
    });

    test('frequency', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/frequency.prm'),
      );
      checkResult(runtime, {1: 2, 2: 4, 3: 1, 4: 1, 5: 2});
    });

    test('moving_averages', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/moving_averages.prm'),
      );
      checkResult(runtime, [55, 41, 67, 58, 66, 58, 54, 34]);
    });

    test('is_palindrome', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/is_palindrome.prm'),
      );
      checkResult(runtime, true);
    });

    test('power', () {
      final RuntimeFacade runtime = getRuntime(loadFile('samples/power.prm'));
      checkResult(runtime, 1024);
    });

    test('is_prime', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/is_prime.prm'),
      );
      checkResult(runtime, true);
    });

    test('reverse_list', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/reverse_list.prm'),
      );
      checkResult(runtime, [5, 4, 3, 2, 1]);
    });

    test('sum_of_digits', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/sum_of_digits.prm'),
      );
      checkResult(runtime, 45);
    });

    test('to_binary', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/to_binary.prm'),
      );
      checkResult(runtime, '"1010"');
    });

    test('flatten', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/flatten.prm'),
      );
      checkResult(runtime, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
    });

    test('gcd_lcm', () {
      final RuntimeFacade runtime = getRuntime(loadFile('samples/gcd_lcm.prm'));
      checkResult(runtime, [6, 144.0]);
    });

    test('matrix_multiply', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/matrix_multiply.prm'),
      );
      checkResult(runtime, [
        [19, 22],
        [43, 50],
      ]);
    });

    test('pi_estimate', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/pi_estimate.prm'),
      );
      checkResult(runtime, 3.0418396189294032);
    });

    test('quicksort', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/quicksort.prm'),
      );
      checkResult(runtime, [3, 9, 27, 38, 43]);
    });

    test('to_roman_numerals', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/to_roman_numerals.prm'),
      );
      checkResult(runtime, '"MCMLXXXIV"');
    });
  });

  group('Sample Error Cases', () {
    test('factorial with negative input throws CustomError', () {
      final RuntimeFacade runtime = getRuntime(
        'factorial(n) = if (n < 0) error.throw(0, "Cannot calculate factorial of a negative number") else if (n == 0) 1 else n * factorial(n - 1)\nmain = factorial(-1)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<CustomError>().having(
            (e) => e.toString(),
            'message',
            contains('negative'),
          ),
        ),
      );
    });

    test('fibonacci with negative input throws CustomError', () {
      final RuntimeFacade runtime = getRuntime(
        'fibonacci(n) = if (n < 0) error.throw(-1, "Cannot calculate Fibonacci with a negative number") else if (n == 0) [] else fibonacci(n - 1) + fibonacci.helper(n)\nfibonacci.helper(n) = if ((n == 1) | (n == 2)) 1 else fibonacci.helper(n - 1) + fibonacci.helper(n - 2)\nmain = fibonacci(-1)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<CustomError>().having(
            (e) => e.toString(),
            'message',
            contains('negative'),
          ),
        ),
      );
    });

    test('findMax with empty list throws CustomError', () {
      final RuntimeFacade runtime = getRuntime(
        'findMax(list) = if (list.isEmpty(list)) error.throw(-1, "Cannot find max number in an empty list") else list.reduce(list.rest(list), list.first(list), num.max)\nmain = findMax([])',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<CustomError>().having(
            (e) => e.toString(),
            'message',
            contains('empty'),
          ),
        ),
      );
    });

    test('power with negative exponent throws CustomError', () {
      final RuntimeFacade runtime = getRuntime(
        'power(base, exp) = if (exp < 0) error.throw(0, "Cannot calculate power with a negative exponent") else if (exp == 0) 1 else base * power(base, exp - 1)\nmain = power(2, -1)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<CustomError>().having(
            (e) => e.toString(),
            'message',
            contains('negative'),
          ),
        ),
      );
    });

    test('sumOfDigits with negative input throws CustomError', () {
      final RuntimeFacade runtime = getRuntime(
        'sumOfDigits(n) = if (n < 0) error.throw(0, "Cannot calculate sum of digits of a negative number") else if (n == 0) 0 else n % 10 + sumOfDigits(to.integer(n / 10))\nmain = sumOfDigits(-5)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<CustomError>().having(
            (e) => e.toString(),
            'message',
            contains('negative'),
          ),
        ),
      );
    });
  });
}
