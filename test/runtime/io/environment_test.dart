@Tags(['runtime', 'io'])
@TestOn('vm')
library;

import 'dart:io';

import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Environment', () {
    test('env.get returns empty string for non-existent variable', () {
      final Runtime runtime = getRuntime('main = env.get("INVALID_VARIABLE")');
      checkResult(runtime, '""');
    });

    test('env.get returns value of existing variable', () {
      final String home = Platform.environment['HOME'] ?? '';
      final Runtime runtime = getRuntime('main = env.get("HOME")');
      checkResult(runtime, '"$home"');
    });

    test('env.get returns empty string for empty variable name', () {
      final Runtime runtime = getRuntime('main = env.get("")');
      checkResult(runtime, '""');
    });
  });
}
