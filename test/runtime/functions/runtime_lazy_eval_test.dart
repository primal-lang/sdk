import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Lazy Evaluation', () {
    test('if true does not evaluate else branch', () {
      final Runtime runtime = getRuntime(
        'main = if (true) 1 else error.throw(-1, "Error")',
      );
      checkResult(runtime, 1);
    });

    test('if false does not evaluate then branch', () {
      final Runtime runtime = getRuntime(
        'main = if (false) error.throw(-1, "Error") else 2',
      );
      checkResult(runtime, 2);
    });
  });
}
