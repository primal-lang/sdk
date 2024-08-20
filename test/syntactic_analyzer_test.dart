import 'package:primal/compiler/errors/lexical_error.dart';
import 'package:primal/compiler/errors/syntactic_error.dart';
import 'package:primal/compiler/models/location.dart';
import 'package:primal/compiler/syntactic/expression.dart';
import 'package:primal/compiler/syntactic/function_definition.dart';
import 'package:test/test.dart';
import 'test_utils.dart';

void main() {
  group('Syntactic Analyzer', () {
    test('Invalid function definition 1', () {
      try {
        getFunctions('123');
        fail('Should fail');
      } catch (e) {
        expect(e, isA<InvalidTokenError>());
      }
    });

    test('Invalid function definition 2', () {
      try {
        getFunctions('isEven ,');
        fail('Should fail');
      } catch (e) {
        expect(e, isA<InvalidTokenError>());
      }
    });

    test('Invalid function definition 3', () {
      try {
        getFunctions('isEven() = true');
        fail('Should fail');
      } catch (e) {
        expect(e, isA<InvalidTokenError>());
      }
    });

    test('Invalid function definition 4', () {
      try {
        getFunctions('_isEven = true');
        fail('Should fail');
      } catch (e) {
        expect(e, isA<InvalidCharacterError>());
      }
    });

    test('Invalid function definition 5', () {
      try {
        getFunctions('_isEven(n) = n');
        fail('Should fail');
      } catch (e) {
        expect(e, isA<InvalidCharacterError>());
      }
    });

    test('Invalid function definition 6', () {
      try {
        getFunctions('isEvent(,) = true');
        fail('Should fail');
      } catch (e) {
        expect(e, isA<InvalidCharacterError>());
      }
    });

    test('Invalid function definition 7', () {
      try {
        getFunctions('isEvent(x,) = true');
        fail('Should fail');
      } catch (e) {
        expect(e, isA<InvalidTokenError>());
      }
    });

    test('Invalid function definition 8', () {
      try {
        getFunctions('isEven(1 = true');
        fail('Should fail');
      } catch (e) {
        expect(e, isA<InvalidTokenError>());
      }
    });

    test('Invalid function definition 9', () {
      try {
        getFunctions('isEven(a( = true');
        fail('Should fail');
      } catch (e) {
        expect(e, isA<InvalidTokenError>());
      }
    });

    test('Invalid function definition 1', () {
      try {
        getFunctions('isEvent(x), = true');
        fail('Should fail');
      } catch (e) {
        expect(e, isA<InvalidTokenError>());
      }
    });

    test('Literal double quoted string definition', () {
      final List<FunctionDefinition> functions =
          getFunctions('greeting = "Hello, world!"');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'greeting',
          parameters: [],
          expression: StringExpression(stringToken('Hello, world!', 1, 12)),
        ),
      ]);
    });

    test('Literal single quoted string definition', () {
      final List<FunctionDefinition> functions =
          getFunctions("greeting = 'Goodbye, world!'");
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'greeting',
          parameters: [],
          expression: StringExpression(stringToken('Goodbye, world!', 1, 12)),
        ),
      ]);
    });

    test('Literal number definition', () {
      final List<FunctionDefinition> functions = getFunctions('pi = 3.14');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'pi',
          parameters: [],
          expression: NumberExpression(numberToken(3.14, 1, 6)),
        ),
      ]);
    });

    test('Literal boolean definition', () {
      final List<FunctionDefinition> functions = getFunctions('enabled = true');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'enabled',
          parameters: [],
          expression: BooleanExpression(booleanToken(true, 1, 11)),
        ),
      ]);
    });

    test('Function with one parameter', () {
      final List<FunctionDefinition> functions = getFunctions('test(a) = true');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: ['a'],
          expression: BooleanExpression(booleanToken(true, 1, 11)),
        ),
      ]);
    });

    test('Function with several parameters', () {
      final List<FunctionDefinition> functions =
          getFunctions('test(a, b, c) = true');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: ['a', 'b', 'c'],
          expression: BooleanExpression(booleanToken(true, 1, 17)),
        ),
      ]);
    });

    test('Complex function 1', () {
      final List<FunctionDefinition> functions =
          getFunctions('isEven(x) = eq(mod(x, 2), 0)');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'isEven',
          parameters: ['x'],
          expression: FunctionCallExpression(
            name: 'eq',
            arguments: [
              FunctionCallExpression(
                name: 'mod',
                arguments: [
                  IdentifierExpression(identifierToken('x', 1, 20)),
                  NumberExpression(numberToken(2, 1, 23)),
                ],
                location: const Location(row: 1, column: 16),
              ),
              NumberExpression(numberToken(0, 1, 27)),
            ],
            location: const Location(row: 1, column: 13),
          ),
        ),
      ]);
    });

    test('Complex function 2', () {
      final List<FunctionDefinition> functions =
          getFunctions('isOdd(x) = not(isEven(positive(x)))');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'isOdd',
          parameters: ['x'],
          expression: FunctionCallExpression(
            name: 'not',
            arguments: [
              FunctionCallExpression(
                name: 'isEven',
                arguments: [
                  FunctionCallExpression(
                    name: 'positive',
                    arguments: [
                      IdentifierExpression(identifierToken('x', 1, 32)),
                    ],
                    location: const Location(row: 1, column: 23),
                  ),
                ],
                location: const Location(row: 1, column: 16),
              ),
            ],
            location: const Location(row: 1, column: 12),
          ),
        ),
      ]);
    });

    test('Complex function 3', () {
      final List<FunctionDefinition> functions = getFunctions(
          'factorial(x) = if(eq(n, 0), 1, mul(n, factorial(sub(n, 1))))');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'factorial',
          parameters: ['x'],
          expression: FunctionCallExpression(
            name: 'if',
            arguments: [
              FunctionCallExpression(
                name: 'eq',
                arguments: [
                  IdentifierExpression(identifierToken('n', 1, 22)),
                  NumberExpression(numberToken(0, 1, 25)),
                ],
                location: const Location(row: 1, column: 19),
              ),
              NumberExpression(numberToken(1, 1, 29)),
              FunctionCallExpression(
                name: 'mul',
                arguments: [
                  IdentifierExpression(identifierToken('n', 1, 36)),
                  FunctionCallExpression(
                    name: 'factorial',
                    arguments: [
                      FunctionCallExpression(
                        name: 'sub',
                        arguments: [
                          IdentifierExpression(identifierToken('n', 1, 53)),
                          NumberExpression(numberToken(1, 1, 56)),
                        ],
                        location: const Location(row: 1, column: 49),
                      ),
                    ],
                    location: const Location(row: 1, column: 39),
                  ),
                ],
                location: const Location(row: 1, column: 32),
              ),
            ],
            location: const Location(row: 1, column: 16),
          ),
        ),
      ]);
    });

    test('Sample file', () {
      final String source = loadFile('sample.prm');
      final List<FunctionDefinition> functions = getFunctions(source);
      expect(functions.length, equals(13));
    });
  });
}
