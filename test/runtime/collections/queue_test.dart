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
      expect(runtime.executeMain, throwsA(isA<EmptyCollectionError>()));
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
      expect(runtime.executeMain, throwsA(isA<EmptyCollectionError>()));
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

    test('queue.new creates queue from list of floats', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.new([1.5, 2.5, 3.5])',
      );
      checkResult(runtime, [1.5, 2.5, 3.5]);
    });

    test('queue.enqueue adds float element to queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.enqueue(queue.new([1.0]), 2.5)',
      );
      checkResult(runtime, [1.0, 2.5]);
    });

    test('queue.peek returns float from queue of floats', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.peek(queue.new([1.1, 2.2, 3.3]))',
      );
      checkResult(runtime, 1.1);
    });

    test('queue.dequeue removes element from queue of floats', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.dequeue(queue.new([1.1, 2.2, 3.3]))',
      );
      checkResult(runtime, [2.2, 3.3]);
    });

    test('queue.new creates queue from list of negative numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.new([-1, -2, -3])',
      );
      checkResult(runtime, [-1, -2, -3]);
    });

    test('queue.enqueue adds negative number to queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.enqueue(queue.new([1, 2]), -3)',
      );
      checkResult(runtime, [1, 2, -3]);
    });

    test('queue.peek returns negative number from queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.peek(queue.new([-1, -2, -3]))',
      );
      checkResult(runtime, -1);
    });

    test('queue.new creates queue with zero element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.new([0])',
      );
      checkResult(runtime, [0]);
    });

    test('queue.enqueue adds zero to queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.enqueue(queue.new([1, 2]), 0)',
      );
      checkResult(runtime, [1, 2, 0]);
    });

    test('queue.peek returns zero from queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.peek(queue.new([0, 1, 2]))',
      );
      checkResult(runtime, 0);
    });

    test('queue.new creates queue with empty string element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.new([""])',
      );
      checkResult(runtime, ['""']);
    });

    test('queue.enqueue adds empty string to queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.enqueue(queue.new(["a"]), "")',
      );
      checkResult(runtime, ['"a"', '""']);
    });

    test('queue.peek returns empty string from queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.peek(queue.new(["", "a"]))',
      );
      checkResult(runtime, '""');
    });

    test('queue.new creates queue with empty list element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.new([[]])',
      );
      checkResult(runtime, ['[]']);
    });

    test('queue.enqueue adds empty list to queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.enqueue(queue.new([1]), [])',
      );
      checkResult(runtime, [1, '[]']);
    });

    test('queue.peek returns empty list from queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.peek(queue.new([[], [1, 2]]))',
      );
      checkResult(runtime, []);
    });

    test(
      'queue.dequeue from two-element queue returns single-element queue',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main = queue.dequeue(queue.new([1, 2]))',
        );
        checkResult(runtime, [2]);
      },
    );

    test('queue.peek on two-element queue returns front element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.peek(queue.new([1, 2]))',
      );
      checkResult(runtime, 1);
    });

    test('queue.length returns two for two-element queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.length(queue.new([1, 2]))',
      );
      checkResult(runtime, 2);
    });

    test('multiple dequeues until empty then check isEmpty', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.isEmpty(queue.dequeue(queue.dequeue(queue.new([1, 2]))))',
      );
      checkResult(runtime, true);
    });

    test('multiple enqueues to empty queue then check length', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.length(queue.enqueue(queue.enqueue(queue.new([]), 1), 2))',
      );
      checkResult(runtime, 2);
    });

    test('enqueue then peek returns front element not enqueued', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.peek(queue.enqueue(queue.new([1]), 42))',
      );
      checkResult(runtime, 1);
    });

    test('dequeue then peek returns new front element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.peek(queue.dequeue(queue.new([1, 2, 3])))',
      );
      checkResult(runtime, 2);
    });

    test('reverse then dequeue removes original last element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.dequeue(queue.reverse(queue.new([1, 2, 3])))',
      );
      checkResult(runtime, [2, 1]);
    });

    test('reverse then peek returns original last element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.peek(queue.reverse(queue.new([10, 20, 30])))',
      );
      checkResult(runtime, 30);
    });

    test('dequeue then reverse on remaining elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.reverse(queue.dequeue(queue.new([1, 2, 3])))',
      );
      checkResult(runtime, [3, 2]);
    });

    test('queue operations with large numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.new([999999999, 1000000000, 1000000001])',
      );
      checkResult(runtime, [999999999, 1000000000, 1000000001]);
    });

    test('queue.peek with large number', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.peek(queue.new([999999999, 2, 3]))',
      );
      checkResult(runtime, 999999999);
    });

    test('queue.enqueue with deeply nested list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.enqueue(queue.new([]), [[1, 2], [3, [4, 5]]])',
      );
      checkResult(runtime, ['[[1, 2], [3, [4, 5]]]']);
    });

    test('queue.new with queue element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.length(queue.new([queue.new([1, 2])]))',
      );
      checkResult(runtime, 1);
    });

    test('queue.enqueue with queue as element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.length(queue.enqueue(queue.new([1]), queue.new([2, 3])))',
      );
      checkResult(runtime, 2);
    });

    test(
      'isEmpty returns true and isNotEmpty returns false for empty queue',
      () {
        final RuntimeFacade runtime1 = getRuntime(
          'main = queue.isEmpty(queue.new([]))',
        );
        checkResult(runtime1, true);

        final RuntimeFacade runtime2 = getRuntime(
          'main = queue.isNotEmpty(queue.new([]))',
        );
        checkResult(runtime2, false);
      },
    );

    test(
      'isEmpty returns false and isNotEmpty returns true for non-empty queue',
      () {
        final RuntimeFacade runtime1 = getRuntime(
          'main = queue.isEmpty(queue.new([1]))',
        );
        checkResult(runtime1, false);

        final RuntimeFacade runtime2 = getRuntime(
          'main = queue.isNotEmpty(queue.new([1]))',
        );
        checkResult(runtime2, true);
      },
    );

    test('queue.enqueue preserves FIFO order', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.peek(queue.enqueue(queue.enqueue(queue.enqueue(queue.new([]), 1), 2), 3))',
      );
      checkResult(runtime, 1);
    });

    test('queue.dequeue removes elements in FIFO order', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.peek(queue.dequeue(queue.dequeue(queue.new([1, 2, 3, 4]))))',
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

  group('Queue Error Messages', () {
    test(
      'queue.dequeue on empty queue throws EmptyCollectionError with correct message',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main = queue.dequeue(queue.new([]))',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<EmptyCollectionError>().having(
              (Exception e) => e.toString(),
              'message',
              allOf(
                contains('empty queue'),
                contains('queue.dequeue'),
              ),
            ),
          ),
        );
      },
    );

    test(
      'queue.peek on empty queue throws EmptyCollectionError with correct message',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main = queue.peek(queue.new([]))',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<EmptyCollectionError>().having(
              (Exception e) => e.toString(),
              'message',
              allOf(
                contains('empty queue'),
                contains('queue.peek'),
              ),
            ),
          ),
        );
      },
    );
  });

  group('Queue with Special Values', () {
    test('queue.new creates queue with map element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.length(queue.new([{"a": 1}]))',
      );
      checkResult(runtime, 1);
    });

    test('queue.enqueue adds map element to queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.length(queue.enqueue(queue.new([]), {"a": 1, "b": 2}))',
      );
      checkResult(runtime, 1);
    });

    test('queue.peek returns map from queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.peek(queue.new([{"a": 1}]))',
      );
      checkResult(runtime, '{"a": 1}');
    });

    test('queue.dequeue removes element from queue with map', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.length(queue.dequeue(queue.new([{"a": 1}, {"b": 2}])))',
      );
      checkResult(runtime, 1);
    });

    test('queue.new creates queue with function element', () {
      final RuntimeFacade runtime = getRuntime('''
double(x) = x * 2
main = queue.length(queue.new([double]))
''');
      checkResult(runtime, 1);
    });

    test('queue.enqueue adds function element to queue', () {
      final RuntimeFacade runtime = getRuntime('''
double(x) = x * 2
main = queue.length(queue.enqueue(queue.new([]), double))
''');
      checkResult(runtime, 1);
    });

    test('queue.new creates queue with whitespace string', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.peek(queue.new(["   "]))',
      );
      checkResult(runtime, '"   "');
    });

    test('queue.enqueue adds whitespace string to queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.peek(queue.enqueue(queue.new([]), "  "))',
      );
      checkResult(runtime, '"  "');
    });

    test('queue.new creates queue with special float values', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.new([0.0, 0.0, 1.7976931348623157e+308])',
      );
      checkResult(runtime, [0.0, 0.0, 1.7976931348623157e+308]);
    });

    test('queue.enqueue adds very small float to queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.peek(queue.enqueue(queue.new([]), 2.2250738585072014e-308))',
      );
      checkResult(runtime, 2.2250738585072014e-308);
    });

    test('queue.peek returns very small float from queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.peek(queue.new([2.2250738585072014e-308]))',
      );
      checkResult(runtime, 2.2250738585072014e-308);
    });

    test('queue.new creates queue with newline in string', () {
      final RuntimeFacade runtime = getRuntime(
        r'main = queue.length(queue.new(["hello\nworld"]))',
      );
      checkResult(runtime, 1);
    });

    test('queue.enqueue adds string with newline to queue', () {
      final RuntimeFacade runtime = getRuntime(
        r'main = queue.length(queue.enqueue(queue.new([]), "line1\nline2"))',
      );
      checkResult(runtime, 1);
    });

    test('queue.new creates queue with tab in string', () {
      final RuntimeFacade runtime = getRuntime(
        r'main = queue.length(queue.new(["hello\tworld"]))',
      );
      checkResult(runtime, 1);
    });
  });

  group('Queue Stress Tests', () {
    test('queue.new creates queue with many elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.length(queue.new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50]))',
      );
      checkResult(runtime, 50);
    });

    test('queue.peek returns first of many elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.peek(queue.new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]))',
      );
      checkResult(runtime, 1);
    });

    test('queue.reverse with many elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.peek(queue.reverse(queue.new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])))',
      );
      checkResult(runtime, 10);
    });

    test('queue.enqueue many times preserves FIFO order', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.peek(queue.enqueue(queue.enqueue(queue.enqueue(queue.enqueue(queue.enqueue(queue.enqueue(queue.enqueue(queue.enqueue(queue.enqueue(queue.enqueue(queue.new([]), 1), 2), 3), 4), 5), 6), 7), 8), 9), 10))',
      );
      checkResult(runtime, 1);
    });

    test('queue.dequeue many times returns remaining elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.peek(queue.dequeue(queue.dequeue(queue.dequeue(queue.dequeue(queue.dequeue(queue.new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])))))))',
      );
      checkResult(runtime, 6);
    });

    test('queue.length after many enqueues and dequeues', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.length(queue.dequeue(queue.dequeue(queue.enqueue(queue.enqueue(queue.enqueue(queue.new([1, 2, 3]), 4), 5), 6))))',
      );
      checkResult(runtime, 4);
    });
  });

  group('Queue Immutability', () {
    test('queue.enqueue does not modify original queue', () {
      final RuntimeFacade runtime = getRuntime('''
original = queue.new([1, 2, 3])
modified = queue.enqueue(original(), 4)
main = queue.length(original())
''');
      checkResult(runtime, 3);
    });

    test('queue.dequeue does not modify original queue', () {
      final RuntimeFacade runtime = getRuntime('''
original = queue.new([1, 2, 3])
modified = queue.dequeue(original())
main = queue.length(original())
''');
      checkResult(runtime, 3);
    });

    test('queue.reverse does not modify original queue', () {
      final RuntimeFacade runtime = getRuntime('''
original = queue.new([1, 2, 3])
reversed = queue.reverse(original())
main = queue.peek(original())
''');
      checkResult(runtime, 1);
    });
  });

  group('Queue with Complex Nested Structures', () {
    test('queue.new creates queue with nested maps', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.length(queue.new([{"outer": {"inner": 1}}]))',
      );
      checkResult(runtime, 1);
    });

    test('queue.enqueue adds nested map to queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.length(queue.enqueue(queue.new([]), {"a": {"b": {"c": 1}}}))',
      );
      checkResult(runtime, 1);
    });

    test('queue.peek returns nested list from queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.peek(queue.new([[[1, 2], [3, 4]], [[5, 6], [7, 8]]]))',
      );
      checkResult(runtime, [
        [1, 2],
        [3, 4],
      ]);
    });

    test('queue.new creates queue with mixed nested structures', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.length(queue.new([[1, 2], {"a": 1}, [3, [4, 5]]]))',
      );
      checkResult(runtime, 3);
    });

    test('queue.dequeue removes nested structure from queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.peek(queue.dequeue(queue.new([[1, 2], [3, 4], [5, 6]])))',
      );
      checkResult(runtime, [3, 4]);
    });

    test('queue.reverse with nested structures', () {
      final RuntimeFacade runtime = getRuntime(
        'main = queue.peek(queue.reverse(queue.new([[1], [2], [3]])))',
      );
      checkResult(runtime, [3]);
    });
  });
}
