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

    test('handles multiline message', () {
      const warning = GenericWarning('line one\nline two\nline three');

      expect(warning.message, equals('line one\nline two\nline three'));
      expect(
        warning.toString(),
        equals('Warning: line one\nline two\nline three'),
      );
    });

    test('const instances with same message are identical', () {
      const warning1 = GenericWarning('same message');
      const warning2 = GenericWarning('same message');

      expect(identical(warning1, warning2), isTrue);
    });

    test('handles very long message', () {
      final String longMessage = 'a' * 1000;
      final GenericWarning warning = GenericWarning(longMessage);

      expect(warning.message.length, equals(1000));
      expect(warning.toString(), equals('Warning: $longMessage'));
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

    test('handles message with special characters', () {
      const warning = SemanticWarning('contains "quotes" and \$pecial chars');

      expect(warning.message, equals('contains "quotes" and \$pecial chars'));
      expect(
        warning.toString(),
        equals('Warning: contains "quotes" and \$pecial chars'),
      );
    });

    test('handles multiline message', () {
      const warning = SemanticWarning('line one\nline two');

      expect(warning.message, equals('line one\nline two'));
      expect(warning.toString(), equals('Warning: line one\nline two'));
    });

    test('const instances with same message are identical', () {
      const warning1 = SemanticWarning('same message');
      const warning2 = SemanticWarning('same message');

      expect(identical(warning1, warning2), isTrue);
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

    test('handles both empty function and parameter names', () {
      const warning = UnusedParameterWarning(
        function: '',
        parameter: '',
      );

      expect(
        warning.toString(),
        equals('Warning: Unused parameter "" in function ""'),
      );
    });

    test('const instances with same parameters are identical', () {
      const warning1 = UnusedParameterWarning(
        function: 'func',
        parameter: 'param',
      );
      const warning2 = UnusedParameterWarning(
        function: 'func',
        parameter: 'param',
      );

      expect(identical(warning1, warning2), isTrue);
    });

    test('handles long function and parameter names', () {
      final String longFunctionName = 'f' * 100;
      final String longParameterName = 'p' * 100;
      final UnusedParameterWarning warning = UnusedParameterWarning(
        function: longFunctionName,
        parameter: longParameterName,
      );

      expect(
        warning.message,
        equals(
          'Unused parameter "$longParameterName" in function "$longFunctionName"',
        ),
      );
    });

    test('handles function name with quotes', () {
      const warning = UnusedParameterWarning(
        function: 'with"quotes',
        parameter: 'x',
      );

      expect(
        warning.toString(),
        equals('Warning: Unused parameter "x" in function "with"quotes"'),
      );
    });

    test('handles parameter name with quotes', () {
      const warning = UnusedParameterWarning(
        function: 'test',
        parameter: 'has"quote',
      );

      expect(
        warning.toString(),
        equals('Warning: Unused parameter "has"quote" in function "test"'),
      );
    });
  });
}
