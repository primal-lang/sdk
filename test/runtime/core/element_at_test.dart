@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/semantic/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('@', () {
    test('returns list element at index', () {
      final RuntimeFacade runtime = getRuntime('main = [10, 20, 30] @ 1');
      checkResult(runtime, 20);
    });

    test('returns first list element', () {
      final RuntimeFacade runtime = getRuntime('main = [10, 20, 30] @ 0');
      checkResult(runtime, 10);
    });

    test('returns last list element', () {
      final RuntimeFacade runtime = getRuntime('main = [10, 20, 30] @ 2');
      checkResult(runtime, 30);
    });

    test('returns map value by key', () {
      final RuntimeFacade runtime = getRuntime(
        'main = {"a": 1, "b": 2} @ "a"',
      );
      checkResult(runtime, 1);
    });

    test('returns string character at index', () {
      final RuntimeFacade runtime = getRuntime('main = "hello" @ 0');
      checkResult(runtime, '"h"');
    });

    test('returns string character at middle index', () {
      final RuntimeFacade runtime = getRuntime('main = "hello" @ 2');
      checkResult(runtime, '"l"');
    });

    test('throws ElementNotFoundError for missing map key', () {
      final RuntimeFacade runtime = getRuntime(
        'main = {"a": 1} @ "z"',
      );
      expect(
        runtime.executeMain,
        throwsA(isA<ElementNotFoundError>()),
      );
    });

    test('throws InvalidArgumentTypesError for invalid types', () {
      final RuntimeFacade runtime = getRuntime('''
x = 42
main = x @ 0
''');
      expect(
        runtime.executeMain,
        throwsA(isA<InvalidArgumentTypesError>()),
      );
    });

    // @ infix operator tests (additional)
    test('@ operator chained', () {
      final RuntimeFacade runtime = getRuntime(
        'main = [[1, 2], [3, 4]] @ 1 @ 0',
      );
      checkResult(runtime, 3);
    });

    test('bracket syntax returns list element', () {
      final RuntimeFacade runtime = getRuntime('main = [10, 20, 30][1]');
      checkResult(runtime, 20);
    });

    test('bracket syntax returns map value', () {
      final RuntimeFacade runtime = getRuntime('main = {"a": 1, "b": 2}["a"]');
      checkResult(runtime, 1);
    });

    test('bracket syntax returns string character', () {
      final RuntimeFacade runtime = getRuntime('main = "hello"[0]');
      checkResult(runtime, '"h"');
    });
  });
}
