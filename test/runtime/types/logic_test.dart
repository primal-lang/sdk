@Tags(['runtime'])
library;

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Logic', () {
    test('bool.and returns true when both are true', () {
      final RuntimeFacade runtime = getRuntime('main = bool.and(true, true)');
      checkResult(runtime, true);
    });

    test('bool.and returns false when first is false', () {
      final RuntimeFacade runtime = getRuntime('main = bool.and(false, true)');
      checkResult(runtime, false);
    });

    test('bool.and returns false when second is false', () {
      final RuntimeFacade runtime = getRuntime('main = bool.and(true, false)');
      checkResult(runtime, false);
    });

    test('bool.and returns false when both are false', () {
      final RuntimeFacade runtime = getRuntime('main = bool.and(false, false)');
      checkResult(runtime, false);
    });

    test('bool.or returns true when both are true', () {
      final RuntimeFacade runtime = getRuntime('main = bool.or(true, true)');
      checkResult(runtime, true);
    });

    test('bool.or returns true when first is true', () {
      final RuntimeFacade runtime = getRuntime('main = bool.or(true, false)');
      checkResult(runtime, true);
    });

    test('bool.or returns true when second is true', () {
      final RuntimeFacade runtime = getRuntime('main = bool.or(false, true)');
      checkResult(runtime, true);
    });

    test('bool.or returns false when both are false', () {
      final RuntimeFacade runtime = getRuntime('main = bool.or(false, false)');
      checkResult(runtime, false);
    });

    test('bool.xor returns false when both are true', () {
      final RuntimeFacade runtime = getRuntime('main = bool.xor(true, true)');
      checkResult(runtime, false);
    });

    test('bool.xor returns true when only first is true', () {
      final RuntimeFacade runtime = getRuntime('main = bool.xor(true, false)');
      checkResult(runtime, true);
    });

    test('bool.xor returns true when only second is true', () {
      final RuntimeFacade runtime = getRuntime('main = bool.xor(false, true)');
      checkResult(runtime, true);
    });

    test('bool.xor returns false when both are false', () {
      final RuntimeFacade runtime = getRuntime('main = bool.xor(false, false)');
      checkResult(runtime, false);
    });

    test('bool.not negates true to false', () {
      final RuntimeFacade runtime = getRuntime('main = bool.not(true)');
      checkResult(runtime, false);
    });

    test('bool.not negates false to true', () {
      final RuntimeFacade runtime = getRuntime('main = bool.not(false)');
      checkResult(runtime, true);
    });
  });

  group('Logic Type Errors', () {
    test('bool.and throws for number arguments', () {
      final RuntimeFacade runtime = getRuntime('main = bool.and(1, 2)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool.or throws for number arguments', () {
      final RuntimeFacade runtime = getRuntime('main = bool.or(1, 2)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool.not throws for number argument', () {
      final RuntimeFacade runtime = getRuntime('main = bool.not(1)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool.xor throws for string arguments', () {
      final RuntimeFacade runtime = getRuntime('main = bool.xor("a", "b")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });
}
