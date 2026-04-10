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

    test('isEmpty returns true and isNotEmpty returns false for empty stack', () {
      final RuntimeFacade runtime1 = getRuntime(
        'main = stack.isEmpty(stack.new([]))',
      );
      checkResult(runtime1, true);

      final RuntimeFacade runtime2 = getRuntime(
        'main = stack.isNotEmpty(stack.new([]))',
      );
      checkResult(runtime2, false);
    });

    test('isEmpty returns false and isNotEmpty returns true for non-empty stack', () {
      final RuntimeFacade runtime1 = getRuntime(
        'main = stack.isEmpty(stack.new([1]))',
      );
      checkResult(runtime1, false);

      final RuntimeFacade runtime2 = getRuntime(
        'main = stack.isNotEmpty(stack.new([1]))',
      );
      checkResult(runtime2, true);
    });
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
  });
}
