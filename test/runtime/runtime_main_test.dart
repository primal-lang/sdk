import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../helpers/pipeline_helpers.dart';

void main() {
  group('Main', () {
    test('main', () {
      final Runtime runtime = getRuntime(
        'main(a, b, c) = to.string(a) + to.string(b) + to.string(c)',
      );
      expect(runtime.executeMain(['aaa', 'bbb', 'ccc']), '"aaabbbccc"');
    });
  });
}
