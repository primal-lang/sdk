@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Empty Collection Operations', () {
    test('list.first empty throws', () {
      final Runtime runtime = getRuntime('main = list.first([])');
      expect(runtime.executeMain, throwsA(isA<EmptyCollectionError>()));
    });

    test('list.last empty throws', () {
      final Runtime runtime = getRuntime('main = list.last([])');
      expect(runtime.executeMain, throwsA(isA<EmptyCollectionError>()));
    });

    test('list.init empty returns empty', () {
      final Runtime runtime = getRuntime('main = list.init([])');
      checkResult(runtime, []);
    });

    test('str.first empty throws', () {
      final Runtime runtime = getRuntime('main = str.first("")');
      expect(runtime.executeMain, throwsA(isA<EmptyCollectionError>()));
    });

    test('str.last empty throws', () {
      final Runtime runtime = getRuntime('main = str.last("")');
      expect(runtime.executeMain, throwsA(isA<EmptyCollectionError>()));
    });

    test('str.init empty returns empty', () {
      final Runtime runtime = getRuntime('main = str.init("")');
      checkResult(runtime, '""');
    });

    test('list.at empty throws', () {
      final Runtime runtime = getRuntime('main = list.at([], 0)');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('str.at empty throws', () {
      final Runtime runtime = getRuntime('main = str.at("", 0)');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });
  });

  group('Out of Bounds', () {
    test('list indexing out of bounds', () {
      final Runtime runtime = getRuntime('main = [1, 2, 3][5]');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('string indexing out of bounds', () {
      final Runtime runtime = getRuntime('main = "Hello"[10]');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list.at out of bounds', () {
      final Runtime runtime = getRuntime('main = list.at([1, 2], 5)');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('str.at out of bounds', () {
      final Runtime runtime = getRuntime('main = str.at("Hi", 5)');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list.removeAt out of bounds', () {
      final Runtime runtime = getRuntime(
        'main = list.removeAt([1, 2], 5)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list.swap out of bounds', () {
      final Runtime runtime = getRuntime('main = list.swap([1], 0, 5)');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list.sublist out of bounds', () {
      final Runtime runtime = getRuntime('main = list.sublist([1, 2], 0, 10)');
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('str.substring out of bounds', () {
      final Runtime runtime = getRuntime(
        'main = str.substring("Hi", 0, 10)',
      );
      expect(runtime.executeMain, throwsA(isA<IndexOutOfBoundsError>()));
    });

    test('list negative index', () {
      final Runtime runtime = getRuntime('main = list.at([1, 2, 3], -1)');
      expect(runtime.executeMain, throwsA(isA<NegativeIndexError>()));
    });
  });

  group('Nested Collections', () {
    test('nested list equality', () {
      final Runtime runtime = getRuntime(
        'main = [1, [2, 3]] == [1, [2, 3]]',
      );
      checkResult(runtime, true);
    });

    test('nested list inequality', () {
      final Runtime runtime = getRuntime(
        'main = [1, [2, 3]] == [1, [2, 4]]',
      );
      checkResult(runtime, false);
    });

    test('list of maps', () {
      final Runtime runtime = getRuntime(
        'main = [{"a": 1}, {"b": 2}]',
      );
      checkResult(runtime, [
        {'"a"': 1},
        {'"b"': 2},
      ]);
    });

    test('map with list value', () {
      final Runtime runtime = getRuntime(
        'main = {"nums": [1, 2, 3]}',
      );
      checkResult(runtime, {
        '"nums"': [1, 2, 3],
      });
    });

    test('deeply nested list', () {
      final Runtime runtime = getRuntime('main = [[[1]]]');
      checkResult(runtime, [
        [
          [1],
        ],
      ]);
    });

    test('index into nested list', () {
      final Runtime runtime = getRuntime(
        'main = ([[1, 2], [3, 4]])[1]',
      );
      checkResult(runtime, [3, 4]);
    });

    test('map with nested map equality', () {
      final Runtime runtime = getRuntime(
        'main = {"a": {"b": 1}} == {"a": {"b": 1}}',
      );
      checkResult(runtime, true);
    });

    test('map with nested map inequality', () {
      final Runtime runtime = getRuntime(
        'main = {"a": {"b": 1}} == {"a": {"b": 2}}',
      );
      checkResult(runtime, false);
    });
  });
}
