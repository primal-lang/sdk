@Tags(['unit'])
@TestOn('vm')
library;

import 'package:primal/compiler/platform/environment/platform_environment_base.dart';
import 'package:primal/compiler/platform/environment/platform_environment_cli.dart';
import 'package:test/test.dart';

void main() {
  late PlatformEnvironmentCli environment;

  setUp(() {
    environment = PlatformEnvironmentCli();
  });

  group('PlatformEnvironmentCli', () {
    test('getVariable returns value for existing variable', () {
      // PATH is available on all Unix-like systems
      final String result = environment.getVariable('PATH');

      expect(result, isNotEmpty);
    });

    test('getVariable returns empty string for nonexistent variable', () {
      final String result = environment.getVariable(
        'PRIMAL_SDK_NONEXISTENT_VAR_12345',
      );

      expect(result, equals(''));
    });

    test('getVariable returns HOME', () {
      final String result = environment.getVariable('HOME');

      expect(result, isNotEmpty);
    });

    test('getVariable returns empty string for empty variable name', () {
      final String result = environment.getVariable('');

      expect(result, equals(''));
    });

    test('getVariable returns consistent results for repeated calls', () {
      final String firstResult = environment.getVariable('PATH');
      final String secondResult = environment.getVariable('PATH');

      expect(firstResult, equals(secondResult));
    });

    test('getVariable is case sensitive', () {
      // PATH exists, path typically does not on Unix systems
      final String upperCase = environment.getVariable('PATH');
      final String lowerCase = environment.getVariable('path');

      expect(upperCase, isNotEmpty);
      expect(lowerCase, equals(''));
    });

    test(
      'getVariable returns empty for variable name with special characters',
      () {
        final String result = environment.getVariable('!@#\$%^&*()');

        expect(result, equals(''));
      },
    );

    test('getVariable returns USER', () {
      final String result = environment.getVariable('USER');

      expect(result, isNotEmpty);
    });

    test('extends PlatformEnvironmentBase', () {
      expect(environment, isA<PlatformEnvironmentBase>());
    });

    test('getVariable returns empty for whitespace-only variable name', () {
      final String resultWithSpace = environment.getVariable(' ');
      final String resultWithTab = environment.getVariable('\t');
      final String resultWithSpaces = environment.getVariable('   ');

      expect(resultWithSpace, equals(''));
      expect(resultWithTab, equals(''));
      expect(resultWithSpaces, equals(''));
    });

    test(
      'getVariable returns empty for variable name with leading whitespace',
      () {
        final String result = environment.getVariable(' PATH');

        expect(result, equals(''));
      },
    );

    test(
      'getVariable returns empty for variable name with trailing whitespace',
      () {
        final String result = environment.getVariable('PATH ');

        expect(result, equals(''));
      },
    );

    test(
      'getVariable returns empty for very long nonexistent variable name',
      () {
        final String longVariableName = 'PRIMAL_TEST_' * 100;
        final String result = environment.getVariable(longVariableName);

        expect(result, equals(''));
      },
    );

    test('getVariable returns empty for variable name with newline', () {
      final String result = environment.getVariable('PATH\n');

      expect(result, equals(''));
    });

    test('getVariable returns empty for variable name with null character', () {
      final String result = environment.getVariable('PATH\x00');

      expect(result, equals(''));
    });

    test('different instances return same values for same variable', () {
      final PlatformEnvironmentCli anotherEnvironment =
          PlatformEnvironmentCli();
      final String firstResult = environment.getVariable('PATH');
      final String secondResult = anotherEnvironment.getVariable('PATH');

      expect(firstResult, equals(secondResult));
    });

    test('getVariable handles variable name with underscore', () {
      // Many environment variables contain underscores
      final String result = environment.getVariable(
        'PRIMAL_SDK_NONEXISTENT_VAR',
      );

      expect(result, equals(''));
    });

    test('getVariable handles variable name with numbers', () {
      final String result = environment.getVariable('VAR123');

      expect(result, equals(''));
    });
  });
}
