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
  });
}
