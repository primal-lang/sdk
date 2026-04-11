@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('comp.eq', () {
    group('Boolean', () {
      test('returns true for equal booleans (true)', () {
        final RuntimeFacade runtime = getRuntime('main = comp.eq(true, true)');
        checkResult(runtime, true);
      });

      test('returns true for equal booleans (false)', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.eq(false, false)',
        );
        checkResult(runtime, true);
      });

      test('returns false for unequal booleans', () {
        final RuntimeFacade runtime = getRuntime('main = comp.eq(true, false)');
        checkResult(runtime, false);
      });
    });

    group('Number', () {
      test('returns true for equal integers', () {
        final RuntimeFacade runtime = getRuntime('main = comp.eq(42, 42)');
        checkResult(runtime, true);
      });

      test('returns false for unequal integers', () {
        final RuntimeFacade runtime = getRuntime('main = comp.eq(42, 43)');
        checkResult(runtime, false);
      });

      test('returns true for equal decimals', () {
        final RuntimeFacade runtime = getRuntime('main = comp.eq(3.14, 3.14)');
        checkResult(runtime, true);
      });

      test('returns false for unequal decimals', () {
        final RuntimeFacade runtime = getRuntime('main = comp.eq(3.14, 3.15)');
        checkResult(runtime, false);
      });

      test('returns true for zero', () {
        final RuntimeFacade runtime = getRuntime('main = comp.eq(0, 0)');
        checkResult(runtime, true);
      });

      test('returns true for negative numbers', () {
        final RuntimeFacade runtime = getRuntime('main = comp.eq(-5, -5)');
        checkResult(runtime, true);
      });
    });

    group('String', () {
      test('returns true for equal strings', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.eq("hey", "hey")',
        );
        checkResult(runtime, true);
      });

      test('returns false for unequal strings', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.eq("hello", "world")',
        );
        checkResult(runtime, false);
      });

      test('returns true for empty strings', () {
        final RuntimeFacade runtime = getRuntime('main = comp.eq("", "")');
        checkResult(runtime, true);
      });

      test('returns false for case-different strings', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.eq("Hello", "hello")',
        );
        checkResult(runtime, false);
      });
    });

    group('Timestamp', () {
      test('returns true for equal timestamps', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.eq(time.fromIso("2024-01-01T00:00:00"), time.fromIso("2024-01-01T00:00:00"))',
        );
        checkResult(runtime, true);
      });

      test('returns false for unequal timestamps', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.eq(time.fromIso("2024-01-01T00:00:00"), time.fromIso("2024-01-02T00:00:00"))',
        );
        checkResult(runtime, false);
      });
    });

    group('List', () {
      test('returns true for equal lists', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.eq([1, 2, 3], [1, 2, 3])',
        );
        checkResult(runtime, true);
      });

      test('returns false for lists with different lengths', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.eq([1, 2, 3], [1, 2])',
        );
        checkResult(runtime, false);
      });

      test('returns false for lists with different elements', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.eq([1, 2, 3], [1, 2, 4])',
        );
        checkResult(runtime, false);
      });

      test('returns true for empty lists', () {
        final RuntimeFacade runtime = getRuntime('main = comp.eq([], [])');
        checkResult(runtime, true);
      });

      test('returns true for nested lists', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.eq([[1, 2], [3]], [[1, 2], [3]])',
        );
        checkResult(runtime, true);
      });

      test('returns false for nested lists with different elements', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.eq([[1, 2], [3]], [[1, 2], [4]])',
        );
        checkResult(runtime, false);
      });
    });

    group('Vector', () {
      test('returns true for equal vectors', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.eq(vector.new([1, 2, 3]), vector.new([1, 2, 3]))',
        );
        checkResult(runtime, true);
      });

      test('returns false for vectors with different lengths', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.eq(vector.new([1, 2, 3]), vector.new([1, 2]))',
        );
        checkResult(runtime, false);
      });

      test('returns false for vectors with different elements', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.eq(vector.new([1, 2, 3]), vector.new([1, 2, 4]))',
        );
        checkResult(runtime, false);
      });

      test('returns true for empty vectors', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.eq(vector.new([]), vector.new([]))',
        );
        checkResult(runtime, true);
      });
    });

    group('Stack', () {
      test('returns true for equal stacks', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.eq(stack.new([1, 2, 3]), stack.new([1, 2, 3]))',
        );
        checkResult(runtime, true);
      });

      test('returns false for stacks with different lengths', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.eq(stack.new([1, 2, 3]), stack.new([1, 2]))',
        );
        checkResult(runtime, false);
      });

      test('returns false for stacks with different elements', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.eq(stack.new([1, 2, 3]), stack.new([1, 2, 4]))',
        );
        checkResult(runtime, false);
      });

      test('returns true for empty stacks', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.eq(stack.new([]), stack.new([]))',
        );
        checkResult(runtime, true);
      });
    });

    group('Queue', () {
      test('returns true for equal queues', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.eq(queue.new([1, 2, 3]), queue.new([1, 2, 3]))',
        );
        checkResult(runtime, true);
      });

      test('returns false for queues with different lengths', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.eq(queue.new([1, 2, 3]), queue.new([1, 2]))',
        );
        checkResult(runtime, false);
      });

      test('returns false for queues with different elements', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.eq(queue.new([1, 2, 3]), queue.new([1, 2, 4]))',
        );
        checkResult(runtime, false);
      });

      test('returns true for empty queues', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.eq(queue.new([]), queue.new([]))',
        );
        checkResult(runtime, true);
      });
    });

    group('Set', () {
      test('returns true for equal sets', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.eq(set.new([1, 2, 3]), set.new([1, 2, 3]))',
        );
        checkResult(runtime, true);
      });

      test('returns true for equal sets with different order', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.eq(set.new([1, 2, 3]), set.new([3, 2, 1]))',
        );
        checkResult(runtime, true);
      });

      test('returns false for sets with different sizes', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.eq(set.new([1, 2, 3]), set.new([1, 2]))',
        );
        checkResult(runtime, false);
      });

      test('returns false for sets with different elements', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.eq(set.new([1, 2, 3]), set.new([1, 2, 4]))',
        );
        checkResult(runtime, false);
      });

      test('returns true for empty sets', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.eq(set.new([]), set.new([]))',
        );
        checkResult(runtime, true);
      });
    });

    group('File', () {
      test('returns true for equal files', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.eq(file.fromPath("."), file.fromPath("."))',
        );
        checkResult(runtime, true);
      });

      test('returns false for unequal files', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.eq(file.fromPath("."), file.fromPath(".."))',
        );
        checkResult(runtime, false);
      });
    });

    group('Directory', () {
      test('returns true for equal directories', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.eq(directory.fromPath("."), directory.fromPath("."))',
        );
        checkResult(runtime, true);
      });

      test('returns false for unequal directories', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.eq(directory.fromPath("."), directory.fromPath(".."))',
        );
        checkResult(runtime, false);
      });
    });

    group('Map', () {
      test('returns true for equal maps', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.eq({"x": 1, "y": 2}, {"x": 1, "y": 2})',
        );
        checkResult(runtime, true);
      });

      test('returns false for maps with different sizes', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.eq({"x": 1, "y": 2}, {"x": 1})',
        );
        checkResult(runtime, false);
      });

      test('returns false for maps with different keys', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.eq({"x": 1, "y": 2}, {"x": 1, "z": 2})',
        );
        checkResult(runtime, false);
      });

      test('returns false for maps with different values', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.eq({"x": 1, "y": 2}, {"x": 1, "y": 3})',
        );
        checkResult(runtime, false);
      });

      test('returns true for equal maps with different insertion order', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.eq({"x": 1, "y": 2}, {"y": 2, "x": 1})',
        );
        checkResult(runtime, true);
      });

      test('returns true for empty maps', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.eq({}, {})',
        );
        checkResult(runtime, true);
      });

      test('returns true for nested maps', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.eq({"x": {"a": 1}}, {"x": {"a": 1}})',
        );
        checkResult(runtime, true);
      });

      test('returns false for nested maps with different values', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.eq({"x": {"a": 1}}, {"x": {"a": 2}})',
        );
        checkResult(runtime, false);
      });
    });

    group('Type Errors', () {
      test('throws for mismatched types (string and number)', () {
        final RuntimeFacade runtime = getRuntime('main = comp.eq("hello", 1)');
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('throws for mismatched types (boolean and number)', () {
        final RuntimeFacade runtime = getRuntime('main = comp.eq(true, 1)');
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('throws for mismatched types (list and number)', () {
        final RuntimeFacade runtime = getRuntime('main = comp.eq([1, 2], 1)');
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });
    });
  });

  group('comp.neq', () {
    group('Boolean', () {
      test('returns false for equal booleans', () {
        final RuntimeFacade runtime = getRuntime('main = comp.neq(true, true)');
        checkResult(runtime, false);
      });

      test('returns true for unequal booleans', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.neq(true, false)',
        );
        checkResult(runtime, true);
      });
    });

    group('Number', () {
      test('returns true for unequal numbers', () {
        final RuntimeFacade runtime = getRuntime('main = comp.neq(7, 8)');
        checkResult(runtime, true);
      });

      test('returns false for equal numbers', () {
        final RuntimeFacade runtime = getRuntime('main = comp.neq(7, 7)');
        checkResult(runtime, false);
      });
    });

    group('String', () {
      test('returns true for unequal strings', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.neq("hello", "world")',
        );
        checkResult(runtime, true);
      });

      test('returns false for equal strings', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.neq("hello", "hello")',
        );
        checkResult(runtime, false);
      });
    });

    group('List', () {
      test('returns true for unequal lists', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.neq([1, 2, 3], [1, 2, 4])',
        );
        checkResult(runtime, true);
      });

      test('returns false for equal lists', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.neq([1, 2, 3], [1, 2, 3])',
        );
        checkResult(runtime, false);
      });

      test('returns true for lists with different lengths', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.neq([1, 2, 3], [1, 2])',
        );
        checkResult(runtime, true);
      });
    });

    group('Timestamp', () {
      test('returns false for equal timestamps', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.neq(time.fromIso("2024-01-01T00:00:00"), time.fromIso("2024-01-01T00:00:00"))',
        );
        checkResult(runtime, false);
      });

      test('returns true for unequal timestamps', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.neq(time.fromIso("2024-01-01T00:00:00"), time.fromIso("2024-01-02T00:00:00"))',
        );
        checkResult(runtime, true);
      });
    });

    group('Vector', () {
      test('returns false for equal vectors', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.neq(vector.new([1, 2, 3]), vector.new([1, 2, 3]))',
        );
        checkResult(runtime, false);
      });

      test('returns true for unequal vectors', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.neq(vector.new([1, 2, 3]), vector.new([1, 2, 4]))',
        );
        checkResult(runtime, true);
      });
    });

    group('Stack', () {
      test('returns false for equal stacks', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.neq(stack.new([1, 2, 3]), stack.new([1, 2, 3]))',
        );
        checkResult(runtime, false);
      });

      test('returns true for unequal stacks', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.neq(stack.new([1, 2, 3]), stack.new([1, 2, 4]))',
        );
        checkResult(runtime, true);
      });
    });

    group('Queue', () {
      test('returns false for equal queues', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.neq(queue.new([1, 2, 3]), queue.new([1, 2, 3]))',
        );
        checkResult(runtime, false);
      });

      test('returns true for unequal queues', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.neq(queue.new([1, 2, 3]), queue.new([1, 2, 4]))',
        );
        checkResult(runtime, true);
      });
    });

    group('Set', () {
      test('returns false for equal sets', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.neq(set.new([1, 2, 3]), set.new([1, 2, 3]))',
        );
        checkResult(runtime, false);
      });

      test('returns true for unequal sets', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.neq(set.new([1, 2, 3]), set.new([1, 2]))',
        );
        checkResult(runtime, true);
      });
    });

    group('Map', () {
      test('returns false for equal maps', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.neq({"x": 1, "y": 2}, {"x": 1, "y": 2})',
        );
        checkResult(runtime, false);
      });

      test('returns true for unequal maps', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.neq({"x": 1, "y": 2}, {"x": 1, "y": 3})',
        );
        checkResult(runtime, true);
      });
    });

    group('File', () {
      test('returns false for equal files', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.neq(file.fromPath("."), file.fromPath("."))',
        );
        checkResult(runtime, false);
      });

      test('returns true for unequal files', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.neq(file.fromPath("."), file.fromPath(".."))',
        );
        checkResult(runtime, true);
      });
    });

    group('Directory', () {
      test('returns false for equal directories', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.neq(directory.fromPath("."), directory.fromPath("."))',
        );
        checkResult(runtime, false);
      });

      test('returns true for unequal directories', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.neq(directory.fromPath("."), directory.fromPath(".."))',
        );
        checkResult(runtime, true);
      });
    });

    group('Type Errors', () {
      test('throws for mismatched types', () {
        final RuntimeFacade runtime = getRuntime('main = comp.neq("hello", 1)');
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });
    });
  });

  group('comp.gt', () {
    group('Number', () {
      test('returns true when first is greater', () {
        final RuntimeFacade runtime = getRuntime('main = comp.gt(10, 4)');
        checkResult(runtime, true);
      });

      test('returns false when first is less', () {
        final RuntimeFacade runtime = getRuntime('main = comp.gt(4, 10)');
        checkResult(runtime, false);
      });

      test('returns false when equal', () {
        final RuntimeFacade runtime = getRuntime('main = comp.gt(5, 5)');
        checkResult(runtime, false);
      });

      test('works with negative numbers', () {
        final RuntimeFacade runtime = getRuntime('main = comp.gt(-1, -5)');
        checkResult(runtime, true);
      });

      test('works with decimals', () {
        final RuntimeFacade runtime = getRuntime('main = comp.gt(3.15, 3.14)');
        checkResult(runtime, true);
      });
    });

    group('String', () {
      test('returns true for lexicographically greater string', () {
        final RuntimeFacade runtime = getRuntime('main = comp.gt("b", "a")');
        checkResult(runtime, true);
      });

      test('returns false for lexicographically lesser string', () {
        final RuntimeFacade runtime = getRuntime('main = comp.gt("a", "b")');
        checkResult(runtime, false);
      });

      test('returns false for equal strings', () {
        final RuntimeFacade runtime = getRuntime('main = comp.gt("a", "a")');
        checkResult(runtime, false);
      });

      test('compares by length when prefix matches', () {
        final RuntimeFacade runtime = getRuntime('main = comp.gt("ab", "a")');
        checkResult(runtime, true);
      });
    });

    group('Timestamp', () {
      test('returns true when first timestamp is later', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.gt(time.fromIso("2024-01-02T00:00:00"), time.fromIso("2024-01-01T00:00:00"))',
        );
        checkResult(runtime, true);
      });

      test('returns false when first timestamp is earlier', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.gt(time.fromIso("2024-01-01T00:00:00"), time.fromIso("2024-01-02T00:00:00"))',
        );
        checkResult(runtime, false);
      });

      test('returns false when timestamps are equal', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.gt(time.fromIso("2024-01-01T00:00:00"), time.fromIso("2024-01-01T00:00:00"))',
        );
        checkResult(runtime, false);
      });
    });
  });

  group('comp.lt', () {
    group('Number', () {
      test('returns true when first is less', () {
        final RuntimeFacade runtime = getRuntime('main = comp.lt(4, 10)');
        checkResult(runtime, true);
      });

      test('returns false when first is greater', () {
        final RuntimeFacade runtime = getRuntime('main = comp.lt(10, 4)');
        checkResult(runtime, false);
      });

      test('returns false when equal', () {
        final RuntimeFacade runtime = getRuntime('main = comp.lt(5, 5)');
        checkResult(runtime, false);
      });

      test('works with negative numbers', () {
        final RuntimeFacade runtime = getRuntime('main = comp.lt(-5, -1)');
        checkResult(runtime, true);
      });

      test('works with decimals', () {
        final RuntimeFacade runtime = getRuntime('main = comp.lt(3.14, 3.15)');
        checkResult(runtime, true);
      });
    });

    group('String', () {
      test('returns true for lexicographically lesser string', () {
        final RuntimeFacade runtime = getRuntime('main = comp.lt("a", "b")');
        checkResult(runtime, true);
      });

      test('returns false for lexicographically greater string', () {
        final RuntimeFacade runtime = getRuntime('main = comp.lt("b", "a")');
        checkResult(runtime, false);
      });

      test('returns false for equal strings', () {
        final RuntimeFacade runtime = getRuntime('main = comp.lt("a", "a")');
        checkResult(runtime, false);
      });

      test('compares by length when prefix matches', () {
        final RuntimeFacade runtime = getRuntime('main = comp.lt("a", "ab")');
        checkResult(runtime, true);
      });
    });

    group('Timestamp', () {
      test('returns true when first timestamp is earlier', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.lt(time.fromIso("2024-01-01T00:00:00"), time.fromIso("2024-01-02T00:00:00"))',
        );
        checkResult(runtime, true);
      });

      test('returns false when first timestamp is later', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.lt(time.fromIso("2024-01-02T00:00:00"), time.fromIso("2024-01-01T00:00:00"))',
        );
        checkResult(runtime, false);
      });

      test('returns false when timestamps are equal', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.lt(time.fromIso("2024-01-01T00:00:00"), time.fromIso("2024-01-01T00:00:00"))',
        );
        checkResult(runtime, false);
      });
    });
  });

  group('comp.ge', () {
    group('Number', () {
      test('returns true when first is greater', () {
        final RuntimeFacade runtime = getRuntime('main = comp.ge(10, 4)');
        checkResult(runtime, true);
      });

      test('returns true when equal', () {
        final RuntimeFacade runtime = getRuntime('main = comp.ge(10, 10)');
        checkResult(runtime, true);
      });

      test('returns false when first is less', () {
        final RuntimeFacade runtime = getRuntime('main = comp.ge(4, 10)');
        checkResult(runtime, false);
      });

      test('works with negative numbers', () {
        final RuntimeFacade runtime = getRuntime('main = comp.ge(-1, -1)');
        checkResult(runtime, true);
      });

      test('works with decimals', () {
        final RuntimeFacade runtime = getRuntime('main = comp.ge(3.14, 3.14)');
        checkResult(runtime, true);
      });
    });

    group('String', () {
      test('returns true for lexicographically greater string', () {
        final RuntimeFacade runtime = getRuntime('main = comp.ge("b", "a")');
        checkResult(runtime, true);
      });

      test('returns true for equal strings', () {
        final RuntimeFacade runtime = getRuntime('main = comp.ge("a", "a")');
        checkResult(runtime, true);
      });

      test('returns false for lexicographically lesser string', () {
        final RuntimeFacade runtime = getRuntime('main = comp.ge("a", "b")');
        checkResult(runtime, false);
      });
    });

    group('Timestamp', () {
      test('returns true when first timestamp is later', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.ge(time.fromIso("2024-01-02T00:00:00"), time.fromIso("2024-01-01T00:00:00"))',
        );
        checkResult(runtime, true);
      });

      test('returns true when timestamps are equal', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.ge(time.fromIso("2024-01-01T00:00:00"), time.fromIso("2024-01-01T00:00:00"))',
        );
        checkResult(runtime, true);
      });

      test('returns false when first timestamp is earlier', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.ge(time.fromIso("2024-01-01T00:00:00"), time.fromIso("2024-01-02T00:00:00"))',
        );
        checkResult(runtime, false);
      });
    });
  });

  group('comp.le', () {
    group('Number', () {
      test('returns true when first is less', () {
        final RuntimeFacade runtime = getRuntime('main = comp.le(4, 10)');
        checkResult(runtime, true);
      });

      test('returns true when equal', () {
        final RuntimeFacade runtime = getRuntime('main = comp.le(10, 10)');
        checkResult(runtime, true);
      });

      test('returns false when first is greater', () {
        final RuntimeFacade runtime = getRuntime('main = comp.le(10, 4)');
        checkResult(runtime, false);
      });

      test('works with negative numbers', () {
        final RuntimeFacade runtime = getRuntime('main = comp.le(-1, -1)');
        checkResult(runtime, true);
      });

      test('works with decimals', () {
        final RuntimeFacade runtime = getRuntime('main = comp.le(3.14, 3.14)');
        checkResult(runtime, true);
      });
    });

    group('String', () {
      test('returns true for lexicographically lesser string', () {
        final RuntimeFacade runtime = getRuntime('main = comp.le("a", "b")');
        checkResult(runtime, true);
      });

      test('returns true for equal strings', () {
        final RuntimeFacade runtime = getRuntime('main = comp.le("a", "a")');
        checkResult(runtime, true);
      });

      test('returns false for lexicographically greater string', () {
        final RuntimeFacade runtime = getRuntime('main = comp.le("b", "a")');
        checkResult(runtime, false);
      });
    });

    group('Timestamp', () {
      test('returns true when first timestamp is earlier', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.le(time.fromIso("2024-01-01T00:00:00"), time.fromIso("2024-01-02T00:00:00"))',
        );
        checkResult(runtime, true);
      });

      test('returns true when timestamps are equal', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.le(time.fromIso("2024-01-01T00:00:00"), time.fromIso("2024-01-01T00:00:00"))',
        );
        checkResult(runtime, true);
      });

      test('returns false when first timestamp is later', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.le(time.fromIso("2024-01-02T00:00:00"), time.fromIso("2024-01-01T00:00:00"))',
        );
        checkResult(runtime, false);
      });
    });
  });

  group('Type Errors', () {
    group('comp.gt', () {
      test('throws for mismatched types (string and number)', () {
        final RuntimeFacade runtime = getRuntime('main = comp.gt("hello", 1)');
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('throws for non-comparable types (lists)', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.gt([1, 2], [3, 4])',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('throws for non-comparable types (booleans)', () {
        final RuntimeFacade runtime = getRuntime('main = comp.gt(true, false)');
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('throws for non-comparable types (maps)', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.gt({"a": 1}, {"b": 2})',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });
    });

    group('comp.lt', () {
      test('throws for mismatched types (string and number)', () {
        final RuntimeFacade runtime = getRuntime('main = comp.lt("hello", 1)');
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('throws for non-comparable types (lists)', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.lt([1, 2], [3, 4])',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('throws for non-comparable types (booleans)', () {
        final RuntimeFacade runtime = getRuntime('main = comp.lt(true, false)');
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });
    });

    group('comp.ge', () {
      test('throws for mismatched types (string and number)', () {
        final RuntimeFacade runtime = getRuntime('main = comp.ge("hello", 1)');
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('throws for non-comparable types (lists)', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.ge([1, 2], [3, 4])',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('throws for non-comparable types (booleans)', () {
        final RuntimeFacade runtime = getRuntime('main = comp.ge(true, false)');
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });
    });

    group('comp.le', () {
      test('throws for mismatched types (string and number)', () {
        final RuntimeFacade runtime = getRuntime('main = comp.le("hello", 1)');
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('throws for non-comparable types (lists)', () {
        final RuntimeFacade runtime = getRuntime(
          'main = comp.le([1, 2], [3, 4])',
        );
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });

      test('throws for non-comparable types (booleans)', () {
        final RuntimeFacade runtime = getRuntime('main = comp.le(true, false)');
        expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
      });
    });
  });
}
