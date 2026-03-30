@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/library/error/throw.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Division and Modulo Edge Cases', () {
    test('division by zero produces infinity', () {
      final Runtime runtime = getRuntime('main = 1 / 0');
      checkResult(runtime, double.infinity);
    });

    test('negative division by zero produces negative infinity', () {
      final Runtime runtime = getRuntime('main = -1 / 0');
      checkResult(runtime, double.negativeInfinity);
    });

    test('integer modulo by zero throws', () {
      final Runtime runtime = getRuntime('main = 1 % 0');
      expect(
        runtime.executeMain,
        // ignore: deprecated_member_use
        throwsA(isA<IntegerDivisionByZeroException>()),
      );
    });

    test('decimal modulo by zero produces NaN', () {
      final Runtime runtime = getRuntime('main = 1.0 % 0');
      expect(runtime.executeMain(), 'NaN');
    });

    test('zero divided by zero produces NaN', () {
      final Runtime runtime = getRuntime('main = 0 / 0');
      expect(runtime.executeMain(), 'NaN');
    });
  });

  group('Empty Collection Errors', () {
    test('stack.pop on empty stack has descriptive message', () {
      final Runtime runtime = getRuntime('main = stack.pop(stack.new([]))');
      expect(
        runtime.executeMain,
        throwsA(
          isA<RuntimeError>().having(
            (e) => e.toString(),
            'message',
            contains('Cannot pop from an empty stack'),
          ),
        ),
      );
    });

    test('stack.peek on empty stack has descriptive message', () {
      final Runtime runtime = getRuntime('main = stack.peek(stack.new([]))');
      expect(
        runtime.executeMain,
        throwsA(
          isA<RuntimeError>().having(
            (e) => e.toString(),
            'message',
            contains('Cannot peek from an empty stack'),
          ),
        ),
      );
    });

    test('queue.dequeue on empty queue has descriptive message', () {
      final Runtime runtime = getRuntime(
        'main = queue.dequeue(queue.new([]))',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<RuntimeError>().having(
            (e) => e.toString(),
            'message',
            contains('Cannot dequeue from an empty queue'),
          ),
        ),
      );
    });

    test('queue.peek on empty queue has descriptive message', () {
      final Runtime runtime = getRuntime('main = queue.peek(queue.new([]))');
      expect(
        runtime.executeMain,
        throwsA(
          isA<RuntimeError>().having(
            (e) => e.toString(),
            'message',
            contains('Cannot peek from an empty queue'),
          ),
        ),
      );
    });
  });

  group('Map Access Errors', () {
    test('map.at with non-existent key has descriptive message', () {
      final Runtime runtime = getRuntime(
        'main = map.at({"a": 1, "b": 2}, "c")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidMapIndexError>().having(
            (e) => e.toString(),
            'message',
            contains('"c"'),
          ),
        ),
      );
    });
  });

  group('Vector Length Mismatch', () {
    test('vector.add with different lengths has descriptive message', () {
      final Runtime runtime = getRuntime(
        'main = vector.add(vector.new([1]), vector.new([1, 2, 3]))',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<IterablesWithDifferentLengthError>().having(
            (e) => e.toString(),
            'message',
            contains('different length'),
          ),
        ),
      );
    });

    test('vector.sub with different lengths has descriptive message', () {
      final Runtime runtime = getRuntime(
        'main = vector.sub(vector.new([1, 2, 3, 4]), vector.new([1]))',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<IterablesWithDifferentLengthError>().having(
            (e) => e.toString(),
            'message',
            contains('different length'),
          ),
        ),
      );
    });
  });

  group('Type Conversion Errors', () {
    test('to.number with non-numeric string throws FormatException', () {
      final Runtime runtime = getRuntime('main = to.number("abc")');
      expect(runtime.executeMain, throwsA(isA<FormatException>()));
    });

    test('to.integer with non-numeric string throws FormatException', () {
      final Runtime runtime = getRuntime('main = to.integer("abc")');
      expect(runtime.executeMain, throwsA(isA<FormatException>()));
    });

    test('to.decimal with non-numeric string throws FormatException', () {
      final Runtime runtime = getRuntime('main = to.decimal("abc")');
      expect(runtime.executeMain, throwsA(isA<FormatException>()));
    });
  });

  group('Custom Errors', () {
    test('error.throw raises CustomError with message', () {
      final Runtime runtime = getRuntime(
        'main = error.throw(42, "test error")',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<CustomError>().having(
            (e) => e.toString(),
            'message',
            contains('test error'),
          ),
        ),
      );
    });

    test('try catches error and returns fallback', () {
      final Runtime runtime = getRuntime(
        'main = try(error.throw(0, "oops"), "recovered")',
      );
      checkResult(runtime, '"recovered"');
    });

    test('try catches type error and returns fallback', () {
      final Runtime runtime = getRuntime('main = try(1 + true, -1)');
      checkResult(runtime, -1);
    });
  });

  group('Invalid Argument Count', () {
    test('too few arguments throws InvalidArgumentCountError', () {
      final Runtime runtime = getRuntime(
        'apply(f, x) = f(x)\nadd(a, b) = a + b\nmain = apply(add, 1)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentCountError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('Expected: 2'),
              contains('Actual: 1'),
            ),
          ),
        ),
      );
    });

    test('too many arguments throws InvalidArgumentCountError', () {
      final Runtime runtime = getRuntime(
        'apply(f, x, y, z) = f(x, y, z)\nadd(a, b) = a + b\nmain = apply(add, 1, 2, 3)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentCountError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('Expected: 2'),
              contains('Actual: 3'),
            ),
          ),
        ),
      );
    });
  });

  group('Cross-Type Comparison Errors', () {
    test('list equals string throws InvalidArgumentTypesError', () {
      final Runtime runtime = getRuntime('main = [1, 2] == "hello"');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    test('map equals list throws InvalidArgumentTypesError', () {
      final Runtime runtime = getRuntime('main = {"a": 1} == [1]');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });
  });
}
