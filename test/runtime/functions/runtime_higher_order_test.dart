import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Higher order functions', () {
    test('Function as parameter', () {
      final Runtime runtime = getRuntime('''
foo(f, v) = f(v)
main = foo(num.abs, -4)
''');
      checkResult(runtime, 4);
    });

    test('function stored in variable and called indirectly', () {
      final Runtime runtime = getRuntime('''
bar = num.abs
foo(v) = bar()(v)
main = foo(-4)
''');
      checkResult(runtime, 4);
    });

    test('function stored in variable and passed as argument', () {
      final Runtime runtime = getRuntime('''
bar = num.abs
foo(f, v) = f(v)
main = foo(bar(), -4)
''');
      checkResult(runtime, 4);
    });

    test('core function prints its signature', () {
      final Runtime runtime = getRuntime('main = num.add');
      checkResult(runtime, '"num.add(a: Number, b: Number)"');
    });

    test('custom function prints its signature', () {
      final Runtime runtime = getRuntime('''
foo(a, b) = a + b
main = foo
''');
      checkResult(runtime, '"foo(a: Any, b: Any)"');
    });

    test('list of functions prints their signatures', () {
      final Runtime runtime = getRuntime('main = [num.add, num.abs]');
      checkResult(
        runtime,
        '["num.add(a: Number, b: Number)", "num.abs(a: Number)"]',
      );
    });
  });

  group('Custom Functions with Higher-Order', () {
    test('list.map with custom function', () {
      final Runtime runtime = getRuntime('''
double(n) = n * 2
main = list.map([1, 2, 3], double)
''');
      checkResult(runtime, [2, 4, 6]);
    });

    test('list.filter with custom predicate', () {
      final Runtime runtime = getRuntime('''
isSmall(n) = n < 5
main = list.filter([1, 7, 3, 9, 2], isSmall)
''');
      checkResult(runtime, [1, 3, 2]);
    });

    test('list.reduce with custom function', () {
      final Runtime runtime = getRuntime('''
mul(a, b) = a * b
main = list.reduce([1, 2, 3, 4], 1, mul)
''');
      checkResult(runtime, 24);
    });

    test('list.sort with custom comparator', () {
      final Runtime runtime = getRuntime('''
reverseCompare(a, b) = num.compare(b, a)
main = list.sort([3, 1, 5, 2, 4], reverseCompare)
''');
      checkResult(runtime, [5, 4, 3, 2, 1]);
    });

    test('list.all with custom predicate', () {
      final Runtime runtime = getRuntime('''
isPositive(n) = n > 0
main = list.all([1, 2, 3], isPositive)
''');
      checkResult(runtime, true);
    });

    test('list.any with custom predicate', () {
      final Runtime runtime = getRuntime('''
isNeg(n) = n < 0
main = list.any([1, -2, 3], isNeg)
''');
      checkResult(runtime, true);
    });

    test('list.none with custom predicate', () {
      final Runtime runtime = getRuntime('''
isNeg(n) = n < 0
main = list.none([1, 2, 3], isNeg)
''');
      checkResult(runtime, true);
    });
  });
}
