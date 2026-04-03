@Tags(['runtime'])
library;

import 'package:primal/compiler/semantic/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Function Composition', () {
    test('nested core function calls', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.abs(num.negative(5))',
      );
      checkResult(runtime, 5);
    });

    test('composed arithmetic', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.pow(num.add(1, 2), num.sub(5, 2))',
      );
      checkResult(runtime, 27);
    });

    test('chained string operations', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.uppercase(str.reverse("hello"))',
      );
      checkResult(runtime, '"OLLEH"');
    });

    test('composed list and arithmetic', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.add(list.first([10, 20]), list.last([30, 40]))',
      );
      checkResult(runtime, 50);
    });

    test('multi-function program', () {
      final RuntimeFacade runtime = getRuntime('''
square(n) = n * n
cube(n) = n * square(n)
main = cube(3)
''');
      checkResult(runtime, 27);
    });

    test('function chain with three levels', () {
      final RuntimeFacade runtime = getRuntime('''
inc(n) = n + 1
double(n) = n * 2
apply(f, g, v) = f(g(v))
main = apply(double, inc, 3)
''');
      checkResult(runtime, 8);
    });
  });

  group('Multiple Custom Functions', () {
    test('custom functions calling each other', () {
      final RuntimeFacade runtime = getRuntime('''
add1(n) = n + 1
add2(n) = add1(add1(n))
add4(n) = add2(add2(n))
main = add4(0)
''');
      checkResult(runtime, 4);
    });

    test('conditional with custom functions', () {
      final RuntimeFacade runtime = getRuntime('''
classify(n) = if (n > 0) "positive" else if (n < 0) "negative" else "zero"
main = classify(-5)
''');
      checkResult(runtime, '"negative"');
    });

    test('conditional zero case', () {
      final RuntimeFacade runtime = getRuntime('''
classify(n) = if (n > 0) "positive" else if (n < 0) "negative" else "zero"
main = classify(0)
''');
      checkResult(runtime, '"zero"');
    });

    test('custom function with list operations', () {
      final RuntimeFacade runtime = getRuntime('''
sumList(xs) = list.reduce(xs, 0, num.add)
average(xs) = sumList(xs) / list.length(xs)
main = average([10, 20, 30])
''');
      checkResult(runtime, 20.0);
    });

    test('parameterless custom function', () {
      final RuntimeFacade runtime = getRuntime('''
pi = 3.14159
circleArea(r) = pi() * r * r
main = circleArea(1)
''');
      checkResult(runtime, 3.14159);
    });
  });
}
