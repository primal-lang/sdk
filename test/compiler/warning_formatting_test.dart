@Tags(['compiler'])
library;

import 'package:primal/compiler/warnings/generic_warning.dart';
import 'package:primal/compiler/warnings/semantic_warning.dart';
import 'package:test/test.dart';

void main() {
  group('GenericWarning', () {
    test('toString() returns "Warning: message"', () {
      const warning = GenericWarning('something looks off');

      expect(warning.toString(), equals('Warning: something looks off'));
    });

    test('errorType is "Warning"', () {
      const warning = GenericWarning('test');

      expect(warning.errorType, equals('Warning'));
    });

    test('message is preserved', () {
      const warning = GenericWarning('check this');

      expect(warning.message, equals('check this'));
    });

    test('implements Exception', () {
      const warning = GenericWarning('test');

      expect(warning, isA<Exception>());
    });

    test('handles empty message', () {
      const warning = GenericWarning('');

      expect(warning.toString(), equals('Warning: '));
      expect(warning.message, equals(''));
    });

    test('handles message with special characters', () {
      const warning = GenericWarning('contains "quotes" and \$pecial chars');

      expect(warning.message, equals('contains "quotes" and \$pecial chars'));
      expect(
        warning.toString(),
        equals('Warning: contains "quotes" and \$pecial chars'),
      );
    });
  });

  group('SemanticWarning', () {
    test('toString() returns "Warning: message"', () {
      const warning = SemanticWarning('unused variable');

      expect(warning.toString(), equals('Warning: unused variable'));
    });

    test('is a GenericWarning', () {
      const warning = SemanticWarning('test');

      expect(warning, isA<GenericWarning>());
    });

    test('implements Exception', () {
      const warning = SemanticWarning('test');

      expect(warning, isA<Exception>());
    });

    test('errorType is "Warning"', () {
      const warning = SemanticWarning('test');

      expect(warning.errorType, equals('Warning'));
    });

    test('message is preserved', () {
      const warning = SemanticWarning('some warning message');

      expect(warning.message, equals('some warning message'));
    });

    test('handles empty message', () {
      const warning = SemanticWarning('');

      expect(warning.toString(), equals('Warning: '));
      expect(warning.message, equals(''));
    });
  });

  group('UnusedParameterWarning', () {
    test('toString() includes function and parameter names', () {
      const warning = UnusedParameterWarning(
        function: 'add',
        parameter: 'y',
      );

      expect(
        warning.toString(),
        equals('Warning: Unused parameter "y" in function "add"'),
      );
    });

    test('is a SemanticWarning', () {
      const warning = UnusedParameterWarning(
        function: 'f',
        parameter: 'x',
      );

      expect(warning, isA<SemanticWarning>());
    });

    test('is a GenericWarning', () {
      const warning = UnusedParameterWarning(
        function: 'f',
        parameter: 'x',
      );

      expect(warning, isA<GenericWarning>());
    });

    test('implements Exception', () {
      const warning = UnusedParameterWarning(
        function: 'f',
        parameter: 'x',
      );

      expect(warning, isA<Exception>());
    });

    test('errorType is "Warning"', () {
      const warning = UnusedParameterWarning(
        function: 'calculate',
        parameter: 'value',
      );

      expect(warning.errorType, equals('Warning'));
    });

    test('message contains formatted parameter and function names', () {
      const warning = UnusedParameterWarning(
        function: 'multiply',
        parameter: 'factor',
      );

      expect(
        warning.message,
        equals('Unused parameter "factor" in function "multiply"'),
      );
    });

    test('handles empty function name', () {
      const warning = UnusedParameterWarning(
        function: '',
        parameter: 'x',
      );

      expect(
        warning.toString(),
        equals('Warning: Unused parameter "x" in function ""'),
      );
    });

    test('handles empty parameter name', () {
      const warning = UnusedParameterWarning(
        function: 'test',
        parameter: '',
      );

      expect(
        warning.toString(),
        equals('Warning: Unused parameter "" in function "test"'),
      );
    });

    test('handles special characters in function name', () {
      const warning = UnusedParameterWarning(
        function: 'my_function',
        parameter: 'arg',
      );

      expect(
        warning.toString(),
        equals('Warning: Unused parameter "arg" in function "my_function"'),
      );
    });

    test('handles special characters in parameter name', () {
      const warning = UnusedParameterWarning(
        function: 'test',
        parameter: 'some_param',
      );

      expect(
        warning.toString(),
        equals('Warning: Unused parameter "some_param" in function "test"'),
      );
    });
  });
}
