@Tags(['unit'])
library;

import 'package:primal/compiler/errors/generic_error.dart';
import 'package:primal/compiler/errors/lexical_error.dart';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/errors/semantic_error.dart';
import 'package:primal/compiler/errors/syntactic_error.dart';
import 'package:primal/compiler/lexical/token.dart';
import 'package:primal/compiler/models/function_signature.dart';
import 'package:primal/compiler/models/location.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/models/type.dart';
import 'package:primal/compiler/reader/character.dart';
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

      expect(error.errorType, equals('Error'));
      expect(error.toString(), equals('Error: bad syntax'));
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
      final InvalidCharacterError error = InvalidCharacterError(character);

      expect(
        error.toString(),
        equals('Error: Invalid character "@" at [1, 5]'),
      );
    });

    test('with expected', () {
      const character = Character(
        value: '!',
        location: Location(row: 2, column: 3),
      );
      final InvalidCharacterError error = InvalidCharacterError(character, '=');

      expect(
        error.toString(),
        equals(
          'Error: Invalid character "!" at [2, 3]. Expected: =',
        ),
      );
    });
  });

  group('UnterminatedStringError', () {
    test('toString() includes the starting location', () {
      const Location location = Location(row: 5, column: 10);
      final UnterminatedStringError error = UnterminatedStringError(location);

      expect(
        error.toString(),
        equals('Error: Unterminated string starting at [5, 10]'),
      );
    });
  });

  group('UnterminatedCommentError', () {
    test('toString() reports unterminated comment', () {
      const UnterminatedCommentError error = UnterminatedCommentError();

      expect(
        error.toString(),
        equals('Error: Unterminated multi-line comment'),
      );
    });
  });

  group('InvalidEscapeSequenceError', () {
    test('toString() includes the escape character and location', () {
      const Character character = Character(
        value: 'q',
        location: Location(row: 3, column: 8),
      );
      final InvalidEscapeSequenceError error = InvalidEscapeSequenceError(
        character,
      );

      expect(
        error.toString(),
        equals("Error: Invalid escape sequence '\\q' at [3, 8]"),
      );
    });
  });

  group('InvalidHexEscapeError', () {
    test('toString() includes escape type, expected digits, and actual', () {
      const Character character = Character(
        value: 'g',
        location: Location(row: 2, column: 5),
      );
      final InvalidHexEscapeError error = InvalidHexEscapeError(
        character,
        'x',
        2,
      );

      expect(
        error.toString(),
        equals(
          "Error: Invalid hex escape: expected 2 hex digits after '\\x', got 'g' at [2, 5]",
        ),
      );
    });

    test('toString() for unicode escape with 4 digits', () {
      const Character character = Character(
        value: 'z',
        location: Location(row: 1, column: 10),
      );
      final InvalidHexEscapeError error = InvalidHexEscapeError(
        character,
        'u',
        4,
      );

      expect(
        error.toString(),
        equals(
          "Error: Invalid hex escape: expected 4 hex digits after '\\u', got 'z' at [1, 10]",
        ),
      );
    });
  });

  group('InvalidBracedEscapeError', () {
    test('toString() includes the message and location', () {
      final InvalidBracedEscapeError error = InvalidBracedEscapeError(
        'Missing closing brace',
        const Location(row: 4, column: 12),
      );

      expect(
        error.toString(),
        equals('Error: Missing closing brace at [4, 12]'),
      );
    });
  });

  group('InvalidCodePointError', () {
    test('toString() includes the code point in hex and location', () {
      final InvalidCodePointError error = InvalidCodePointError(
        0x110000,
        const Location(row: 1, column: 5),
      );

      expect(
        error.toString(),
        equals(
          'Error: Invalid code point U+110000: exceeds maximum U+10FFFF at [1, 5]',
        ),
      );
    });

    test('toString() pads small code points to 4 digits', () {
      final InvalidCodePointError error = InvalidCodePointError(
        0x1FFFFF,
        const Location(row: 2, column: 3),
      );

      expect(
        error.toString(),
        equals(
          'Error: Invalid code point U+1FFFFF: exceeds maximum U+10FFFF at [2, 3]',
        ),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Syntactic errors
  // ---------------------------------------------------------------------------

  group('InvalidTokenError', () {
    test('without expected', () {
      final IdentifierToken token = identifierToken('foo', 1, 1);
      final InvalidTokenError error = InvalidTokenError(token);

      expect(
        error.toString(),
        equals('Error: Invalid token "foo" at [1, 1]'),
      );
    });

    test('with expected', () {
      final IdentifierToken token = identifierToken('bar', 3, 7);
      final InvalidTokenError error = InvalidTokenError(token, ')');

      expect(
        error.toString(),
        equals(
          'Error: Invalid token "bar" at [3, 7]. Expected: )',
        ),
      );
    });
  });

  group('ExpectedTokenError', () {
    test('toString() includes token and expected', () {
      final NumberToken token = numberToken(42, 5, 10);
      final ExpectedTokenError error = ExpectedTokenError(token, '(');

      expect(
        error.toString(),
        equals(
          'Error: Invalid token "42" at [5, 10]. Expected: (',
        ),
      );
    });
  });

  group('UnexpectedEndOfFileError', () {
    test('toString() reports unexpected end of file', () {
      const error = UnexpectedEndOfFileError();

      expect(
        error.toString(),
        equals('Error: Unexpected end of file'),
      );
    });
  });

  group('UnexpectedTokenError', () {
    test('toString() includes the token', () {
      final IdentifierToken token = identifierToken('extra', 5, 15);
      final UnexpectedTokenError error = UnexpectedTokenError(token);

      expect(
        error.toString(),
        equals('Error: Unexpected token "extra" at [5, 15] after expression'),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Semantic errors
  // ---------------------------------------------------------------------------

  group('DuplicatedFunctionError', () {
    test('toString() lists both parameter sets', () {
      const FunctionSignature function1 = FunctionSignature(
        name: 'add',
        parameters: [Parameter.number('x'), Parameter.number('y')],
      );
      const FunctionSignature function2 = FunctionSignature(
        name: 'add',
        parameters: [Parameter.number('a'), Parameter.number('b')],
      );
      final DuplicatedFunctionError error = DuplicatedFunctionError(
        function1: function1,
        function2: function2,
      );

      expect(
        error.toString(),
        equals(
          'Error: Duplicated function "add" with parameters (x, y) and (a, b)',
        ),
      );
    });
  });

  group('DuplicatedParameterError', () {
    test('toString() includes function name and duplicated parameter', () {
      final DuplicatedParameterError error = DuplicatedParameterError(
        function: 'add',
        parameter: 'x',
        parameters: ['x', 'x'],
      );

      expect(
        error.toString(),
        equals(
          'Error: Duplicated parameter "x" in function "add(x, x)"',
        ),
      );
    });
  });

  group('UndefinedIdentifierError', () {
    test('toString() includes identifier name and function context', () {
      final UndefinedIdentifierError error = UndefinedIdentifierError(
        identifier: 'myVar',
        inFunction: 'calculate',
      );

      expect(
        error.toString(),
        equals(
          'Error: Undefined identifier "myVar" in function "calculate"',
        ),
      );
    });

    test('toString() omits function context when inFunction is null', () {
      final UndefinedIdentifierError error = UndefinedIdentifierError(
        identifier: 'myVar',
      );

      expect(
        error.toString(),
        equals('Error: Undefined identifier "myVar"'),
      );
    });
  });

  group('UndefinedFunctionError', () {
    test('toString() includes function name and context', () {
      final UndefinedFunctionError error = UndefinedFunctionError(
        function: 'compute',
        inFunction: 'main',
      );

      expect(
        error.toString(),
        equals(
          'Error: Undefined function "compute" in function "main"',
        ),
      );
    });

    test('toString() omits function context when inFunction is null', () {
      final UndefinedFunctionError error = UndefinedFunctionError(
        function: 'compute',
      );

      expect(
        error.toString(),
        equals('Error: Undefined function "compute"'),
      );
    });
  });

  group('CannotRedefineStandardLibraryError', () {
    test('toString() includes the function name', () {
      const CannotRedefineStandardLibraryError error =
          CannotRedefineStandardLibraryError(function: 'print');

      expect(
        error.toString(),
        equals('Error: Cannot redefine standard library function "print"'),
      );
    });
  });

  group('CannotDeleteStandardLibraryError', () {
    test('toString() includes the function name', () {
      const CannotDeleteStandardLibraryError error =
          CannotDeleteStandardLibraryError(function: 'map');

      expect(
        error.toString(),
        equals('Error: Cannot delete standard library function "map"'),
      );
    });
  });

  group('FunctionNotFoundError', () {
    test('toString() includes the function name', () {
      const FunctionNotFoundError error = FunctionNotFoundError(
        function: 'missingFunc',
      );

      expect(
        error.toString(),
        equals('Error: Function "missingFunc" not found'),
      );
    });
  });

  group('CannotRenameStandardLibraryError', () {
    test('toString() includes the function name', () {
      const CannotRenameStandardLibraryError error =
          CannotRenameStandardLibraryError(function: 'filter');

      expect(
        error.toString(),
        equals('Error: Cannot rename standard library function "filter"'),
      );
    });
  });

  group('FunctionAlreadyExistsError', () {
    test('toString() includes the function name', () {
      const FunctionAlreadyExistsError error = FunctionAlreadyExistsError(
        function: 'duplicate',
      );

      expect(
        error.toString(),
        equals('Error: Function "duplicate" already exists'),
      );
    });
  });

  group('NotCallableError', () {
    test('toString() includes value and type', () {
      const NotCallableError error = NotCallableError(
        value: '42',
        type: 'Number',
      );

      expect(
        error.toString(),
        equals('Error: Cannot call Number literal "42"'),
      );
    });
  });

  group('NotIndexableError', () {
    test('toString() includes value and type', () {
      const NotIndexableError error = NotIndexableError(
        value: 'true',
        type: 'Boolean',
      );

      expect(
        error.toString(),
        equals('Error: Cannot index Boolean literal "true"'),
      );
    });
  });

  group('InvalidNumberOfArgumentsError', () {
    test('toString() includes function name and argument counts', () {
      const error = InvalidNumberOfArgumentsError(
        function: 'process',
        expected: 2,
        actual: 3,
      );

      expect(
        error.toString(),
        equals(
          'Error: Invalid number of arguments calling function "process": expected 2, got 3',
        ),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Runtime errors
  // ---------------------------------------------------------------------------

  group('InvalidArgumentTypesError', () {
    test('toString() lists expected and actual types', () {
      final InvalidArgumentTypesError error = InvalidArgumentTypesError(
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
      final InvalidArgumentCountError error = InvalidArgumentCountError(
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

  group('EmptyCollectionError', () {
    test('toString() includes function and collection type', () {
      final EmptyCollectionError error = EmptyCollectionError(
        function: 'head',
        collectionType: 'list',
      );

      expect(
        error.toString(),
        equals(
          'Runtime error: Cannot get element from empty list in function "head"',
        ),
      );
    });
  });

  group('IndexOutOfBoundsError', () {
    test('toString() includes function, index, and length', () {
      final IndexOutOfBoundsError error = IndexOutOfBoundsError(
        function: 'at',
        index: 10,
        length: 5,
      );

      expect(
        error.toString(),
        equals('Runtime error: Index 10 is out of bounds for at (length: 5)'),
      );
    });
  });

  group('NegativeIndexError', () {
    test('toString() includes function and index', () {
      final NegativeIndexError error = NegativeIndexError(
        function: 'at',
        index: -3,
      );

      expect(
        error.toString(),
        equals('Runtime error: Negative index -3 is not allowed for at'),
      );
    });
  });

  group('DivisionByZeroError', () {
    test('toString() includes the function name', () {
      final DivisionByZeroError error = DivisionByZeroError(
        function: 'divide',
      );

      expect(
        error.toString(),
        equals('Runtime error: Division by zero is not allowed in "divide"'),
      );
    });
  });

  group('InvalidNumericOperationError', () {
    test('toString() includes function and reason', () {
      final InvalidNumericOperationError error = InvalidNumericOperationError(
        function: 'sqrt',
        reason: 'negative number',
      );

      expect(
        error.toString(),
        equals(
          'Runtime error: Invalid numeric operation in "sqrt": negative number',
        ),
      );
    });
  });

  group('ParseError', () {
    test('toString() includes function, input, and target type', () {
      final ParseError error = ParseError(
        function: 'toNumber',
        input: 'abc',
        targetType: 'Number',
      );

      expect(
        error.toString(),
        equals(
          'Runtime error: Cannot parse "abc" as Number in "toNumber"',
        ),
      );
    });
  });

  group('JsonParseError', () {
    test('toString() includes details and input', () {
      final JsonParseError error = JsonParseError(
        input: '{"invalid": }',
        details: 'Unexpected character',
      );

      expect(
        error.toString(),
        equals(
          'Runtime error: Invalid JSON: Unexpected character. Input: "{"invalid": }"',
        ),
      );
    });

    test('toString() truncates long input to 50 characters', () {
      final String longInput = 'a' * 100;
      final JsonParseError error = JsonParseError(
        input: longInput,
        details: 'Parse failed',
      );

      expect(
        error.toString(),
        equals(
          'Runtime error: Invalid JSON: Parse failed. Input: "${'a' * 50}..."',
        ),
      );
    });

    test('toString() does not truncate input of exactly 50 characters', () {
      final String exactInput = 'b' * 50;
      final JsonParseError error = JsonParseError(
        input: exactInput,
        details: 'Syntax error',
      );

      expect(
        error.toString(),
        equals(
          'Runtime error: Invalid JSON: Syntax error. Input: "${'b' * 50}"',
        ),
      );
    });
  });

  group('RecursionLimitError', () {
    test('toString() includes the limit', () {
      final RecursionLimitError error = RecursionLimitError(limit: 1000);

      expect(
        error.toString(),
        equals('Runtime error: Maximum recursion depth of 1000 exceeded'),
      );
    });
  });
}
