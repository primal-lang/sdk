import 'package:dry/compiler/errors/syntactic_error.dart';
import 'package:dry/compiler/input/location.dart';
import 'package:dry/compiler/syntactic/expression.dart';
import 'package:dry/compiler/syntactic/function_definition.dart';
import 'package:test/test.dart';
import 'test_utils.dart';

void main() {
  group('Syntactic Analyzer', () {
    test('Invalid function definition 1', () {
      try {
        getFunctions('123');
      } catch (e) {
        expect(e, isA<SyntacticError>());
      }
    });

    test('Invalid function definition 2', () {
      try {
        getFunctions('isEven ,');
      } catch (e) {
        expect(e, isA<SyntacticError>());
      }
    });

    test('Invalid function definition 3', () {
      try {
        getFunctions('isEven()');
      } catch (e) {
        expect(e, isA<SyntacticError>());
      }
    });

    test('Invalid function definition 4', () {
      try {
        getFunctions('isEven(1');
      } catch (e) {
        expect(e, isA<SyntacticError>());
      }
    });

    test('Invalid function definition 5', () {
      try {
        getFunctions('isEven(a(');
      } catch (e) {
        expect(e, isA<SyntacticError>());
      }
    });

    test('Invalid function definition 6', () {
      try {
        getFunctions('isEvent(x),');
      } catch (e) {
        expect(e, isA<SyntacticError>());
      }
    });

    test('Literal double quoted string definition', () {
      final List<FunctionDefinition> functions =
          getFunctions('greeting = "Hello, world!"');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'greeting',
          parameters: [],
          expression: LiteralExpression.string(stringToken('Hello, world!')),
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
          expression: LiteralExpression.string(stringToken('Goodbye, world!')),
        ),
      ]);
    });

    test('Literal number definition', () {
      final List<FunctionDefinition> functions = getFunctions('pi = 3.14');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'pi',
          parameters: [],
          expression: LiteralExpression.number(numberToken(3.14)),
        ),
      ]);
    });

    test('Literal boolean definition', () {
      final List<FunctionDefinition> functions = getFunctions('enabled = true');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'enabled',
          parameters: [],
          expression: LiteralExpression.boolean(booleanToken(true)),
        ),
      ]);
    });

    test('Function with one parameter', () {
      final List<FunctionDefinition> functions = getFunctions('test(a) = true');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: ['a'],
          expression: LiteralExpression.boolean(booleanToken(true)),
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
          expression: LiteralExpression.boolean(booleanToken(true)),
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
                  LiteralExpression.symbol(symbolToken('x')),
                  LiteralExpression.number(numberToken(2)),
                ],
                location: const Location(row: 1, column: 4),
              ),
              LiteralExpression.number(numberToken(0)),
            ],
            location: const Location(row: 1, column: 1),
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
                      LiteralExpression.symbol(symbolToken('x')),
                    ],
                    location: const Location(row: 1, column: 12),
                  ),
                ],
                location: const Location(row: 1, column: 5),
              ),
            ],
            location: const Location(row: 1, column: 1),
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
                  LiteralExpression.symbol(symbolToken('n')),
                  LiteralExpression.number(numberToken(0)),
                ],
                location: const Location(row: 1, column: 4),
              ),
              LiteralExpression.number(numberToken(1)),
              FunctionCallExpression(
                name: 'mul',
                arguments: [
                  LiteralExpression.symbol(symbolToken('n')),
                  FunctionCallExpression(
                    name: 'factorial',
                    arguments: [
                      FunctionCallExpression(
                        name: 'sub',
                        arguments: [
                          LiteralExpression.symbol(symbolToken('n')),
                          LiteralExpression.number(numberToken(1)),
                        ],
                        location: const Location(row: 1, column: 34),
                      ),
                    ],
                    location: const Location(row: 1, column: 24),
                  ),
                ],
                location: const Location(row: 1, column: 17),
              ),
            ],
            location: const Location(row: 1, column: 1),
          ),
        ),
      ]);
    });

    test('Sample file', () {
      final String source = loadFile('sample.dry');
      final List<FunctionDefinition> functions = getFunctions(source);
      expect(functions.length, equals(10));
    });
  });
}
