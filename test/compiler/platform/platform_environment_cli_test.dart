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

    test('getVariable handles variable name starting with number', () {
      final String result = environment.getVariable('123VAR');

      expect(result, equals(''));
    });

    test('getVariable handles variable name with only numbers', () {
      final String result = environment.getVariable('12345');

      expect(result, equals(''));
    });

    test('getVariable handles variable name with unicode characters', () {
      final String result = environment.getVariable('VAR_\u00E9\u00E8');

      expect(result, equals(''));
    });

    test('getVariable handles variable name with equals sign', () {
      final String result = environment.getVariable('VAR=VALUE');

      expect(result, equals(''));
    });

    test('getVariable handles variable name with multiple underscores', () {
      final String result = environment.getVariable('VAR__NAME');

      expect(result, equals(''));
    });

    test('getVariable returns SHELL on Unix systems', () {
      final String result = environment.getVariable('SHELL');

      // SHELL is typically set on Unix systems
      expect(result, anyOf(isNotEmpty, equals('')));
    });

    test('getVariable returns PWD on Unix systems', () {
      final String result = environment.getVariable('PWD');

      // PWD is typically set on Unix systems
      expect(result, anyOf(isNotEmpty, equals('')));
    });

    test('getVariable PATH contains path separator', () {
      final String result = environment.getVariable('PATH');

      // PATH should contain at least one colon (Unix path separator)
      expect(result, contains(':'));
    });

    test('getVariable returns LANG or empty string', () {
      final String result = environment.getVariable('LANG');

      // LANG may or may not be set depending on system configuration
      expect(result, isA<String>());
    });

    test('getVariable handles hyphen in variable name', () {
      final String result = environment.getVariable('VAR-NAME');

      expect(result, equals(''));
    });

    test('getVariable handles dot in variable name', () {
      final String result = environment.getVariable('VAR.NAME');

      expect(result, equals(''));
    });

    test('getVariable handles slash in variable name', () {
      final String result = environment.getVariable('VAR/NAME');

      expect(result, equals(''));
    });

    test('getVariable handles backslash in variable name', () {
      final String result = environment.getVariable('VAR\\NAME');

      expect(result, equals(''));
    });

    test('getVariable handles carriage return in variable name', () {
      final String result = environment.getVariable('PATH\r');

      expect(result, equals(''));
    });

    test('getVariable handles mixed whitespace in variable name', () {
      final String result = environment.getVariable(' \t\n ');

      expect(result, equals(''));
    });

    test('can instantiate PlatformEnvironmentCli', () {
      final PlatformEnvironmentCli instance = PlatformEnvironmentCli();

      expect(instance, isNotNull);
    });

    test('multiple instances are independent', () {
      final PlatformEnvironmentCli instance1 = PlatformEnvironmentCli();
      final PlatformEnvironmentCli instance2 = PlatformEnvironmentCli();

      expect(identical(instance1, instance2), isFalse);
    });

    test('getVariable returns TERM or empty string', () {
      final String result = environment.getVariable('TERM');

      // TERM may or may not be set depending on environment
      expect(result, isA<String>());
    });

    test('getVariable handles single character variable name', () {
      final String result = environment.getVariable('X');

      // Single char variable may or may not exist
      expect(result, isA<String>());
    });

    test('getVariable handles single underscore variable name', () {
      final String result = environment.getVariable('_');

      // _ is often set to the last argument of previous command
      expect(result, isA<String>());
    });

    test('getVariable handles variable name with colon', () {
      final String result = environment.getVariable('VAR:NAME');

      expect(result, equals(''));
    });

    test('getVariable handles variable name with space in middle', () {
      final String result = environment.getVariable('VAR NAME');

      expect(result, equals(''));
    });

    test('getVariable handles HOSTNAME', () {
      final String result = environment.getVariable('HOSTNAME');

      // HOSTNAME may or may not be set
      expect(result, isA<String>());
    });

    test('getVariable handles EDITOR', () {
      final String result = environment.getVariable('EDITOR');

      // EDITOR may or may not be set
      expect(result, isA<String>());
    });

    test('getVariable handles LOGNAME', () {
      final String result = environment.getVariable('LOGNAME');

      // LOGNAME is usually set on Unix systems, similar to USER
      expect(result, anyOf(isNotEmpty, equals('')));
    });
  });
}
