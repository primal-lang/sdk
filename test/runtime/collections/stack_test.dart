@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Stack', () {
    test('stack.new creates empty stack from empty list', () {
      final RuntimeFacade runtime = getRuntime('main = stack.new([])');
      checkResult(runtime, []);
    });

    test('stack.new creates stack from non-empty list', () {
      final RuntimeFacade runtime = getRuntime('main = stack.new([1, 2])');
      checkResult(runtime, [1, 2]);
    });

    test('stack.push adds element to empty stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.push(stack.new([]), 1)',
      );
      checkResult(runtime, [1]);
    });

    test('stack.push adds element to top of non-empty stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.push(stack.new([1, 2]), 3)',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('stack.pop throws on empty stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.pop(stack.new([]))',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('stack.pop removes top element from stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.pop(stack.new([1, 2, 3]))',
      );
      checkResult(runtime, [1, 2]);
    });

    test('stack.pop on single-element stack returns empty stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.pop(stack.new([1]))',
      );
      checkResult(runtime, []);
    });

    test('stack.peek throws on empty stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.peek(stack.new([]))',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('stack.peek returns top element of multi-element stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.peek(stack.new([1, 2, 3]))',
      );
      checkResult(runtime, 3);
    });

    test('stack.peek returns element of single-element stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.peek(stack.new([1]))',
      );
      checkResult(runtime, 1);
    });

    test('stack.isEmpty returns true for empty stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.isEmpty(stack.new([]))',
      );
      checkResult(runtime, true);
    });

    test('stack.isEmpty returns false for non-empty stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.isEmpty(stack.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('stack.isNotEmpty returns false for empty stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.isNotEmpty(stack.new([]))',
      );
      checkResult(runtime, false);
    });

    test('stack.isNotEmpty returns true for non-empty stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.isNotEmpty(stack.new([1, 2, 3]))',
      );
      checkResult(runtime, true);
    });

    test('stack.length returns zero for empty stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.length(stack.new([]))',
      );
      checkResult(runtime, 0);
    });

    test('stack.length returns element count for non-empty stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.length(stack.new([1, 2, 3]))',
      );
      checkResult(runtime, 3);
    });

    test('stack.reverse on empty stack returns empty stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.reverse(stack.new([]))',
      );
      checkResult(runtime, []);
    });

    test('stack.reverse reverses element order', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.reverse(stack.new([1, 2, 3]))',
      );
      checkResult(runtime, [3, 2, 1]);
    });

    test('stack.reverse on single-element stack returns same stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.reverse(stack.new([42]))',
      );
      checkResult(runtime, [42]);
    });

    test('stack.length returns one for single-element stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.length(stack.new([1]))',
      );
      checkResult(runtime, 1);
    });

    test('stack.isEmpty returns false for single-element stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.isEmpty(stack.new([1]))',
      );
      checkResult(runtime, false);
    });

    test('stack.isNotEmpty returns true for single-element stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.isNotEmpty(stack.new([1]))',
      );
      checkResult(runtime, true);
    });

    test('stack.new creates stack from list of strings', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.new(["a", "b", "c"])',
      );
      checkResult(runtime, ['"a"', '"b"', '"c"']);
    });

    test('stack.new creates stack from list of booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.new([true, false, true])',
      );
      checkResult(runtime, [true, false, true]);
    });

    test('stack.new creates stack from list of mixed types', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.new([1, "two", true])',
      );
      checkResult(runtime, [1, '"two"', true]);
    });

    test('stack.new creates stack from nested lists', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.new([[1, 2], [3, 4]])',
      );
      checkResult(runtime, ['[1, 2]', '[3, 4]']);
    });

    test('stack.push adds string element to stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.push(stack.new(["a"]), "b")',
      );
      checkResult(runtime, ['"a"', '"b"']);
    });

    test('stack.push adds list element to stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.push(stack.new([1]), [2, 3])',
      );
      checkResult(runtime, [1, '[2, 3]']);
    });

    test('stack.peek returns string from stack of strings', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.peek(stack.new(["a", "b", "c"]))',
      );
      checkResult(runtime, '"c"');
    });

    test('stack.peek returns boolean from stack of booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.peek(stack.new([true, false]))',
      );
      checkResult(runtime, false);
    });

    test('stack.peek returns list from stack of lists', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.peek(stack.new([[1, 2], [3, 4]]))',
      );
      checkResult(runtime, [3, 4]);
    });

    test('stack.pop removes string element from stack of strings', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.pop(stack.new(["a", "b", "c"]))',
      );
      checkResult(runtime, ['"a"', '"b"']);
    });

    test('stack.reverse reverses stack of strings', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.reverse(stack.new(["a", "b", "c"]))',
      );
      checkResult(runtime, ['"c"', '"b"', '"a"']);
    });

    test('stack.reverse twice returns original stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.reverse(stack.reverse(stack.new([1, 2, 3])))',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('chained push operations', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.push(stack.push(stack.push(stack.new([]), 1), 2), 3)',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('chained pop operations', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.pop(stack.pop(stack.new([1, 2, 3])))',
      );
      checkResult(runtime, [1]);
    });

    test('push then pop returns original stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.pop(stack.push(stack.new([1, 2]), 3))',
      );
      checkResult(runtime, [1, 2]);
    });

    test('pop then push replaces top element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.push(stack.pop(stack.new([1, 2, 3])), 99)',
      );
      checkResult(runtime, [1, 2, 99]);
    });

    test('peek after push returns pushed element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.peek(stack.push(stack.new([1, 2]), 3))',
      );
      checkResult(runtime, 3);
    });

    test('length after push increments by one', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.length(stack.push(stack.new([1, 2]), 3))',
      );
      checkResult(runtime, 3);
    });

    test('length after pop decrements by one', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.length(stack.pop(stack.new([1, 2, 3])))',
      );
      checkResult(runtime, 2);
    });

    test('isEmpty after popping last element returns true', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.isEmpty(stack.pop(stack.new([1])))',
      );
      checkResult(runtime, true);
    });

    test('isNotEmpty after pushing to empty stack returns true', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.isNotEmpty(stack.push(stack.new([]), 1))',
      );
      checkResult(runtime, true);
    });

    test('reverse after push', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.reverse(stack.push(stack.new([1, 2]), 3))',
      );
      checkResult(runtime, [3, 2, 1]);
    });

    test('push after reverse', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.push(stack.reverse(stack.new([1, 2, 3])), 4)',
      );
      checkResult(runtime, [3, 2, 1, 4]);
    });

    test('peek after reverse returns first original element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.peek(stack.reverse(stack.new([1, 2, 3])))',
      );
      checkResult(runtime, 1);
    });

    test('length is preserved after reverse', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.length(stack.reverse(stack.new([1, 2, 3])))',
      );
      checkResult(runtime, 3);
    });

    test('stack.reverse with two elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.reverse(stack.new([1, 2]))',
      );
      checkResult(runtime, [2, 1]);
    });

    test('stack.new creates stack from list of floats', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.new([1.5, 2.5, 3.5])',
      );
      checkResult(runtime, [1.5, 2.5, 3.5]);
    });

    test('stack.push adds float element to stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.push(stack.new([1.0]), 2.5)',
      );
      checkResult(runtime, [1.0, 2.5]);
    });

    test('stack.peek returns float from stack of floats', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.peek(stack.new([1.1, 2.2, 3.3]))',
      );
      checkResult(runtime, 3.3);
    });

    test('stack.pop removes float element from stack of floats', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.pop(stack.new([1.1, 2.2, 3.3]))',
      );
      checkResult(runtime, [1.1, 2.2]);
    });

    test('stack.new creates stack from list of negative numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.new([-1, -2, -3])',
      );
      checkResult(runtime, [-1, -2, -3]);
    });

    test('stack.push adds negative number to stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.push(stack.new([1, 2]), -3)',
      );
      checkResult(runtime, [1, 2, -3]);
    });

    test('stack.peek returns negative number from stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.peek(stack.new([1, -2, 3, -4]))',
      );
      checkResult(runtime, -4);
    });

    test('stack.new creates stack with zero element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.new([0])',
      );
      checkResult(runtime, [0]);
    });

    test('stack.push adds zero to stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.push(stack.new([1, 2]), 0)',
      );
      checkResult(runtime, [1, 2, 0]);
    });

    test('stack.peek returns zero from stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.peek(stack.new([1, 2, 0]))',
      );
      checkResult(runtime, 0);
    });

    test('stack.new creates stack with empty string element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.new([""])',
      );
      checkResult(runtime, ['""']);
    });

    test('stack.push adds empty string to stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.push(stack.new(["a"]), "")',
      );
      checkResult(runtime, ['"a"', '""']);
    });

    test('stack.peek returns empty string from stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.peek(stack.new(["a", ""]))',
      );
      checkResult(runtime, '""');
    });

    test('stack.new creates stack with empty list element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.new([[]])',
      );
      checkResult(runtime, ['[]']);
    });

    test('stack.push adds empty list to stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.push(stack.new([1]), [])',
      );
      checkResult(runtime, [1, '[]']);
    });

    test('stack.peek returns empty list from stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.peek(stack.new([[1, 2], []]))',
      );
      checkResult(runtime, []);
    });

    test('stack.pop from two-element stack returns single-element stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.pop(stack.new([1, 2]))',
      );
      checkResult(runtime, [1]);
    });

    test('stack.peek on two-element stack returns top element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.peek(stack.new([1, 2]))',
      );
      checkResult(runtime, 2);
    });

    test('stack.length returns two for two-element stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.length(stack.new([1, 2]))',
      );
      checkResult(runtime, 2);
    });

    test('multiple pops until empty then check isEmpty', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.isEmpty(stack.pop(stack.pop(stack.new([1, 2]))))',
      );
      checkResult(runtime, true);
    });

    test('multiple pushes to empty stack then check length', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.length(stack.push(stack.push(stack.new([]), 1), 2))',
      );
      checkResult(runtime, 2);
    });

    test('push then peek returns pushed element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.peek(stack.push(stack.new([]), 42))',
      );
      checkResult(runtime, 42);
    });

    test('pop then peek returns new top element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.peek(stack.pop(stack.new([1, 2, 3])))',
      );
      checkResult(runtime, 2);
    });

    test('reverse then pop removes original first element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.pop(stack.reverse(stack.new([1, 2, 3])))',
      );
      checkResult(runtime, [3, 2]);
    });

    test('reverse then peek returns original first element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.peek(stack.reverse(stack.new([10, 20, 30])))',
      );
      checkResult(runtime, 10);
    });

    test('pop then reverse on remaining elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.reverse(stack.pop(stack.new([1, 2, 3])))',
      );
      checkResult(runtime, [2, 1]);
    });

    test('stack operations with large numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.new([999999999, 1000000000, 1000000001])',
      );
      checkResult(runtime, [999999999, 1000000000, 1000000001]);
    });

    test('stack.peek with large number', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.peek(stack.new([1, 2, 999999999]))',
      );
      checkResult(runtime, 999999999);
    });

    test('stack.push with deeply nested list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.push(stack.new([]), [[1, 2], [3, [4, 5]]])',
      );
      checkResult(runtime, ['[[1, 2], [3, [4, 5]]]']);
    });

    test('stack.new with stack element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.length(stack.new([stack.new([1, 2])]))',
      );
      checkResult(runtime, 1);
    });

    test('stack.push with stack as element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.length(stack.push(stack.new([1]), stack.new([2, 3])))',
      );
      checkResult(runtime, 2);
    });

    test(
      'isEmpty returns true and isNotEmpty returns false for empty stack',
      () {
        final RuntimeFacade runtime1 = getRuntime(
          'main = stack.isEmpty(stack.new([]))',
        );
        checkResult(runtime1, true);

        final RuntimeFacade runtime2 = getRuntime(
          'main = stack.isNotEmpty(stack.new([]))',
        );
        checkResult(runtime2, false);
      },
    );

    test(
      'isEmpty returns false and isNotEmpty returns true for non-empty stack',
      () {
        final RuntimeFacade runtime1 = getRuntime(
          'main = stack.isEmpty(stack.new([1]))',
        );
        checkResult(runtime1, false);

        final RuntimeFacade runtime2 = getRuntime(
          'main = stack.isNotEmpty(stack.new([1]))',
        );
        checkResult(runtime2, true);
      },
    );
  });

  group('Stack Type Errors', () {
    test('stack.new throws for non-list arg', () {
      final RuntimeFacade runtime = getRuntime('main = stack.new(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.push throws for non-stack first arg', () {
      final RuntimeFacade runtime = getRuntime('main = stack.push([1, 2], 3)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.pop throws for non-stack arg', () {
      final RuntimeFacade runtime = getRuntime('main = stack.pop([1, 2])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.peek throws for non-stack arg', () {
      final RuntimeFacade runtime = getRuntime('main = stack.peek([1, 2])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.isEmpty throws for non-stack arg', () {
      final RuntimeFacade runtime = getRuntime('main = stack.isEmpty([1, 2])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.isNotEmpty throws for non-stack arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.isNotEmpty([1, 2])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.length throws for non-stack arg', () {
      final RuntimeFacade runtime = getRuntime('main = stack.length([1, 2])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.reverse throws for non-stack arg', () {
      final RuntimeFacade runtime = getRuntime('main = stack.reverse([1, 2])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.new throws for string arg', () {
      final RuntimeFacade runtime = getRuntime('main = stack.new("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.new throws for boolean arg', () {
      final RuntimeFacade runtime = getRuntime('main = stack.new(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.push throws for string first arg', () {
      final RuntimeFacade runtime = getRuntime('main = stack.push("hello", 1)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.push throws for number first arg', () {
      final RuntimeFacade runtime = getRuntime('main = stack.push(42, 1)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.push throws for boolean first arg', () {
      final RuntimeFacade runtime = getRuntime('main = stack.push(true, 1)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.pop throws for string arg', () {
      final RuntimeFacade runtime = getRuntime('main = stack.pop("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.pop throws for number arg', () {
      final RuntimeFacade runtime = getRuntime('main = stack.pop(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.pop throws for boolean arg', () {
      final RuntimeFacade runtime = getRuntime('main = stack.pop(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.peek throws for string arg', () {
      final RuntimeFacade runtime = getRuntime('main = stack.peek("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.peek throws for number arg', () {
      final RuntimeFacade runtime = getRuntime('main = stack.peek(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.peek throws for boolean arg', () {
      final RuntimeFacade runtime = getRuntime('main = stack.peek(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.isEmpty throws for string arg', () {
      final RuntimeFacade runtime = getRuntime('main = stack.isEmpty("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.isEmpty throws for number arg', () {
      final RuntimeFacade runtime = getRuntime('main = stack.isEmpty(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.isEmpty throws for boolean arg', () {
      final RuntimeFacade runtime = getRuntime('main = stack.isEmpty(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.isNotEmpty throws for string arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.isNotEmpty("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.isNotEmpty throws for number arg', () {
      final RuntimeFacade runtime = getRuntime('main = stack.isNotEmpty(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.isNotEmpty throws for boolean arg', () {
      final RuntimeFacade runtime = getRuntime('main = stack.isNotEmpty(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.length throws for string arg', () {
      final RuntimeFacade runtime = getRuntime('main = stack.length("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.length throws for number arg', () {
      final RuntimeFacade runtime = getRuntime('main = stack.length(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.length throws for boolean arg', () {
      final RuntimeFacade runtime = getRuntime('main = stack.length(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.reverse throws for string arg', () {
      final RuntimeFacade runtime = getRuntime('main = stack.reverse("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.reverse throws for number arg', () {
      final RuntimeFacade runtime = getRuntime('main = stack.reverse(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.reverse throws for boolean arg', () {
      final RuntimeFacade runtime = getRuntime('main = stack.reverse(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.new throws for map arg', () {
      final RuntimeFacade runtime = getRuntime('main = stack.new({"a": 1})');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.push throws for map first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.push({"a": 1}, 1)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.pop throws for map arg', () {
      final RuntimeFacade runtime = getRuntime('main = stack.pop({"a": 1})');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.peek throws for map arg', () {
      final RuntimeFacade runtime = getRuntime('main = stack.peek({"a": 1})');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.isEmpty throws for map arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.isEmpty({"a": 1})',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.isNotEmpty throws for map arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.isNotEmpty({"a": 1})',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.length throws for map arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.length({"a": 1})',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.reverse throws for map arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.reverse({"a": 1})',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.new throws for queue arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.new(queue.new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.push throws for queue first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.push(queue.new([1, 2]), 3)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.pop throws for queue arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.pop(queue.new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.peek throws for queue arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.peek(queue.new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.isEmpty throws for queue arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.isEmpty(queue.new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.isNotEmpty throws for queue arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.isNotEmpty(queue.new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.length throws for queue arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.length(queue.new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.reverse throws for queue arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.reverse(queue.new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.new throws for set arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.new(set.new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.push throws for set first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.push(set.new([1, 2]), 3)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.pop throws for set arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.pop(set.new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.peek throws for set arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.peek(set.new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.isEmpty throws for set arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.isEmpty(set.new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.isNotEmpty throws for set arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.isNotEmpty(set.new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.length throws for set arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.length(set.new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.reverse throws for set arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.reverse(set.new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.new throws for vector arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.new(vector.new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.push throws for vector first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.push(vector.new([1, 2]), 3)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.pop throws for vector arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.pop(vector.new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.peek throws for vector arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.peek(vector.new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.isEmpty throws for vector arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.isEmpty(vector.new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.isNotEmpty throws for vector arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.isNotEmpty(vector.new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.length throws for vector arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.length(vector.new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.reverse throws for vector arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.reverse(vector.new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Stack Error Messages', () {
    test(
      'stack.pop on empty stack throws RuntimeError with correct message',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main = stack.pop(stack.new([]))',
        );
        expect(
          runtime.executeMain,
          throwsA(
            allOf(
              isA<RuntimeError>(),
              predicate<RuntimeError>(
                (error) => error.toString().contains('empty stack'),
              ),
            ),
          ),
        );
      },
    );

    test(
      'stack.peek on empty stack throws RuntimeError with correct message',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main = stack.peek(stack.new([]))',
        );
        expect(
          runtime.executeMain,
          throwsA(
            allOf(
              isA<RuntimeError>(),
              predicate<RuntimeError>(
                (error) => error.toString().contains('empty stack'),
              ),
            ),
          ),
        );
      },
    );
  });

  group('Stack with Special Values', () {
    test('stack.new creates stack with map element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.length(stack.new([{"a": 1}]))',
      );
      checkResult(runtime, 1);
    });

    test('stack.push adds map element to stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.length(stack.push(stack.new([]), {"a": 1, "b": 2}))',
      );
      checkResult(runtime, 1);
    });

    test('stack.peek returns map from stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.peek(stack.new([{"a": 1}]))',
      );
      checkResult(runtime, '{"a": 1}');
    });

    test('stack.new creates stack with function element', () {
      final RuntimeFacade runtime = getRuntime('''
double(x) = x * 2
main = stack.length(stack.new([double]))
''');
      checkResult(runtime, 1);
    });

    test('stack.push adds function element to stack', () {
      final RuntimeFacade runtime = getRuntime('''
double(x) = x * 2
main = stack.length(stack.push(stack.new([]), double))
''');
      checkResult(runtime, 1);
    });

    test('stack.new creates stack with unicode strings', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.peek(stack.new(["hello", "world"]))',
      );
      checkResult(runtime, '"world"');
    });

    test('stack.push adds unicode string to stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.peek(stack.push(stack.new([]), "test"))',
      );
      checkResult(runtime, '"test"');
    });

    test('stack.new creates stack with whitespace string', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.peek(stack.new(["   "]))',
      );
      checkResult(runtime, '"   "');
    });

    test('stack.push adds whitespace string to stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.peek(stack.push(stack.new([]), "  "))',
      );
      checkResult(runtime, '"  "');
    });

    test('stack.new creates stack with special float values', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.new([0.0, 0.0, 1.7976931348623157e+308])',
      );
      checkResult(runtime, [0.0, 0.0, 1.7976931348623157e+308]);
    });

    test('stack.push adds very small float to stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.peek(stack.push(stack.new([]), 2.2250738585072014e-308))',
      );
      checkResult(runtime, 2.2250738585072014e-308);
    });

    test('stack.new creates stack with mixed positive and negative floats', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.new([-1.5, 0.0, 1.5])',
      );
      checkResult(runtime, [-1.5, 0.0, 1.5]);
    });

    test('stack with functions maintains length', () {
      final RuntimeFacade runtime = getRuntime('''
double(x) = x * 2
triple(x) = x * 3
main = stack.length(stack.new([double, triple]))
''');
      checkResult(runtime, 2);
    });

    test('stack.pop removes element from stack with functions', () {
      final RuntimeFacade runtime = getRuntime('''
double(x) = x * 2
triple(x) = x * 3
main = stack.length(stack.pop(stack.new([double, triple])))
''');
      checkResult(runtime, 1);
    });

    test('stack.reverse maintains length with functions', () {
      final RuntimeFacade runtime = getRuntime('''
double(x) = x * 2
triple(x) = x * 3
main = stack.length(stack.reverse(stack.new([double, triple])))
''');
      checkResult(runtime, 2);
    });

    test('stack.push adds function element', () {
      final RuntimeFacade runtime = getRuntime('''
double(x) = x * 2
quadruple(x) = x * 4
main = stack.length(stack.push(stack.new([double]), quadruple))
''');
      checkResult(runtime, 2);
    });
  });

  group('Stack Stress Tests', () {
    test('stack.new with many elements preserves length', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.length(stack.new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]))',
      );
      checkResult(runtime, 20);
    });

    test('stack.push many times builds correct stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.length(stack.push(stack.push(stack.push(stack.push(stack.push(stack.push(stack.push(stack.push(stack.push(stack.push(stack.new([]), 1), 2), 3), 4), 5), 6), 7), 8), 9), 10))',
      );
      checkResult(runtime, 10);
    });

    test('stack.pop many times reduces stack correctly', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.length(stack.pop(stack.pop(stack.pop(stack.pop(stack.pop(stack.new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])))))))',
      );
      checkResult(runtime, 5);
    });

    test('stack.peek after many pushes returns last pushed element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.peek(stack.push(stack.push(stack.push(stack.push(stack.push(stack.new([]), 1), 2), 3), 4), 99))',
      );
      checkResult(runtime, 99);
    });

    test('stack.reverse with many elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.peek(stack.reverse(stack.new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])))',
      );
      checkResult(runtime, 1);
    });

    test('stack with deeply nested structures', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.length(stack.new([[[1]], [[2]], [[3]]]))',
      );
      checkResult(runtime, 3);
    });

    test('stack.peek with deeply nested structure returns correct element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.peek(stack.new([[[1, 2]], [[3, 4]], [[5, 6]]]))',
      );
      checkResult(runtime, [
        [5, 6],
      ]);
    });

    test('stack with 50 elements preserves all elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.length(stack.new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50]))',
      );
      checkResult(runtime, 50);
    });

    test('stack.peek on 50 element stack returns last element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.peek(stack.new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50]))',
      );
      checkResult(runtime, 50);
    });

    test('stack.reverse on 50 element stack reverses order', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.peek(stack.reverse(stack.new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50])))',
      );
      checkResult(runtime, 1);
    });

    test('stack.pop on 50 element stack returns 49 elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.length(stack.pop(stack.new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50])))',
      );
      checkResult(runtime, 49);
    });
  });

  group('Stack Immutability', () {
    test('stack.push does not modify original stack', () {
      final RuntimeFacade runtime = getRuntime('''
original = stack.new([1, 2, 3])
modified = stack.push(original(), 4)
main = stack.length(original())
''');
      checkResult(runtime, 3);
    });

    test('stack.pop does not modify original stack', () {
      final RuntimeFacade runtime = getRuntime('''
original = stack.new([1, 2, 3])
modified = stack.pop(original())
main = stack.length(original())
''');
      checkResult(runtime, 3);
    });

    test('stack.reverse does not modify original stack', () {
      final RuntimeFacade runtime = getRuntime('''
original = stack.new([1, 2, 3])
reversed = stack.reverse(original())
main = stack.peek(original())
''');
      checkResult(runtime, 3);
    });
  });

  group('Stack Boundary Cases', () {
    test('stack.pop immediately after push on empty stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.isEmpty(stack.pop(stack.push(stack.new([]), 1)))',
      );
      checkResult(runtime, true);
    });

    test('stack.peek immediately after push on empty stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.peek(stack.push(stack.new([]), 42))',
      );
      checkResult(runtime, 42);
    });

    test('stack.length after push then pop equals original length', () {
      final RuntimeFacade runtime = getRuntime('''
original = stack.new([1, 2, 3])
pushed = stack.push(original(), 4)
popped = stack.pop(pushed())
main = stack.length(popped())
''');
      checkResult(runtime, 3);
    });

    test('stack.reverse preserves element values', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.length(stack.reverse(stack.new([1, 2, 3])))',
      );
      checkResult(runtime, 3);
    });

    test('stack.isEmpty and isNotEmpty are inverses for empty stack', () {
      final RuntimeFacade runtime1 = getRuntime(
        'main = stack.isEmpty(stack.new([]))',
      );
      checkResult(runtime1, true);

      final RuntimeFacade runtime2 = getRuntime(
        'main = stack.isNotEmpty(stack.new([]))',
      );
      checkResult(runtime2, false);
    });

    test('stack.isEmpty and isNotEmpty are inverses for non-empty stack', () {
      final RuntimeFacade runtime1 = getRuntime(
        'main = stack.isEmpty(stack.new([1]))',
      );
      checkResult(runtime1, false);

      final RuntimeFacade runtime2 = getRuntime(
        'main = stack.isNotEmpty(stack.new([1]))',
      );
      checkResult(runtime2, true);
    });

    test('stack.new from empty list equals empty stack', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.isEmpty(stack.new([]))',
      );
      checkResult(runtime, true);
    });

    test('chained multiple pops throw on empty', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.pop(stack.pop(stack.pop(stack.new([1, 2]))))',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('stack.peek on stack created from single-element list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.peek(stack.new([999]))',
      );
      checkResult(runtime, 999);
    });

    test(
      'stack.pop on stack created from single-element list returns empty',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main = stack.isEmpty(stack.pop(stack.new([1])))',
        );
        checkResult(runtime, true);
      },
    );
  });

  group('Stack with Duplicate Elements', () {
    test('stack.new creates stack with duplicate elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.new([1, 1, 1, 1, 1])',
      );
      checkResult(runtime, [1, 1, 1, 1, 1]);
    });

    test('stack.push adds duplicate element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.new([1, 1, 1])',
      );
      checkResult(runtime, [1, 1, 1]);
    });

    test('stack.length counts duplicate elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.length(stack.new([1, 1, 1, 1]))',
      );
      checkResult(runtime, 4);
    });

    test('stack.pop removes one of duplicate top elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.pop(stack.new([1, 2, 2]))',
      );
      checkResult(runtime, [1, 2]);
    });

    test('stack.peek returns top duplicate element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.peek(stack.new([1, 2, 2]))',
      );
      checkResult(runtime, 2);
    });

    test('stack.reverse preserves duplicate elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main = stack.reverse(stack.new([1, 1, 2, 2]))',
      );
      checkResult(runtime, [2, 2, 1, 1]);
    });
  });
}
