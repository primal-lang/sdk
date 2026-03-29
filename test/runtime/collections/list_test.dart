@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('List', () {
    test('List constructor creates empty list', () {
      final Runtime runtime = getRuntime('main = []');
      checkResult(runtime, []);
    });

    test('List constructor creates single element list', () {
      final Runtime runtime = getRuntime('main = [1]');
      checkResult(runtime, [1]);
    });

    test('List constructor creates nested list', () {
      final Runtime runtime = getRuntime('main = [[1]]');
      checkResult(runtime, [
        [1],
      ]);
    });

    test('List constructor evaluates expression in elements', () {
      final Runtime runtime = getRuntime('main = [1 + 2]');
      checkResult(runtime, [3]);
    });

    test('List constructor evaluates expression in nested list', () {
      final Runtime runtime = getRuntime('main = [[1 + 2]]');
      checkResult(runtime, [
        [3],
      ]);
    });

    test('List constructor creates list with mixed types', () {
      final Runtime runtime = getRuntime('main = [1, true, "hello"]');
      checkResult(runtime, [1, true, '"hello"']);
    });

    test('List indexing returns element at given index', () {
      final Runtime runtime = getRuntime('main = [1, true, "hello"][1]');
      checkResult(runtime, true);
    });

    test('List indexing returns nested list at given index', () {
      final Runtime runtime = getRuntime(
        'main = [[1, 2, 3], [4, 5, 6], [7, 8, 9]][1]',
      );
      checkResult(runtime, [4, 5, 6]);
    });

    test('List indexing supports chained indexing into nested lists', () {
      final Runtime runtime = getRuntime(
        'main = ([[1, 2, 3], [4, 5, 6], [7, 8, 9]][1])[0]',
      );
      checkResult(runtime, 4);
    });

    test('List indexing works inside function body', () {
      final Runtime runtime = getRuntime('''
foo(values) = [values[0]]

main = foo([2])
''');
      checkResult(runtime, [2]);
    });

    test('List concatenation joins two lists with plus operator', () {
      final Runtime runtime = getRuntime('main = [1, 2] + [3, 4]');
      checkResult(runtime, [1, 2, 3, 4]);
    });

    test('List concatenation prepends element to list with plus operator', () {
      final Runtime runtime = getRuntime('main = 1 + [2, 3]');
      checkResult(runtime, [1, 2, 3]);
    });

    test('List concatenation appends element to list with plus operator', () {
      final Runtime runtime = getRuntime('main = [1, 2] + 3');
      checkResult(runtime, [1, 2, 3]);
    });

    test('list.insertStart prepends element to empty list', () {
      final Runtime runtime = getRuntime('main = list.insertStart([], 42)');
      checkResult(runtime, [42]);
    });

    test('list.insertStart prepends element to non-empty list', () {
      final Runtime runtime = getRuntime('main = list.insertStart([true], 1)');
      checkResult(runtime, [1, true]);
    });

    test('list.insertEnd appends element to empty list', () {
      final Runtime runtime = getRuntime('main = list.insertEnd([], 42)');
      checkResult(runtime, [42]);
    });

    test('list.insertEnd appends element to non-empty list', () {
      final Runtime runtime = getRuntime('main = list.insertEnd([true], 1)');
      checkResult(runtime, [true, 1]);
    });

    test('list.at returns element at given index', () {
      final Runtime runtime = getRuntime('main = list.at([0, 1, 2], 1)');
      checkResult(runtime, 1);
    });

    test('list.at returns evaluated expression at given index', () {
      final Runtime runtime = getRuntime('main = list.at([0, 2 + 3, 4], 1)');
      checkResult(runtime, 5);
    });

    test('list.set inserts element into empty list', () {
      final Runtime runtime = getRuntime('main = list.set([], 0, 1)');
      checkResult(runtime, [1]);
    });

    test('list.set inserts element at given index in non-empty list', () {
      final Runtime runtime = getRuntime(
        'main = list.set([1, 2, 3, 4, 5], 2, 42)',
      );
      checkResult(runtime, [1, 2, 42, 3, 4, 5]);
    });

    test('list.join concatenates elements with separator', () {
      final Runtime runtime = getRuntime(
        'main = list.join(["Hello", "world!"], ", ")',
      );
      checkResult(runtime, '"Hello, world!"');
    });

    test('list.join returns empty string for empty list', () {
      final Runtime runtime = getRuntime('main = list.join([], ",")');
      checkResult(runtime, '""');
    });

    test('list.length returns zero for empty list', () {
      final Runtime runtime = getRuntime('main = list.length([])');
      checkResult(runtime, 0);
    });

    test('list.length returns count of elements', () {
      final Runtime runtime = getRuntime('main = list.length([1, 2, 3])');
      checkResult(runtime, 3);
    });

    test('list.concat returns empty list when both lists are empty', () {
      final Runtime runtime = getRuntime('main = list.concat([], [])');
      checkResult(runtime, []);
    });

    test('list.concat appends empty list to non-empty list', () {
      final Runtime runtime = getRuntime('main = list.concat([1, 2], [])');
      checkResult(runtime, [1, 2]);
    });

    test('list.concat appends non-empty list to empty list', () {
      final Runtime runtime = getRuntime('main = list.concat([], [1, 2])');
      checkResult(runtime, [1, 2]);
    });

    test('list.concat joins two non-empty lists', () {
      final Runtime runtime = getRuntime('main = list.concat([1, 2], [3, 4])');
      checkResult(runtime, [1, 2, 3, 4]);
    });

    test('list.isEmpty returns true for empty list', () {
      final Runtime runtime = getRuntime('main = list.isEmpty([])');
      checkResult(runtime, true);
    });

    test('list.isEmpty returns false for non-empty list', () {
      final Runtime runtime = getRuntime('main = list.isEmpty([1, 2, 3])');
      checkResult(runtime, false);
    });

    test('list.isNotEmpty returns false for empty list', () {
      final Runtime runtime = getRuntime('main = list.isNotEmpty([])');
      checkResult(runtime, false);
    });

    test('list.isNotEmpty returns true for non-empty list', () {
      final Runtime runtime = getRuntime('main = list.isNotEmpty([1, 2, 3])');
      checkResult(runtime, true);
    });

    test('list.contains returns false for empty list', () {
      final Runtime runtime = getRuntime('main = list.contains([], 1)');
      checkResult(runtime, false);
    });

    test('list.contains returns true when element exists', () {
      final Runtime runtime = getRuntime('main = list.contains([1, 2, 3], 1)');
      checkResult(runtime, true);
    });

    test('list.contains returns true when evaluated expression matches', () {
      final Runtime runtime = getRuntime(
        'main = list.contains([1, 2 + 2, 3], 4)',
      );
      checkResult(runtime, true);
    });

    test('list.contains returns false when element does not exist', () {
      final Runtime runtime = getRuntime('main = list.contains([1, 2, 3], 4)');
      checkResult(runtime, false);
    });

    test('list.first', () {
      final Runtime runtime = getRuntime('main = list.first([1, 2, 3])');
      checkResult(runtime, 1);
    });

    test('list.last', () {
      final Runtime runtime = getRuntime('main = list.last([1, 2, 3])');
      checkResult(runtime, 3);
    });

    test('list.init', () {
      final Runtime runtime = getRuntime('main = list.init([1, 2, 3, 4, 5])');
      checkResult(runtime, [1, 2, 3, 4]);
    });

    test('list.rest returns empty list for empty input', () {
      final Runtime runtime = getRuntime('main = list.rest([])');
      checkResult(runtime, []);
    });

    test('list.rest returns all elements except the first', () {
      final Runtime runtime = getRuntime('main = list.rest([1, 2, 3, 4, 5])');
      checkResult(runtime, [2, 3, 4, 5]);
    });

    test('list.take returns empty list when taking zero elements', () {
      final Runtime runtime = getRuntime(
        'main = list.take([1, 2, 3, 4, 5], 0)',
      );
      checkResult(runtime, []);
    });

    test('list.take returns first n elements', () {
      final Runtime runtime = getRuntime(
        'main = list.take([1, 2, 3, 4, 5], 4)',
      );
      checkResult(runtime, [1, 2, 3, 4]);
    });

    test('list.drop returns full list when dropping zero elements', () {
      final Runtime runtime = getRuntime(
        'main = list.drop([1, 2, 3, 4, 5], 0)',
      );
      checkResult(runtime, [1, 2, 3, 4, 5]);
    });

    test('list.drop removes first n elements', () {
      final Runtime runtime = getRuntime(
        'main = list.drop([1, 2, 3, 4, 5], 2)',
      );
      checkResult(runtime, [3, 4, 5]);
    });

    test('list.remove returns unchanged list when element not found', () {
      final Runtime runtime = getRuntime(
        'main = list.remove([1, 2, 3, 4, 5], 0)',
      );
      checkResult(runtime, [1, 2, 3, 4, 5]);
    });

    test('list.remove removes single occurrence of element', () {
      final Runtime runtime = getRuntime(
        'main = list.remove([1, 2, 3, 4, 5], 2)',
      );
      checkResult(runtime, [1, 3, 4, 5]);
    });

    test('list.remove removes all occurrences of element', () {
      final Runtime runtime = getRuntime(
        'main = list.remove([1, 2, 2, 4, 5], 2)',
      );
      checkResult(runtime, [1, 4, 5]);
    });

    test('list.removeAt', () {
      final Runtime runtime = getRuntime(
        'main = list.removeAt([1, 2, 3, 4, 5], 2)',
      );
      checkResult(runtime, [1, 2, 4, 5]);
    });

    test('list.reverse', () {
      final Runtime runtime = getRuntime('main = list.reverse([1, 2, 3])');
      checkResult(runtime, [3, 2, 1]);
    });

    test('list.filled returns empty list when count is zero', () {
      final Runtime runtime = getRuntime('main = list.filled(0, 1)');
      checkResult(runtime, []);
    });

    test('list.filled returns list with repeated value', () {
      final Runtime runtime = getRuntime('main = list.filled(3, 1)');
      checkResult(runtime, [1, 1, 1]);
    });

    test('list.indexOf returns -1 when element not found', () {
      final Runtime runtime = getRuntime('main = list.indexOf([1, 2, 3], 4)');
      checkResult(runtime, -1);
    });

    test('list.indexOf returns index of existing element', () {
      final Runtime runtime = getRuntime('main = list.indexOf([1, 2, 3], 2)');
      checkResult(runtime, 1);
    });

    test('list.swap', () {
      final Runtime runtime = getRuntime(
        'main = list.swap([1, 2, 3, 4, 5], 1, 3)',
      );
      checkResult(runtime, [1, 4, 3, 2, 5]);
    });

    test('list.sublist', () {
      final Runtime runtime = getRuntime(
        'main = list.sublist([1, 2, 3, 4, 5], 1, 3)',
      );
      checkResult(runtime, [2, 3]);
    });

    test('list.map returns empty list for empty input', () {
      final Runtime runtime = getRuntime('main = list.map([], num.abs)');
      checkResult(runtime, []);
    });

    test('list.map applies function to each element', () {
      final Runtime runtime = getRuntime(
        'main = list.map([1, -2 - 6, 3 * -3, -4, num.negative(7)], num.abs)',
      );
      checkResult(runtime, [1, 8, 9, 4, 7]);
    });

    test('list.filter returns empty list for empty input', () {
      final Runtime runtime = getRuntime('main = list.filter([], num.isEven)');
      checkResult(runtime, []);
    });

    test('list.filter keeps only elements matching predicate', () {
      final Runtime runtime = getRuntime(
        'main = list.filter([-3, -2, -1, 0, 1, 2, 3], num.isEven)',
      );
      checkResult(runtime, [-2, 0, 2]);
    });

    test('list.filter returns empty list when no elements match', () {
      final Runtime runtime = getRuntime(
        'main = list.filter([-3, -2, -1, 1, 2, 3], num.isZero)',
      );
      checkResult(runtime, []);
    });

    test('list.reduce returns initial value for empty list', () {
      final Runtime runtime = getRuntime('main = list.reduce([], 0, num.add)');
      checkResult(runtime, 0);
    });

    test('list.reduce accumulates values with function', () {
      final Runtime runtime = getRuntime(
        'main = list.reduce([1, 2, 3, 4, 5], 10, num.add)',
      );
      checkResult(runtime, 25);
    });

    test('list.all returns true for empty list', () {
      final Runtime runtime = getRuntime('main = list.all([], num.isEven)');
      checkResult(runtime, true);
    });

    test('list.all returns false when some elements fail predicate', () {
      final Runtime runtime = getRuntime(
        'main = list.all([2, 4, 5], num.isEven)',
      );
      checkResult(runtime, false);
    });

    test('list.all returns true when all elements pass predicate', () {
      final Runtime runtime = getRuntime(
        'main = list.all([2, 4, 6], num.isEven)',
      );
      checkResult(runtime, true);
    });

    test('list.none returns true for empty list', () {
      final Runtime runtime = getRuntime('main = list.none([], num.isEven)');
      checkResult(runtime, true);
    });

    test('list.none returns false when some elements match predicate', () {
      final Runtime runtime = getRuntime(
        'main = list.none([1, 2, 3], num.isEven)',
      );
      checkResult(runtime, false);
    });

    test('list.none returns true when no elements match predicate', () {
      final Runtime runtime = getRuntime(
        'main = list.none([1, 3, 7], num.isEven)',
      );
      checkResult(runtime, true);
    });

    test('list.any returns false for empty list', () {
      final Runtime runtime = getRuntime('main = list.any([], num.isEven)');
      checkResult(runtime, false);
    });

    test('list.any returns false when no elements match predicate', () {
      final Runtime runtime = getRuntime(
        'main = list.any([1, 3, 5], num.isEven)',
      );
      checkResult(runtime, false);
    });

    test('list.any returns true when some elements match predicate', () {
      final Runtime runtime = getRuntime(
        'main = list.any([1, 2, 3], num.isEven)',
      );
      checkResult(runtime, true);
    });

    test('list.zip returns empty list for two empty lists', () {
      final Runtime runtime = getRuntime('main = list.zip([], [], num.add)');
      checkResult(runtime, []);
    });

    test('list.zip pads shorter second list with unzipped elements', () {
      final Runtime runtime = getRuntime(
        'main = list.zip([1, 3, 5], [2, 4], num.add)',
      );
      checkResult(runtime, [3, 7, 5]);
    });

    test('list.zip pads shorter first list with unzipped elements', () {
      final Runtime runtime = getRuntime(
        'main = list.zip([1, 3], [2, 4, 6], num.add)',
      );
      checkResult(runtime, [3, 7, 6]);
    });

    test('list.zip combines equal-length lists element-wise', () {
      final Runtime runtime = getRuntime(
        'main = list.zip([1, 3, 5], [2, 4, 6], num.add)',
      );
      checkResult(runtime, [3, 7, 11]);
    });

    test('list.zip evaluates expressions before combining', () {
      final Runtime runtime = getRuntime(
        'main = list.zip([1 + 1 + 1, 3, 5], [2, 4, 6], num.add)',
      );
      checkResult(runtime, [5, 7, 11]);
    });

    test('list.sort returns empty list for empty input', () {
      final Runtime runtime = getRuntime('main = list.sort([], num.compare)');
      checkResult(runtime, []);
    });

    test('list.sort sorts numbers in ascending order', () {
      final Runtime runtime = getRuntime(
        'main = list.sort([3, 1, 5, 2, 4], num.compare)',
      );
      checkResult(runtime, [1, 2, 3, 4, 5]);
    });

    test('list.sort sorts strings in alphabetical order', () {
      final Runtime runtime = getRuntime(
        'main = list.sort(["Peter", "Alice", "John", "Bob", "Daniel"], str.compare)',
      );
      checkResult(runtime, [
        '"Alice"',
        '"Bob"',
        '"Daniel"',
        '"John"',
        '"Peter"',
      ]);
    });
  });

  group('List Type Errors', () {
    test('list.length throws for wrong type', () {
      final Runtime runtime = getRuntime('main = list.length("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.first throws for wrong type', () {
      final Runtime runtime = getRuntime('main = list.first("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.last throws for wrong type', () {
      final Runtime runtime = getRuntime('main = list.last("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.isEmpty throws for wrong type', () {
      final Runtime runtime = getRuntime('main = list.isEmpty("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.reverse throws for wrong type', () {
      final Runtime runtime = getRuntime('main = list.reverse("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.sort throws for wrong type', () {
      final Runtime runtime = getRuntime(
        'main = list.sort("hello", num.compare)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.contains throws for wrong type', () {
      final Runtime runtime = getRuntime('main = list.contains("hello", 1)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.map throws for wrong type', () {
      final Runtime runtime = getRuntime('main = list.map("hello", num.abs)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });
  });

  group('List Error Cases', () {
    test('list.at throws RangeError for out-of-bounds index', () {
      final Runtime runtime = getRuntime('main = list.at([1, 2, 3], 10)');
      expect(runtime.executeMain, throwsA(isA<RangeError>()));
    });

    test('list.first throws StateError on empty list', () {
      final Runtime runtime = getRuntime('main = list.first([])');
      expect(runtime.executeMain, throwsA(isA<StateError>()));
    });

    test('list.last throws StateError on empty list', () {
      final Runtime runtime = getRuntime('main = list.last([])');
      expect(runtime.executeMain, throwsA(isA<StateError>()));
    });

    test(
      'list.reduce throws InvalidArgumentTypesError with non-function accumulator',
      () {
        final Runtime runtime = getRuntime(
          'main = list.reduce([1, 2, 3], 0, 42)',
        );
        expect(
          runtime.executeMain,
          throwsA(isA<InvalidArgumentTypesError>()),
        );
      },
    );
  });
}
