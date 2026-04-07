@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('@', () {
    test('returns list element at index', () {
      final RuntimeFacade runtime = getRuntime('main = [10, 20, 30] @ 1');
      checkResult(runtime, 20);
    });

    test('returns first list element', () {
      final RuntimeFacade runtime = getRuntime('main = [10, 20, 30] @ 0');
      checkResult(runtime, 10);
    });

    test('returns last list element', () {
      final RuntimeFacade runtime = getRuntime('main = [10, 20, 30] @ 2');
      checkResult(runtime, 30);
    });

    test('returns map value by key', () {
      final RuntimeFacade runtime = getRuntime(
        'main = {"a": 1, "b": 2} @ "a"',
      );
      checkResult(runtime, 1);
    });

    test('returns string character at index', () {
      final RuntimeFacade runtime = getRuntime('main = "hello" @ 0');
      checkResult(runtime, '"h"');
    });

    test('returns string character at middle index', () {
      final RuntimeFacade runtime = getRuntime('main = "hello" @ 2');
      checkResult(runtime, '"l"');
    });

    test('throws ElementNotFoundError for missing map key', () {
      final RuntimeFacade runtime = getRuntime(
        'main = {"a": 1} @ "z"',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<ElementNotFoundError>()),
      );
    });

    test('throws InvalidArgumentTypesError for invalid types', () {
      final RuntimeFacade runtime = getRuntime('''
x = 42
main = x @ 0
''');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    // @ infix operator tests (additional)
    test('@ operator chained', () {
      final RuntimeFacade runtime = getRuntime(
        'main = [[1, 2], [3, 4]] @ 1 @ 0',
      );
      checkResult(runtime, 3);
    });

    test('bracket syntax returns list element', () {
      final RuntimeFacade runtime = getRuntime('main = [10, 20, 30][1]');
      checkResult(runtime, 20);
    });

    test('bracket syntax returns map value', () {
      final RuntimeFacade runtime = getRuntime('main = {"a": 1, "b": 2}["a"]');
      checkResult(runtime, 1);
    });

    test('bracket syntax returns string character', () {
      final RuntimeFacade runtime = getRuntime('main = "hello"[0]');
      checkResult(runtime, '"h"');
    });

    test('@ operator with grapheme returns full grapheme', () {
      final RuntimeFacade runtime = getRuntime('main = "a👨‍👩‍👧b" @ 1');
      checkResult(runtime, '"👨‍👩‍👧"');
    });

    test('bracket syntax with grapheme returns full grapheme', () {
      final RuntimeFacade runtime = getRuntime('main = "a👨‍👩‍👧b"[1]');
      checkResult(runtime, '"👨‍👩‍👧"');
    });

    // List edge cases
    test('returns element from single-element list', () {
      final RuntimeFacade runtime = getRuntime('main = [42] @ 0');
      checkResult(runtime, 42);
    });

    test('throws IndexOutOfBoundsError for list index out of bounds', () {
      final RuntimeFacade runtime = getRuntime('main = [10, 20, 30] @ 5');
      expect(
        runtime.executeMain,
        throwsA(isA<IndexOutOfBoundsError>()),
      );
    });

    test('throws IndexOutOfBoundsError for list index equal to length', () {
      final RuntimeFacade runtime = getRuntime('main = [10, 20, 30] @ 3');
      expect(
        runtime.executeMain,
        throwsA(isA<IndexOutOfBoundsError>()),
      );
    });

    test('throws NegativeIndexError for negative list index', () {
      final RuntimeFacade runtime = getRuntime('main = [10, 20, 30] @ -1');
      expect(
        runtime.executeMain,
        throwsA(isA<NegativeIndexError>()),
      );
    });

    test('throws IndexOutOfBoundsError for empty list access', () {
      final RuntimeFacade runtime = getRuntime('main = [] @ 0');
      expect(
        runtime.executeMain,
        throwsA(isA<IndexOutOfBoundsError>()),
      );
    });

    // String edge cases
    test('returns last string character', () {
      final RuntimeFacade runtime = getRuntime('main = "hello" @ 4');
      checkResult(runtime, '"o"');
    });

    test('returns character from single-character string', () {
      final RuntimeFacade runtime = getRuntime('main = "x" @ 0');
      checkResult(runtime, '"x"');
    });

    test('throws IndexOutOfBoundsError for string index out of bounds', () {
      final RuntimeFacade runtime = getRuntime('main = "hello" @ 10');
      expect(
        runtime.executeMain,
        throwsA(isA<IndexOutOfBoundsError>()),
      );
    });

    test('throws IndexOutOfBoundsError for string index equal to length', () {
      final RuntimeFacade runtime = getRuntime('main = "hello" @ 5');
      expect(
        runtime.executeMain,
        throwsA(isA<IndexOutOfBoundsError>()),
      );
    });

    test('throws NegativeIndexError for negative string index', () {
      final RuntimeFacade runtime = getRuntime('main = "hello" @ -1');
      expect(
        runtime.executeMain,
        throwsA(isA<NegativeIndexError>()),
      );
    });

    test('throws IndexOutOfBoundsError for empty string access', () {
      final RuntimeFacade runtime = getRuntime('main = "" @ 0');
      expect(
        runtime.executeMain,
        throwsA(isA<IndexOutOfBoundsError>()),
      );
    });

    // Map edge cases
    test('returns map value by number key', () {
      final RuntimeFacade runtime = getRuntime(
        'main = {1: "one", 2: "two"} @ 1',
      );
      checkResult(runtime, '"one"');
    });

    test('throws ElementNotFoundError for empty map access', () {
      final RuntimeFacade runtime = getRuntime('main = {} @ "key"');
      expect(
        runtime.executeMain,
        throwsA(isA<ElementNotFoundError>()),
      );
    });

    // Additional invalid type combinations
    test('throws InvalidArgumentTypesError for boolean operand', () {
      final RuntimeFacade runtime = getRuntime('''
x = true
main = x @ 0
''');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('throws InvalidArgumentTypesError for list with string index', () {
      final RuntimeFacade runtime = getRuntime('main = [1, 2, 3] @ "0"');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('throws InvalidArgumentTypesError for string with string index', () {
      final RuntimeFacade runtime = getRuntime('main = "hello" @ "0"');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });
  });
}
