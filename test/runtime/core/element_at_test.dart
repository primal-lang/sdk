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

    // Additional map key types
    test('returns map value by boolean key', () {
      final RuntimeFacade runtime = getRuntime(
        'main = {true: "yes", false: "no"} @ true',
      );
      checkResult(runtime, '"yes"');
    });

    test('returns map value by false boolean key', () {
      final RuntimeFacade runtime = getRuntime(
        'main = {true: "yes", false: "no"} @ false',
      );
      checkResult(runtime, '"no"');
    });

    test('returns map value from mixed key types', () {
      final RuntimeFacade runtime = getRuntime(
        'main = {1: "one", "two": 2, true: "yes"} @ "two"',
      );
      checkResult(runtime, 2);
    });

    // Deeply nested structures
    test('@ operator triple chained on nested lists', () {
      final RuntimeFacade runtime = getRuntime(
        'main = [[[1, 2], [3, 4]], [[5, 6], [7, 8]]] @ 1 @ 0 @ 1',
      );
      checkResult(runtime, 6);
    });

    test('bracket syntax triple chained on nested lists', () {
      final RuntimeFacade runtime = getRuntime(
        'main = [[[1, 2], [3, 4]], [[5, 6], [7, 8]]][1][0][1]',
      );
      checkResult(runtime, 6);
    });

    test('@ operator on nested maps', () {
      final RuntimeFacade runtime = getRuntime(
        'main = {"outer": {"inner": 42}} @ "outer" @ "inner"',
      );
      checkResult(runtime, 42);
    });

    test('bracket syntax on nested maps', () {
      final RuntimeFacade runtime = getRuntime(
        'main = {"outer": {"inner": 42}}["outer"]["inner"]',
      );
      checkResult(runtime, 42);
    });

    test('@ operator on list containing maps', () {
      final RuntimeFacade runtime = getRuntime(
        'main = [{"a": 1}, {"b": 2}] @ 1 @ "b"',
      );
      checkResult(runtime, 2);
    });

    test('@ operator on map containing lists', () {
      final RuntimeFacade runtime = getRuntime(
        'main = {"nums": [10, 20, 30]} @ "nums" @ 2',
      );
      checkResult(runtime, 30);
    });

    // Float index behavior (truncates to integer)
    test('list access with float index truncates to integer', () {
      final RuntimeFacade runtime = getRuntime('main = [10, 20, 30] @ 1.9');
      checkResult(runtime, 20);
    });

    test('string access with float index truncates to integer', () {
      final RuntimeFacade runtime = getRuntime('main = "hello" @ 2.7');
      checkResult(runtime, '"l"');
    });

    test('list access with zero float index', () {
      final RuntimeFacade runtime = getRuntime('main = [10, 20, 30] @ 0.5');
      checkResult(runtime, 10);
    });

    // Large index values
    test('throws IndexOutOfBoundsError for very large list index', () {
      final RuntimeFacade runtime = getRuntime('main = [1, 2, 3] @ 999999');
      expect(
        runtime.executeMain,
        throwsA(isA<IndexOutOfBoundsError>()),
      );
    });

    test('throws IndexOutOfBoundsError for very large string index', () {
      final RuntimeFacade runtime = getRuntime('main = "hello" @ 999999');
      expect(
        runtime.executeMain,
        throwsA(isA<IndexOutOfBoundsError>()),
      );
    });

    // Map returning different value types
    test('returns list value from map', () {
      final RuntimeFacade runtime = getRuntime(
        'main = {"items": [1, 2, 3]} @ "items"',
      );
      checkResult(runtime, '[1, 2, 3]');
    });

    test('returns nested map value from map', () {
      final RuntimeFacade runtime = getRuntime(
        'main = {"data": {"x": 1}} @ "data"',
      );
      checkResult(runtime, '{"x": 1}');
    });

    test('returns boolean value from map', () {
      final RuntimeFacade runtime = getRuntime(
        'main = {"flag": true} @ "flag"',
      );
      checkResult(runtime, true);
    });

    // Additional bracket syntax edge cases
    test('bracket syntax returns first list element', () {
      final RuntimeFacade runtime = getRuntime('main = [10, 20, 30][0]');
      checkResult(runtime, 10);
    });

    test('bracket syntax returns last list element', () {
      final RuntimeFacade runtime = getRuntime('main = [10, 20, 30][2]');
      checkResult(runtime, 30);
    });

    test('bracket syntax returns last string character', () {
      final RuntimeFacade runtime = getRuntime('main = "hello"[4]');
      checkResult(runtime, '"o"');
    });

    test('bracket syntax throws IndexOutOfBoundsError for list', () {
      final RuntimeFacade runtime = getRuntime('main = [10, 20, 30][5]');
      expect(
        runtime.executeMain,
        throwsA(isA<IndexOutOfBoundsError>()),
      );
    });

    test('bracket syntax throws IndexOutOfBoundsError for string', () {
      final RuntimeFacade runtime = getRuntime('main = "hello"[10]');
      expect(
        runtime.executeMain,
        throwsA(isA<IndexOutOfBoundsError>()),
      );
    });

    test('bracket syntax throws NegativeIndexError for list', () {
      final RuntimeFacade runtime = getRuntime('main = [10, 20, 30][-1]');
      expect(
        runtime.executeMain,
        throwsA(isA<NegativeIndexError>()),
      );
    });

    test('bracket syntax throws NegativeIndexError for string', () {
      final RuntimeFacade runtime = getRuntime('main = "hello"[-1]');
      expect(
        runtime.executeMain,
        throwsA(isA<NegativeIndexError>()),
      );
    });

    test('bracket syntax throws ElementNotFoundError for missing map key', () {
      final RuntimeFacade runtime = getRuntime('main = {"a": 1}["missing"]');
      expect(
        runtime.executeMain,
        throwsA(isA<ElementNotFoundError>()),
      );
    });

    test('bracket syntax throws IndexOutOfBoundsError for empty list', () {
      final RuntimeFacade runtime = getRuntime('main = [][0]');
      expect(
        runtime.executeMain,
        throwsA(isA<IndexOutOfBoundsError>()),
      );
    });

    test('bracket syntax throws IndexOutOfBoundsError for empty string', () {
      final RuntimeFacade runtime = getRuntime('main = ""[0]');
      expect(
        runtime.executeMain,
        throwsA(isA<IndexOutOfBoundsError>()),
      );
    });

    // Additional invalid type combinations
    test('throws InvalidArgumentTypesError for function operand', () {
      final RuntimeFacade runtime = getRuntime('''
identity(x) = x
main = identity @ 0
''');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('throws InvalidArgumentTypesError for list with boolean index', () {
      final RuntimeFacade runtime = getRuntime('main = [1, 2, 3] @ true');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('throws InvalidArgumentTypesError for string with boolean index', () {
      final RuntimeFacade runtime = getRuntime('main = "hello" @ true');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('throws InvalidArgumentTypesError for list with list index', () {
      final RuntimeFacade runtime = getRuntime('main = [1, 2, 3] @ [0]');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('throws InvalidArgumentTypesError for string with list index', () {
      final RuntimeFacade runtime = getRuntime('main = "hello" @ [0]');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    // String with multiple graphemes
    test('returns grapheme from string with multiple graphemes', () {
      final RuntimeFacade runtime = getRuntime(
        'main = "a👨‍👩‍👧b👨‍👩‍👧c" @ 3',
      );
      checkResult(runtime, '"👨‍👩‍👧"');
    });

    test('returns last grapheme from grapheme string', () {
      final RuntimeFacade runtime = getRuntime('main = "a👨‍👩‍👧" @ 1');
      checkResult(runtime, '"👨‍👩‍👧"');
    });

    test(
      'throws IndexOutOfBoundsError for grapheme string index at length',
      () {
        final RuntimeFacade runtime = getRuntime('main = "a👨‍👩‍👧" @ 2');
        expect(
          runtime.executeMain,
          throwsA(isA<IndexOutOfBoundsError>()),
        );
      },
    );

    // Single-element map
    test('returns value from single-element map', () {
      final RuntimeFacade runtime = getRuntime('main = {"only": 42} @ "only"');
      checkResult(runtime, 42);
    });

    // Function-based access (parameterless functions must be called with ())
    test('@ operator with parameterless function index for list', () {
      final RuntimeFacade runtime = getRuntime('''
index = 1
main = [10, 20, 30] @ index()
''');
      checkResult(runtime, 20);
    });

    test('@ operator with parameterless function index for string', () {
      final RuntimeFacade runtime = getRuntime('''
index = 2
main = "hello" @ index()
''');
      checkResult(runtime, '"l"');
    });

    test('@ operator with parameterless function key for map', () {
      final RuntimeFacade runtime = getRuntime('''
key = "b"
main = {"a": 1, "b": 2} @ key()
''');
      checkResult(runtime, 2);
    });

    test('@ operator with parameterless function returning list', () {
      final RuntimeFacade runtime = getRuntime('''
items = [100, 200, 300]
main = items() @ 1
''');
      checkResult(runtime, 200);
    });

    test('@ operator with computed index', () {
      final RuntimeFacade runtime = getRuntime('main = [10, 20, 30] @ (1 + 1)');
      checkResult(runtime, 30);
    });

    // Zero index edge cases
    test('returns first element with explicit zero index for list', () {
      final RuntimeFacade runtime = getRuntime('main = [100, 200] @ 0');
      checkResult(runtime, 100);
    });

    test('returns first character with explicit zero index for string', () {
      final RuntimeFacade runtime = getRuntime('main = "test" @ 0');
      checkResult(runtime, '"t"');
    });
  });
}
