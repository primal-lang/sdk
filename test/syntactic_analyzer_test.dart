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
        getFunctions('isEven(1 = true');
        fail('Should fail');
      } catch (e) {
        expect(e, isA<InvalidTokenError>());
      }
    });

    test('Invalid function definition 5', () {
      try {
        getFunctions('isEven(a( = true');
        fail('Should fail');
      } catch (e) {
        expect(e, isA<InvalidTokenError>());
      }
    });

    test('Invalid function definition 6', () {
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
          expression:
              StringLiteralExpression(stringToken('Hello, world!', 1, 12)),
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
          expression:
              StringLiteralExpression(stringToken('Goodbye, world!', 1, 12)),
        ),
      ]);
    });

    test('Literal number definition', () {
      final List<FunctionDefinition> functions = getFunctions('pi = 3.14');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'pi',
          parameters: [],
          expression: NumberLiteralExpression(numberToken(3.14, 1, 6)),
        ),
      ]);
    });

    test('Literal boolean definition', () {
      final List<FunctionDefinition> functions = getFunctions('enabled = true');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'enabled',
          parameters: [],
          expression: BooleanLiteralExpression(booleanToken(true, 1, 11)),
        ),
      ]);
    });

    test('Literal list definition', () {
      final List<FunctionDefinition> functions =
          getFunctions('list = [1, 2, 3]');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'list',
          parameters: [],
          expression: ListLiteralExpression(
            location: const Location(row: 1, column: 8),
            arguments: [
              NumberLiteralExpression(numberToken(1, 1, 9)),
              NumberLiteralExpression(numberToken(2, 1, 12)),
              NumberLiteralExpression(numberToken(3, 1, 15)),
            ],
          ),
        ),
      ]);
    });

    test('Indexing list ', () {
      final List<FunctionDefinition> functions =
          getFunctions('list = [1, 2, 3][1]');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'list',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('element.at', 1, 17)),
            arguments: [
              ListLiteralExpression(
                location: const Location(row: 1, column: 8),
                arguments: [
                  NumberLiteralExpression(numberToken(1, 1, 9)),
                  NumberLiteralExpression(numberToken(2, 1, 12)),
                  NumberLiteralExpression(numberToken(3, 1, 15)),
                ],
              ),
              NumberLiteralExpression(numberToken(1, 1, 18)),
            ],
          ),
        ),
      ]);
    });

    test('Function with no parameters', () {
      final List<FunctionDefinition> functions = getFunctions('test = true');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: BooleanLiteralExpression(booleanToken(true, 1, 8)),
        ),
      ]);
    });

    test('Function with one parameter', () {
      final List<FunctionDefinition> functions = getFunctions('test(a) = true');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: ['a'],
          expression: BooleanLiteralExpression(booleanToken(true, 1, 11)),
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
          expression: BooleanLiteralExpression(booleanToken(true, 1, 17)),
        ),
      ]);
    });

    test('Complex function 1', () {
      final List<FunctionDefinition> functions =
          getFunctions('isEven(x) = (x % 2) == 0');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'isEven',
          parameters: ['x'],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('==', 1, 21)),
            arguments: [
              CallExpression(
                callee: IdentifierExpression(identifierToken('%', 1, 16)),
                arguments: [
                  IdentifierExpression(identifierToken('x', 1, 14)),
                  NumberLiteralExpression(numberToken(2, 1, 18)),
                ],
              ),
              NumberLiteralExpression(numberToken(0, 1, 24)),
            ],
          ),
        ),
      ]);
    });

    test('Complex function 2', () {
      final List<FunctionDefinition> functions =
          getFunctions('isOdd(x) = !isEven(x)');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'isOdd',
          parameters: ['x'],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('!', 1, 12)),
            arguments: [
              CallExpression(
                callee: IdentifierExpression(identifierToken('isEven', 1, 13)),
                arguments: [
                  IdentifierExpression(identifierToken('x', 1, 20)),
                ],
              ),
            ],
          ),
        ),
      ]);
    });

    test('Complex function 3', () {
      final List<FunctionDefinition> functions = getFunctions(
          'factorial(n) = if (n == 0) 1 else n * factorial(n - 1)');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'factorial',
          parameters: ['n'],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('if', 1, 16)),
            arguments: [
              CallExpression(
                callee: IdentifierExpression(identifierToken('==', 1, 22)),
                arguments: [
                  IdentifierExpression(identifierToken('n', 1, 20)),
                  NumberLiteralExpression(numberToken(0, 1, 25)),
                ],
              ),
              NumberLiteralExpression(numberToken(1, 1, 28)),
              CallExpression(
                callee: IdentifierExpression(identifierToken('*', 1, 37)),
                arguments: [
                  IdentifierExpression(identifierToken('n', 1, 35)),
                  CallExpression(
                    callee: IdentifierExpression(
                        identifierToken('factorial', 1, 39)),
                    arguments: [
                      CallExpression(
                        callee:
                            IdentifierExpression(identifierToken('-', 1, 51)),
                        arguments: [
                          IdentifierExpression(identifierToken('n', 1, 49)),
                          NumberLiteralExpression(numberToken(1, 1, 53)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ]);
    });

    test('Sample file', () {
      final String source = loadFile('sample.prm');
      final List<FunctionDefinition> functions = getFunctions(source);
      expect(functions.length, equals(11));
    });
  });
}
