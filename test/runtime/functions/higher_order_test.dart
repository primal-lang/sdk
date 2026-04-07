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
main = foo(num.abs, -4)
''');
      checkResult(runtime, 4);
    });

    test('function stored in variable and called indirectly', () {
      final RuntimeFacade runtime = getRuntime('''
bar = num.abs
foo(v) = bar()(v)
main = foo(-4)
''');
      checkResult(runtime, 4);
    });

    test('function stored in variable and passed as argument', () {
      final RuntimeFacade runtime = getRuntime('''
bar = num.abs
foo(f, v) = f(v)
main = foo(bar(), -4)
''');
      checkResult(runtime, 4);
    });

    test('core function prints its signature', () {
      final RuntimeFacade runtime = getRuntime('main = num.add');
      checkResult(runtime, '"num.add(a: Number, b: Number)"');
    });

    test('custom function prints its signature', () {
      final RuntimeFacade runtime = getRuntime('''
foo(a, b) = a + b
main = foo
''');
      checkResult(runtime, '"foo(a: Any, b: Any)"');
    });

    test('list of functions prints their signatures', () {
      final RuntimeFacade runtime = getRuntime('main = [num.add, num.abs]');
      checkResult(
        runtime,
        '["num.add(a: Number, b: Number)", "num.abs(a: Number)"]',
      );
    });
  });

  group('Custom Functions with Higher-Order', () {
    test('list.map with custom function', () {
      final RuntimeFacade runtime = getRuntime('''
double(n) = n * 2
main = list.map([1, 2, 3], double)
''');
      checkResult(runtime, [2, 4, 6]);
    });

    test('list.filter with custom predicate', () {
      final RuntimeFacade runtime = getRuntime('''
isSmall(n) = n < 5
main = list.filter([1, 7, 3, 9, 2], isSmall)
''');
      checkResult(runtime, [1, 3, 2]);
    });

    test('list.reduce with custom function', () {
      final RuntimeFacade runtime = getRuntime('''
mul(a, b) = a * b
main = list.reduce([1, 2, 3, 4], 1, mul)
''');
      checkResult(runtime, 24);
    });

    test('list.sort with custom comparator', () {
      final RuntimeFacade runtime = getRuntime('''
reverseCompare(a, b) = num.compare(b, a)
main = list.sort([3, 1, 5, 2, 4], reverseCompare)
''');
      checkResult(runtime, [5, 4, 3, 2, 1]);
    });

    test('list.all with custom predicate', () {
      final RuntimeFacade runtime = getRuntime('''
isPositive(n) = n > 0
main = list.all([1, 2, 3], isPositive)
''');
      checkResult(runtime, true);
    });

    test('list.any with custom predicate', () {
      final RuntimeFacade runtime = getRuntime('''
isNeg(n) = n < 0
main = list.any([1, -2, 3], isNeg)
''');
      checkResult(runtime, true);
    });

    test('list.none with custom predicate', () {
      final RuntimeFacade runtime = getRuntime('''
isNeg(n) = n < 0
main = list.none([1, 2, 3], isNeg)
''');
      checkResult(runtime, true);
    });

    test('list.zip with custom function', () {
      final RuntimeFacade runtime = getRuntime('''
multiply(a, b) = a * b
main = list.zip([1, 2, 3], [4, 5, 6], multiply)
''');
      checkResult(runtime, [4, 10, 18]);
    });
  });

  group('Empty List Edge Cases with Custom Functions', () {
    test('list.map with custom function on empty list', () {
      final RuntimeFacade runtime = getRuntime('''
double(n) = n * 2
main = list.map([], double)
''');
      checkResult(runtime, []);
    });

    test('list.filter with custom predicate on empty list', () {
      final RuntimeFacade runtime = getRuntime('''
isPositive(n) = n > 0
main = list.filter([], isPositive)
''');
      checkResult(runtime, []);
    });

    test('list.reduce with custom function on empty list', () {
      final RuntimeFacade runtime = getRuntime('''
add(a, b) = a + b
main = list.reduce([], 100, add)
''');
      checkResult(runtime, 100);
    });

    test('list.all with custom predicate on empty list returns true', () {
      final RuntimeFacade runtime = getRuntime('''
isPositive(n) = n > 0
main = list.all([], isPositive)
''');
      checkResult(runtime, true);
    });

    test('list.any with custom predicate on empty list returns false', () {
      final RuntimeFacade runtime = getRuntime('''
isPositive(n) = n > 0
main = list.any([], isPositive)
''');
      checkResult(runtime, false);
    });

    test('list.none with custom predicate on empty list returns true', () {
      final RuntimeFacade runtime = getRuntime('''
isPositive(n) = n > 0
main = list.none([], isPositive)
''');
      checkResult(runtime, true);
    });

    test('list.sort with custom comparator on empty list', () {
      final RuntimeFacade runtime = getRuntime('''
descending(a, b) = num.compare(b, a)
main = list.sort([], descending)
''');
      checkResult(runtime, []);
    });

    test('list.zip with custom function on empty lists', () {
      final RuntimeFacade runtime = getRuntime('''
add(a, b) = a + b
main = list.zip([], [], add)
''');
      checkResult(runtime, []);
    });
  });

  group('Single-Element List Cases with Custom Functions', () {
    test('list.map with custom function on single element', () {
      final RuntimeFacade runtime = getRuntime('''
triple(n) = n * 3
main = list.map([5], triple)
''');
      checkResult(runtime, [15]);
    });

    test('list.filter with custom predicate matching single element', () {
      final RuntimeFacade runtime = getRuntime('''
isPositive(n) = n > 0
main = list.filter([5], isPositive)
''');
      checkResult(runtime, [5]);
    });

    test('list.filter with custom predicate not matching single element', () {
      final RuntimeFacade runtime = getRuntime('''
isNegative(n) = n < 0
main = list.filter([5], isNegative)
''');
      checkResult(runtime, []);
    });

    test('list.reduce with custom function on single element', () {
      final RuntimeFacade runtime = getRuntime('''
add(a, b) = a + b
main = list.reduce([10], 5, add)
''');
      checkResult(runtime, 15);
    });

    test('list.all with custom predicate on single matching element', () {
      final RuntimeFacade runtime = getRuntime('''
isPositive(n) = n > 0
main = list.all([5], isPositive)
''');
      checkResult(runtime, true);
    });

    test('list.all with custom predicate on single non-matching element', () {
      final RuntimeFacade runtime = getRuntime('''
isNegative(n) = n < 0
main = list.all([5], isNegative)
''');
      checkResult(runtime, false);
    });

    test('list.any with custom predicate on single matching element', () {
      final RuntimeFacade runtime = getRuntime('''
isPositive(n) = n > 0
main = list.any([5], isPositive)
''');
      checkResult(runtime, true);
    });

    test('list.any with custom predicate on single non-matching element', () {
      final RuntimeFacade runtime = getRuntime('''
isNegative(n) = n < 0
main = list.any([5], isNegative)
''');
      checkResult(runtime, false);
    });

    test('list.sort with custom comparator on single element', () {
      final RuntimeFacade runtime = getRuntime('''
descending(a, b) = num.compare(b, a)
main = list.sort([42], descending)
''');
      checkResult(runtime, [42]);
    });
  });

  group('Function Composition with Higher-Order Functions', () {
    test('nested map operations with custom functions', () {
      final RuntimeFacade runtime = getRuntime('''
double(n) = n * 2
increment(n) = n + 1
main = list.map(list.map([1, 2, 3], double), increment)
''');
      checkResult(runtime, [3, 5, 7]);
    });

    test('filter then map with custom functions', () {
      final RuntimeFacade runtime = getRuntime('''
isPositive(n) = n > 0
double(n) = n * 2
main = list.map(list.filter([-1, 2, -3, 4], isPositive), double)
''');
      checkResult(runtime, [4, 8]);
    });

    test('map then filter with custom functions', () {
      final RuntimeFacade runtime = getRuntime('''
double(n) = n * 2
isSmall(n) = n < 10
main = list.filter(list.map([1, 2, 3, 4, 5], double), isSmall)
''');
      checkResult(runtime, [2, 4, 6, 8]);
    });

    test('map then reduce with custom functions', () {
      final RuntimeFacade runtime = getRuntime('''
square(n) = n * n
add(a, b) = a + b
main = list.reduce(list.map([1, 2, 3], square), 0, add)
''');
      checkResult(runtime, 14);
    });

    test('filter then reduce with custom functions', () {
      final RuntimeFacade runtime = getRuntime('''
isEven(n) = n % 2 == 0
add(a, b) = a + b
main = list.reduce(list.filter([1, 2, 3, 4, 5, 6], isEven), 0, add)
''');
      checkResult(runtime, 12);
    });

    test('sort then map with custom functions', () {
      final RuntimeFacade runtime = getRuntime('''
descending(a, b) = num.compare(b, a)
double(n) = n * 2
main = list.map(list.sort([3, 1, 2], descending), double)
''');
      checkResult(runtime, [6, 4, 2]);
    });

    test('zip then filter with custom functions', () {
      final RuntimeFacade runtime = getRuntime('''
add(a, b) = a + b
isGreaterThanFour(n) = n > 4
main = list.filter(list.zip([1, 2, 3], [3, 4, 5], add), isGreaterThanFour)
''');
      checkResult(runtime, [6, 8]);
    });
  });

  group('Multi-Parameter Custom Functions as Higher-Order Arguments', () {
    test('list.reduce with custom three-operation combiner', () {
      final RuntimeFacade runtime = getRuntime('''
combineWithBonus(accumulated, current) = accumulated + current + 1
main = list.reduce([10, 20, 30], 0, combineWithBonus)
''');
      checkResult(runtime, 63);
    });

    test('list.sort with custom multi-condition comparator', () {
      final RuntimeFacade runtime = getRuntime('''
compareAbsolute(a, b) = num.compare(num.abs(a), num.abs(b))
main = list.sort([-5, 3, -1, 4, -2], compareAbsolute)
''');
      checkResult(runtime, [-1, -2, 3, 4, -5]);
    });

    test('list.zip with custom arithmetic combiner', () {
      final RuntimeFacade runtime = getRuntime('''
weightedSum(a, b) = a * 2 + b * 3
main = list.zip([1, 2, 3], [4, 5, 6], weightedSum)
''');
      checkResult(runtime, [14, 19, 24]);
    });
  });

  group('Recursive Custom Functions with Higher-Order Functions', () {
    test('list.map with recursive factorial function', () {
      final RuntimeFacade runtime = getRuntime('''
factorial(n) = if (n <= 1) 1 else n * factorial(n - 1)
main = list.map([1, 2, 3, 4, 5], factorial)
''');
      checkResult(runtime, [1, 2, 6, 24, 120]);
    });

    test('list.filter with recursive fibonacci predicate', () {
      final RuntimeFacade runtime = getRuntime('''
fib(n) = if (n <= 1) n else fib(n - 1) + fib(n - 2)
isFibLessThan10(n) = fib(n) < 10
main = list.filter([1, 2, 3, 4, 5, 6, 7], isFibLessThan10)
''');
      checkResult(runtime, [1, 2, 3, 4, 5, 6]);
    });

    test('list.reduce with recursive sum helper', () {
      final RuntimeFacade runtime = getRuntime('''
sumDigits(n) = if (n < 10) n else (n % 10) + sumDigits(num.floor(n / 10))
addDigitSums(a, b) = a + sumDigits(num.floor(b))
main = list.reduce([123, 456, 789], 0, addDigitSums)
''');
      checkResult(runtime, 45);
    });
  });

  group('Higher-Order Function Error Cases', () {
    test('list.filter throws when custom predicate returns number', () {
      final RuntimeFacade runtime = getRuntime('''
returnNumber(n) = n * 2
main = list.filter([1, 2, 3], returnNumber)
''');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (InvalidArgumentTypesError e) => e.toString(),
            'message',
            allOf(
              contains('list.filter'),
              contains('Boolean'),
              contains('Number'),
            ),
          ),
        ),
      );
    });

    test('list.filter throws when custom predicate returns string', () {
      final RuntimeFacade runtime = getRuntime('''
returnString(n) = "not a boolean"
main = list.filter([1, 2, 3], returnString)
''');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (InvalidArgumentTypesError e) => e.toString(),
            'message',
            allOf(
              contains('list.filter'),
              contains('Boolean'),
              contains('String'),
            ),
          ),
        ),
      );
    });

    test('list.all throws when custom predicate returns number', () {
      final RuntimeFacade runtime = getRuntime('''
returnNumber(n) = n + 1
main = list.all([1, 2, 3], returnNumber)
''');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (InvalidArgumentTypesError e) => e.toString(),
            'message',
            allOf(
              contains('list.all'),
              contains('Boolean'),
              contains('Number'),
            ),
          ),
        ),
      );
    });

    test('list.any throws when custom predicate returns string', () {
      final RuntimeFacade runtime = getRuntime('''
returnString(n) = "hello"
main = list.any([1, 2, 3], returnString)
''');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (InvalidArgumentTypesError e) => e.toString(),
            'message',
            allOf(
              contains('list.any'),
              contains('Boolean'),
              contains('String'),
            ),
          ),
        ),
      );
    });

    test('list.none throws when custom predicate returns list', () {
      final RuntimeFacade runtime = getRuntime('''
returnList(n) = [n]
main = list.none([1, 2, 3], returnList)
''');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (InvalidArgumentTypesError e) => e.toString(),
            'message',
            allOf(
              contains('list.none'),
              contains('Boolean'),
              contains('List'),
            ),
          ),
        ),
      );
    });

    test('list.sort throws when custom comparator returns boolean', () {
      final RuntimeFacade runtime = getRuntime('''
badCompare(a, b) = a > b
main = list.sort([3, 1, 2], badCompare)
''');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (InvalidArgumentTypesError e) => e.toString(),
            'message',
            allOf(
              contains('list.sort'),
              contains('Number'),
              contains('Boolean'),
            ),
          ),
        ),
      );
    });

    test('list.sort throws when custom comparator returns string', () {
      final RuntimeFacade runtime = getRuntime('''
stringCompare(a, b) = "comparison"
main = list.sort([3, 1, 2], stringCompare)
''');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (InvalidArgumentTypesError e) => e.toString(),
            'message',
            allOf(
              contains('list.sort'),
              contains('Number'),
              contains('String'),
            ),
          ),
        ),
      );
    });

    test('list.map with non-function second argument throws error', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.map([1, 2, 3], 42)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (InvalidArgumentTypesError e) => e.toString(),
            'message',
            contains('list.map'),
          ),
        ),
      );
    });

    test('list.filter with non-function second argument throws error', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.filter([1, 2, 3], "not a function")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (InvalidArgumentTypesError e) => e.toString(),
            'message',
            contains('list.filter'),
          ),
        ),
      );
    });

    test('list.reduce with non-function third argument throws error', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.reduce([1, 2, 3], 0, true)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (InvalidArgumentTypesError e) => e.toString(),
            'message',
            contains('list.reduce'),
          ),
        ),
      );
    });

    test('list.sort with non-function second argument throws error', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.sort([3, 1, 2], [1, 2, 3])',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (InvalidArgumentTypesError e) => e.toString(),
            'message',
            contains('list.sort'),
          ),
        ),
      );
    });

    test('list.zip with non-function third argument throws error', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.zip([1, 2], [3, 4], 99)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (InvalidArgumentTypesError e) => e.toString(),
            'message',
            contains('list.zip'),
          ),
        ),
      );
    });
  });

  group('Functions Returning Functions', () {
    test('function returning core function reference', () {
      final RuntimeFacade runtime = getRuntime('''
getAbs = num.abs
main = getAbs()(-5)
''');
      checkResult(runtime, 5);
    });

    test('function returning custom function reference', () {
      final RuntimeFacade runtime = getRuntime('''
double(n) = n * 2
getDoubler = double
main = getDoubler()(10)
''');
      checkResult(runtime, 20);
    });

    test('function selecting which function to return', () {
      final RuntimeFacade runtime = getRuntime('''
double(n) = n * 2
triple(n) = n * 3
selectOp(useDouble) = if (useDouble) double else triple
main = selectOp(true)(5)
''');
      checkResult(runtime, 10);
    });

    test('function selecting which function to return (false branch)', () {
      final RuntimeFacade runtime = getRuntime('''
double(n) = n * 2
triple(n) = n * 3
selectOp(useDouble) = if (useDouble) double else triple
main = selectOp(false)(5)
''');
      checkResult(runtime, 15);
    });

    test('returned function used with list.map', () {
      final RuntimeFacade runtime = getRuntime('''
double(n) = n * 2
triple(n) = n * 3
selectOp(useDouble) = if (useDouble) double else triple
main = list.map([1, 2, 3], selectOp(true))
''');
      checkResult(runtime, [2, 4, 6]);
    });
  });

  group('Boundary Value Cases', () {
    test('list.all returns false on first failing element (short-circuit)', () {
      final RuntimeFacade runtime = getRuntime('''
lessThanThree(n) = n < 3
main = list.all([1, 2, 5, 1], lessThanThree)
''');
      checkResult(runtime, false);
    });

    test('list.any returns true on first matching element (short-circuit)', () {
      final RuntimeFacade runtime = getRuntime('''
greaterThanThree(n) = n > 3
main = list.any([1, 2, 5, 1], greaterThanThree)
''');
      checkResult(runtime, true);
    });

    test(
      'list.none returns false on first matching element (short-circuit)',
      () {
        final RuntimeFacade runtime = getRuntime('''
isZero(n) = n == 0
main = list.none([1, 0, 2, 3], isZero)
''');
        checkResult(runtime, false);
      },
    );

    test('list.filter with predicate matching all elements', () {
      final RuntimeFacade runtime = getRuntime('''
isPositive(n) = n > 0
main = list.filter([1, 2, 3, 4, 5], isPositive)
''');
      checkResult(runtime, [1, 2, 3, 4, 5]);
    });

    test('list.filter with predicate matching no elements', () {
      final RuntimeFacade runtime = getRuntime('''
isNegative(n) = n < 0
main = list.filter([1, 2, 3, 4, 5], isNegative)
''');
      checkResult(runtime, []);
    });

    test('list.reduce accumulates from left to right', () {
      final RuntimeFacade runtime = getRuntime('''
subtract(a, b) = a - b
main = list.reduce([1, 2, 3], 10, subtract)
''');
      checkResult(runtime, 4);
    });

    test('list.zip with unequal lists retains extra first list elements', () {
      final RuntimeFacade runtime = getRuntime('''
add(a, b) = a + b
main = list.zip([1, 2, 3, 4, 5], [10, 20], add)
''');
      checkResult(runtime, [11, 22, 3, 4, 5]);
    });

    test('list.zip with unequal lists retains extra second list elements', () {
      final RuntimeFacade runtime = getRuntime('''
add(a, b) = a + b
main = list.zip([1, 2], [10, 20, 30, 40], add)
''');
      checkResult(runtime, [11, 22, 30, 40]);
    });
  });
}
