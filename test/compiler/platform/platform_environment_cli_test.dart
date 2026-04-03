@Tags(['unit'])
@TestOn('vm')
library;

import 'package:primal/compiler/platform/environment/platform_environment_cli.dart';
import 'package:test/test.dart';

void main() {
  late PlatformEnvironmentCli env;

  setUp(() {
    env = PlatformEnvironmentCli();
  });

  group('PlatformEnvironmentCli', () {
    test('getVariable returns value for existing variable', () {
      // PATH is available on all Unix-like systems
      final String result = env.getVariable('PATH');

      expect(result, isNotEmpty);
    });

    test('getVariable returns empty string for nonexistent variable', () {
      final String result = env.getVariable('PRIMAL_SDK_NONEXISTENT_VAR_12345');

      expect(result, equals(''));
    });

    test('getVariable returns HOME', () {
      final String result = env.getVariable('HOME');

      expect(result, isNotEmpty);
    });
  });
}
