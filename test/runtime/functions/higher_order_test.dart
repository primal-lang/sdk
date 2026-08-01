@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Higher order functions', () {
    test('Function as parameter', () {
      final RuntimeFacade runtime = getRuntime('''
foo(f, v) = f(v)
main() = foo(num_abs, -4)
''');
      checkResult(runtime, 4);
    });

    test('function stored in variable and called indirectly', () {
      final RuntimeFacade runtime = getRuntime('''
bar() = num_abs
foo(v) = bar()(v)
main() = foo(-4)
''');
      checkResult(runtime, 4);
    });

    test('function stored in variable and passed as argument', () {
      final RuntimeFacade runtime = getRuntime('''
bar() = num_abs
foo(f, v) = f(v)
main() = foo(bar(), -4)
''');
      checkResult(runtime, 4);
    });

    test('core function prints its signature', () {
      final RuntimeFacade runtime = getRuntime('main() = num_add');
      checkResult(runtime, '"num_add(a: Number, b: Number)"');
    });

    test('custom function prints its signature', () {
      final RuntimeFacade runtime = getRuntime('''
foo(a, b) = a + b
main() = foo
''');
      checkResult(runtime, '"foo(a: Any, b: Any)"');
    });

    test('list of functions prints their signatures', () {
      final RuntimeFacade runtime = getRuntime('main() = [num_add, num_abs]');
      checkResult(
        runtime,
        '["num_add(a: Number, b: Number)", "num_abs(a: Number)"]',
      );
    });
  });

  group('Custom Functions with Higher-Order', () {
    test('list_map with custom function', () {
      final RuntimeFacade runtime = getRuntime('''
double(n) = n * 2
main() = list_map([1, 2, 3], double)
''');
      checkResult(runtime, [2, 4, 6]);
    });

    test('list_filter with custom predicate', () {
      final RuntimeFacade runtime = getRuntime('''
isSmall(n) = n < 5
main() = list_filter([1, 7, 3, 9, 2], isSmall)
''');
      checkResult(runtime, [1, 3, 2]);
    });

    test('list_reduce with custom function', () {
      final RuntimeFacade runtime = getRuntime('''
mul(a, b) = a * b
main() = list_reduce([1, 2, 3, 4], 1, mul)
''');
      checkResult(runtime, 24);
    });

    test('list_sort with custom comparator', () {
      final RuntimeFacade runtime = getRuntime('''
reverseCompare(a, b) = num_compare(b, a)
main() = list_sort([3, 1, 5, 2, 4], reverseCompare)
''');
      checkResult(runtime, [5, 4, 3, 2, 1]);
    });

    test('list_all with custom predicate', () {
      final RuntimeFacade runtime = getRuntime('''
isPositive(n) = n > 0
main() = list_all([1, 2, 3], isPositive)
''');
      checkResult(runtime, true);
    });

    test('list_any with custom predicate', () {
      final RuntimeFacade runtime = getRuntime('''
isNeg(n) = n < 0
main() = list_any([1, -2, 3], isNeg)
''');
      checkResult(runtime, true);
    });

    test('list_none with custom predicate', () {
      final RuntimeFacade runtime = getRuntime('''
isNeg(n) = n < 0
main() = list_none([1, 2, 3], isNeg)
''');
      checkResult(runtime, true);
    });

    test('list_zip with custom function', () {
      final RuntimeFacade runtime = getRuntime('''
multiply(a, b) = a * b
main() = list_zip([1, 2, 3], [4, 5, 6], multiply)
''');
      checkResult(runtime, [4, 10, 18]);
    });
  });

  group('Empty List Edge Cases with Custom Functions', () {
    test('list_map with custom function on empty list', () {
      final RuntimeFacade runtime = getRuntime('''
double(n) = n * 2
main() = list_map([], double)
''');
      checkResult(runtime, []);
    });

    test('list_filter with custom predicate on empty list', () {
      final RuntimeFacade runtime = getRuntime('''
isPositive(n) = n > 0
main() = list_filter([], isPositive)
''');
      checkResult(runtime, []);
    });

    test('list_reduce with custom function on empty list', () {
      final RuntimeFacade runtime = getRuntime('''
add(a, b) = a + b
main() = list_reduce([], 100, add)
''');
      checkResult(runtime, 100);
    });

    test('list_all with custom predicate on empty list returns true', () {
      final RuntimeFacade runtime = getRuntime('''
isPositive(n) = n > 0
main() = list_all([], isPositive)
''');
      checkResult(runtime, true);
    });

    test('list_any with custom predicate on empty list returns false', () {
      final RuntimeFacade runtime = getRuntime('''
isPositive(n) = n > 0
main() = list_any([], isPositive)
''');
      checkResult(runtime, false);
    });

    test('list_none with custom predicate on empty list returns true', () {
      final RuntimeFacade runtime = getRuntime('''
isPositive(n) = n > 0
main() = list_none([], isPositive)
''');
      checkResult(runtime, true);
    });

    test('list_sort with custom comparator on empty list', () {
      final RuntimeFacade runtime = getRuntime('''
descending(a, b) = num_compare(b, a)
main() = list_sort([], descending)
''');
      checkResult(runtime, []);
    });

    test('list_zip with custom function on empty lists', () {
      final RuntimeFacade runtime = getRuntime('''
add(a, b) = a + b
main() = list_zip([], [], add)
''');
      checkResult(runtime, []);
    });
  });

  group('Single-Element List Cases with Custom Functions', () {
    test('list_map with custom function on single element', () {
      final RuntimeFacade runtime = getRuntime('''
triple(n) = n * 3
main() = list_map([5], triple)
''');
      checkResult(runtime, [15]);
    });

    test('list_filter with custom predicate matching single element', () {
      final RuntimeFacade runtime = getRuntime('''
isPositive(n) = n > 0
main() = list_filter([5], isPositive)
''');
      checkResult(runtime, [5]);
    });

    test('list_filter with custom predicate not matching single element', () {
      final RuntimeFacade runtime = getRuntime('''
isNegative(n) = n < 0
main() = list_filter([5], isNegative)
''');
      checkResult(runtime, []);
    });

    test('list_reduce with custom function on single element', () {
      final RuntimeFacade runtime = getRuntime('''
add(a, b) = a + b
main() = list_reduce([10], 5, add)
''');
      checkResult(runtime, 15);
    });

    test('list_all with custom predicate on single matching element', () {
      final RuntimeFacade runtime = getRuntime('''
isPositive(n) = n > 0
main() = list_all([5], isPositive)
''');
      checkResult(runtime, true);
    });

    test('list_all with custom predicate on single non-matching element', () {
      final RuntimeFacade runtime = getRuntime('''
isNegative(n) = n < 0
main() = list_all([5], isNegative)
''');
      checkResult(runtime, false);
    });

    test('list_any with custom predicate on single matching element', () {
      final RuntimeFacade runtime = getRuntime('''
isPositive(n) = n > 0
main() = list_any([5], isPositive)
''');
      checkResult(runtime, true);
    });

    test('list_any with custom predicate on single non-matching element', () {
      final RuntimeFacade runtime = getRuntime('''
isNegative(n) = n < 0
main() = list_any([5], isNegative)
''');
      checkResult(runtime, false);
    });

    test('list_sort with custom comparator on single element', () {
      final RuntimeFacade runtime = getRuntime('''
descending(a, b) = num_compare(b, a)
main() = list_sort([42], descending)
''');
      checkResult(runtime, [42]);
    });
  });

  group('Function Composition with Higher-Order Functions', () {
    test('nested map operations with custom functions', () {
      final RuntimeFacade runtime = getRuntime('''
double(n) = n * 2
increment(n) = n + 1
main() = list_map(list_map([1, 2, 3], double), increment)
''');
      checkResult(runtime, [3, 5, 7]);
    });

    test('filter then map with custom functions', () {
      final RuntimeFacade runtime = getRuntime('''
isPositive(n) = n > 0
double(n) = n * 2
main() = list_map(list_filter([-1, 2, -3, 4], isPositive), double)
''');
      checkResult(runtime, [4, 8]);
    });

    test('map then filter with custom functions', () {
      final RuntimeFacade runtime = getRuntime('''
double(n) = n * 2
isSmall(n) = n < 10
main() = list_filter(list_map([1, 2, 3, 4, 5], double), isSmall)
''');
      checkResult(runtime, [2, 4, 6, 8]);
    });

    test('map then reduce with custom functions', () {
      final RuntimeFacade runtime = getRuntime('''
square(n) = n * n
add(a, b) = a + b
main() = list_reduce(list_map([1, 2, 3], square), 0, add)
''');
      checkResult(runtime, 14);
    });

    test('filter then reduce with custom functions', () {
      final RuntimeFacade runtime = getRuntime('''
isEven(n) = n % 2 == 0
add(a, b) = a + b
main() = list_reduce(list_filter([1, 2, 3, 4, 5, 6], isEven), 0, add)
''');
      checkResult(runtime, 12);
    });

    test('sort then map with custom functions', () {
      final RuntimeFacade runtime = getRuntime('''
descending(a, b) = num_compare(b, a)
double(n) = n * 2
main() = list_map(list_sort([3, 1, 2], descending), double)
''');
      checkResult(runtime, [6, 4, 2]);
    });

    test('zip then filter with custom functions', () {
      final RuntimeFacade runtime = getRuntime('''
add(a, b) = a + b
isGreaterThanFour(n) = n > 4
main() = list_filter(list_zip([1, 2, 3], [3, 4, 5], add), isGreaterThanFour)
''');
      checkResult(runtime, [6, 8]);
    });
  });

  group('Multi-Parameter Custom Functions as Higher-Order Arguments', () {
    test('list_reduce with custom three-operation combiner', () {
      final RuntimeFacade runtime = getRuntime('''
combineWithBonus(accumulated, current) = accumulated + current + 1
main() = list_reduce([10, 20, 30], 0, combineWithBonus)
''');
      checkResult(runtime, 63);
    });

    test('list_sort with custom multi-condition comparator', () {
      final RuntimeFacade runtime = getRuntime('''
compareAbsolute(a, b) = num_compare(num_abs(a), num_abs(b))
main() = list_sort([-5, 3, -1, 4, -2], compareAbsolute)
''');
      checkResult(runtime, [-1, -2, 3, 4, -5]);
    });

    test('list_zip with custom arithmetic combiner', () {
      final RuntimeFacade runtime = getRuntime('''
weightedSum(a, b) = a * 2 + b * 3
main() = list_zip([1, 2, 3], [4, 5, 6], weightedSum)
''');
      checkResult(runtime, [14, 19, 24]);
    });
  });

  group('Recursive Custom Functions with Higher-Order Functions', () {
    test('list_map with recursive factorial function', () {
      final RuntimeFacade runtime = getRuntime('''
factorial(n) = if (n <= 1) 1 else n * factorial(n - 1)
main() = list_map([1, 2, 3, 4, 5], factorial)
''');
      checkResult(runtime, [1, 2, 6, 24, 120]);
    });

    test('list_filter with recursive fibonacci predicate', () {
      final RuntimeFacade runtime = getRuntime('''
fib(n) = if (n <= 1) n else fib(n - 1) + fib(n - 2)
isFibLessThan10(n) = fib(n) < 10
main() = list_filter([1, 2, 3, 4, 5, 6, 7], isFibLessThan10)
''');
      checkResult(runtime, [1, 2, 3, 4, 5, 6]);
    });

    test('list_reduce with recursive sum helper', () {
      final RuntimeFacade runtime = getRuntime('''
sumDigits(n) = if (n < 10) n else (n % 10) + sumDigits(num_floor(n / 10))
addDigitSums(a, b) = a + sumDigits(num_floor(b))
main() = list_reduce([123, 456, 789], 0, addDigitSums)
''');
      checkResult(runtime, 45);
    });
  });

  group('Higher-Order Function Error Cases', () {
    test('list_filter throws when custom predicate returns number', () {
      final RuntimeFacade runtime = getRuntime('''
returnNumber(n) = n * 2
main() = list_filter([1, 2, 3], returnNumber)
''');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (InvalidArgumentTypesError e) => e.toString(),
            'message',
            allOf(
              contains('list_filter'),
              contains('Boolean'),
              contains('Number'),
            ),
          ),
        ),
      );
    });

    test('list_filter throws when custom predicate returns string', () {
      final RuntimeFacade runtime = getRuntime('''
returnString(n) = "not a boolean"
main() = list_filter([1, 2, 3], returnString)
''');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (InvalidArgumentTypesError e) => e.toString(),
            'message',
            allOf(
              contains('list_filter'),
              contains('Boolean'),
              contains('String'),
            ),
          ),
        ),
      );
    });

    test('list_all throws when custom predicate returns number', () {
      final RuntimeFacade runtime = getRuntime('''
returnNumber(n) = n + 1
main() = list_all([1, 2, 3], returnNumber)
''');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (InvalidArgumentTypesError e) => e.toString(),
            'message',
            allOf(
              contains('list_all'),
              contains('Boolean'),
              contains('Number'),
            ),
          ),
        ),
      );
    });

    test('list_any throws when custom predicate returns string', () {
      final RuntimeFacade runtime = getRuntime('''
returnString(n) = "hello"
main() = list_any([1, 2, 3], returnString)
''');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (InvalidArgumentTypesError e) => e.toString(),
            'message',
            allOf(
              contains('list_any'),
              contains('Boolean'),
              contains('String'),
            ),
          ),
        ),
      );
    });

    test('list_none throws when custom predicate returns list', () {
      final RuntimeFacade runtime = getRuntime('''
returnList(n) = [n]
main() = list_none([1, 2, 3], returnList)
''');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (InvalidArgumentTypesError e) => e.toString(),
            'message',
            allOf(
              contains('list_none'),
              contains('Boolean'),
              contains('List'),
            ),
          ),
        ),
      );
    });

    test('list_sort throws when custom comparator returns boolean', () {
      final RuntimeFacade runtime = getRuntime('''
badCompare(a, b) = a > b
main() = list_sort([3, 1, 2], badCompare)
''');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (InvalidArgumentTypesError e) => e.toString(),
            'message',
            allOf(
              contains('list_sort'),
              contains('Number'),
              contains('Boolean'),
            ),
          ),
        ),
      );
    });

    test('list_sort throws when custom comparator returns string', () {
      final RuntimeFacade runtime = getRuntime('''
stringCompare(a, b) = "comparison"
main() = list_sort([3, 1, 2], stringCompare)
''');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (InvalidArgumentTypesError e) => e.toString(),
            'message',
            allOf(
              contains('list_sort'),
              contains('Number'),
              contains('String'),
            ),
          ),
        ),
      );
    });

    test('list_map with non-function second argument throws error', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map([1, 2, 3], 42)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (InvalidArgumentTypesError e) => e.toString(),
            'message',
            contains('list_map'),
          ),
        ),
      );
    });

    test('list_filter with non-function second argument throws error', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_filter([1, 2, 3], "not a function")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (InvalidArgumentTypesError e) => e.toString(),
            'message',
            contains('list_filter'),
          ),
        ),
      );
    });

    test('list_reduce with non-function third argument throws error', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_reduce([1, 2, 3], 0, true)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (InvalidArgumentTypesError e) => e.toString(),
            'message',
            contains('list_reduce'),
          ),
        ),
      );
    });

    test('list_sort with non-function second argument throws error', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sort([3, 1, 2], [1, 2, 3])',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (InvalidArgumentTypesError e) => e.toString(),
            'message',
            contains('list_sort'),
          ),
        ),
      );
    });

    test('list_zip with non-function third argument throws error', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_zip([1, 2], [3, 4], 99)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (InvalidArgumentTypesError e) => e.toString(),
            'message',
            contains('list_zip'),
          ),
        ),
      );
    });
  });

  group('Functions Returning Functions', () {
    test('function returning core function reference', () {
      final RuntimeFacade runtime = getRuntime('''
getAbs() = num_abs
main() = getAbs()(-5)
''');
      checkResult(runtime, 5);
    });

    test('function returning custom function reference', () {
      final RuntimeFacade runtime = getRuntime('''
double(n) = n * 2
getDoubler() = double
main() = getDoubler()(10)
''');
      checkResult(runtime, 20);
    });

    test('function selecting which function to return', () {
      final RuntimeFacade runtime = getRuntime('''
double(n) = n * 2
triple(n) = n * 3
selectOp(useDouble) = if (useDouble) double else triple
main() = selectOp(true)(5)
''');
      checkResult(runtime, 10);
    });

    test('function selecting which function to return (false branch)', () {
      final RuntimeFacade runtime = getRuntime('''
double(n) = n * 2
triple(n) = n * 3
selectOp(useDouble) = if (useDouble) double else triple
main() = selectOp(false)(5)
''');
      checkResult(runtime, 15);
    });

    test('returned function used with list_map', () {
      final RuntimeFacade runtime = getRuntime('''
double(n) = n * 2
triple(n) = n * 3
selectOp(useDouble) = if (useDouble) double else triple
main() = list_map([1, 2, 3], selectOp(true))
''');
      checkResult(runtime, [2, 4, 6]);
    });
  });

  group('Boundary Value Cases', () {
    test('list_all returns false on first failing element (short-circuit)', () {
      final RuntimeFacade runtime = getRuntime('''
lessThanThree(n) = n < 3
main() = list_all([1, 2, 5, 1], lessThanThree)
''');
      checkResult(runtime, false);
    });

    test('list_any returns true on first matching element (short-circuit)', () {
      final RuntimeFacade runtime = getRuntime('''
greaterThanThree(n) = n > 3
main() = list_any([1, 2, 5, 1], greaterThanThree)
''');
      checkResult(runtime, true);
    });

    test(
      'list_none returns false on first matching element (short-circuit)',
      () {
        final RuntimeFacade runtime = getRuntime('''
isZero(n) = n == 0
main() = list_none([1, 0, 2, 3], isZero)
''');
        checkResult(runtime, false);
      },
    );

    test('list_filter with predicate matching all elements', () {
      final RuntimeFacade runtime = getRuntime('''
isPositive(n) = n > 0
main() = list_filter([1, 2, 3, 4, 5], isPositive)
''');
      checkResult(runtime, [1, 2, 3, 4, 5]);
    });

    test('list_filter with predicate matching no elements', () {
      final RuntimeFacade runtime = getRuntime('''
isNegative(n) = n < 0
main() = list_filter([1, 2, 3, 4, 5], isNegative)
''');
      checkResult(runtime, []);
    });

    test('list_reduce accumulates from left to right', () {
      final RuntimeFacade runtime = getRuntime('''
subtract(a, b) = a - b
main() = list_reduce([1, 2, 3], 10, subtract)
''');
      checkResult(runtime, 4);
    });

    test('list_zip with unequal lists retains extra first list elements', () {
      final RuntimeFacade runtime = getRuntime('''
add(a, b) = a + b
main() = list_zip([1, 2, 3, 4, 5], [10, 20], add)
''');
      checkResult(runtime, [11, 22, 3, 4, 5]);
    });

    test('list_zip with unequal lists retains extra second list elements', () {
      final RuntimeFacade runtime = getRuntime('''
add(a, b) = a + b
main() = list_zip([1, 2], [10, 20, 30, 40], add)
''');
      checkResult(runtime, [11, 22, 30, 40]);
    });
  });

  group('Two-Element List Cases with Custom Functions', () {
    test('list_map with custom function on two elements', () {
      final RuntimeFacade runtime = getRuntime('''
square(n) = n * n
main() = list_map([3, 4], square)
''');
      checkResult(runtime, [9, 16]);
    });

    test('list_filter with custom predicate on two elements both match', () {
      final RuntimeFacade runtime = getRuntime('''
isPositive(n) = n > 0
main() = list_filter([5, 10], isPositive)
''');
      checkResult(runtime, [5, 10]);
    });

    test('list_filter with custom predicate on two elements one matches', () {
      final RuntimeFacade runtime = getRuntime('''
isEven(n) = n % 2 == 0
main() = list_filter([3, 4], isEven)
''');
      checkResult(runtime, [4]);
    });

    test('list_filter with custom predicate on two elements none match', () {
      final RuntimeFacade runtime = getRuntime('''
isNegative(n) = n < 0
main() = list_filter([5, 10], isNegative)
''');
      checkResult(runtime, []);
    });

    test('list_reduce with custom function on two elements', () {
      final RuntimeFacade runtime = getRuntime('''
multiply(a, b) = a * b
main() = list_reduce([3, 4], 2, multiply)
''');
      checkResult(runtime, 24);
    });

    test('list_all with custom predicate on two elements both match', () {
      final RuntimeFacade runtime = getRuntime('''
isPositive(n) = n > 0
main() = list_all([5, 10], isPositive)
''');
      checkResult(runtime, true);
    });

    test('list_all with custom predicate on two elements one fails', () {
      final RuntimeFacade runtime = getRuntime('''
isEven(n) = n % 2 == 0
main() = list_all([4, 5], isEven)
''');
      checkResult(runtime, false);
    });

    test('list_any with custom predicate on two elements one matches', () {
      final RuntimeFacade runtime = getRuntime('''
isEven(n) = n % 2 == 0
main() = list_any([3, 4], isEven)
''');
      checkResult(runtime, true);
    });

    test('list_any with custom predicate on two elements none match', () {
      final RuntimeFacade runtime = getRuntime('''
isNegative(n) = n < 0
main() = list_any([5, 10], isNegative)
''');
      checkResult(runtime, false);
    });

    test('list_none with custom predicate on two elements none match', () {
      final RuntimeFacade runtime = getRuntime('''
isNegative(n) = n < 0
main() = list_none([5, 10], isNegative)
''');
      checkResult(runtime, true);
    });

    test('list_none with custom predicate on two elements one matches', () {
      final RuntimeFacade runtime = getRuntime('''
isEven(n) = n % 2 == 0
main() = list_none([3, 4], isEven)
''');
      checkResult(runtime, false);
    });

    test('list_sort with custom comparator on two elements', () {
      final RuntimeFacade runtime = getRuntime('''
descending(a, b) = num_compare(b, a)
main() = list_sort([3, 7], descending)
''');
      checkResult(runtime, [7, 3]);
    });

    test('list_zip with custom function on two element lists', () {
      final RuntimeFacade runtime = getRuntime('''
subtract(a, b) = a - b
main() = list_zip([10, 20], [3, 5], subtract)
''');
      checkResult(runtime, [7, 15]);
    });
  });

  group('Core Functions as Higher-Order Arguments', () {
    test('list_map with num_abs', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map([-1, -2, -3], num_abs)',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('list_map with num_inc', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map([1, 2, 3], num_inc)',
      );
      checkResult(runtime, [2, 3, 4]);
    });

    test('list_map with num_dec', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map([1, 2, 3], num_dec)',
      );
      checkResult(runtime, [0, 1, 2]);
    });

    test('list_map with num_floor', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map([1.5, 2.7, 3.9], num_floor)',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('list_map with num_ceil', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map([1.1, 2.3, 3.5], num_ceil)',
      );
      checkResult(runtime, [2, 3, 4]);
    });

    test('list_map with num_round', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map([1.4, 2.5, 3.6], num_round)',
      );
      checkResult(runtime, [1, 3, 4]);
    });

    test('list_map with num_sign', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map([-5, 0, 5], num_sign)',
      );
      checkResult(runtime, [-1, 0, 1]);
    });

    test('list_map with num_sqrt', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map([1, 4, 9], num_sqrt)',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('list_map with num_isEven', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map([1, 2, 3, 4], num_isEven)',
      );
      checkResult(runtime, [false, true, false, true]);
    });

    test('list_map with num_isOdd', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map([1, 2, 3, 4], num_isOdd)',
      );
      checkResult(runtime, [true, false, true, false]);
    });

    test('list_map with num_isPositive', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map([-1, 0, 1], num_isPositive)',
      );
      checkResult(runtime, [false, false, true]);
    });

    test('list_map with num_isNegative', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map([-1, 0, 1], num_isNegative)',
      );
      checkResult(runtime, [true, false, false]);
    });

    test('list_map with num_isZero', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map([-1, 0, 1], num_isZero)',
      );
      checkResult(runtime, [false, true, false]);
    });

    test('list_map with bool_not', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map([true, false, true], bool_not)',
      );
      checkResult(runtime, [false, true, false]);
    });

    test('list_map with str_length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map(["a", "bb", "ccc"], str_length)',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('list_map with str_uppercase', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map(["hello", "world"], str_uppercase)',
      );
      checkResult(runtime, ['"HELLO"', '"WORLD"']);
    });

    test('list_map with str_lowercase', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map(["HELLO", "WORLD"], str_lowercase)',
      );
      checkResult(runtime, ['"hello"', '"world"']);
    });

    test('list_map with str_trim', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map(["  a  ", "  b  "], str_trim)',
      );
      checkResult(runtime, ['"a"', '"b"']);
    });

    test('list_map with str_reverse', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map(["abc", "def"], str_reverse)',
      );
      checkResult(runtime, ['"cba"', '"fed"']);
    });

    test('list_map with str_isEmpty', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map(["", "a", ""], str_isEmpty)',
      );
      checkResult(runtime, [true, false, true]);
    });

    test('list_map with str_isNotEmpty', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map(["", "a", ""], str_isNotEmpty)',
      );
      checkResult(runtime, [false, true, false]);
    });

    test('list_map with list_length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map([[1], [1, 2], [1, 2, 3]], list_length)',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('list_map with list_reverse', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map([[1, 2], [3, 4]], list_reverse)',
      );
      checkResult(runtime, [
        [2, 1],
        [4, 3],
      ]);
    });

    test('list_map with list_isEmpty', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map([[], [1], []], list_isEmpty)',
      );
      checkResult(runtime, [true, false, true]);
    });

    test('list_map with list_isNotEmpty', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map([[], [1], []], list_isNotEmpty)',
      );
      checkResult(runtime, [false, true, false]);
    });

    test('list_map with list_first', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map([[1, 2], [3, 4], [5, 6]], list_first)',
      );
      checkResult(runtime, [1, 3, 5]);
    });

    test('list_map with list_last', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map([[1, 2], [3, 4], [5, 6]], list_last)',
      );
      checkResult(runtime, [2, 4, 6]);
    });

    test('list_reduce with num_add', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_reduce([1, 2, 3, 4], 0, num_add)',
      );
      checkResult(runtime, 10);
    });

    test('list_reduce with num_mul', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_reduce([1, 2, 3, 4], 1, num_mul)',
      );
      checkResult(runtime, 24);
    });

    test('list_reduce with num_max', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_reduce([3, 1, 4, 1, 5], 0, num_max)',
      );
      checkResult(runtime, 5);
    });

    test('list_reduce with num_min', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_reduce([3, 1, 4, 1, 5], 100, num_min)',
      );
      checkResult(runtime, 1);
    });

    test('list_reduce with str_concat', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_reduce(["a", "b", "c"], "", str_concat)',
      );
      checkResult(runtime, '"abc"');
    });

    test('list_sort with num_compare', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sort([3, 1, 4, 1, 5], num_compare)',
      );
      checkResult(runtime, [1, 1, 3, 4, 5]);
    });

    test('list_sort with str_compare', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sort(["banana", "apple", "cherry"], str_compare)',
      );
      checkResult(runtime, ['"apple"', '"banana"', '"cherry"']);
    });

    test('list_zip with num_add', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_zip([1, 2, 3], [4, 5, 6], num_add)',
      );
      checkResult(runtime, [5, 7, 9]);
    });

    test('list_zip with num_mul', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_zip([1, 2, 3], [4, 5, 6], num_mul)',
      );
      checkResult(runtime, [4, 10, 18]);
    });

    test('list_zip with num_sub', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_zip([10, 20, 30], [1, 2, 3], num_sub)',
      );
      checkResult(runtime, [9, 18, 27]);
    });

    test('list_zip with str_concat', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_zip(["hello", "good"], [" world", "bye"], str_concat)',
      );
      checkResult(runtime, ['"hello world"', '"goodbye"']);
    });

    test('list_zip with bool_and', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_zip([true, true, false], [true, false, false], bool_and)',
      );
      checkResult(runtime, [true, false, false]);
    });

    test('list_zip with bool_or', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_zip([true, true, false], [true, false, false], bool_or)',
      );
      checkResult(runtime, [true, true, false]);
    });

    test('list_zip with bool_xor', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_zip([true, true, false], [true, false, false], bool_xor)',
      );
      checkResult(runtime, [false, true, false]);
    });
  });

  group('Mixed Types in Lists with Higher-Order Functions', () {
    test('list_map with identity function on mixed types', () {
      final RuntimeFacade runtime = getRuntime('''
identity(x) = x
main() = list_map([1, "two", true], identity)
''');
      checkResult(runtime, [1, '"two"', true]);
    });

    test('list_filter with always true predicate on mixed types', () {
      final RuntimeFacade runtime = getRuntime('''
alwaysTrue(x) = true
main() = list_filter([1, "two", true, [3]], alwaysTrue)
''');
      checkResult(runtime, [
        1,
        '"two"',
        true,
        [3],
      ]);
    });

    test('list_filter with always false predicate on mixed types', () {
      final RuntimeFacade runtime = getRuntime('''
alwaysFalse(x) = false
main() = list_filter([1, "two", true, [3]], alwaysFalse)
''');
      checkResult(runtime, []);
    });

    test('list_all with always true predicate on mixed types', () {
      final RuntimeFacade runtime = getRuntime('''
alwaysTrue(x) = true
main() = list_all([1, "two", true], alwaysTrue)
''');
      checkResult(runtime, true);
    });

    test('list_any with always false predicate on mixed types', () {
      final RuntimeFacade runtime = getRuntime('''
alwaysFalse(x) = false
main() = list_any([1, "two", true], alwaysFalse)
''');
      checkResult(runtime, false);
    });

    test('list_none with always false predicate on mixed types', () {
      final RuntimeFacade runtime = getRuntime('''
alwaysFalse(x) = false
main() = list_none([1, "two", true], alwaysFalse)
''');
      checkResult(runtime, true);
    });

    test('list_reduce on mixed types building a list', () {
      final RuntimeFacade runtime = getRuntime('''
appendToList(accumulator, element) = list_insertEnd(accumulator, element)
main() = list_reduce([1, "two", true], [], appendToList)
''');
      checkResult(runtime, [1, '"two"', true]);
    });
  });

  group('Stress Testing with Large Lists', () {
    test('list_map on large list', () {
      final RuntimeFacade runtime = getRuntime('''
double(n) = n * 2
main() = list_length(list_map(list_filled(100, 1), double))
''');
      checkResult(runtime, 100);
    });

    test('list_filter on large list keeping all', () {
      final RuntimeFacade runtime = getRuntime('''
isPositive(n) = n > 0
main() = list_length(list_filter(list_filled(100, 1), isPositive))
''');
      checkResult(runtime, 100);
    });

    test('list_filter on large list keeping none', () {
      final RuntimeFacade runtime = getRuntime('''
isNegative(n) = n < 0
main() = list_length(list_filter(list_filled(100, 1), isNegative))
''');
      checkResult(runtime, 0);
    });

    test('list_reduce on large list', () {
      final RuntimeFacade runtime = getRuntime('''
add(a, b) = a + b
main() = list_reduce(list_filled(100, 1), 0, add)
''');
      checkResult(runtime, 100);
    });

    test('list_all on large list all true', () {
      final RuntimeFacade runtime = getRuntime('''
isPositive(n) = n > 0
main() = list_all(list_filled(100, 1), isPositive)
''');
      checkResult(runtime, true);
    });

    test('list_any on large list first element matches', () {
      final RuntimeFacade runtime = getRuntime('''
isOne(n) = n == 1
main() = list_any(list_filled(100, 1), isOne)
''');
      checkResult(runtime, true);
    });

    test('list_none on large list all fail predicate', () {
      final RuntimeFacade runtime = getRuntime('''
isZero(n) = n == 0
main() = list_none(list_filled(100, 1), isZero)
''');
      checkResult(runtime, true);
    });

    test('list_zip on two large lists', () {
      final RuntimeFacade runtime = getRuntime('''
add(a, b) = a + b
main() = list_length(list_zip(list_filled(100, 1), list_filled(100, 2), add))
''');
      checkResult(runtime, 100);
    });
  });

  group('Nested Higher-Order Function Compositions', () {
    test('triple nested map operations', () {
      final RuntimeFacade runtime = getRuntime('''
double(n) = n * 2
increment(n) = n + 1
square(n) = n * n
main() = list_map(list_map(list_map([1, 2], double), increment), square)
''');
      checkResult(runtime, [9, 25]);
    });

    test('filter then map then reduce', () {
      final RuntimeFacade runtime = getRuntime('''
isPositive(n) = n > 0
double(n) = n * 2
add(a, b) = a + b
main() = list_reduce(list_map(list_filter([-1, 2, -3, 4], isPositive), double), 0, add)
''');
      checkResult(runtime, 12);
    });

    test('map then filter then sort then reduce', () {
      final RuntimeFacade runtime = getRuntime('''
double(n) = n * 2
isLessThan10(n) = n < 10
descending(a, b) = num_compare(b, a)
add(a, b) = a + b
main() = list_reduce(list_sort(list_filter(list_map([1, 2, 3, 4, 5, 6], double), isLessThan10), descending), 0, add)
''');
      checkResult(runtime, 20);
    });

    test('zip then map then filter', () {
      final RuntimeFacade runtime = getRuntime('''
add(a, b) = a + b
double(n) = n * 2
isGreaterThan10(n) = n > 10
main() = list_filter(list_map(list_zip([1, 2, 3], [4, 5, 6], add), double), isGreaterThan10)
''');
      checkResult(runtime, [14, 18]);
    });

    test('all predicates composed with filter', () {
      final RuntimeFacade runtime = getRuntime('''
isPositive(n) = n > 0
isEven(n) = n % 2 == 0
main() = list_all(list_filter([1, 2, 3, 4, 5, 6], isEven), isPositive)
''');
      checkResult(runtime, true);
    });

    test('any predicate composed with map', () {
      final RuntimeFacade runtime = getRuntime('''
double(n) = n * 2
isGreaterThan5(n) = n > 5
main() = list_any(list_map([1, 2, 3], double), isGreaterThan5)
''');
      checkResult(runtime, true);
    });
  });

  group('Function References in Collections', () {
    test('list of functions prints their signatures', () {
      final RuntimeFacade runtime = getRuntime('''
double(n) = n * 2
triple(n) = n * 3
main() = [double, triple]
''');
      checkResult(
        runtime,
        '["double(n: Any)", "triple(n: Any)"]',
      );
    });

    test('reduce functions to apply sequentially', () {
      final RuntimeFacade runtime = getRuntime('''
double(n) = n * 2
addOne(n) = n + 1
applyFunction(value, function) = function(value)
main() = list_reduce([double, addOne], 5, applyFunction)
''');
      checkResult(runtime, 11);
    });

    test('conditional selecting function from collection', () {
      final RuntimeFacade runtime = getRuntime('''
double(n) = n * 2
triple(n) = n * 3
selectFromPair(useFirst) = if (useFirst) double else triple
main() = selectFromPair(true)(5)
''');
      checkResult(runtime, 10);
    });

    test('function map over list of inputs', () {
      final RuntimeFacade runtime = getRuntime('''
double(n) = n * 2
triple(n) = n * 3
applyBoth(x) = [double(x), triple(x)]
main() = applyBoth(4)
''');
      checkResult(runtime, [8, 12]);
    });
  });

  group('Identity and Constant Functions', () {
    test('list_map with identity function', () {
      final RuntimeFacade runtime = getRuntime('''
identity(x) = x
main() = list_map([1, 2, 3], identity)
''');
      checkResult(runtime, [1, 2, 3]);
    });

    test('list_filter with constant true predicate', () {
      final RuntimeFacade runtime = getRuntime('''
alwaysTrue(x) = true
main() = list_filter([1, 2, 3], alwaysTrue)
''');
      checkResult(runtime, [1, 2, 3]);
    });

    test('list_filter with constant false predicate', () {
      final RuntimeFacade runtime = getRuntime('''
alwaysFalse(x) = false
main() = list_filter([1, 2, 3], alwaysFalse)
''');
      checkResult(runtime, []);
    });

    test('list_reduce with constant function ignoring accumulator', () {
      final RuntimeFacade runtime = getRuntime('''
alwaysSecond(a, b) = b
main() = list_reduce([1, 2, 3], 100, alwaysSecond)
''');
      checkResult(runtime, 3);
    });

    test('list_reduce with constant function ignoring element', () {
      final RuntimeFacade runtime = getRuntime('''
alwaysFirst(a, b) = a
main() = list_reduce([1, 2, 3], 100, alwaysFirst)
''');
      checkResult(runtime, 100);
    });

    test('list_sort with constant zero comparator maintains order', () {
      final RuntimeFacade runtime = getRuntime('''
alwaysZero(a, b) = 0
main() = list_sort([3, 1, 4, 1, 5], alwaysZero)
''');
      checkResult(runtime, [3, 1, 4, 1, 5]);
    });
  });

  group('Additional Error Cases', () {
    test('list_all with non-function second argument throws error', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_all([1, 2, 3], 42)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (InvalidArgumentTypesError e) => e.toString(),
            'message',
            contains('list_all'),
          ),
        ),
      );
    });

    test('list_any with non-function second argument throws error', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_any([1, 2, 3], "not a function")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (InvalidArgumentTypesError e) => e.toString(),
            'message',
            contains('list_any'),
          ),
        ),
      );
    });

    test('list_none with non-function second argument throws error', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_none([1, 2, 3], true)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (InvalidArgumentTypesError e) => e.toString(),
            'message',
            contains('list_none'),
          ),
        ),
      );
    });

    test('list_map with non-list first argument throws error', () {
      final RuntimeFacade runtime = getRuntime('''
double(n) = n * 2
main() = list_map("not a list", double)
''');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (InvalidArgumentTypesError e) => e.toString(),
            'message',
            contains('list_map'),
          ),
        ),
      );
    });

    test('list_filter with non-list first argument throws error', () {
      final RuntimeFacade runtime = getRuntime('''
isPositive(n) = n > 0
main() = list_filter(123, isPositive)
''');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (InvalidArgumentTypesError e) => e.toString(),
            'message',
            contains('list_filter'),
          ),
        ),
      );
    });

    test('list_reduce with non-list first argument throws error', () {
      final RuntimeFacade runtime = getRuntime('''
add(a, b) = a + b
main() = list_reduce(true, 0, add)
''');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (InvalidArgumentTypesError e) => e.toString(),
            'message',
            contains('list_reduce'),
          ),
        ),
      );
    });

    test('list_sort with non-list first argument throws error', () {
      final RuntimeFacade runtime = getRuntime('''
compare(a, b) = num_compare(a, b)
main() = list_sort("not a list", compare)
''');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (InvalidArgumentTypesError e) => e.toString(),
            'message',
            contains('list_sort'),
          ),
        ),
      );
    });

    test('list_all with non-list first argument throws error', () {
      final RuntimeFacade runtime = getRuntime('''
isPositive(n) = n > 0
main() = list_all(42, isPositive)
''');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (InvalidArgumentTypesError e) => e.toString(),
            'message',
            contains('list_all'),
          ),
        ),
      );
    });

    test('list_any with non-list first argument throws error', () {
      final RuntimeFacade runtime = getRuntime('''
isPositive(n) = n > 0
main() = list_any("not a list", isPositive)
''');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (InvalidArgumentTypesError e) => e.toString(),
            'message',
            contains('list_any'),
          ),
        ),
      );
    });

    test('list_none with non-list first argument throws error', () {
      final RuntimeFacade runtime = getRuntime('''
isPositive(n) = n > 0
main() = list_none(true, isPositive)
''');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (InvalidArgumentTypesError e) => e.toString(),
            'message',
            contains('list_none'),
          ),
        ),
      );
    });

    test('list_zip with non-list first argument throws error', () {
      final RuntimeFacade runtime = getRuntime('''
add(a, b) = a + b
main() = list_zip("not a list", [1, 2, 3], add)
''');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (InvalidArgumentTypesError e) => e.toString(),
            'message',
            contains('list_zip'),
          ),
        ),
      );
    });

    test('list_zip with non-list second argument throws error', () {
      final RuntimeFacade runtime = getRuntime('''
add(a, b) = a + b
main() = list_zip([1, 2, 3], 42, add)
''');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (InvalidArgumentTypesError e) => e.toString(),
            'message',
            contains('list_zip'),
          ),
        ),
      );
    });
  });

  group('Functions with Side Effects through Return Values', () {
    test('custom function modifying list through map', () {
      final RuntimeFacade runtime = getRuntime('''
wrapInList(n) = [n]
main() = list_map([1, 2, 3], wrapInList)
''');
      checkResult(runtime, [
        [1],
        [2],
        [3],
      ]);
    });

    test('custom function extracting from nested list', () {
      final RuntimeFacade runtime = getRuntime('''
getFirst(lst) = list_first(lst)
main() = list_map([[1, 2], [3, 4], [5, 6]], getFirst)
''');
      checkResult(runtime, [1, 3, 5]);
    });

    test('custom function computing list length', () {
      final RuntimeFacade runtime = getRuntime('''
getLength(lst) = list_length(lst)
main() = list_map([[1], [1, 2], [1, 2, 3]], getLength)
''');
      checkResult(runtime, [1, 2, 3]);
    });
  });

  group('Conditional Logic in Higher-Order Functions', () {
    test('custom function with conditional in map', () {
      final RuntimeFacade runtime = getRuntime('''
absValue(n) = if (n < 0) (0 - n) else n
main() = list_map([-3, -2, -1, 0, 1, 2, 3], absValue)
''');
      checkResult(runtime, [3, 2, 1, 0, 1, 2, 3]);
    });

    test('custom function with nested conditionals in map', () {
      final RuntimeFacade runtime = getRuntime('''
classify(n) = if (n < 0) "negative" else if (n > 0) "positive" else "zero"
main() = list_map([-1, 0, 1], classify)
''');
      checkResult(runtime, ['"negative"', '"zero"', '"positive"']);
    });

    test('filter with conditional predicate', () {
      final RuntimeFacade runtime = getRuntime('''
isInRange(n) = if (n >= 0) (n <= 10) else false
main() = list_filter([-5, 0, 5, 10, 15], isInRange)
''');
      checkResult(runtime, [0, 5, 10]);
    });

    test('reduce with conditional combiner', () {
      final RuntimeFacade runtime = getRuntime('''
maxPositive(a, b) = if (b > 0) (if (b > a) b else a) else a
main() = list_reduce([-5, 3, -2, 7, -1, 4], 0, maxPositive)
''');
      checkResult(runtime, 7);
    });

    test('sort with conditional comparator', () {
      final RuntimeFacade runtime = getRuntime('''
compareAbs(a, b) = if (num_abs(a) < num_abs(b)) -1 else if (num_abs(a) > num_abs(b)) 1 else 0
main() = list_sort([-5, 3, -1, 4, -2], compareAbs)
''');
      checkResult(runtime, [-1, -2, 3, 4, -5]);
    });
  });

  group('String Functions in Higher-Order Context', () {
    test('filter strings by length predicate', () {
      final RuntimeFacade runtime = getRuntime('''
isShort(s) = str_length(s) < 4
main() = list_filter(["a", "bb", "ccc", "dddd", "eeeee"], isShort)
''');
      checkResult(runtime, ['"a"', '"bb"', '"ccc"']);
    });

    test('map strings with transformation', () {
      final RuntimeFacade runtime = getRuntime('''
reverseStr(s) = str_reverse(s)
main() = list_map(["abc", "def"], reverseStr)
''');
      checkResult(runtime, ['"cba"', '"fed"']);
    });

    test('reduce strings with custom concat', () {
      final RuntimeFacade runtime = getRuntime('''
joinWithComma(a, b) = str_concat(str_concat(a, ", "), b)
main() = list_reduce(["apple", "banana", "cherry"], "fruits:", joinWithComma)
''');
      checkResult(runtime, '"fruits:, apple, banana, cherry"');
    });

    test('sort strings by length', () {
      final RuntimeFacade runtime = getRuntime('''
compareByLength(a, b) = num_compare(str_length(a), str_length(b))
main() = list_sort(["aaa", "b", "cc"], compareByLength)
''');
      checkResult(runtime, ['"b"', '"cc"', '"aaa"']);
    });
  });

  group('Boolean Functions in Higher-Order Context', () {
    test('map boolean values with not', () {
      final RuntimeFacade runtime = getRuntime('''
negate(b) = !b
main() = list_map([true, false, true, false], negate)
''');
      checkResult(runtime, [false, true, false, true]);
    });

    test('filter to keep only true values', () {
      final RuntimeFacade runtime = getRuntime('''
isTrue(b) = b
main() = list_filter([true, false, true, false, true], isTrue)
''');
      checkResult(runtime, [true, true, true]);
    });

    test('reduce booleans with and logic', () {
      final RuntimeFacade runtime = getRuntime('''
andLogic(a, b) = a && b
main() = list_reduce([true, true, true], true, andLogic)
''');
      checkResult(runtime, true);
    });

    test('reduce booleans with or logic', () {
      final RuntimeFacade runtime = getRuntime('''
orLogic(a, b) = a || b
main() = list_reduce([false, false, true], false, orLogic)
''');
      checkResult(runtime, true);
    });

    test('all booleans are true', () {
      final RuntimeFacade runtime = getRuntime('''
isTrue(b) = b
main() = list_all([true, true, true], isTrue)
''');
      checkResult(runtime, true);
    });

    test('any boolean is true', () {
      final RuntimeFacade runtime = getRuntime('''
isTrue(b) = b
main() = list_any([false, false, true], isTrue)
''');
      checkResult(runtime, true);
    });

    test('none booleans are true when all false', () {
      final RuntimeFacade runtime = getRuntime('''
isTrue(b) = b
main() = list_none([false, false, false], isTrue)
''');
      checkResult(runtime, true);
    });
  });

  group('Mutual Recursion with Higher-Order Functions', () {
    test('mutually recursive even/odd predicates with filter', () {
      final RuntimeFacade runtime = getRuntime('''
isEven(n) = if (n == 0) true else isOdd(n - 1)
isOdd(n) = if (n == 0) false else isEven(n - 1)
main() = list_filter([0, 1, 2, 3, 4, 5], isEven)
''');
      checkResult(runtime, [0, 2, 4]);
    });

    test('mutually recursive even/odd predicates with map', () {
      final RuntimeFacade runtime = getRuntime('''
isEven(n) = if (n == 0) true else isOdd(n - 1)
isOdd(n) = if (n == 0) false else isEven(n - 1)
main() = list_map([0, 1, 2, 3], isEven)
''');
      checkResult(runtime, [true, false, true, false]);
    });
  });

  group('Empty and Single Element Edge Cases with Core Functions', () {
    test('list_map with core function on empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map([], num_abs)',
      );
      checkResult(runtime, []);
    });

    test('list_map with core function on single element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map([-5], num_abs)',
      );
      checkResult(runtime, [5]);
    });

    test('list_reduce with core function on empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_reduce([], 42, num_add)',
      );
      checkResult(runtime, 42);
    });

    test('list_reduce with core function on single element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_reduce([10], 5, num_add)',
      );
      checkResult(runtime, 15);
    });

    test('list_sort with core function on empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sort([], num_compare)',
      );
      checkResult(runtime, []);
    });

    test('list_sort with core function on single element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sort([42], num_compare)',
      );
      checkResult(runtime, [42]);
    });

    test('list_zip with core function on empty lists', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_zip([], [], num_add)',
      );
      checkResult(runtime, []);
    });

    test('list_zip with core function on single element lists', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_zip([3], [4], num_add)',
      );
      checkResult(runtime, [7]);
    });
  });

  group('Functions Calling Other Custom Functions', () {
    test('higher-order function with custom helper', () {
      final RuntimeFacade runtime = getRuntime('''
helper(x) = x + 10
wrapper(n) = helper(n) * 2
main() = list_map([1, 2, 3], wrapper)
''');
      checkResult(runtime, [22, 24, 26]);
    });

    test('predicate using custom helper function', () {
      final RuntimeFacade runtime = getRuntime('''
computeThreshold(n) = n * 2
isAboveThreshold(n) = n > computeThreshold(2)
main() = list_filter([1, 3, 5, 7], isAboveThreshold)
''');
      checkResult(runtime, [5, 7]);
    });

    test('combiner using multiple custom helpers', () {
      // combineWithHelpers(0, 1) = double(0) + addOne(1) = 0 + 2 = 2
      // combineWithHelpers(2, 2) = double(2) + addOne(2) = 4 + 3 = 7
      // combineWithHelpers(7, 3) = double(7) + addOne(3) = 14 + 4 = 18
      final RuntimeFacade runtime = getRuntime('''
double(n) = n * 2
addOne(n) = n + 1
combineWithHelpers(a, b) = double(a) + addOne(b)
main() = list_reduce([1, 2, 3], 0, combineWithHelpers)
''');
      checkResult(runtime, 18);
    });

    test('comparator using custom transform', () {
      final RuntimeFacade runtime = getRuntime('''
transform(n) = num_abs(n) * 2
compareTransformed(a, b) = num_compare(transform(a), transform(b))
main() = list_sort([2, -3, 1, -4], compareTransformed)
''');
      checkResult(runtime, [1, 2, -3, -4]);
    });
  });

  group('Chained Function References', () {
    test('function reference stored and retrieved', () {
      final RuntimeFacade runtime = getRuntime('''
double(n) = n * 2
storedFunction() = double
main() = storedFunction()(5)
''');
      checkResult(runtime, 10);
    });

    test('function reference passed through multiple functions', () {
      final RuntimeFacade runtime = getRuntime('''
double(n) = n * 2
passThrough(f) = f
main() = passThrough(double)(5)
''');
      checkResult(runtime, 10);
    });

    test('function reference used in conditional', () {
      final RuntimeFacade runtime = getRuntime('''
double(n) = n * 2
triple(n) = n * 3
chooseFunction(useDouble) = if (useDouble) double else triple
main() = chooseFunction(true)(4)
''');
      checkResult(runtime, 8);
    });

    test('function reference used in conditional false branch', () {
      final RuntimeFacade runtime = getRuntime('''
double(n) = n * 2
triple(n) = n * 3
chooseFunction(useDouble) = if (useDouble) double else triple
main() = chooseFunction(false)(4)
''');
      checkResult(runtime, 12);
    });

    test('nested function reference returns', () {
      final RuntimeFacade runtime = getRuntime('''
double(n) = n * 2
getDoubler() = double
applyFunction(f, x) = f(x)
main() = applyFunction(getDoubler(), 7)
''');
      checkResult(runtime, 14);
    });
  });

  group('Higher-Order Functions with Nested Lists', () {
    test('list_map on list of lists', () {
      final RuntimeFacade runtime = getRuntime('''
sumList(lst) = list_reduce(lst, 0, num_add)
main() = list_map([[1, 2], [3, 4], [5, 6]], sumList)
''');
      checkResult(runtime, [3, 7, 11]);
    });

    test('list_filter on list of lists by length', () {
      final RuntimeFacade runtime = getRuntime('''
hasMultipleElements(lst) = list_length(lst) > 1
main() = list_filter([[1], [2, 3], [4], [5, 6, 7]], hasMultipleElements)
''');
      checkResult(runtime, [
        [2, 3],
        [5, 6, 7],
      ]);
    });

    test('list_reduce on list of lists to flatten', () {
      final RuntimeFacade runtime = getRuntime('''
main() = list_reduce([[1, 2], [3, 4], [5, 6]], [], list_concat)
''');
      checkResult(runtime, [1, 2, 3, 4, 5, 6]);
    });

    test('list_sort on list of lists by first element', () {
      final RuntimeFacade runtime = getRuntime('''
compareByFirst(a, b) = num_compare(list_first(a), list_first(b))
main() = list_sort([[3, 1], [1, 2], [2, 3]], compareByFirst)
''');
      checkResult(runtime, [
        [1, 2],
        [2, 3],
        [3, 1],
      ]);
    });

    test('list_all checking all sublists have elements', () {
      final RuntimeFacade runtime = getRuntime('''
hasElements(lst) = list_isNotEmpty(lst)
main() = list_all([[1], [2, 3], [4, 5, 6]], hasElements)
''');
      checkResult(runtime, true);
    });

    test('list_any checking if any sublist is empty', () {
      final RuntimeFacade runtime = getRuntime('''
isEmpty(lst) = list_isEmpty(lst)
main() = list_any([[1], [], [3]], isEmpty)
''');
      checkResult(runtime, true);
    });

    test('list_none checking no sublists have more than 5 elements', () {
      final RuntimeFacade runtime = getRuntime('''
hasManyElements(lst) = list_length(lst) > 5
main() = list_none([[1, 2], [3, 4, 5], [6]], hasManyElements)
''');
      checkResult(runtime, true);
    });
  });
}
