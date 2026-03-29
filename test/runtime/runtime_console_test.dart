import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../utils/test_utils.dart';

void main() {
  group('Console', () {
    test('console.write', () {
      final Runtime runtime = getRuntime(
        'main = console.write("Enter in function")',
      );
      checkResult(runtime, '"Enter in function"');
    });

    test('console.writeLn', () {
      final Runtime runtime = getRuntime(
        'main = console.writeLn("Enter in function")',
      );
      checkResult(runtime, '"Enter in function"');
    });
  });
}
