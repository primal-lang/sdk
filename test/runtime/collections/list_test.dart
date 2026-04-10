@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('List', () {
    test('List constructor creates empty list', () {
      final RuntimeFacade runtime = getRuntime('main = []');
      checkResult(runtime, []);
    });

    test('List constructor creates single element list', () {
      final RuntimeFacade runtime = getRuntime('main = [1]');
      checkResult(runtime, [1]);
    });

    test('List constructor creates nested list', () {
      final RuntimeFacade runtime = getRuntime('main = [[1]]');
      checkResult(runtime, [
        [1],
      ]);
    });

    test('List constructor evaluates expression in elements', () {
      final RuntimeFacade runtime = getRuntime('main = [1 + 2]');
      checkResult(runtime, [3]);
    });

    test('List constructor evaluates expression in nested list', () {
      final RuntimeFacade runtime = getRuntime('main = [[1 + 2]]');
      checkResult(runtime, [
        [3],
      ]);
    });

    test('List constructor creates list with mixed types', () {
      final RuntimeFacade runtime = getRuntime('main = [1, true, "hello"]');
      checkResult(runtime, [1, true, '"hello"']);
    });

    test('List indexing returns element at given index', () {
      final RuntimeFacade runtime = getRuntime('main = [1, true, "hello"][1]');
      checkResult(runtime, true);
    });

    test('List indexing returns nested list at given index', () {
      final RuntimeFacade runtime = getRuntime(
        'main = [[1, 2, 3], [4, 5, 6], [7, 8, 9]][1]',
      );
      checkResult(runtime, [4, 5, 6]);
    });

    test('List indexing supports chained indexing into nested lists', () {
      final RuntimeFacade runtime = getRuntime(
        'main = ([[1, 2, 3], [4, 5, 6], [7, 8, 9]][1])[0]',
      );
      checkResult(runtime, 4);
    });

    test('List indexing works inside function body', () {
      final RuntimeFacade runtime = getRuntime('''
foo(values) = [values[0]]

main = foo([2])
''');
      checkResult(runtime, [2]);
    });

    test('List concatenation joins two lists with plus operator', () {
      final RuntimeFacade runtime = getRuntime('main = [1, 2] + [3, 4]');
      checkResult(runtime, [1, 2, 3, 4]);
    });

    test('List concatenation prepends element to list with plus operator', () {
      final RuntimeFacade runtime = getRuntime('main = 1 + [2, 3]');
      checkResult(runtime, [1, 2, 3]);
    });

    test('List concatenation appends element to list with plus operator', () {
      final RuntimeFacade runtime = getRuntime('main = [1, 2] + 3');
      checkResult(runtime, [1, 2, 3]);
    });

    test('list.insertStart prepends element to empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.insertStart([], 42)',
      );
      checkResult(runtime, [42]);
    });

    test('list.insertStart prepends element to non-empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.insertStart([true], 1)',
      );
      checkResult(runtime, [1, true]);
    });

    test('list.insertEnd appends element to empty list', () {
      final RuntimeFacade runtime = getRuntime('main = list.insertEnd([], 42)');
      checkResult(runtime, [42]);
    });

    test('list.insertEnd appends element to non-empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.insertEnd([true], 1)',
      );
      checkResult(runtime, [true, 1]);
    });

    test('list.at returns element at given index', () {
      final RuntimeFacade runtime = getRuntime('main = list.at([0, 1, 2], 1)');
      checkResult(runtime, 1);
    });

    test('list.at returns reduced expression at given index', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.at([0, 2 + 3, 4], 1)',
      );
      checkResult(runtime, 5);
    });

    test('list.set replaces element at given index', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.set([1, 2, 3, 4, 5], 2, 42)',
      );
      checkResult(runtime, [1, 2, 42, 4, 5]);
    });

    test('list.set replaces first element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.set([1, 2, 3], 0, 99)',
      );
      checkResult(runtime, [99, 2, 3]);
    });

    test('list.set replaces last element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.set([1, 2, 3], 2, 99)',
      );
      checkResult(runtime, [1, 2, 99]);
    });

    test('list.set preserves list length', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.length(list.set([1, 2, 3, 4, 5], 2, 42))',
      );
      checkResult(runtime, 5);
    });

    test('list.set in single element list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.set([1], 0, 99)',
      );
      checkResult(runtime, [99]);
    });

    test('list.set with string value', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.set([1, 2, 3], 1, "hello")',
      );
      checkResult(runtime, [1, '"hello"', 3]);
    });

    test('list.set with boolean value', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.set([1, 2, 3], 1, true)',
      );
      checkResult(runtime, [1, true, 3]);
    });

    test('list.set with nested list value', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.set([1, 2, 3], 1, [4, 5])',
      );
      checkResult(runtime, [
        1,
        [4, 5],
        3,
      ]);
    });

    test('list.set evaluates value expression', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.set([1, 2, 3], 1, 10 + 5)',
      );
      checkResult(runtime, [1, 15, 3]);
    });

    test('list.join concatenates elements with separator', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.join(["Hello", "world!"], ", ")',
      );
      checkResult(runtime, '"Hello, world!"');
    });

    test('list.join returns empty string for empty list', () {
      final RuntimeFacade runtime = getRuntime('main = list.join([], ",")');
      checkResult(runtime, '""');
    });

    test('list.length returns zero for empty list', () {
      final RuntimeFacade runtime = getRuntime('main = list.length([])');
      checkResult(runtime, 0);
    });

    test('list.length returns count of elements', () {
      final RuntimeFacade runtime = getRuntime('main = list.length([1, 2, 3])');
      checkResult(runtime, 3);
    });

    test('list.concat returns empty list when both lists are empty', () {
      final RuntimeFacade runtime = getRuntime('main = list.concat([], [])');
      checkResult(runtime, []);
    });

    test('list.concat appends empty list to non-empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.concat([1, 2], [])',
      );
      checkResult(runtime, [1, 2]);
    });

    test('list.concat appends non-empty list to empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.concat([], [1, 2])',
      );
      checkResult(runtime, [1, 2]);
    });

    test('list.concat joins two non-empty lists', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.concat([1, 2], [3, 4])',
      );
      checkResult(runtime, [1, 2, 3, 4]);
    });

    test('list.isEmpty returns true for empty list', () {
      final RuntimeFacade runtime = getRuntime('main = list.isEmpty([])');
      checkResult(runtime, true);
    });

    test('list.isEmpty returns false for non-empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.isEmpty([1, 2, 3])',
      );
      checkResult(runtime, false);
    });

    test('list.isNotEmpty returns false for empty list', () {
      final RuntimeFacade runtime = getRuntime('main = list.isNotEmpty([])');
      checkResult(runtime, false);
    });

    test('list.isNotEmpty returns true for non-empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.isNotEmpty([1, 2, 3])',
      );
      checkResult(runtime, true);
    });

    test('list.contains returns false for empty list', () {
      final RuntimeFacade runtime = getRuntime('main = list.contains([], 1)');
      checkResult(runtime, false);
    });

    test('list.contains returns true when element exists', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.contains([1, 2, 3], 1)',
      );
      checkResult(runtime, true);
    });

    test('list.contains returns true when reduced expression matches', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.contains([1, 2 + 2, 3], 4)',
      );
      checkResult(runtime, true);
    });

    test('list.contains returns false when element does not exist', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.contains([1, 2, 3], 4)',
      );
      checkResult(runtime, false);
    });

    test('list.first', () {
      final RuntimeFacade runtime = getRuntime('main = list.first([1, 2, 3])');
      checkResult(runtime, 1);
    });

    test('list.last', () {
      final RuntimeFacade runtime = getRuntime('main = list.last([1, 2, 3])');
      checkResult(runtime, 3);
    });

    test('list.init', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.init([1, 2, 3, 4, 5])',
      );
      checkResult(runtime, [1, 2, 3, 4]);
    });

    test('list.rest returns empty list for empty input', () {
      final RuntimeFacade runtime = getRuntime('main = list.rest([])');
      checkResult(runtime, []);
    });

    test('list.rest returns all elements except the first', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.rest([1, 2, 3, 4, 5])',
      );
      checkResult(runtime, [2, 3, 4, 5]);
    });

    test('list.take returns empty list when taking zero elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.take([1, 2, 3, 4, 5], 0)',
      );
      checkResult(runtime, []);
    });

    test('list.take returns first n elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.take([1, 2, 3, 4, 5], 4)',
      );
      checkResult(runtime, [1, 2, 3, 4]);
    });

    test('list.drop returns full list when dropping zero elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.drop([1, 2, 3, 4, 5], 0)',
      );
      checkResult(runtime, [1, 2, 3, 4, 5]);
    });

    test('list.drop removes first n elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.drop([1, 2, 3, 4, 5], 2)',
      );
      checkResult(runtime, [3, 4, 5]);
    });

    test('list.remove returns unchanged list when element not found', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.remove([1, 2, 3, 4, 5], 0)',
      );
      checkResult(runtime, [1, 2, 3, 4, 5]);
    });

    test('list.remove removes single occurrence of element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.remove([1, 2, 3, 4, 5], 2)',
      );
      checkResult(runtime, [1, 3, 4, 5]);
    });

    test('list.remove removes all occurrences of element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.remove([1, 2, 2, 4, 5], 2)',
      );
      checkResult(runtime, [1, 4, 5]);
    });

    test('list.removeAt', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.removeAt([1, 2, 3, 4, 5], 2)',
      );
      checkResult(runtime, [1, 2, 4, 5]);
    });

    test('list.reverse', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.reverse([1, 2, 3])',
      );
      checkResult(runtime, [3, 2, 1]);
    });

    test('list.filled returns empty list when count is zero', () {
      final RuntimeFacade runtime = getRuntime('main = list.filled(0, 1)');
      checkResult(runtime, []);
    });

    test('list.filled returns list with repeated value', () {
      final RuntimeFacade runtime = getRuntime('main = list.filled(3, 1)');
      checkResult(runtime, [1, 1, 1]);
    });

    test('list.filled throws NegativeIndexError for negative count', () {
      final RuntimeFacade runtime = getRuntime('main = list.filled(-1, 1)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<NegativeIndexError>().having(
            (NegativeIndexError e) => e.toString(),
            'message',
            allOf(
              contains('-1'),
              contains('list.filled'),
            ),
          ),
        ),
      );
    });

    test('list.indexOf returns -1 when element not found', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.indexOf([1, 2, 3], 4)',
      );
      checkResult(runtime, -1);
    });

    test('list.indexOf returns index of existing element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.indexOf([1, 2, 3], 2)',
      );
      checkResult(runtime, 1);
    });

    test('list.swap', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.swap([1, 2, 3, 4, 5], 1, 3)',
      );
      checkResult(runtime, [1, 4, 3, 2, 5]);
    });

    test('list.sublist', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.sublist([1, 2, 3, 4, 5], 1, 3)',
      );
      checkResult(runtime, [2, 3]);
    });

    test('list.map returns empty list for empty input', () {
      final RuntimeFacade runtime = getRuntime('main = list.map([], num.abs)');
      checkResult(runtime, []);
    });

    test('list.map applies function to each element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.map([1, -2 - 6, 3 * -3, -4, num.negative(7)], num.abs)',
      );
      checkResult(runtime, [1, 8, 9, 4, 7]);
    });

    test('list.filter returns empty list for empty input', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.filter([], num.isEven)',
      );
      checkResult(runtime, []);
    });

    test('list.filter keeps only elements matching predicate', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.filter([-3, -2, -1, 0, 1, 2, 3], num.isEven)',
      );
      checkResult(runtime, [-2, 0, 2]);
    });

    test('list.filter returns empty list when no elements match', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.filter([-3, -2, -1, 1, 2, 3], num.isZero)',
      );
      checkResult(runtime, []);
    });

    test('list.filter throws when predicate returns non-boolean', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.filter([1, 2, 3], num.abs)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list.all throws when predicate returns non-boolean', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.all([1, 2, 3], num.abs)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('list.all'),
              contains('Boolean'),
              contains('Number'),
            ),
          ),
        ),
      );
    });

    test('list.any throws when predicate returns non-boolean', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.any([1, 2, 3], num.abs)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('list.any'),
              contains('Boolean'),
              contains('Number'),
            ),
          ),
        ),
      );
    });

    test('list.none throws when predicate returns non-boolean', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.none([1, 2, 3], num.abs)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('list.none'),
              contains('Boolean'),
              contains('Number'),
            ),
          ),
        ),
      );
    });

    test('list.reduce returns initial value for empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.reduce([], 0, num.add)',
      );
      checkResult(runtime, 0);
    });

    test('list.reduce accumulates values with function', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.reduce([1, 2, 3, 4, 5], 10, num.add)',
      );
      checkResult(runtime, 25);
    });

    test('list.all returns true for empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.all([], num.isEven)',
      );
      checkResult(runtime, true);
    });

    test('list.all returns false when some elements fail predicate', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.all([2, 4, 5], num.isEven)',
      );
      checkResult(runtime, false);
    });

    test('list.all returns true when all elements pass predicate', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.all([2, 4, 6], num.isEven)',
      );
      checkResult(runtime, true);
    });

    test('list.none returns true for empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.none([], num.isEven)',
      );
      checkResult(runtime, true);
    });

    test('list.none returns false when some elements match predicate', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.none([1, 2, 3], num.isEven)',
      );
      checkResult(runtime, false);
    });

    test('list.none returns true when no elements match predicate', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.none([1, 3, 7], num.isEven)',
      );
      checkResult(runtime, true);
    });

    test('list.any returns false for empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.any([], num.isEven)',
      );
      checkResult(runtime, false);
    });

    test('list.any returns false when no elements match predicate', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.any([1, 3, 5], num.isEven)',
      );
      checkResult(runtime, false);
    });

    test('list.any returns true when some elements match predicate', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.any([1, 2, 3], num.isEven)',
      );
      checkResult(runtime, true);
    });

    test('list.zip returns empty list for two empty lists', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.zip([], [], num.add)',
      );
      checkResult(runtime, []);
    });

    test('list.zip pads shorter second list with unzipped elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.zip([1, 3, 5], [2, 4], num.add)',
      );
      checkResult(runtime, [3, 7, 5]);
    });

    test('list.zip pads shorter first list with unzipped elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.zip([1, 3], [2, 4, 6], num.add)',
      );
      checkResult(runtime, [3, 7, 6]);
    });

    test('list.zip combines equal-length lists element-wise', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.zip([1, 3, 5], [2, 4, 6], num.add)',
      );
      checkResult(runtime, [3, 7, 11]);
    });

    test('list.zip evaluates expressions before combining', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.zip([1 + 1 + 1, 3, 5], [2, 4, 6], num.add)',
      );
      checkResult(runtime, [5, 7, 11]);
    });

    test('list.sort returns empty list for empty input', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.sort([], num.compare)',
      );
      checkResult(runtime, []);
    });

    test('list.sort sorts numbers in ascending order', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.sort([3, 1, 5, 2, 4], num.compare)',
      );
      checkResult(runtime, [1, 2, 3, 4, 5]);
    });

    test('list.sort sorts strings in alphabetical order', () {
      final RuntimeFacade runtime = getRuntime(
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

    test('list.sort handles comparator returning decimal values', () {
      final RuntimeFacade runtime = getRuntime('''
decimalCompare(a, b) = num.mul(num.sub(a, b), 1.5)
main = list.sort([3, 1, 5, 2, 4], decimalCompare)
''');
      checkResult(runtime, [1, 2, 3, 4, 5]);
    });

    test('list.init returns empty list for single element list', () {
      final RuntimeFacade runtime = getRuntime('main = list.init([1])');
      checkResult(runtime, []);
    });

    test('list.init returns empty list for empty list', () {
      final RuntimeFacade runtime = getRuntime('main = list.init([])');
      checkResult(runtime, []);
    });

    test('list.rest returns empty list for single element list', () {
      final RuntimeFacade runtime = getRuntime('main = list.rest([1])');
      checkResult(runtime, []);
    });

    test('list.reverse returns empty list for empty input', () {
      final RuntimeFacade runtime = getRuntime('main = list.reverse([])');
      checkResult(runtime, []);
    });

    test('list.reverse returns same list for single element', () {
      final RuntimeFacade runtime = getRuntime('main = list.reverse([42])');
      checkResult(runtime, [42]);
    });

    test('list.indexOf returns -1 for empty list', () {
      final RuntimeFacade runtime = getRuntime('main = list.indexOf([], 1)');
      checkResult(runtime, -1);
    });

    test('list.join returns element string for single element list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.join(["hello"], ", ")',
      );
      checkResult(runtime, '"hello"');
    });

    test('list.sublist returns empty list for equal start and end', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.sublist([1, 2, 3], 1, 1)',
      );
      checkResult(runtime, []);
    });

    test('list.sublist returns full list for zero to length', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.sublist([1, 2, 3], 0, 3)',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('list.swap with same index returns unchanged list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.swap([1, 2, 3], 1, 1)',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('list.remove returns empty list for empty input', () {
      final RuntimeFacade runtime = getRuntime('main = list.remove([], 1)');
      checkResult(runtime, []);
    });

    test('list.first returns element for single element list', () {
      final RuntimeFacade runtime = getRuntime('main = list.first([42])');
      checkResult(runtime, 42);
    });

    test('list.last returns element for single element list', () {
      final RuntimeFacade runtime = getRuntime('main = list.last([42])');
      checkResult(runtime, 42);
    });

    test('list.zip with first list empty returns second list elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.zip([], [1, 2, 3], num.add)',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('list.zip with second list empty returns first list elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.zip([1, 2, 3], [], num.add)',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('list.sort returns single element list unchanged', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.sort([42], num.compare)',
      );
      checkResult(runtime, [42]);
    });

    test('list.sort handles list with duplicate values', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.sort([3, 1, 2, 1, 3], num.compare)',
      );
      checkResult(runtime, [1, 1, 2, 3, 3]);
    });

    test('list.sort handles already sorted list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.sort([1, 2, 3, 4, 5], num.compare)',
      );
      checkResult(runtime, [1, 2, 3, 4, 5]);
    });

    test('list.sort handles reverse sorted list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.sort([5, 4, 3, 2, 1], num.compare)',
      );
      checkResult(runtime, [1, 2, 3, 4, 5]);
    });

    test('list.at on empty list throws IndexOutOfBoundsError', () {
      final RuntimeFacade runtime = getRuntime('main = list.at([], 0)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<IndexOutOfBoundsError>().having(
            (IndexOutOfBoundsError e) => e.toString(),
            'message',
            allOf(
              contains('0'),
              contains('length: 0'),
              contains('list.at'),
            ),
          ),
        ),
      );
    });

    test('list.set on empty list throws IndexOutOfBoundsError', () {
      final RuntimeFacade runtime = getRuntime('main = list.set([], 0, 42)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<IndexOutOfBoundsError>().having(
            (IndexOutOfBoundsError e) => e.toString(),
            'message',
            allOf(
              contains('0'),
              contains('length: 0'),
              contains('list.set'),
            ),
          ),
        ),
      );
    });

    test('list.sublist on empty list with zero indices returns empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.sublist([], 0, 0)',
      );
      checkResult(runtime, []);
    });

    test('list.sublist throws NegativeIndexError for negative end index', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.sublist([1, 2, 3], 0, -1)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<IndexOutOfBoundsError>().having(
            (IndexOutOfBoundsError e) => e.toString(),
            'message',
            allOf(
              contains('-1'),
              contains('list.sublist'),
            ),
          ),
        ),
      );
    });

    test('list.swap first and last elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.swap([1, 2, 3, 4, 5], 0, 4)',
      );
      checkResult(runtime, [5, 2, 3, 4, 1]);
    });

    test('list.swap in two element list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.swap([1, 2], 0, 1)',
      );
      checkResult(runtime, [2, 1]);
    });

    test('list.take on empty list returns empty list', () {
      final RuntimeFacade runtime = getRuntime('main = list.take([], 5)');
      checkResult(runtime, []);
    });

    test('list.drop on empty list returns empty list', () {
      final RuntimeFacade runtime = getRuntime('main = list.drop([], 5)');
      checkResult(runtime, []);
    });

    test('list.reduce with single element list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.reduce([5], 10, num.add)',
      );
      checkResult(runtime, 15);
    });

    test('list.zip with single element lists', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.zip([1], [2], num.add)',
      );
      checkResult(runtime, [3]);
    });

    test('list.indexOf returns first occurrence with duplicates', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.indexOf([1, 2, 2, 3], 2)',
      );
      checkResult(runtime, 1);
    });

    test('list.contains returns true for single element list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.contains([42], 42)',
      );
      checkResult(runtime, true);
    });

    test('list.contains returns false for single element list when not found',
        () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.contains([42], 99)',
      );
      checkResult(runtime, false);
    });

    test('list.length returns one for single element list', () {
      final RuntimeFacade runtime = getRuntime('main = list.length([42])');
      checkResult(runtime, 1);
    });

    test('list.join concatenates numbers with separator', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.join([1, 2, 3], "-")',
      );
      checkResult(runtime, '"1-2-3"');
    });

    test('list.join with empty separator', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.join(["a", "b", "c"], "")',
      );
      checkResult(runtime, '"abc"');
    });

    test('list.filled with boolean value', () {
      final RuntimeFacade runtime = getRuntime('main = list.filled(3, true)');
      checkResult(runtime, [true, true, true]);
    });

    test('list.filled with string value', () {
      final RuntimeFacade runtime = getRuntime('main = list.filled(2, "x")');
      checkResult(runtime, ['"x"', '"x"']);
    });

    test('list.filled with list value', () {
      final RuntimeFacade runtime = getRuntime('main = list.filled(2, [1, 2])');
      checkResult(runtime, [
        [1, 2],
        [1, 2],
      ]);
    });

    test('list.remove from single element list when element matches', () {
      final RuntimeFacade runtime = getRuntime('main = list.remove([42], 42)');
      checkResult(runtime, []);
    });

    test('list.remove from single element list when element does not match',
        () {
      final RuntimeFacade runtime = getRuntime('main = list.remove([42], 99)');
      checkResult(runtime, [42]);
    });

    test('list.isEmpty returns true for single element list is false', () {
      final RuntimeFacade runtime = getRuntime('main = list.isEmpty([1])');
      checkResult(runtime, false);
    });

    test('list.isNotEmpty returns true for single element list', () {
      final RuntimeFacade runtime = getRuntime('main = list.isNotEmpty([1])');
      checkResult(runtime, true);
    });

    test('list.init on two element list returns single element', () {
      final RuntimeFacade runtime = getRuntime('main = list.init([1, 2])');
      checkResult(runtime, [1]);
    });

    test('list.rest on two element list returns single element', () {
      final RuntimeFacade runtime = getRuntime('main = list.rest([1, 2])');
      checkResult(runtime, [2]);
    });

    test('list.concat with nested lists', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.concat([[1, 2]], [[3, 4]])',
      );
      checkResult(runtime, [
        [1, 2],
        [3, 4],
      ]);
    });

    test('list.map with identity function', () {
      final RuntimeFacade runtime = getRuntime('''
identity(x) = x
main = list.map([1, 2, 3], identity)
''');
      checkResult(runtime, [1, 2, 3]);
    });

    test('list.filter keeps all elements when all match', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.filter([2, 4, 6], num.isEven)',
      );
      checkResult(runtime, [2, 4, 6]);
    });

    test('list.all returns true for single element matching predicate', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.all([2], num.isEven)',
      );
      checkResult(runtime, true);
    });

    test('list.all returns false for single element not matching predicate',
        () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.all([3], num.isEven)',
      );
      checkResult(runtime, false);
    });

    test('list.any returns true for single element matching predicate', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.any([2], num.isEven)',
      );
      checkResult(runtime, true);
    });

    test('list.any returns false for single element not matching predicate',
        () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.any([3], num.isEven)',
      );
      checkResult(runtime, false);
    });

    test('list.none returns false for single element matching predicate', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.none([2], num.isEven)',
      );
      checkResult(runtime, false);
    });

    test('list.none returns true for single element not matching predicate',
        () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.none([3], num.isEven)',
      );
      checkResult(runtime, true);
    });

    test('list.reverse on two element list', () {
      final RuntimeFacade runtime = getRuntime('main = list.reverse([1, 2])');
      checkResult(runtime, [2, 1]);
    });

    test('list.insertStart with nested list element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.insertStart([1, 2], [0])',
      );
      checkResult(runtime, [
        [0],
        1,
        2,
      ]);
    });

    test('list.insertEnd with nested list element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.insertEnd([1, 2], [3])',
      );
      checkResult(runtime, [
        1,
        2,
        [3],
      ]);
    });

    test('list.removeAt in middle of list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.removeAt([1, 2, 3, 4, 5], 2)',
      );
      checkResult(runtime, [1, 2, 4, 5]);
    });

    test('list.take from single element list', () {
      final RuntimeFacade runtime = getRuntime('main = list.take([1], 1)');
      checkResult(runtime, [1]);
    });

    test('list.drop from single element list', () {
      final RuntimeFacade runtime = getRuntime('main = list.drop([1], 1)');
      checkResult(runtime, []);
    });

    test('list.sublist extracts single element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.sublist([1, 2, 3, 4, 5], 2, 3)',
      );
      checkResult(runtime, [3]);
    });
  });

  group('List Type Errors', () {
    test('list.length throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = list.length("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.first throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = list.first("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.last throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = list.last("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.isEmpty throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = list.isEmpty("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.reverse throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = list.reverse("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.sort throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.sort("hello", num.compare)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test(
      'list.sort throws InvalidArgumentTypesError for non-numeric comparator result',
      () {
        final RuntimeFacade runtime = getRuntime('''
badCompare(a, b) = true
main = list.sort([3, 1, 2], badCompare)
''');
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('list.sort'),
                contains('Number'),
                contains('Boolean'),
              ),
            ),
          ),
        );
      },
    );

    test('list.contains throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.contains("hello", 1)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.map throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.map("hello", num.abs)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('list.map'),
              contains('String'),
              contains('Function'),
            ),
          ),
        ),
      );
    });

    test('list.isNotEmpty throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.isNotEmpty("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.init throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = list.init("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.rest throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main = list.rest("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.concat throws for wrong first argument type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.concat("hello", [1, 2])',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.concat throws for wrong second argument type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.concat([1, 2], "hello")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.take throws for wrong list type', () {
      final RuntimeFacade runtime = getRuntime('main = list.take("hello", 2)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.drop throws for wrong list type', () {
      final RuntimeFacade runtime = getRuntime('main = list.drop("hello", 2)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.at throws for wrong list type', () {
      final RuntimeFacade runtime = getRuntime('main = list.at("hello", 1)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.set throws for wrong list type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.set("hello", 1, 42)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.sublist throws for wrong list type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.sublist("hello", 0, 2)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.swap throws for wrong list type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.swap("hello", 0, 1)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.remove throws for wrong list type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.remove("hello", "l")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.removeAt throws for wrong list type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.removeAt("hello", 1)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.indexOf throws for wrong list type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.indexOf("hello", "l")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.insertStart throws for wrong list type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.insertStart("hello", 1)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.insertEnd throws for wrong list type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.insertEnd("hello", 1)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.join throws for wrong list type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.join("hello", ",")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.join throws for wrong separator type', () {
      final RuntimeFacade runtime = getRuntime('main = list.join([1, 2], 42)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.filter throws for wrong list type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.filter("hello", num.isEven)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.filter throws for wrong function type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.filter([1, 2, 3], 42)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.reduce throws for wrong list type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.reduce("hello", 0, num.add)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.all throws for wrong list type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.all("hello", num.isEven)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.all throws for wrong function type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.all([1, 2, 3], 42)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.any throws for wrong list type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.any("hello", num.isEven)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.any throws for wrong function type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.any([1, 2, 3], 42)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.none throws for wrong list type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.none("hello", num.isEven)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.none throws for wrong function type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.none([1, 2, 3], 42)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.zip throws for wrong first list type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.zip("hello", [1, 2], num.add)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.zip throws for wrong second list type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.zip([1, 2], "hello", num.add)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.zip throws for wrong function type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.zip([1, 2], [3, 4], 42)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.filled throws for wrong count type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.filled("hello", 42)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.map throws for wrong function type', () {
      final RuntimeFacade runtime = getRuntime('main = list.map([1, 2, 3], 42)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.sort throws for wrong function type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.sort([1, 2, 3], "compare")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.at throws for wrong index type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.at([1, 2, 3], "one")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.set throws for wrong index type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.set([1, 2, 3], "one", 42)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.sublist throws for wrong start index type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.sublist([1, 2, 3], "one", 2)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.sublist throws for wrong end index type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.sublist([1, 2, 3], 0, "two")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.swap throws for wrong first index type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.swap([1, 2, 3], "one", 2)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.swap throws for wrong second index type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.swap([1, 2, 3], 0, "two")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.take throws for wrong count type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.take([1, 2, 3], "two")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.drop throws for wrong count type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.drop([1, 2, 3], "two")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.removeAt throws for wrong index type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.removeAt([1, 2, 3], "one")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list.filled throws for non-integer count', () {
      final RuntimeFacade runtime = getRuntime('main = list.filled(2.5, 1)');
      checkResult(runtime, [1, 1]);
    });

    test('list.reduce throws for wrong initial value type when function expects specific type', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.reduce([1, 2, 3], "zero", num.add)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });
  });

  group('List Error Cases', () {
    test('list.at throws IndexOutOfBoundsError for out-of-bounds index', () {
      final RuntimeFacade runtime = getRuntime('main = list.at([1, 2, 3], 10)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<IndexOutOfBoundsError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('10'),
              contains('length: 3'),
              contains('list.at'),
            ),
          ),
        ),
      );
    });

    test('list.at throws NegativeIndexError for negative index', () {
      final RuntimeFacade runtime = getRuntime('main = list.at([1, 2, 3], -1)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<NegativeIndexError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('-1'),
              contains('list.at'),
            ),
          ),
        ),
      );
    });

    test('list.first throws EmptyCollectionError for empty list', () {
      final RuntimeFacade runtime = getRuntime('main = list.first([])');
      expect(
        runtime.executeMain,
        throwsA(
          isA<EmptyCollectionError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('empty'),
              contains('list'),
              contains('list.first'),
            ),
          ),
        ),
      );
    });

    test('list.last throws EmptyCollectionError for empty list', () {
      final RuntimeFacade runtime = getRuntime('main = list.last([])');
      expect(
        runtime.executeMain,
        throwsA(
          isA<EmptyCollectionError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('empty'),
              contains('list'),
              contains('list.last'),
            ),
          ),
        ),
      );
    });

    test(
      'list.reduce throws InvalidArgumentTypesError with non-function accumulator',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main = list.reduce([1, 2, 3], 0, 42)',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('list.reduce'),
                contains('List'),
                contains('Number'),
              ),
            ),
          ),
        );
      },
    );

    test('list.drop clamps to length for out-of-bounds count', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.drop([1, 2, 3], 10)',
      );
      checkResult(runtime, []);
    });

    test('list.drop throws NegativeIndexError for negative count', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.drop([1, 2, 3], -1)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<NegativeIndexError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('-1'),
              contains('list.drop'),
            ),
          ),
        ),
      );
    });

    test('list.take clamps to length for out-of-bounds count', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.take([1, 2, 3], 10)',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('list.take throws NegativeIndexError for negative count', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.take([1, 2, 3], -1)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<NegativeIndexError>().having(
            (NegativeIndexError e) => e.toString(),
            'message',
            allOf(
              contains('-1'),
              contains('list.take'),
            ),
          ),
        ),
      );
    });

    test('list.set throws NegativeIndexError for negative index', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.set([1, 2, 3], -1, 42)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<NegativeIndexError>().having(
            (NegativeIndexError e) => e.toString(),
            'message',
            allOf(
              contains('-1'),
              contains('list.set'),
            ),
          ),
        ),
      );
    });

    test('list.set throws IndexOutOfBoundsError for out-of-bounds index', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.set([1, 2, 3], 10, 42)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<IndexOutOfBoundsError>().having(
            (IndexOutOfBoundsError e) => e.toString(),
            'message',
            allOf(
              contains('10'),
              contains('length: 3'),
              contains('list.set'),
            ),
          ),
        ),
      );
    });

    test('list.sublist throws NegativeIndexError for negative start', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.sublist([1, 2, 3], -1, 2)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<NegativeIndexError>().having(
            (NegativeIndexError e) => e.toString(),
            'message',
            allOf(
              contains('-1'),
              contains('list.sublist'),
            ),
          ),
        ),
      );
    });

    test(
      'list.sublist throws IndexOutOfBoundsError when start exceeds length',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main = list.sublist([1, 2, 3], 10, 12)',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<IndexOutOfBoundsError>().having(
              (IndexOutOfBoundsError e) => e.toString(),
              'message',
              allOf(
                contains('10'),
                contains('length: 3'),
                contains('list.sublist'),
              ),
            ),
          ),
        );
      },
    );

    test(
      'list.sublist throws IndexOutOfBoundsError when end is less than start',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main = list.sublist([1, 2, 3], 2, 1)',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<IndexOutOfBoundsError>().having(
              (IndexOutOfBoundsError e) => e.toString(),
              'message',
              allOf(
                contains('1'),
                contains('list.sublist'),
              ),
            ),
          ),
        );
      },
    );

    test(
      'list.sublist throws IndexOutOfBoundsError when end exceeds length',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main = list.sublist([1, 2, 3], 0, 10)',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<IndexOutOfBoundsError>().having(
              (IndexOutOfBoundsError e) => e.toString(),
              'message',
              allOf(
                contains('10'),
                contains('length: 3'),
                contains('list.sublist'),
              ),
            ),
          ),
        );
      },
    );

    test('list.swap throws NegativeIndexError for negative first index', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.swap([1, 2, 3], -1, 2)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<NegativeIndexError>().having(
            (NegativeIndexError e) => e.toString(),
            'message',
            allOf(
              contains('-1'),
              contains('list.swap'),
            ),
          ),
        ),
      );
    });

    test('list.swap throws NegativeIndexError for negative second index', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.swap([1, 2, 3], 0, -1)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<NegativeIndexError>().having(
            (NegativeIndexError e) => e.toString(),
            'message',
            allOf(
              contains('-1'),
              contains('list.swap'),
            ),
          ),
        ),
      );
    });

    test(
      'list.swap throws IndexOutOfBoundsError for out-of-bounds first index',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main = list.swap([1, 2, 3], 10, 1)',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<IndexOutOfBoundsError>().having(
              (IndexOutOfBoundsError e) => e.toString(),
              'message',
              allOf(
                contains('10'),
                contains('length: 3'),
                contains('list.swap'),
              ),
            ),
          ),
        );
      },
    );

    test(
      'list.swap throws IndexOutOfBoundsError for out-of-bounds second index',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main = list.swap([1, 2, 3], 0, 10)',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<IndexOutOfBoundsError>().having(
              (IndexOutOfBoundsError e) => e.toString(),
              'message',
              allOf(
                contains('10'),
                contains('length: 3'),
                contains('list.swap'),
              ),
            ),
          ),
        );
      },
    );

    test('list.removeAt throws NegativeIndexError for negative index', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.removeAt([1, 2, 3], -1)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<NegativeIndexError>().having(
            (NegativeIndexError e) => e.toString(),
            'message',
            allOf(
              contains('-1'),
              contains('list.removeAt'),
            ),
          ),
        ),
      );
    });

    test(
      'list.removeAt throws IndexOutOfBoundsError for out-of-bounds index',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main = list.removeAt([1, 2, 3], 10)',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<IndexOutOfBoundsError>().having(
              (IndexOutOfBoundsError e) => e.toString(),
              'message',
              allOf(
                contains('10'),
                contains('length: 3'),
                contains('list.removeAt'),
              ),
            ),
          ),
        );
      },
    );

    test('list.removeAt removes first element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.removeAt([1, 2, 3], 0)',
      );
      checkResult(runtime, [2, 3]);
    });

    test('list.removeAt removes last element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.removeAt([1, 2, 3], 2)',
      );
      checkResult(runtime, [1, 2]);
    });

    test('list.removeAt on single element list returns empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.removeAt([42], 0)',
      );
      checkResult(runtime, []);
    });

    test('list.swap throws IndexOutOfBoundsError on empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.swap([], 0, 0)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<IndexOutOfBoundsError>().having(
            (IndexOutOfBoundsError e) => e.toString(),
            'message',
            allOf(
              contains('0'),
              contains('length: 0'),
              contains('list.swap'),
            ),
          ),
        ),
      );
    });

    test('list.removeAt throws IndexOutOfBoundsError on empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.removeAt([], 0)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<IndexOutOfBoundsError>().having(
            (IndexOutOfBoundsError e) => e.toString(),
            'message',
            allOf(
              contains('0'),
              contains('length: 0'),
              contains('list.removeAt'),
            ),
          ),
        ),
      );
    });

    test('list.sublist throws IndexOutOfBoundsError on empty list with non-zero indices', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.sublist([], 0, 1)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<IndexOutOfBoundsError>().having(
            (IndexOutOfBoundsError e) => e.toString(),
            'message',
            allOf(
              contains('1'),
              contains('length: 0'),
              contains('list.sublist'),
            ),
          ),
        ),
      );
    });
  });
}
