@Tags(['runtime', 'io'])
@TestOn('vm')
library;

import 'dart:io';

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Environment', () {
    group('env.get', () {
      test('returns empty string for non-existent variable', () {
        final RuntimeFacade runtime = getRuntime(
          'main = env.get("INVALID_VARIABLE")',
        );
        checkResult(runtime, '""');
      });

      test('returns value of existing variable HOME', () {
        final String home = Platform.environment['HOME'] ?? '';
        final RuntimeFacade runtime = getRuntime('main = env.get("HOME")');
        checkResult(runtime, '"$home"');
      });

      test('returns value of existing variable PATH', () {
        final String path = Platform.environment['PATH'] ?? '';
        final RuntimeFacade runtime = getRuntime('main = env.get("PATH")');
        checkResult(runtime, '"$path"');
      });

      test('returns value of existing variable USER', () {
        final String user = Platform.environment['USER'] ?? '';
        final RuntimeFacade runtime = getRuntime('main = env.get("USER")');
        checkResult(runtime, '"$user"');
      });

      test('returns empty string for empty variable name', () {
        final RuntimeFacade runtime = getRuntime('main = env.get("")');
        checkResult(runtime, '""');
      });

      test('is case-sensitive for variable names', () {
        final String home = Platform.environment['HOME'] ?? '';
        final RuntimeFacade runtimeLower = getRuntime('main = env.get("home")');
        final RuntimeFacade runtimeUpper = getRuntime('main = env.get("HOME")');
        // On Unix systems, HOME exists but home likely does not
        checkResult(runtimeUpper, '"$home"');
        // home (lowercase) should return empty string if not set
        final String homeLower = Platform.environment['home'] ?? '';
        checkResult(runtimeLower, '"$homeLower"');
      });

      test('returns empty string for variable name with only spaces', () {
        final RuntimeFacade runtime = getRuntime('main = env.get("   ")');
        checkResult(runtime, '""');
      });

      test('handles variable names with underscores', () {
        // LC_ALL is a common environment variable with underscore
        final String lcAll = Platform.environment['LC_ALL'] ?? '';
        final RuntimeFacade runtime = getRuntime('main = env.get("LC_ALL")');
        checkResult(runtime, '"$lcAll"');
      });
    });

    group('env.get type errors', () {
      test('throws InvalidArgumentTypesError when given a number', () {
        final RuntimeFacade runtime = getRuntime('main = env.get(42)');
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('function "env.get"'),
                contains('Expected: (String)'),
                contains('Actual: (Number)'),
              ),
            ),
          ),
        );
      });

      test('throws InvalidArgumentTypesError when given a boolean', () {
        final RuntimeFacade runtime = getRuntime('main = env.get(true)');
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('function "env.get"'),
                contains('Expected: (String)'),
                contains('Actual: (Boolean)'),
              ),
            ),
          ),
        );
      });

      test('throws InvalidArgumentTypesError when given a list', () {
        final RuntimeFacade runtime = getRuntime('main = env.get(["HOME"])');
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('function "env.get"'),
                contains('Expected: (String)'),
                contains('Actual: (List)'),
              ),
            ),
          ),
        );
      });

      test('throws InvalidArgumentTypesError when given a map', () {
        final RuntimeFacade runtime = getRuntime(
          'main = env.get({"key": "value"})',
        );
        expect(
          runtime.executeMain,
          throwsA(
            isA<InvalidArgumentTypesError>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('function "env.get"'),
                contains('Expected: (String)'),
                contains('Actual: (Map)'),
              ),
            ),
          ),
        );
      });
    });
  });
}
