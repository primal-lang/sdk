@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Queue', () {
    test('queue.new creates empty queue from empty list', () {
      final RuntimeFacade runtime = getRuntime('main = queue.new([])');
      checkResult(runtime, []);
    });

    test('queue.new creates queue from non-empty list', () {
      final RuntimeFacade runtime = getRuntime('main = queue.new([1, 2])');
      checkResult(runtime, [1, 2]);
    });

    test('queue.enqueue adds element to empty queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.enqueue(queue.new([]), 1)',
      );
      checkResult(runtime, [1]);
    });

    test('queue.enqueue adds element to back of non-empty queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.enqueue(queue.new([1, 2]), 3)',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('queue.dequeue throws on empty queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.dequeue(queue.new([]))',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('queue.dequeue removes front element from queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.dequeue(queue.new([1, 2, 3]))',
      );
      checkResult(runtime, [2, 3]);
    });

    test('queue.dequeue on single-element queue returns empty queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.dequeue(queue.new([1]))',
      );
      checkResult(runtime, []);
    });

    test('queue.peek throws on empty queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.peek(queue.new([]))',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('queue.peek returns front element of multi-element queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.peek(queue.new([1, 2, 3]))',
      );
      checkResult(runtime, 1);
    });

    test('queue.peek returns element of single-element queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.peek(queue.new([1]))',
      );
      checkResult(runtime, 1);
    });

    test('queue.isEmpty returns true for empty queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.isEmpty(queue.new([]))',
      );
      checkResult(runtime, true);
    });

    test('queue.isEmpty returns false for non-empty queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.isEmpty(queue.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('queue.isNotEmpty returns false for empty queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.isNotEmpty(queue.new([]))',
      );
      checkResult(runtime, false);
    });

    test('queue.isNotEmpty returns true for non-empty queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.isNotEmpty(queue.new([1, 2, 3]))',
      );
      checkResult(runtime, true);
    });

    test('queue.length returns zero for empty queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.length(queue.new([]))',
      );
      checkResult(runtime, 0);
    });

    test('queue.length returns element count for non-empty queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.length(queue.new([1, 2, 3]))',
      );
      checkResult(runtime, 3);
    });

    test('queue.reverse on empty queue returns empty queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.reverse(queue.new([]))',
      );
      checkResult(runtime, []);
    });

    test('queue.reverse reverses element order', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.reverse(queue.new([1, 2, 3]))',
      );
      checkResult(runtime, [3, 2, 1]);
    });

    test('queue.reverse on single-element queue returns same queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.reverse(queue.new([1]))',
      );
      checkResult(runtime, [1]);
    });

    test('queue.length returns one for single-element queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.length(queue.new([1]))',
      );
      checkResult(runtime, 1);
    });

    test('queue.isEmpty returns false for single-element queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.isEmpty(queue.new([1]))',
      );
      checkResult(runtime, false);
    });

    test('queue.isNotEmpty returns true for single-element queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.isNotEmpty(queue.new([1]))',
      );
      checkResult(runtime, true);
    });

    test('queue.enqueue with string element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.enqueue(queue.new(["a", "b"]), "c")',
      );
      checkResult(runtime, '["a", "b", "c"]');
    });

    test('queue.enqueue with boolean element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.enqueue(queue.new([true]), false)',
      );
      checkResult(runtime, [true, false]);
    });

    test('queue.enqueue with mixed types', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.enqueue(queue.new([1, "two"]), true)',
      );
      checkResult(runtime, '[1, "two", true]');
    });

    test('queue.peek with string element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.peek(queue.new(["hello", "world"]))',
      );
      checkResult(runtime, '"hello"');
    });

    test('queue.dequeue with string elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.dequeue(queue.new(["a", "b", "c"]))',
      );
      checkResult(runtime, '["b", "c"]');
    });

    test('queue.new with nested list elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.new([[1, 2], [3, 4]])',
      );
      checkResult(runtime, [
        [1, 2],
        [3, 4],
      ]);
    });

    test('queue.enqueue multiple times', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.enqueue(queue.enqueue(queue.enqueue(queue.new([]), 1), 2), 3)',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('queue.dequeue after enqueue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.dequeue(queue.enqueue(queue.new([1, 2]), 3))',
      );
      checkResult(runtime, [2, 3]);
    });

    test('queue.peek after enqueue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.peek(queue.enqueue(queue.new([1]), 2))',
      );
      checkResult(runtime, 1);
    });

    test('queue.peek after dequeue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.peek(queue.dequeue(queue.new([1, 2, 3])))',
      );
      checkResult(runtime, 2);
    });

    test('queue.length after enqueue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.length(queue.enqueue(queue.new([1, 2]), 3))',
      );
      checkResult(runtime, 3);
    });

    test('queue.length after dequeue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.length(queue.dequeue(queue.new([1, 2, 3])))',
      );
      checkResult(runtime, 2);
    });

    test('queue.isEmpty after dequeue to empty', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.isEmpty(queue.dequeue(queue.new([1])))',
      );
      checkResult(runtime, true);
    });

    test('queue.isNotEmpty after enqueue to non-empty', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.isNotEmpty(queue.enqueue(queue.new([]), 1))',
      );
      checkResult(runtime, true);
    });

    test('queue.reverse after enqueue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.reverse(queue.enqueue(queue.new([1, 2]), 3))',
      );
      checkResult(runtime, [3, 2, 1]);
    });

    test('queue.reverse with two elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.reverse(queue.new([1, 2]))',
      );
      checkResult(runtime, [2, 1]);
    });

    test('queue.dequeue twice', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.dequeue(queue.dequeue(queue.new([1, 2, 3])))',
      );
      checkResult(runtime, [3]);
    });

    test('queue.new creates queue from list of strings', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.new(["a", "b", "c"])',
      );
      checkResult(runtime, ['"a"', '"b"', '"c"']);
    });

    test('queue.new creates queue from list of booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.new([true, false, true])',
      );
      checkResult(runtime, [true, false, true]);
    });

    test('queue.new creates queue from list of mixed types', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.new([1, "two", true])',
      );
      checkResult(runtime, [1, '"two"', true]);
    });

    test('queue.enqueue adds list element to queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.enqueue(queue.new([1]), [2, 3])',
      );
      checkResult(runtime, [1, '[2, 3]']);
    });

    test('queue.peek returns boolean from queue of booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.peek(queue.new([true, false]))',
      );
      checkResult(runtime, true);
    });

    test('queue.peek returns list from queue of lists', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.peek(queue.new([[1, 2], [3, 4]]))',
      );
      checkResult(runtime, [1, 2]);
    });

    test('queue.dequeue removes element from queue of booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.dequeue(queue.new([true, false, true]))',
      );
      checkResult(runtime, [false, true]);
    });

    test('queue.reverse reverses queue of strings', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.reverse(queue.new(["a", "b", "c"]))',
      );
      checkResult(runtime, ['"c"', '"b"', '"a"']);
    });

    test('queue.reverse twice returns original queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.reverse(queue.reverse(queue.new([1, 2, 3])))',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('queue.dequeue then enqueue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.enqueue(queue.dequeue(queue.new([1, 2, 3])), 4)',
      );
      checkResult(runtime, [2, 3, 4]);
    });

    test('queue.enqueue after reverse', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.enqueue(queue.reverse(queue.new([1, 2, 3])), 4)',
      );
      checkResult(runtime, [3, 2, 1, 4]);
    });

    test('queue.reverse after dequeue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.reverse(queue.dequeue(queue.new([1, 2, 3])))',
      );
      checkResult(runtime, [3, 2]);
    });

    test('queue.peek after reverse returns last original element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.peek(queue.reverse(queue.new([1, 2, 3])))',
      );
      checkResult(runtime, 3);
    });

    test('queue.length is preserved after reverse', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.length(queue.reverse(queue.new([1, 2, 3])))',
      );
      checkResult(runtime, 3);
    });
  });

  group('Queue Type Errors', () {
    test('queue.new throws for non-list arg', () {
      final RuntimeFacade runtime = getRuntime('main = queue.new(1)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
    test('queue.enqueue throws for non-queue first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.enqueue([1, 2], 3)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.dequeue throws for non-queue arg', () {
      final RuntimeFacade runtime = getRuntime('main = queue.dequeue([1, 2])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.peek throws for non-queue arg', () {
      final RuntimeFacade runtime = getRuntime('main = queue.peek([1, 2])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.length throws for non-queue arg', () {
      final RuntimeFacade runtime = getRuntime('main = queue.length([1, 2])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.isEmpty throws for non-queue arg', () {
      final RuntimeFacade runtime = getRuntime('main = queue.isEmpty([1, 2])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.isNotEmpty throws for non-queue arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.isNotEmpty([1, 2])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.reverse throws for non-queue arg', () {
      final RuntimeFacade runtime = getRuntime('main = queue.reverse([1, 2])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.new throws for string arg', () {
      final RuntimeFacade runtime = getRuntime('main = queue.new("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.new throws for boolean arg', () {
      final RuntimeFacade runtime = getRuntime('main = queue.new(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.enqueue throws for string first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.enqueue("hello", 1)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.enqueue throws for number first arg', () {
      final RuntimeFacade runtime = getRuntime('main = queue.enqueue(42, 1)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.enqueue throws for boolean first arg', () {
      final RuntimeFacade runtime = getRuntime('main = queue.enqueue(true, 1)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.dequeue throws for string arg', () {
      final RuntimeFacade runtime = getRuntime('main = queue.dequeue("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.dequeue throws for number arg', () {
      final RuntimeFacade runtime = getRuntime('main = queue.dequeue(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.dequeue throws for boolean arg', () {
      final RuntimeFacade runtime = getRuntime('main = queue.dequeue(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.peek throws for string arg', () {
      final RuntimeFacade runtime = getRuntime('main = queue.peek("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.peek throws for number arg', () {
      final RuntimeFacade runtime = getRuntime('main = queue.peek(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.peek throws for boolean arg', () {
      final RuntimeFacade runtime = getRuntime('main = queue.peek(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.isEmpty throws for string arg', () {
      final RuntimeFacade runtime = getRuntime('main = queue.isEmpty("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.isEmpty throws for number arg', () {
      final RuntimeFacade runtime = getRuntime('main = queue.isEmpty(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.isEmpty throws for boolean arg', () {
      final RuntimeFacade runtime = getRuntime('main = queue.isEmpty(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.isNotEmpty throws for string arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.isNotEmpty("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.isNotEmpty throws for number arg', () {
      final RuntimeFacade runtime = getRuntime('main = queue.isNotEmpty(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.isNotEmpty throws for boolean arg', () {
      final RuntimeFacade runtime = getRuntime('main = queue.isNotEmpty(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.length throws for string arg', () {
      final RuntimeFacade runtime = getRuntime('main = queue.length("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.length throws for number arg', () {
      final RuntimeFacade runtime = getRuntime('main = queue.length(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.length throws for boolean arg', () {
      final RuntimeFacade runtime = getRuntime('main = queue.length(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.reverse throws for string arg', () {
      final RuntimeFacade runtime = getRuntime('main = queue.reverse("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.reverse throws for number arg', () {
      final RuntimeFacade runtime = getRuntime('main = queue.reverse(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.reverse throws for boolean arg', () {
      final RuntimeFacade runtime = getRuntime('main = queue.reverse(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });
}
