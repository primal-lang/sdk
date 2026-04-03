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
  });
}
