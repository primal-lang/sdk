@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/library/error/throw.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Control', () {
    test('if/else 1', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (true) "yes" else "no"',
      );
      checkResult(runtime, '"yes"');
    });

    test('if/else 2', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (false) "yes" else "no"',
      );
      checkResult(runtime, '"no"');
    });

    test('if/else 3', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (true) 1 + 2 else 42',
      );
      checkResult(runtime, 3);
    });

    test(
      'if/else with non-boolean condition throws InvalidArgumentTypesError',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main = if (42) "yes" else "no"',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (e) => e.toString(),
              'message',
              allOf(contains('if'), contains('Number')),
            ),
          ),
        );
      },
    );

    test('if/else with string condition throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if ("true") "yes" else "no"',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(contains('if'), contains('String')),
          ),
        ),
      );
    });

    test('if/else with list condition throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if ([1, 2, 3]) "yes" else "no"',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(contains('if'), contains('List')),
          ),
        ),
      );
    });

    test('if/else evaluates else branch expression', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (false) 1 else 2 + 3',
      );
      checkResult(runtime, 5);
    });

    test('nested if/else returns outer then branch', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (true) (if (false) 1 else 2) else 3',
      );
      checkResult(runtime, 2);
    });

    test('nested if/else returns outer else branch', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (false) 1 else (if (true) 2 else 3)',
      );
      checkResult(runtime, 2);
    });

    test('if/else with comparison expression as condition', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (5 > 3) "greater" else "not greater"',
      );
      checkResult(runtime, '"greater"');
    });

    test('if/else with equality expression as condition', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (1 == 1) "equal" else "not equal"',
      );
      checkResult(runtime, '"equal"');
    });

    test('if/else with logical negation as condition', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (!false) "yes" else "no"',
      );
      checkResult(runtime, '"yes"');
    });

    test('if/else with function call as condition', () {
      final RuntimeFacade runtime = getRuntime(
        'isPositive(n) = n > 0\nmain = if (isPositive(5)) "positive" else "not positive"',
      );
      checkResult(runtime, '"positive"');
    });

    test('if/else short-circuits and does not evaluate unused branch', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (true) 1 else error.throw(0, "should not be evaluated")',
      );
      checkResult(runtime, 1);
    });

    test('if/else short-circuits when condition is false', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (false) error.throw(0, "should not be evaluated") else 2',
      );
      checkResult(runtime, 2);
    });

    test('if/else returns function result', () {
      final RuntimeFacade runtime = getRuntime(
        'double(n) = n * 2\nmain = if (true) double(5) else double(10)',
      );
      checkResult(runtime, 10);
    });

    test('if/else returns list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (true) [1, 2, 3] else [4, 5, 6]',
      );
      checkResult(runtime, '[1, 2, 3]');
    });

    test('if/else returns map', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (false) {"a": 1} else {"b": 2}',
      );
      checkResult(runtime, '{"b": 2}');
    });

    test('if/else with variable as condition', () {
      final RuntimeFacade runtime = getRuntime(
        'flag(x) = x > 0\nmain = if (flag(5)) "yes" else "no"',
      );
      checkResult(runtime, '"yes"');
    });

    test('if/else with logical AND as condition', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (true && true) "both true" else "not both"',
      );
      checkResult(runtime, '"both true"');
    });

    test('if/else with logical AND false case', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (true && false) "both true" else "not both"',
      );
      checkResult(runtime, '"not both"');
    });

    test('if/else with logical OR as condition', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (false || true) "at least one" else "neither"',
      );
      checkResult(runtime, '"at least one"');
    });

    test('if/else with logical OR false case', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (false || false) "at least one" else "neither"',
      );
      checkResult(runtime, '"neither"');
    });

    test('if/else with map condition throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if ({"key": true}) "yes" else "no"',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(contains('if'), contains('Map')),
          ),
        ),
      );
    });

    test('if/else with double negation', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (!!true) "yes" else "no"',
      );
      checkResult(runtime, '"yes"');
    });

    test('deeply nested if/else chain', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (false) 1 else (if (false) 2 else (if (true) 3 else 4))',
      );
      checkResult(runtime, 3);
    });

    test('if/else with inequality expression as condition', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (5 != 3) "not equal" else "equal"',
      );
      checkResult(runtime, '"not equal"');
    });

    test('if/else with less than or equal comparison', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (3 <= 5) "less or equal" else "greater"',
      );
      checkResult(runtime, '"less or equal"');
    });

    test('if/else with greater than or equal comparison', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (5 >= 5) "greater or equal" else "less"',
      );
      checkResult(runtime, '"greater or equal"');
    });

    test('if/else with less than comparison', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (2 < 5) "less" else "not less"',
      );
      checkResult(runtime, '"less"');
    });

    test('if/else with combined logical operators', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if ((true && false) || true) "yes" else "no"',
      );
      checkResult(runtime, '"yes"');
    });

    test('if/else with function call returning boolean', () {
      final RuntimeFacade runtime = getRuntime(
        'isEven(n) = n % 2 == 0\nmain = if (isEven(4)) "even" else "odd"',
      );
      checkResult(runtime, '"even"');
    });

    test(
      'if/else with empty list condition throws InvalidArgumentTypesError',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main = if ([]) "yes" else "no"',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (e) => e.toString(),
              'message',
              allOf(contains('if'), contains('List')),
            ),
          ),
        );
      },
    );

    test('if/else with zero condition throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (0) "yes" else "no"',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(contains('if'), contains('Number')),
          ),
        ),
      );
    });

    test('if/else returns number from then branch', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (true) 42 else 0',
      );
      checkResult(runtime, 42);
    });

    test('if/else returns number from else branch', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (false) 42 else 0',
      );
      checkResult(runtime, 0);
    });

    test('if/else returns boolean from branches', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (true) false else true',
      );
      checkResult(runtime, false);
    });
  });

  group('Try/Catch', () {
    test('try/catch 1', () {
      final RuntimeFacade runtime = getRuntime('main = try(1 / 2, 42)');
      checkResult(runtime, 0.5);
    });

    test('try/catch 2', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(error.throw(0, "Does not compute"), 42)',
      );
      checkResult(runtime, 42);
    });

    test('try/catch evaluates fallback expression', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(error.throw(0, "fail"), 1 + 2)',
      );
      checkResult(runtime, 3);
    });

    test('try catches division by zero', () {
      final RuntimeFacade runtime = getRuntime('main = try(1 / 0, -1)');
      checkResult(runtime, -1);
    });

    test('try catches parse error', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(to.number("abc"), 0)',
      );
      checkResult(runtime, 0);
    });

    test('try catches empty collection error', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(stack.pop(stack.new([])), "empty")',
      );
      checkResult(runtime, '"empty"');
    });

    test('try catches invalid map index error', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(map.at({}, "x"), "missing")',
      );
      checkResult(runtime, '"missing"');
    });

    test('try catches type mismatch error', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(1 + "string", "type error")',
      );
      checkResult(runtime, '"type error"');
    });

    test('try catches index out of bounds error', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(list.at([1, 2], 10), -1)',
      );
      checkResult(runtime, -1);
    });

    test('try catches empty queue dequeue error', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(queue.dequeue(queue.new([])), "empty queue")',
      );
      checkResult(runtime, '"empty queue"');
    });

    test('try with nested try returns outer fallback', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(try(1 / 0, error.throw(0, "inner")), "outer")',
      );
      checkResult(runtime, '"outer"');
    });

    test('try with nested try returns inner fallback', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(try(1 / 0, 42), "outer")',
      );
      checkResult(runtime, 42);
    });

    test('try with nested try returns successful inner value', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(try(1 + 1, 42), "outer")',
      );
      checkResult(runtime, 2);
    });

    test('try returns string on success', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try("hello", "fallback")',
      );
      checkResult(runtime, '"hello"');
    });

    test('try returns list on success', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try([1, 2, 3], [])',
      );
      checkResult(runtime, '[1, 2, 3]');
    });

    test('try returns map on success', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try({"a": 1}, {})',
      );
      checkResult(runtime, '{"a": 1}');
    });

    test('try returns boolean on success', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(true, false)',
      );
      checkResult(runtime, true);
    });

    test('try evaluates fallback to function result', () {
      final RuntimeFacade runtime = getRuntime(
        'fallback(x) = x * 2\nmain = try(1 / 0, fallback(21))',
      );
      checkResult(runtime, 42);
    });

    test('try catches modulo by zero error', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(10 % 0, "modulo error")',
      );
      checkResult(runtime, '"modulo error"');
    });

    test('try catches negative index error', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(list.at([1, 2, 3], -1), "negative index")',
      );
      checkResult(runtime, '"negative index"');
    });

    test('try with function call that succeeds', () {
      final RuntimeFacade runtime = getRuntime(
        'double(x) = x * 2\nmain = try(double(5), 0)',
      );
      checkResult(runtime, 10);
    });

    test('try with if/else in primary expression', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(if (true) 1 / 0 else 1, "caught")',
      );
      checkResult(runtime, '"caught"');
    });

    test('try with if/else in fallback expression', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(1 / 0, if (true) "yes" else "no")',
      );
      checkResult(runtime, '"yes"');
    });

    test('try catches empty list first error', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(list.first([]), "empty list")',
      );
      checkResult(runtime, '"empty list"');
    });

    test('try catches empty list last error', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(list.last([]), "empty list")',
      );
      checkResult(runtime, '"empty list"');
    });

    test('try where both expressions succeed returns primary', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(10, 20)',
      );
      checkResult(runtime, 10);
    });

    test('try returns fallback number on error', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(1 / 0, 999)',
      );
      checkResult(runtime, 999);
    });

    test('try returns fallback list on error', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(1 / 0, [1, 2, 3])',
      );
      checkResult(runtime, '[1, 2, 3]');
    });

    test('try returns fallback map on error', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(1 / 0, {"fallback": true})',
      );
      checkResult(runtime, '{"fallback": true}');
    });

    test('try catches string concatenation type error', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(str.concat(1, 2), "type error")',
      );
      checkResult(runtime, '"type error"');
    });

    test('try catches invalid sqrt argument error', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(num.sqrt(-1), "invalid sqrt")',
      );
      checkResult(runtime, '"invalid sqrt"');
    });

    test('try with deeply nested error', () {
      final RuntimeFacade runtime = getRuntime(
        'inner() = 1 / 0\nmiddle() = inner()\nouter() = middle()\nmain = try(outer(), "caught deep")',
      );
      checkResult(runtime, '"caught deep"');
    });

    test('try with error in fallback propagates error', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(1 / 0, error.throw(0, "fallback error"))',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<CustomError>().having(
            (e) => e.toString(),
            'message',
            contains('fallback error'),
          ),
        ),
      );
    });

    test('try with empty map access error', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(map.at({}, "missing"), "no key")',
      );
      checkResult(runtime, '"no key"');
    });

    test('try with boolean primary succeeds', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(1 > 2, true)',
      );
      checkResult(runtime, false);
    });

    test('try with comparison expression succeeds', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(5 == 5, false)',
      );
      checkResult(runtime, true);
    });

    test('try catches json parse error', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(json.decode("invalid json"), "parse error")',
      );
      checkResult(runtime, '"parse error"');
    });

    test('try catches recursion limit error', () {
      final RuntimeFacade runtime = getRuntime(
        'infinite(x) = infinite(x + 1)\nmain = try(infinite(0), "recursion")',
      );
      checkResult(runtime, '"recursion"');
    });

    test('try with arithmetic expression succeeds', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try((2 + 3) * 4, 0)',
      );
      checkResult(runtime, 20);
    });

    test('try with list operations succeeds', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(list.length([1, 2, 3]), 0)',
      );
      checkResult(runtime, 3);
    });
  });

  group('Error', () {
    test('throw', () {
      final RuntimeFacade runtime = getRuntime(
        'main = error.throw(-1, "Segmentation fault")',
      );
      expect(runtime.executeMain, throwsA(isA<CustomError>()));
    });

    test('throw with string error code', () {
      final RuntimeFacade runtime = getRuntime(
        'main = error.throw("ERR001", "Custom error")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<CustomError>().having(
            (e) => e.toString(),
            'message',
            contains('Custom error'),
          ),
        ),
      );
    });

    test('throw with numeric error code', () {
      final RuntimeFacade runtime = getRuntime(
        'main = error.throw(404, "Not found")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<CustomError>().having(
            (e) => e.toString(),
            'message',
            contains('Not found'),
          ),
        ),
      );
    });

    test('throw with list error code', () {
      final RuntimeFacade runtime = getRuntime(
        'main = error.throw([1, 2], "List error")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<CustomError>().having(
            (e) => e.toString(),
            'message',
            contains('List error'),
          ),
        ),
      );
    });

    test('throw with boolean error code', () {
      final RuntimeFacade runtime = getRuntime(
        'main = error.throw(false, "Boolean error")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<CustomError>().having(
            (e) => e.toString(),
            'message',
            contains('Boolean error'),
          ),
        ),
      );
    });

    test('throw with non-string message throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = error.throw(1, 123)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(contains('error.throw'), contains('Number')),
          ),
        ),
      );
    });

    test('throw with list as message throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = error.throw(1, [1, 2, 3])',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(contains('error.throw'), contains('List')),
          ),
        ),
      );
    });

    test('throw with boolean as message throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = error.throw(1, true)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(contains('error.throw'), contains('Boolean')),
          ),
        ),
      );
    });

    test('throw with expression as message', () {
      final RuntimeFacade runtime = getRuntime(
        'main = error.throw(0, str.concat("error: ", "details"))',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<CustomError>().having(
            (e) => e.toString(),
            'message',
            contains('error: details'),
          ),
        ),
      );
    });

    test('throw with expression as error code', () {
      final RuntimeFacade runtime = getRuntime(
        'main = error.throw(1 + 1, "computed code")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<CustomError>().having(
            (e) => e.code.toString(),
            'code',
            equals('2'),
          ),
        ),
      );
    });

    test('throw propagates through function calls', () {
      final RuntimeFacade runtime = getRuntime(
        'fail() = error.throw(0, "inner failure")\nmain = fail()',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<CustomError>().having(
            (e) => e.toString(),
            'message',
            contains('inner failure'),
          ),
        ),
      );
    });

    test('throw can be caught by try in outer scope', () {
      final RuntimeFacade runtime = getRuntime(
        'fail() = error.throw(0, "inner")\nmain = try(fail(), "caught")',
      );
      checkResult(runtime, '"caught"');
    });

    test('throw with empty string message', () {
      final RuntimeFacade runtime = getRuntime(
        'main = error.throw(0, "")',
      );
      expect(runtime.executeMain, throwsA(isA<CustomError>()));
    });

    test('throw with map error code', () {
      final RuntimeFacade runtime = getRuntime(
        'main = error.throw({"code": 500}, "Server error")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<CustomError>().having(
            (e) => e.toString(),
            'message',
            contains('Server error'),
          ),
        ),
      );
    });

    test('throw with zero error code', () {
      final RuntimeFacade runtime = getRuntime(
        'main = error.throw(0, "Zero error")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<CustomError>().having(
            (e) => e.code.toString(),
            'code',
            equals('0'),
          ),
        ),
      );
    });

    test('throw with float error code', () {
      final RuntimeFacade runtime = getRuntime(
        'main = error.throw(3.14, "Float error")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<CustomError>().having(
            (e) => e.code.toString(),
            'code',
            equals('3.14'),
          ),
        ),
      );
    });

    test('throw with negative error code', () {
      final RuntimeFacade runtime = getRuntime(
        'main = error.throw(-100, "Negative code")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<CustomError>().having(
            (e) => e.code.toString(),
            'code',
            equals('-100'),
          ),
        ),
      );
    });

    test('throw with map as message throws InvalidArgumentTypesError', () {
      final RuntimeFacade runtime = getRuntime(
        'main = error.throw(1, {"key": "value"})',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(contains('error.throw'), contains('Map')),
          ),
        ),
      );
    });

    test('throw with deeply nested function calls', () {
      final RuntimeFacade runtime = getRuntime(
        'level3() = error.throw(3, "deep")\nlevel2() = level3()\nlevel1() = level2()\nmain = level1()',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<CustomError>().having(
            (e) => e.toString(),
            'message',
            contains('deep'),
          ),
        ),
      );
    });

    test('throw caught at intermediate level', () {
      final RuntimeFacade runtime = getRuntime(
        'failing() = error.throw(0, "fail")\nhandling() = try(failing(), "handled")\nmain = handling()',
      );
      checkResult(runtime, '"handled"');
    });

    test('throw with very long message', () {
      final RuntimeFacade runtime = getRuntime(
        'main = error.throw(0, "This is a very long error message that contains a lot of text to ensure that the error handling can cope with lengthy descriptions")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<CustomError>().having(
            (e) => e.toString(),
            'message',
            contains('very long error message'),
          ),
        ),
      );
    });

    test('throw with empty list error code', () {
      final RuntimeFacade runtime = getRuntime(
        'main = error.throw([], "Empty list code")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<CustomError>().having(
            (e) => e.code.toString(),
            'code',
            equals('[]'),
          ),
        ),
      );
    });

    test('throw with empty map error code', () {
      final RuntimeFacade runtime = getRuntime(
        'main = error.throw({}, "Empty map code")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<CustomError>().having(
            (e) => e.code.toString(),
            'code',
            equals('{}'),
          ),
        ),
      );
    });

    test('throw with nested data structure as error code', () {
      final RuntimeFacade runtime = getRuntime(
        'main = error.throw({"errors": [1, 2, 3]}, "Nested code")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<CustomError>().having(
            (e) => e.toString(),
            'message',
            contains('Nested code'),
          ),
        ),
      );
    });

    test('throw with function result as error code', () {
      final RuntimeFacade runtime = getRuntime(
        'getCode() = 42\nmain = error.throw(getCode(), "Function code")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<CustomError>().having(
            (e) => e.code.toString(),
            'code',
            equals('42'),
          ),
        ),
      );
    });

    test('throw with function result as message', () {
      final RuntimeFacade runtime = getRuntime(
        'getMessage() = "Dynamic message"\nmain = error.throw(0, getMessage())',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<CustomError>().having(
            (e) => e.toString(),
            'message',
            contains('Dynamic message'),
          ),
        ),
      );
    });

    test('throw preserves error code type as number', () {
      final RuntimeFacade runtime = getRuntime(
        'main = error.throw(123, "Number code")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<CustomError>().having(
            (e) => e.code.toString(),
            'code',
            equals('123'),
          ),
        ),
      );
    });

    test('throw preserves error code type as string', () {
      final RuntimeFacade runtime = getRuntime(
        'main = error.throw("ERR_CODE", "String code")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<CustomError>().having(
            (e) => e.code.toString(),
            'code',
            contains('ERR_CODE'),
          ),
        ),
      );
    });
  });
}
