import 'package:primal/compiler/library/error/throw.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../utils/test_utils.dart';

void main() {
  group('Control', () {
    test('if/else 1', () {
      final Runtime runtime = getRuntime('main = if (true) "yes" else "no"');
      checkResult(runtime, '"yes"');
    });

    test('if/else 2', () {
      final Runtime runtime = getRuntime('main = if (false) "yes" else "no"');
      checkResult(runtime, '"no"');
    });

    test('if/else 3', () {
      final Runtime runtime = getRuntime('main = if (true) 1 + 2 else 42');
      checkResult(runtime, 3);
    });
  });

  group('Try/Catch', () {
    test('try/catch 1', () {
      final Runtime runtime = getRuntime('main = try(1 / 2, 42)');
      checkResult(runtime, 0.5);
    });

    test('try/catch 2', () {
      final Runtime runtime = getRuntime(
        'main = try(error.throw(0, "Does not compute"), 42)',
      );
      checkResult(runtime, 42);
    });
  });

  group('Error', () {
    test('throw', () {
      final Runtime runtime = getRuntime(
        'main = error.throw(-1, "Segmentation fault")',
      );
      expect(runtime.executeMain, throwsA(isA<CustomError>()));
    });
  });
}
