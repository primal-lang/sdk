@Tags(['runtime'])
library;

import 'package:primal/compiler/library/error/throw.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
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

    test('balancedParenthesis with invalid character throws CustomError', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/balanced_parentheses.prm').replaceAll(
          'main = balancedParenthesis("((((()()(()))())))")',
          'main = balancedParenthesis("(a)")',
        ),
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<CustomError>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid element'),
          ),
        ),
      );
    });

    test('toRoman with non-positive number throws CustomError', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile(
          'samples/to_roman_numerals.prm',
        ).replaceAll('main = toRoman(1984)', 'main = toRoman(-1)'),
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<CustomError>().having(
            (e) => e.toString(),
            'message',
            contains('non-positive'),
          ),
        ),
      );
    });
  });

  group('Sample Edge Cases', () {
    test('factorial with zero returns 1', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile(
          'samples/factorial.prm',
        ).replaceAll('main = factorial(5)', 'main = factorial(0)'),
      );
      checkResult(runtime, 1);
    });

    test('factorial with one returns 1', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile(
          'samples/factorial.prm',
        ).replaceAll('main = factorial(5)', 'main = factorial(1)'),
      );
      checkResult(runtime, 1);
    });

    test('fibonacci with zero returns empty list', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile(
          'samples/fibonacci.prm',
        ).replaceAll('main = fibonacci(10)', 'main = fibonacci(0)'),
      );
      checkResult(runtime, []);
    });

    test('fibonacci with one returns single element list', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile(
          'samples/fibonacci.prm',
        ).replaceAll('main = fibonacci(10)', 'main = fibonacci(1)'),
      );
      checkResult(runtime, [1]);
    });

    test('fibonacci with two returns first two elements', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile(
          'samples/fibonacci.prm',
        ).replaceAll('main = fibonacci(10)', 'main = fibonacci(2)'),
      );
      checkResult(runtime, [1, 1]);
    });

    test('isPrime with zero returns false', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile(
          'samples/is_prime.prm',
        ).replaceAll('main = isPrime(97)', 'main = isPrime(0)'),
      );
      checkResult(runtime, false);
    });

    test('isPrime with one returns false', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile(
          'samples/is_prime.prm',
        ).replaceAll('main = isPrime(97)', 'main = isPrime(1)'),
      );
      checkResult(runtime, false);
    });

    test('isPrime with two returns true', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile(
          'samples/is_prime.prm',
        ).replaceAll('main = isPrime(97)', 'main = isPrime(2)'),
      );
      checkResult(runtime, true);
    });

    test('isPrime with negative returns false', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile(
          'samples/is_prime.prm',
        ).replaceAll('main = isPrime(97)', 'main = isPrime(-5)'),
      );
      checkResult(runtime, false);
    });

    test('isPrime with composite even number returns false', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile(
          'samples/is_prime.prm',
        ).replaceAll('main = isPrime(97)', 'main = isPrime(4)'),
      );
      checkResult(runtime, false);
    });

    test('isPrime with composite odd number returns false', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile(
          'samples/is_prime.prm',
        ).replaceAll('main = isPrime(97)', 'main = isPrime(9)'),
      );
      checkResult(runtime, false);
    });

    test('reverseList with empty list returns empty list', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/reverse_list.prm').replaceAll(
          'main = reverseList([1, 2, 3, 4, 5])',
          'main = reverseList([])',
        ),
      );
      checkResult(runtime, []);
    });

    test('reverseList with single element returns same element', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/reverse_list.prm').replaceAll(
          'main = reverseList([1, 2, 3, 4, 5])',
          'main = reverseList([42])',
        ),
      );
      checkResult(runtime, [42]);
    });

    test('toBinary with zero returns zero string', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile(
          'samples/to_binary.prm',
        ).replaceAll('main = toBinary(10)', 'main = toBinary(0)'),
      );
      checkResult(runtime, '"0"');
    });

    test('toBinary with one returns one string', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile(
          'samples/to_binary.prm',
        ).replaceAll('main = toBinary(10)', 'main = toBinary(1)'),
      );
      checkResult(runtime, '"1"');
    });

    test('toBinary with power of two', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile(
          'samples/to_binary.prm',
        ).replaceAll('main = toBinary(10)', 'main = toBinary(8)'),
      );
      checkResult(runtime, '"1000"');
    });

    test('quicksort with empty list returns empty list', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/quicksort.prm').replaceAll(
          'main = quicksort([38, 27, 43, 3, 9])',
          'main = quicksort([])',
        ),
      );
      checkResult(runtime, []);
    });

    test('quicksort with single element returns same element', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/quicksort.prm').replaceAll(
          'main = quicksort([38, 27, 43, 3, 9])',
          'main = quicksort([5])',
        ),
      );
      checkResult(runtime, [5]);
    });

    test('quicksort with already sorted list returns same list', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/quicksort.prm').replaceAll(
          'main = quicksort([38, 27, 43, 3, 9])',
          'main = quicksort([1, 2, 3, 4, 5])',
        ),
      );
      checkResult(runtime, [1, 2, 3, 4, 5]);
    });

    test('quicksort with reverse sorted list', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/quicksort.prm').replaceAll(
          'main = quicksort([38, 27, 43, 3, 9])',
          'main = quicksort([5, 4, 3, 2, 1])',
        ),
      );
      checkResult(runtime, [1, 2, 3, 4, 5]);
    });

    test('quicksort with duplicate elements', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/quicksort.prm').replaceAll(
          'main = quicksort([38, 27, 43, 3, 9])',
          'main = quicksort([3, 1, 2, 1, 3])',
        ),
      );
      checkResult(runtime, [1, 1, 2, 3, 3]);
    });

    test('flatten with empty list returns empty list', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/flatten.prm').replaceAll(
          'main = flatten([1, [2, 3], [4, [5, 6], 7], [8, [9, [10]]]])',
          'main = flatten([])',
        ),
      );
      checkResult(runtime, []);
    });

    test('flatten with flat list returns same list', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/flatten.prm').replaceAll(
          'main = flatten([1, [2, 3], [4, [5, 6], 7], [8, [9, [10]]]])',
          'main = flatten([1, 2, 3])',
        ),
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('flatten with nested empty lists', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/flatten.prm').replaceAll(
          'main = flatten([1, [2, 3], [4, [5, 6], 7], [8, [9, [10]]]])',
          'main = flatten([[], [[]]])',
        ),
      );
      checkResult(runtime, []);
    });

    test('binarySearch with element found at beginning', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/binary_search.prm').replaceAll(
          'main = binarySearch([1, 2, 3, 4, 6, 7, 8, 9, 10], 5)',
          'main = binarySearch([1, 2, 3, 4, 5], 1)',
        ),
      );
      checkResult(runtime, true);
    });

    test('binarySearch with element found at end', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/binary_search.prm').replaceAll(
          'main = binarySearch([1, 2, 3, 4, 6, 7, 8, 9, 10], 5)',
          'main = binarySearch([1, 2, 3, 4, 5], 5)',
        ),
      );
      checkResult(runtime, true);
    });

    test('binarySearch with element found in middle', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/binary_search.prm').replaceAll(
          'main = binarySearch([1, 2, 3, 4, 6, 7, 8, 9, 10], 5)',
          'main = binarySearch([1, 2, 3, 4, 5], 3)',
        ),
      );
      checkResult(runtime, true);
    });

    test('binarySearch with empty list returns false', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/binary_search.prm').replaceAll(
          'main = binarySearch([1, 2, 3, 4, 6, 7, 8, 9, 10], 5)',
          'main = binarySearch([], 1)',
        ),
      );
      checkResult(runtime, false);
    });

    test('binarySearch with single element found', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/binary_search.prm').replaceAll(
          'main = binarySearch([1, 2, 3, 4, 6, 7, 8, 9, 10], 5)',
          'main = binarySearch([5], 5)',
        ),
      );
      checkResult(runtime, true);
    });

    test('binarySearch with single element not found', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/binary_search.prm').replaceAll(
          'main = binarySearch([1, 2, 3, 4, 6, 7, 8, 9, 10], 5)',
          'main = binarySearch([5], 3)',
        ),
      );
      checkResult(runtime, false);
    });

    test('isPalindrome with empty string returns true', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile(
          'samples/is_palindrome.prm',
        ).replaceAll('main = isPalindrome("level")', 'main = isPalindrome("")'),
      );
      checkResult(runtime, true);
    });

    test('isPalindrome with single character returns true', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/is_palindrome.prm').replaceAll(
          'main = isPalindrome("level")',
          'main = isPalindrome("a")',
        ),
      );
      checkResult(runtime, true);
    });

    test('isPalindrome with non-palindrome returns false', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/is_palindrome.prm').replaceAll(
          'main = isPalindrome("level")',
          'main = isPalindrome("hello")',
        ),
      );
      checkResult(runtime, false);
    });

    test('isPalindrome with two character palindrome returns true', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/is_palindrome.prm').replaceAll(
          'main = isPalindrome("level")',
          'main = isPalindrome("aa")',
        ),
      );
      checkResult(runtime, true);
    });

    test('isPalindrome with two character non-palindrome returns false', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/is_palindrome.prm').replaceAll(
          'main = isPalindrome("level")',
          'main = isPalindrome("ab")',
        ),
      );
      checkResult(runtime, false);
    });

    test('balancedParenthesis with empty string returns true', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/balanced_parentheses.prm').replaceAll(
          'main = balancedParenthesis("((((()()(()))())))")',
          'main = balancedParenthesis("")',
        ),
      );
      checkResult(runtime, true);
    });

    test('balancedParenthesis with single pair returns true', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/balanced_parentheses.prm').replaceAll(
          'main = balancedParenthesis("((((()()(()))())))")',
          'main = balancedParenthesis("()")',
        ),
      );
      checkResult(runtime, true);
    });

    test('balancedParenthesis with unbalanced opening returns false', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/balanced_parentheses.prm').replaceAll(
          'main = balancedParenthesis("((((()()(()))())))")',
          'main = balancedParenthesis("(()")',
        ),
      );
      checkResult(runtime, false);
    });

    test('balancedParenthesis with unbalanced closing returns false', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/balanced_parentheses.prm').replaceAll(
          'main = balancedParenthesis("((((()()(()))())))")',
          'main = balancedParenthesis("())")',
        ),
      );
      checkResult(runtime, false);
    });

    test('balancedParenthesis with closing first returns false', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/balanced_parentheses.prm').replaceAll(
          'main = balancedParenthesis("((((()()(()))())))")',
          'main = balancedParenthesis(")(")',
        ),
      );
      checkResult(runtime, false);
    });

    test('divisors with one returns only one', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile(
          'samples/divisors.prm',
        ).replaceAll('main = divisors(10)', 'main = divisors(1)'),
      );
      checkResult(runtime, [1]);
    });

    test('divisors with prime number returns one and itself', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile(
          'samples/divisors.prm',
        ).replaceAll('main = divisors(10)', 'main = divisors(7)'),
      );
      checkResult(runtime, [1, 7]);
    });

    test('power with zero exponent returns one', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile(
          'samples/power.prm',
        ).replaceAll('main = power(2, 10)', 'main = power(5, 0)'),
      );
      checkResult(runtime, 1);
    });

    test('power with one exponent returns base', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile(
          'samples/power.prm',
        ).replaceAll('main = power(2, 10)', 'main = power(7, 1)'),
      );
      checkResult(runtime, 7);
    });

    test('power with zero base and positive exponent returns zero', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile(
          'samples/power.prm',
        ).replaceAll('main = power(2, 10)', 'main = power(0, 5)'),
      );
      checkResult(runtime, 0);
    });

    test('sumOfDigits with zero returns zero', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile(
          'samples/sum_of_digits.prm',
        ).replaceAll('main = sumOfDigits(123456789)', 'main = sumOfDigits(0)'),
      );
      checkResult(runtime, 0);
    });

    test('sumOfDigits with single digit returns itself', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile(
          'samples/sum_of_digits.prm',
        ).replaceAll('main = sumOfDigits(123456789)', 'main = sumOfDigits(7)'),
      );
      checkResult(runtime, 7);
    });

    test('movingAverage with window larger than list returns empty', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/moving_averages.prm').replaceAll(
          'main = movingAverage([89, 8, 68, 47, 86, 42, 71, 60, 30, 12], 3)',
          'main = movingAverage([1, 2], 5)',
        ),
      );
      checkResult(runtime, []);
    });

    test(
      'movingAverage with window equal to list length returns single element',
      () {
        final RuntimeFacade runtime = getRuntime(
          loadFile('samples/moving_averages.prm').replaceAll(
            'main = movingAverage([89, 8, 68, 47, 86, 42, 71, 60, 30, 12], 3)',
            'main = movingAverage([10, 20, 30], 3)',
          ),
        );
        checkResult(runtime, [20]);
      },
    );

    test('frequency with empty list returns empty map', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/frequency.prm').replaceAll(
          'main = frequency([1, 2, 2, 3, 1, 4, 5, 2, 2, 5])',
          'main = frequency([])',
        ),
      );
      checkResult(runtime, {});
    });

    test('frequency with all unique elements', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/frequency.prm').replaceAll(
          'main = frequency([1, 2, 2, 3, 1, 4, 5, 2, 2, 5])',
          'main = frequency([1, 2, 3])',
        ),
      );
      checkResult(runtime, {1: 1, 2: 1, 3: 1});
    });

    test('frequency with all same elements', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/frequency.prm').replaceAll(
          'main = frequency([1, 2, 2, 3, 1, 4, 5, 2, 2, 5])',
          'main = frequency([5, 5, 5])',
        ),
      );
      checkResult(runtime, {5: 3});
    });

    test('findMax with single element returns that element', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/find_max.prm').replaceAll(
          'main = findMax([1, 7, -13, 9, 2])',
          'main = findMax([42])',
        ),
      );
      checkResult(runtime, 42);
    });

    test('findMax with all negative numbers', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/find_max.prm').replaceAll(
          'main = findMax([1, 7, -13, 9, 2])',
          'main = findMax([-5, -3, -10, -1])',
        ),
      );
      checkResult(runtime, -1);
    });

    test('findMax with max at beginning', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/find_max.prm').replaceAll(
          'main = findMax([1, 7, -13, 9, 2])',
          'main = findMax([99, 1, 2, 3])',
        ),
      );
      checkResult(runtime, 99);
    });

    test('findMax with max at end', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/find_max.prm').replaceAll(
          'main = findMax([1, 7, -13, 9, 2])',
          'main = findMax([1, 2, 3, 99])',
        ),
      );
      checkResult(runtime, 99);
    });

    test('gcd with same numbers returns that number', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile(
          'samples/gcd_lcm.prm',
        ).replaceAll('main = [gcd(48, 18), lcm(48, 18)]', 'main = gcd(7, 7)'),
      );
      checkResult(runtime, 7);
    });

    test('gcd with one returns one', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile(
          'samples/gcd_lcm.prm',
        ).replaceAll('main = [gcd(48, 18), lcm(48, 18)]', 'main = gcd(1, 15)'),
      );
      checkResult(runtime, 1);
    });

    test('gcd with coprime numbers returns one', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile(
          'samples/gcd_lcm.prm',
        ).replaceAll('main = [gcd(48, 18), lcm(48, 18)]', 'main = gcd(7, 11)'),
      );
      checkResult(runtime, 1);
    });

    test('lcm with same numbers returns that number', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile(
          'samples/gcd_lcm.prm',
        ).replaceAll('main = [gcd(48, 18), lcm(48, 18)]', 'main = lcm(5, 5)'),
      );
      checkResult(runtime, 5.0);
    });

    test('lcm with coprime numbers returns product', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile(
          'samples/gcd_lcm.prm',
        ).replaceAll('main = [gcd(48, 18), lcm(48, 18)]', 'main = lcm(3, 7)'),
      );
      checkResult(runtime, 21.0);
    });

    test('toRoman with zero returns empty string', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile(
          'samples/to_roman_numerals.prm',
        ).replaceAll('main = toRoman(1984)', 'main = toRoman(0)'),
      );
      checkResult(runtime, '""');
    });

    test('toRoman with one returns I', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile(
          'samples/to_roman_numerals.prm',
        ).replaceAll('main = toRoman(1984)', 'main = toRoman(1)'),
      );
      checkResult(runtime, '"I"');
    });

    test('toRoman with four returns IV', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile(
          'samples/to_roman_numerals.prm',
        ).replaceAll('main = toRoman(1984)', 'main = toRoman(4)'),
      );
      checkResult(runtime, '"IV"');
    });

    test('toRoman with nine returns IX', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile(
          'samples/to_roman_numerals.prm',
        ).replaceAll('main = toRoman(1984)', 'main = toRoman(9)'),
      );
      checkResult(runtime, '"IX"');
    });

    test('toRoman with forty returns XL', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile(
          'samples/to_roman_numerals.prm',
        ).replaceAll('main = toRoman(1984)', 'main = toRoman(40)'),
      );
      checkResult(runtime, '"XL"');
    });

    test('toRoman with ninety returns XC', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile(
          'samples/to_roman_numerals.prm',
        ).replaceAll('main = toRoman(1984)', 'main = toRoman(90)'),
      );
      checkResult(runtime, '"XC"');
    });

    test('toRoman with four hundred returns CD', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile(
          'samples/to_roman_numerals.prm',
        ).replaceAll('main = toRoman(1984)', 'main = toRoman(400)'),
      );
      checkResult(runtime, '"CD"');
    });

    test('toRoman with nine hundred returns CM', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile(
          'samples/to_roman_numerals.prm',
        ).replaceAll('main = toRoman(1984)', 'main = toRoman(900)'),
      );
      checkResult(runtime, '"CM"');
    });

    test('piEstimate with zero terms returns zero', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile(
          'samples/pi_estimate.prm',
        ).replaceAll('main = piEstimate(10)', 'main = piEstimate(0)'),
      );
      checkResult(runtime, 0);
    });

    test('piEstimate with one term returns four', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile(
          'samples/pi_estimate.prm',
        ).replaceAll('main = piEstimate(10)', 'main = piEstimate(1)'),
      );
      checkResult(runtime, 4.0);
    });

    test('matrix multiply identity matrix', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/matrix_multiply.prm').replaceAll(
          'main = matMul([[1, 2], [3, 4]], [[5, 6], [7, 8]])',
          'main = matMul([[1, 0], [0, 1]], [[5, 6], [7, 8]])',
        ),
      );
      checkResult(runtime, [
        [5, 6],
        [7, 8],
      ]);
    });

    test('matrix multiply with zero matrix', () {
      final RuntimeFacade runtime = getRuntime(
        loadFile('samples/matrix_multiply.prm').replaceAll(
          'main = matMul([[1, 2], [3, 4]], [[5, 6], [7, 8]])',
          'main = matMul([[0, 0], [0, 0]], [[5, 6], [7, 8]])',
        ),
      );
      checkResult(runtime, [
        [0, 0],
        [0, 0],
      ]);
    });
  });
}
