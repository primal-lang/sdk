import 'dart:io';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../test_utils.dart';

void main() {
  group('Environment', () {
    test('env.get 1', () {
      final Runtime runtime = getRuntime('main = env.get("INVALID_VARIABLE")');
      checkResult(runtime, '""');
    });

    test('env.get 2', () {
      final String username = Platform.environment['USERNAME'] ?? '';
      final Runtime runtime = getRuntime('main = env.get("USERNAME")');
      checkResult(runtime, '"$username"');
    });
  });
}
