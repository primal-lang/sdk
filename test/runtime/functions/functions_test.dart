@Tags(['runtime'])
library;

import 'package:primal/compiler/lowering/runtime_facade.dart';
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

    test('conditional positive case', () {
      final RuntimeFacade runtime = getRuntime('''
classify(n) = if (n > 0) "positive" else if (n < 0) "negative" else "zero"
main = classify(5)
''');
      checkResult(runtime, '"positive"');
    });

    test('identity function', () {
      final RuntimeFacade runtime = getRuntime('''
identity(x) = x
main = identity(42)
''');
      checkResult(runtime, 42);
    });

    test('identity function with string', () {
      final RuntimeFacade runtime = getRuntime('''
identity(x) = x
main = identity("hello")
''');
      checkResult(runtime, '"hello"');
    });

    test('function returning list', () {
      final RuntimeFacade runtime = getRuntime('''
pair(a, b) = [a, b]
main = pair(1, 2)
''');
      checkResult(runtime, [1, 2]);
    });

    test('function returning map', () {
      final RuntimeFacade runtime = getRuntime('''
makeEntry(k, v) = {k: v}
main = makeEntry("name", "Alice")
''');
      checkResult(runtime, '{"name": "Alice"}');
    });

    test('function returning boolean', () {
      final RuntimeFacade runtime = getRuntime('''
isPositive(n) = n > 0
main = isPositive(5)
''');
      checkResult(runtime, true);
    });

    test('function returning boolean false', () {
      final RuntimeFacade runtime = getRuntime('''
isPositive(n) = n > 0
main = isPositive(-5)
''');
      checkResult(runtime, false);
    });

    test('function with map operations', () {
      final RuntimeFacade runtime = getRuntime('''
getValue(m, k) = map.at(m, k)
main = getValue({"x": 10, "y": 20}, "y")
''');
      checkResult(runtime, 20);
    });

    test('function with set operations', () {
      final RuntimeFacade runtime = getRuntime('''
makeSet(xs) = set.new(xs)
main = set.length(makeSet([1, 2, 2, 3]))
''');
      checkResult(runtime, 3);
    });
  });

  group('Deep Function Composition', () {
    test('four-level function chain', () {
      final RuntimeFacade runtime = getRuntime('''
a(n) = n + 1
b(n) = a(n) * 2
c(n) = b(n) - 3
d(n) = c(n) / 2
main = d(5)
''');
      checkResult(runtime, 4.5);
    });

    test('deeply nested core function calls', () {
      final RuntimeFacade runtime = getRuntime(
        'main = num.abs(num.negative(num.abs(num.negative(5))))',
      );
      checkResult(runtime, 5);
    });

    test('composition with different types', () {
      final RuntimeFacade runtime = getRuntime('''
double(n) = n * 2
stringify(n) = to.string(n)
prefix(s) = str.concat("Value: ", s)
main = prefix(stringify(double(21)))
''');
      checkResult(runtime, '"Value: 42"');
    });

    test('composition with list to number', () {
      final RuntimeFacade runtime = getRuntime('''
sum(xs) = list.reduce(xs, 0, num.add)
double(n) = n * 2
main = double(sum([1, 2, 3, 4, 5]))
''');
      checkResult(runtime, 30);
    });
  });

  group('Parameterless Function Chains', () {
    test('multiple parameterless functions calling each other', () {
      final RuntimeFacade runtime = getRuntime('''
base = 10
doubled = base() * 2
tripled = doubled() + base()
main = tripled()
''');
      checkResult(runtime, 30);
    });

    test('parameterless function returning list', () {
      final RuntimeFacade runtime = getRuntime('''
numbers = [1, 2, 3, 4, 5]
main = list.length(numbers())
''');
      checkResult(runtime, 5);
    });

    test('parameterless function returning map', () {
      final RuntimeFacade runtime = getRuntime('''
config = {"name": "test", "value": 42}
main = map.at(config(), "value")
''');
      checkResult(runtime, 42);
    });

    test('parameterless function returning empty list', () {
      final RuntimeFacade runtime = getRuntime('''
empty = []
main = list.length(empty())
''');
      checkResult(runtime, 0);
    });
  });

  group('Function Composition Edge Cases', () {
    test('composition with empty string', () {
      final RuntimeFacade runtime = getRuntime('''
wrap(s) = str.concat("[", str.concat(s, "]"))
main = wrap("")
''');
      checkResult(runtime, '"[]"');
    });

    test('composition with empty list', () {
      final RuntimeFacade runtime = getRuntime('''
count(xs) = list.length(xs)
double(n) = n * 2
main = double(count([]))
''');
      checkResult(runtime, 0);
    });

    test('composition with single element list', () {
      final RuntimeFacade runtime = getRuntime('''
getFirst(xs) = list.first(xs)
double(n) = n * 2
main = double(getFirst([21]))
''');
      checkResult(runtime, 42);
    });

    test('composition with boundary number', () {
      final RuntimeFacade runtime = getRuntime('''
addOne(n) = n + 1
main = addOne(0)
''');
      checkResult(runtime, 1);
    });

    test('composition with negative result', () {
      final RuntimeFacade runtime = getRuntime('''
subtract(a, b) = a - b
double(n) = n * 2
main = double(subtract(3, 10))
''');
      checkResult(runtime, -14);
    });
  });

  group('Error Handling in Function Composition', () {
    test('try catches error in composed function', () {
      final RuntimeFacade runtime = getRuntime('''
safeDivide(a, b) = try(a / b, 0)
main = safeDivide(10, 0)
''');
      checkResult(runtime, 0);
    });

    test('try with nested function calls', () {
      final RuntimeFacade runtime = getRuntime('''
getFirst(xs) = list.first(xs)
safeFirst(xs) = try(getFirst(xs), -1)
main = safeFirst([])
''');
      checkResult(runtime, -1);
    });

    test('error propagates through function calls', () {
      final RuntimeFacade runtime = getRuntime('''
double(n) = n * 2
unsafe(xs) = double(list.first(xs))
main = try(unsafe([]), 0)
''');
      checkResult(runtime, 0);
    });

    test('try in middle of composition chain', () {
      final RuntimeFacade runtime = getRuntime('''
parse(s) = try(to.number(s), 0)
double(n) = n * 2
main = double(parse("abc"))
''');
      checkResult(runtime, 0);
    });
  });

  group('Complex Custom Function Scenarios', () {
    test('function with multiple conditional branches', () {
      final RuntimeFacade runtime = getRuntime('''
grade(score) = if (score >= 90) "A" else if (score >= 80) "B" else if (score >= 70) "C" else if (score >= 60) "D" else "F"
main = grade(75)
''');
      checkResult(runtime, '"C"');
    });

    test('grade function boundary at A', () {
      final RuntimeFacade runtime = getRuntime('''
grade(score) = if (score >= 90) "A" else if (score >= 80) "B" else if (score >= 70) "C" else if (score >= 60) "D" else "F"
main = grade(90)
''');
      checkResult(runtime, '"A"');
    });

    test('grade function boundary at F', () {
      final RuntimeFacade runtime = getRuntime('''
grade(score) = if (score >= 90) "A" else if (score >= 80) "B" else if (score >= 70) "C" else if (score >= 60) "D" else "F"
main = grade(59)
''');
      checkResult(runtime, '"F"');
    });

    test('function using logical operators', () {
      final RuntimeFacade runtime = getRuntime('''
inRange(n, lo, hi) = (n >= lo) && (n <= hi)
main = inRange(5, 1, 10)
''');
      checkResult(runtime, true);
    });

    test('function using logical operators out of range', () {
      final RuntimeFacade runtime = getRuntime('''
inRange(n, lo, hi) = (n >= lo) && (n <= hi)
main = inRange(15, 1, 10)
''');
      checkResult(runtime, false);
    });

    test('function using or operator', () {
      final RuntimeFacade runtime = getRuntime('''
isEdge(n, lo, hi) = (n == lo) || (n == hi)
main = isEdge(10, 1, 10)
''');
      checkResult(runtime, true);
    });

    test('function using not operator', () {
      final RuntimeFacade runtime = getRuntime('''
isNonPositive(n) = !(n > 0)
main = isNonPositive(-5)
''');
      checkResult(runtime, true);
    });

    test('function with list concatenation', () {
      final RuntimeFacade runtime = getRuntime('''
combine(xs, ys) = list.concat(xs, ys)
main = combine([1, 2], [3, 4])
''');
      checkResult(runtime, [1, 2, 3, 4]);
    });

    test('function with nested list access', () {
      final RuntimeFacade runtime = getRuntime('''
getNestedValue(xs, i, j) = xs[i][j]
main = getNestedValue([[1, 2], [3, 4]], 1, 0)
''');
      checkResult(runtime, 3);
    });
  });
}
