@Tags(['runtime'])
library;

import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';
import '../../helpers/resource_helpers.dart';

void main() {
  group('Samples', () {
    test('balanced_parenthesis', () {
      final Runtime runtime = getRuntime(
        loadFile('web_samples/balanced_parentheses.prm'),
      );
      checkResult(runtime, true);
    });

    test('binary_search', () {
      final Runtime runtime = getRuntime(
        loadFile('web_samples/binary_search.prm'),
      );
      checkResult(runtime, false);
    });

    test('divisors', () {
      final Runtime runtime = getRuntime(loadFile('web_samples/divisors.prm'));
      checkResult(runtime, [1, 2, 5, 10]);
    });

    test('factorial', () {
      final Runtime runtime = getRuntime(loadFile('web_samples/factorial.prm'));
      checkResult(runtime, 120);
    });

    test('fibonacci', () {
      final Runtime runtime = getRuntime(loadFile('web_samples/fibonacci.prm'));
      checkResult(runtime, [1, 1, 2, 3, 5, 8, 13, 21, 34, 55]);
    });

    test('find_max', () {
      final Runtime runtime = getRuntime(loadFile('web_samples/find_max.prm'));
      checkResult(runtime, 9);
    });

    test('frequency', () {
      final Runtime runtime = getRuntime(loadFile('web_samples/frequency.prm'));
      checkResult(runtime, {1: 2, 2: 4, 3: 1, 4: 1, 5: 2});
    });

    test('moving_averages', () {
      final Runtime runtime = getRuntime(
        loadFile('web_samples/moving_averages.prm'),
      );
      checkResult(runtime, [55, 41, 67, 58, 66, 58, 54, 34]);
    });

    test('is_palindrome', () {
      final Runtime runtime = getRuntime(
        loadFile('web_samples/is_palindrome.prm'),
      );
      checkResult(runtime, true);
    });

    test('power', () {
      final Runtime runtime = getRuntime(loadFile('web_samples/power.prm'));
      checkResult(runtime, 1024);
    });

    test('is_prime', () {
      final Runtime runtime = getRuntime(loadFile('web_samples/is_prime.prm'));
      checkResult(runtime, true);
    });

    test('reverse_list', () {
      final Runtime runtime = getRuntime(
        loadFile('web_samples/reverse_list.prm'),
      );
      checkResult(runtime, [5, 4, 3, 2, 1]);
    });

    test('sum_of_digits', () {
      final Runtime runtime = getRuntime(
        loadFile('web_samples/sum_of_digits.prm'),
      );
      checkResult(runtime, 45);
    });

    test('to_binary', () {
      final Runtime runtime = getRuntime(loadFile('web_samples/to_binary.prm'));
      checkResult(runtime, '"1010"');
    });

    test('flatten', () {
      final Runtime runtime = getRuntime(
        loadFile('web_samples/flatten.prm'),
      );
      checkResult(runtime, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
    });

    test('gcd_lcm', () {
      final Runtime runtime = getRuntime(loadFile('web_samples/gcd_lcm.prm'));
      checkResult(runtime, [6, 144.0]);
    });

    test('matrix_multiply', () {
      final Runtime runtime = getRuntime(
        loadFile('web_samples/matrix_multiply.prm'),
      );
      checkResult(runtime, [
        [19, 22],
        [43, 50],
      ]);
    });

    test('pi_estimate', () {
      final Runtime runtime = getRuntime(
        loadFile('web_samples/pi_estimate.prm'),
      );
      checkResult(runtime, 3.0418396189294032);
    });

    test('quicksort', () {
      final Runtime runtime = getRuntime(
        loadFile('web_samples/quicksort.prm'),
      );
      checkResult(runtime, [3, 9, 27, 38, 43]);
    });

    test('to_roman_numerals', () {
      final Runtime runtime = getRuntime(
        loadFile('web_samples/to_roman_numerals.prm'),
      );
      checkResult(runtime, '"MCMLXXXIV"');
    });
  });
}
