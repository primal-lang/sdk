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
      final RuntimeFacade runtime = getRuntime('main() = []');
      checkResult(runtime, []);
    });

    test('List constructor creates single element list', () {
      final RuntimeFacade runtime = getRuntime('main() = [1]');
      checkResult(runtime, [1]);
    });

    test('List constructor creates nested list', () {
      final RuntimeFacade runtime = getRuntime('main() = [[1]]');
      checkResult(runtime, [
        [1],
      ]);
    });

    test('List constructor evaluates expression in elements', () {
      final RuntimeFacade runtime = getRuntime('main() = [1 + 2]');
      checkResult(runtime, [3]);
    });

    test('List constructor evaluates expression in nested list', () {
      final RuntimeFacade runtime = getRuntime('main() = [[1 + 2]]');
      checkResult(runtime, [
        [3],
      ]);
    });

    test('List constructor creates list with mixed types', () {
      final RuntimeFacade runtime = getRuntime('main() = [1, true, "hello"]');
      checkResult(runtime, [1, true, '"hello"']);
    });

    test('List indexing returns element at given index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = [1, true, "hello"][1]',
      );
      checkResult(runtime, true);
    });

    test('List indexing returns nested list at given index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = [[1, 2, 3], [4, 5, 6], [7, 8, 9]][1]',
      );
      checkResult(runtime, [4, 5, 6]);
    });

    test('List indexing supports chained indexing into nested lists', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = ([[1, 2, 3], [4, 5, 6], [7, 8, 9]][1])[0]',
      );
      checkResult(runtime, 4);
    });

    test('List indexing works inside function body', () {
      final RuntimeFacade runtime = getRuntime('''
foo(values) = [values[0]]

main() = foo([2])
''');
      checkResult(runtime, [2]);
    });

    test('List concatenation joins two lists with plus operator', () {
      final RuntimeFacade runtime = getRuntime('main() = [1, 2] + [3, 4]');
      checkResult(runtime, [1, 2, 3, 4]);
    });

    test('List concatenation prepends element to list with plus operator', () {
      final RuntimeFacade runtime = getRuntime('main() = 1 + [2, 3]');
      checkResult(runtime, [1, 2, 3]);
    });

    test('List concatenation appends element to list with plus operator', () {
      final RuntimeFacade runtime = getRuntime('main() = [1, 2] + 3');
      checkResult(runtime, [1, 2, 3]);
    });

    test('list_insertStart prepends element to empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_insertStart([], 42)',
      );
      checkResult(runtime, [42]);
    });

    test('list_insertStart prepends element to non-empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_insertStart([true], 1)',
      );
      checkResult(runtime, [1, true]);
    });

    test('list_insertEnd appends element to empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_insertEnd([], 42)',
      );
      checkResult(runtime, [42]);
    });

    test('list_insertEnd appends element to non-empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_insertEnd([true], 1)',
      );
      checkResult(runtime, [true, 1]);
    });

    test('list_at returns element at given index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_at([0, 1, 2], 1)',
      );
      checkResult(runtime, 1);
    });

    test('list_at returns reduced expression at given index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_at([0, 2 + 3, 4], 1)',
      );
      checkResult(runtime, 5);
    });

    test('list_set replaces element at given index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_set([1, 2, 3, 4, 5], 2, 42)',
      );
      checkResult(runtime, [1, 2, 42, 4, 5]);
    });

    test('list_set replaces first element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_set([1, 2, 3], 0, 99)',
      );
      checkResult(runtime, [99, 2, 3]);
    });

    test('list_set replaces last element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_set([1, 2, 3], 2, 99)',
      );
      checkResult(runtime, [1, 2, 99]);
    });

    test('list_set preserves list length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_length(list_set([1, 2, 3, 4, 5], 2, 42))',
      );
      checkResult(runtime, 5);
    });

    test('list_set in single element list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_set([1], 0, 99)',
      );
      checkResult(runtime, [99]);
    });

    test('list_set with string value', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_set([1, 2, 3], 1, "hello")',
      );
      checkResult(runtime, [1, '"hello"', 3]);
    });

    test('list_set with boolean value', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_set([1, 2, 3], 1, true)',
      );
      checkResult(runtime, [1, true, 3]);
    });

    test('list_set with nested list value', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_set([1, 2, 3], 1, [4, 5])',
      );
      checkResult(runtime, [
        1,
        [4, 5],
        3,
      ]);
    });

    test('list_set evaluates value expression', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_set([1, 2, 3], 1, 10 + 5)',
      );
      checkResult(runtime, [1, 15, 3]);
    });

    test('list_join concatenates elements with separator', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_join(["Hello", "world!"], ", ")',
      );
      checkResult(runtime, '"Hello, world!"');
    });

    test('list_join returns empty string for empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = list_join([], ",")');
      checkResult(runtime, '""');
    });

    test('list_length returns zero for empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = list_length([])');
      checkResult(runtime, 0);
    });

    test('list_length returns count of elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_length([1, 2, 3])',
      );
      checkResult(runtime, 3);
    });

    test('list_concat returns empty list when both lists are empty', () {
      final RuntimeFacade runtime = getRuntime('main() = list_concat([], [])');
      checkResult(runtime, []);
    });

    test('list_concat appends empty list to non-empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_concat([1, 2], [])',
      );
      checkResult(runtime, [1, 2]);
    });

    test('list_concat appends non-empty list to empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_concat([], [1, 2])',
      );
      checkResult(runtime, [1, 2]);
    });

    test('list_concat joins two non-empty lists', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_concat([1, 2], [3, 4])',
      );
      checkResult(runtime, [1, 2, 3, 4]);
    });

    test('list_isEmpty returns true for empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = list_isEmpty([])');
      checkResult(runtime, true);
    });

    test('list_isEmpty returns false for non-empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_isEmpty([1, 2, 3])',
      );
      checkResult(runtime, false);
    });

    test('list_isNotEmpty returns false for empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = list_isNotEmpty([])');
      checkResult(runtime, false);
    });

    test('list_isNotEmpty returns true for non-empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_isNotEmpty([1, 2, 3])',
      );
      checkResult(runtime, true);
    });

    test('list_contains returns false for empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = list_contains([], 1)');
      checkResult(runtime, false);
    });

    test('list_contains returns true when element exists', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_contains([1, 2, 3], 1)',
      );
      checkResult(runtime, true);
    });

    test('list_contains returns true when reduced expression matches', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_contains([1, 2 + 2, 3], 4)',
      );
      checkResult(runtime, true);
    });

    test('list_contains returns false when element does not exist', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_contains([1, 2, 3], 4)',
      );
      checkResult(runtime, false);
    });

    test('list_first', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_first([1, 2, 3])',
      );
      checkResult(runtime, 1);
    });

    test('list_last', () {
      final RuntimeFacade runtime = getRuntime('main() = list_last([1, 2, 3])');
      checkResult(runtime, 3);
    });

    test('list_init', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_init([1, 2, 3, 4, 5])',
      );
      checkResult(runtime, [1, 2, 3, 4]);
    });

    test('list_rest returns empty list for empty input', () {
      final RuntimeFacade runtime = getRuntime('main() = list_rest([])');
      checkResult(runtime, []);
    });

    test('list_rest returns all elements except the first', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_rest([1, 2, 3, 4, 5])',
      );
      checkResult(runtime, [2, 3, 4, 5]);
    });

    test('list_take returns empty list when taking zero elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_take([1, 2, 3, 4, 5], 0)',
      );
      checkResult(runtime, []);
    });

    test('list_take returns first n elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_take([1, 2, 3, 4, 5], 4)',
      );
      checkResult(runtime, [1, 2, 3, 4]);
    });

    test('list_drop returns full list when dropping zero elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_drop([1, 2, 3, 4, 5], 0)',
      );
      checkResult(runtime, [1, 2, 3, 4, 5]);
    });

    test('list_drop removes first n elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_drop([1, 2, 3, 4, 5], 2)',
      );
      checkResult(runtime, [3, 4, 5]);
    });

    test('list_remove returns unchanged list when element not found', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_remove([1, 2, 3, 4, 5], 0)',
      );
      checkResult(runtime, [1, 2, 3, 4, 5]);
    });

    test('list_remove removes single occurrence of element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_remove([1, 2, 3, 4, 5], 2)',
      );
      checkResult(runtime, [1, 3, 4, 5]);
    });

    test('list_remove removes all occurrences of element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_remove([1, 2, 2, 4, 5], 2)',
      );
      checkResult(runtime, [1, 4, 5]);
    });

    test('list_removeAt', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_removeAt([1, 2, 3, 4, 5], 2)',
      );
      checkResult(runtime, [1, 2, 4, 5]);
    });

    test('list_reverse', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_reverse([1, 2, 3])',
      );
      checkResult(runtime, [3, 2, 1]);
    });

    test('list_filled returns empty list when count is zero', () {
      final RuntimeFacade runtime = getRuntime('main() = list_filled(0, 1)');
      checkResult(runtime, []);
    });

    test('list_filled returns list with repeated value', () {
      final RuntimeFacade runtime = getRuntime('main() = list_filled(3, 1)');
      checkResult(runtime, [1, 1, 1]);
    });

    test('list_filled throws NegativeIndexError for negative count', () {
      final RuntimeFacade runtime = getRuntime('main() = list_filled(-1, 1)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<NegativeIndexError>().having(
            (NegativeIndexError e) => e.toString(),
            'message',
            allOf(
              contains('-1'),
              contains('list_filled'),
            ),
          ),
        ),
      );
    });

    test('list_indexOf returns -1 when element not found', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_indexOf([1, 2, 3], 4)',
      );
      checkResult(runtime, -1);
    });

    test('list_indexOf returns index of existing element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_indexOf([1, 2, 3], 2)',
      );
      checkResult(runtime, 1);
    });

    test('list_swap', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_swap([1, 2, 3, 4, 5], 1, 3)',
      );
      checkResult(runtime, [1, 4, 3, 2, 5]);
    });

    test('list_sublist', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sublist([1, 2, 3, 4, 5], 1, 3)',
      );
      checkResult(runtime, [2, 3]);
    });

    test('list_map returns empty list for empty input', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map([], num_abs)',
      );
      checkResult(runtime, []);
    });

    test('list_map applies function to each element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map([1, -2 - 6, 3 * -3, -4, num_negative(7)], num_abs)',
      );
      checkResult(runtime, [1, 8, 9, 4, 7]);
    });

    test('list_filter returns empty list for empty input', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_filter([], num_isEven)',
      );
      checkResult(runtime, []);
    });

    test('list_filter keeps only elements matching predicate', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_filter([-3, -2, -1, 0, 1, 2, 3], num_isEven)',
      );
      checkResult(runtime, [-2, 0, 2]);
    });

    test('list_filter returns empty list when no elements match', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_filter([-3, -2, -1, 1, 2, 3], num_isZero)',
      );
      checkResult(runtime, []);
    });

    test('list_filter throws when predicate returns non-boolean', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_filter([1, 2, 3], num_abs)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list_all throws when predicate returns non-boolean', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_all([1, 2, 3], num_abs)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('list_all'),
              contains('Boolean'),
              contains('Number'),
            ),
          ),
        ),
      );
    });

    test('list_any throws when predicate returns non-boolean', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_any([1, 2, 3], num_abs)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('list_any'),
              contains('Boolean'),
              contains('Number'),
            ),
          ),
        ),
      );
    });

    test('list_none throws when predicate returns non-boolean', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_none([1, 2, 3], num_abs)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('list_none'),
              contains('Boolean'),
              contains('Number'),
            ),
          ),
        ),
      );
    });

    test('list_reduce returns initial value for empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_reduce([], 0, num_add)',
      );
      checkResult(runtime, 0);
    });

    test('list_reduce accumulates values with function', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_reduce([1, 2, 3, 4, 5], 10, num_add)',
      );
      checkResult(runtime, 25);
    });

    test('list_all returns true for empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_all([], num_isEven)',
      );
      checkResult(runtime, true);
    });

    test('list_all returns false when some elements fail predicate', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_all([2, 4, 5], num_isEven)',
      );
      checkResult(runtime, false);
    });

    test('list_all returns true when all elements pass predicate', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_all([2, 4, 6], num_isEven)',
      );
      checkResult(runtime, true);
    });

    test('list_none returns true for empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_none([], num_isEven)',
      );
      checkResult(runtime, true);
    });

    test('list_none returns false when some elements match predicate', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_none([1, 2, 3], num_isEven)',
      );
      checkResult(runtime, false);
    });

    test('list_none returns true when no elements match predicate', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_none([1, 3, 7], num_isEven)',
      );
      checkResult(runtime, true);
    });

    test('list_any returns false for empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_any([], num_isEven)',
      );
      checkResult(runtime, false);
    });

    test('list_any returns false when no elements match predicate', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_any([1, 3, 5], num_isEven)',
      );
      checkResult(runtime, false);
    });

    test('list_any returns true when some elements match predicate', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_any([1, 2, 3], num_isEven)',
      );
      checkResult(runtime, true);
    });

    test('list_zip returns empty list for two empty lists', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_zip([], [], num_add)',
      );
      checkResult(runtime, []);
    });

    test('list_zip pads shorter second list with unzipped elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_zip([1, 3, 5], [2, 4], num_add)',
      );
      checkResult(runtime, [3, 7, 5]);
    });

    test('list_zip pads shorter first list with unzipped elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_zip([1, 3], [2, 4, 6], num_add)',
      );
      checkResult(runtime, [3, 7, 6]);
    });

    test('list_zip combines equal-length lists element-wise', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_zip([1, 3, 5], [2, 4, 6], num_add)',
      );
      checkResult(runtime, [3, 7, 11]);
    });

    test('list_zip evaluates expressions before combining', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_zip([1 + 1 + 1, 3, 5], [2, 4, 6], num_add)',
      );
      checkResult(runtime, [5, 7, 11]);
    });

    test('list_sort returns empty list for empty input', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sort([], num_compare)',
      );
      checkResult(runtime, []);
    });

    test('list_sort sorts numbers in ascending order', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sort([3, 1, 5, 2, 4], num_compare)',
      );
      checkResult(runtime, [1, 2, 3, 4, 5]);
    });

    test('list_sort sorts strings in alphabetical order', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sort(["Peter", "Alice", "John", "Bob", "Daniel"], str_compare)',
      );
      checkResult(runtime, [
        '"Alice"',
        '"Bob"',
        '"Daniel"',
        '"John"',
        '"Peter"',
      ]);
    });

    test('list_sort handles comparator returning decimal values', () {
      final RuntimeFacade runtime = getRuntime('''
decimalCompare(a, b) = num_mul(num_sub(a, b), 1.5)
main() = list_sort([3, 1, 5, 2, 4], decimalCompare)
''');
      checkResult(runtime, [1, 2, 3, 4, 5]);
    });

    test('list_init returns empty list for single element list', () {
      final RuntimeFacade runtime = getRuntime('main() = list_init([1])');
      checkResult(runtime, []);
    });

    test('list_init returns empty list for empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = list_init([])');
      checkResult(runtime, []);
    });

    test('list_rest returns empty list for single element list', () {
      final RuntimeFacade runtime = getRuntime('main() = list_rest([1])');
      checkResult(runtime, []);
    });

    test('list_reverse returns empty list for empty input', () {
      final RuntimeFacade runtime = getRuntime('main() = list_reverse([])');
      checkResult(runtime, []);
    });

    test('list_reverse returns same list for single element', () {
      final RuntimeFacade runtime = getRuntime('main() = list_reverse([42])');
      checkResult(runtime, [42]);
    });

    test('list_indexOf returns -1 for empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = list_indexOf([], 1)');
      checkResult(runtime, -1);
    });

    test('list_join returns element string for single element list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_join(["hello"], ", ")',
      );
      checkResult(runtime, '"hello"');
    });

    test('list_sublist returns empty list for equal start and end', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sublist([1, 2, 3], 1, 1)',
      );
      checkResult(runtime, []);
    });

    test('list_sublist returns full list for zero to length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sublist([1, 2, 3], 0, 3)',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('list_swap with same index returns unchanged list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_swap([1, 2, 3], 1, 1)',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('list_remove returns empty list for empty input', () {
      final RuntimeFacade runtime = getRuntime('main() = list_remove([], 1)');
      checkResult(runtime, []);
    });

    test('list_first returns element for single element list', () {
      final RuntimeFacade runtime = getRuntime('main() = list_first([42])');
      checkResult(runtime, 42);
    });

    test('list_last returns element for single element list', () {
      final RuntimeFacade runtime = getRuntime('main() = list_last([42])');
      checkResult(runtime, 42);
    });

    test('list_zip with first list empty returns second list elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_zip([], [1, 2, 3], num_add)',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('list_zip with second list empty returns first list elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_zip([1, 2, 3], [], num_add)',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('list_sort returns single element list unchanged', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sort([42], num_compare)',
      );
      checkResult(runtime, [42]);
    });

    test('list_sort handles list with duplicate values', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sort([3, 1, 2, 1, 3], num_compare)',
      );
      checkResult(runtime, [1, 1, 2, 3, 3]);
    });

    test('list_sort handles already sorted list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sort([1, 2, 3, 4, 5], num_compare)',
      );
      checkResult(runtime, [1, 2, 3, 4, 5]);
    });

    test('list_sort handles reverse sorted list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sort([5, 4, 3, 2, 1], num_compare)',
      );
      checkResult(runtime, [1, 2, 3, 4, 5]);
    });

    test('list_at on empty list throws IndexOutOfBoundsError', () {
      final RuntimeFacade runtime = getRuntime('main() = list_at([], 0)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<IndexOutOfBoundsError>().having(
            (IndexOutOfBoundsError e) => e.toString(),
            'message',
            allOf(
              contains('0'),
              contains('length: 0'),
              contains('list_at'),
            ),
          ),
        ),
      );
    });

    test('list_set on empty list throws IndexOutOfBoundsError', () {
      final RuntimeFacade runtime = getRuntime('main() = list_set([], 0, 42)');
      expect(
        runtime.executeMain,
        throwsA(
          isA<IndexOutOfBoundsError>().having(
            (IndexOutOfBoundsError e) => e.toString(),
            'message',
            allOf(
              contains('0'),
              contains('length: 0'),
              contains('list_set'),
            ),
          ),
        ),
      );
    });

    test('list_sublist on empty list with zero indices returns empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sublist([], 0, 0)',
      );
      checkResult(runtime, []);
    });

    test('list_sublist throws NegativeIndexError for negative end index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sublist([1, 2, 3], 0, -1)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<IndexOutOfBoundsError>().having(
            (IndexOutOfBoundsError e) => e.toString(),
            'message',
            allOf(
              contains('-1'),
              contains('list_sublist'),
            ),
          ),
        ),
      );
    });

    test('list_swap first and last elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_swap([1, 2, 3, 4, 5], 0, 4)',
      );
      checkResult(runtime, [5, 2, 3, 4, 1]);
    });

    test('list_swap in two element list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_swap([1, 2], 0, 1)',
      );
      checkResult(runtime, [2, 1]);
    });

    test('list_take on empty list returns empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = list_take([], 5)');
      checkResult(runtime, []);
    });

    test('list_drop on empty list returns empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = list_drop([], 5)');
      checkResult(runtime, []);
    });

    test('list_reduce with single element list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_reduce([5], 10, num_add)',
      );
      checkResult(runtime, 15);
    });

    test('list_zip with single element lists', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_zip([1], [2], num_add)',
      );
      checkResult(runtime, [3]);
    });

    test('list_indexOf returns first occurrence with duplicates', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_indexOf([1, 2, 2, 3], 2)',
      );
      checkResult(runtime, 1);
    });

    test('list_contains returns true for single element list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_contains([42], 42)',
      );
      checkResult(runtime, true);
    });

    test(
      'list_contains returns false for single element list when not found',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list_contains([42], 99)',
        );
        checkResult(runtime, false);
      },
    );

    test('list_length returns one for single element list', () {
      final RuntimeFacade runtime = getRuntime('main() = list_length([42])');
      checkResult(runtime, 1);
    });

    test('list_join concatenates numbers with separator', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_join([1, 2, 3], "-")',
      );
      checkResult(runtime, '"1-2-3"');
    });

    test('list_join with empty separator', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_join(["a", "b", "c"], "")',
      );
      checkResult(runtime, '"abc"');
    });

    test('list_filled with boolean value', () {
      final RuntimeFacade runtime = getRuntime('main() = list_filled(3, true)');
      checkResult(runtime, [true, true, true]);
    });

    test('list_filled with string value', () {
      final RuntimeFacade runtime = getRuntime('main() = list_filled(2, "x")');
      checkResult(runtime, ['"x"', '"x"']);
    });

    test('list_filled with list value', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_filled(2, [1, 2])',
      );
      checkResult(runtime, [
        [1, 2],
        [1, 2],
      ]);
    });

    test('list_remove from single element list when element matches', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_remove([42], 42)',
      );
      checkResult(runtime, []);
    });

    test(
      'list_remove from single element list when element does not match',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list_remove([42], 99)',
        );
        checkResult(runtime, [42]);
      },
    );

    test('list_isEmpty returns true for single element list is false', () {
      final RuntimeFacade runtime = getRuntime('main() = list_isEmpty([1])');
      checkResult(runtime, false);
    });

    test('list_isNotEmpty returns true for single element list', () {
      final RuntimeFacade runtime = getRuntime('main() = list_isNotEmpty([1])');
      checkResult(runtime, true);
    });

    test('list_init on two element list returns single element', () {
      final RuntimeFacade runtime = getRuntime('main() = list_init([1, 2])');
      checkResult(runtime, [1]);
    });

    test('list_rest on two element list returns single element', () {
      final RuntimeFacade runtime = getRuntime('main() = list_rest([1, 2])');
      checkResult(runtime, [2]);
    });

    test('list_concat with nested lists', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_concat([[1, 2]], [[3, 4]])',
      );
      checkResult(runtime, [
        [1, 2],
        [3, 4],
      ]);
    });

    test('list_map with identity function', () {
      final RuntimeFacade runtime = getRuntime('''
identity(x) = x
main() = list_map([1, 2, 3], identity)
''');
      checkResult(runtime, [1, 2, 3]);
    });

    test('list_filter keeps all elements when all match', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_filter([2, 4, 6], num_isEven)',
      );
      checkResult(runtime, [2, 4, 6]);
    });

    test('list_all returns true for single element matching predicate', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_all([2], num_isEven)',
      );
      checkResult(runtime, true);
    });

    test(
      'list_all returns false for single element not matching predicate',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list_all([3], num_isEven)',
        );
        checkResult(runtime, false);
      },
    );

    test('list_any returns true for single element matching predicate', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_any([2], num_isEven)',
      );
      checkResult(runtime, true);
    });

    test(
      'list_any returns false for single element not matching predicate',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list_any([3], num_isEven)',
        );
        checkResult(runtime, false);
      },
    );

    test('list_none returns false for single element matching predicate', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_none([2], num_isEven)',
      );
      checkResult(runtime, false);
    });

    test(
      'list_none returns true for single element not matching predicate',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list_none([3], num_isEven)',
        );
        checkResult(runtime, true);
      },
    );

    test('list_reverse on two element list', () {
      final RuntimeFacade runtime = getRuntime('main() = list_reverse([1, 2])');
      checkResult(runtime, [2, 1]);
    });

    test('list_insertStart with nested list element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_insertStart([1, 2], [0])',
      );
      checkResult(runtime, [
        [0],
        1,
        2,
      ]);
    });

    test('list_insertEnd with nested list element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_insertEnd([1, 2], [3])',
      );
      checkResult(runtime, [
        1,
        2,
        [3],
      ]);
    });

    test('list_removeAt in middle of list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_removeAt([1, 2, 3, 4, 5], 2)',
      );
      checkResult(runtime, [1, 2, 4, 5]);
    });

    test('list_take from single element list', () {
      final RuntimeFacade runtime = getRuntime('main() = list_take([1], 1)');
      checkResult(runtime, [1]);
    });

    test('list_drop from single element list', () {
      final RuntimeFacade runtime = getRuntime('main() = list_drop([1], 1)');
      checkResult(runtime, []);
    });

    test('list_sublist extracts single element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sublist([1, 2, 3, 4, 5], 2, 3)',
      );
      checkResult(runtime, [3]);
    });

    test('list_at truncates decimal index to integer', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_at([10, 20, 30], 1.9)',
      );
      checkResult(runtime, 20);
    });

    test('list_set truncates decimal index to integer', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_set([1, 2, 3], 1.7, 99)',
      );
      checkResult(runtime, [1, 99, 3]);
    });

    test('list_map with single element list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map([5], num_abs)',
      );
      checkResult(runtime, [5]);
    });

    test('list_filter with single element matching', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_filter([2], num_isEven)',
      );
      checkResult(runtime, [2]);
    });

    test('list_filter with single element not matching', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_filter([3], num_isEven)',
      );
      checkResult(runtime, []);
    });

    test('list_reduce with multiplication', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_reduce([1, 2, 3, 4], 1, num_mul)',
      );
      checkResult(runtime, 24);
    });

    test('list_reduce with subtraction', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_reduce([1, 2, 3], 10, num_sub)',
      );
      checkResult(runtime, 4);
    });

    test('list_indexOf with single element list matching', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_indexOf([42], 42)',
      );
      checkResult(runtime, 0);
    });

    test('list_indexOf with single element list not matching', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_indexOf([42], 99)',
      );
      checkResult(runtime, -1);
    });

    test('list_sort with negative numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sort([-3, 1, -5, 2, -4], num_compare)',
      );
      checkResult(runtime, [-5, -4, -3, 1, 2]);
    });

    test('list_sort with mixed positive and negative numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sort([0, -1, 1, -2, 2], num_compare)',
      );
      checkResult(runtime, [-2, -1, 0, 1, 2]);
    });

    test('list_join with booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_join([true, false, true], " and ")',
      );
      checkResult(runtime, '"true and false and true"');
    });

    test('list_join with mixed numbers and booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_join([1, true, 2], ":")',
      );
      checkResult(runtime, '"1:true:2"');
    });

    test('list_swap in single element list with same index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_swap([42], 0, 0)',
      );
      checkResult(runtime, [42]);
    });

    test('list_concat with single element lists', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_concat([1], [2])',
      );
      checkResult(runtime, [1, 2]);
    });

    test('list_zip with string concatenation function', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_zip(["a", "b"], ["1", "2"], str_concat)',
      );
      checkResult(runtime, ['"a1"', '"b2"']);
    });

    test('list_zip with multiplication function', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_zip([2, 3, 4], [5, 6, 7], num_mul)',
      );
      checkResult(runtime, [10, 18, 28]);
    });

    test('list_contains with nested list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_contains([[1, 2], [3, 4]], [1, 2])',
      );
      checkResult(runtime, true);
    });

    test('list_contains with nested list not found', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_contains([[1, 2], [3, 4]], [1, 3])',
      );
      checkResult(runtime, false);
    });

    test('list_remove with nested list element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_remove([[1, 2], [3, 4], [1, 2]], [1, 2])',
      );
      checkResult(runtime, [
        [3, 4],
      ]);
    });

    test('list_indexOf with nested list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_indexOf([[1, 2], [3, 4]], [3, 4])',
      );
      checkResult(runtime, 1);
    });

    test('list_take truncates decimal count to integer', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_take([1, 2, 3, 4, 5], 2.9)',
      );
      checkResult(runtime, [1, 2]);
    });

    test('list_drop truncates decimal count to integer', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_drop([1, 2, 3, 4, 5], 2.9)',
      );
      checkResult(runtime, [3, 4, 5]);
    });

    test('list_sublist truncates decimal indices to integers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sublist([1, 2, 3, 4, 5], 1.2, 3.8)',
      );
      checkResult(runtime, [2, 3]);
    });

    test('list_swap truncates decimal indices to integers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_swap([1, 2, 3], 0.5, 2.9)',
      );
      checkResult(runtime, [3, 2, 1]);
    });

    test('list_removeAt truncates decimal index to integer', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_removeAt([1, 2, 3], 1.7)',
      );
      checkResult(runtime, [1, 3]);
    });

    test('list_filled truncates decimal count to integer', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_filled(3.9, "x")',
      );
      checkResult(runtime, ['"x"', '"x"', '"x"']);
    });

    test('list_reverse with nested lists', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_reverse([[1, 2], [3, 4], [5, 6]])',
      );
      checkResult(runtime, [
        [5, 6],
        [3, 4],
        [1, 2],
      ]);
    });

    test('list_map with constant function', () {
      final RuntimeFacade runtime = getRuntime('''
always42(x) = 42
main() = list_map([1, 2, 3], always42)
''');
      checkResult(runtime, [42, 42, 42]);
    });

    test('list_filter removes all elements when none match', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_filter([1, 3, 5, 7], num_isEven)',
      );
      checkResult(runtime, []);
    });

    test('list_reduce with empty accumulator function', () {
      final RuntimeFacade runtime = getRuntime('''
takeSecond(a, b) = b
main() = list_reduce([1, 2, 3], 0, takeSecond)
''');
      checkResult(runtime, 3);
    });

    test('list_reduce with take first function', () {
      final RuntimeFacade runtime = getRuntime('''
takeFirst(a, b) = a
main() = list_reduce([1, 2, 3], 0, takeFirst)
''');
      checkResult(runtime, 0);
    });

    test('list_all with all elements matching', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_all([0, 0, 0, 0], num_isZero)',
      );
      checkResult(runtime, true);
    });

    test('list_any with last element matching', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_any([1, 3, 5, 2], num_isEven)',
      );
      checkResult(runtime, true);
    });

    test('list_none with all elements matching predicate', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_none([2, 4, 6], num_isEven)',
      );
      checkResult(runtime, false);
    });

    test('list_sort with two element list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sort([2, 1], num_compare)',
      );
      checkResult(runtime, [1, 2]);
    });

    test('list_sort with two equal elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sort([5, 5], num_compare)',
      );
      checkResult(runtime, [5, 5]);
    });

    test('list_length with nested lists counts outer elements only', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_length([[1, 2, 3], [4, 5], [6]])',
      );
      checkResult(runtime, 3);
    });

    test('list_first with nested list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_first([[1, 2], [3, 4]])',
      );
      checkResult(runtime, [1, 2]);
    });

    test('list_last with nested list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_last([[1, 2], [3, 4]])',
      );
      checkResult(runtime, [3, 4]);
    });

    test('list_init with nested lists', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_init([[1, 2], [3, 4], [5, 6]])',
      );
      checkResult(runtime, [
        [1, 2],
        [3, 4],
      ]);
    });

    test('list_rest with nested lists', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_rest([[1, 2], [3, 4], [5, 6]])',
      );
      checkResult(runtime, [
        [3, 4],
        [5, 6],
      ]);
    });

    test('list_take from nested lists', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_take([[1], [2], [3]], 2)',
      );
      checkResult(runtime, [
        [1],
        [2],
      ]);
    });

    test('list_drop from nested lists', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_drop([[1], [2], [3]], 1)',
      );
      checkResult(runtime, [
        [2],
        [3],
      ]);
    });

    test('list_sublist from nested lists', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sublist([[1], [2], [3], [4]], 1, 3)',
      );
      checkResult(runtime, [
        [2],
        [3],
      ]);
    });

    test('list_set with function value', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = (list_set([1, 2, 3], 1, num_abs))[1](-5)',
      );
      checkResult(runtime, 5);
    });

    test('list_swap adjacent elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_swap([1, 2, 3, 4], 1, 2)',
      );
      checkResult(runtime, [1, 3, 2, 4]);
    });

    test('list_filled with function value', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = (list_filled(2, num_abs))[0](-7)',
      );
      checkResult(runtime, 7);
    });

    test('list_concat preserves order', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_concat([3, 2, 1], [6, 5, 4])',
      );
      checkResult(runtime, [3, 2, 1, 6, 5, 4]);
    });

    test('list_map transforms nested list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map([[1, 2], [3, 4]], list_first)',
      );
      checkResult(runtime, [1, 3]);
    });

    test('list_filter on nested lists with length predicate', () {
      final RuntimeFacade runtime = getRuntime('''
hasTwo(lst) = comp_eq(list_length(lst), 2)
main() = list_filter([[1], [2, 3], [4, 5, 6], [7, 8]], hasTwo)
''');
      checkResult(runtime, [
        [2, 3],
        [7, 8],
      ]);
    });

    test('list_reduce building a list', () {
      final RuntimeFacade runtime = getRuntime('''
append(lst, elem) = list_insertEnd(lst, elem)
main() = list_reduce([1, 2, 3], [], append)
''');
      checkResult(runtime, [1, 2, 3]);
    });

    test('list_all on nested lists', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_all([[1], [2], [3]], list_isNotEmpty)',
      );
      checkResult(runtime, true);
    });

    test('list_any on nested lists', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_any([[], [1], []], list_isNotEmpty)',
      );
      checkResult(runtime, true);
    });

    test('list_none on nested lists', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_none([[], [], []], list_isNotEmpty)',
      );
      checkResult(runtime, true);
    });

    test('list_zip applies function with correct argument order', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_zip([10, 20], [3, 4], num_sub)',
      );
      checkResult(runtime, [7, 16]);
    });

    test('list_sort is stable for equal elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sort([3, 3, 3], num_compare)',
      );
      checkResult(runtime, [3, 3, 3]);
    });

    test('list_contains with boolean value in boolean list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_contains([true, false, true], true)',
      );
      checkResult(runtime, true);
    });

    test('list_contains with string value in string list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_contains(["hello", "world", "foo"], "world")',
      );
      checkResult(runtime, true);
    });

    test('list_indexOf with string value in string list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_indexOf(["one", "two", "three"], "two")',
      );
      checkResult(runtime, 1);
    });

    test('list_indexOf with boolean value in boolean list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_indexOf([true, false, true], false)',
      );
      checkResult(runtime, 1);
    });

    test('list_remove with string value from string list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_remove(["a", "b", "c", "b"], "b")',
      );
      checkResult(runtime, ['"a"', '"c"']);
    });

    test('list_remove with boolean value from boolean list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_remove([true, false, true], true)',
      );
      checkResult(runtime, [false]);
    });

    test('list chained operations', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_reverse(list_take(list_drop([1, 2, 3, 4, 5], 1), 3))',
      );
      checkResult(runtime, [4, 3, 2]);
    });

    test('list double reverse returns original', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_reverse(list_reverse([1, 2, 3, 4, 5]))',
      );
      checkResult(runtime, [1, 2, 3, 4, 5]);
    });

    test('list init and rest on same list are complementary', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_concat(list_init([1, 2, 3, 4]), [list_last([1, 2, 3, 4])])',
      );
      checkResult(runtime, [1, 2, 3, 4]);
    });

    test('list first and rest on same list are complementary', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_concat([list_first([1, 2, 3, 4])], list_rest([1, 2, 3, 4]))',
      );
      checkResult(runtime, [1, 2, 3, 4]);
    });

    test('list_length after insertStart increases by one', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_length(list_insertStart([1, 2], 0))',
      );
      checkResult(runtime, 3);
    });

    test('list_length after insertEnd increases by one', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_length(list_insertEnd([1, 2], 3))',
      );
      checkResult(runtime, 3);
    });

    test('list_length after removeAt decreases by one', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_length(list_removeAt([1, 2, 3], 1))',
      );
      checkResult(runtime, 2);
    });

    test('list_take and drop are complementary', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_concat(list_take([1, 2, 3, 4, 5], 2), list_drop([1, 2, 3, 4, 5], 2))',
      );
      checkResult(runtime, [1, 2, 3, 4, 5]);
    });

    test('list operations preserve element expressions', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_first(list_reverse([1 + 1, 2 + 2, 3 + 3]))',
      );
      checkResult(runtime, 6);
    });

    test('list_join with newline separator', () {
      final RuntimeFacade runtime = getRuntime(
        r'main() = list_join(["line1", "line2"], "\n")',
      );
      checkResult(runtime, '"line1\nline2"');
    });

    test('list_isEmpty after removing all elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_isEmpty(list_remove([1, 1, 1], 1))',
      );
      checkResult(runtime, true);
    });

    test('list_isNotEmpty after adding to empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_isNotEmpty(list_insertStart([], 1))',
      );
      checkResult(runtime, true);
    });

    test('list large input with filled', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_length(list_filled(100, 0))',
      );
      checkResult(runtime, 100);
    });

    test('list large input with map', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_length(list_map(list_filled(50, 1), num_abs))',
      );
      checkResult(runtime, 50);
    });

    test('list large input with filter', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_length(list_filter(list_filled(50, 1), num_isPositive))',
      );
      checkResult(runtime, 50);
    });

    test('list large input with reduce', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_reduce(list_filled(20, 1), 0, num_add)',
      );
      checkResult(runtime, 20);
    });

    test('list_filled with single element', () {
      final RuntimeFacade runtime = getRuntime('main() = list_filled(1, 42)');
      checkResult(runtime, [42]);
    });

    test('list_at accesses last valid index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_at([10, 20, 30], 2)',
      );
      checkResult(runtime, 30);
    });

    test('list_at accesses first index explicitly', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_at([10, 20, 30], 0)',
      );
      checkResult(runtime, 10);
    });

    test('list_sort with decimal numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sort([3.5, 1.2, 2.8, 1.1, 2.9], num_compare)',
      );
      checkResult(runtime, [1.1, 1.2, 2.8, 2.9, 3.5]);
    });

    test('list_sort with mixed integer and decimal numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sort([3, 1.5, 2, 1.1, 3.0], num_compare)',
      );
      checkResult(runtime, [1.1, 1.5, 2, 3, 3.0]);
    });

    test('list_reduce to build string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_reduce(["a", "b", "c"], "", str_concat)',
      );
      checkResult(runtime, '"abc"');
    });

    test('list_reduce with num_max to find maximum', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_reduce([3, 7, 2, 9, 1], 0, num_max)',
      );
      checkResult(runtime, 9);
    });

    test('list_reduce with num_min to find minimum', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_reduce([3, 7, 2, 9, 1], 100, num_min)',
      );
      checkResult(runtime, 1);
    });

    test('list_filter with num_isPositive', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_filter([-2, -1, 0, 1, 2], num_isPositive)',
      );
      checkResult(runtime, [1, 2]);
    });

    test('list_filter with num_isNegative', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_filter([-2, -1, 0, 1, 2], num_isNegative)',
      );
      checkResult(runtime, [-2, -1]);
    });

    test('list_swap with reversed indices second less than first', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_swap([1, 2, 3, 4, 5], 3, 1)',
      );
      checkResult(runtime, [1, 4, 3, 2, 5]);
    });

    test('list_indexOf returns index of last element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_indexOf([10, 20, 30, 40], 40)',
      );
      checkResult(runtime, 3);
    });

    test('list_indexOf returns index of first element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_indexOf([10, 20, 30, 40], 10)',
      );
      checkResult(runtime, 0);
    });

    test('list concatenation with plus operator joins empty lists', () {
      final RuntimeFacade runtime = getRuntime('main() = [] + []');
      checkResult(runtime, []);
    });

    test('list concatenation prepends to empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = 1 + []');
      checkResult(runtime, [1]);
    });

    test('list concatenation appends to empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = [] + 1');
      checkResult(runtime, [1]);
    });

    test('list indexing with expression as index', () {
      final RuntimeFacade runtime = getRuntime('main() = [10, 20, 30][1 + 1]');
      checkResult(runtime, 30);
    });

    test('list indexing with function result as index', () {
      final RuntimeFacade runtime = getRuntime('''
getIndex(x) = x
main() = [10, 20, 30][getIndex(1)]
''');
      checkResult(runtime, 20);
    });

    test('list_set with consecutive updates', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_set(list_set([1, 2, 3], 0, 10), 2, 30)',
      );
      checkResult(runtime, [10, 2, 30]);
    });

    test('list_concat with deeply nested lists', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_concat([[[1, 2]]], [[[3, 4]]])',
      );
      checkResult(runtime, [
        [
          [1, 2],
        ],
        [
          [3, 4],
        ],
      ]);
    });

    test('list_map preserves nested list structure', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map([[1, 2], [3, 4]], list_length)',
      );
      checkResult(runtime, [2, 2]);
    });

    test('list_all with first element failing predicate', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_all([1, 2, 4, 6], num_isEven)',
      );
      checkResult(runtime, false);
    });

    test('list_any with only first element matching predicate', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_any([2, 1, 3, 5], num_isEven)',
      );
      checkResult(runtime, true);
    });

    test('list_none with first element matching predicate', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_none([2, 1, 3, 5], num_isEven)',
      );
      checkResult(runtime, false);
    });

    test('list_filter preserves order', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_filter([5, 2, 8, 1, 4], num_isEven)',
      );
      checkResult(runtime, [2, 8, 4]);
    });

    test('list_reverse preserves element types', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_reverse([1, "two", true, [4]])',
      );
      checkResult(runtime, [
        [4],
        true,
        '"two"',
        1,
      ]);
    });

    test('list_sublist returns full list from start', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sublist([1, 2, 3, 4, 5], 0, 5)',
      );
      checkResult(runtime, [1, 2, 3, 4, 5]);
    });

    test('list_sublist returns single last element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sublist([1, 2, 3, 4, 5], 4, 5)',
      );
      checkResult(runtime, [5]);
    });

    test('list_sublist returns single first element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sublist([1, 2, 3, 4, 5], 0, 1)',
      );
      checkResult(runtime, [1]);
    });

    test('list_zip with division function', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_zip([10, 20, 30], [2, 4, 5], num_div)',
      );
      checkResult(runtime, [5.0, 5.0, 6.0]);
    });

    test('list_join with tab separator', () {
      final RuntimeFacade runtime = getRuntime(
        r'main() = list_join(["a", "b", "c"], "\t")',
      );
      checkResult(runtime, '"a\tb\tc"');
    });

    test('list_join with nested lists converts to string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_join([[1, 2], [3, 4]], " | ")',
      );
      checkResult(runtime, '"[1, 2] | [3, 4]"');
    });

    test('list_length after multiple operations', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_length(list_concat(list_take([1, 2, 3], 2), list_drop([4, 5, 6], 1)))',
      );
      checkResult(runtime, 4);
    });

    test('list_isEmpty after filter removes all elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_isEmpty(list_filter([1, 3, 5], num_isEven))',
      );
      checkResult(runtime, true);
    });

    test('list_isNotEmpty after filter keeps some elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_isNotEmpty(list_filter([1, 2, 3], num_isEven))',
      );
      checkResult(runtime, true);
    });

    test('list_contains after insertStart', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_contains(list_insertStart([2, 3], 1), 1)',
      );
      checkResult(runtime, true);
    });

    test('list_contains after insertEnd', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_contains(list_insertEnd([1, 2], 3), 3)',
      );
      checkResult(runtime, true);
    });

    test('list_contains after remove', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_contains(list_remove([1, 2, 3], 2), 2)',
      );
      checkResult(runtime, false);
    });

    test('list_indexOf after reverse', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_indexOf(list_reverse([10, 20, 30]), 10)',
      );
      checkResult(runtime, 2);
    });

    test('list_first after sort', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_first(list_sort([5, 3, 8, 1], num_compare))',
      );
      checkResult(runtime, 1);
    });

    test('list_last after sort', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_last(list_sort([5, 3, 8, 1], num_compare))',
      );
      checkResult(runtime, 8);
    });

    test('list_reduce on nested list to flatten', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_reduce([[1, 2], [3, 4], [5]], [], list_concat)',
      );
      checkResult(runtime, [1, 2, 3, 4, 5]);
    });

    test('list_map with num_negative', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map([1, 2, 3], num_negative)',
      );
      checkResult(runtime, [-1, -2, -3]);
    });

    test('list_map with num_inc', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map([1, 2, 3], num_inc)',
      );
      checkResult(runtime, [2, 3, 4]);
    });

    test('list_map with num_abs', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map([-1, -2, 3, -4], num_abs)',
      );
      checkResult(runtime, [1, 2, 3, 4]);
    });

    test('list_filter with num_isOdd', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_filter([1, 2, 3, 4, 5], num_isOdd)',
      );
      checkResult(runtime, [1, 3, 5]);
    });

    test('list_all with num_isPositive', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_all([1, 2, 3, 4], num_isPositive)',
      );
      checkResult(runtime, true);
    });

    test('list_all with num_isPositive when one is zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_all([1, 0, 3, 4], num_isPositive)',
      );
      checkResult(runtime, false);
    });

    test('list_any with num_isNegative', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_any([1, -2, 3, 4], num_isNegative)',
      );
      checkResult(runtime, true);
    });

    test('list_none with num_isNegative', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_none([1, 2, 3, 4], num_isNegative)',
      );
      checkResult(runtime, true);
    });

    test('list_zip combining lists of different sizes with subtraction', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_zip([10, 20, 30, 40], [1, 2], num_sub)',
      );
      checkResult(runtime, [9, 18, 30, 40]);
    });

    test('list_sort with all equal elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sort([5, 5, 5, 5], num_compare)',
      );
      checkResult(runtime, [5, 5, 5, 5]);
    });

    test('list_sort with alternating elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sort([1, 9, 2, 8, 3, 7], num_compare)',
      );
      checkResult(runtime, [1, 2, 3, 7, 8, 9]);
    });

    test('list_filled with zero creates empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = list_filled(0, 42)');
      checkResult(runtime, []);
    });

    test('list_insertStart preserves order of existing elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_insertStart([2, 3, 4], 1)',
      );
      checkResult(runtime, [1, 2, 3, 4]);
    });

    test('list_insertEnd preserves order of existing elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_insertEnd([1, 2, 3], 4)',
      );
      checkResult(runtime, [1, 2, 3, 4]);
    });

    test('list_removeAt from two element list removing first', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_removeAt([1, 2], 0)',
      );
      checkResult(runtime, [2]);
    });

    test('list_removeAt from two element list removing second', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_removeAt([1, 2], 1)',
      );
      checkResult(runtime, [1]);
    });

    test('list_init on three element list returns two elements', () {
      final RuntimeFacade runtime = getRuntime('main() = list_init([1, 2, 3])');
      checkResult(runtime, [1, 2]);
    });

    test('list_rest on three element list returns two elements', () {
      final RuntimeFacade runtime = getRuntime('main() = list_rest([1, 2, 3])');
      checkResult(runtime, [2, 3]);
    });

    test('list constructor with multiple nested lists', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = [[1, 2], [3, 4], [5, 6]]',
      );
      checkResult(runtime, [
        [1, 2],
        [3, 4],
        [5, 6],
      ]);
    });

    test('list constructor with empty nested list', () {
      final RuntimeFacade runtime = getRuntime('main() = [[]]');
      checkResult(runtime, [[]]);
    });

    test('list constructor with multiple empty nested lists', () {
      final RuntimeFacade runtime = getRuntime('main() = [[], [], []]');
      checkResult(runtime, [[], [], []]);
    });

    test('list_contains with empty nested list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_contains([[], [1]], [])',
      );
      checkResult(runtime, true);
    });

    test('list_indexOf with empty nested list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_indexOf([[], [1], [2]], [])',
      );
      checkResult(runtime, 0);
    });

    test('list_remove removes empty nested list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_remove([[], [1], [], [2]], [])',
      );
      checkResult(runtime, [
        [1],
        [2],
      ]);
    });

    test('list_reduce accumulating count of elements', () {
      final RuntimeFacade runtime = getRuntime('''
increment(acc, elem) = num_add(acc, 1)
main() = list_reduce([10, 20, 30, 40, 50], 0, increment)
''');
      checkResult(runtime, 5);
    });

    test('list_filter with custom predicate on strings', () {
      final RuntimeFacade runtime = getRuntime('''
isShort(s) = comp_lt(str_length(s), 4)
main() = list_filter(["hi", "hello", "hey", "howdy"], isShort)
''');
      checkResult(runtime, ['"hi"', '"hey"']);
    });

    test('list_map with str_length on strings', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map(["a", "bb", "ccc"], str_length)',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('list_sort strings by length', () {
      final RuntimeFacade runtime = getRuntime('''
compareByLength(a, b) = num_sub(str_length(a), str_length(b))
main() = list_sort(["hello", "hi", "hey"], compareByLength)
''');
      checkResult(runtime, ['"hi"', '"hey"', '"hello"']);
    });

    test('list_zip with modulo function', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_zip([10, 15, 20], [3, 4, 6], num_mod)',
      );
      checkResult(runtime, [1, 3, 2]);
    });

    test('list_all on two element list both matching', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_all([2, 4], num_isEven)',
      );
      checkResult(runtime, true);
    });

    test('list_any on two element list one matching', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_any([1, 2], num_isEven)',
      );
      checkResult(runtime, true);
    });

    test('list_none on two element list none matching', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_none([1, 3], num_isEven)',
      );
      checkResult(runtime, true);
    });

    test('list_swap swaps same index in two element list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_swap([1, 2], 1, 1)',
      );
      checkResult(runtime, [1, 2]);
    });

    test('list_concat multiple times', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_concat(list_concat([1], [2]), [3])',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('list_take entire list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_take([1, 2, 3], 3)',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('list_drop entire list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_drop([1, 2, 3], 3)',
      );
      checkResult(runtime, []);
    });

    test('list_set at index zero in multi-element list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_set([1, 2, 3, 4, 5], 0, 10)',
      );
      checkResult(runtime, [10, 2, 3, 4, 5]);
    });

    test('list_set at last index in multi-element list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_set([1, 2, 3, 4, 5], 4, 50)',
      );
      checkResult(runtime, [1, 2, 3, 4, 50]);
    });

    test('list_join with multi-character separator', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_join(["a", "b", "c"], " => ")',
      );
      checkResult(runtime, '"a => b => c"');
    });

    test('list_reverse on string list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_reverse(["a", "b", "c"])',
      );
      checkResult(runtime, ['"c"', '"b"', '"a"']);
    });

    test('list_reverse on boolean list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_reverse([true, false, true])',
      );
      checkResult(runtime, [true, false, true]);
    });

    test('list concatenation multiple elements prepend', () {
      final RuntimeFacade runtime = getRuntime('main() = [1, 2] + [3, 4, 5]');
      checkResult(runtime, [1, 2, 3, 4, 5]);
    });

    test('list indexing returns last element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = [10, 20, 30, 40][3]',
      );
      checkResult(runtime, 40);
    });

    test('list indexing returns first element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = [10, 20, 30, 40][0]',
      );
      checkResult(runtime, 10);
    });
  });

  group('List Type Errors', () {
    test('list_length throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = list_length("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_first throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = list_first("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_last throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = list_last("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_isEmpty throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_isEmpty("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_reverse throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_reverse("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_sort throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sort("hello", num_compare)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test(
      'list_sort throws InvalidArgumentTypesError for non-numeric comparator result',
      () {
        final RuntimeFacade runtime = getRuntime('''
badCompare(a, b) = true
main() = list_sort([3, 1, 2], badCompare)
''');
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('list_sort'),
                contains('Number'),
                contains('Boolean'),
              ),
            ),
          ),
        );
      },
    );

    test('list_contains throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_contains("hello", 1)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_map throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map("hello", num_abs)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('list_map'),
              contains('String'),
              contains('Function'),
            ),
          ),
        ),
      );
    });

    test('list_isNotEmpty throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_isNotEmpty("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_init throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = list_init("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_rest throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = list_rest("hello")');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_concat throws for wrong first argument type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_concat("hello", [1, 2])',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_concat throws for wrong second argument type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_concat([1, 2], "hello")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_take throws for wrong list type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_take("hello", 2)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_drop throws for wrong list type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_drop("hello", 2)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_at throws for wrong list type', () {
      final RuntimeFacade runtime = getRuntime('main() = list_at("hello", 1)');
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_set throws for wrong list type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_set("hello", 1, 42)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_sublist throws for wrong list type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sublist("hello", 0, 2)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_swap throws for wrong list type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_swap("hello", 0, 1)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_remove throws for wrong list type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_remove("hello", "l")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_removeAt throws for wrong list type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_removeAt("hello", 1)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_indexOf throws for wrong list type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_indexOf("hello", "l")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_insertStart throws for wrong list type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_insertStart("hello", 1)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_insertEnd throws for wrong list type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_insertEnd("hello", 1)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_join throws for wrong list type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_join("hello", ",")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_join throws for wrong separator type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_join([1, 2], 42)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_filter throws for wrong list type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_filter("hello", num_isEven)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_filter throws for wrong function type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_filter([1, 2, 3], 42)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_reduce throws for wrong list type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_reduce("hello", 0, num_add)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_all throws for wrong list type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_all("hello", num_isEven)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_all throws for wrong function type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_all([1, 2, 3], 42)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_any throws for wrong list type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_any("hello", num_isEven)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_any throws for wrong function type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_any([1, 2, 3], 42)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_none throws for wrong list type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_none("hello", num_isEven)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_none throws for wrong function type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_none([1, 2, 3], 42)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_zip throws for wrong first list type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_zip("hello", [1, 2], num_add)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_zip throws for wrong second list type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_zip([1, 2], "hello", num_add)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_zip throws for wrong function type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_zip([1, 2], [3, 4], 42)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_filled throws for wrong count type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_filled("hello", 42)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_map throws for wrong function type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_map([1, 2, 3], 42)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_sort throws for wrong function type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sort([1, 2, 3], "compare")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_at throws for wrong index type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_at([1, 2, 3], "one")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_set throws for wrong index type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_set([1, 2, 3], "one", 42)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_sublist throws for wrong start index type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sublist([1, 2, 3], "one", 2)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_sublist throws for wrong end index type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sublist([1, 2, 3], 0, "two")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_swap throws for wrong first index type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_swap([1, 2, 3], "one", 2)',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_swap throws for wrong second index type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_swap([1, 2, 3], 0, "two")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_take throws for wrong count type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_take([1, 2, 3], "two")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_drop throws for wrong count type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_drop([1, 2, 3], "two")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_removeAt throws for wrong index type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_removeAt([1, 2, 3], "one")',
      );
      expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
    });

    test('list_filled truncates a non-integer count', () {
      final RuntimeFacade runtime = getRuntime('main() = list_filled(2.5, 1)');
      checkResult(runtime, [1, 1]);
    });

    test(
      'list_reduce throws for wrong initial value type when function expects specific type',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list_reduce([1, 2, 3], "zero", num_add)',
        );
        expect(runtime.executeMain, throwsA(isA<RuntimeError>()));
      },
    );

    test('list_chunk throws for wrong first argument type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_chunk("abc", 2)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list_chunk throws for wrong second argument type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_chunk([1, 2, 3], "2")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list_count throws for wrong first argument type', () {
      final RuntimeFacade runtime = getRuntime(
        'isPositive(x) = x > 0\nmain() = list_count("abc", isPositive)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list_distinct throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = list_distinct(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list_flatten throws for wrong type', () {
      final RuntimeFacade runtime = getRuntime('main() = list_flatten("abc")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('List Error Cases', () {
    test('list_at throws IndexOutOfBoundsError for out-of-bounds index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_at([1, 2, 3], 10)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<IndexOutOfBoundsError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('10'),
              contains('length: 3'),
              contains('list_at'),
            ),
          ),
        ),
      );
    });

    test('list_at throws NegativeIndexError for negative index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_at([1, 2, 3], -1)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<NegativeIndexError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('-1'),
              contains('list_at'),
            ),
          ),
        ),
      );
    });

    test('list_first throws EmptyCollectionError for empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = list_first([])');
      expect(
        runtime.executeMain,
        throwsA(
          isA<EmptyCollectionError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('empty'),
              contains('list'),
              contains('list_first'),
            ),
          ),
        ),
      );
    });

    test('list_last throws EmptyCollectionError for empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = list_last([])');
      expect(
        runtime.executeMain,
        throwsA(
          isA<EmptyCollectionError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('empty'),
              contains('list'),
              contains('list_last'),
            ),
          ),
        ),
      );
    });

    test(
      'list_reduce throws InvalidArgumentTypesError with non-function accumulator',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list_reduce([1, 2, 3], 0, 42)',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('list_reduce'),
                contains('List'),
                contains('Number'),
              ),
            ),
          ),
        );
      },
    );

    test('list_drop clamps to length for out-of-bounds count', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_drop([1, 2, 3], 10)',
      );
      checkResult(runtime, []);
    });

    test('list_drop throws NegativeIndexError for negative count', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_drop([1, 2, 3], -1)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<NegativeIndexError>().having(
            (e) => e.toString(),
            'message',
            allOf(
              contains('-1'),
              contains('list_drop'),
            ),
          ),
        ),
      );
    });

    test('list_take clamps to length for out-of-bounds count', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_take([1, 2, 3], 10)',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('list_take throws NegativeIndexError for negative count', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_take([1, 2, 3], -1)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<NegativeIndexError>().having(
            (NegativeIndexError e) => e.toString(),
            'message',
            allOf(
              contains('-1'),
              contains('list_take'),
            ),
          ),
        ),
      );
    });

    test('list_set throws NegativeIndexError for negative index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_set([1, 2, 3], -1, 42)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<NegativeIndexError>().having(
            (NegativeIndexError e) => e.toString(),
            'message',
            allOf(
              contains('-1'),
              contains('list_set'),
            ),
          ),
        ),
      );
    });

    test('list_set throws IndexOutOfBoundsError for out-of-bounds index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_set([1, 2, 3], 10, 42)',
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
              contains('list_set'),
            ),
          ),
        ),
      );
    });

    test('list_sublist throws NegativeIndexError for negative start', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sublist([1, 2, 3], -1, 2)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<NegativeIndexError>().having(
            (NegativeIndexError e) => e.toString(),
            'message',
            allOf(
              contains('-1'),
              contains('list_sublist'),
            ),
          ),
        ),
      );
    });

    test(
      'list_sublist throws IndexOutOfBoundsError when start exceeds length',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list_sublist([1, 2, 3], 10, 12)',
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
                contains('list_sublist'),
              ),
            ),
          ),
        );
      },
    );

    test(
      'list_sublist throws IndexOutOfBoundsError when end is less than start',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list_sublist([1, 2, 3], 2, 1)',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<IndexOutOfBoundsError>().having(
              (IndexOutOfBoundsError e) => e.toString(),
              'message',
              allOf(
                contains('1'),
                contains('list_sublist'),
              ),
            ),
          ),
        );
      },
    );

    test(
      'list_sublist throws IndexOutOfBoundsError when end exceeds length',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list_sublist([1, 2, 3], 0, 10)',
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
                contains('list_sublist'),
              ),
            ),
          ),
        );
      },
    );

    test('list_swap throws NegativeIndexError for negative first index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_swap([1, 2, 3], -1, 2)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<NegativeIndexError>().having(
            (NegativeIndexError e) => e.toString(),
            'message',
            allOf(
              contains('-1'),
              contains('list_swap'),
            ),
          ),
        ),
      );
    });

    test('list_swap throws NegativeIndexError for negative second index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_swap([1, 2, 3], 0, -1)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<NegativeIndexError>().having(
            (NegativeIndexError e) => e.toString(),
            'message',
            allOf(
              contains('-1'),
              contains('list_swap'),
            ),
          ),
        ),
      );
    });

    test(
      'list_swap throws IndexOutOfBoundsError for out-of-bounds first index',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list_swap([1, 2, 3], 10, 1)',
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
                contains('list_swap'),
              ),
            ),
          ),
        );
      },
    );

    test(
      'list_swap throws IndexOutOfBoundsError for out-of-bounds second index',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list_swap([1, 2, 3], 0, 10)',
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
                contains('list_swap'),
              ),
            ),
          ),
        );
      },
    );

    test('list_removeAt throws NegativeIndexError for negative index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_removeAt([1, 2, 3], -1)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<NegativeIndexError>().having(
            (NegativeIndexError e) => e.toString(),
            'message',
            allOf(
              contains('-1'),
              contains('list_removeAt'),
            ),
          ),
        ),
      );
    });

    test(
      'list_removeAt throws IndexOutOfBoundsError for out-of-bounds index',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list_removeAt([1, 2, 3], 10)',
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
                contains('list_removeAt'),
              ),
            ),
          ),
        );
      },
    );

    test('list_removeAt removes first element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_removeAt([1, 2, 3], 0)',
      );
      checkResult(runtime, [2, 3]);
    });

    test('list_removeAt removes last element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_removeAt([1, 2, 3], 2)',
      );
      checkResult(runtime, [1, 2]);
    });

    test('list_removeAt on single element list returns empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_removeAt([42], 0)',
      );
      checkResult(runtime, []);
    });

    test('list_swap throws IndexOutOfBoundsError on empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_swap([], 0, 0)',
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
              contains('list_swap'),
            ),
          ),
        ),
      );
    });

    test('list_removeAt throws IndexOutOfBoundsError on empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_removeAt([], 0)',
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
              contains('list_removeAt'),
            ),
          ),
        ),
      );
    });

    test(
      'list_sublist throws IndexOutOfBoundsError on empty list with non-zero indices',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = list_sublist([], 0, 1)',
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
                contains('list_sublist'),
              ),
            ),
          ),
        );
      },
    );

    // list_flatten tests
    test('list_flatten returns empty list for empty input', () {
      final RuntimeFacade runtime = getRuntime('main() = list_flatten([])');
      checkResult(runtime, []);
    });

    test('list_flatten returns same list when no nested lists', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_flatten([1, 2, 3])',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('list_flatten flattens nested lists one level', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_flatten([[1, 2], [3, 4]])',
      );
      checkResult(runtime, [1, 2, 3, 4]);
    });

    test('list_flatten handles mixed nested and flat elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_flatten([1, [2, 3], 4])',
      );
      checkResult(runtime, [1, 2, 3, 4]);
    });

    test('list_flatten only flattens one level', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_flatten([[[1, 2]], [[3, 4]]])',
      );
      checkResult(runtime, [
        [1, 2],
        [3, 4],
      ]);
    });

    test('list_flatten handles empty nested lists', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_flatten([[], [1], []])',
      );
      checkResult(runtime, [1]);
    });

    test('list_flatten with single nested list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_flatten([[1, 2, 3]])',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    // list_distinct tests
    test('list_distinct returns empty list for empty input', () {
      final RuntimeFacade runtime = getRuntime('main() = list_distinct([])');
      checkResult(runtime, []);
    });

    test('list_distinct returns same list when no duplicates', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_distinct([1, 2, 3])',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('list_distinct removes duplicate numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_distinct([1, 2, 2, 3, 1])',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('list_distinct preserves first occurrence order', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_distinct([3, 1, 2, 1, 3])',
      );
      checkResult(runtime, [3, 1, 2]);
    });

    test('list_distinct removes duplicate strings', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_distinct(["a", "b", "a", "c"])',
      );
      checkResult(runtime, ['"a"', '"b"', '"c"']);
    });

    test('list_distinct removes duplicate booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_distinct([true, false, true, false])',
      );
      checkResult(runtime, [true, false]);
    });

    test('list_distinct with single element', () {
      final RuntimeFacade runtime = getRuntime('main() = list_distinct([42])');
      checkResult(runtime, [42]);
    });

    test('list_distinct with all duplicates', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_distinct([1, 1, 1, 1])',
      );
      checkResult(runtime, [1]);
    });

    // list_count tests
    test('list_count returns zero for empty list', () {
      final RuntimeFacade runtime = getRuntime('''
isEven(x) = x % 2 == 0
main() = list_count([], isEven)
''');
      checkResult(runtime, 0);
    });

    test('list_count counts matching elements', () {
      final RuntimeFacade runtime = getRuntime('''
isEven(x) = x % 2 == 0
main() = list_count([1, 2, 3, 4, 5, 6], isEven)
''');
      checkResult(runtime, 3);
    });

    test('list_count returns zero when none match', () {
      final RuntimeFacade runtime = getRuntime('''
isNegative(x) = x < 0
main() = list_count([1, 2, 3], isNegative)
''');
      checkResult(runtime, 0);
    });

    test('list_count returns length when all match', () {
      final RuntimeFacade runtime = getRuntime('''
isPositive(x) = x > 0
main() = list_count([1, 2, 3], isPositive)
''');
      checkResult(runtime, 3);
    });

    test('list_count with lambda predicate', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_count([1, 2, 3, 4], (x) -> x > 2)',
      );
      checkResult(runtime, 2);
    });

    test('list_count throws error when predicate does not return boolean', () {
      final RuntimeFacade runtime = getRuntime('''
double(x) = x * 2
main() = list_count([1, 2, 3], double)
''');
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidArgumentTypesError>().having(
            (InvalidArgumentTypesError e) => e.toString(),
            'message',
            allOf(contains('Boolean'), contains('Number')),
          ),
        ),
      );
    });

    // list_chunk tests
    test('list_chunk returns empty list for empty input', () {
      final RuntimeFacade runtime = getRuntime('main() = list_chunk([], 2)');
      checkResult(runtime, []);
    });

    test('list_chunk splits list into equal chunks', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_chunk([1, 2, 3, 4], 2)',
      );
      checkResult(runtime, [
        [1, 2],
        [3, 4],
      ]);
    });

    test('list_chunk handles last chunk smaller than size', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_chunk([1, 2, 3, 4, 5], 2)',
      );
      checkResult(runtime, [
        [1, 2],
        [3, 4],
        [5],
      ]);
    });

    test('list_chunk with chunk size larger than list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_chunk([1, 2, 3], 10)',
      );
      checkResult(runtime, [
        [1, 2, 3],
      ]);
    });

    test('list_chunk with chunk size of 1', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_chunk([1, 2, 3], 1)',
      );
      checkResult(runtime, [
        [1],
        [2],
        [3],
      ]);
    });

    test('list_chunk with chunk size equal to list length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_chunk([1, 2, 3], 3)',
      );
      checkResult(runtime, [
        [1, 2, 3],
      ]);
    });

    test('list_chunk throws NegativeIndexError on negative chunk size', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_chunk([1, 2, 3], -1)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<NegativeIndexError>().having(
            (NegativeIndexError e) => e.toString(),
            'message',
            allOf(contains('-1'), contains('list_chunk')),
          ),
        ),
      );
    });

    test('list_chunk throws error on zero chunk size', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_chunk([1, 2, 3], 0)',
      );
      expect(
        runtime.executeMain,
        throwsA(
          isA<InvalidValueError>().having(
            (InvalidValueError e) => e.toString(),
            'message',
            contains('Chunk size must be positive'),
          ),
        ),
      );
    });

    test('list_chunk with single element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_chunk([42], 5)',
      );
      checkResult(runtime, [
        [42],
      ]);
    });
  });
}
