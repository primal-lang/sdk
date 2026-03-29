import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../helpers/assertion_helpers.dart';
import '../helpers/pipeline_helpers.dart';

void main() {
  group('Queue', () {
    test('queue.new 1', () {
      final Runtime runtime = getRuntime('main = queue.new([])');
      checkResult(runtime, []);
    });

    test('queue.new 2', () {
      final Runtime runtime = getRuntime('main = queue.new([1, 2])');
      checkResult(runtime, [1, 2]);
    });

    test('queue.enqueue 1', () {
      final Runtime runtime = getRuntime(
        'main = queue.enqueue(queue.new([]), 1)',
      );
      checkResult(runtime, [1]);
    });

    test('queue.enqueue 2', () {
      final Runtime runtime = getRuntime(
        'main = queue.enqueue(queue.new([1, 2]), 3)',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('queue.dequeue 1', () {
      final Runtime runtime = getRuntime(
        'main = queue.dequeue(queue.new([]))',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('queue.dequeue 2', () {
      final Runtime runtime = getRuntime(
        'main = queue.dequeue(queue.new([1, 2, 3]))',
      );
      checkResult(runtime, [2, 3]);
    });

    test('queue.dequeue 3', () {
      final Runtime runtime = getRuntime(
        'main = queue.dequeue(queue.new([1]))',
      );
      checkResult(runtime, []);
    });

    test('queue.peek 1', () {
      final Runtime runtime = getRuntime('main = queue.peek(queue.new([]))');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('queue.peek 2', () {
      final Runtime runtime = getRuntime(
        'main = queue.peek(queue.new([1, 2, 3]))',
      );
      checkResult(runtime, 1);
    });

    test('queue.peek 3', () {
      final Runtime runtime = getRuntime('main = queue.peek(queue.new([1]))');
      checkResult(runtime, 1);
    });

    test('queue.isEmpty 1', () {
      final Runtime runtime = getRuntime('main = queue.isEmpty(queue.new([]))');
      checkResult(runtime, true);
    });

    test('queue.isEmpty 2', () {
      final Runtime runtime = getRuntime(
        'main = queue.isEmpty(queue.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('queue.isNotEmpty 1', () {
      final Runtime runtime = getRuntime(
        'main = queue.isNotEmpty(queue.new([]))',
      );
      checkResult(runtime, false);
    });

    test('queue.isNotEmpty 2', () {
      final Runtime runtime = getRuntime(
        'main = queue.isNotEmpty(queue.new([1, 2, 3]))',
      );
      checkResult(runtime, true);
    });

    test('queue.length 1', () {
      final Runtime runtime = getRuntime('main = queue.length(queue.new([]))');
      checkResult(runtime, 0);
    });

    test('queue.length 2', () {
      final Runtime runtime = getRuntime(
        'main = queue.length(queue.new([1, 2, 3]))',
      );
      checkResult(runtime, 3);
    });

    test('queue.reverse 1', () {
      final Runtime runtime = getRuntime('main = queue.reverse(queue.new([]))');
      checkResult(runtime, []);
    });

    test('queue.reverse 2', () {
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
