@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';

import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Empty Collection Operations', () {
    test('list_first empty throws', () {
      final RuntimeFacade runtime = getRuntime('main() = list_first([])');
      expect(runtime.executeMain, throwsA(isA<EmptyCollectionError>()));
    });

    test('list_last empty throws', () {
      final RuntimeFacade runtime = getRuntime('main() = list_last([])');
      expect(runtime.executeMain, throwsA(isA<EmptyCollectionError>()));
    });

    test('list_init empty returns empty', () {
      final RuntimeFacade runtime = getRuntime('main() = list_init([])');
      checkResult(runtime, []);
    });

    test('str_first empty throws', () {
      final RuntimeFacade runtime = getRuntime('main() = str_first("")');
      expect(runtime.executeMain, throwsA(isA<EmptyCollectionError>()));
    });

    test('str_last empty throws', () {
      final RuntimeFacade runtime = getRuntime('main() = str_last("")');
      expect(runtime.executeMain, throwsA(isA<EmptyCollectionError>()));
    });

    test('str_init empty returns empty', () {
      final RuntimeFacade runtime = getRuntime('main() = str_init("")');
      checkResult(runtime, '""');
    });

    test('list_at empty throws', () {
      final RuntimeFacade runtime = getRuntime('main() = list_at([], 0)');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('str_at empty throws', () {
      final RuntimeFacade runtime = getRuntime('main() = str_at("", 0)');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });
  });

  group('Out of Bounds', () {
    test('list indexing out of bounds', () {
      final RuntimeFacade runtime = getRuntime('main() = [1, 2, 3][5]');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('string indexing out of bounds', () {
      final RuntimeFacade runtime = getRuntime('main() = "Hello"[10]');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list_at out of bounds', () {
      final RuntimeFacade runtime = getRuntime('main() = list_at([1, 2], 5)');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('str_at out of bounds', () {
      final RuntimeFacade runtime = getRuntime('main() = str_at("Hi", 5)');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list_removeAt out of bounds', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_removeAt([1, 2], 5)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list_swap out of bounds', () {
      final RuntimeFacade runtime = getRuntime('main() = list_swap([1], 0, 5)');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list_sublist out of bounds', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sublist([1, 2], 0, 10)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('str_substring out of bounds', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_substring("Hi", 0, 10)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list negative index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_at([1, 2, 3], -1)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });

    test('str_removeAt out of bounds', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_removeAt("Hi", 5)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('str_removeAt negative index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_removeAt("Hi", -1)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });

    test('list_removeAt negative index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_removeAt([1, 2], -1)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });

    test('list_swap negative first index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_swap([1, 2], -1, 0)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });

    test('list_swap negative second index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_swap([1, 2], 0, -1)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });

    test('list_swap first index out of bounds', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_swap([1, 2], 5, 0)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list_set negative index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_set([1, 2], -1, 99)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });

    test('list_set out of bounds index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_set([1, 2], 10, 99)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list_set index equal to length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_set([1, 2], 2, 99)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list_set empty list at index 0', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_set([], 0, 99)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list_set empty list at index 1', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_set([], 1, 99)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list_set single element list at index 1', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_set([1], 1, 99)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list_sublist negative start index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sublist([1, 2, 3], -1, 2)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });

    test('list_sublist end less than start', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sublist([1, 2, 3], 2, 1)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list_sublist start greater than length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sublist([1, 2, 3], 10, 12)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('str_take negative count', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_take("Hello", -1)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });

    test('str_drop negative count', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_drop("Hello", -1)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });

    test('str_substring negative start', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_substring("Hello", -1, 3)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });

    test('str_substring end less than start', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_substring("Hello", 3, 1)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('str_at negative index', () {
      final RuntimeFacade runtime = getRuntime('main() = str_at("Hello", -1)');
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });

    test('str_substring start greater than length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_substring("Hi", 5, 6)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('str_removeAt on empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = str_removeAt("", 0)');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list_removeAt on empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = list_removeAt([], 0)');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list_at index equal to length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_at([1, 2, 3], 3)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('str_at index equal to length', () {
      final RuntimeFacade runtime = getRuntime('main() = str_at("abc", 3)');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list_swap on empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = list_swap([], 0, 0)');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list_swap on single element list with out of bounds', () {
      final RuntimeFacade runtime = getRuntime('main() = list_swap([1], 0, 1)');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('map_at on empty map', () {
      final RuntimeFacade runtime = getRuntime('main() = map_at({}, "key")');
      expect(runtime.executeMain, throwsA(isA<InvalidMapIndexError>()));
    });

    test('map_at non-existent key', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = map_at({"a": 1}, "b")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidMapIndexError>()));
    });

    test('list_sublist negative end index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sublist([1, 2, 3], 0, -1)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('str_substring negative end index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_substring("Hello", 0, -1)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list_take negative count', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_take([1, 2], -1)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });

    test('list_drop negative count', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_drop([1, 2], -1)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });
  });

  group('Boundary Value Operations', () {
    test('list_sublist empty list returns empty', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sublist([], 0, 0)',
      );
      checkResult(runtime, []);
    });

    test('str_substring empty string returns empty', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_substring("", 0, 0)',
      );
      checkResult(runtime, '""');
    });

    test('str_init single character returns empty', () {
      final RuntimeFacade runtime = getRuntime('main() = str_init("a")');
      checkResult(runtime, '""');
    });

    test('str_rest single character returns empty', () {
      final RuntimeFacade runtime = getRuntime('main() = str_rest("a")');
      checkResult(runtime, '""');
    });

    test('list_init single element returns empty', () {
      final RuntimeFacade runtime = getRuntime('main() = list_init([1])');
      checkResult(runtime, []);
    });

    test('list_rest single element returns empty', () {
      final RuntimeFacade runtime = getRuntime('main() = list_rest([1])');
      checkResult(runtime, []);
    });

    test('list_sublist end equal to length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sublist([1, 2, 3], 1, 3)',
      );
      checkResult(runtime, [2, 3]);
    });

    test('str_substring end equal to length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_substring("Hello", 2, 5)',
      );
      checkResult(runtime, '"llo"');
    });

    test('list_sublist start equal to length returns empty', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_sublist([1, 2, 3], 3, 3)',
      );
      checkResult(runtime, []);
    });

    test('str_substring start equal to length returns empty', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_substring("Hi", 2, 2)',
      );
      checkResult(runtime, '""');
    });

    test('list_take count equal to length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_take([1, 2, 3], 3)',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('str_take count equal to length', () {
      final RuntimeFacade runtime = getRuntime('main() = str_take("abc", 3)');
      checkResult(runtime, '"abc"');
    });

    test('list_drop count equal to length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_drop([1, 2, 3], 3)',
      );
      checkResult(runtime, []);
    });

    test('str_drop count equal to length', () {
      final RuntimeFacade runtime = getRuntime('main() = str_drop("abc", 3)');
      checkResult(runtime, '""');
    });

    test('list_take exceeds length clamps to length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_take([1, 2], 10)',
      );
      checkResult(runtime, [1, 2]);
    });

    test('str_take exceeds length clamps to length', () {
      final RuntimeFacade runtime = getRuntime('main() = str_take("ab", 10)');
      checkResult(runtime, '"ab"');
    });

    test('list_drop exceeds length returns empty', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_drop([1, 2], 10)',
      );
      checkResult(runtime, []);
    });

    test('str_drop exceeds length returns empty', () {
      final RuntimeFacade runtime = getRuntime('main() = str_drop("ab", 10)');
      checkResult(runtime, '""');
    });

    test('list_removeAt first element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_removeAt([1, 2, 3], 0)',
      );
      checkResult(runtime, [2, 3]);
    });

    test('list_removeAt last element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_removeAt([1, 2, 3], 2)',
      );
      checkResult(runtime, [1, 2]);
    });

    test('str_removeAt first character', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_removeAt("abc", 0)',
      );
      checkResult(runtime, '"bc"');
    });

    test('str_removeAt last character', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_removeAt("abc", 2)',
      );
      checkResult(runtime, '"ab"');
    });

    test('list_swap first and last elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_swap([1, 2, 3], 0, 2)',
      );
      checkResult(runtime, [3, 2, 1]);
    });

    test('list_swap same index returns unchanged', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_swap([1, 2, 3], 1, 1)',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('list_set at first index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_set([1, 2, 3], 0, 99)',
      );
      checkResult(runtime, [99, 2, 3]);
    });

    test('list_set at last index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_set([1, 2, 3], 2, 99)',
      );
      checkResult(runtime, [1, 2, 99]);
    });

    test('list_first single element', () {
      final RuntimeFacade runtime = getRuntime('main() = list_first([42])');
      checkResult(runtime, 42);
    });

    test('list_last single element', () {
      final RuntimeFacade runtime = getRuntime('main() = list_last([42])');
      checkResult(runtime, 42);
    });

    test('str_first single character', () {
      final RuntimeFacade runtime = getRuntime('main() = str_first("x")');
      checkResult(runtime, '"x"');
    });

    test('str_last single character', () {
      final RuntimeFacade runtime = getRuntime('main() = str_last("x")');
      checkResult(runtime, '"x"');
    });
  });

  group('Empty List Operations', () {
    test('list_rest empty returns empty', () {
      final RuntimeFacade runtime = getRuntime('main() = list_rest([])');
      checkResult(runtime, []);
    });

    test('list_reverse empty returns empty', () {
      final RuntimeFacade runtime = getRuntime('main() = list_reverse([])');
      checkResult(runtime, []);
    });

    test('list_concat two empty lists', () {
      final RuntimeFacade runtime = getRuntime('main() = list_concat([], [])');
      checkResult(runtime, []);
    });

    test('list_concat empty with non-empty', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_concat([], [1, 2])',
      );
      checkResult(runtime, [1, 2]);
    });

    test('list_concat non-empty with empty', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_concat([1, 2], [])',
      );
      checkResult(runtime, [1, 2]);
    });

    test('list_indexOf empty list returns negative one', () {
      final RuntimeFacade runtime = getRuntime('main() = list_indexOf([], 1)');
      checkResult(runtime, -1);
    });

    test('list_indexOf element not found returns negative one', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_indexOf([1, 2, 3], 5)',
      );
      checkResult(runtime, -1);
    });

    test('list_contains empty list returns false', () {
      final RuntimeFacade runtime = getRuntime('main() = list_contains([], 1)');
      checkResult(runtime, false);
    });

    test('list_contains element not in list returns false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_contains([1, 2, 3], 5)',
      );
      checkResult(runtime, false);
    });

    test('list_remove empty list returns empty', () {
      final RuntimeFacade runtime = getRuntime('main() = list_remove([], 1)');
      checkResult(runtime, []);
    });

    test('list_remove element not found returns unchanged', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_remove([1, 2, 3], 5)',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('list_insertStart empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_insertStart([], 1)',
      );
      checkResult(runtime, [1]);
    });

    test('list_insertEnd empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_insertEnd([], 1)',
      );
      checkResult(runtime, [1]);
    });

    test('list_join empty list returns empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = list_join([], ", ")');
      checkResult(runtime, '""');
    });

    test('list_join single element list', () {
      final RuntimeFacade runtime = getRuntime('main() = list_join([1], ", ")');
      checkResult(runtime, '"1"');
    });

    test('list_isEmpty empty list returns true', () {
      final RuntimeFacade runtime = getRuntime('main() = list_isEmpty([])');
      checkResult(runtime, true);
    });

    test('list_isEmpty non-empty list returns false', () {
      final RuntimeFacade runtime = getRuntime('main() = list_isEmpty([1])');
      checkResult(runtime, false);
    });

    test('list_isNotEmpty empty list returns false', () {
      final RuntimeFacade runtime = getRuntime('main() = list_isNotEmpty([])');
      checkResult(runtime, false);
    });

    test('list_isNotEmpty non-empty list returns true', () {
      final RuntimeFacade runtime = getRuntime('main() = list_isNotEmpty([1])');
      checkResult(runtime, true);
    });

    test('list_length empty list returns zero', () {
      final RuntimeFacade runtime = getRuntime('main() = list_length([])');
      checkResult(runtime, 0);
    });

    test('list_take zero count returns empty', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_take([1, 2, 3], 0)',
      );
      checkResult(runtime, []);
    });

    test('list_drop zero count returns unchanged', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_drop([1, 2, 3], 0)',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('list_take empty list returns empty', () {
      final RuntimeFacade runtime = getRuntime('main() = list_take([], 5)');
      checkResult(runtime, []);
    });

    test('list_drop empty list returns empty', () {
      final RuntimeFacade runtime = getRuntime('main() = list_drop([], 5)');
      checkResult(runtime, []);
    });

    test('list_reverse single element', () {
      final RuntimeFacade runtime = getRuntime('main() = list_reverse([42])');
      checkResult(runtime, [42]);
    });
  });

  group('List Filled Boundary Cases', () {
    test('list_filled zero count returns empty', () {
      final RuntimeFacade runtime = getRuntime('main() = list_filled(0, 1)');
      checkResult(runtime, []);
    });

    test('list_filled negative count throws', () {
      final RuntimeFacade runtime = getRuntime('main() = list_filled(-1, 1)');
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });

    test('list_filled single element', () {
      final RuntimeFacade runtime = getRuntime('main() = list_filled(1, 42)');
      checkResult(runtime, [42]);
    });
  });

  group('Empty String Operations', () {
    test('str_rest empty returns empty', () {
      final RuntimeFacade runtime = getRuntime('main() = str_rest("")');
      checkResult(runtime, '""');
    });

    test('str_reverse empty returns empty', () {
      final RuntimeFacade runtime = getRuntime('main() = str_reverse("")');
      checkResult(runtime, '""');
    });

    test('str_reverse single character', () {
      final RuntimeFacade runtime = getRuntime('main() = str_reverse("a")');
      checkResult(runtime, '"a"');
    });

    test('str_indexOf empty string returns negative one', () {
      final RuntimeFacade runtime = getRuntime('main() = str_indexOf("", "a")');
      checkResult(runtime, -1);
    });

    test('str_indexOf substring not found returns negative one', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_indexOf("hello", "xyz")',
      );
      checkResult(runtime, -1);
    });

    test('str_indexOf empty substring returns zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_indexOf("hello", "")',
      );
      checkResult(runtime, 0);
    });

    test('str_concat two empty strings', () {
      final RuntimeFacade runtime = getRuntime('main() = str_concat("", "")');
      checkResult(runtime, '""');
    });

    test('str_concat empty with non-empty', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_concat("", "hello")',
      );
      checkResult(runtime, '"hello"');
    });

    test('str_concat non-empty with empty', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_concat("hello", "")',
      );
      checkResult(runtime, '"hello"');
    });

    test('str_contains empty string in non-empty returns true', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_contains("hello", "")',
      );
      checkResult(runtime, true);
    });

    test('str_contains substring not found returns false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_contains("hello", "xyz")',
      );
      checkResult(runtime, false);
    });

    test('str_contains empty string in empty returns true', () {
      final RuntimeFacade runtime = getRuntime('main() = str_contains("", "")');
      checkResult(runtime, true);
    });

    test('str_startsWith empty prefix returns true', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_startsWith("hello", "")',
      );
      checkResult(runtime, true);
    });

    test('str_startsWith empty string with empty prefix returns true', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_startsWith("", "")',
      );
      checkResult(runtime, true);
    });

    test('str_startsWith empty string with non-empty prefix returns false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_startsWith("", "a")',
      );
      checkResult(runtime, false);
    });

    test('str_endsWith empty suffix returns true', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_endsWith("hello", "")',
      );
      checkResult(runtime, true);
    });

    test('str_endsWith empty string with empty suffix returns true', () {
      final RuntimeFacade runtime = getRuntime('main() = str_endsWith("", "")');
      checkResult(runtime, true);
    });

    test('str_endsWith empty string with non-empty suffix returns false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_endsWith("", "a")',
      );
      checkResult(runtime, false);
    });

    test(
      'str_split empty string with non-empty separator returns list with empty string',
      () {
        final RuntimeFacade runtime = getRuntime('main() = str_split("", ",")');
        checkResult(runtime, ['""']);
      },
    );

    test('str_split empty string with empty separator returns empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = str_split("", "")');
      checkResult(runtime, []);
    });

    test('str_split with empty separator returns characters', () {
      final RuntimeFacade runtime = getRuntime('main() = str_split("abc", "")');
      checkResult(runtime, ['"a"', '"b"', '"c"']);
    });

    test('str_isEmpty empty string returns true', () {
      final RuntimeFacade runtime = getRuntime('main() = str_isEmpty("")');
      checkResult(runtime, true);
    });

    test('str_isEmpty non-empty string returns false', () {
      final RuntimeFacade runtime = getRuntime('main() = str_isEmpty("a")');
      checkResult(runtime, false);
    });

    test('str_isNotEmpty empty string returns false', () {
      final RuntimeFacade runtime = getRuntime('main() = str_isNotEmpty("")');
      checkResult(runtime, false);
    });

    test('str_isNotEmpty non-empty string returns true', () {
      final RuntimeFacade runtime = getRuntime('main() = str_isNotEmpty("a")');
      checkResult(runtime, true);
    });

    test('str_length empty string returns zero', () {
      final RuntimeFacade runtime = getRuntime('main() = str_length("")');
      checkResult(runtime, 0);
    });

    test('str_take zero count returns empty', () {
      final RuntimeFacade runtime = getRuntime('main() = str_take("hello", 0)');
      checkResult(runtime, '""');
    });

    test('str_drop zero count returns unchanged', () {
      final RuntimeFacade runtime = getRuntime('main() = str_drop("hello", 0)');
      checkResult(runtime, '"hello"');
    });

    test('str_take empty string returns empty', () {
      final RuntimeFacade runtime = getRuntime('main() = str_take("", 5)');
      checkResult(runtime, '""');
    });

    test('str_drop empty string returns empty', () {
      final RuntimeFacade runtime = getRuntime('main() = str_drop("", 5)');
      checkResult(runtime, '""');
    });
  });

  group('Empty Map Operations', () {
    test('map_keys empty map returns empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = map_keys({})');
      checkResult(runtime, []);
    });

    test('map_values empty map returns empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = map_values({})');
      checkResult(runtime, []);
    });

    test('map_set empty map adds entry', () {
      final RuntimeFacade runtime = getRuntime('main() = map_set({}, "a", 1)');
      checkResult(runtime, {'"a"': 1});
    });

    test('map_set updates existing key', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = map_set({"a": 1}, "a", 99)',
      );
      checkResult(runtime, {'"a"': 99});
    });

    test('map_removeAt empty map returns empty', () {
      final RuntimeFacade runtime = getRuntime('main() = map_removeAt({}, 1)');
      checkResult(runtime, {});
    });

    test('map_removeAt non-existent key returns unchanged', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = map_removeAt({1: "a"}, 2)',
      );
      checkResult(runtime, {1: '"a"'});
    });

    test('map_containsKey empty map returns false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = map_containsKey({}, "a")',
      );
      checkResult(runtime, false);
    });

    test('map_containsKey key exists returns true', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = map_containsKey({"a": 1}, "a")',
      );
      checkResult(runtime, true);
    });

    test('map_containsKey key not exists returns false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = map_containsKey({"a": 1}, "b")',
      );
      checkResult(runtime, false);
    });

    test('map_isEmpty empty map returns true', () {
      final RuntimeFacade runtime = getRuntime('main() = map_isEmpty({})');
      checkResult(runtime, true);
    });

    test('map_isEmpty non-empty map returns false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = map_isEmpty({"a": 1})',
      );
      checkResult(runtime, false);
    });

    test('map_isNotEmpty empty map returns false', () {
      final RuntimeFacade runtime = getRuntime('main() = map_isNotEmpty({})');
      checkResult(runtime, false);
    });

    test('map_isNotEmpty non-empty map returns true', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = map_isNotEmpty({"a": 1})',
      );
      checkResult(runtime, true);
    });

    test('map_length empty map returns zero', () {
      final RuntimeFacade runtime = getRuntime('main() = map_length({})');
      checkResult(runtime, 0);
    });

    test('map_length single entry returns one', () {
      final RuntimeFacade runtime = getRuntime('main() = map_length({"a": 1})');
      checkResult(runtime, 1);
    });
  });

  group('Single Element Boundary Cases', () {
    test('list_indexOf first element returns zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_indexOf([1, 2, 3], 1)',
      );
      checkResult(runtime, 0);
    });

    test('list_indexOf last element returns correct index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_indexOf([1, 2, 3], 3)',
      );
      checkResult(runtime, 2);
    });

    test('list_contains first element returns true', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_contains([1, 2, 3], 1)',
      );
      checkResult(runtime, true);
    });

    test('list_contains last element returns true', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_contains([1, 2, 3], 3)',
      );
      checkResult(runtime, true);
    });

    test('list_remove all occurrences', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_remove([1, 2, 1, 3, 1], 1)',
      );
      checkResult(runtime, [2, 3]);
    });

    test('list_removeAt single element list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_removeAt([42], 0)',
      );
      checkResult(runtime, []);
    });

    test('str_indexOf first character returns zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_indexOf("hello", "h")',
      );
      checkResult(runtime, 0);
    });

    test('str_indexOf last character returns correct index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str_indexOf("hello", "o")',
      );
      checkResult(runtime, 4);
    });

    test('str_removeAt single character string', () {
      final RuntimeFacade runtime = getRuntime('main() = str_removeAt("x", 0)');
      checkResult(runtime, '""');
    });

    test('list_swap adjacent elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_swap([1, 2, 3], 0, 1)',
      );
      checkResult(runtime, [2, 1, 3]);
    });

    test('list_swap single element list at same index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_swap([42], 0, 0)',
      );
      checkResult(runtime, [42]);
    });

    test('list_set single element list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list_set([1], 0, 99)',
      );
      checkResult(runtime, [99]);
    });
  });

  group('Nested Collections', () {
    test('nested list equality', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = [1, [2, 3]] == [1, [2, 3]]',
      );
      checkResult(runtime, true);
    });

    test('nested list inequality', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = [1, [2, 3]] == [1, [2, 4]]',
      );
      checkResult(runtime, false);
    });

    test('list of maps', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = [{"a": 1}, {"b": 2}]',
      );
      checkResult(runtime, [
        {'"a"': 1},
        {'"b"': 2},
      ]);
    });

    test('map with list value', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = {"nums": [1, 2, 3]}',
      );
      checkResult(runtime, {
        '"nums"': [1, 2, 3],
      });
    });

    test('deeply nested list', () {
      final RuntimeFacade runtime = getRuntime('main() = [[[1]]]');
      checkResult(runtime, [
        [
          [1],
        ],
      ]);
    });

    test('index into nested list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = ([[1, 2], [3, 4]])[1]',
      );
      checkResult(runtime, [3, 4]);
    });

    test('map with nested map equality', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = {"a": {"b": 1}} == {"a": {"b": 1}}',
      );
      checkResult(runtime, true);
    });

    test('map with nested map inequality', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = {"a": {"b": 1}} == {"a": {"b": 2}}',
      );
      checkResult(runtime, false);
    });
  });
}
