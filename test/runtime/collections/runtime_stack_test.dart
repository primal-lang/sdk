import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Stack', () {
    test('stack.new 1', () {
      final Runtime runtime = getRuntime('main = stack.new([])');
      checkResult(runtime, []);
    });

    test('stack.new 2', () {
      final Runtime runtime = getRuntime('main = stack.new([1, 2])');
      checkResult(runtime, [1, 2]);
    });

    test('stack.push 1', () {
      final Runtime runtime = getRuntime('main = stack.push(stack.new([]), 1)');
      checkResult(runtime, [1]);
    });

    test('stack.push 2', () {
      final Runtime runtime = getRuntime(
        'main = stack.push(stack.new([1, 2]), 3)',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('stack.pop 1', () {
      final Runtime runtime = getRuntime('main = stack.pop(stack.new([]))');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('stack.pop 2', () {
      final Runtime runtime = getRuntime(
        'main = stack.pop(stack.new([1, 2, 3]))',
      );
      checkResult(runtime, [1, 2]);
    });

    test('stack.pop 3', () {
      final Runtime runtime = getRuntime('main = stack.pop(stack.new([1]))');
      checkResult(runtime, []);
    });

    test('stack.peek 1', () {
      final Runtime runtime = getRuntime('main = stack.peek(stack.new([]))');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('stack.peek 2', () {
      final Runtime runtime = getRuntime(
        'main = stack.peek(stack.new([1, 2, 3]))',
      );
      checkResult(runtime, 3);
    });

    test('stack.peek 3', () {
      final Runtime runtime = getRuntime('main = stack.peek(stack.new([1]))');
      checkResult(runtime, 1);
    });

    test('stack.isEmpty 1', () {
      final Runtime runtime = getRuntime('main = stack.isEmpty(stack.new([]))');
      checkResult(runtime, true);
    });

    test('stack.isEmpty 2', () {
      final Runtime runtime = getRuntime(
        'main = stack.isEmpty(stack.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('stack.isNotEmpty 1', () {
      final Runtime runtime = getRuntime(
        'main = stack.isNotEmpty(stack.new([]))',
      );
      checkResult(runtime, false);
    });

    test('stack.isNotEmpty 2', () {
      final Runtime runtime = getRuntime(
        'main = stack.isNotEmpty(stack.new([1, 2, 3]))',
      );
      checkResult(runtime, true);
    });

    test('stack.length 1', () {
      final Runtime runtime = getRuntime('main = stack.length(stack.new([]))');
      checkResult(runtime, 0);
    });

    test('stack.length 2', () {
      final Runtime runtime = getRuntime(
        'main = stack.length(stack.new([1, 2, 3]))',
      );
      checkResult(runtime, 3);
    });

    test('stack.reverse 1', () {
      final Runtime runtime = getRuntime('main = stack.reverse(stack.new([]))');
      checkResult(runtime, []);
    });

    test('stack.reverse 2', () {
      final Runtime runtime = getRuntime(
        'main = stack.reverse(stack.new([1, 2, 3]))',
      );
      checkResult(runtime, [3, 2, 1]);
    });
  });

  group('Stack Type Errors', () {
    test('stack.push throws for non-stack first arg', () {
      final Runtime runtime = getRuntime('main = stack.push([1, 2], 3)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.pop throws for non-stack arg', () {
      final Runtime runtime = getRuntime('main = stack.pop([1, 2])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.peek throws for non-stack arg', () {
      final Runtime runtime = getRuntime('main = stack.peek([1, 2])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('stack.length throws for non-stack arg', () {
      final Runtime runtime = getRuntime('main = stack.length([1, 2])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });
}
