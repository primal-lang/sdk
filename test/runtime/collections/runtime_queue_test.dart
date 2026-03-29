import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Queue', () {
    test('queue.new creates empty queue from empty list', () {
      final Runtime runtime = getRuntime('main = queue.new([])');
      checkResult(runtime, []);
    });

    test('queue.new creates queue from non-empty list', () {
      final Runtime runtime = getRuntime('main = queue.new([1, 2])');
      checkResult(runtime, [1, 2]);
    });

    test('queue.enqueue adds element to empty queue', () {
      final Runtime runtime = getRuntime(
        'main = queue.enqueue(queue.new([]), 1)',
      );
      checkResult(runtime, [1]);
    });

    test('queue.enqueue adds element to back of non-empty queue', () {
      final Runtime runtime = getRuntime(
        'main = queue.enqueue(queue.new([1, 2]), 3)',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('queue.dequeue throws on empty queue', () {
      final Runtime runtime = getRuntime(
        'main = queue.dequeue(queue.new([]))',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('queue.dequeue removes front element from queue', () {
      final Runtime runtime = getRuntime(
        'main = queue.dequeue(queue.new([1, 2, 3]))',
      );
      checkResult(runtime, [2, 3]);
    });

    test('queue.dequeue on single-element queue returns empty queue', () {
      final Runtime runtime = getRuntime(
        'main = queue.dequeue(queue.new([1]))',
      );
      checkResult(runtime, []);
    });

    test('queue.peek throws on empty queue', () {
      final Runtime runtime = getRuntime('main = queue.peek(queue.new([]))');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('queue.peek returns front element of multi-element queue', () {
      final Runtime runtime = getRuntime(
        'main = queue.peek(queue.new([1, 2, 3]))',
      );
      checkResult(runtime, 1);
    });

    test('queue.peek returns element of single-element queue', () {
      final Runtime runtime = getRuntime('main = queue.peek(queue.new([1]))');
      checkResult(runtime, 1);
    });

    test('queue.isEmpty returns true for empty queue', () {
      final Runtime runtime = getRuntime('main = queue.isEmpty(queue.new([]))');
      checkResult(runtime, true);
    });

    test('queue.isEmpty returns false for non-empty queue', () {
      final Runtime runtime = getRuntime(
        'main = queue.isEmpty(queue.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('queue.isNotEmpty returns false for empty queue', () {
      final Runtime runtime = getRuntime(
        'main = queue.isNotEmpty(queue.new([]))',
      );
      checkResult(runtime, false);
    });

    test('queue.isNotEmpty returns true for non-empty queue', () {
      final Runtime runtime = getRuntime(
        'main = queue.isNotEmpty(queue.new([1, 2, 3]))',
      );
      checkResult(runtime, true);
    });

    test('queue.length returns zero for empty queue', () {
      final Runtime runtime = getRuntime('main = queue.length(queue.new([]))');
      checkResult(runtime, 0);
    });

    test('queue.length returns element count for non-empty queue', () {
      final Runtime runtime = getRuntime(
        'main = queue.length(queue.new([1, 2, 3]))',
      );
      checkResult(runtime, 3);
    });

    test('queue.reverse on empty queue returns empty queue', () {
      final Runtime runtime = getRuntime('main = queue.reverse(queue.new([]))');
      checkResult(runtime, []);
    });

    test('queue.reverse reverses element order', () {
      final Runtime runtime = getRuntime(
        'main = queue.reverse(queue.new([1, 2, 3]))',
      );
      checkResult(runtime, [3, 2, 1]);
    });
  });

  group('Queue Type Errors', () {
    test('queue.enqueue throws for non-queue first arg', () {
      final Runtime runtime = getRuntime('main = queue.enqueue([1, 2], 3)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.dequeue throws for non-queue arg', () {
      final Runtime runtime = getRuntime('main = queue.dequeue([1, 2])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.peek throws for non-queue arg', () {
      final Runtime runtime = getRuntime('main = queue.peek([1, 2])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('queue.length throws for non-queue arg', () {
      final Runtime runtime = getRuntime('main = queue.length([1, 2])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });
}
