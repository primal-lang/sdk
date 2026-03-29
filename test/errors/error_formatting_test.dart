@Tags(['unit'])
library;

import 'package:primal/compiler/errors/generic_error.dart';
import 'package:primal/compiler/errors/lexical_error.dart';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/errors/semantic_error.dart';
import 'package:primal/compiler/errors/syntactic_error.dart';
import 'package:primal/compiler/models/location.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/models/type.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/scanner/character.dart';
import 'package:test/test.dart';

import '../helpers/token_factories.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Base classes
  // ---------------------------------------------------------------------------

  group('GenericError', () {
    test('toString() returns "errorType: message"', () {
      const error = GenericError('Custom error', 'something went wrong');

      expect(error.toString(), equals('Custom error: something went wrong'));
    });
  });

  group('CompilationError', () {
    test('has errorType "Compilation error"', () {
      const error = CompilationError('bad syntax');

      expect(error.errorType, equals('Compilation error'));
      expect(error.toString(), equals('Compilation error: bad syntax'));
    });
  });

  group('RuntimeError', () {
    test('has errorType "Runtime error"', () {
      const error = RuntimeError('something exploded');

      expect(error.errorType, equals('Runtime error'));
      expect(error.toString(), equals('Runtime error: something exploded'));
    });
  });

  // ---------------------------------------------------------------------------
  // Lexical errors
  // ---------------------------------------------------------------------------

  group('InvalidCharacterError', () {
    test('without expected', () {
      const character = Character(
        value: '@',
        location: Location(row: 1, column: 5),
      );
      final error = InvalidCharacterError(character);

      expect(
        error.toString(),
        equals('Compilation error: Invalid character "@" at [1, 5]'),
      );
    });

    test('with expected', () {
      const character = Character(
        value: '!',
        location: Location(row: 2, column: 3),
      );
      final error = InvalidCharacterError(character, '=');

      expect(
        error.toString(),
        equals(
          'Compilation error: Invalid character "!" at [2, 3]. Expected: =',
        ),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Syntactic errors
  // ---------------------------------------------------------------------------

  group('InvalidTokenError', () {
    test('without expected', () {
      final token = identifierToken('foo', 1, 1);
      final error = InvalidTokenError(token);

      expect(
        error.toString(),
        equals('Compilation error: Invalid token "foo" at [1, 1]'),
      );
    });

    test('with expected', () {
      final token = identifierToken('bar', 3, 7);
      final error = InvalidTokenError(token, ')');

      expect(
        error.toString(),
        equals(
          'Compilation error: Invalid token "bar" at [3, 7]. Expected: )',
        ),
      );
    });
  });

  group('ExpectedTokenError', () {
    test('toString() includes token and expected', () {
      final token = numberToken(42, 5, 10);
      final error = ExpectedTokenError(token, '(');

      expect(
        error.toString(),
        equals(
          'Compilation error: Invalid token "42" at [5, 10]. Expected: (',
        ),
      );
    });
  });

  group('UnexpectedEndOfFileError', () {
    test('toString() reports unexpected end of file', () {
      const error = UnexpectedEndOfFileError();

      expect(
        error.toString(),
        equals('Compilation error: Unexpected end of file'),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Semantic errors
  // ---------------------------------------------------------------------------

  group('DuplicatedFunctionError', () {
    test('toString() lists both parameter sets', () {
      final function1 = FunctionNode(
        name: 'add',
        parameters: [Parameter.number('x'), Parameter.number('y')],
      );
      final function2 = FunctionNode(
        name: 'add',
        parameters: [Parameter.number('a'), Parameter.number('b')],
      );
      final error = DuplicatedFunctionError(
        function1: function1,
        function2: function2,
      );

      expect(
        error.toString(),
        equals(
          'Compilation error: Duplicated function "add" with parameters (x, y) and (a, b)',
        ),
      );
    });
  });

  group('DuplicatedParameterError', () {
    test('toString() includes function name and duplicated parameter', () {
      final error = DuplicatedParameterError(
        function: 'add',
        parameter: 'x',
        parameters: ['x', 'x'],
      );

      expect(
        error.toString(),
        equals(
          'Compilation error: Duplicated parameter "x" in function "add(x, x)"',
        ),
      );
    });
  });

  group('UndefinedIdentifierError', () {
    test('toString() includes identifier name', () {
      const error = UndefinedIdentifierError('myVar');

      expect(
        error.toString(),
        equals('Compilation error: Undefined identifier "myVar"'),
      );
    });
  });

  group('UndefinedFunctionError', () {
    test('toString() includes function name', () {
      const error = UndefinedFunctionError('compute');

      expect(
        error.toString(),
        equals('Compilation error: Undefined function "compute"'),
      );
    });
  });

  group('InvalidNumberOfArgumentsError', () {
    test('toString() includes function name', () {
      const error = InvalidNumberOfArgumentsError('process');

      expect(
        error.toString(),
        equals(
          'Compilation error: Invalid number of arguments calling function "process"',
        ),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Runtime errors
  // ---------------------------------------------------------------------------

  group('InvalidArgumentTypesError', () {
    test('toString() lists expected and actual types', () {
      final error = InvalidArgumentTypesError(
        function: 'add',
        expected: [const NumberType(), const NumberType()],
        actual: [const StringType(), const BooleanType()],
      );

      expect(
        error.toString(),
        equals(
          'Runtime error: Invalid argument types for function "add". Expected: (Number, Number). Actual: (String, Boolean)',
        ),
      );
    });
  });

  group('InvalidArgumentCountError', () {
    test('toString() shows expected and actual counts', () {
      final error = InvalidArgumentCountError(
        function: 'multiply',
        expected: 2,
        actual: 3,
      );

      expect(
        error.toString(),
        equals(
          'Runtime error: Invalid argument count for function "multiply". Expected: 2. Actual: 3',
        ),
      );
    });
  });

  group('IterablesWithDifferentLengthError', () {
    test('toString() shows both iterables', () {
      const error = IterablesWithDifferentLengthError(
        iterable1: '[1, 2, 3]',
        iterable2: '[4, 5]',
      );

      expect(
        error.toString(),
        equals(
          'Runtime error: Iterables with different length: [1, 2, 3] and [4, 5]',
        ),
      );
    });
  });

  group('InvalidLiteralValueError', () {
    test('toString() includes the value', () {
      const error = InvalidLiteralValueError('not_a_number');

      expect(
        error.toString(),
        equals('Runtime error: Invalid literal value: "not_a_number"'),
      );
    });
  });

  group('InvalidValueError', () {
    test('toString() includes the value', () {
      const error = InvalidValueError('bad_value');

      expect(
        error.toString(),
        equals('Runtime error: Invalid value: "bad_value"'),
      );
    });
  });

  group('InvalidMapIndexError', () {
    test('toString() includes the index', () {
      const error = InvalidMapIndexError('missing_key');

      expect(
        error.toString(),
        equals(
          'Runtime error: No element present in map for key: "missing_key"',
        ),
      );
    });
  });

  group('ElementNotFoundError', () {
    test('toString() includes the index', () {
      const error = ElementNotFoundError('99');

      expect(
        error.toString(),
        equals('Runtime error: Element not found at index: "99"'),
      );
    });
  });

  group('NotFoundInScopeError', () {
    test('toString() includes the variable name', () {
      const error = NotFoundInScopeError('unknownVar');

      expect(
        error.toString(),
        equals('Runtime error: Variable "unknownVar" not found in scope'),
      );
    });
  });

  group('InvalidFunctionError', () {
    test('toString() includes the variable name', () {
      const error = InvalidFunctionError('notAFunc');

      expect(
        error.toString(),
        equals('Runtime error: "notAFunc" is not a function'),
      );
    });
  });

  group('UnimplementedFunctionWebError', () {
    test('toString() includes the function name', () {
      const error = UnimplementedFunctionWebError('readFile');

      expect(
        error.toString(),
        equals(
          'Runtime error: Function "readFile" is not implemented on the web platform',
        ),
      );
    });
  });
}
