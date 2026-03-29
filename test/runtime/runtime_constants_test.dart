import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../helpers/assertion_helpers.dart';
import '../helpers/pipeline_helpers.dart';

void main() {
  group('Constants', () {
    test('Boolean', () {
      final Runtime runtime = getRuntime('main = true');
      checkResult(runtime, true);
    });

    test('Number', () {
      final Runtime runtime = getRuntime('main = 42');
      checkResult(runtime, 42);
    });

    test('String', () {
      final Runtime runtime = getRuntime('main = "Hello"');
      checkResult(runtime, '"Hello"');
    });

    test('List', () {
      final Runtime runtime = getRuntime('main = [1, 2, 3]');
      checkResult(runtime, [1, 2, 3]);
    });
  });
}
