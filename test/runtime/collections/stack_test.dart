@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';

import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Stack', () {
    test('stack_new creates empty stack from empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = stack_new([])');
      checkResult(runtime, []);
    });

    test('stack_new creates stack from non-empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = stack_new([1, 2])');
      checkResult(runtime, [1, 2]);
    });

    test('stack_push adds element to empty stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_push(stack_new([]), 1)',
      );
      checkResult(runtime, [1]);
    });

    test('stack_push adds element to top of non-empty stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_push(stack_new([1, 2]), 3)',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('stack_pop throws on empty stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_pop(stack_new([]))',
      );
      expect(runtime.executeMain, throwsA(isA<EmptyCollectionError>()));
    });

    test('stack_pop removes top element from stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_pop(stack_new([1, 2, 3]))',
      );
      checkResult(runtime, [1, 2]);
    });

    test('stack_pop on single-element stack returns empty stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_pop(stack_new([1]))',
      );
      checkResult(runtime, []);
    });

    test('stack_peek throws on empty stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_peek(stack_new([]))',
      );
      expect(runtime.executeMain, throwsA(isA<EmptyCollectionError>()));
    });

    test('stack_peek returns top element of multi-element stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_peek(stack_new([1, 2, 3]))',
      );
      checkResult(runtime, 3);
    });

    test('stack_peek returns element of single-element stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_peek(stack_new([1]))',
      );
      checkResult(runtime, 1);
    });

    test('stack_isEmpty returns true for empty stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_isEmpty(stack_new([]))',
      );
      checkResult(runtime, true);
    });

    test('stack_isEmpty returns false for non-empty stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_isEmpty(stack_new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('stack_isNotEmpty returns false for empty stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_isNotEmpty(stack_new([]))',
      );
      checkResult(runtime, false);
    });

    test('stack_isNotEmpty returns true for non-empty stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_isNotEmpty(stack_new([1, 2, 3]))',
      );
      checkResult(runtime, true);
    });

    test('stack_length returns zero for empty stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_length(stack_new([]))',
      );
      checkResult(runtime, 0);
    });

    test('stack_length returns element count for non-empty stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_length(stack_new([1, 2, 3]))',
      );
      checkResult(runtime, 3);
    });

    test('stack_reverse on empty stack returns empty stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_reverse(stack_new([]))',
      );
      checkResult(runtime, []);
    });

    test('stack_reverse reverses element order', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_reverse(stack_new([1, 2, 3]))',
      );
      checkResult(runtime, [3, 2, 1]);
    });

    test('stack_reverse on single-element stack returns same stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_reverse(stack_new([42]))',
      );
      checkResult(runtime, [42]);
    });

    test('stack_length returns one for single-element stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_length(stack_new([1]))',
      );
      checkResult(runtime, 1);
    });

    test('stack_isEmpty returns false for single-element stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_isEmpty(stack_new([1]))',
      );
      checkResult(runtime, false);
    });

    test('stack_isNotEmpty returns true for single-element stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_isNotEmpty(stack_new([1]))',
      );
      checkResult(runtime, true);
    });

    test('stack_new creates stack from list of strings', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_new(["a", "b", "c"])',
      );
      checkResult(runtime, ['"a"', '"b"', '"c"']);
    });

    test('stack_new creates stack from list of booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_new([true, false, true])',
      );
      checkResult(runtime, [true, false, true]);
    });

    test('stack_new creates stack from list of mixed types', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_new([1, "two", true])',
      );
      checkResult(runtime, [1, '"two"', true]);
    });

    test('stack_new creates stack from nested lists', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_new([[1, 2], [3, 4]])',
      );
      checkResult(runtime, ['[1, 2]', '[3, 4]']);
    });

    test('stack_push adds string element to stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_push(stack_new(["a"]), "b")',
      );
      checkResult(runtime, ['"a"', '"b"']);
    });

    test('stack_push adds list element to stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_push(stack_new([1]), [2, 3])',
      );
      checkResult(runtime, [1, '[2, 3]']);
    });

    test('stack_peek returns string from stack of strings', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_peek(stack_new(["a", "b", "c"]))',
      );
      checkResult(runtime, '"c"');
    });

    test('stack_peek returns boolean from stack of booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_peek(stack_new([true, false]))',
      );
      checkResult(runtime, false);
    });

    test('stack_peek returns list from stack of lists', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_peek(stack_new([[1, 2], [3, 4]]))',
      );
      checkResult(runtime, [3, 4]);
    });

    test('stack_pop removes string element from stack of strings', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_pop(stack_new(["a", "b", "c"]))',
      );
      checkResult(runtime, ['"a"', '"b"']);
    });

    test('stack_reverse reverses stack of strings', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_reverse(stack_new(["a", "b", "c"]))',
      );
      checkResult(runtime, ['"c"', '"b"', '"a"']);
    });

    test('stack_reverse twice returns original stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_reverse(stack_reverse(stack_new([1, 2, 3])))',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('chained push operations', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_push(stack_push(stack_push(stack_new([]), 1), 2), 3)',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('chained pop operations', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_pop(stack_pop(stack_new([1, 2, 3])))',
      );
      checkResult(runtime, [1]);
    });

    test('push then pop returns original stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_pop(stack_push(stack_new([1, 2]), 3))',
      );
      checkResult(runtime, [1, 2]);
    });

    test('pop then push replaces top element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_push(stack_pop(stack_new([1, 2, 3])), 99)',
      );
      checkResult(runtime, [1, 2, 99]);
    });

    test('peek after push returns pushed element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_peek(stack_push(stack_new([1, 2]), 3))',
      );
      checkResult(runtime, 3);
    });

    test('length after push increments by one', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_length(stack_push(stack_new([1, 2]), 3))',
      );
      checkResult(runtime, 3);
    });

    test('length after pop decrements by one', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_length(stack_pop(stack_new([1, 2, 3])))',
      );
      checkResult(runtime, 2);
    });

    test('isEmpty after popping last element returns true', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_isEmpty(stack_pop(stack_new([1])))',
      );
      checkResult(runtime, true);
    });

    test('isNotEmpty after pushing to empty stack returns true', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_isNotEmpty(stack_push(stack_new([]), 1))',
      );
      checkResult(runtime, true);
    });

    test('reverse after push', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_reverse(stack_push(stack_new([1, 2]), 3))',
      );
      checkResult(runtime, [3, 2, 1]);
    });

    test('push after reverse', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_push(stack_reverse(stack_new([1, 2, 3])), 4)',
      );
      checkResult(runtime, [3, 2, 1, 4]);
    });

    test('peek after reverse returns first original element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_peek(stack_reverse(stack_new([1, 2, 3])))',
      );
      checkResult(runtime, 1);
    });

    test('length is preserved after reverse', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_length(stack_reverse(stack_new([1, 2, 3])))',
      );
      checkResult(runtime, 3);
    });

    test('stack_reverse with two elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_reverse(stack_new([1, 2]))',
      );
      checkResult(runtime, [2, 1]);
    });

    test('stack_new creates stack from list of floats', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_new([1.5, 2.5, 3.5])',
      );
      checkResult(runtime, [1.5, 2.5, 3.5]);
    });

    test('stack_push adds float element to stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_push(stack_new([1.0]), 2.5)',
      );
      checkResult(runtime, [1.0, 2.5]);
    });

    test('stack_peek returns float from stack of floats', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_peek(stack_new([1.1, 2.2, 3.3]))',
      );
      checkResult(runtime, 3.3);
    });

    test('stack_pop removes float element from stack of floats', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_pop(stack_new([1.1, 2.2, 3.3]))',
      );
      checkResult(runtime, [1.1, 2.2]);
    });

    test('stack_new creates stack from list of negative numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_new([-1, -2, -3])',
      );
      checkResult(runtime, [-1, -2, -3]);
    });

    test('stack_push adds negative number to stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_push(stack_new([1, 2]), -3)',
      );
      checkResult(runtime, [1, 2, -3]);
    });

    test('stack_peek returns negative number from stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_peek(stack_new([1, -2, 3, -4]))',
      );
      checkResult(runtime, -4);
    });

    test('stack_new creates stack with zero element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_new([0])',
      );
      checkResult(runtime, [0]);
    });

    test('stack_push adds zero to stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_push(stack_new([1, 2]), 0)',
      );
      checkResult(runtime, [1, 2, 0]);
    });

    test('stack_peek returns zero from stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_peek(stack_new([1, 2, 0]))',
      );
      checkResult(runtime, 0);
    });

    test('stack_new creates stack with empty string element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_new([""])',
      );
      checkResult(runtime, ['""']);
    });

    test('stack_push adds empty string to stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_push(stack_new(["a"]), "")',
      );
      checkResult(runtime, ['"a"', '""']);
    });

    test('stack_peek returns empty string from stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_peek(stack_new(["a", ""]))',
      );
      checkResult(runtime, '""');
    });

    test('stack_new creates stack with empty list element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_new([[]])',
      );
      checkResult(runtime, ['[]']);
    });

    test('stack_push adds empty list to stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_push(stack_new([1]), [])',
      );
      checkResult(runtime, [1, '[]']);
    });

    test('stack_peek returns empty list from stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_peek(stack_new([[1, 2], []]))',
      );
      checkResult(runtime, []);
    });

    test('stack_pop from two-element stack returns single-element stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_pop(stack_new([1, 2]))',
      );
      checkResult(runtime, [1]);
    });

    test('stack_peek on two-element stack returns top element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_peek(stack_new([1, 2]))',
      );
      checkResult(runtime, 2);
    });

    test('stack_length returns two for two-element stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_length(stack_new([1, 2]))',
      );
      checkResult(runtime, 2);
    });

    test('multiple pops until empty then check isEmpty', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_isEmpty(stack_pop(stack_pop(stack_new([1, 2]))))',
      );
      checkResult(runtime, true);
    });

    test('multiple pushes to empty stack then check length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_length(stack_push(stack_push(stack_new([]), 1), 2))',
      );
      checkResult(runtime, 2);
    });

    test('push then peek returns pushed element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_peek(stack_push(stack_new([]), 42))',
      );
      checkResult(runtime, 42);
    });

    test('pop then peek returns new top element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_peek(stack_pop(stack_new([1, 2, 3])))',
      );
      checkResult(runtime, 2);
    });

    test('reverse then pop removes original first element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_pop(stack_reverse(stack_new([1, 2, 3])))',
      );
      checkResult(runtime, [3, 2]);
    });

    test('reverse then peek returns original first element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_peek(stack_reverse(stack_new([10, 20, 30])))',
      );
      checkResult(runtime, 10);
    });

    test('pop then reverse on remaining elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_reverse(stack_pop(stack_new([1, 2, 3])))',
      );
      checkResult(runtime, [2, 1]);
    });

    test('stack operations with large numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_new([999999999, 1000000000, 1000000001])',
      );
      checkResult(runtime, [999999999, 1000000000, 1000000001]);
    });

    test('stack_peek with large number', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_peek(stack_new([1, 2, 999999999]))',
      );
      checkResult(runtime, 999999999);
    });

    test('stack_push with deeply nested list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_push(stack_new([]), [[1, 2], [3, [4, 5]]])',
      );
      checkResult(runtime, ['[[1, 2], [3, [4, 5]]]']);
    });

    test('stack_new with stack element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_length(stack_new([stack_new([1, 2])]))',
      );
      checkResult(runtime, 1);
    });

    test('stack_push with stack as element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_length(stack_push(stack_new([1]), stack_new([2, 3])))',
      );
      checkResult(runtime, 2);
    });

    test(
      'isEmpty returns true and isNotEmpty returns false for empty stack',
      () {
        final RuntimeFacade runtime1 = getRuntime(
          'main() = stack_isEmpty(stack_new([]))',
        );
        checkResult(runtime1, true);

        final RuntimeFacade runtime2 = getRuntime(
          'main() = stack_isNotEmpty(stack_new([]))',
        );
        checkResult(runtime2, false);
      },
    );

    test(
      'isEmpty returns false and isNotEmpty returns true for non-empty stack',
      () {
        final RuntimeFacade runtime1 = getRuntime(
          'main() = stack_isEmpty(stack_new([1]))',
        );
        checkResult(runtime1, false);

        final RuntimeFacade runtime2 = getRuntime(
          'main() = stack_isNotEmpty(stack_new([1]))',
        );
        checkResult(runtime2, true);
      },
    );
  });

  group('Stack Type Errors', () {
    test('stack_new throws for non-list arg', () {
      final RuntimeFacade runtime = getRuntime('main() = stack_new(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_push throws for non-stack first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_push([1, 2], 3)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_pop throws for non-stack arg', () {
      final RuntimeFacade runtime = getRuntime('main() = stack_pop([1, 2])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_peek throws for non-stack arg', () {
      final RuntimeFacade runtime = getRuntime('main() = stack_peek([1, 2])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_isEmpty throws for non-stack arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_isEmpty([1, 2])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_isNotEmpty throws for non-stack arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_isNotEmpty([1, 2])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_length throws for non-stack arg', () {
      final RuntimeFacade runtime = getRuntime('main() = stack_length([1, 2])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_reverse throws for non-stack arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_reverse([1, 2])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_new throws for string arg', () {
      final RuntimeFacade runtime = getRuntime('main() = stack_new("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_new throws for boolean arg', () {
      final RuntimeFacade runtime = getRuntime('main() = stack_new(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_push throws for string first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_push("hello", 1)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_push throws for number first arg', () {
      final RuntimeFacade runtime = getRuntime('main() = stack_push(42, 1)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_push throws for boolean first arg', () {
      final RuntimeFacade runtime = getRuntime('main() = stack_push(true, 1)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_pop throws for string arg', () {
      final RuntimeFacade runtime = getRuntime('main() = stack_pop("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_pop throws for number arg', () {
      final RuntimeFacade runtime = getRuntime('main() = stack_pop(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_pop throws for boolean arg', () {
      final RuntimeFacade runtime = getRuntime('main() = stack_pop(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_peek throws for string arg', () {
      final RuntimeFacade runtime = getRuntime('main() = stack_peek("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_peek throws for number arg', () {
      final RuntimeFacade runtime = getRuntime('main() = stack_peek(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_peek throws for boolean arg', () {
      final RuntimeFacade runtime = getRuntime('main() = stack_peek(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_isEmpty throws for string arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_isEmpty("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_isEmpty throws for number arg', () {
      final RuntimeFacade runtime = getRuntime('main() = stack_isEmpty(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_isEmpty throws for boolean arg', () {
      final RuntimeFacade runtime = getRuntime('main() = stack_isEmpty(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_isNotEmpty throws for string arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_isNotEmpty("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_isNotEmpty throws for number arg', () {
      final RuntimeFacade runtime = getRuntime('main() = stack_isNotEmpty(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_isNotEmpty throws for boolean arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_isNotEmpty(true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_length throws for string arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_length("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_length throws for number arg', () {
      final RuntimeFacade runtime = getRuntime('main() = stack_length(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_length throws for boolean arg', () {
      final RuntimeFacade runtime = getRuntime('main() = stack_length(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_reverse throws for string arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_reverse("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_reverse throws for number arg', () {
      final RuntimeFacade runtime = getRuntime('main() = stack_reverse(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_reverse throws for boolean arg', () {
      final RuntimeFacade runtime = getRuntime('main() = stack_reverse(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_new throws for map arg', () {
      final RuntimeFacade runtime = getRuntime('main() = stack_new({"a": 1})');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_push throws for map first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_push({"a": 1}, 1)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_pop throws for map arg', () {
      final RuntimeFacade runtime = getRuntime('main() = stack_pop({"a": 1})');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_peek throws for map arg', () {
      final RuntimeFacade runtime = getRuntime('main() = stack_peek({"a": 1})');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_isEmpty throws for map arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_isEmpty({"a": 1})',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_isNotEmpty throws for map arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_isNotEmpty({"a": 1})',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_length throws for map arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_length({"a": 1})',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_reverse throws for map arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_reverse({"a": 1})',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_new throws for queue arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_new(queue_new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_push throws for queue first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_push(queue_new([1, 2]), 3)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_pop throws for queue arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_pop(queue_new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_peek throws for queue arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_peek(queue_new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_isEmpty throws for queue arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_isEmpty(queue_new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_isNotEmpty throws for queue arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_isNotEmpty(queue_new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_length throws for queue arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_length(queue_new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_reverse throws for queue arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_reverse(queue_new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_new throws for set arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_new(set_new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_push throws for set first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_push(set_new([1, 2]), 3)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_pop throws for set arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_pop(set_new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_peek throws for set arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_peek(set_new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_isEmpty throws for set arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_isEmpty(set_new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_isNotEmpty throws for set arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_isNotEmpty(set_new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_length throws for set arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_length(set_new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_reverse throws for set arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_reverse(set_new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_new throws for vector arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_new(vector_new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_push throws for vector first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_push(vector_new([1, 2]), 3)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_pop throws for vector arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_pop(vector_new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_peek throws for vector arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_peek(vector_new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_isEmpty throws for vector arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_isEmpty(vector_new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_isNotEmpty throws for vector arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_isNotEmpty(vector_new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_length throws for vector arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_length(vector_new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack_reverse throws for vector arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_reverse(vector_new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Stack Error Messages', () {
    test(
      'stack_pop on empty stack throws EmptyCollectionError with correct message',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = stack_pop(stack_new([]))',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<EmptyCollectionError>().having(
              (Exception e) => e.toString(),
              'message',
              allOf(
                contains('empty stack'),
                contains('stack_pop'),
              ),
            ),
          ),
        );
      },
    );

    test(
      'stack_peek on empty stack throws EmptyCollectionError with correct message',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = stack_peek(stack_new([]))',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<EmptyCollectionError>().having(
              (Exception e) => e.toString(),
              'message',
              allOf(
                contains('empty stack'),
                contains('stack_peek'),
              ),
            ),
          ),
        );
      },
    );
  });

  group('Stack with Special Values', () {
    test('stack_new creates stack with map element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_length(stack_new([{"a": 1}]))',
      );
      checkResult(runtime, 1);
    });

    test('stack_push adds map element to stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_length(stack_push(stack_new([]), {"a": 1, "b": 2}))',
      );
      checkResult(runtime, 1);
    });

    test('stack_peek returns map from stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_peek(stack_new([{"a": 1}]))',
      );
      checkResult(runtime, '{"a": 1}');
    });

    test('stack_new creates stack with function element', () {
      final RuntimeFacade runtime = getRuntime('''
double(x) = x * 2
main() = stack_length(stack_new([double]))
''');
      checkResult(runtime, 1);
    });

    test('stack_push adds function element to stack', () {
      final RuntimeFacade runtime = getRuntime('''
double(x) = x * 2
main() = stack_length(stack_push(stack_new([]), double))
''');
      checkResult(runtime, 1);
    });

    test('stack_new creates stack with unicode strings', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_peek(stack_new(["hello", "world"]))',
      );
      checkResult(runtime, '"world"');
    });

    test('stack_push adds unicode string to stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_peek(stack_push(stack_new([]), "test"))',
      );
      checkResult(runtime, '"test"');
    });

    test('stack_new creates stack with whitespace string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_peek(stack_new(["   "]))',
      );
      checkResult(runtime, '"   "');
    });

    test('stack_push adds whitespace string to stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_peek(stack_push(stack_new([]), "  "))',
      );
      checkResult(runtime, '"  "');
    });

    test('stack_new creates stack with special float values', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_new([0.0, 0.0, 1.7976931348623157e+308])',
      );
      checkResult(runtime, [0.0, 0.0, 1.7976931348623157e+308]);
    });

    test('stack_push adds very small float to stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_peek(stack_push(stack_new([]), 2.2250738585072014e-308))',
      );
      checkResult(runtime, 2.2250738585072014e-308);
    });

    test('stack_new creates stack with mixed positive and negative floats', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_new([-1.5, 0.0, 1.5])',
      );
      checkResult(runtime, [-1.5, 0.0, 1.5]);
    });

    test('stack with functions maintains length', () {
      final RuntimeFacade runtime = getRuntime('''
double(x) = x * 2
triple(x) = x * 3
main() = stack_length(stack_new([double, triple]))
''');
      checkResult(runtime, 2);
    });

    test('stack_pop removes element from stack with functions', () {
      final RuntimeFacade runtime = getRuntime('''
double(x) = x * 2
triple(x) = x * 3
main() = stack_length(stack_pop(stack_new([double, triple])))
''');
      checkResult(runtime, 1);
    });

    test('stack_reverse maintains length with functions', () {
      final RuntimeFacade runtime = getRuntime('''
double(x) = x * 2
triple(x) = x * 3
main() = stack_length(stack_reverse(stack_new([double, triple])))
''');
      checkResult(runtime, 2);
    });

    test('stack_push adds function element', () {
      final RuntimeFacade runtime = getRuntime('''
double(x) = x * 2
quadruple(x) = x * 4
main() = stack_length(stack_push(stack_new([double]), quadruple))
''');
      checkResult(runtime, 2);
    });
  });

  group('Stack Stress Tests', () {
    test('stack_new with many elements preserves length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_length(stack_new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]))',
      );
      checkResult(runtime, 20);
    });

    test('stack_push many times builds correct stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_length(stack_push(stack_push(stack_push(stack_push(stack_push(stack_push(stack_push(stack_push(stack_push(stack_push(stack_new([]), 1), 2), 3), 4), 5), 6), 7), 8), 9), 10))',
      );
      checkResult(runtime, 10);
    });

    test('stack_pop many times reduces stack correctly', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_length(stack_pop(stack_pop(stack_pop(stack_pop(stack_pop(stack_new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])))))))',
      );
      checkResult(runtime, 5);
    });

    test('stack_peek after many pushes returns last pushed element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_peek(stack_push(stack_push(stack_push(stack_push(stack_push(stack_new([]), 1), 2), 3), 4), 99))',
      );
      checkResult(runtime, 99);
    });

    test('stack_reverse with many elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_peek(stack_reverse(stack_new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])))',
      );
      checkResult(runtime, 1);
    });

    test('stack with deeply nested structures', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_length(stack_new([[[1]], [[2]], [[3]]]))',
      );
      checkResult(runtime, 3);
    });

    test('stack_peek with deeply nested structure returns correct element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_peek(stack_new([[[1, 2]], [[3, 4]], [[5, 6]]]))',
      );
      checkResult(runtime, [
        [5, 6],
      ]);
    });

    test('stack with 50 elements preserves all elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_length(stack_new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50]))',
      );
      checkResult(runtime, 50);
    });

    test('stack_peek on 50 element stack returns last element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_peek(stack_new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50]))',
      );
      checkResult(runtime, 50);
    });

    test('stack_reverse on 50 element stack reverses order', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_peek(stack_reverse(stack_new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50])))',
      );
      checkResult(runtime, 1);
    });

    test('stack_pop on 50 element stack returns 49 elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_length(stack_pop(stack_new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50])))',
      );
      checkResult(runtime, 49);
    });
  });

  group('Stack Immutability', () {
    test('stack_push does not modify original stack', () {
      final RuntimeFacade runtime = getRuntime('''
original() = stack_new([1, 2, 3])
modified() = stack_push(original(), 4)
main() = stack_length(original())
''');
      checkResult(runtime, 3);
    });

    test('stack_pop does not modify original stack', () {
      final RuntimeFacade runtime = getRuntime('''
original() = stack_new([1, 2, 3])
modified() = stack_pop(original())
main() = stack_length(original())
''');
      checkResult(runtime, 3);
    });

    test('stack_reverse does not modify original stack', () {
      final RuntimeFacade runtime = getRuntime('''
original() = stack_new([1, 2, 3])
reversed() = stack_reverse(original())
main() = stack_peek(original())
''');
      checkResult(runtime, 3);
    });
  });

  group('Stack Boundary Cases', () {
    test('stack_pop immediately after push on empty stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_isEmpty(stack_pop(stack_push(stack_new([]), 1)))',
      );
      checkResult(runtime, true);
    });

    test('stack_peek immediately after push on empty stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_peek(stack_push(stack_new([]), 42))',
      );
      checkResult(runtime, 42);
    });

    test('stack_length after push then pop equals original length', () {
      final RuntimeFacade runtime = getRuntime('''
original() = stack_new([1, 2, 3])
pushed() = stack_push(original(), 4)
popped() = stack_pop(pushed())
main() = stack_length(popped())
''');
      checkResult(runtime, 3);
    });

    test('stack_reverse preserves element values', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_length(stack_reverse(stack_new([1, 2, 3])))',
      );
      checkResult(runtime, 3);
    });

    test('stack_isEmpty and isNotEmpty are inverses for empty stack', () {
      final RuntimeFacade runtime1 = getRuntime(
        'main() = stack_isEmpty(stack_new([]))',
      );
      checkResult(runtime1, true);

      final RuntimeFacade runtime2 = getRuntime(
        'main() = stack_isNotEmpty(stack_new([]))',
      );
      checkResult(runtime2, false);
    });

    test('stack_isEmpty and isNotEmpty are inverses for non-empty stack', () {
      final RuntimeFacade runtime1 = getRuntime(
        'main() = stack_isEmpty(stack_new([1]))',
      );
      checkResult(runtime1, false);

      final RuntimeFacade runtime2 = getRuntime(
        'main() = stack_isNotEmpty(stack_new([1]))',
      );
      checkResult(runtime2, true);
    });

    test('stack_new from empty list equals empty stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_isEmpty(stack_new([]))',
      );
      checkResult(runtime, true);
    });

    test('chained multiple pops throw on empty', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_pop(stack_pop(stack_pop(stack_new([1, 2]))))',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('stack_peek on stack created from single-element list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_peek(stack_new([999]))',
      );
      checkResult(runtime, 999);
    });

    test(
      'stack_pop on stack created from single-element list returns empty',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = stack_isEmpty(stack_pop(stack_new([1])))',
        );
        checkResult(runtime, true);
      },
    );
  });

  group('Stack with Duplicate Elements', () {
    test('stack_new creates stack with duplicate elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_new([1, 1, 1, 1, 1])',
      );
      checkResult(runtime, [1, 1, 1, 1, 1]);
    });

    test('stack_push adds duplicate element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_new([1, 1, 1])',
      );
      checkResult(runtime, [1, 1, 1]);
    });

    test('stack_length counts duplicate elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_length(stack_new([1, 1, 1, 1]))',
      );
      checkResult(runtime, 4);
    });

    test('stack_pop removes one of duplicate top elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_pop(stack_new([1, 2, 2]))',
      );
      checkResult(runtime, [1, 2]);
    });

    test('stack_peek returns top duplicate element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_peek(stack_new([1, 2, 2]))',
      );
      checkResult(runtime, 2);
    });

    test('stack_reverse preserves duplicate elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = stack_reverse(stack_new([1, 1, 2, 2]))',
      );
      checkResult(runtime, [2, 2, 1, 1]);
    });
  });
}
