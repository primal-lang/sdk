@Tags(['runtime'])
library;

import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Lazy Evaluation', () {
    test('if true does not evaluate else branch', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (true) 1 else error.throw(-1, "Error")',
      );
      checkResult(runtime, 1);
    });

    test('if false does not evaluate then branch', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (false) error.throw(-1, "Error") else 2',
      );
      checkResult(runtime, 2);
    });

    test('nested if with lazy outer else', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (true) (if (true) 1 else 2) else error.throw(-1, "Error")',
      );
      checkResult(runtime, 1);
    });

    test('nested if with lazy inner else', () {
      final RuntimeFacade runtime = getRuntime(
        'main = if (true) (if (true) 1 else error.throw(-1, "Error")) else 0',
      );
      checkResult(runtime, 1);
    });

    test('try does not propagate caught error', () {
      final RuntimeFacade runtime = getRuntime(
        'main = try(error.throw(-1, "Fail"), 42)',
      );
      checkResult(runtime, 42);
    });

    test('try returns value when no error', () {
      final RuntimeFacade runtime = getRuntime('main = try(10, -1)');
      checkResult(runtime, 10);
    });
  });
}
