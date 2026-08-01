@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Set', () {
    test('set_new creates empty set from empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = set_new([])');
      checkResult(runtime, {});
    });

    test('set_new creates set from list with unique elements', () {
      final RuntimeFacade runtime = getRuntime('main() = set_new([1, 2])');
      checkResult(runtime, {1, 2});
    });

    test('set_new creates single-element set', () {
      final RuntimeFacade runtime = getRuntime('main() = set_new([42])');
      checkResult(runtime, {42});
    });

    test('set_new removes duplicates from list', () {
      final RuntimeFacade runtime = getRuntime('main() = set_new([1, 2, 1])');
      checkResult(runtime, {1, 2});
    });

    test('set_new creates set with string elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new(["a", "b", "c"])',
      );
      checkResult(runtime, {'"a"', '"b"', '"c"'});
    });

    test('set_new creates set with boolean elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([true, false])',
      );
      checkResult(runtime, {true, false});
    });

    test('set_new creates set with mixed element types', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([1, "two", true])',
      );
      checkResult(runtime, {1, '"two"', true});
    });

    test('set_new removes duplicate booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([true, false, true])',
      );
      checkResult(runtime, {true, false});
    });

    test('set_add adds element to empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_add(set_new([]), 1)',
      );
      checkResult(runtime, {1});
    });

    test('set_add adds new element to non-empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_add(set_new([1, 2]), 3)',
      );
      checkResult(runtime, {1, 2, 3});
    });

    test('set_add does not duplicate existing element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_add(set_new([1, 2]), 2)',
      );
      checkResult(runtime, {1, 2});
    });

    test('set_add adds string element to set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_add(set_new(["a", "b"]), "c")',
      );
      checkResult(runtime, {'"a"', '"b"', '"c"'});
    });

    test('set_add adds element to single-element set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_add(set_new([1]), 2)',
      );
      checkResult(runtime, {1, 2});
    });

    test('set_remove on empty set returns empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_remove(set_new([]), 1)',
      );
      checkResult(runtime, {});
    });

    test('set_remove returns unchanged set when element absent', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_remove(set_new([1, 2]), 3)',
      );
      checkResult(runtime, {1, 2});
    });

    test('set_remove removes existing element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_remove(set_new([1, 2]), 2)',
      );
      checkResult(runtime, {1});
    });

    test('set_remove from single-element set returns empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_remove(set_new([1]), 1)',
      );
      checkResult(runtime, {});
    });

    test('set_contains returns true for existing element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_contains(set_new([1, 2, 3]), 2)',
      );
      checkResult(runtime, true);
    });

    test('set_contains returns false for missing element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_contains(set_new([1, 2]), 3)',
      );
      checkResult(runtime, false);
    });

    test('set_contains returns false for empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_contains(set_new([]), 1)',
      );
      checkResult(runtime, false);
    });

    test('set_contains returns true for single-element set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_contains(set_new([42]), 42)',
      );
      checkResult(runtime, true);
    });

    test('set_contains returns false for single-element set when absent', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_contains(set_new([42]), 99)',
      );
      checkResult(runtime, false);
    });

    test('set_isEmpty returns true for empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isEmpty(set_new([]))',
      );
      checkResult(runtime, true);
    });

    test('set_isEmpty returns false for non-empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isEmpty(set_new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('set_isEmpty returns false for single-element set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isEmpty(set_new([42]))',
      );
      checkResult(runtime, false);
    });

    test('set_isNotEmpty returns false for empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isNotEmpty(set_new([]))',
      );
      checkResult(runtime, false);
    });

    test('set_isNotEmpty returns true for non-empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isNotEmpty(set_new([1, 2, 3]))',
      );
      checkResult(runtime, true);
    });

    test('set_isNotEmpty returns true for single-element set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isNotEmpty(set_new([42]))',
      );
      checkResult(runtime, true);
    });

    test('set_length returns zero for empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_length(set_new([]))',
      );
      checkResult(runtime, 0);
    });

    test('set_length returns element count for non-empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_length(set_new([1, 2, 3]))',
      );
      checkResult(runtime, 3);
    });

    test('set_length returns one for single-element set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_length(set_new([42]))',
      );
      checkResult(runtime, 1);
    });

    test('set_union of two empty sets returns empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_union(set_new([]), set_new([]))',
      );
      checkResult(runtime, {});
    });

    test('set_union combines disjoint sets', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_union(set_new([1, 2]), set_new([3]))',
      );
      checkResult(runtime, {1, 2, 3});
    });

    test('set_union combines sets with smaller first operand', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_union(set_new([1]), set_new([2, 3]))',
      );
      checkResult(runtime, {1, 2, 3});
    });

    test('set_union with empty first operand returns second set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_union(set_new([]), set_new([1, 2]))',
      );
      checkResult(runtime, {1, 2});
    });

    test('set_union with empty second operand returns first set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_union(set_new([1, 2]), set_new([]))',
      );
      checkResult(runtime, {1, 2});
    });

    test('set_union merges overlapping sets without duplicates', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_union(set_new([1, 2]), set_new([2, 3]))',
      );
      checkResult(runtime, {1, 2, 3});
    });

    test('set_union with identical sets returns same set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_union(set_new([1, 2]), set_new([1, 2]))',
      );
      checkResult(runtime, {1, 2});
    });

    test('set_intersection of two empty sets returns empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_intersection(set_new([]), set_new([]))',
      );
      checkResult(runtime, {});
    });

    test('set_intersection of disjoint sets returns empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_intersection(set_new([1]), set_new([2]))',
      );
      checkResult(runtime, {});
    });

    test('set_intersection returns common elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_intersection(set_new([1, 2]), set_new([2, 3]))',
      );
      checkResult(runtime, {2});
    });

    test('set_intersection is commutative', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_intersection(set_new([2, 3]), set_new([1, 2]))',
      );
      checkResult(runtime, {2});
    });

    test('set_intersection with empty first operand returns empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_intersection(set_new([]), set_new([1, 2]))',
      );
      checkResult(runtime, {});
    });

    test('set_intersection with empty second operand returns empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_intersection(set_new([1, 2]), set_new([]))',
      );
      checkResult(runtime, {});
    });

    test('set_intersection with identical sets returns same set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_intersection(set_new([1, 2]), set_new([1, 2]))',
      );
      checkResult(runtime, {1, 2});
    });

    test('set_difference of two empty sets returns empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_difference(set_new([]), set_new([]))',
      );
      checkResult(runtime, {});
    });

    test('set_difference with empty second set returns first set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_difference(set_new([1, 2]), set_new([]))',
      );
      checkResult(runtime, {1, 2});
    });

    test('set_difference with empty first set returns empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_difference(set_new([]), set_new([1, 2]))',
      );
      checkResult(runtime, {});
    });

    test('set_difference of disjoint sets returns first set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_difference(set_new([1, 2]), set_new([3, 4]))',
      );
      checkResult(runtime, {1, 2});
    });

    test('set_difference removes common elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_difference(set_new([1, 2, 3]), set_new([2, 3]))',
      );
      checkResult(runtime, {1});
    });

    test('set_difference is not commutative', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_difference(set_new([2, 3]), set_new([1, 2, 3]))',
      );
      checkResult(runtime, {});
    });

    test('set_difference with identical sets returns empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_difference(set_new([1, 2, 3]), set_new([1, 2, 3]))',
      );
      checkResult(runtime, {});
    });

    test('set_difference with single-element sets', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_difference(set_new([1]), set_new([1]))',
      );
      checkResult(runtime, {});
    });

    test('set - set performs set difference', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([1, 2, 3]) - set_new([2])',
      );
      checkResult(runtime, {1, 3});
    });

    test('set - element removes element from set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([1, 2, 3]) - 2',
      );
      checkResult(runtime, {1, 3});
    });

    test('set - element on empty set returns empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([]) - 1',
      );
      checkResult(runtime, {});
    });

    test('set - element when element not in set returns unchanged set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([1, 2]) - 5',
      );
      checkResult(runtime, {1, 2});
    });

    test('set stored in a variable', () {
      final RuntimeFacade runtime = getRuntime('''
foo(values) = [set_add(values, 1)]

main() = foo(set_new([2, 3]))
''');
      checkResult(runtime, [
        {2, 3, 1},
      ]);
    });

    test('set_add does not duplicate existing boolean element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_add(set_new([true, false]), true)',
      );
      checkResult(runtime, {true, false});
    });

    test('set_add adds boolean element to set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_add(set_new([1, 2]), true)',
      );
      checkResult(runtime, {1, 2, true});
    });

    test('set_remove removes string element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_remove(set_new(["a", "b", "c"]), "b")',
      );
      checkResult(runtime, {'"a"', '"c"'});
    });

    test('set_remove returns unchanged set when string element absent', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_remove(set_new(["a", "b"]), "z")',
      );
      checkResult(runtime, {'"a"', '"b"'});
    });

    test('set_contains returns true for existing string element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_contains(set_new(["apple", "banana"]), "banana")',
      );
      checkResult(runtime, true);
    });

    test('set_contains returns false for missing string element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_contains(set_new(["apple", "banana"]), "cherry")',
      );
      checkResult(runtime, false);
    });

    test('set_contains returns true for boolean element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_contains(set_new([true, false]), false)',
      );
      checkResult(runtime, true);
    });

    test('set_union of single-element sets', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_union(set_new([1]), set_new([2]))',
      );
      checkResult(runtime, {1, 2});
    });

    test('set_union of single-element set with itself', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_union(set_new([1]), set_new([1]))',
      );
      checkResult(runtime, {1});
    });

    test('set_intersection of single-element sets with common element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_intersection(set_new([1]), set_new([1]))',
      );
      checkResult(runtime, {1});
    });

    test('set_intersection returns multiple common elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_intersection(set_new([1, 2, 3, 4]), set_new([2, 3, 5]))',
      );
      checkResult(runtime, {2, 3});
    });

    test('set_intersection with single-element sets no overlap', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_intersection(set_new([1]), set_new([2]))',
      );
      checkResult(runtime, {});
    });

    test('set - set with single-element sets', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([1]) - set_new([1])',
      );
      checkResult(runtime, {});
    });

    test('set - string element removes element from set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new(["a", "b", "c"]) - "b"',
      );
      checkResult(runtime, {'"a"', '"c"'});
    });

    test('chained set_add operations', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_add(set_add(set_new([1]), 2), 3)',
      );
      checkResult(runtime, {1, 2, 3});
    });

    test('chained set_remove operations', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_remove(set_remove(set_new([1, 2, 3]), 1), 3)',
      );
      checkResult(runtime, {2});
    });

    test('set_add followed by set_remove', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_remove(set_add(set_new([1, 2]), 3), 2)',
      );
      checkResult(runtime, {1, 3});
    });

    test('set_remove followed by set_add', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_add(set_remove(set_new([1, 2]), 1), 3)',
      );
      checkResult(runtime, {2, 3});
    });

    test('set_isEmpty after removing all elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isEmpty(set_remove(set_new([1]), 1))',
      );
      checkResult(runtime, true);
    });

    test('set_isNotEmpty after adding to empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isNotEmpty(set_add(set_new([]), 1))',
      );
      checkResult(runtime, true);
    });

    test('set_length after add operation', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_length(set_add(set_new([1, 2]), 3))',
      );
      checkResult(runtime, 3);
    });

    test('set_length after remove operation', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_length(set_remove(set_new([1, 2, 3]), 2))',
      );
      checkResult(runtime, 2);
    });

    test('set_length unchanged when adding duplicate', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_length(set_add(set_new([1, 2]), 1))',
      );
      checkResult(runtime, 2);
    });

    test('set_length unchanged when removing non-existent element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_length(set_remove(set_new([1, 2]), 99))',
      );
      checkResult(runtime, 2);
    });

    test('set_contains after add operation', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_contains(set_add(set_new([1, 2]), 3), 3)',
      );
      checkResult(runtime, true);
    });

    test('set_contains returns false after remove operation', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_contains(set_remove(set_new([1, 2, 3]), 2), 2)',
      );
      checkResult(runtime, false);
    });

    test('set_union result with contains', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_contains(set_union(set_new([1, 2]), set_new([3, 4])), 3)',
      );
      checkResult(runtime, true);
    });

    test('set_intersection result with contains', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_contains(set_intersection(set_new([1, 2, 3]), set_new([2, 3, 4])), 2)',
      );
      checkResult(runtime, true);
    });

    test('set_difference result with contains', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_contains(set_difference(set_new([1, 2, 3]), set_new([2])), 1)',
      );
      checkResult(runtime, true);
    });

    test('set_difference result does not contain removed element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_contains(set_difference(set_new([1, 2, 3]), set_new([2])), 2)',
      );
      checkResult(runtime, false);
    });

    test('set_new with nested list elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_length(set_new([[1, 2], [3, 4]]))',
      );
      checkResult(runtime, 2);
    });

    test(
      'set_new with duplicate nested lists keeps all since lists are reference types',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = set_length(set_new([[1, 2], [1, 2], [3, 4]]))',
        );
        // Lists are reference types, so duplicate lists are not deduplicated
        checkResult(runtime, 3);
      },
    );

    test('set with float elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([1.5, 2.5, 3.5])',
      );
      checkResult(runtime, {1.5, 2.5, 3.5});
    });

    test('set with negative numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([-1, -2, 0, 1])',
      );
      checkResult(runtime, {-1, -2, 0, 1});
    });

    test('set_add with float element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_add(set_new([1, 2]), 2.5)',
      );
      checkResult(runtime, {1, 2, 2.5});
    });

    test('set_contains with float element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_contains(set_new([1.5, 2.5]), 1.5)',
      );
      checkResult(runtime, true);
    });

    test('set_remove with float element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_remove(set_new([1.5, 2.5, 3.5]), 2.5)',
      );
      checkResult(runtime, {1.5, 3.5});
    });

    test('set - operator with float element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([1.5, 2.5]) - 1.5',
      );
      checkResult(runtime, {2.5});
    });

    test('set_union with string sets', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_union(set_new(["a", "b"]), set_new(["b", "c"]))',
      );
      checkResult(runtime, {'"a"', '"b"', '"c"'});
    });

    test('set_intersection with string sets', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_intersection(set_new(["a", "b", "c"]), set_new(["b", "c", "d"]))',
      );
      checkResult(runtime, {'"b"', '"c"'});
    });

    test('set_difference with string sets', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_difference(set_new(["a", "b", "c"]), set_new(["b"]))',
      );
      checkResult(runtime, {'"a"', '"c"'});
    });

    test('set - set with string sets', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new(["a", "b", "c"]) - set_new(["a", "c"])',
      );
      checkResult(runtime, {'"b"'});
    });

    test('set_union with mixed type sets', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_union(set_new([1, "a"]), set_new([true, 2]))',
      );
      checkResult(runtime, {1, '"a"', true, 2});
    });

    test('set_intersection with mixed type sets no overlap', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_intersection(set_new([1, 2]), set_new(["a", "b"]))',
      );
      checkResult(runtime, {});
    });

    test('set + set performs set union', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([1, 2]) + set_new([2, 3])',
      );
      checkResult(runtime, {1, 2, 3});
    });

    test('set + element adds element to set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([1, 2]) + 3',
      );
      checkResult(runtime, {1, 2, 3});
    });

    test('element + set adds element to set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = 3 + set_new([1, 2])',
      );
      checkResult(runtime, {1, 2, 3});
    });

    test('set + element does not duplicate existing element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([1, 2]) + 2',
      );
      checkResult(runtime, {1, 2});
    });

    test('element + set does not duplicate existing element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = 2 + set_new([1, 2])',
      );
      checkResult(runtime, {1, 2});
    });

    test('set + set with empty first operand returns second set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([]) + set_new([1, 2])',
      );
      checkResult(runtime, {1, 2});
    });

    test('set + set with empty second operand returns first set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([1, 2]) + set_new([])',
      );
      checkResult(runtime, {1, 2});
    });

    test('set + set with two empty sets returns empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([]) + set_new([])',
      );
      checkResult(runtime, {});
    });

    test('set + element on empty set returns single-element set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([]) + 42',
      );
      checkResult(runtime, {42});
    });

    test('element + empty set returns single-element set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = 42 + set_new([])',
      );
      checkResult(runtime, {42});
    });

    test('set + string element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new(["a", "b"]) + "c"',
      );
      checkResult(runtime, {'"a"', '"b"', '"c"'});
    });

    test('string element + set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = "c" + set_new(["a", "b"])',
      );
      checkResult(runtime, {'"a"', '"b"', '"c"'});
    });

    test('set + boolean element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([1, 2]) + true',
      );
      checkResult(runtime, {1, 2, true});
    });

    test('boolean element + set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = true + set_new([1, 2])',
      );
      checkResult(runtime, {1, 2, true});
    });

    test('set + float element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([1, 2]) + 3.5',
      );
      checkResult(runtime, {1, 2, 3.5});
    });

    test('chained set + operations', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([1]) + 2 + 3',
      );
      checkResult(runtime, {1, 2, 3});
    });

    test('set + set with single-element sets', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([1]) + set_new([2])',
      );
      checkResult(runtime, {1, 2});
    });

    test('set with zero value', () {
      final RuntimeFacade runtime = getRuntime('main() = set_new([0, 1, 2])');
      checkResult(runtime, {0, 1, 2});
    });

    test('set_contains with zero value', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_contains(set_new([0, 1, 2]), 0)',
      );
      checkResult(runtime, true);
    });

    test('set_remove with zero value', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_remove(set_new([0, 1, 2]), 0)',
      );
      checkResult(runtime, {1, 2});
    });

    test('set with empty string element', () {
      final RuntimeFacade runtime = getRuntime('main() = set_new(["", "a"])');
      checkResult(runtime, {'""', '"a"'});
    });

    test('set_contains with empty string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_contains(set_new(["", "a"]), "")',
      );
      checkResult(runtime, true);
    });

    test('set_remove with empty string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_remove(set_new(["", "a", "b"]), "")',
      );
      checkResult(runtime, {'"a"', '"b"'});
    });

    test('set with negative float values', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([-1.5, -2.5, 0.0, 1.5])',
      );
      checkResult(runtime, {-1.5, -2.5, 0.0, 1.5});
    });

    test('set_union preserves order from first set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_length(set_union(set_new([1, 2, 3]), set_new([4, 5])))',
      );
      checkResult(runtime, 5);
    });

    test('set_intersection preserves elements from second set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_length(set_intersection(set_new([1, 2, 3, 4, 5]), set_new([2, 4])))',
      );
      checkResult(runtime, 2);
    });

    test('set_difference with partial overlap', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_difference(set_new([1, 2, 3, 4, 5]), set_new([2, 4, 6]))',
      );
      checkResult(runtime, {1, 3, 5});
    });

    test('is_set returns true for empty set', () {
      final RuntimeFacade runtime = getRuntime('main() = is_set(set_new([]))');
      checkResult(runtime, true);
    });

    test('is_set returns true for non-empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = is_set(set_new([1, 2, 3]))',
      );
      checkResult(runtime, true);
    });

    test('is_set returns false for list', () {
      final RuntimeFacade runtime = getRuntime('main() = is_set([1, 2, 3])');
      checkResult(runtime, false);
    });

    test('is_set returns false for number', () {
      final RuntimeFacade runtime = getRuntime('main() = is_set(42)');
      checkResult(runtime, false);
    });

    test('to_list converts set to list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = to_list(set_new([1, 2, 3]))',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('to_list converts empty set to empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = to_list(set_new([]))');
      checkResult(runtime, []);
    });

    test('set_length with large set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_length(set_new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]))',
      );
      checkResult(runtime, 20);
    });

    test('set operations preserve type after union', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = is_set(set_union(set_new([1]), set_new([2])))',
      );
      checkResult(runtime, true);
    });

    test('set operations preserve type after intersection', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = is_set(set_intersection(set_new([1, 2]), set_new([2, 3])))',
      );
      checkResult(runtime, true);
    });

    test('set operations preserve type after difference', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = is_set(set_difference(set_new([1, 2]), set_new([2])))',
      );
      checkResult(runtime, true);
    });

    test('set operations preserve type after add', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = is_set(set_add(set_new([1]), 2))',
      );
      checkResult(runtime, true);
    });

    test('set operations preserve type after remove', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = is_set(set_remove(set_new([1, 2]), 1))',
      );
      checkResult(runtime, true);
    });

    test('set + operator preserves type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = is_set(set_new([1]) + set_new([2]))',
      );
      checkResult(runtime, true);
    });

    test('set - operator preserves type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = is_set(set_new([1, 2]) - set_new([1]))',
      );
      checkResult(runtime, true);
    });

    test('complex set expression', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_length(set_union(set_difference(set_new([1, 2, 3, 4]), set_new([2, 4])), set_new([5, 6])))',
      );
      checkResult(runtime, 4);
    });

    test('set with all false booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([false, false, false])',
      );
      checkResult(runtime, {false});
    });

    test('set with all true booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([true, true, true])',
      );
      checkResult(runtime, {true});
    });

    test('set_add with list element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_length(set_add(set_new([1, 2]), [3, 4]))',
      );
      checkResult(runtime, 3);
    });

    test('set_contains with list element throws error', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_contains(set_new([1, 2]), [1, 2])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set - operator with single-element result', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([1, 2, 3]) - set_new([1, 3])',
      );
      checkResult(runtime, {2});
    });

    test('set_new deduplicates all elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_length(set_new([1, 1, 2, 2, 3, 3, 4, 4, 5, 5]))',
      );
      checkResult(runtime, 5);
    });
  });

  group('Set Type Errors', () {
    test('set_contains throws for non-set first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_contains([1, 2], 1)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_add throws for non-set first arg', () {
      final RuntimeFacade runtime = getRuntime('main() = set_add([1, 2], 3)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_remove throws for non-set first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_remove([1, 2], 1)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_length throws for non-set arg', () {
      final RuntimeFacade runtime = getRuntime('main() = set_length([1, 2])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_union throws for non-set first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_union([1, 2], set_new([3]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_difference throws for non-set first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_difference([1, 2], set_new([1]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_difference throws for non-set second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_difference(set_new([1, 2]), [1])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('element - set throws error', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = 5 - set_new([1, 5, 10])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_new throws for non-list arg', () {
      final RuntimeFacade runtime = getRuntime('main() = set_new(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_isEmpty throws for non-set arg', () {
      final RuntimeFacade runtime = getRuntime('main() = set_isEmpty([1, 2])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_isNotEmpty throws for non-set arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isNotEmpty([1, 2])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_union throws for non-set second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_union(set_new([1, 2]), [3])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_intersection throws for non-set first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_intersection([1, 2], set_new([1]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_intersection throws for non-set second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_intersection(set_new([1, 2]), [1])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_new throws for string arg', () {
      final RuntimeFacade runtime = getRuntime('main() = set_new("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_new throws for boolean arg', () {
      final RuntimeFacade runtime = getRuntime('main() = set_new(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_new throws for map arg', () {
      final RuntimeFacade runtime = getRuntime('main() = set_new({"a": 1})');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_length throws for string arg', () {
      final RuntimeFacade runtime = getRuntime('main() = set_length("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_length throws for number arg', () {
      final RuntimeFacade runtime = getRuntime('main() = set_length(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_length throws for boolean arg', () {
      final RuntimeFacade runtime = getRuntime('main() = set_length(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_length throws for map arg', () {
      final RuntimeFacade runtime = getRuntime('main() = set_length({"a": 1})');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_isEmpty throws for string arg', () {
      final RuntimeFacade runtime = getRuntime('main() = set_isEmpty("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_isEmpty throws for number arg', () {
      final RuntimeFacade runtime = getRuntime('main() = set_isEmpty(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_isEmpty throws for boolean arg', () {
      final RuntimeFacade runtime = getRuntime('main() = set_isEmpty(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_isEmpty throws for map arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isEmpty({"a": 1})',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_isNotEmpty throws for string arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isNotEmpty("hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_isNotEmpty throws for number arg', () {
      final RuntimeFacade runtime = getRuntime('main() = set_isNotEmpty(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_isNotEmpty throws for boolean arg', () {
      final RuntimeFacade runtime = getRuntime('main() = set_isNotEmpty(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_isNotEmpty throws for map arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isNotEmpty({"a": 1})',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_contains throws for string first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_contains("hello", "h")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_contains throws for number first arg', () {
      final RuntimeFacade runtime = getRuntime('main() = set_contains(42, 4)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_contains throws for boolean first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_contains(true, true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_contains throws for map first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_contains({"a": 1}, "a")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_add throws for string first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_add("hello", "x")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_add throws for number first arg', () {
      final RuntimeFacade runtime = getRuntime('main() = set_add(42, 1)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_add throws for boolean first arg', () {
      final RuntimeFacade runtime = getRuntime('main() = set_add(true, false)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_add throws for map first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_add({"a": 1}, "b")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_remove throws for string first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_remove("hello", "h")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_remove throws for number first arg', () {
      final RuntimeFacade runtime = getRuntime('main() = set_remove(42, 4)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_remove throws for boolean first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_remove(true, true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_remove throws for map first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_remove({"a": 1}, "a")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_union throws for string first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_union("hello", set_new([1]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_union throws for number first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_union(42, set_new([1]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_union throws for boolean first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_union(true, set_new([1]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_union throws for map first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_union({"a": 1}, set_new([1]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_union throws for string second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_union(set_new([1]), "hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_union throws for number second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_union(set_new([1]), 42)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_union throws for boolean second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_union(set_new([1]), true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_union throws for map second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_union(set_new([1]), {"a": 1})',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_intersection throws for string first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_intersection("hello", set_new([1]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_intersection throws for number first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_intersection(42, set_new([1]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_intersection throws for boolean first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_intersection(true, set_new([1]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_intersection throws for map first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_intersection({"a": 1}, set_new([1]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_intersection throws for string second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_intersection(set_new([1]), "hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_intersection throws for number second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_intersection(set_new([1]), 42)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_intersection throws for boolean second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_intersection(set_new([1]), true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_intersection throws for map second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_intersection(set_new([1]), {"a": 1})',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_difference throws for string first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_difference("hello", set_new([1]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_difference throws for number first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_difference(42, set_new([1]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_difference throws for boolean first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_difference(true, set_new([1]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_difference throws for map first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_difference({"a": 1}, set_new([1]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_difference throws for string second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_difference(set_new([1]), "hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_difference throws for number second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_difference(set_new([1]), 42)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_difference throws for boolean second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_difference(set_new([1]), true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_difference throws for map second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_difference(set_new([1]), {"a": 1})',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('string - set throws error', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = "hello" - set_new(["h"])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('boolean - set throws error', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = true - set_new([true])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list - set throws error', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = [1, 2] - set_new([1])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map - set throws error', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = {"a": 1} - set_new(["a"])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_new throws for set arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new(set_new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Set Equality', () {
    test('set == set returns true for identical empty sets', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([]) == set_new([])',
      );
      checkResult(runtime, true);
    });

    test('set == set returns true for identical non-empty sets', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([1, 2, 3]) == set_new([1, 2, 3])',
      );
      checkResult(runtime, true);
    });

    test('set == set returns true regardless of insertion order', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([1, 2, 3]) == set_new([3, 2, 1])',
      );
      checkResult(runtime, true);
    });

    test('set == set returns false for different sets', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([1, 2]) == set_new([1, 3])',
      );
      checkResult(runtime, false);
    });

    test('set == set returns false for different lengths', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([1, 2]) == set_new([1, 2, 3])',
      );
      checkResult(runtime, false);
    });

    test('set == set returns false when comparing empty and non-empty', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([]) == set_new([1])',
      );
      checkResult(runtime, false);
    });

    test('set != set returns false for identical sets', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([1, 2]) != set_new([1, 2])',
      );
      checkResult(runtime, false);
    });

    test('set != set returns true for different sets', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([1, 2]) != set_new([3, 4])',
      );
      checkResult(runtime, true);
    });

    test('set == set with string elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new(["a", "b"]) == set_new(["b", "a"])',
      );
      checkResult(runtime, true);
    });

    test('set == set with boolean elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([true, false]) == set_new([false, true])',
      );
      checkResult(runtime, true);
    });

    test('set == set with mixed type elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([1, "a", true]) == set_new([true, 1, "a"])',
      );
      checkResult(runtime, true);
    });

    test('set == set with single-element sets', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([42]) == set_new([42])',
      );
      checkResult(runtime, true);
    });

    test('set == set returns false for subset comparison', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([1, 2, 3]) == set_new([1, 2])',
      );
      checkResult(runtime, false);
    });

    test('set != set with empty sets', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([]) != set_new([])',
      );
      checkResult(runtime, false);
    });

    test('set equality after operations', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_add(set_new([1]), 2) == set_new([1, 2])',
      );
      checkResult(runtime, true);
    });

    test('set equality after union', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_union(set_new([1]), set_new([2])) == set_new([1, 2])',
      );
      checkResult(runtime, true);
    });

    test('set equality after intersection', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_intersection(set_new([1, 2, 3]), set_new([2, 3, 4])) == set_new([2, 3])',
      );
      checkResult(runtime, true);
    });

    test('set equality after difference', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_difference(set_new([1, 2, 3]), set_new([2])) == set_new([1, 3])',
      );
      checkResult(runtime, true);
    });

    test('set equality with float elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([1.5, 2.5]) == set_new([2.5, 1.5])',
      );
      checkResult(runtime, true);
    });

    test('set equality with negative numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([-1, -2, 0]) == set_new([0, -2, -1])',
      );
      checkResult(runtime, true);
    });
  });

  group('Set to_list Conversions', () {
    test('to_list converts single-element set to list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = to_list(set_new([42]))',
      );
      checkResult(runtime, [42]);
    });

    test('to_list converts set with string elements to list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = to_list(set_new(["a", "b"]))',
      );
      checkResult(runtime, ['"a"', '"b"']);
    });

    test('to_list converts set with boolean elements to list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = to_list(set_new([true, false]))',
      );
      checkResult(runtime, [true, false]);
    });

    test('to_list converts set with mixed elements to list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_length(to_list(set_new([1, "a", true])))',
      );
      checkResult(runtime, 3);
    });

    test('to_list result can be indexed', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = to_list(set_new([10, 20, 30]))[0]',
      );
      checkResult(runtime, 10);
    });

    test('to_list result length matches set length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_length(to_list(set_new([1, 2, 3, 4, 5])))',
      );
      checkResult(runtime, 5);
    });

    test('to_list throws for number arg', () {
      final RuntimeFacade runtime = getRuntime('main() = to_list(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('to_list throws for string arg', () {
      final RuntimeFacade runtime = getRuntime('main() = to_list("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('to_list throws for boolean arg', () {
      final RuntimeFacade runtime = getRuntime('main() = to_list(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('to_list throws for list arg', () {
      final RuntimeFacade runtime = getRuntime('main() = to_list([1, 2, 3])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('to_list throws for map arg', () {
      final RuntimeFacade runtime = getRuntime('main() = to_list({"a": 1})');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Set with Map Elements', () {
    test('set_new with map elements creates set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_length(set_new([{"a": 1}, {"b": 2}]))',
      );
      checkResult(runtime, 2);
    });

    test(
      'set with duplicate maps keeps all since maps are reference types',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = set_length(set_new([{"a": 1}, {"a": 1}]))',
        );
        // Maps are reference types, so duplicate maps are not deduplicated
        checkResult(runtime, 2);
      },
    );

    test('set_add with map element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_length(set_add(set_new([1, 2]), {"key": "value"}))',
      );
      checkResult(runtime, 3);
    });

    test('set_contains with map element throws error', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_contains(set_new([1, 2]), {"a": 1})',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_remove with map element throws error', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_remove(set_new([1, 2]), {"a": 1})',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Set Remove Edge Cases', () {
    test('set_remove with string element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_remove(set_new(["a", "b", "c"]), "b")',
      );
      checkResult(runtime, {'"a"', '"c"'});
    });

    test('set_remove with numeric element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_remove(set_new([1, 2, 3]), 2)',
      );
      checkResult(runtime, {1, 3});
    });

    test('set_remove with negative number', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_remove(set_new([-1, 0, 1]), -1)',
      );
      checkResult(runtime, {0, 1});
    });

    test('set_remove with zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_remove(set_new([0, 1, 2]), 0)',
      );
      checkResult(runtime, {1, 2});
    });

    test('set_remove with float element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_remove(set_new([1.5, 2.5, 3.5]), 2.5)',
      );
      checkResult(runtime, {1.5, 3.5});
    });

    test('set_remove with empty string element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_remove(set_new(["", "a", "b"]), "")',
      );
      checkResult(runtime, {'"a"', '"b"'});
    });

    test('set - operator with string element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new(["a", "b", "c"]) - "b"',
      );
      checkResult(runtime, {'"a"', '"c"'});
    });

    test('set - operator with negative number', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([-5, -3, 0, 3, 5]) - (-3)',
      );
      checkResult(runtime, {-5, 0, 3, 5});
    });
  });

  group('Set Add Edge Cases', () {
    test('set_add with negative number', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_add(set_new([1, 2]), -1)',
      );
      checkResult(runtime, {1, 2, -1});
    });

    test('set_add with zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_add(set_new([1, 2]), 0)',
      );
      checkResult(runtime, {1, 2, 0});
    });

    test('set_add with empty string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_add(set_new(["a", "b"]), "")',
      );
      checkResult(runtime, {'"a"', '"b"', '""'});
    });

    test('set_add does not duplicate zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_add(set_new([0, 1, 2]), 0)',
      );
      checkResult(runtime, {0, 1, 2});
    });

    test('set_add does not duplicate empty string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_add(set_new(["", "a"]), "")',
      );
      checkResult(runtime, {'""', '"a"'});
    });

    test('set_add does not duplicate negative number', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_add(set_new([-1, 0, 1]), -1)',
      );
      checkResult(runtime, {-1, 0, 1});
    });

    test('set + operator with zero element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([1, 2]) + 0',
      );
      checkResult(runtime, {1, 2, 0});
    });

    test('set + operator with negative number', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([1, 2]) + (-5)',
      );
      checkResult(runtime, {1, 2, -5});
    });

    test('set + operator with empty string', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new(["a"]) + ""',
      );
      checkResult(runtime, {'"a"', '""'});
    });
  });

  group('Set Contains Edge Cases', () {
    test('set_contains with negative number', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_contains(set_new([-1, 0, 1]), -1)',
      );
      checkResult(runtime, true);
    });

    test('set_contains returns false for non-existent element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_contains(set_new([1, 2, 3]), 4)',
      );
      checkResult(runtime, false);
    });

    test('set_contains with zero in set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_contains(set_new([0, 1, 2]), 0)',
      );
      checkResult(runtime, true);
    });

    test('set_contains with empty string in set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_contains(set_new(["", "a"]), "")',
      );
      checkResult(runtime, true);
    });

    test('set_contains with negative float', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_contains(set_new([-1.5, 0, 1.5]), -1.5)',
      );
      checkResult(runtime, true);
    });

    test('set_contains returns false for negative number not in set', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_contains(set_new([1, 2, 3]), -1)',
      );
      checkResult(runtime, false);
    });
  });

  group('Set Union Edge Cases', () {
    test('set_union with sets containing negative numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_union(set_new([-1, 0]), set_new([0, 1]))',
      );
      checkResult(runtime, {-1, 0, 1});
    });

    test('set_union with sets containing empty strings', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_union(set_new([""]), set_new(["a"]))',
      );
      checkResult(runtime, {'""', '"a"'});
    });

    test('set_union with sets containing zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_union(set_new([0]), set_new([1]))',
      );
      checkResult(runtime, {0, 1});
    });

    test('set + operator with sets containing negatives', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([-2, -1]) + set_new([0, 1])',
      );
      checkResult(runtime, {-2, -1, 0, 1});
    });
  });

  group('Set Intersection Edge Cases', () {
    test('set_intersection with sets containing negative numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_intersection(set_new([-1, 0, 1]), set_new([-1, 1]))',
      );
      checkResult(runtime, {-1, 1});
    });

    test('set_intersection with sets containing zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_intersection(set_new([0, 1, 2]), set_new([0, 2, 4]))',
      );
      checkResult(runtime, {0, 2});
    });

    test('set_intersection with sets containing empty strings', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_intersection(set_new(["", "a", "b"]), set_new(["", "b", "c"]))',
      );
      checkResult(runtime, {'""', '"b"'});
    });

    test('set_intersection with large overlap', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_intersection(set_new([1, 2, 3, 4, 5]), set_new([2, 3, 4, 5, 6]))',
      );
      checkResult(runtime, {2, 3, 4, 5});
    });

    test('set_intersection with all elements matching', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_intersection(set_new([1, 2, 3]), set_new([1, 2, 3, 4, 5]))',
      );
      checkResult(runtime, {1, 2, 3});
    });
  });

  group('Set Difference Edge Cases', () {
    test('set_difference with sets containing negative numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_difference(set_new([-2, -1, 0, 1]), set_new([-1, 1]))',
      );
      checkResult(runtime, {-2, 0});
    });

    test('set_difference with sets containing zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_difference(set_new([0, 1, 2, 3]), set_new([0, 2]))',
      );
      checkResult(runtime, {1, 3});
    });

    test('set_difference with sets containing empty strings', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_difference(set_new(["", "a", "b"]), set_new([""]))',
      );
      checkResult(runtime, {'"a"', '"b"'});
    });

    test('set - operator with negative numbers', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_new([-3, -2, -1, 0]) - set_new([-2, 0])',
      );
      checkResult(runtime, {-3, -1});
    });

    test('set_difference removes all when second set is superset', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_difference(set_new([1, 2]), set_new([1, 2, 3, 4, 5]))',
      );
      checkResult(runtime, {});
    });
  });

  group('Set Chained Operations', () {
    test('triple union operation', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_union(set_union(set_new([1]), set_new([2])), set_new([3]))',
      );
      checkResult(runtime, {1, 2, 3});
    });

    test('triple intersection operation', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_intersection(set_intersection(set_new([1, 2, 3, 4]), set_new([2, 3, 4, 5])), set_new([3, 4, 5, 6]))',
      );
      checkResult(runtime, {3, 4});
    });

    test('union followed by intersection', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_intersection(set_union(set_new([1, 2]), set_new([3, 4])), set_new([2, 3]))',
      );
      checkResult(runtime, {2, 3});
    });

    test('intersection followed by union', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_union(set_intersection(set_new([1, 2, 3]), set_new([2, 3, 4])), set_new([5]))',
      );
      checkResult(runtime, {2, 3, 5});
    });

    test('difference followed by union', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_union(set_difference(set_new([1, 2, 3]), set_new([2])), set_new([4]))',
      );
      checkResult(runtime, {1, 3, 4});
    });

    test('union followed by difference', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_difference(set_union(set_new([1, 2]), set_new([3, 4])), set_new([2, 4]))',
      );
      checkResult(runtime, {1, 3});
    });

    test('chained + and - operators', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = (set_new([1, 2]) + set_new([3, 4])) - set_new([2, 3])',
      );
      checkResult(runtime, {1, 4});
    });

    test('add followed by remove of same element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_remove(set_add(set_new([1, 2]), 3), 3)',
      );
      checkResult(runtime, {1, 2});
    });

    test('remove followed by add of same element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_add(set_remove(set_new([1, 2, 3]), 2), 2)',
      );
      checkResult(runtime, {1, 3, 2});
    });

    test('multiple add operations with duplicates', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_add(set_add(set_add(set_new([1]), 2), 2), 3)',
      );
      checkResult(runtime, {1, 2, 3});
    });

    test('multiple remove operations', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_remove(set_remove(set_remove(set_new([1, 2, 3, 4, 5]), 1), 3), 5)',
      );
      checkResult(runtime, {2, 4});
    });
  });

  group('Set Type Preservation', () {
    test('set_union result is a set type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = is_set(set_new([1]) + set_new([2]))',
      );
      checkResult(runtime, true);
    });

    test('set - element result is a set type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = is_set(set_new([1, 2, 3]) - 2)',
      );
      checkResult(runtime, true);
    });

    test('set - set result is a set type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = is_set(set_new([1, 2, 3]) - set_new([2]))',
      );
      checkResult(runtime, true);
    });

    test('set + element result is a set type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = is_set(set_new([1]) + 2)',
      );
      checkResult(runtime, true);
    });

    test('element + set result is a set type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = is_set(1 + set_new([2]))',
      );
      checkResult(runtime, true);
    });

    test('complex expression preserves set type', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = is_set(set_difference(set_union(set_new([1]), set_new([2])), set_new([1])))',
      );
      checkResult(runtime, true);
    });
  });

  group('is_set Edge Cases', () {
    test('is_set returns false for string', () {
      final RuntimeFacade runtime = getRuntime('main() = is_set("hello")');
      checkResult(runtime, false);
    });

    test('is_set returns false for boolean true', () {
      final RuntimeFacade runtime = getRuntime('main() = is_set(true)');
      checkResult(runtime, false);
    });

    test('is_set returns false for boolean false', () {
      final RuntimeFacade runtime = getRuntime('main() = is_set(false)');
      checkResult(runtime, false);
    });

    test('is_set returns false for empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = is_set([])');
      checkResult(runtime, false);
    });

    test('is_set returns false for empty map', () {
      final RuntimeFacade runtime = getRuntime('main() = is_set({})');
      checkResult(runtime, false);
    });

    test('is_set returns false for float', () {
      final RuntimeFacade runtime = getRuntime('main() = is_set(3.14)');
      checkResult(runtime, false);
    });

    test('is_set returns false for negative number', () {
      final RuntimeFacade runtime = getRuntime('main() = is_set(-42)');
      checkResult(runtime, false);
    });

    test('is_set returns false for zero', () {
      final RuntimeFacade runtime = getRuntime('main() = is_set(0)');
      checkResult(runtime, false);
    });

    test('is_set returns true after set operations', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = is_set(set_remove(set_add(set_new([1]), 2), 1))',
      );
      checkResult(runtime, true);
    });
  });

  group('Set isSubset', () {
    test('set_isSubset returns true when a is subset of b', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSubset(set_new([1, 2]), set_new([1, 2, 3]))',
      );
      checkResult(runtime, true);
    });

    test('set_isSubset returns true when sets are equal', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSubset(set_new([1, 2, 3]), set_new([1, 2, 3]))',
      );
      checkResult(runtime, true);
    });

    test('set_isSubset returns false when a is not subset of b', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSubset(set_new([1, 2, 4]), set_new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('set_isSubset returns true for empty set as first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSubset(set_new([]), set_new([1, 2, 3]))',
      );
      checkResult(runtime, true);
    });

    test('set_isSubset returns true when both sets are empty', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSubset(set_new([]), set_new([]))',
      );
      checkResult(runtime, true);
    });

    test(
      'set_isSubset returns false when second set is empty and first is not',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = set_isSubset(set_new([1]), set_new([]))',
        );
        checkResult(runtime, false);
      },
    );

    test('set_isSubset with single-element sets that match', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSubset(set_new([1]), set_new([1]))',
      );
      checkResult(runtime, true);
    });

    test('set_isSubset with single-element sets that differ', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSubset(set_new([1]), set_new([2]))',
      );
      checkResult(runtime, false);
    });

    test('set_isSubset with string elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSubset(set_new(["a"]), set_new(["a", "b"]))',
      );
      checkResult(runtime, true);
    });

    test('set_isSubset with boolean elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSubset(set_new([true]), set_new([true, false]))',
      );
      checkResult(runtime, true);
    });

    test('set_isSubset with mixed type elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSubset(set_new([1, "a"]), set_new([1, "a", true]))',
      );
      checkResult(runtime, true);
    });

    test('set_isSubset throws for non-set first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSubset([1, 2], set_new([1, 2, 3]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_isSubset throws for non-set second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSubset(set_new([1, 2]), [1, 2, 3])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_isSubset throws for number first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSubset(42, set_new([1]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_isSubset throws for string first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSubset("hello", set_new([1]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_isSubset throws for boolean first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSubset(true, set_new([1]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_isSubset throws for map first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSubset({"a": 1}, set_new([1]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_isSubset throws for number second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSubset(set_new([1]), 42)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_isSubset throws for string second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSubset(set_new([1]), "hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_isSubset throws for boolean second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSubset(set_new([1]), true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_isSubset throws for map second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSubset(set_new([1]), {"a": 1})',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Set isSuperset', () {
    test('set_isSuperset returns true when a is superset of b', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSuperset(set_new([1, 2, 3]), set_new([1, 2]))',
      );
      checkResult(runtime, true);
    });

    test('set_isSuperset returns true when sets are equal', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSuperset(set_new([1, 2, 3]), set_new([1, 2, 3]))',
      );
      checkResult(runtime, true);
    });

    test('set_isSuperset returns false when a is not superset of b', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSuperset(set_new([1, 2]), set_new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('set_isSuperset returns true for empty set as second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSuperset(set_new([1, 2, 3]), set_new([]))',
      );
      checkResult(runtime, true);
    });

    test('set_isSuperset returns true when both sets are empty', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSuperset(set_new([]), set_new([]))',
      );
      checkResult(runtime, true);
    });

    test(
      'set_isSuperset returns false when first set is empty and second is not',
      () {
        final RuntimeFacade runtime = getRuntime(
          'main() = set_isSuperset(set_new([]), set_new([1]))',
        );
        checkResult(runtime, false);
      },
    );

    test('set_isSuperset with single-element sets that match', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSuperset(set_new([1]), set_new([1]))',
      );
      checkResult(runtime, true);
    });

    test('set_isSuperset with single-element sets that differ', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSuperset(set_new([1]), set_new([2]))',
      );
      checkResult(runtime, false);
    });

    test('set_isSuperset with string elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSuperset(set_new(["a", "b"]), set_new(["a"]))',
      );
      checkResult(runtime, true);
    });

    test('set_isSuperset with boolean elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSuperset(set_new([true, false]), set_new([true]))',
      );
      checkResult(runtime, true);
    });

    test('set_isSuperset with mixed type elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSuperset(set_new([1, "a", true]), set_new([1, "a"]))',
      );
      checkResult(runtime, true);
    });

    test('set_isSuperset throws for non-set first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSuperset([1, 2, 3], set_new([1, 2]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_isSuperset throws for non-set second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSuperset(set_new([1, 2, 3]), [1, 2])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_isSuperset throws for number first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSuperset(42, set_new([1]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_isSuperset throws for string first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSuperset("hello", set_new([1]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_isSuperset throws for boolean first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSuperset(true, set_new([1]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_isSuperset throws for map first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSuperset({"a": 1}, set_new([1]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_isSuperset throws for number second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSuperset(set_new([1]), 42)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_isSuperset throws for string second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSuperset(set_new([1]), "hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_isSuperset throws for boolean second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSuperset(set_new([1]), true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_isSuperset throws for map second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSuperset(set_new([1]), {"a": 1})',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Set isDisjoint', () {
    test('set_isDisjoint returns true for disjoint sets', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isDisjoint(set_new([1, 2]), set_new([3, 4]))',
      );
      checkResult(runtime, true);
    });

    test('set_isDisjoint returns false for sets with common elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isDisjoint(set_new([1, 2, 3]), set_new([3, 4, 5]))',
      );
      checkResult(runtime, false);
    });

    test('set_isDisjoint returns false for identical sets', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isDisjoint(set_new([1, 2, 3]), set_new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('set_isDisjoint returns true when both sets are empty', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isDisjoint(set_new([]), set_new([]))',
      );
      checkResult(runtime, true);
    });

    test('set_isDisjoint returns true when first set is empty', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isDisjoint(set_new([]), set_new([1, 2, 3]))',
      );
      checkResult(runtime, true);
    });

    test('set_isDisjoint returns true when second set is empty', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isDisjoint(set_new([1, 2, 3]), set_new([]))',
      );
      checkResult(runtime, true);
    });

    test('set_isDisjoint with single-element disjoint sets', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isDisjoint(set_new([1]), set_new([2]))',
      );
      checkResult(runtime, true);
    });

    test('set_isDisjoint with single-element overlapping sets', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isDisjoint(set_new([1]), set_new([1]))',
      );
      checkResult(runtime, false);
    });

    test('set_isDisjoint with string elements disjoint', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isDisjoint(set_new(["a", "b"]), set_new(["c", "d"]))',
      );
      checkResult(runtime, true);
    });

    test('set_isDisjoint with string elements overlapping', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isDisjoint(set_new(["a", "b"]), set_new(["b", "c"]))',
      );
      checkResult(runtime, false);
    });

    test('set_isDisjoint with boolean elements disjoint', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isDisjoint(set_new([true]), set_new([false]))',
      );
      checkResult(runtime, true);
    });

    test('set_isDisjoint with boolean elements overlapping', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isDisjoint(set_new([true, false]), set_new([false]))',
      );
      checkResult(runtime, false);
    });

    test('set_isDisjoint with mixed type elements disjoint', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isDisjoint(set_new([1, "a"]), set_new([2, "b"]))',
      );
      checkResult(runtime, true);
    });

    test('set_isDisjoint with mixed type elements overlapping', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isDisjoint(set_new([1, "a"]), set_new([1, "b"]))',
      );
      checkResult(runtime, false);
    });

    test('set_isDisjoint is commutative', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isDisjoint(set_new([3, 4]), set_new([1, 2]))',
      );
      checkResult(runtime, true);
    });

    test('set_isDisjoint throws for non-set first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isDisjoint([1, 2], set_new([3, 4]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_isDisjoint throws for non-set second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isDisjoint(set_new([1, 2]), [3, 4])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_isDisjoint throws for number first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isDisjoint(42, set_new([1]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_isDisjoint throws for string first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isDisjoint("hello", set_new([1]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_isDisjoint throws for boolean first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isDisjoint(true, set_new([1]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_isDisjoint throws for map first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isDisjoint({"a": 1}, set_new([1]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_isDisjoint throws for number second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isDisjoint(set_new([1]), 42)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_isDisjoint throws for string second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isDisjoint(set_new([1]), "hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_isDisjoint throws for boolean second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isDisjoint(set_new([1]), true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set_isDisjoint throws for map second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isDisjoint(set_new([1]), {"a": 1})',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });

  group('Set Subset/Superset Relationship', () {
    test('isSubset and isSuperset are inverse for same sets', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = [set_isSubset(set_new([1, 2]), set_new([1, 2, 3])), set_isSuperset(set_new([1, 2, 3]), set_new([1, 2]))]',
      );
      checkResult(runtime, [true, true]);
    });

    test('isSubset and isSuperset with disjoint sets', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = [set_isSubset(set_new([1, 2]), set_new([3, 4])), set_isSuperset(set_new([3, 4]), set_new([1, 2]))]',
      );
      checkResult(runtime, [false, false]);
    });

    test('proper subset is not superset', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSuperset(set_new([1, 2]), set_new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('proper superset is not subset', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isSubset(set_new([1, 2, 3]), set_new([1, 2]))',
      );
      checkResult(runtime, false);
    });
  });

  group('Set Disjoint and Other Operations', () {
    test('disjoint sets have empty intersection', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = [set_isDisjoint(set_new([1, 2]), set_new([3, 4])), set_isEmpty(set_intersection(set_new([1, 2]), set_new([3, 4])))]',
      );
      checkResult(runtime, [true, true]);
    });

    test('non-disjoint sets have non-empty intersection', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = [set_isDisjoint(set_new([1, 2, 3]), set_new([3, 4])), set_isNotEmpty(set_intersection(set_new([1, 2, 3]), set_new([3, 4])))]',
      );
      checkResult(runtime, [false, true]);
    });

    test('subset of disjoint sets are also disjoint', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = set_isDisjoint(set_new([1]), set_new([3, 4]))',
      );
      checkResult(runtime, true);
    });
  });
}
