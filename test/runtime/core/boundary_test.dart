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
      final RuntimeFacade runtime = getRuntime('main = list.first([])');
      expect(runtime.executeMain, throwsA(isA<EmptyCollectionError>()));
    });

    test('list.last empty throws', () {
      final RuntimeFacade runtime = getRuntime('main = list.last([])');
      expect(runtime.executeMain, throwsA(isA<EmptyCollectionError>()));
    });

    test('list.init empty returns empty', () {
      final RuntimeFacade runtime = getRuntime('main = list.init([])');
      checkResult(runtime, []);
    });

    test('str.first empty throws', () {
      final RuntimeFacade runtime = getRuntime('main = str.first("")');
      expect(runtime.executeMain, throwsA(isA<EmptyCollectionError>()));
    });

    test('str.last empty throws', () {
      final RuntimeFacade runtime = getRuntime('main = str.last("")');
      expect(runtime.executeMain, throwsA(isA<EmptyCollectionError>()));
    });

    test('str.init empty returns empty', () {
      final RuntimeFacade runtime = getRuntime('main = str.init("")');
      checkResult(runtime, '""');
    });

    test('list.at empty throws', () {
      final RuntimeFacade runtime = getRuntime('main = list.at([], 0)');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('str.at empty throws', () {
      final RuntimeFacade runtime = getRuntime('main = str.at("", 0)');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });
  });

  group('Out of Bounds', () {
    test('list indexing out of bounds', () {
      final RuntimeFacade runtime = getRuntime('main = [1, 2, 3][5]');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('string indexing out of bounds', () {
      final RuntimeFacade runtime = getRuntime('main = "Hello"[10]');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list.at out of bounds', () {
      final RuntimeFacade runtime = getRuntime('main = list.at([1, 2], 5)');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('str.at out of bounds', () {
      final RuntimeFacade runtime = getRuntime('main = str.at("Hi", 5)');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list.removeAt out of bounds', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.removeAt([1, 2], 5)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list.swap out of bounds', () {
      final RuntimeFacade runtime = getRuntime('main = list.swap([1], 0, 5)');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list.sublist out of bounds', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.sublist([1, 2], 0, 10)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('str.substring out of bounds', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.substring("Hi", 0, 10)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list negative index', () {
      final RuntimeFacade runtime = getRuntime('main = list.at([1, 2, 3], -1)');
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });

    test('str.removeAt out of bounds', () {
      final RuntimeFacade runtime = getRuntime('main = str.removeAt("Hi", 5)');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('str.removeAt negative index', () {
      final RuntimeFacade runtime = getRuntime('main = str.removeAt("Hi", -1)');
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });

    test('list.removeAt negative index', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.removeAt([1, 2], -1)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });

    test('list.swap negative first index', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.swap([1, 2], -1, 0)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });

    test('list.swap negative second index', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.swap([1, 2], 0, -1)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });

    test('list.swap first index out of bounds', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.swap([1, 2], 5, 0)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list.set negative index', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.set([1, 2], -1, 99)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });

    test('list.set out of bounds index', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.set([1, 2], 10, 99)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list.set index equal to length', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.set([1, 2], 2, 99)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list.set empty list at index 0', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.set([], 0, 99)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list.set empty list at index 1', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.set([], 1, 99)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list.set single element list at index 1', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.set([1], 1, 99)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list.sublist negative start index', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.sublist([1, 2, 3], -1, 2)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });

    test('list.sublist end less than start', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.sublist([1, 2, 3], 2, 1)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list.sublist start greater than length', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.sublist([1, 2, 3], 10, 12)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('str.take negative count', () {
      final RuntimeFacade runtime = getRuntime('main = str.take("Hello", -1)');
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });

    test('str.drop negative count', () {
      final RuntimeFacade runtime = getRuntime('main = str.drop("Hello", -1)');
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });

    test('str.substring negative start', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.substring("Hello", -1, 3)',
      );
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });

    test('str.substring end less than start', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.substring("Hello", 3, 1)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('str.at negative index', () {
      final RuntimeFacade runtime = getRuntime('main = str.at("Hello", -1)');
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });

    test('str.substring start greater than length', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.substring("Hi", 5, 6)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('str.removeAt on empty string', () {
      final RuntimeFacade runtime = getRuntime('main = str.removeAt("", 0)');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list.removeAt on empty list', () {
      final RuntimeFacade runtime = getRuntime('main = list.removeAt([], 0)');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list.at index equal to length', () {
      final RuntimeFacade runtime = getRuntime('main = list.at([1, 2, 3], 3)');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('str.at index equal to length', () {
      final RuntimeFacade runtime = getRuntime('main = str.at("abc", 3)');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list.swap on empty list', () {
      final RuntimeFacade runtime = getRuntime('main = list.swap([], 0, 0)');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list.swap on single element list with out of bounds', () {
      final RuntimeFacade runtime = getRuntime('main = list.swap([1], 0, 1)');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('map.at on empty map', () {
      final RuntimeFacade runtime = getRuntime('main = map.at({}, "key")');
      expect(runtime.executeMain, throwsA(isA<InvalidMapIndexError>()));
    });

    test('map.at non-existent key', () {
      final RuntimeFacade runtime = getRuntime(
        'main = map.at({"a": 1}, "b")',
      );
      expect(runtime.executeMain, throwsA(isA<InvalidMapIndexError>()));
    });

    test('list.sublist negative end index', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.sublist([1, 2, 3], 0, -1)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('str.substring negative end index', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.substring("Hello", 0, -1)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list.take negative count', () {
      final RuntimeFacade runtime = getRuntime('main = list.take([1, 2], -1)');
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });

    test('list.drop negative count', () {
      final RuntimeFacade runtime = getRuntime('main = list.drop([1, 2], -1)');
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });
  });

  group('Boundary Value Operations', () {
    test('list.sublist empty list returns empty', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.sublist([], 0, 0)',
      );
      checkResult(runtime, []);
    });

    test('str.substring empty string returns empty', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.substring("", 0, 0)',
      );
      checkResult(runtime, '""');
    });

    test('str.init single character returns empty', () {
      final RuntimeFacade runtime = getRuntime('main = str.init("a")');
      checkResult(runtime, '""');
    });

    test('str.rest single character returns empty', () {
      final RuntimeFacade runtime = getRuntime('main = str.rest("a")');
      checkResult(runtime, '""');
    });

    test('list.init single element returns empty', () {
      final RuntimeFacade runtime = getRuntime('main = list.init([1])');
      checkResult(runtime, []);
    });

    test('list.rest single element returns empty', () {
      final RuntimeFacade runtime = getRuntime('main = list.rest([1])');
      checkResult(runtime, []);
    });

    test('list.sublist end equal to length', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.sublist([1, 2, 3], 1, 3)',
      );
      checkResult(runtime, [2, 3]);
    });

    test('str.substring end equal to length', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.substring("Hello", 2, 5)',
      );
      checkResult(runtime, '"llo"');
    });

    test('list.sublist start equal to length returns empty', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.sublist([1, 2, 3], 3, 3)',
      );
      checkResult(runtime, []);
    });

    test('str.substring start equal to length returns empty', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.substring("Hi", 2, 2)',
      );
      checkResult(runtime, '""');
    });

    test('list.take count equal to length', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.take([1, 2, 3], 3)',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('str.take count equal to length', () {
      final RuntimeFacade runtime = getRuntime('main = str.take("abc", 3)');
      checkResult(runtime, '"abc"');
    });

    test('list.drop count equal to length', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.drop([1, 2, 3], 3)',
      );
      checkResult(runtime, []);
    });

    test('str.drop count equal to length', () {
      final RuntimeFacade runtime = getRuntime('main = str.drop("abc", 3)');
      checkResult(runtime, '""');
    });

    test('list.take exceeds length clamps to length', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.take([1, 2], 10)',
      );
      checkResult(runtime, [1, 2]);
    });

    test('str.take exceeds length clamps to length', () {
      final RuntimeFacade runtime = getRuntime('main = str.take("ab", 10)');
      checkResult(runtime, '"ab"');
    });

    test('list.drop exceeds length returns empty', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.drop([1, 2], 10)',
      );
      checkResult(runtime, []);
    });

    test('str.drop exceeds length returns empty', () {
      final RuntimeFacade runtime = getRuntime('main = str.drop("ab", 10)');
      checkResult(runtime, '""');
    });

    test('list.removeAt first element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.removeAt([1, 2, 3], 0)',
      );
      checkResult(runtime, [2, 3]);
    });

    test('list.removeAt last element', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.removeAt([1, 2, 3], 2)',
      );
      checkResult(runtime, [1, 2]);
    });

    test('str.removeAt first character', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.removeAt("abc", 0)',
      );
      checkResult(runtime, '"bc"');
    });

    test('str.removeAt last character', () {
      final RuntimeFacade runtime = getRuntime(
        'main = str.removeAt("abc", 2)',
      );
      checkResult(runtime, '"ab"');
    });

    test('list.swap first and last elements', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.swap([1, 2, 3], 0, 2)',
      );
      checkResult(runtime, [3, 2, 1]);
    });

    test('list.swap same index returns unchanged', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.swap([1, 2, 3], 1, 1)',
      );
      checkResult(runtime, [1, 2, 3]);
    });

    test('list.set at first index', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.set([1, 2, 3], 0, 99)',
      );
      checkResult(runtime, [99, 2, 3]);
    });

    test('list.set at last index', () {
      final RuntimeFacade runtime = getRuntime(
        'main = list.set([1, 2, 3], 2, 99)',
      );
      checkResult(runtime, [1, 2, 99]);
    });

    test('list.first single element', () {
      final RuntimeFacade runtime = getRuntime('main = list.first([42])');
      checkResult(runtime, 42);
    });

    test('list.last single element', () {
      final RuntimeFacade runtime = getRuntime('main = list.last([42])');
      checkResult(runtime, 42);
    });

    test('str.first single character', () {
      final RuntimeFacade runtime = getRuntime('main = str.first("x")');
      checkResult(runtime, '"x"');
    });

    test('str.last single character', () {
      final RuntimeFacade runtime = getRuntime('main = str.last("x")');
      checkResult(runtime, '"x"');
    });
  });

  group('Nested Collections', () {
    test('nested list equality', () {
      final RuntimeFacade runtime = getRuntime(
        'main = [1, [2, 3]] == [1, [2, 3]]',
      );
      checkResult(runtime, true);
    });

    test('nested list inequality', () {
      final RuntimeFacade runtime = getRuntime(
        'main = [1, [2, 3]] == [1, [2, 4]]',
      );
      checkResult(runtime, false);
    });

    test('list of maps', () {
      final RuntimeFacade runtime = getRuntime(
        'main = [{"a": 1}, {"b": 2}]',
      );
      checkResult(runtime, [
        {'"a"': 1},
        {'"b"': 2},
      ]);
    });

    test('map with list value', () {
      final RuntimeFacade runtime = getRuntime(
        'main = {"nums": [1, 2, 3]}',
      );
      checkResult(runtime, {
        '"nums"': [1, 2, 3],
      });
    });

    test('deeply nested list', () {
      final RuntimeFacade runtime = getRuntime('main = [[[1]]]');
      checkResult(runtime, [
        [
          [1],
        ],
      ]);
    });

    test('index into nested list', () {
      final RuntimeFacade runtime = getRuntime(
        'main = ([[1, 2], [3, 4]])[1]',
      );
      checkResult(runtime, [3, 4]);
    });

    test('map with nested map equality', () {
      final RuntimeFacade runtime = getRuntime(
        'main = {"a": {"b": 1}} == {"a": {"b": 1}}',
      );
      checkResult(runtime, true);
    });

    test('map with nested map inequality', () {
      final RuntimeFacade runtime = getRuntime(
        'main = {"a": {"b": 1}} == {"a": {"b": 2}}',
      );
      checkResult(runtime, false);
    });
  });
}
