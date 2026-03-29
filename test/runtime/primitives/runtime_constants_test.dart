import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Constants', () {
    test('boolean true', () {
      final Runtime runtime = getRuntime('main = true');
      checkResult(runtime, true);
    });

    test('boolean false', () {
      final Runtime runtime = getRuntime('main = false');
      checkResult(runtime, false);
    });

    test('positive integer', () {
      final Runtime runtime = getRuntime('main = 42');
      checkResult(runtime, 42);
    });

    test('zero', () {
      final Runtime runtime = getRuntime('main = 0');
      checkResult(runtime, 0);
    });

    test('negative integer', () {
      final Runtime runtime = getRuntime('main = -7');
      checkResult(runtime, -7);
    });

    test('decimal number', () {
      final Runtime runtime = getRuntime('main = 3.14');
      checkResult(runtime, 3.14);
    });

    test('string', () {
      final Runtime runtime = getRuntime('main = "Hello"');
      checkResult(runtime, '"Hello"');
    });

    test('empty string', () {
      final Runtime runtime = getRuntime('main = ""');
      checkResult(runtime, '""');
    });

    test('list of numbers', () {
      final Runtime runtime = getRuntime('main = [1, 2, 3]');
      checkResult(runtime, [1, 2, 3]);
    });

    test('empty list', () {
      final Runtime runtime = getRuntime('main = []');
      checkResult(runtime, []);
    });

    test('nested list', () {
      final Runtime runtime = getRuntime('main = [[1, 2], [3, 4]]');
      checkResult(runtime, [[1, 2], [3, 4]]);
    });

    test('list of mixed types', () {
      final Runtime runtime = getRuntime('main = [1, "two", true]');
      checkResult(runtime, [1, '"two"', true]);
    });
  });
}
