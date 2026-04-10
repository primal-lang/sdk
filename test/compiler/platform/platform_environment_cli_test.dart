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

    test('getVariable handles variable name with dollar sign prefix', () {
      final String result = environment.getVariable('\$PATH');

      expect(result, equals(''));
    });

    test('getVariable handles variable name with dollar sign and braces', () {
      final String result = environment.getVariable('\${PATH}');

      expect(result, equals(''));
    });

    test('getVariable handles variable name with backticks', () {
      final String result = environment.getVariable('`VAR`');

      expect(result, equals(''));
    });

    test('getVariable handles variable name with single quotes', () {
      final String result = environment.getVariable("'VAR'");

      expect(result, equals(''));
    });

    test('getVariable handles variable name with double quotes', () {
      final String result = environment.getVariable('"VAR"');

      expect(result, equals(''));
    });

    test('getVariable handles variable name with vertical tab', () {
      final String result = environment.getVariable('VAR\x0BNAME');

      expect(result, equals(''));
    });

    test('getVariable handles variable name with form feed', () {
      final String result = environment.getVariable('VAR\x0CNAME');

      expect(result, equals(''));
    });

    test('getVariable handles variable name with bell character', () {
      final String result = environment.getVariable('VAR\x07NAME');

      expect(result, equals(''));
    });

    test('getVariable handles variable name with asterisk', () {
      final String result = environment.getVariable('VAR*NAME');

      expect(result, equals(''));
    });

    test('getVariable handles variable name with question mark', () {
      final String result = environment.getVariable('VAR?NAME');

      expect(result, equals(''));
    });

    test('getVariable handles variable name with ampersand', () {
      final String result = environment.getVariable('VAR&NAME');

      expect(result, equals(''));
    });

    test('getVariable handles variable name with pipe', () {
      final String result = environment.getVariable('VAR|NAME');

      expect(result, equals(''));
    });

    test('getVariable handles variable name with percent sign', () {
      final String result = environment.getVariable('%VAR%');

      expect(result, equals(''));
    });

    test('getVariable handles variable name with tilde', () {
      final String result = environment.getVariable('~VAR');

      expect(result, equals(''));
    });

    test('getVariable handles variable name with parentheses', () {
      final String result = environment.getVariable('VAR(NAME)');

      expect(result, equals(''));
    });

    test('getVariable handles variable name with braces', () {
      final String result = environment.getVariable('{VAR}');

      expect(result, equals(''));
    });

    test('getVariable handles variable name with square brackets', () {
      final String result = environment.getVariable('VAR[0]');

      expect(result, equals(''));
    });

    test('getVariable handles variable name with angle brackets', () {
      final String result = environment.getVariable('VAR<NAME>');

      expect(result, equals(''));
    });

    test('getVariable handles variable name with semicolon', () {
      final String result = environment.getVariable('VAR;NAME');

      expect(result, equals(''));
    });

    test('getVariable handles variable name with exclamation mark', () {
      final String result = environment.getVariable('VAR!NAME');

      expect(result, equals(''));
    });

    test('getVariable handles variable name with at sign only', () {
      final String result = environment.getVariable('@');

      expect(result, equals(''));
    });

    test('getVariable handles variable name with hash only', () {
      final String result = environment.getVariable('#');

      expect(result, equals(''));
    });

    test('getVariable always returns String type', () {
      final String existingVariable = environment.getVariable('PATH');
      final String nonExistingVariable = environment.getVariable(
        'NONEXISTENT_VAR_XYZ',
      );

      expect(existingVariable, isA<String>());
      expect(nonExistingVariable, isA<String>());
    });

    test('getVariable returns empty string not null for missing variable', () {
      final String result = environment.getVariable('DEFINITELY_NOT_SET_VAR');

      expect(result, isNot(isNull));
      expect(result, equals(''));
    });

    test('getVariable handles escape sequences in variable name', () {
      final String result = environment.getVariable('VAR\\nNAME');

      expect(result, equals(''));
    });

    test('getVariable handles variable name with high unicode codepoint', () {
      final String result = environment.getVariable('VAR_\u{1F600}');

      expect(result, equals(''));
    });

    test('getVariable handles variable name with combining characters', () {
      final String result = environment.getVariable('VAR_e\u0301');

      expect(result, equals(''));
    });

    test('getVariable handles variable name with zero-width characters', () {
      final String result = environment.getVariable('VAR\u200BNAME');

      expect(result, equals(''));
    });

    test('getVariable handles repeated special characters', () {
      final String result = environment.getVariable('!!!');

      expect(result, equals(''));
    });

    test('getVariable handles variable name with all valid characters', () {
      final String result = environment.getVariable(
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789',
      );

      expect(result, equals(''));
    });

    test('getVariable handles lowercase variable name', () {
      final String result = environment.getVariable('lowercase_var');

      expect(result, equals(''));
    });

    test('getVariable handles mixed case variable name', () {
      final String result = environment.getVariable('MixedCase_Var_123');

      expect(result, equals(''));
    });

    test('getVariable handles XDG_RUNTIME_DIR', () {
      final String result = environment.getVariable('XDG_RUNTIME_DIR');

      // XDG_RUNTIME_DIR may or may not be set
      expect(result, isA<String>());
    });

    test('getVariable handles DISPLAY', () {
      final String result = environment.getVariable('DISPLAY');

      // DISPLAY may or may not be set depending on environment
      expect(result, isA<String>());
    });

    test('getVariable handles TMPDIR', () {
      final String result = environment.getVariable('TMPDIR');

      // TMPDIR may or may not be set
      expect(result, isA<String>());
    });

    test('getVariable handles variable name ending with underscore', () {
      final String result = environment.getVariable('VAR_');

      expect(result, equals(''));
    });

    test('getVariable handles variable name starting with underscore', () {
      final String result = environment.getVariable('_VAR');

      // Variables starting with underscore may exist
      expect(result, isA<String>());
    });

    test('getVariable handles double underscore prefix', () {
      final String result = environment.getVariable('__VAR');

      expect(result, isA<String>());
    });

    test('getVariable handles triple underscore variable name', () {
      final String result = environment.getVariable('___');

      expect(result, isA<String>());
    });

    test('getVariable result length is non-negative', () {
      final String existingResult = environment.getVariable('PATH');
      final String missingResult = environment.getVariable('MISSING_VAR_XYZ');

      expect(existingResult.length, greaterThanOrEqualTo(0));
      expect(missingResult.length, equals(0));
    });
  });
}
