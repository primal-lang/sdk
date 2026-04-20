@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Empty Collection Operations', () {
    test('list.first empty throws', () {
      final RuntimeFacade runtime = getRuntime('main() = list.first([])');
      expect(runtime.executeMain, throwsA(isA<EmptyCollectionError>()));
    });

    test('list.last empty throws', () {
      final RuntimeFacade runtime = getRuntime('main() = list.last([])');
      expect(runtime.executeMain, throwsA(isA<EmptyCollectionError>()));
    });

    test('list.init empty returns empty', () {
      final RuntimeFacade runtime = getRuntime('main() = list.init([])');
      checkResult(runtime, []);
    });

    test('str.first empty throws', () {
      final RuntimeFacade runtime = getRuntime('main() = str.first("")');
      expect(runtime.executeMain, throwsA(isA<EmptyCollectionError>()));
    });

    test('str.last empty throws', () {
      final RuntimeFacade runtime = getRuntime('main() = str.last("")');
      expect(runtime.executeMain, throwsA(isA<EmptyCollectionError>()));
    });

    test('str.init empty returns empty', () {
      final RuntimeFacade runtime = getRuntime('main() = str.init("")');
      checkResult(runtime, '""');
    });

    test('list.at empty throws', () {
      final RuntimeFacade runtime = getRuntime('main() = list.at([], 0)');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('str.at empty throws', () {
      final RuntimeFacade runtime = getRuntime('main() = str.at("", 0)');
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

    test('list.at out of bounds', () {
      final RuntimeFacade runtime = getRuntime('main() = list.at([1, 2], 5)');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('str.at out of bounds', () {
      final RuntimeFacade runtime = getRuntime('main() = str.at("Hi", 5)');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list.removeAt out of bounds', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.removeAt([1, 2], 5)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list.swap out of bounds', () {
      final RuntimeFacade runtime = getRuntime('main() = list.swap([1], 0, 5)');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list.sublist out of bounds', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.sublist([1, 2], 0, 10)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('str.substring out of bounds', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.substring("Hi", 0, 10)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list negative index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.at([1, 2, 3], -1)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });

    test('str.removeAt out of bounds', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.removeAt("Hi", 5)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('str.removeAt negative index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.removeAt("Hi", -1)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });

    test('list.removeAt negative index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.removeAt([1, 2], -1)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });

    test('list.swap negative first index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.swap([1, 2], -1, 0)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });

    test('list.swap negative second index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.swap([1, 2], 0, -1)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });

    test('list.swap first index out of bounds', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.swap([1, 2], 5, 0)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list.set negative index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.set([1, 2], -1, 99)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });

    test('list.set out of bounds index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.set([1, 2], 10, 99)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list.set index equal to length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.set([1, 2], 2, 99)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list.set empty list at index 0', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.set([], 0, 99)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list.set empty list at index 1', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.set([], 1, 99)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list.set single element list at index 1', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.set([1], 1, 99)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list.sublist negative start index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.sublist([1, 2, 3], -1, 2)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });

    test('list.sublist end less than start', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.sublist([1, 2, 3], 2, 1)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list.sublist start greater than length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.sublist([1, 2, 3], 10, 12)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('str.take negative count', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.take("Hello", -1)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });

    test('str.drop negative count', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.drop("Hello", -1)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });

    test('str.substring negative start', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.substring("Hello", -1, 3)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });

    test('str.substring end less than start', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.substring("Hello", 3, 1)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('str.at negative index', () {
      final RuntimeFacade runtime = getRuntime('main() = str.at("Hello", -1)');
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });

    test('str.substring start greater than length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.substring("Hi", 5, 6)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('str.removeAt on empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = str.removeAt("", 0)');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list.removeAt on empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = list.removeAt([], 0)');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list.at index equal to length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.at([1, 2, 3], 3)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('str.at index equal to length', () {
      final RuntimeFacade runtime = getRuntime('main() = str.at("abc", 3)');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list.swap on empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = list.swap([], 0, 0)');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list.swap on single element list with out of bounds', () {
      final RuntimeFacade runtime = getRuntime('main() = list.swap([1], 0, 1)');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('map.at on empty map', () {
      final RuntimeFacade runtime = getRuntime('main() = map.at({}, "key")');
      expect(runtime.executeMain, throwsA(isA<InvalidMapIndexError>()));
    });

    test('map.at non-existent key', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = map.at({"a": 1}, "b")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidMapIndexError>()));
    });

    test('list.sublist negative end index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.sublist([1, 2, 3], 0, -1)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('str.substring negative end index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.substring("Hello", 0, -1)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list.take negative count', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.take([1, 2], -1)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });

    test('list.drop negative count', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.drop([1, 2], -1)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });
  });

  group('Boundary Value Operations', () {
    test('list.sublist empty list returns empty', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.sublist([], 0, 0)',
      );
      checkResult(runtime, []);
    });

    test('str.substring empty string returns empty', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.substring("", 0, 0)',
      );
      checkResult(runtime, '""');
    });

    test('str.init single character returns empty', () {
      final RuntimeFacade runtime = getRuntime('main() = str.init("a")');
      checkResult(runtime, '""');
    });

    test('str.rest single character returns empty', () {
      final RuntimeFacade runtime = getRuntime('main() = str.rest("a")');
      checkResult(runtime, '""');
    });

    test('list.init single element returns empty', () {
      final RuntimeFacade runtime = getRuntime('main() = list.init([1])');
      checkResult(runtime, []);
    });

    test('list.rest single element returns empty', () {
      final RuntimeFacade runtime = getRuntime('main() = list.rest([1])');
      checkResult(runtime, []);
    });

    test('list.sublist end equal to length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.sublist([1, 2, 3], 1, 3)',
      );
      checkResult(runtime, [2, 3]);
    });

    test('str.substring end equal to length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.substring("Hello", 2, 5)',
      );
      checkResult(runtime, '"llo"');
    });

    test('list.sublist start equal to length returns empty', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.sublist([1, 2, 3], 3, 3)',
      );
      checkResult(runtime, []);
    });

    test('str.substring start equal to length returns empty', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.substring("Hi", 2, 2)',
      );
      checkResult(runtime, '""');
    });

    test('list.take count equal to length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.take([1, 2, 3], 3)',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('str.take count equal to length', () {
      final RuntimeFacade runtime = getRuntime('main() = str.take("abc", 3)');
      checkResult(runtime, '"abc"');
    });

    test('list.drop count equal to length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.drop([1, 2, 3], 3)',
      );
      checkResult(runtime, []);
    });

    test('str.drop count equal to length', () {
      final RuntimeFacade runtime = getRuntime('main() = str.drop("abc", 3)');
      checkResult(runtime, '""');
    });

    test('list.take exceeds length clamps to length', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.take([1, 2], 10)',
      );
      checkResult(runtime, [1, 2]);
    });

    test('str.take exceeds length clamps to length', () {
      final RuntimeFacade runtime = getRuntime('main() = str.take("ab", 10)');
      checkResult(runtime, '"ab"');
    });

    test('list.drop exceeds length returns empty', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.drop([1, 2], 10)',
      );
      checkResult(runtime, []);
    });

    test('str.drop exceeds length returns empty', () {
      final RuntimeFacade runtime = getRuntime('main() = str.drop("ab", 10)');
      checkResult(runtime, '""');
    });

    test('list.removeAt first element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.removeAt([1, 2, 3], 0)',
      );
      checkResult(runtime, [2, 3]);
    });

    test('list.removeAt last element', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.removeAt([1, 2, 3], 2)',
      );
      checkResult(runtime, [1, 2]);
    });

    test('str.removeAt first character', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.removeAt("abc", 0)',
      );
      checkResult(runtime, '"bc"');
    });

    test('str.removeAt last character', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.removeAt("abc", 2)',
      );
      checkResult(runtime, '"ab"');
    });

    test('list.swap first and last elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.swap([1, 2, 3], 0, 2)',
      );
      checkResult(runtime, [3, 2, 1]);
    });

    test('list.swap same index returns unchanged', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.swap([1, 2, 3], 1, 1)',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('list.set at first index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.set([1, 2, 3], 0, 99)',
      );
      checkResult(runtime, [99, 2, 3]);
    });

    test('list.set at last index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.set([1, 2, 3], 2, 99)',
      );
      checkResult(runtime, [1, 2, 99]);
    });

    test('list.first single element', () {
      final RuntimeFacade runtime = getRuntime('main() = list.first([42])');
      checkResult(runtime, 42);
    });

    test('list.last single element', () {
      final RuntimeFacade runtime = getRuntime('main() = list.last([42])');
      checkResult(runtime, 42);
    });

    test('str.first single character', () {
      final RuntimeFacade runtime = getRuntime('main() = str.first("x")');
      checkResult(runtime, '"x"');
    });

    test('str.last single character', () {
      final RuntimeFacade runtime = getRuntime('main() = str.last("x")');
      checkResult(runtime, '"x"');
    });
  });

  group('Empty List Operations', () {
    test('list.rest empty returns empty', () {
      final RuntimeFacade runtime = getRuntime('main() = list.rest([])');
      checkResult(runtime, []);
    });

    test('list.reverse empty returns empty', () {
      final RuntimeFacade runtime = getRuntime('main() = list.reverse([])');
      checkResult(runtime, []);
    });

    test('list.concat two empty lists', () {
      final RuntimeFacade runtime = getRuntime('main() = list.concat([], [])');
      checkResult(runtime, []);
    });

    test('list.concat empty with non-empty', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.concat([], [1, 2])',
      );
      checkResult(runtime, [1, 2]);
    });

    test('list.concat non-empty with empty', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.concat([1, 2], [])',
      );
      checkResult(runtime, [1, 2]);
    });

    test('list.indexOf empty list returns negative one', () {
      final RuntimeFacade runtime = getRuntime('main() = list.indexOf([], 1)');
      checkResult(runtime, -1);
    });

    test('list.indexOf element not found returns negative one', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.indexOf([1, 2, 3], 5)',
      );
      checkResult(runtime, -1);
    });

    test('list.contains empty list returns false', () {
      final RuntimeFacade runtime = getRuntime('main() = list.contains([], 1)');
      checkResult(runtime, false);
    });

    test('list.contains element not in list returns false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.contains([1, 2, 3], 5)',
      );
      checkResult(runtime, false);
    });

    test('list.remove empty list returns empty', () {
      final RuntimeFacade runtime = getRuntime('main() = list.remove([], 1)');
      checkResult(runtime, []);
    });

    test('list.remove element not found returns unchanged', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.remove([1, 2, 3], 5)',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('list.insertStart empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.insertStart([], 1)',
      );
      checkResult(runtime, [1]);
    });

    test('list.insertEnd empty list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.insertEnd([], 1)',
      );
      checkResult(runtime, [1]);
    });

    test('list.join empty list returns empty string', () {
      final RuntimeFacade runtime = getRuntime('main() = list.join([], ", ")');
      checkResult(runtime, '""');
    });

    test('list.join single element list', () {
      final RuntimeFacade runtime = getRuntime('main() = list.join([1], ", ")');
      checkResult(runtime, '"1"');
    });

    test('list.isEmpty empty list returns true', () {
      final RuntimeFacade runtime = getRuntime('main() = list.isEmpty([])');
      checkResult(runtime, true);
    });

    test('list.isEmpty non-empty list returns false', () {
      final RuntimeFacade runtime = getRuntime('main() = list.isEmpty([1])');
      checkResult(runtime, false);
    });

    test('list.isNotEmpty empty list returns false', () {
      final RuntimeFacade runtime = getRuntime('main() = list.isNotEmpty([])');
      checkResult(runtime, false);
    });

    test('list.isNotEmpty non-empty list returns true', () {
      final RuntimeFacade runtime = getRuntime('main() = list.isNotEmpty([1])');
      checkResult(runtime, true);
    });

    test('list.length empty list returns zero', () {
      final RuntimeFacade runtime = getRuntime('main() = list.length([])');
      checkResult(runtime, 0);
    });

    test('list.take zero count returns empty', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.take([1, 2, 3], 0)',
      );
      checkResult(runtime, []);
    });

    test('list.drop zero count returns unchanged', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.drop([1, 2, 3], 0)',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('list.take empty list returns empty', () {
      final RuntimeFacade runtime = getRuntime('main() = list.take([], 5)');
      checkResult(runtime, []);
    });

    test('list.drop empty list returns empty', () {
      final RuntimeFacade runtime = getRuntime('main() = list.drop([], 5)');
      checkResult(runtime, []);
    });

    test('list.reverse single element', () {
      final RuntimeFacade runtime = getRuntime('main() = list.reverse([42])');
      checkResult(runtime, [42]);
    });
  });

  group('List Filled Boundary Cases', () {
    test('list.filled zero count returns empty', () {
      final RuntimeFacade runtime = getRuntime('main() = list.filled(0, 1)');
      checkResult(runtime, []);
    });

    test('list.filled negative count throws', () {
      final RuntimeFacade runtime = getRuntime('main() = list.filled(-1, 1)');
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });

    test('list.filled single element', () {
      final RuntimeFacade runtime = getRuntime('main() = list.filled(1, 42)');
      checkResult(runtime, [42]);
    });
  });

  group('Empty String Operations', () {
    test('str.rest empty returns empty', () {
      final RuntimeFacade runtime = getRuntime('main() = str.rest("")');
      checkResult(runtime, '""');
    });

    test('str.reverse empty returns empty', () {
      final RuntimeFacade runtime = getRuntime('main() = str.reverse("")');
      checkResult(runtime, '""');
    });

    test('str.reverse single character', () {
      final RuntimeFacade runtime = getRuntime('main() = str.reverse("a")');
      checkResult(runtime, '"a"');
    });

    test('str.indexOf empty string returns negative one', () {
      final RuntimeFacade runtime = getRuntime('main() = str.indexOf("", "a")');
      checkResult(runtime, -1);
    });

    test('str.indexOf substring not found returns negative one', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.indexOf("hello", "xyz")',
      );
      checkResult(runtime, -1);
    });

    test('str.indexOf empty substring returns zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.indexOf("hello", "")',
      );
      checkResult(runtime, 0);
    });

    test('str.concat two empty strings', () {
      final RuntimeFacade runtime = getRuntime('main() = str.concat("", "")');
      checkResult(runtime, '""');
    });

    test('str.concat empty with non-empty', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.concat("", "hello")',
      );
      checkResult(runtime, '"hello"');
    });

    test('str.concat non-empty with empty', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.concat("hello", "")',
      );
      checkResult(runtime, '"hello"');
    });

    test('str.contains empty string in non-empty returns true', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.contains("hello", "")',
      );
      checkResult(runtime, true);
    });

    test('str.contains substring not found returns false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.contains("hello", "xyz")',
      );
      checkResult(runtime, false);
    });

    test('str.contains empty string in empty returns true', () {
      final RuntimeFacade runtime = getRuntime('main() = str.contains("", "")');
      checkResult(runtime, true);
    });

    test('str.startsWith empty prefix returns true', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.startsWith("hello", "")',
      );
      checkResult(runtime, true);
    });

    test('str.startsWith empty string with empty prefix returns true', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.startsWith("", "")',
      );
      checkResult(runtime, true);
    });

    test('str.startsWith empty string with non-empty prefix returns false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.startsWith("", "a")',
      );
      checkResult(runtime, false);
    });

    test('str.endsWith empty suffix returns true', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.endsWith("hello", "")',
      );
      checkResult(runtime, true);
    });

    test('str.endsWith empty string with empty suffix returns true', () {
      final RuntimeFacade runtime = getRuntime('main() = str.endsWith("", "")');
      checkResult(runtime, true);
    });

    test('str.endsWith empty string with non-empty suffix returns false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.endsWith("", "a")',
      );
      checkResult(runtime, false);
    });

    test(
      'str.split empty string with non-empty separator returns list with empty string',
      () {
        final RuntimeFacade runtime = getRuntime('main() = str.split("", ",")');
        checkResult(runtime, ['""']);
      },
    );

    test('str.split empty string with empty separator returns empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = str.split("", "")');
      checkResult(runtime, []);
    });

    test('str.split with empty separator returns characters', () {
      final RuntimeFacade runtime = getRuntime('main() = str.split("abc", "")');
      checkResult(runtime, ['"a"', '"b"', '"c"']);
    });

    test('str.isEmpty empty string returns true', () {
      final RuntimeFacade runtime = getRuntime('main() = str.isEmpty("")');
      checkResult(runtime, true);
    });

    test('str.isEmpty non-empty string returns false', () {
      final RuntimeFacade runtime = getRuntime('main() = str.isEmpty("a")');
      checkResult(runtime, false);
    });

    test('str.isNotEmpty empty string returns false', () {
      final RuntimeFacade runtime = getRuntime('main() = str.isNotEmpty("")');
      checkResult(runtime, false);
    });

    test('str.isNotEmpty non-empty string returns true', () {
      final RuntimeFacade runtime = getRuntime('main() = str.isNotEmpty("a")');
      checkResult(runtime, true);
    });

    test('str.length empty string returns zero', () {
      final RuntimeFacade runtime = getRuntime('main() = str.length("")');
      checkResult(runtime, 0);
    });

    test('str.take zero count returns empty', () {
      final RuntimeFacade runtime = getRuntime('main() = str.take("hello", 0)');
      checkResult(runtime, '""');
    });

    test('str.drop zero count returns unchanged', () {
      final RuntimeFacade runtime = getRuntime('main() = str.drop("hello", 0)');
      checkResult(runtime, '"hello"');
    });

    test('str.take empty string returns empty', () {
      final RuntimeFacade runtime = getRuntime('main() = str.take("", 5)');
      checkResult(runtime, '""');
    });

    test('str.drop empty string returns empty', () {
      final RuntimeFacade runtime = getRuntime('main() = str.drop("", 5)');
      checkResult(runtime, '""');
    });
  });

  group('Empty Map Operations', () {
    test('map.keys empty map returns empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = map.keys({})');
      checkResult(runtime, []);
    });

    test('map.values empty map returns empty list', () {
      final RuntimeFacade runtime = getRuntime('main() = map.values({})');
      checkResult(runtime, []);
    });

    test('map.set empty map adds entry', () {
      final RuntimeFacade runtime = getRuntime('main() = map.set({}, "a", 1)');
      checkResult(runtime, {'"a"': 1});
    });

    test('map.set updates existing key', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = map.set({"a": 1}, "a", 99)',
      );
      checkResult(runtime, {'"a"': 99});
    });

    test('map.removeAt empty map returns empty', () {
      final RuntimeFacade runtime = getRuntime('main() = map.removeAt({}, 1)');
      checkResult(runtime, {});
    });

    test('map.removeAt non-existent key returns unchanged', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = map.removeAt({1: "a"}, 2)',
      );
      checkResult(runtime, {1: '"a"'});
    });

    test('map.containsKey empty map returns false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = map.containsKey({}, "a")',
      );
      checkResult(runtime, false);
    });

    test('map.containsKey key exists returns true', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = map.containsKey({"a": 1}, "a")',
      );
      checkResult(runtime, true);
    });

    test('map.containsKey key not exists returns false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = map.containsKey({"a": 1}, "b")',
      );
      checkResult(runtime, false);
    });

    test('map.isEmpty empty map returns true', () {
      final RuntimeFacade runtime = getRuntime('main() = map.isEmpty({})');
      checkResult(runtime, true);
    });

    test('map.isEmpty non-empty map returns false', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = map.isEmpty({"a": 1})',
      );
      checkResult(runtime, false);
    });

    test('map.isNotEmpty empty map returns false', () {
      final RuntimeFacade runtime = getRuntime('main() = map.isNotEmpty({})');
      checkResult(runtime, false);
    });

    test('map.isNotEmpty non-empty map returns true', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = map.isNotEmpty({"a": 1})',
      );
      checkResult(runtime, true);
    });

    test('map.length empty map returns zero', () {
      final RuntimeFacade runtime = getRuntime('main() = map.length({})');
      checkResult(runtime, 0);
    });

    test('map.length single entry returns one', () {
      final RuntimeFacade runtime = getRuntime('main() = map.length({"a": 1})');
      checkResult(runtime, 1);
    });
  });

  group('Single Element Boundary Cases', () {
    test('list.indexOf first element returns zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.indexOf([1, 2, 3], 1)',
      );
      checkResult(runtime, 0);
    });

    test('list.indexOf last element returns correct index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.indexOf([1, 2, 3], 3)',
      );
      checkResult(runtime, 2);
    });

    test('list.contains first element returns true', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.contains([1, 2, 3], 1)',
      );
      checkResult(runtime, true);
    });

    test('list.contains last element returns true', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.contains([1, 2, 3], 3)',
      );
      checkResult(runtime, true);
    });

    test('list.remove all occurrences', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.remove([1, 2, 1, 3, 1], 1)',
      );
      checkResult(runtime, [2, 3]);
    });

    test('list.removeAt single element list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.removeAt([42], 0)',
      );
      checkResult(runtime, []);
    });

    test('str.indexOf first character returns zero', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.indexOf("hello", "h")',
      );
      checkResult(runtime, 0);
    });

    test('str.indexOf last character returns correct index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = str.indexOf("hello", "o")',
      );
      checkResult(runtime, 4);
    });

    test('str.removeAt single character string', () {
      final RuntimeFacade runtime = getRuntime('main() = str.removeAt("x", 0)');
      checkResult(runtime, '""');
    });

    test('list.swap adjacent elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.swap([1, 2, 3], 0, 1)',
      );
      checkResult(runtime, [2, 1, 3]);
    });

    test('list.swap single element list at same index', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.swap([42], 0, 0)',
      );
      checkResult(runtime, [42]);
    });

    test('list.set single element list', () {
      final RuntimeFacade runtime = getRuntime(
        'main() = list.set([1], 0, 99)',
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
