@Tags(['runtime'])
library;

import 'package:primal/compiler/library/error/throw.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Control', () {
    test('if/else 1', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (true) "yes" else "no"',
      );
      checkResult(runtime, '"yes"');
    });

    test('if/else 2', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (false) "yes" else "no"',
      );
      checkResult(runtime, '"no"');
    });

    test('if/else 3', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (true) 1 + 2 else 42',
      );
      checkResult(runtime, 3);
    });
  });

  group('Try/Catch', () {
    test('try/catch 1', () {
      final RuntimeFacade runtime = getRuntime('main = try(1 / 2, 42)');
      checkResult(runtime, 0.5);
    });

    test('try/catch 2', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(error.throw(0, "Does not compute"), 42)',
      );
      checkResult(runtime, 42);
    });

    test('try/catch evaluates fallback expression', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(error.throw(0, "fail"), 1 + 2)',
      );
      checkResult(runtime, 3);
    });
  });

  group('Error', () {
    test('throw', () {
      final RuntimeFacade runtime = getRuntime(
        'main = error.throw(-1, "Segmentation fault")',
      );
      expect(runtime.executeMain, throwsA(isA<CustomError>()));
    });
  });
}
