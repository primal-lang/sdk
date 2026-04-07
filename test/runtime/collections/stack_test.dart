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
  });
}
