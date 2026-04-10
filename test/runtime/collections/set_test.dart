@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Set', () {
    test('set.new creates empty set from empty list', () {
      final RuntimeFacade runtime = getRuntime('main = set.new([])');
      checkResult(runtime, {});
    });

    test('set.new creates set from list with unique elements', () {
      final RuntimeFacade runtime = getRuntime('main = set.new([1, 2])');
      checkResult(runtime, {1, 2});
    });

    test('set.new creates single-element set', () {
      final RuntimeFacade runtime = getRuntime('main = set.new([42])');
      checkResult(runtime, {42});
    });

    test('set.new removes duplicates from list', () {
      final RuntimeFacade runtime = getRuntime('main = set.new([1, 2, 1])');
      checkResult(runtime, {1, 2});
    });

    test('set.new creates set with string elements', () {
      final RuntimeFacade runtime = getRuntime('main = set.new(["a", "b", "c"])');
      checkResult(runtime, {'"a"', '"b"', '"c"'});
    });

    test('set.new creates set with boolean elements', () {
      final RuntimeFacade runtime = getRuntime('main = set.new([true, false])');
      checkResult(runtime, {true, false});
    });

    test('set.new creates set with mixed element types', () {
      final RuntimeFacade runtime = getRuntime('main = set.new([1, "two", true])');
      checkResult(runtime, {1, '"two"', true});
    });

    test('set.new removes duplicate booleans', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.new([true, false, true])',
      );
      checkResult(runtime, {true, false});
    });

    test('set.add adds element to empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.add(set.new([]), 1)',
      );
      checkResult(runtime, {1});
    });

    test('set.add adds new element to non-empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.add(set.new([1, 2]), 3)',
      );
      checkResult(runtime, {1, 2, 3});
    });

    test('set.add does not duplicate existing element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.add(set.new([1, 2]), 2)',
      );
      checkResult(runtime, {1, 2});
    });

    test('set.add adds string element to set', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.add(set.new(["a", "b"]), "c")',
      );
      checkResult(runtime, {'"a"', '"b"', '"c"'});
    });

    test('set.add adds element to single-element set', () {
      final RuntimeFacade runtime = getRuntime('main = set.add(set.new([1]), 2)');
      checkResult(runtime, {1, 2});
    });

    test('set.remove on empty set returns empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.remove(set.new([]), 1)',
      );
      checkResult(runtime, {});
    });

    test('set.remove returns unchanged set when element absent', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.remove(set.new([1, 2]), 3)',
      );
      checkResult(runtime, {1, 2});
    });

    test('set.remove removes existing element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.remove(set.new([1, 2]), 2)',
      );
      checkResult(runtime, {1});
    });

    test('set.remove from single-element set returns empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.remove(set.new([1]), 1)',
      );
      checkResult(runtime, {});
    });

    test('set.contains returns true for existing element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.contains(set.new([1, 2, 3]), 2)',
      );
      checkResult(runtime, true);
    });

    test('set.contains returns false for missing element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.contains(set.new([1, 2]), 3)',
      );
      checkResult(runtime, false);
    });

    test('set.contains returns false for empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.contains(set.new([]), 1)',
      );
      checkResult(runtime, false);
    });

    test('set.contains returns true for single-element set', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.contains(set.new([42]), 42)',
      );
      checkResult(runtime, true);
    });

    test('set.contains returns false for single-element set when absent', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.contains(set.new([42]), 99)',
      );
      checkResult(runtime, false);
    });

    test('set.isEmpty returns true for empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.isEmpty(set.new([]))',
      );
      checkResult(runtime, true);
    });

    test('set.isEmpty returns false for non-empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.isEmpty(set.new([1, 2, 3]))',
      );
      checkResult(runtime, false);
    });

    test('set.isEmpty returns false for single-element set', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.isEmpty(set.new([42]))',
      );
      checkResult(runtime, false);
    });

    test('set.isNotEmpty returns false for empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.isNotEmpty(set.new([]))',
      );
      checkResult(runtime, false);
    });

    test('set.isNotEmpty returns true for non-empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.isNotEmpty(set.new([1, 2, 3]))',
      );
      checkResult(runtime, true);
    });

    test('set.isNotEmpty returns true for single-element set', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.isNotEmpty(set.new([42]))',
      );
      checkResult(runtime, true);
    });

    test('set.length returns zero for empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.length(set.new([]))',
      );
      checkResult(runtime, 0);
    });

    test('set.length returns element count for non-empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.length(set.new([1, 2, 3]))',
      );
      checkResult(runtime, 3);
    });

    test('set.length returns one for single-element set', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.length(set.new([42]))',
      );
      checkResult(runtime, 1);
    });

    test('set.union of two empty sets returns empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.union(set.new([]), set.new([]))',
      );
      checkResult(runtime, {});
    });

    test('set.union combines disjoint sets', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.union(set.new([1, 2]), set.new([3]))',
      );
      checkResult(runtime, {1, 2, 3});
    });

    test('set.union combines sets with smaller first operand', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.union(set.new([1]), set.new([2, 3]))',
      );
      checkResult(runtime, {1, 2, 3});
    });

    test('set.union with empty first operand returns second set', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.union(set.new([]), set.new([1, 2]))',
      );
      checkResult(runtime, {1, 2});
    });

    test('set.union with empty second operand returns first set', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.union(set.new([1, 2]), set.new([]))',
      );
      checkResult(runtime, {1, 2});
    });

    test('set.union merges overlapping sets without duplicates', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.union(set.new([1, 2]), set.new([2, 3]))',
      );
      checkResult(runtime, {1, 2, 3});
    });

    test('set.union with identical sets returns same set', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.union(set.new([1, 2]), set.new([1, 2]))',
      );
      checkResult(runtime, {1, 2});
    });

    test('set.intersection of two empty sets returns empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.intersection(set.new([]), set.new([]))',
      );
      checkResult(runtime, {});
    });

    test('set.intersection of disjoint sets returns empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.intersection(set.new([1]), set.new([2]))',
      );
      checkResult(runtime, {});
    });

    test('set.intersection returns common elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.intersection(set.new([1, 2]), set.new([2, 3]))',
      );
      checkResult(runtime, {2});
    });

    test('set.intersection is commutative', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.intersection(set.new([2, 3]), set.new([1, 2]))',
      );
      checkResult(runtime, {2});
    });

    test('set.intersection with empty first operand returns empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.intersection(set.new([]), set.new([1, 2]))',
      );
      checkResult(runtime, {});
    });

    test('set.intersection with empty second operand returns empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.intersection(set.new([1, 2]), set.new([]))',
      );
      checkResult(runtime, {});
    });

    test('set.intersection with identical sets returns same set', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.intersection(set.new([1, 2]), set.new([1, 2]))',
      );
      checkResult(runtime, {1, 2});
    });

    test('set.difference of two empty sets returns empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.difference(set.new([]), set.new([]))',
      );
      checkResult(runtime, {});
    });

    test('set.difference with empty second set returns first set', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.difference(set.new([1, 2]), set.new([]))',
      );
      checkResult(runtime, {1, 2});
    });

    test('set.difference with empty first set returns empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.difference(set.new([]), set.new([1, 2]))',
      );
      checkResult(runtime, {});
    });

    test('set.difference of disjoint sets returns first set', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.difference(set.new([1, 2]), set.new([3, 4]))',
      );
      checkResult(runtime, {1, 2});
    });

    test('set.difference removes common elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.difference(set.new([1, 2, 3]), set.new([2, 3]))',
      );
      checkResult(runtime, {1});
    });

    test('set.difference is not commutative', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.difference(set.new([2, 3]), set.new([1, 2, 3]))',
      );
      checkResult(runtime, {});
    });

    test('set.difference with identical sets returns empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.difference(set.new([1, 2, 3]), set.new([1, 2, 3]))',
      );
      checkResult(runtime, {});
    });

    test('set.difference with single-element sets', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.difference(set.new([1]), set.new([1]))',
      );
      checkResult(runtime, {});
    });

    test('set - set performs set difference', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.new([1, 2, 3]) - set.new([2])',
      );
      checkResult(runtime, {1, 3});
    });

    test('set - element removes element from set', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.new([1, 2, 3]) - 2',
      );
      checkResult(runtime, {1, 3});
    });

    test('set - element on empty set returns empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.new([]) - 1',
      );
      checkResult(runtime, {});
    });

    test('set - element when element not in set returns unchanged set', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.new([1, 2]) - 5',
      );
      checkResult(runtime, {1, 2});
    });

    test('set.variable', () {
      final RuntimeFacade runtime = getRuntime('''
foo(values) = [set.add(values, 1)]

main = foo(set.new([2, 3]))
''');
      checkResult(runtime, [
        {2, 3, 1},
      ]);
    });

    test('set.add does not duplicate existing boolean element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.add(set.new([true, false]), true)',
      );
      checkResult(runtime, {true, false});
    });

    test('set.add adds boolean element to set', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.add(set.new([1, 2]), true)',
      );
      checkResult(runtime, {1, 2, true});
    });

    test('set.remove removes string element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.remove(set.new(["a", "b", "c"]), "b")',
      );
      checkResult(runtime, {'"a"', '"c"'});
    });

    test('set.remove returns unchanged set when string element absent', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.remove(set.new(["a", "b"]), "z")',
      );
      checkResult(runtime, {'"a"', '"b"'});
    });

    test('set.contains returns true for existing string element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.contains(set.new(["apple", "banana"]), "banana")',
      );
      checkResult(runtime, true);
    });

    test('set.contains returns false for missing string element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.contains(set.new(["apple", "banana"]), "cherry")',
      );
      checkResult(runtime, false);
    });

    test('set.contains returns true for boolean element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.contains(set.new([true, false]), false)',
      );
      checkResult(runtime, true);
    });

    test('set.union of single-element sets', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.union(set.new([1]), set.new([2]))',
      );
      checkResult(runtime, {1, 2});
    });

    test('set.union of single-element set with itself', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.union(set.new([1]), set.new([1]))',
      );
      checkResult(runtime, {1});
    });

    test('set.intersection of single-element sets with common element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.intersection(set.new([1]), set.new([1]))',
      );
      checkResult(runtime, {1});
    });

    test('set.intersection returns multiple common elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.intersection(set.new([1, 2, 3, 4]), set.new([2, 3, 5]))',
      );
      checkResult(runtime, {2, 3});
    });

    test('set.intersection with single-element sets no overlap', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.intersection(set.new([1]), set.new([2]))',
      );
      checkResult(runtime, {});
    });

    test('set - set with single-element sets', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.new([1]) - set.new([1])',
      );
      checkResult(runtime, {});
    });

    test('set - string element removes element from set', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.new(["a", "b", "c"]) - "b"',
      );
      checkResult(runtime, {'"a"', '"c"'});
    });

    test('chained set.add operations', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.add(set.add(set.new([1]), 2), 3)',
      );
      checkResult(runtime, {1, 2, 3});
    });

    test('chained set.remove operations', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.remove(set.remove(set.new([1, 2, 3]), 1), 3)',
      );
      checkResult(runtime, {2});
    });

    test('set.add followed by set.remove', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.remove(set.add(set.new([1, 2]), 3), 2)',
      );
      checkResult(runtime, {1, 3});
    });

    test('set.remove followed by set.add', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.add(set.remove(set.new([1, 2]), 1), 3)',
      );
      checkResult(runtime, {2, 3});
    });

    test('set.isEmpty after removing all elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.isEmpty(set.remove(set.new([1]), 1))',
      );
      checkResult(runtime, true);
    });

    test('set.isNotEmpty after adding to empty set', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.isNotEmpty(set.add(set.new([]), 1))',
      );
      checkResult(runtime, true);
    });

    test('set.length after add operation', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.length(set.add(set.new([1, 2]), 3))',
      );
      checkResult(runtime, 3);
    });

    test('set.length after remove operation', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.length(set.remove(set.new([1, 2, 3]), 2))',
      );
      checkResult(runtime, 2);
    });

    test('set.length unchanged when adding duplicate', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.length(set.add(set.new([1, 2]), 1))',
      );
      checkResult(runtime, 2);
    });

    test('set.length unchanged when removing non-existent element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.length(set.remove(set.new([1, 2]), 99))',
      );
      checkResult(runtime, 2);
    });

    test('set.contains after add operation', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.contains(set.add(set.new([1, 2]), 3), 3)',
      );
      checkResult(runtime, true);
    });

    test('set.contains returns false after remove operation', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.contains(set.remove(set.new([1, 2, 3]), 2), 2)',
      );
      checkResult(runtime, false);
    });

    test('set.union result with contains', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.contains(set.union(set.new([1, 2]), set.new([3, 4])), 3)',
      );
      checkResult(runtime, true);
    });

    test('set.intersection result with contains', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.contains(set.intersection(set.new([1, 2, 3]), set.new([2, 3, 4])), 2)',
      );
      checkResult(runtime, true);
    });

    test('set.difference result with contains', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.contains(set.difference(set.new([1, 2, 3]), set.new([2])), 1)',
      );
      checkResult(runtime, true);
    });

    test('set.difference result does not contain removed element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.contains(set.difference(set.new([1, 2, 3]), set.new([2])), 2)',
      );
      checkResult(runtime, false);
    });

    test('set.new with nested list elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.length(set.new([[1, 2], [3, 4]]))',
      );
      checkResult(runtime, 2);
    });

    test('set.new with duplicate nested lists keeps all since lists are reference types', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.length(set.new([[1, 2], [1, 2], [3, 4]]))',
      );
      // Lists are reference types, so duplicate lists are not deduplicated
      checkResult(runtime, 3);
    });

    test('set with float elements', () {
      final RuntimeFacade runtime = getRuntime('main = set.new([1.5, 2.5, 3.5])');
      checkResult(runtime, {1.5, 2.5, 3.5});
    });

    test('set with negative numbers', () {
      final RuntimeFacade runtime = getRuntime('main = set.new([-1, -2, 0, 1])');
      checkResult(runtime, {-1, -2, 0, 1});
    });

    test('set.add with float element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.add(set.new([1, 2]), 2.5)',
      );
      checkResult(runtime, {1, 2, 2.5});
    });

    test('set.contains with float element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.contains(set.new([1.5, 2.5]), 1.5)',
      );
      checkResult(runtime, true);
    });

    test('set.remove with float element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.remove(set.new([1.5, 2.5, 3.5]), 2.5)',
      );
      checkResult(runtime, {1.5, 3.5});
    });

    test('set - operator with float element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.new([1.5, 2.5]) - 1.5',
      );
      checkResult(runtime, {2.5});
    });

    test('set.union with string sets', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.union(set.new(["a", "b"]), set.new(["b", "c"]))',
      );
      checkResult(runtime, {'"a"', '"b"', '"c"'});
    });

    test('set.intersection with string sets', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.intersection(set.new(["a", "b", "c"]), set.new(["b", "c", "d"]))',
      );
      checkResult(runtime, {'"b"', '"c"'});
    });

    test('set.difference with string sets', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.difference(set.new(["a", "b", "c"]), set.new(["b"]))',
      );
      checkResult(runtime, {'"a"', '"c"'});
    });

    test('set - set with string sets', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.new(["a", "b", "c"]) - set.new(["a", "c"])',
      );
      checkResult(runtime, {'"b"'});
    });

    test('set.union with mixed type sets', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.union(set.new([1, "a"]), set.new([true, 2]))',
      );
      checkResult(runtime, {1, '"a"', true, 2});
    });

    test('set.intersection with mixed type sets no overlap', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.intersection(set.new([1, 2]), set.new(["a", "b"]))',
      );
      checkResult(runtime, {});
    });
  });

  group('Set Type Errors', () {
    test('set.contains throws for non-set first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.contains([1, 2], 1)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.add throws for non-set first arg', () {
      final RuntimeFacade runtime = getRuntime('main = set.add([1, 2], 3)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.remove throws for non-set first arg', () {
      final RuntimeFacade runtime = getRuntime('main = set.remove([1, 2], 1)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.length throws for non-set arg', () {
      final RuntimeFacade runtime = getRuntime('main = set.length([1, 2])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.union throws for non-set first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.union([1, 2], set.new([3]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.difference throws for non-set first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.difference([1, 2], set.new([1]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.difference throws for non-set second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.difference(set.new([1, 2]), [1])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('element - set throws error', () {
      final RuntimeFacade runtime = getRuntime(
        'main = 5 - set.new([1, 5, 10])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.new throws for non-list arg', () {
      final RuntimeFacade runtime = getRuntime('main = set.new(5)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.isEmpty throws for non-set arg', () {
      final RuntimeFacade runtime = getRuntime('main = set.isEmpty([1, 2])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.isNotEmpty throws for non-set arg', () {
      final RuntimeFacade runtime = getRuntime('main = set.isNotEmpty([1, 2])');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.union throws for non-set second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.union(set.new([1, 2]), [3])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.intersection throws for non-set first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.intersection([1, 2], set.new([1]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.intersection throws for non-set second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.intersection(set.new([1, 2]), [1])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.new throws for string arg', () {
      final RuntimeFacade runtime = getRuntime('main = set.new("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.new throws for boolean arg', () {
      final RuntimeFacade runtime = getRuntime('main = set.new(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.new throws for map arg', () {
      final RuntimeFacade runtime = getRuntime('main = set.new({"a": 1})');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.length throws for string arg', () {
      final RuntimeFacade runtime = getRuntime('main = set.length("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.length throws for number arg', () {
      final RuntimeFacade runtime = getRuntime('main = set.length(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.length throws for boolean arg', () {
      final RuntimeFacade runtime = getRuntime('main = set.length(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.length throws for map arg', () {
      final RuntimeFacade runtime = getRuntime('main = set.length({"a": 1})');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.isEmpty throws for string arg', () {
      final RuntimeFacade runtime = getRuntime('main = set.isEmpty("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.isEmpty throws for number arg', () {
      final RuntimeFacade runtime = getRuntime('main = set.isEmpty(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.isEmpty throws for boolean arg', () {
      final RuntimeFacade runtime = getRuntime('main = set.isEmpty(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.isEmpty throws for map arg', () {
      final RuntimeFacade runtime = getRuntime('main = set.isEmpty({"a": 1})');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.isNotEmpty throws for string arg', () {
      final RuntimeFacade runtime = getRuntime('main = set.isNotEmpty("hello")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.isNotEmpty throws for number arg', () {
      final RuntimeFacade runtime = getRuntime('main = set.isNotEmpty(42)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.isNotEmpty throws for boolean arg', () {
      final RuntimeFacade runtime = getRuntime('main = set.isNotEmpty(true)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.isNotEmpty throws for map arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.isNotEmpty({"a": 1})',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.contains throws for string first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.contains("hello", "h")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.contains throws for number first arg', () {
      final RuntimeFacade runtime = getRuntime('main = set.contains(42, 4)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.contains throws for boolean first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.contains(true, true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.contains throws for map first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.contains({"a": 1}, "a")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.add throws for string first arg', () {
      final RuntimeFacade runtime = getRuntime('main = set.add("hello", "x")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.add throws for number first arg', () {
      final RuntimeFacade runtime = getRuntime('main = set.add(42, 1)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.add throws for boolean first arg', () {
      final RuntimeFacade runtime = getRuntime('main = set.add(true, false)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.add throws for map first arg', () {
      final RuntimeFacade runtime = getRuntime('main = set.add({"a": 1}, "b")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.remove throws for string first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.remove("hello", "h")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.remove throws for number first arg', () {
      final RuntimeFacade runtime = getRuntime('main = set.remove(42, 4)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.remove throws for boolean first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.remove(true, true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.remove throws for map first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.remove({"a": 1}, "a")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.union throws for string first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.union("hello", set.new([1]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.union throws for number first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.union(42, set.new([1]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.union throws for boolean first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.union(true, set.new([1]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.union throws for map first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.union({"a": 1}, set.new([1]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.union throws for string second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.union(set.new([1]), "hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.union throws for number second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.union(set.new([1]), 42)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.union throws for boolean second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.union(set.new([1]), true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.union throws for map second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.union(set.new([1]), {"a": 1})',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.intersection throws for string first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.intersection("hello", set.new([1]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.intersection throws for number first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.intersection(42, set.new([1]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.intersection throws for boolean first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.intersection(true, set.new([1]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.intersection throws for map first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.intersection({"a": 1}, set.new([1]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.intersection throws for string second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.intersection(set.new([1]), "hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.intersection throws for number second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.intersection(set.new([1]), 42)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.intersection throws for boolean second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.intersection(set.new([1]), true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.intersection throws for map second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.intersection(set.new([1]), {"a": 1})',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.difference throws for string first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.difference("hello", set.new([1]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.difference throws for number first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.difference(42, set.new([1]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.difference throws for boolean first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.difference(true, set.new([1]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.difference throws for map first arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.difference({"a": 1}, set.new([1]))',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.difference throws for string second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.difference(set.new([1]), "hello")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.difference throws for number second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.difference(set.new([1]), 42)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.difference throws for boolean second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.difference(set.new([1]), true)',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('set.difference throws for map second arg', () {
      final RuntimeFacade runtime = getRuntime(
        'main = set.difference(set.new([1]), {"a": 1})',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('string - set throws error', () {
      final RuntimeFacade runtime = getRuntime(
        'main = "hello" - set.new(["h"])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('boolean - set throws error', () {
      final RuntimeFacade runtime = getRuntime(
        'main = true - set.new([true])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('list - set throws error', () {
      final RuntimeFacade runtime = getRuntime(
        'main = [1, 2] - set.new([1])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('map - set throws error', () {
      final RuntimeFacade runtime = getRuntime(
        'main = {"a": 1} - set.new(["a"])',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });
}
