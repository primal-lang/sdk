@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('element.at', () {
    test('returns list element at index', () {
      final Runtime runtime = getRuntime('main = element.at([10, 20, 30], 1)');
      checkResult(runtime, 20);
    });

    test('returns first list element', () {
      final Runtime runtime = getRuntime('main = element.at([10, 20, 30], 0)');
      checkResult(runtime, 10);
    });

    test('returns last list element', () {
      final Runtime runtime = getRuntime('main = element.at([10, 20, 30], 2)');
      checkResult(runtime, 30);
    });

    test('returns map value by key', () {
      final Runtime runtime = getRuntime(
        'main = element.at({"a": 1, "b": 2}, "a")',
      );
      checkResult(runtime, 1);
    });

    test('returns string character at index', () {
      final Runtime runtime = getRuntime('main = element.at("hello", 0)');
      checkResult(runtime, '"h"');
    });

    test('returns string character at middle index', () {
      final Runtime runtime = getRuntime('main = element.at("hello", 2)');
      checkResult(runtime, '"l"');
    });

    test('throws ElementNotFoundError for missing map key', () {
      final Runtime runtime = getRuntime(
        'main = element.at({"a": 1}, "z")',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<ElementNotFoundError>()),
      );
    });

    test('throws InvalidArgumentTypesError for invalid types', () {
      final Runtime runtime = getRuntime('main = element.at(42, 0)');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });
  });
}
