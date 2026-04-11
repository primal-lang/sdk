@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
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

    test('grade function boundary at B', () {
      final RuntimeFacade runtime = getRuntime('''
grade(score) = if (score >= 90) "A" else if (score >= 80) "B" else if (score >= 70) "C" else if (score >= 60) "D" else "F"
main = grade(80)
''');
      checkResult(runtime, '"B"');
    });

    test('grade function boundary at D', () {
      final RuntimeFacade runtime = getRuntime('''
grade(score) = if (score >= 90) "A" else if (score >= 80) "B" else if (score >= 70) "C" else if (score >= 60) "D" else "F"
main = grade(60)
''');
      checkResult(runtime, '"D"');
    });

    test('grade function boundary just below B', () {
      final RuntimeFacade runtime = getRuntime('''
grade(score) = if (score >= 90) "A" else if (score >= 80) "B" else if (score >= 70) "C" else if (score >= 60) "D" else "F"
main = grade(79)
''');
      checkResult(runtime, '"C"');
    });

    test('inRange at lower boundary', () {
      final RuntimeFacade runtime = getRuntime('''
inRange(n, lo, hi) = (n >= lo) && (n <= hi)
main = inRange(1, 1, 10)
''');
      checkResult(runtime, true);
    });

    test('inRange at upper boundary', () {
      final RuntimeFacade runtime = getRuntime('''
inRange(n, lo, hi) = (n >= lo) && (n <= hi)
main = inRange(10, 1, 10)
''');
      checkResult(runtime, true);
    });

    test('inRange below lower boundary', () {
      final RuntimeFacade runtime = getRuntime('''
inRange(n, lo, hi) = (n >= lo) && (n <= hi)
main = inRange(0, 1, 10)
''');
      checkResult(runtime, false);
    });

    test('isEdge when n is neither lo nor hi', () {
      final RuntimeFacade runtime = getRuntime('''
isEdge(n, lo, hi) = (n == lo) || (n == hi)
main = isEdge(5, 1, 10)
''');
      checkResult(runtime, false);
    });

    test('isEdge when n equals lo', () {
      final RuntimeFacade runtime = getRuntime('''
isEdge(n, lo, hi) = (n == lo) || (n == hi)
main = isEdge(1, 1, 10)
''');
      checkResult(runtime, true);
    });

    test('function using not operator with true', () {
      final RuntimeFacade runtime = getRuntime('''
isNonPositive(n) = !(n > 0)
main = isNonPositive(5)
''');
      checkResult(runtime, false);
    });

    test('function with string concatenation operator', () {
      final RuntimeFacade runtime = getRuntime('''
greet(name) = "Hello, " + name + "!"
main = greet("World")
''');
      checkResult(runtime, '"Hello, World!"');
    });

    test('function with comparison returning different types', () {
      final RuntimeFacade runtime = getRuntime('''
describe(n) = if (n > 0) "positive" else if (n < 0) "negative" else 0
main = describe(0)
''');
      checkResult(runtime, 0);
    });

    test('function with many parameters', () {
      final RuntimeFacade runtime = getRuntime('''
sum6(a, b, c, d, e, f) = a + b + c + d + e + f
main = sum6(1, 2, 3, 4, 5, 6)
''');
      checkResult(runtime, 21);
    });
  });

  group('Function Argument Errors', () {
    test('calling function with too few arguments throws error', () {
      final RuntimeFacade runtime = getRuntime('''
add(a, b) = a + b
apply(f, x) = f(x)
main = apply(add, 1)
''');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentCountError>().having(
            (InvalidArgumentCountError error) => error.toString(),
            'message',
            allOf(contains('Expected: 2'), contains('Actual: 1')),
          ),
        ),
      );
    });

    test('calling function with too many arguments throws error', () {
      final RuntimeFacade runtime = getRuntime('''
identity(x) = x
apply3(f, a, b, c) = f(a, b, c)
main = apply3(identity, 1, 2, 3)
''');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentCountError>().having(
            (InvalidArgumentCountError error) => error.toString(),
            'message',
            allOf(contains('Expected: 1'), contains('Actual: 3')),
          ),
        ),
      );
    });

    test('undefined function in dynamic call throws error', () {
      final RuntimeFacade runtime = getRuntime('''
wrap(f, x) = f(x)
getValue = 42
main = wrap(getValue(), 5)
''');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidFunctionError>()),
      );
    });

    test('type mismatch in function argument throws error', () {
      final RuntimeFacade runtime = getRuntime('''
double(n) = n * 2
main = double("not a number")
''');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });
  });

  group('Parameterless Function Variations', () {
    test('parameterless function returning boolean', () {
      final RuntimeFacade runtime = getRuntime('''
alwaysTrue = true
main = alwaysTrue()
''');
      checkResult(runtime, true);
    });

    test('parameterless function returning negative number', () {
      final RuntimeFacade runtime = getRuntime('''
negativeValue = -42
main = negativeValue()
''');
      checkResult(runtime, -42);
    });

    test('parameterless function returning decimal', () {
      final RuntimeFacade runtime = getRuntime('''
piApprox = 3.14159
main = piApprox()
''');
      checkResult(runtime, 3.14159);
    });

    test('parameterless function returning empty map', () {
      final RuntimeFacade runtime = getRuntime('''
emptyMap = {}
main = map.length(emptyMap())
''');
      checkResult(runtime, 0);
    });

    test('parameterless function returning set', () {
      final RuntimeFacade runtime = getRuntime('''
uniqueNumbers = set.new([1, 2, 3])
main = set.length(uniqueNumbers())
''');
      checkResult(runtime, 3);
    });

    test('chained parameterless function calls', () {
      final RuntimeFacade runtime = getRuntime('''
a = 1
b = a() + 1
c = b() + 1
d = c() + 1
main = d()
''');
      checkResult(runtime, 4);
    });
  });

  group('Complex Function Interactions', () {
    test('function composition with type conversion', () {
      final RuntimeFacade runtime = getRuntime('''
numberToString(n) = to.string(n)
addPrefix(s) = str.concat("Value: ", s)
main = addPrefix(numberToString(42))
''');
      checkResult(runtime, '"Value: 42"');
    });

    test('function composition with boolean conversion', () {
      final RuntimeFacade runtime = getRuntime('''
isPositive(n) = n > 0
boolToString(b) = to.string(b)
main = boolToString(isPositive(-5))
''');
      checkResult(runtime, '"false"');
    });

    test('function with nested conditional and arithmetic', () {
      final RuntimeFacade runtime = getRuntime('''
clamp(n, minVal, maxVal) = if (n < minVal) minVal else if (n > maxVal) maxVal else n
main = clamp(150, 0, 100)
''');
      checkResult(runtime, 100);
    });

    test('clamp function returns input when in range', () {
      final RuntimeFacade runtime = getRuntime('''
clamp(n, minVal, maxVal) = if (n < minVal) minVal else if (n > maxVal) maxVal else n
main = clamp(50, 0, 100)
''');
      checkResult(runtime, 50);
    });

    test('clamp function returns min when below range', () {
      final RuntimeFacade runtime = getRuntime('''
clamp(n, minVal, maxVal) = if (n < minVal) minVal else if (n > maxVal) maxVal else n
main = clamp(-50, 0, 100)
''');
      checkResult(runtime, 0);
    });

    test('function returning list from computation', () {
      final RuntimeFacade runtime = getRuntime('''
range(start, endVal) = if (start >= endVal) [] else list.insertStart(range(start + 1, endVal), start)
main = range(1, 5)
''');
      checkResult(runtime, [1, 2, 3, 4]);
    });

    test('function with map creation and access', () {
      final RuntimeFacade runtime = getRuntime('''
createPerson(name, age) = {"name": name, "age": age}
getName(person) = map.at(person, "name")
main = getName(createPerson("Alice", 30))
''');
      checkResult(runtime, '"Alice"');
    });

    test('function chaining with multiple types', () {
      final RuntimeFacade runtime = getRuntime('''
createList(x) = [x]
getFirst(xs) = list.first(xs)
double(n) = n * 2
main = double(getFirst(createList(21)))
''');
      checkResult(runtime, 42);
    });
  });

  group('Function with Special Values', () {
    test('function handling zero in division', () {
      final RuntimeFacade runtime = getRuntime('''
safeDivide(a, b) = if (b == 0) 0 else a / b
main = safeDivide(10, 0)
''');
      checkResult(runtime, 0);
    });

    test('function with very large number', () {
      final RuntimeFacade runtime = getRuntime('''
addLarge(n) = n + 1000000000
main = addLarge(1)
''');
      checkResult(runtime, 1000000001);
    });

    test('function with very small decimal', () {
      final RuntimeFacade runtime = getRuntime('''
addSmall(n) = n + 0.000001
main = addSmall(0)
''');
      checkResult(runtime, 0.000001);
    });

    test('function preserving unicode in string', () {
      final RuntimeFacade runtime = getRuntime('''
addEmoji(s) = str.concat(s, " \u2764")
main = addEmoji("Hello")
''');
      checkResult(runtime, '"Hello \u2764"');
    });

    test('function with empty string parameter', () {
      final RuntimeFacade runtime = getRuntime('''
wrapInBrackets(s) = str.concat("[", str.concat(s, "]"))
main = wrapInBrackets("")
''');
      checkResult(runtime, '"[]"');
    });

    test('function with whitespace string', () {
      final RuntimeFacade runtime = getRuntime('''
trimAndLength(s) = str.length(str.trim(s))
main = trimAndLength("   ")
''');
      checkResult(runtime, 0);
    });
  });

  group('Nested Function Definitions', () {
    test('five-level function chain', () {
      final RuntimeFacade runtime = getRuntime('''
level1(n) = n + 1
level2(n) = level1(n) + 1
level3(n) = level2(n) + 1
level4(n) = level3(n) + 1
level5(n) = level4(n) + 1
main = level5(0)
''');
      checkResult(runtime, 5);
    });

    test('function referencing multiple other functions', () {
      final RuntimeFacade runtime = getRuntime('''
addOne(n) = n + 1
double(n) = n * 2
triple(n) = n * 3
combined(n) = addOne(n) + double(n) + triple(n)
main = combined(10)
''');
      checkResult(runtime, 61);
    });

    test('diamond dependency between functions', () {
      final RuntimeFacade runtime = getRuntime('''
base(n) = n
left(n) = base(n) + 1
right(n) = base(n) + 2
combined(n) = left(n) + right(n)
main = combined(10)
''');
      checkResult(runtime, 23);
    });

    test('function calling itself indirectly through another', () {
      final RuntimeFacade runtime = getRuntime('''
countDown(n) = if (n <= 0) 0 else helper(n)
helper(n) = countDown(n - 1) + 1
main = countDown(5)
''');
      checkResult(runtime, 5);
    });
  });

  group('Function Composition with Operators', () {
    test('composition with modulo operator', () {
      final RuntimeFacade runtime = getRuntime('''
isEven(n) = n % 2 == 0
main = isEven(4)
''');
      checkResult(runtime, true);
    });

    test('composition with modulo operator odd case', () {
      final RuntimeFacade runtime = getRuntime('''
isEven(n) = n % 2 == 0
main = isEven(5)
''');
      checkResult(runtime, false);
    });

    test('composition with greater than or equal', () {
      final RuntimeFacade runtime = getRuntime('''
isAdult(age) = age >= 18
main = isAdult(18)
''');
      checkResult(runtime, true);
    });

    test('composition with less than or equal', () {
      final RuntimeFacade runtime = getRuntime('''
isMinor(age) = age <= 17
main = isMinor(17)
''');
      checkResult(runtime, true);
    });

    test('composition with not equal', () {
      final RuntimeFacade runtime = getRuntime('''
isNotZero(n) = n != 0
main = isNotZero(5)
''');
      checkResult(runtime, true);
    });

    test('composition with not equal false case', () {
      final RuntimeFacade runtime = getRuntime('''
isNotZero(n) = n != 0
main = isNotZero(0)
''');
      checkResult(runtime, false);
    });

    test('composition with negative unary operator', () {
      final RuntimeFacade runtime = getRuntime('''
negate(n) = -n
doubleNegate(n) = negate(negate(n))
main = doubleNegate(5)
''');
      checkResult(runtime, 5);
    });
  });

  group('Complex Boolean Logic in Functions', () {
    test('function with and and or combined', () {
      final RuntimeFacade runtime = getRuntime('''
isValidAge(age) = (age >= 0) && (age <= 120)
isWorking(age) = (age >= 18) && (age <= 65)
isWorkingAdult(age) = isValidAge(age) && isWorking(age)
main = isWorkingAdult(30)
''');
      checkResult(runtime, true);
    });

    test('isWorkingAdult with too young age', () {
      final RuntimeFacade runtime = getRuntime('''
isValidAge(age) = (age >= 0) && (age <= 120)
isWorking(age) = (age >= 18) && (age <= 65)
isWorkingAdult(age) = isValidAge(age) && isWorking(age)
main = isWorkingAdult(10)
''');
      checkResult(runtime, false);
    });

    test('function with triple or', () {
      final RuntimeFacade runtime = getRuntime('''
isSpecial(n) = (n == 1) || (n == 7) || (n == 13)
main = isSpecial(7)
''');
      checkResult(runtime, true);
    });

    test('isSpecial with non-special number', () {
      final RuntimeFacade runtime = getRuntime('''
isSpecial(n) = (n == 1) || (n == 7) || (n == 13)
main = isSpecial(5)
''');
      checkResult(runtime, false);
    });

    test('function with complex boolean expression', () {
      final RuntimeFacade runtime = getRuntime('''
isValid(x, y) = ((x > 0) && (y > 0)) || ((x < 0) && (y < 0))
main = isValid(5, 10)
''');
      checkResult(runtime, true);
    });

    test('isValid with mixed signs returns false', () {
      final RuntimeFacade runtime = getRuntime('''
isValid(x, y) = ((x > 0) && (y > 0)) || ((x < 0) && (y < 0))
main = isValid(5, -10)
''');
      checkResult(runtime, false);
    });

    test('isValid with both negative returns true', () {
      final RuntimeFacade runtime = getRuntime('''
isValid(x, y) = ((x > 0) && (y > 0)) || ((x < 0) && (y < 0))
main = isValid(-5, -10)
''');
      checkResult(runtime, true);
    });
  });

  group('Function Return Type Variations', () {
    test('function returning nested list', () {
      final RuntimeFacade runtime = getRuntime('''
makeMatrix(a, b, c, d) = [[a, b], [c, d]]
main = makeMatrix(1, 2, 3, 4)
''');
      checkResult(runtime, [
        [1, 2],
        [3, 4],
      ]);
    });

    test('function returning nested map', () {
      final RuntimeFacade runtime = getRuntime('''
makePerson(name, city, country) = {"name": name, "address": {"city": city, "country": country}}
main = makePerson("Alice", "Paris", "France")
''');
      checkResult(
        runtime,
        '{"name": "Alice", "address": {"city": "Paris", "country": "France"}}',
      );
    });

    test('function returning list of maps', () {
      final RuntimeFacade runtime = getRuntime('''
makeItems(n1, n2) = [{"value": n1}, {"value": n2}]
main = makeItems(10, 20)
''');
      checkResult(runtime, '[{"value": 10}, {"value": 20}]');
    });

    test('function returning map with list value', () {
      final RuntimeFacade runtime = getRuntime('''
makeContainer(xs) = {"items": xs, "count": list.length(xs)}
main = makeContainer([1, 2, 3])
''');
      checkResult(runtime, '{"items": [1, 2, 3], "count": 3}');
    });
  });

  group('Error Handling in Composition', () {
    test('try catches division by zero in custom function', () {
      final RuntimeFacade runtime = getRuntime('''
divide(a, b) = a / b
safeDivide(a, b) = try(divide(a, b), 0)
main = safeDivide(10, 0)
''');
      checkResult(runtime, 0);
    });

    test('try catches list index out of bounds', () {
      final RuntimeFacade runtime = getRuntime('''
getElement(xs, i) = xs[i]
safeGet(xs, i) = try(getElement(xs, i), -1)
main = safeGet([1, 2, 3], 10)
''');
      checkResult(runtime, -1);
    });

    test('try catches map key not found', () {
      final RuntimeFacade runtime = getRuntime('''
getKey(m, k) = map.at(m, k)
safeGetKey(m, k) = try(getKey(m, k), "not found")
main = safeGetKey({"a": 1}, "b")
''');
      checkResult(runtime, '"not found"');
    });

    test('nested try with multiple error sources', () {
      final RuntimeFacade runtime = getRuntime('''
mayFail1(x) = if (x < 0) error.throw(0, "negative") else x
mayFail2(x) = if (x > 100) error.throw(0, "too large") else x
validate(x) = try(mayFail1(try(mayFail2(x), 50)), 0)
main = validate(150)
''');
      checkResult(runtime, 50);
    });

    test('nested try with outer error', () {
      final RuntimeFacade runtime = getRuntime('''
mayFail1(x) = if (x < 0) error.throw(0, "negative") else x
mayFail2(x) = if (x > 100) error.throw(0, "too large") else x
validate(x) = try(mayFail1(try(mayFail2(x), -10)), 0)
main = validate(150)
''');
      checkResult(runtime, 0);
    });
  });
}
