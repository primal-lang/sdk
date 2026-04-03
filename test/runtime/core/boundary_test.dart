@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/semantic/runtime_facade.dart';
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
