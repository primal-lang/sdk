import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../utils/test_utils.dart';

void main() {
  group('Logic', () {
    test('bool.and 1', () {
      final Runtime runtime = getRuntime('main = bool.and(true, true)');
      checkResult(runtime, true);
    });

    test('bool.and 2', () {
      final Runtime runtime = getRuntime('main = bool.and(false, true)');
      checkResult(runtime, false);
    });

    test('bool.and 3', () {
      final Runtime runtime = getRuntime('main = bool.and(true, false)');
      checkResult(runtime, false);
    });

    test('bool.and 4', () {
      final Runtime runtime = getRuntime('main = bool.and(false, false)');
      checkResult(runtime, false);
    });

    test('bool.or 1', () {
      final Runtime runtime = getRuntime('main = bool.or(true, true)');
      checkResult(runtime, true);
    });

    test('bool.or 2', () {
      final Runtime runtime = getRuntime('main = bool.or(true, false)');
      checkResult(runtime, true);
    });

    test('bool.or 3', () {
      final Runtime runtime = getRuntime('main = bool.or(false, true)');
      checkResult(runtime, true);
    });

    test('bool.or 4', () {
      final Runtime runtime = getRuntime('main = bool.or(false, false)');
      checkResult(runtime, false);
    });

    test('bool.xor 1', () {
      final Runtime runtime = getRuntime('main = bool.xor(true, true)');
      checkResult(runtime, false);
    });

    test('bool.xor 2', () {
      final Runtime runtime = getRuntime('main = bool.xor(true, false)');
      checkResult(runtime, true);
    });

    test('bool.xor 3', () {
      final Runtime runtime = getRuntime('main = bool.xor(false, true)');
      checkResult(runtime, true);
    });

    test('bool.xor 4', () {
      final Runtime runtime = getRuntime('main = bool.xor(false, false)');
      checkResult(runtime, false);
    });

    test('bool.not 1', () {
      final Runtime runtime = getRuntime('main = bool.not(true)');
      checkResult(runtime, false);
    });

    test('bool.not 2', () {
      final Runtime runtime = getRuntime('main = bool.not(false)');
      checkResult(runtime, true);
    });
  });

  group('Logic Type Errors', () {
    test('bool.and throws for number arguments', () {
      final Runtime runtime = getRuntime('main = bool.and(1, 2)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool.or throws for number arguments', () {
      final Runtime runtime = getRuntime('main = bool.or(1, 2)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool.not throws for number argument', () {
      final Runtime runtime = getRuntime('main = bool.not(1)');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });

    test('bool.xor throws for string arguments', () {
      final Runtime runtime = getRuntime('main = bool.xor("a", "b")');
      expect(runtime.executeMain, throwsA(isA<InvalidArgumentTypesError>()));
    });
  });
}
