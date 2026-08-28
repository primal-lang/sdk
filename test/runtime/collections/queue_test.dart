@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';

import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Queue', () {
    test('queue_new creates empty queue from empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = queue_new([])');
      checkResult(runtime, []);
    });

    test('queue_new creates queue from non-empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = queue_new([1, 2])');
      checkResult(runtime, [1, 2]);
    });

    test('queue_enqueue adds element to empty queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_enqueue(queue_new([]), 1)',
      );
      checkResult(runtime, [1]);
    });

    test('queue_enqueue adds element to back of non-empty queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_enqueue(queue_new([1, 2]), 3)',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('queue_dequeue throws on empty queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_dequeue(queue_new([]))',
      );
      expect(runtime.executeMain, throwsA(isA<EmptyCollectionError>()));
    });

    test('queue_dequeue removes front element from queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_dequeue(queue_new([1, 2, 3]))',
      );
      checkResult(runtime, [2, 3]);
    });

    test('queue_dequeue on single-element queue returns empty queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_dequeue(queue_new([1]))',
      );
      checkResult(runtime, []);
    });

    test('queue_peek throws on empty queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_peek(queue_new([]))',
      );
      expect(runtime.executeMain, throwsA(isA<EmptyCollectionError>()));
    });

    test('queue_peek returns front element of multi-element queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_peek(queue_new([1, 2, 3]))',
      );
      checkResult(runtime, 1);
    });

    test('queue_peek returns element of single-element queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_peek(queue_new([1]))',
      );
      checkResult(runtime, 1);
    });

    test('queue_isEmpty returns true for empty queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_isEmpty(queue_new([]))',
      );
      checkResult(runtime, true);
    });

    test('queue_isEmpty returns false for non-empty queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_isEmpty(queue_new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('queue_isNotEmpty returns false for empty queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_isNotEmpty(queue_new([]))',
      );
      checkResult(runtime, false);
    });

    test('queue_isNotEmpty returns true for non-empty queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_isNotEmpty(queue_new([1, 2, 3]))',
      );
      checkResult(runtime, true);
    });

    test('queue_length returns zero for empty queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_length(queue_new([]))',
      );
      checkResult(runtime, 0);
    });

    test('queue_length returns element count for non-empty queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_length(queue_new([1, 2, 3]))',
      );
      checkResult(runtime, 3);
    });

    test('queue_reverse on empty queue returns empty queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_reverse(queue_new([]))',
      );
      checkResult(runtime, []);
    });

    test('queue_reverse reverses element order', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_reverse(queue_new([1, 2, 3]))',
      );
      checkResult(runtime, [3, 2, 1]);
    });

    test('queue_reverse on single-element queue returns same queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_reverse(queue_new([1]))',
      );
      checkResult(runtime, [1]);
    });

    test('queue_length returns one for single-element queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_length(queue_new([1]))',
      );
      checkResult(runtime, 1);
    });

    test('queue_isEmpty returns false for single-element queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_isEmpty(queue_new([1]))',
      );
      checkResult(runtime, false);
    });

    test('queue_isNotEmpty returns true for single-element queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_isNotEmpty(queue_new([1]))',
      );
      checkResult(runtime, true);
    });

    test('queue_enqueue with string element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_enqueue(queue_new(["a", "b"]), "c")',
      );
      checkResult(runtime, '["a", "b", "c"]');
    });

    test('queue_enqueue with boolean element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_enqueue(queue_new([true]), false)',
      );
      checkResult(runtime, [true, false]);
    });

    test('queue_enqueue with mixed types', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_enqueue(queue_new([1, "two"]), true)',
      );
      checkResult(runtime, '[1, "two", true]');
    });

    test('queue_peek with string element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_peek(queue_new(["hello", "world"]))',
      );
      checkResult(runtime, '"hello"');
    });

    test('queue_dequeue with string elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_dequeue(queue_new(["a", "b", "c"]))',
      );
      checkResult(runtime, '["b", "c"]');
    });

    test('queue_new with nested list elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_new([[1, 2], [3, 4]])',
      );
      checkResult(runtime, [
        [1, 2],
        [3, 4],
      ]);
    });

    test('queue_enqueue multiple times', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_enqueue(queue_enqueue(queue_enqueue(queue_new([]), 1), 2), 3)',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('queue_dequeue after enqueue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_dequeue(queue_enqueue(queue_new([1, 2]), 3))',
      );
      checkResult(runtime, [2, 3]);
    });

    test('queue_peek after enqueue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_peek(queue_enqueue(queue_new([1]), 2))',
      );
      checkResult(runtime, 1);
    });

    test('queue_peek after dequeue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_peek(queue_dequeue(queue_new([1, 2, 3])))',
      );
      checkResult(runtime, 2);
    });

    test('queue_length after enqueue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_length(queue_enqueue(queue_new([1, 2]), 3))',
      );
      checkResult(runtime, 3);
    });

    test('queue_length after dequeue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_length(queue_dequeue(queue_new([1, 2, 3])))',
      );
      checkResult(runtime, 2);
    });

    test('queue_isEmpty after dequeue to empty', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_isEmpty(queue_dequeue(queue_new([1])))',
      );
      checkResult(runtime, true);
    });

    test('queue_isNotEmpty after enqueue to non-empty', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_isNotEmpty(queue_enqueue(queue_new([]), 1))',
      );
      checkResult(runtime, true);
    });

    test('queue_reverse after enqueue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_reverse(queue_enqueue(queue_new([1, 2]), 3))',
      );
      checkResult(runtime, [3, 2, 1]);
    });

    test('queue_reverse with two elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_reverse(queue_new([1, 2]))',
      );
      checkResult(runtime, [2, 1]);
    });

    test('queue_dequeue twice', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_dequeue(queue_dequeue(queue_new([1, 2, 3])))',
      );
      checkResult(runtime, [3]);
    });

    test('queue_new creates queue from list of strings', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_new(["a", "b", "c"])',
      );
      checkResult(runtime, ['"a"', '"b"', '"c"']);
    });

    test('queue_new creates queue from list of booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_new([true, false, true])',
      );
      checkResult(runtime, [true, false, true]);
    });

    test('queue_new creates queue from list of mixed types', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_new([1, "two", true])',
      );
      checkResult(runtime, [1, '"two"', true]);
    });

    test('queue_enqueue adds list element to queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_enqueue(queue_new([1]), [2, 3])',
      );
      checkResult(runtime, [1, '[2, 3]']);
    });

    test('queue_peek returns boolean from queue of booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_peek(queue_new([true, false]))',
      );
      checkResult(runtime, true);
    });

    test('queue_peek returns list from queue of lists', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_peek(queue_new([[1, 2], [3, 4]]))',
      );
      checkResult(runtime, [1, 2]);
    });

    test('queue_dequeue removes element from queue of booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_dequeue(queue_new([true, false, true]))',
      );
      checkResult(runtime, [false, true]);
    });

    test('queue_reverse reverses queue of strings', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_reverse(queue_new(["a", "b", "c"]))',
      );
      checkResult(runtime, ['"c"', '"b"', '"a"']);
    });

    test('queue_reverse twice returns original queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_reverse(queue_reverse(queue_new([1, 2, 3])))',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('queue_dequeue then enqueue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_enqueue(queue_dequeue(queue_new([1, 2, 3])), 4)',
      );
      checkResult(runtime, [2, 3, 4]);
    });

    test('queue_enqueue after reverse', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_enqueue(queue_reverse(queue_new([1, 2, 3])), 4)',
      );
      checkResult(runtime, [3, 2, 1, 4]);
    });

    test('queue_reverse after dequeue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_reverse(queue_dequeue(queue_new([1, 2, 3])))',
      );
      checkResult(runtime, [3, 2]);
    });

    test('queue_peek after reverse returns last original element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_peek(queue_reverse(queue_new([1, 2, 3])))',
      );
      checkResult(runtime, 3);
    });

    test('queue_length is preserved after reverse', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_length(queue_reverse(queue_new([1, 2, 3])))',
      );
      checkResult(runtime, 3);
    });

    test('queue_new creates queue from list of floats', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_new([1.5, 2.5, 3.5])',
      );
      checkResult(runtime, [1.5, 2.5, 3.5]);
    });

    test('queue_enqueue adds float element to queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_enqueue(queue_new([1.0]), 2.5)',
      );
      checkResult(runtime, [1.0, 2.5]);
    });

    test('queue_peek returns float from queue of floats', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_peek(queue_new([1.1, 2.2, 3.3]))',
      );
      checkResult(runtime, 1.1);
    });

    test('queue_dequeue removes element from queue of floats', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_dequeue(queue_new([1.1, 2.2, 3.3]))',
      );
      checkResult(runtime, [2.2, 3.3]);
    });

    test('queue_new creates queue from list of negative numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_new([-1, -2, -3])',
      );
      checkResult(runtime, [-1, -2, -3]);
    });

    test('queue_enqueue adds negative number to queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_enqueue(queue_new([1, 2]), -3)',
      );
      checkResult(runtime, [1, 2, -3]);
    });

    test('queue_peek returns negative number from queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_peek(queue_new([-1, -2, -3]))',
      );
      checkResult(runtime, -1);
    });

    test('queue_new creates queue with zero element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_new([0])',
      );
      checkResult(runtime, [0]);
    });

    test('queue_enqueue adds zero to queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_enqueue(queue_new([1, 2]), 0)',
      );
      checkResult(runtime, [1, 2, 0]);
    });

    test('queue_peek returns zero from queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_peek(queue_new([0, 1, 2]))',
      );
      checkResult(runtime, 0);
    });

    test('queue_new creates queue with empty string element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_new([""])',
      );
      checkResult(runtime, ['""']);
    });

    test('queue_enqueue adds empty string to queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_enqueue(queue_new(["a"]), "")',
      );
      checkResult(runtime, ['"a"', '""']);
    });

    test('queue_peek returns empty string from queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_peek(queue_new(["", "a"]))',
      );
      checkResult(runtime, '""');
    });

    test('queue_new creates queue with empty list element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_new([[]])',
      );
      checkResult(runtime, ['[]']);
    });

    test('queue_enqueue adds empty list to queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_enqueue(queue_new([1]), [])',
      );
      checkResult(runtime, [1, '[]']);
    });

    test('queue_peek returns empty list from queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_peek(queue_new([[], [1, 2]]))',
      );
      checkResult(runtime, []);
    });

    test(
      'queue_dequeue from two-element queue returns single-element queue',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = queue_dequeue(queue_new([1, 2]))',
        );
        checkResult(runtime, [2]);
      },
    );

    test('queue_peek on two-element queue returns front element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_peek(queue_new([1, 2]))',
      );
      checkResult(runtime, 1);
    });

    test('queue_length returns two for two-element queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_length(queue_new([1, 2]))',
      );
      checkResult(runtime, 2);
    });

    test('multiple dequeues until empty then check isEmpty', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_isEmpty(queue_dequeue(queue_dequeue(queue_new([1, 2]))))',
      );
      checkResult(runtime, true);
    });

    test('multiple enqueues to empty queue then check length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_length(queue_enqueue(queue_enqueue(queue_new([]), 1), 2))',
      );
      checkResult(runtime, 2);
    });

    test('enqueue then peek returns front element not enqueued', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_peek(queue_enqueue(queue_new([1]), 42))',
      );
      checkResult(runtime, 1);
    });

    test('dequeue then peek returns new front element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_peek(queue_dequeue(queue_new([1, 2, 3])))',
      );
      checkResult(runtime, 2);
    });

    test('reverse then dequeue removes original last element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_dequeue(queue_reverse(queue_new([1, 2, 3])))',
      );
      checkResult(runtime, [2, 1]);
    });

    test('reverse then peek returns original last element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_peek(queue_reverse(queue_new([10, 20, 30])))',
      );
      checkResult(runtime, 30);
    });

    test('dequeue then reverse on remaining elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_reverse(queue_dequeue(queue_new([1, 2, 3])))',
      );
      checkResult(runtime, [3, 2]);
    });

    test('queue operations with large numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_new([999999999, 1000000000, 1000000001])',
      );
      checkResult(runtime, [999999999, 1000000000, 1000000001]);
    });

    test('queue_peek with large number', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_peek(queue_new([999999999, 2, 3]))',
      );
      checkResult(runtime, 999999999);
    });

    test('queue_enqueue with deeply nested list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_enqueue(queue_new([]), [[1, 2], [3, [4, 5]]])',
      );
      checkResult(runtime, ['[[1, 2], [3, [4, 5]]]']);
    });

    test('queue_new with queue element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_length(queue_new([queue_new([1, 2])]))',
      );
      checkResult(runtime, 1);
    });

    test('queue_enqueue with queue as element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_length(queue_enqueue(queue_new([1]), queue_new([2, 3])))',
      );
      checkResult(runtime, 2);
    });

    test(
      'isEmpty returns true and isNotEmpty returns false for empty queue',
      () {
        final RuntimeFacade runtime1 = getRuntime(
          'main() = queue_isEmpty(queue_new([]))',
        );
        checkResult(runtime1, true);

        final RuntimeFacade runtime2 = getRuntime(
          'main() = queue_isNotEmpty(queue_new([]))',
        );
        checkResult(runtime2, false);
      },
    );

    test(
      'isEmpty returns false and isNotEmpty returns true for non-empty queue',
      () {
        final RuntimeFacade runtime1 = getRuntime(
          'main() = queue_isEmpty(queue_new([1]))',
        );
        checkResult(runtime1, false);

        final RuntimeFacade runtime2 = getRuntime(
          'main() = queue_isNotEmpty(queue_new([1]))',
        );
        checkResult(runtime2, true);
      },
    );

    test('queue_enqueue preserves FIFO order', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_peek(queue_enqueue(queue_enqueue(queue_enqueue(queue_new([]), 1), 2), 3))',
      );
      checkResult(runtime, 1);
    });

    test('queue_dequeue removes elements in FIFO order', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_peek(queue_dequeue(queue_dequeue(queue_new([1, 2, 3, 4]))))',
      );
      checkResult(runtime, 3);
    });
  });

  group('Queue Type Errors', () {
    test('queue_new throws for non-list arg', () {
      final RuntimeFacade runtime = getRuntime('main() = queue_new(1)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
    test('queue_enqueue throws for non-queue first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_enqueue([1, 2], 3)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue_dequeue throws for non-queue arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_dequeue([1, 2])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue_peek throws for non-queue arg', () {
      final RuntimeFacade runtime = getRuntime('main() = queue_peek([1, 2])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue_length throws for non-queue arg', () {
      final RuntimeFacade runtime = getRuntime('main() = queue_length([1, 2])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue_isEmpty throws for non-queue arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_isEmpty([1, 2])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue_isNotEmpty throws for non-queue arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_isNotEmpty([1, 2])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue_reverse throws for non-queue arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_reverse([1, 2])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue_new throws for string arg', () {
      final RuntimeFacade runtime = getRuntime('main() = queue_new("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue_new throws for boolean arg', () {
      final RuntimeFacade runtime = getRuntime('main() = queue_new(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue_enqueue throws for string first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_enqueue("hello", 1)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue_enqueue throws for number first arg', () {
      final RuntimeFacade runtime = getRuntime('main() = queue_enqueue(42, 1)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue_enqueue throws for boolean first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_enqueue(true, 1)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue_dequeue throws for string arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_dequeue("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue_dequeue throws for number arg', () {
      final RuntimeFacade runtime = getRuntime('main() = queue_dequeue(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue_dequeue throws for boolean arg', () {
      final RuntimeFacade runtime = getRuntime('main() = queue_dequeue(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue_peek throws for string arg', () {
      final RuntimeFacade runtime = getRuntime('main() = queue_peek("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue_peek throws for number arg', () {
      final RuntimeFacade runtime = getRuntime('main() = queue_peek(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue_peek throws for boolean arg', () {
      final RuntimeFacade runtime = getRuntime('main() = queue_peek(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue_isEmpty throws for string arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_isEmpty("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue_isEmpty throws for number arg', () {
      final RuntimeFacade runtime = getRuntime('main() = queue_isEmpty(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue_isEmpty throws for boolean arg', () {
      final RuntimeFacade runtime = getRuntime('main() = queue_isEmpty(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue_isNotEmpty throws for string arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_isNotEmpty("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue_isNotEmpty throws for number arg', () {
      final RuntimeFacade runtime = getRuntime('main() = queue_isNotEmpty(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue_isNotEmpty throws for boolean arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_isNotEmpty(true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue_length throws for string arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_length("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue_length throws for number arg', () {
      final RuntimeFacade runtime = getRuntime('main() = queue_length(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue_length throws for boolean arg', () {
      final RuntimeFacade runtime = getRuntime('main() = queue_length(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue_reverse throws for string arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_reverse("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue_reverse throws for number arg', () {
      final RuntimeFacade runtime = getRuntime('main() = queue_reverse(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue_reverse throws for boolean arg', () {
      final RuntimeFacade runtime = getRuntime('main() = queue_reverse(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Queue Error Messages', () {
    test(
      'queue_dequeue on empty queue throws EmptyCollectionError with correct message',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = queue_dequeue(queue_new([]))',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<EmptyCollectionError>().having(
              (Exception e) => e.toString(),
              'message',
              allOf(
                contains('empty queue'),
                contains('queue_dequeue'),
              ),
            ),
          ),
        );
      },
    );

    test(
      'queue_peek on empty queue throws EmptyCollectionError with correct message',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = queue_peek(queue_new([]))',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<EmptyCollectionError>().having(
              (Exception e) => e.toString(),
              'message',
              allOf(
                contains('empty queue'),
                contains('queue_peek'),
              ),
            ),
          ),
        );
      },
    );
  });

  group('Queue with Special Values', () {
    test('queue_new creates queue with map element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_length(queue_new([{"a": 1}]))',
      );
      checkResult(runtime, 1);
    });

    test('queue_enqueue adds map element to queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_length(queue_enqueue(queue_new([]), {"a": 1, "b": 2}))',
      );
      checkResult(runtime, 1);
    });

    test('queue_peek returns map from queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_peek(queue_new([{"a": 1}]))',
      );
      checkResult(runtime, '{"a": 1}');
    });

    test('queue_dequeue removes element from queue with map', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_length(queue_dequeue(queue_new([{"a": 1}, {"b": 2}])))',
      );
      checkResult(runtime, 1);
    });

    test('queue_new creates queue with function element', () {
      final RuntimeFacade runtime = getRuntime('''
double(x) = x * 2
main() = queue_length(queue_new([double]))
''');
      checkResult(runtime, 1);
    });

    test('queue_enqueue adds function element to queue', () {
      final RuntimeFacade runtime = getRuntime('''
double(x) = x * 2
main() = queue_length(queue_enqueue(queue_new([]), double))
''');
      checkResult(runtime, 1);
    });

    test('queue_new creates queue with whitespace string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_peek(queue_new(["   "]))',
      );
      checkResult(runtime, '"   "');
    });

    test('queue_enqueue adds whitespace string to queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_peek(queue_enqueue(queue_new([]), "  "))',
      );
      checkResult(runtime, '"  "');
    });

    test('queue_new creates queue with special float values', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_new([0.0, 0.0, 1.7976931348623157e+308])',
      );
      checkResult(runtime, [0.0, 0.0, 1.7976931348623157e+308]);
    });

    test('queue_enqueue adds very small float to queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_peek(queue_enqueue(queue_new([]), 2.2250738585072014e-308))',
      );
      checkResult(runtime, 2.2250738585072014e-308);
    });

    test('queue_peek returns very small float from queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_peek(queue_new([2.2250738585072014e-308]))',
      );
      checkResult(runtime, 2.2250738585072014e-308);
    });

    test('queue_new creates queue with newline in string', () {
      final RuntimeFacade runtime = getRuntime(
        r'main() = queue_length(queue_new(["hello\nworld"]))',
      );
      checkResult(runtime, 1);
    });

    test('queue_enqueue adds string with newline to queue', () {
      final RuntimeFacade runtime = getRuntime(
        r'main() = queue_length(queue_enqueue(queue_new([]), "line1\nline2"))',
      );
      checkResult(runtime, 1);
    });

    test('queue_new creates queue with tab in string', () {
      final RuntimeFacade runtime = getRuntime(
        r'main() = queue_length(queue_new(["hello\tworld"]))',
      );
      checkResult(runtime, 1);
    });
  });

  group('Queue Stress Tests', () {
    test('queue_new creates queue with many elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_length(queue_new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50]))',
      );
      checkResult(runtime, 50);
    });

    test('queue_peek returns first of many elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_peek(queue_new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]))',
      );
      checkResult(runtime, 1);
    });

    test('queue_reverse with many elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_peek(queue_reverse(queue_new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])))',
      );
      checkResult(runtime, 10);
    });

    test('queue_enqueue many times preserves FIFO order', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_peek(queue_enqueue(queue_enqueue(queue_enqueue(queue_enqueue(queue_enqueue(queue_enqueue(queue_enqueue(queue_enqueue(queue_enqueue(queue_enqueue(queue_new([]), 1), 2), 3), 4), 5), 6), 7), 8), 9), 10))',
      );
      checkResult(runtime, 1);
    });

    test('queue_dequeue many times returns remaining elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_peek(queue_dequeue(queue_dequeue(queue_dequeue(queue_dequeue(queue_dequeue(queue_new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])))))))',
      );
      checkResult(runtime, 6);
    });

    test('queue_length after many enqueues and dequeues', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_length(queue_dequeue(queue_dequeue(queue_enqueue(queue_enqueue(queue_enqueue(queue_new([1, 2, 3]), 4), 5), 6))))',
      );
      checkResult(runtime, 4);
    });
  });

  group('Queue Immutability', () {
    test('queue_enqueue does not modify original queue', () {
      final RuntimeFacade runtime = getRuntime('''
original() = queue_new([1, 2, 3])
modified() = queue_enqueue(original(), 4)
main() = queue_length(original())
''');
      checkResult(runtime, 3);
    });

    test('queue_dequeue does not modify original queue', () {
      final RuntimeFacade runtime = getRuntime('''
original() = queue_new([1, 2, 3])
modified() = queue_dequeue(original())
main() = queue_length(original())
''');
      checkResult(runtime, 3);
    });

    test('queue_reverse does not modify original queue', () {
      final RuntimeFacade runtime = getRuntime('''
original() = queue_new([1, 2, 3])
reversed() = queue_reverse(original())
main() = queue_peek(original())
''');
      checkResult(runtime, 1);
    });
  });

  group('Queue with Complex Nested Structures', () {
    test('queue_new creates queue with nested maps', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_length(queue_new([{"outer": {"inner": 1}}]))',
      );
      checkResult(runtime, 1);
    });

    test('queue_enqueue adds nested map to queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_length(queue_enqueue(queue_new([]), {"a": {"b": {"c": 1}}}))',
      );
      checkResult(runtime, 1);
    });

    test('queue_peek returns nested list from queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_peek(queue_new([[[1, 2], [3, 4]], [[5, 6], [7, 8]]]))',
      );
      checkResult(runtime, [
        [1, 2],
        [3, 4],
      ]);
    });

    test('queue_new creates queue with mixed nested structures', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_length(queue_new([[1, 2], {"a": 1}, [3, [4, 5]]]))',
      );
      checkResult(runtime, 3);
    });

    test('queue_dequeue removes nested structure from queue', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_peek(queue_dequeue(queue_new([[1, 2], [3, 4], [5, 6]])))',
      );
      checkResult(runtime, [3, 4]);
    });

    test('queue_reverse with nested structures', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = queue_peek(queue_reverse(queue_new([[1], [2], [3]])))',
      );
      checkResult(runtime, [3]);
    });
  });
}
