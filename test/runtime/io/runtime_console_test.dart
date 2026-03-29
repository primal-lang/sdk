import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Console', () {
    test('console.write outputs string', () {
      final Runtime runtime = getRuntime(
        'main = console.write("Enter in function")',
      );
      checkResult(runtime, '"Enter in function"');
    });

    test('console.writeLn outputs string with newline', () {
      final Runtime runtime = getRuntime(
        'main = console.writeLn("Enter in function")',
      );
      checkResult(runtime, '"Enter in function"');
    });

    test('console.write with number argument', () {
      final Runtime runtime = getRuntime('main = console.write(42)');
      checkResult(runtime, 42);
    });

    test('console.writeLn with boolean argument', () {
      final Runtime runtime = getRuntime('main = console.writeLn(true)');
      checkResult(runtime, true);
    });

    test('console.write with expression result', () {
      final Runtime runtime = getRuntime(
        'main = console.write(1 + 2)',
      );
      checkResult(runtime, 3);
    });
  });
}
