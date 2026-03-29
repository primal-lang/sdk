import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Main', () {
    test('parameterless main returns constant', () {
      final Runtime runtime = getRuntime('main = 42');
      checkResult(runtime, 42);
    });

    test('main with single argument', () {
      final Runtime runtime = getRuntime('main(a) = a');
      expect(runtime.executeMain(['hello']), '"hello"');
    });

    test('main with multiple arguments', () {
      final Runtime runtime = getRuntime(
        'main(a, b, c) = to.string(a) + to.string(b) + to.string(c)',
      );
      expect(runtime.executeMain(['aaa', 'bbb', 'ccc']), '"aaabbbccc"');
    });

    test('main calls custom helper function', () {
      final Runtime runtime = getRuntime(
        'double(x) = x * 2\nmain = double(5)',
      );
      checkResult(runtime, 10);
    });

    test('hasMain is true when main is defined', () {
      final Runtime runtime = getRuntime('main = 1');
      expect(runtime.hasMain, true);
    });

    test('hasMain is false when main is not defined', () {
      final Runtime runtime = getRuntime('f(x) = x');
      expect(runtime.hasMain, false);
    });
  });
}
