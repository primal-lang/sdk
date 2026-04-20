@Tags(['runtime'])
library;

import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Main', () {
    test('parameterless main returns constant', () {
      final RuntimeFacade runtime = getRuntime('main() = 42');
      checkResult(runtime, 42);
    });

    test('main with single argument', () {
      final RuntimeFacade runtime = getRuntime('main(a) = a');
      expect(runtime.executeMain(['hello']), '"hello"');
    });

    test('main with multiple arguments', () {
      final RuntimeFacade runtime = getRuntime(
        'main(a, b, c) = to.string(a) + to.string(b) + to.string(c)',
      );
      expect(runtime.executeMain(['aaa', 'bbb', 'ccc']), '"aaabbbccc"');
    });

    test('main calls custom helper function', () {
      final RuntimeFacade runtime = getRuntime(
        'double(x) = x * 2\nmain() = double(5)',
      );
      checkResult(runtime, 10);
    });

    test('hasMain is true when main is defined', () {
      final RuntimeFacade runtime = getRuntime('main() = 1');
      expect(runtime.hasMain, true);
    });

    test('hasMain is false when main is not defined', () {
      final RuntimeFacade runtime = getRuntime('f(x) = x');
      expect(runtime.hasMain, false);
    });

    group('return types', () {
      test('main returns boolean true', () {
        final RuntimeFacade runtime = getRuntime('main() = true');
        checkResult(runtime, true);
      });

      test('main returns boolean false', () {
        final RuntimeFacade runtime = getRuntime('main() = false');
        checkResult(runtime, false);
      });

      test('main returns string', () {
        final RuntimeFacade runtime = getRuntime('main() = "hello world"');
        checkResult(runtime, '"hello world"');
      });

      test('main returns empty string', () {
        final RuntimeFacade runtime = getRuntime('main() = ""');
        checkResult(runtime, '""');
      });

      test('main returns list', () {
        final RuntimeFacade runtime = getRuntime('main() = [1, 2, 3]');
        checkResult(runtime, '[1, 2, 3]');
      });

      test('main returns empty list', () {
        final RuntimeFacade runtime = getRuntime('main() = []');
        checkResult(runtime, '[]');
      });

      test('main returns nested list', () {
        final RuntimeFacade runtime = getRuntime('main() = [[1, 2], [3, 4]]');
        checkResult(runtime, '[[1, 2], [3, 4]]');
      });

      test('main returns map', () {
        final RuntimeFacade runtime = getRuntime('main() = {"a": 1, "b": 2}');
        checkResult(runtime, {'"a"': 1, '"b"': 2});
      });

      test('main returns empty map', () {
        final RuntimeFacade runtime = getRuntime('main() = {}');
        checkResult(runtime, {});
      });

      test('main returns negative number', () {
        final RuntimeFacade runtime = getRuntime('main() = -42');
        checkResult(runtime, -42);
      });

      test('main returns decimal number', () {
        final RuntimeFacade runtime = getRuntime('main() = 3.14159');
        checkResult(runtime, 3.14159);
      });
    });

    group('conditionals', () {
      test('main uses if-else returning then branch', () {
        final RuntimeFacade runtime = getRuntime('main() = if (true) 1 else 2');
        checkResult(runtime, 1);
      });

      test('main uses if-else returning else branch', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = if (false) 1 else 2',
        );
        checkResult(runtime, 2);
      });

      test('main uses nested conditionals', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = if (false) 1 else if (true) 2 else 3',
        );
        checkResult(runtime, 2);
      });

      test('main uses conditional with comparison', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = if (5 > 3) "greater" else "lesser"',
        );
        checkResult(runtime, '"greater"');
      });
    });

    group('function composition', () {
      test('main calls nested custom functions', () {
        final RuntimeFacade runtime = getRuntime(
          'add1(x) = x + 1\nadd2(x) = add1(add1(x))\nmain() = add2(5)',
        );
        checkResult(runtime, 7);
      });

      test('main calls chain of three custom functions', () {
        final RuntimeFacade runtime = getRuntime(
          'f(x) = x * 2\ng(x) = f(x) + 1\nh(x) = g(x) * 3\nmain() = h(5)',
        );
        checkResult(runtime, 33);
      });

      test('main calls recursive helper function', () {
        final RuntimeFacade runtime = getRuntime(
          'factorial(n) = if (n <= 1) 1 else n * factorial(n - 1)\nmain() = factorial(5)',
        );
        checkResult(runtime, 120);
      });

      test('main uses mutually recursive functions', () {
        final RuntimeFacade runtime = getRuntime(
          'isEven(n) = if (n == 0) true else isOdd(n - 1)\nisOdd(n) = if (n == 0) false else isEven(n - 1)\nmain() = isEven(10)',
        );
        checkResult(runtime, true);
      });
    });

    group('standard library integration', () {
      test('main calls standard library function directly', () {
        final RuntimeFacade runtime = getRuntime('main() = num.add(10, 20)');
        checkResult(runtime, 30);
      });

      test('main uses string concatenation via standard library', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str.concat("hello", " world")',
        );
        checkResult(runtime, '"hello world"');
      });

      test('main uses list operations', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list.length([1, 2, 3])',
        );
        checkResult(runtime, 3);
      });
    });

    group('argument handling', () {
      test('main with empty arguments list passed explicitly', () {
        final RuntimeFacade runtime = getRuntime('main() = 42');
        expect(runtime.executeMain([]), '42');
      });

      test('main with null arguments defaults to empty list', () {
        final RuntimeFacade runtime = getRuntime('main() = 42');
        expect(runtime.executeMain(null), '42');
      });

      test('main argument is used in computation', () {
        final RuntimeFacade runtime = getRuntime(
          'main(x) = to.number(x) * 2',
        );
        expect(runtime.executeMain(['21']), '42');
      });

      test('main arguments preserve order', () {
        final RuntimeFacade runtime = getRuntime(
          'main(a, b, c) = [a, b, c]',
        );
        expect(runtime.executeMain(['x', 'y', 'z']), '["x", "y", "z"]');
      });

      test('main with argument containing spaces', () {
        final RuntimeFacade runtime = getRuntime('main(a) = a');
        expect(runtime.executeMain(['hello world']), '"hello world"');
      });
    });

    group('edge cases', () {
      test('main returns zero', () {
        final RuntimeFacade runtime = getRuntime('main() = 0');
        checkResult(runtime, 0);
      });

      test('main with single element list', () {
        final RuntimeFacade runtime = getRuntime('main() = [42]');
        checkResult(runtime, '[42]');
      });

      test('main with mixed type list', () {
        final RuntimeFacade runtime = getRuntime('main() = [1, "two", true]');
        checkResult(runtime, '[1, "two", true]');
      });

      test('main computes expression inline', () {
        final RuntimeFacade runtime = getRuntime('main() = 2 + 3 * 4');
        checkResult(runtime, 14);
      });

      test('main with large number', () {
        final RuntimeFacade runtime = getRuntime('main() = 9999999999');
        checkResult(runtime, 9999999999);
      });

      test('main returns deeply nested list', () {
        final RuntimeFacade runtime = getRuntime('main() = [[[[1]]]]');
        checkResult(runtime, '[[[[1]]]]');
      });

      test('main returns very small decimal', () {
        final RuntimeFacade runtime = getRuntime('main() = 0.000001');
        checkResult(runtime, 0.000001);
      });

      test('main returns negative zero', () {
        final RuntimeFacade runtime = getRuntime('main() = 0 - 0');
        checkResult(runtime, 0);
      });

      test('main returns result of division producing decimal', () {
        final RuntimeFacade runtime = getRuntime('main() = 1 / 2');
        checkResult(runtime, 0.5);
      });

      test('main returns map with numeric value', () {
        final RuntimeFacade runtime = getRuntime('main() = {"key": 123}');
        checkResult(runtime, {'"key"': 123});
      });

      test('main returns map with nested map', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = {"outer": {"inner": 1}}',
        );
        checkResult(runtime, {
          '"outer"': {'"inner"': 1},
        });
      });

      test('main returns list containing map', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = [{"a": 1}, {"b": 2}]',
        );
        checkResult(runtime, '[{"a": 1}, {"b": 2}]');
      });

      test('main returns map containing list', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = {"items": [1, 2, 3]}',
        );
        checkResult(runtime, {'"items"': '[1, 2, 3]'});
      });
    });

    group('string handling', () {
      test('main returns string with newline', () {
        final RuntimeFacade runtime = getRuntime('main() = "line1\\nline2"');
        checkResult(runtime, '"line1\nline2"');
      });

      test('main returns string with tab', () {
        final RuntimeFacade runtime = getRuntime('main() = "col1\\tcol2"');
        checkResult(runtime, '"col1\tcol2"');
      });

      test('main returns string with escaped quote', () {
        final RuntimeFacade runtime = getRuntime('main() = "say \\"hello\\""');
        checkResult(runtime, '"say "hello""');
      });

      test('main returns string with backslash', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = "path\\\\to\\\\file"',
        );
        checkResult(runtime, '"path\\to\\file"');
      });

      test('main returns string with unicode characters', () {
        final RuntimeFacade runtime = getRuntime('main() = "caf\u00e9"');
        checkResult(runtime, '"caf\u00e9"');
      });

      test('main returns whitespace only string', () {
        final RuntimeFacade runtime = getRuntime('main() = "   "');
        checkResult(runtime, '"   "');
      });
    });

    group('numeric operations', () {
      test('main returns result of subtraction', () {
        final RuntimeFacade runtime = getRuntime('main() = 10 - 3');
        checkResult(runtime, 7);
      });

      test('main returns result of multiplication', () {
        final RuntimeFacade runtime = getRuntime('main() = 6 * 7');
        checkResult(runtime, 42);
      });

      test('main returns result of division', () {
        final RuntimeFacade runtime = getRuntime('main() = 84 / 2');
        checkResult(runtime, 42.0);
      });

      test('main returns result of modulo', () {
        final RuntimeFacade runtime = getRuntime('main() = 17 % 5');
        checkResult(runtime, 2);
      });

      test('main returns negative result', () {
        final RuntimeFacade runtime = getRuntime('main() = 5 - 10');
        checkResult(runtime, -5);
      });

      test('main returns chained arithmetic', () {
        final RuntimeFacade runtime = getRuntime('main() = 1 + 2 + 3 + 4');
        checkResult(runtime, 10);
      });

      test('main returns grouped arithmetic', () {
        final RuntimeFacade runtime = getRuntime('main() = (1 + 2) * (3 + 4)');
        checkResult(runtime, 21);
      });
    });

    group('comparison operations', () {
      test('main returns greater than comparison', () {
        final RuntimeFacade runtime = getRuntime('main() = 5 > 3');
        checkResult(runtime, true);
      });

      test('main returns less than comparison', () {
        final RuntimeFacade runtime = getRuntime('main() = 5 < 3');
        checkResult(runtime, false);
      });

      test('main returns equality comparison true', () {
        final RuntimeFacade runtime = getRuntime('main() = 5 == 5');
        checkResult(runtime, true);
      });

      test('main returns equality comparison false', () {
        final RuntimeFacade runtime = getRuntime('main() = 5 == 3');
        checkResult(runtime, false);
      });

      test('main returns inequality comparison', () {
        final RuntimeFacade runtime = getRuntime('main() = 5 != 3');
        checkResult(runtime, true);
      });

      test('main returns greater than or equal comparison', () {
        final RuntimeFacade runtime = getRuntime('main() = 5 >= 5');
        checkResult(runtime, true);
      });

      test('main returns less than or equal comparison', () {
        final RuntimeFacade runtime = getRuntime('main() = 5 <= 5');
        checkResult(runtime, true);
      });
    });

    group('logical operations', () {
      test('main returns and operation true', () {
        final RuntimeFacade runtime = getRuntime('main() = true && true');
        checkResult(runtime, true);
      });

      test('main returns and operation false', () {
        final RuntimeFacade runtime = getRuntime('main() = true && false');
        checkResult(runtime, false);
      });

      test('main returns or operation true', () {
        final RuntimeFacade runtime = getRuntime('main() = false || true');
        checkResult(runtime, true);
      });

      test('main returns or operation false', () {
        final RuntimeFacade runtime = getRuntime('main() = false || false');
        checkResult(runtime, false);
      });

      test('main returns negation true', () {
        final RuntimeFacade runtime = getRuntime('main() = !false');
        checkResult(runtime, true);
      });

      test('main returns negation false', () {
        final RuntimeFacade runtime = getRuntime('main() = !true');
        checkResult(runtime, false);
      });

      test('main returns chained logical operations', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = true && true || false',
        );
        checkResult(runtime, true);
      });

      test('main returns grouped logical operations', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = true && (false || true)',
        );
        checkResult(runtime, true);
      });
    });

    group('higher order functions', () {
      test('main uses list.map with custom function', () {
        final RuntimeFacade runtime = getRuntime(
          'double(x) = x * 2\nmain() = list.map([1, 2, 3], double)',
        );
        checkResult(runtime, '[2, 4, 6]');
      });

      test('main uses list.filter with custom predicate', () {
        final RuntimeFacade runtime = getRuntime(
          'isPositive(x) = x > 0\nmain() = list.filter([-1, 0, 1, 2], isPositive)',
        );
        checkResult(runtime, '[1, 2]');
      });

      test('main uses list.reduce with standard library function', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list.reduce([1, 2, 3, 4], 0, num.add)',
        );
        checkResult(runtime, 10);
      });

      test('main passes function as argument', () {
        final RuntimeFacade runtime = getRuntime(
          'apply(f, x) = f(x)\nadd10(n) = n + 10\nmain() = apply(add10, 32)',
        );
        checkResult(runtime, 42);
      });

      test('main uses function returning from conditional', () {
        final RuntimeFacade runtime = getRuntime(
          'double(x) = x * 2\ntriple(x) = x * 3\ngetMultiplier(useDouble) = if (useDouble) double else triple\nmain() = (getMultiplier(true))(5)',
        );
        checkResult(runtime, 10);
      });
    });

    group('set operations', () {
      test('main returns set from list', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = set.new([1, 2, 2, 3])',
        );
        checkResult(runtime, '{1, 2, 3}');
      });

      test('main returns empty set', () {
        final RuntimeFacade runtime = getRuntime('main() = set.new([])');
        checkResult(runtime, '{}');
      });

      test('main checks set membership', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = set.contains(set.new([1, 2, 3]), 2)',
        );
        checkResult(runtime, true);
      });

      test('main returns set length', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = set.length(set.new([1, 2, 3]))',
        );
        checkResult(runtime, 3);
      });
    });

    group('argument edge cases', () {
      test('main with argument containing equals sign', () {
        final RuntimeFacade runtime = getRuntime('main(a) = a');
        expect(runtime.executeMain(['key=value']), '"key=value"');
      });

      test('main with argument containing comma', () {
        final RuntimeFacade runtime = getRuntime('main(a) = a');
        expect(runtime.executeMain(['a,b,c']), '"a,b,c"');
      });

      test('main with argument containing parentheses', () {
        final RuntimeFacade runtime = getRuntime('main(a) = a');
        expect(runtime.executeMain(['(test)']), '"(test)"');
      });

      test('main with argument containing brackets', () {
        final RuntimeFacade runtime = getRuntime('main(a) = a');
        expect(runtime.executeMain(['[1,2,3]']), '"[1,2,3]"');
      });

      test('main with argument containing braces', () {
        final RuntimeFacade runtime = getRuntime('main(a) = a');
        expect(runtime.executeMain(['{key:value}']), '"{key:value}"');
      });

      test('main with many arguments', () {
        final RuntimeFacade runtime = getRuntime(
          'main(a, b, c, d, e) = to.string(a) + to.string(b) + to.string(c) + to.string(d) + to.string(e)',
        );
        expect(runtime.executeMain(['1', '2', '3', '4', '5']), '"12345"');
      });

      test('main argument used in arithmetic after conversion', () {
        final RuntimeFacade runtime = getRuntime(
          'main(a, b) = to.number(a) + to.number(b)',
        );
        expect(runtime.executeMain(['10', '20']), '30');
      });
    });

    group('complex conditionals', () {
      test('main with deeply nested conditionals', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = if (false) 1 else if (false) 2 else if (false) 3 else 4',
        );
        checkResult(runtime, 4);
      });

      test('main with conditional in list element', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = [if (true) 1 else 0, if (false) 1 else 0]',
        );
        checkResult(runtime, '[1, 0]');
      });

      test('main with conditional in function call', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = num.add(if (true) 10 else 0, if (false) 0 else 5)',
        );
        checkResult(runtime, 15);
      });

      test('main with conditional comparing strings', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = if ("a" == "a") "match" else "no match"',
        );
        checkResult(runtime, '"match"');
      });

      test('main with conditional using logical operators', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = if (true && false) "both" else if (true || false) "either" else "neither"',
        );
        checkResult(runtime, '"either"');
      });
    });

    group('list operations from main', () {
      test('main returns list first element', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list.first([1, 2, 3])',
        );
        checkResult(runtime, 1);
      });

      test('main returns list rest', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list.rest([1, 2, 3])',
        );
        checkResult(runtime, '[2, 3]');
      });

      test('main returns list length', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list.length([1, 2, 3, 4, 5])',
        );
        checkResult(runtime, 5);
      });

      test('main returns list concatenation', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list.concat([1, 2], [3, 4])',
        );
        checkResult(runtime, '[1, 2, 3, 4]');
      });

      test('main returns reversed list', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list.reverse([1, 2, 3])',
        );
        checkResult(runtime, '[3, 2, 1]');
      });

      test('main returns element at index', () {
        final RuntimeFacade runtime = getRuntime('main() = [10, 20, 30][1]');
        checkResult(runtime, 20);
      });
    });

    group('map operations from main', () {
      test('main returns map value by key', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = {"name": "Alice"}["name"]',
        );
        checkResult(runtime, '"Alice"');
      });

      test('main returns map keys', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = map.keys({"a": 1, "b": 2})',
        );
        checkResult(runtime, '["a", "b"]');
      });

      test('main returns map values', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = map.values({"a": 1, "b": 2})',
        );
        checkResult(runtime, '[1, 2]');
      });

      test('main checks map contains key', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = map.containsKey({"a": 1}, "a")',
        );
        checkResult(runtime, true);
      });

      test('main returns map length', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = map.length({"a": 1, "b": 2, "c": 3})',
        );
        checkResult(runtime, 3);
      });
    });

    group('string operations from main', () {
      test('main returns string length', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str.length("hello")',
        );
        checkResult(runtime, 5);
      });

      test('main returns uppercase string', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str.uppercase("hello")',
        );
        checkResult(runtime, '"HELLO"');
      });

      test('main returns lowercase string', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str.lowercase("HELLO")',
        );
        checkResult(runtime, '"hello"');
      });

      test('main returns substring', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str.substring("hello world", 0, 5)',
        );
        checkResult(runtime, '"hello"');
      });

      test('main returns string contains check', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str.contains("hello world", "world")',
        );
        checkResult(runtime, true);
      });

      test('main returns split string as list', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str.split("a,b,c", ",")',
        );
        checkResult(runtime, '["a", "b", "c"]');
      });

      test('main returns trimmed string', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = str.trim("  hello  ")',
        );
        checkResult(runtime, '"hello"');
      });
    });

    group('boundary conditions', () {
      test('main returns empty list head via safe operation', () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list.length([])',
        );
        checkResult(runtime, 0);
      });

      test('main returns string character at valid index', () {
        final RuntimeFacade runtime = getRuntime('main() = "hello"[0]');
        checkResult(runtime, '"h"');
      });

      test('main returns last character of string', () {
        final RuntimeFacade runtime = getRuntime('main() = "hello"[4]');
        checkResult(runtime, '"o"');
      });

      test('main with computation resulting in zero', () {
        final RuntimeFacade runtime = getRuntime('main() = 5 - 5');
        checkResult(runtime, 0);
      });

      test('main with boolean expression evaluating entire list', () {
        final RuntimeFacade runtime = getRuntime(
          'id(x) = x\nmain() = list.all([true, true, true], id)',
        );
        checkResult(runtime, true);
      });

      test('main with boolean expression evaluating any', () {
        final RuntimeFacade runtime = getRuntime(
          'id(x) = x\nmain() = list.any([false, false, true], id)',
        );
        checkResult(runtime, true);
      });
    });

    group('recursive patterns', () {
      test('main with fibonacci', () {
        final RuntimeFacade runtime = getRuntime(
          'fib(n) = if (n <= 1) n else fib(n - 1) + fib(n - 2)\nmain() = fib(10)',
        );
        checkResult(runtime, 55);
      });

      test('main with sum of list via recursion', () {
        final RuntimeFacade runtime = getRuntime(
          'sumList(items) = if (list.length(items) == 0) 0 else list.first(items) + sumList(list.rest(items))\nmain() = sumList([1, 2, 3, 4, 5])',
        );
        checkResult(runtime, 15);
      });

      test('main with count down via recursion', () {
        final RuntimeFacade runtime = getRuntime(
          'countdown(n) = if (n <= 0) [] else list.concat([n], countdown(n - 1))\nmain() = countdown(5)',
        );
        checkResult(runtime, '[5, 4, 3, 2, 1]');
      });

      test('main with GCD via recursion', () {
        final RuntimeFacade runtime = getRuntime(
          'gcd(a, b) = if (b == 0) a else gcd(b, a % b)\nmain() = gcd(48, 18)',
        );
        checkResult(runtime, 6);
      });
    });

    group('type coercion and conversion', () {
      test('main converts number to string', () {
        final RuntimeFacade runtime = getRuntime('main() = to.string(42)');
        checkResult(runtime, '"42"');
      });

      test('main converts boolean to string', () {
        final RuntimeFacade runtime = getRuntime('main() = to.string(true)');
        checkResult(runtime, '"true"');
      });

      test('main converts string to number', () {
        final RuntimeFacade runtime = getRuntime('main() = to.number("42")');
        checkResult(runtime, 42);
      });

      test('main converts string to boolean', () {
        final RuntimeFacade runtime = getRuntime('main() = to.boolean("true")');
        checkResult(runtime, true);
      });

      test('main checks if value is number', () {
        final RuntimeFacade runtime = getRuntime('main() = is.number(42)');
        checkResult(runtime, true);
      });

      test('main checks if value is string', () {
        final RuntimeFacade runtime = getRuntime('main() = is.string("hello")');
        checkResult(runtime, true);
      });

      test('main checks if value is list', () {
        final RuntimeFacade runtime = getRuntime('main() = is.list([1, 2, 3])');
        checkResult(runtime, true);
      });

      test('main checks if value is boolean', () {
        final RuntimeFacade runtime = getRuntime('main() = is.boolean(true)');
        checkResult(runtime, true);
      });

      test('main checks if number is not a string', () {
        final RuntimeFacade runtime = getRuntime('main() = is.string(42)');
        checkResult(runtime, false);
      });

      test('main checks if string is not a number', () {
        final RuntimeFacade runtime = getRuntime('main() = is.number("hello")');
        checkResult(runtime, false);
      });
    });
  });
}
