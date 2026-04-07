@Tags(['compiler'])
library;

import 'package:primal/compiler/errors/syntactic_error.dart';
import 'package:primal/compiler/lexical/token.dart';
import 'package:primal/compiler/models/located.dart';
import 'package:primal/compiler/models/location.dart';
import 'package:primal/compiler/syntactic/expression.dart';
import 'package:primal/compiler/syntactic/function_definition.dart';
import 'package:primal/compiler/syntactic/syntactic_analyzer.dart';
import 'package:primal/utils/list_iterator.dart';
import 'package:test/test.dart';
import '../helpers/assertion_helpers.dart';
import '../helpers/pipeline_helpers.dart';
import '../helpers/resource_helpers.dart';
import '../helpers/token_factories.dart';

void main() {
  group('Syntactic Analyzer', () {
    test('Invalid function definition 1', () {
      expect(() => getFunctions('123'), throwsA(isA<InvalidTokenError>()));
    });

    test('Invalid function definition 2', () {
      expect(
        () => getFunctions('isEven ,'),
        throwsA(isA<InvalidTokenError>()),
      );
    });

    test('Function with empty parameter list', () {
      final List<FunctionDefinition> functions = getFunctions(
        'isEven() = true',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'isEven',
          parameters: [],
          expression: BooleanExpression(booleanToken(true, 1, 12)),
        ),
      ]);
    });

    test('Invalid function definition 4', () {
      expect(
        () => getFunctions('isEven(1 = true'),
        throwsA(isA<InvalidTokenError>()),
      );
    });

    test('Invalid function definition 5', () {
      expect(
        () => getFunctions('isEven(a( = true'),
        throwsA(isA<InvalidTokenError>()),
      );
    });

    test('Invalid function definition 6', () {
      expect(
        () => getFunctions('isEvent(x), = true'),
        throwsA(isA<InvalidTokenError>()),
      );
    });

    test('Non-identifier after comma in parameter list', () {
      expect(
        () => getFunctions('f(x, 5) = x'),
        throwsA(isA<InvalidTokenError>()),
      );
    });

    test('Literal double quoted string definition', () {
      final List<FunctionDefinition> functions = getFunctions(
        'greeting = "Hello, world!"',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'greeting',
          parameters: [],
          expression: StringExpression(stringToken('Hello, world!', 1, 12)),
        ),
      ]);
    });

    test('Literal single quoted string definition', () {
      final List<FunctionDefinition> functions = getFunctions(
        "greeting = 'Goodbye, world!'",
      );
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

    test('Literal list definition', () {
      final List<FunctionDefinition> functions = getFunctions(
        'list = [1, 2, 3]',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'list',
          parameters: [],
          expression: ListExpression(
            location: const Location(row: 1, column: 8),
            value: [
              NumberExpression(numberToken(1, 1, 9)),
              NumberExpression(numberToken(2, 1, 12)),
              NumberExpression(numberToken(3, 1, 15)),
            ],
          ),
        ),
      ]);
    });

    test('Indexing list ', () {
      final List<FunctionDefinition> functions = getFunctions(
        'list = [1, 2, 3][1]',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'list',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('@', 1, 17)),
            arguments: [
              ListExpression(
                location: const Location(row: 1, column: 8),
                value: [
                  NumberExpression(numberToken(1, 1, 9)),
                  NumberExpression(numberToken(2, 1, 12)),
                  NumberExpression(numberToken(3, 1, 15)),
                ],
              ),
              NumberExpression(numberToken(1, 1, 18)),
            ],
          ),
        ),
      ]);
    });

    test('Literal map definition', () {
      final List<FunctionDefinition> functions = getFunctions(
        'map = {1: "one", 2: "two", 3: "three"}',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'map',
          parameters: [],
          expression: MapExpression(
            location: const Location(row: 1, column: 7),
            value: [
              MapEntryExpression(
                location: const Location(row: 1, column: 8),
                key: NumberExpression(numberToken(1, 1, 8)),
                value: StringExpression(stringToken('one', 1, 11)),
              ),
              MapEntryExpression(
                location: const Location(row: 1, column: 18),
                key: NumberExpression(numberToken(2, 1, 18)),
                value: StringExpression(stringToken('two', 1, 21)),
              ),
              MapEntryExpression(
                location: const Location(row: 1, column: 28),
                key: NumberExpression(numberToken(3, 1, 28)),
                value: StringExpression(stringToken('three', 1, 31)),
              ),
            ],
          ),
        ),
      ]);
    });

    test('Indexing map ', () {
      final List<FunctionDefinition> functions = getFunctions(
        'map = {1: "one", 2: "two", 3: "three"}[1]',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'map',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('@', 1, 39)),
            arguments: [
              MapExpression(
                location: const Location(row: 1, column: 7),
                value: [
                  MapEntryExpression(
                    location: const Location(row: 1, column: 8),
                    key: NumberExpression(numberToken(1, 1, 8)),
                    value: StringExpression(stringToken('one', 1, 11)),
                  ),
                  MapEntryExpression(
                    location: const Location(row: 1, column: 18),
                    key: NumberExpression(numberToken(2, 1, 18)),
                    value: StringExpression(stringToken('two', 1, 21)),
                  ),
                  MapEntryExpression(
                    location: const Location(row: 1, column: 28),
                    key: NumberExpression(numberToken(3, 1, 28)),
                    value: StringExpression(stringToken('three', 1, 31)),
                  ),
                ],
              ),
              NumberExpression(numberToken(1, 1, 40)),
            ],
          ),
        ),
      ]);
    });

    test('MapEntryExpression has correct location', () {
      final List<FunctionDefinition> functions = getFunctions(
        'map = {"key": "value"}',
      );
      final MapExpression mapExpr = functions[0].expression as MapExpression;
      final MapEntryExpression entry = mapExpr.value[0];

      expect(entry.location, equals(const Location(row: 1, column: 8)));
    });

    test('MapEntryExpression extends Located', () {
      final List<FunctionDefinition> functions = getFunctions(
        'map = {"key": "value"}',
      );
      final MapExpression mapExpr = functions[0].expression as MapExpression;
      final MapEntryExpression entry = mapExpr.value[0];

      expect(entry, isA<Located>());
    });

    test('Function with no parameters', () {
      final List<FunctionDefinition> functions = getFunctions('test = true');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: BooleanExpression(booleanToken(true, 1, 8)),
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
      final List<FunctionDefinition> functions = getFunctions(
        'test(a, b, c) = true',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: ['a', 'b', 'c'],
          expression: BooleanExpression(booleanToken(true, 1, 17)),
        ),
      ]);
    });

    test('Complex function 1', () {
      final List<FunctionDefinition> functions = getFunctions(
        'isEven(x) = (x % 2) == 0',
      );
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
                  NumberExpression(numberToken(2, 1, 18)),
                ],
              ),
              NumberExpression(numberToken(0, 1, 24)),
            ],
          ),
        ),
      ]);
    });

    test('Complex function 2', () {
      final List<FunctionDefinition> functions = getFunctions(
        'isOdd(x) = !isEven(x)',
      );
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
        'factorial(n) = if (n == 0) 1 else n * factorial(n - 1)',
      );
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
                  NumberExpression(numberToken(0, 1, 25)),
                ],
              ),
              NumberExpression(numberToken(1, 1, 28)),
              CallExpression(
                callee: IdentifierExpression(identifierToken('*', 1, 37)),
                arguments: [
                  IdentifierExpression(identifierToken('n', 1, 35)),
                  CallExpression(
                    callee: IdentifierExpression(
                      identifierToken('factorial', 1, 39),
                    ),
                    arguments: [
                      CallExpression(
                        callee: IdentifierExpression(
                          identifierToken('-', 1, 51),
                        ),
                        arguments: [
                          IdentifierExpression(identifierToken('n', 1, 49)),
                          NumberExpression(numberToken(1, 1, 53)),
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

    // Error cases: UnexpectedEndOfFileError

    test('Error: missing expression body', () {
      expect(
        () => getFunctions('test ='),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('Error: incomplete binary operation', () {
      expect(
        () => getFunctions('test = 1 +'),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('Error: function with parameters but no body', () {
      expect(
        () => getFunctions('test(a)'),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('Error: if without else', () {
      expect(
        () => getFunctions('test = if (true) 1'),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    // Error cases: ExpectedTokenError

    test('Error: if missing condition parentheses', () {
      expect(
        () => getFunctions('test = if true 1 else 2'),
        throwsA(isA<ExpectedTokenError>()),
      );
    });

    test('Error: map missing colon', () {
      expect(
        () => getFunctions('test = {1 2}'),
        throwsA(isA<ExpectedTokenError>()),
      );
    });

    test('Error: list with wrong closing bracket', () {
      expect(
        () => getFunctions('test = [1, 2)'),
        throwsA(isA<ExpectedTokenError>()),
      );
    });

    // Binary operators

    test('Binary addition', () {
      final List<FunctionDefinition> functions = getFunctions('test = 1 + 2');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('+', 1, 10)),
            arguments: [
              NumberExpression(numberToken(1, 1, 8)),
              NumberExpression(numberToken(2, 1, 12)),
            ],
          ),
        ),
      ]);
    });

    test('Binary subtraction', () {
      final List<FunctionDefinition> functions = getFunctions('test = 5 - 3');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('-', 1, 10)),
            arguments: [
              NumberExpression(numberToken(5, 1, 8)),
              NumberExpression(numberToken(3, 1, 12)),
            ],
          ),
        ),
      ]);
    });

    test('Binary multiplication', () {
      final List<FunctionDefinition> functions = getFunctions('test = 2 * 3');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('*', 1, 10)),
            arguments: [
              NumberExpression(numberToken(2, 1, 8)),
              NumberExpression(numberToken(3, 1, 12)),
            ],
          ),
        ),
      ]);
    });

    test('Binary division', () {
      final List<FunctionDefinition> functions = getFunctions('test = 6 / 2');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('/', 1, 10)),
            arguments: [
              NumberExpression(numberToken(6, 1, 8)),
              NumberExpression(numberToken(2, 1, 12)),
            ],
          ),
        ),
      ]);
    });

    test('Binary less than', () {
      final List<FunctionDefinition> functions = getFunctions('test = 1 < 2');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('<', 1, 10)),
            arguments: [
              NumberExpression(numberToken(1, 1, 8)),
              NumberExpression(numberToken(2, 1, 12)),
            ],
          ),
        ),
      ]);
    });

    test('Binary greater than', () {
      final List<FunctionDefinition> functions = getFunctions('test = 1 > 2');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('>', 1, 10)),
            arguments: [
              NumberExpression(numberToken(1, 1, 8)),
              NumberExpression(numberToken(2, 1, 12)),
            ],
          ),
        ),
      ]);
    });

    test('Binary less than or equal', () {
      final List<FunctionDefinition> functions = getFunctions('test = 3 <= 5');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('<=', 1, 10)),
            arguments: [
              NumberExpression(numberToken(3, 1, 8)),
              NumberExpression(numberToken(5, 1, 13)),
            ],
          ),
        ),
      ]);
    });

    test('Binary greater than or equal', () {
      final List<FunctionDefinition> functions = getFunctions('test = 5 >= 3');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('>=', 1, 10)),
            arguments: [
              NumberExpression(numberToken(5, 1, 8)),
              NumberExpression(numberToken(3, 1, 13)),
            ],
          ),
        ),
      ]);
    });

    test('Binary not equal', () {
      final List<FunctionDefinition> functions = getFunctions('test = 1 != 2');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('!=', 1, 10)),
            arguments: [
              NumberExpression(numberToken(1, 1, 8)),
              NumberExpression(numberToken(2, 1, 13)),
            ],
          ),
        ),
      ]);
    });

    test('Binary logical and', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = true & false',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('&', 1, 13)),
            arguments: [
              BooleanExpression(booleanToken(true, 1, 8)),
              BooleanExpression(booleanToken(false, 1, 15)),
            ],
          ),
        ),
      ]);
    });

    test('Binary logical or', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = true | false',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('|', 1, 13)),
            arguments: [
              BooleanExpression(booleanToken(true, 1, 8)),
              BooleanExpression(booleanToken(false, 1, 15)),
            ],
          ),
        ),
      ]);
    });

    // Unary operators

    test('Unary negation', () {
      final List<FunctionDefinition> functions = getFunctions('test = -5');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('-', 1, 8)),
            arguments: [
              NumberExpression(numberToken(0, 1, 8)),
              NumberExpression(numberToken(5, 1, 9)),
            ],
          ),
        ),
      ]);
    });

    test('Unary logical not', () {
      final List<FunctionDefinition> functions = getFunctions('test = !true');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('!', 1, 8)),
            arguments: [
              BooleanExpression(booleanToken(true, 1, 9)),
            ],
          ),
        ),
      ]);
    });

    // Operator precedence

    test('Precedence: multiplication before addition', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = 1 + 2 * 3',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('+', 1, 10)),
            arguments: [
              NumberExpression(numberToken(1, 1, 8)),
              CallExpression(
                callee: IdentifierExpression(identifierToken('*', 1, 14)),
                arguments: [
                  NumberExpression(numberToken(2, 1, 12)),
                  NumberExpression(numberToken(3, 1, 16)),
                ],
              ),
            ],
          ),
        ),
      ]);
    });

    test('Precedence: grouping overrides default', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = (1 + 2) * 3',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('*', 1, 16)),
            arguments: [
              CallExpression(
                callee: IdentifierExpression(identifierToken('+', 1, 11)),
                arguments: [
                  NumberExpression(numberToken(1, 1, 9)),
                  NumberExpression(numberToken(2, 1, 13)),
                ],
              ),
              NumberExpression(numberToken(3, 1, 18)),
            ],
          ),
        ),
      ]);
    });

    test('Precedence: addition before equality', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = 1 + 2 == 3',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('==', 1, 14)),
            arguments: [
              CallExpression(
                callee: IdentifierExpression(identifierToken('+', 1, 10)),
                arguments: [
                  NumberExpression(numberToken(1, 1, 8)),
                  NumberExpression(numberToken(2, 1, 12)),
                ],
              ),
              NumberExpression(numberToken(3, 1, 17)),
            ],
          ),
        ),
      ]);
    });

    test('Precedence: division before subtraction', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = 10 - 4 / 2',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('-', 1, 11)),
            arguments: [
              NumberExpression(numberToken(10, 1, 8)),
              CallExpression(
                callee: IdentifierExpression(identifierToken('/', 1, 15)),
                arguments: [
                  NumberExpression(numberToken(4, 1, 13)),
                  NumberExpression(numberToken(2, 1, 17)),
                ],
              ),
            ],
          ),
        ),
      ]);
    });

    // Collection edge cases

    test('Empty list', () {
      final List<FunctionDefinition> functions = getFunctions('test = []');
      checkFunctions(functions, [
        const FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: ListExpression(
            location: Location(row: 1, column: 8),
            value: [],
          ),
        ),
      ]);
    });

    test('Empty map', () {
      final List<FunctionDefinition> functions = getFunctions('test = {}');
      checkFunctions(functions, [
        const FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: MapExpression(
            location: Location(row: 1, column: 8),
            value: [],
          ),
        ),
      ]);
    });

    test('Nested list', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = [[1], [2]]',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: ListExpression(
            location: const Location(row: 1, column: 8),
            value: [
              ListExpression(
                location: const Location(row: 1, column: 9),
                value: [NumberExpression(numberToken(1, 1, 10))],
              ),
              ListExpression(
                location: const Location(row: 1, column: 14),
                value: [NumberExpression(numberToken(2, 1, 15))],
              ),
            ],
          ),
        ),
      ]);
    });

    // Indexing variations

    test('Indexing on identifier', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test(list) = list[0]',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: ['list'],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('@', 1, 18)),
            arguments: [
              IdentifierExpression(identifierToken('list', 1, 14)),
              NumberExpression(numberToken(0, 1, 19)),
            ],
          ),
        ),
      ]);
    });

    test('Indexing on string', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = "abc"[1]',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('@', 1, 13)),
            arguments: [
              StringExpression(stringToken('abc', 1, 8)),
              NumberExpression(numberToken(1, 1, 14)),
            ],
          ),
        ),
      ]);
    });

    test('Indexing with complex expression', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test(list) = list[1 + 2]',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: ['list'],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('@', 1, 18)),
            arguments: [
              IdentifierExpression(identifierToken('list', 1, 14)),
              CallExpression(
                callee: IdentifierExpression(identifierToken('+', 1, 21)),
                arguments: [
                  NumberExpression(numberToken(1, 1, 19)),
                  NumberExpression(numberToken(2, 1, 23)),
                ],
              ),
            ],
          ),
        ),
      ]);
    });

    // Function calls

    test('No-argument function call', () {
      final List<FunctionDefinition> functions = getFunctions('test = foo()');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('foo', 1, 8)),
            arguments: [],
          ),
        ),
      ]);
    });

    test('Multi-argument function call', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = foo(1, 2, 3)',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('foo', 1, 8)),
            arguments: [
              NumberExpression(numberToken(1, 1, 12)),
              NumberExpression(numberToken(2, 1, 15)),
              NumberExpression(numberToken(3, 1, 18)),
            ],
          ),
        ),
      ]);
    });

    test('Nested function call', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = foo(bar(1))',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('foo', 1, 8)),
            arguments: [
              CallExpression(
                callee: IdentifierExpression(identifierToken('bar', 1, 12)),
                arguments: [
                  NumberExpression(numberToken(1, 1, 16)),
                ],
              ),
            ],
          ),
        ),
      ]);
    });

    test('Chained function call', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = foo(1)(2)',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: CallExpression(
              callee: IdentifierExpression(identifierToken('foo', 1, 8)),
              arguments: [
                NumberExpression(numberToken(1, 1, 12)),
              ],
            ),
            arguments: [
              NumberExpression(numberToken(2, 1, 15)),
            ],
          ),
        ),
      ]);
    });

    // Nested if/else

    test('Nested if/else', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test(a, b) = if (a) if (b) 1 else 2 else 3',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: ['a', 'b'],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('if', 1, 14)),
            arguments: [
              IdentifierExpression(identifierToken('a', 1, 18)),
              CallExpression(
                callee: IdentifierExpression(identifierToken('if', 1, 21)),
                arguments: [
                  IdentifierExpression(identifierToken('b', 1, 25)),
                  NumberExpression(numberToken(1, 1, 28)),
                  NumberExpression(numberToken(2, 1, 35)),
                ],
              ),
              NumberExpression(numberToken(3, 1, 42)),
            ],
          ),
        ),
      ]);
    });

    // Multiple function definitions

    test('Multiple function definitions', () {
      final List<FunctionDefinition> functions = getFunctions('a = 1\nb = 2');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'a',
          parameters: [],
          expression: NumberExpression(numberToken(1, 1, 5)),
        ),
        FunctionDefinition(
          name: 'b',
          parameters: [],
          expression: NumberExpression(numberToken(2, 2, 5)),
        ),
      ]);
    });

    // Number literal formats

    test('Literal number with underscore separator', () {
      final List<FunctionDefinition> functions = getFunctions(
        'million = 1_000_000',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'million',
          parameters: [],
          expression: NumberExpression(numberToken(1000000, 1, 11)),
        ),
      ]);
    });

    test('Literal number with scientific notation', () {
      final List<FunctionDefinition> functions = getFunctions('big = 1e10');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'big',
          parameters: [],
          expression: NumberExpression(numberToken(1e10, 1, 7)),
        ),
      ]);
    });

    test('Literal number with scientific notation and negative exponent', () {
      final List<FunctionDefinition> functions = getFunctions('small = 1e-5');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'small',
          parameters: [],
          expression: NumberExpression(numberToken(1e-5, 1, 9)),
        ),
      ]);
    });

    test('Literal decimal with scientific notation', () {
      final List<FunctionDefinition> functions = getFunctions('val = 2.5e3');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'val',
          parameters: [],
          expression: NumberExpression(numberToken(2.5e3, 1, 7)),
        ),
      ]);
    });

    // ResultState terminal behavior

    test('ResultState.next throws StateError', () {
      final ListIterator<Token> iterator = ListIterator<Token>([]);
      final ResultState resultState = ResultState(
        iterator,
        FunctionDefinition(
          name: 'test',
          expression: BooleanExpression(booleanToken(true, 1, 1)),
        ),
      );

      expect(
        () => resultState.next,
        throwsA(isA<StateError>()),
      );
    });

    // Empty source

    test('Empty source returns empty list', () {
      final List<FunctionDefinition> functions = getFunctions('');
      expect(functions, isEmpty);
    });

    // Binary modulo operator

    test('Binary modulo', () {
      final List<FunctionDefinition> functions = getFunctions('test = 10 % 3');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('%', 1, 11)),
            arguments: [
              NumberExpression(numberToken(10, 1, 8)),
              NumberExpression(numberToken(3, 1, 13)),
            ],
          ),
        ),
      ]);
    });

    // Explicit @ operator

    test('Binary index operator with @', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test(list) = list @ 0',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: ['list'],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('@', 1, 19)),
            arguments: [
              IdentifierExpression(identifierToken('list', 1, 14)),
              NumberExpression(numberToken(0, 1, 21)),
            ],
          ),
        ),
      ]);
    });

    // Single-element collections

    test('Single-element list', () {
      final List<FunctionDefinition> functions = getFunctions('test = [42]');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: ListExpression(
            location: const Location(row: 1, column: 8),
            value: [
              NumberExpression(numberToken(42, 1, 9)),
            ],
          ),
        ),
      ]);
    });

    test('Single-entry map', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = {1: "one"}',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: MapExpression(
            location: const Location(row: 1, column: 8),
            value: [
              MapEntryExpression(
                location: const Location(row: 1, column: 9),
                key: NumberExpression(numberToken(1, 1, 9)),
                value: StringExpression(stringToken('one', 1, 12)),
              ),
            ],
          ),
        ),
      ]);
    });

    // Nested collections

    test('Nested map', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = {"a": {"b": 1}}',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: MapExpression(
            location: const Location(row: 1, column: 8),
            value: [
              MapEntryExpression(
                location: const Location(row: 1, column: 9),
                key: StringExpression(stringToken('a', 1, 9)),
                value: MapExpression(
                  location: const Location(row: 1, column: 14),
                  value: [
                    MapEntryExpression(
                      location: const Location(row: 1, column: 15),
                      key: StringExpression(stringToken('b', 1, 15)),
                      value: NumberExpression(numberToken(1, 1, 20)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ]);
    });

    // Chained indexing

    test('Chained indexing with brackets', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = [[1, 2], [3, 4]][0][1]',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('@', 1, 27)),
            arguments: [
              CallExpression(
                callee: IdentifierExpression(identifierToken('@', 1, 24)),
                arguments: [
                  ListExpression(
                    location: const Location(row: 1, column: 8),
                    value: [
                      ListExpression(
                        location: const Location(row: 1, column: 9),
                        value: [
                          NumberExpression(numberToken(1, 1, 10)),
                          NumberExpression(numberToken(2, 1, 13)),
                        ],
                      ),
                      ListExpression(
                        location: const Location(row: 1, column: 17),
                        value: [
                          NumberExpression(numberToken(3, 1, 18)),
                          NumberExpression(numberToken(4, 1, 21)),
                        ],
                      ),
                    ],
                  ),
                  NumberExpression(numberToken(0, 1, 25)),
                ],
              ),
              NumberExpression(numberToken(1, 1, 28)),
            ],
          ),
        ),
      ]);
    });

    // Error cases: unclosed delimiters

    test('Error: unclosed list', () {
      expect(
        () => getFunctions('test = [1, 2'),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('Error: unclosed map', () {
      expect(
        () => getFunctions('test = {1: 2'),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('Error: unclosed parentheses in expression', () {
      expect(
        () => getFunctions('test = (1 + 2'),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('Error: unclosed function call', () {
      expect(
        () => getFunctions('test = foo(1, 2'),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('Error: if missing closing paren', () {
      expect(
        () => getFunctions('test = if (true 1 else 2'),
        throwsA(isA<ExpectedTokenError>()),
      );
    });

    test('Error: map with wrong closing delimiter', () {
      expect(
        () => getFunctions('test = {1: 2]'),
        throwsA(isA<ExpectedTokenError>()),
      );
    });

    test('Error: unclosed bracket index', () {
      expect(
        () => getFunctions('test = list[0'),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    // Chained operators

    test('Chained addition (left associativity)', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = 1 + 2 + 3',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('+', 1, 14)),
            arguments: [
              CallExpression(
                callee: IdentifierExpression(identifierToken('+', 1, 10)),
                arguments: [
                  NumberExpression(numberToken(1, 1, 8)),
                  NumberExpression(numberToken(2, 1, 12)),
                ],
              ),
              NumberExpression(numberToken(3, 1, 16)),
            ],
          ),
        ),
      ]);
    });

    test('Chained subtraction (left associativity)', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = 10 - 3 - 2',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('-', 1, 15)),
            arguments: [
              CallExpression(
                callee: IdentifierExpression(identifierToken('-', 1, 11)),
                arguments: [
                  NumberExpression(numberToken(10, 1, 8)),
                  NumberExpression(numberToken(3, 1, 13)),
                ],
              ),
              NumberExpression(numberToken(2, 1, 17)),
            ],
          ),
        ),
      ]);
    });

    test('Chained comparison operators', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = 1 < 2 < 3',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('<', 1, 14)),
            arguments: [
              CallExpression(
                callee: IdentifierExpression(identifierToken('<', 1, 10)),
                arguments: [
                  NumberExpression(numberToken(1, 1, 8)),
                  NumberExpression(numberToken(2, 1, 12)),
                ],
              ),
              NumberExpression(numberToken(3, 1, 16)),
            ],
          ),
        ),
      ]);
    });

    test('Chained equality operators', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = true == true == false',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('==', 1, 21)),
            arguments: [
              CallExpression(
                callee: IdentifierExpression(identifierToken('==', 1, 13)),
                arguments: [
                  BooleanExpression(booleanToken(true, 1, 8)),
                  BooleanExpression(booleanToken(true, 1, 16)),
                ],
              ),
              BooleanExpression(booleanToken(false, 1, 24)),
            ],
          ),
        ),
      ]);
    });

    test('Chained logical or', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = true | false | true',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('|', 1, 21)),
            arguments: [
              CallExpression(
                callee: IdentifierExpression(identifierToken('|', 1, 13)),
                arguments: [
                  BooleanExpression(booleanToken(true, 1, 8)),
                  BooleanExpression(booleanToken(false, 1, 15)),
                ],
              ),
              BooleanExpression(booleanToken(true, 1, 23)),
            ],
          ),
        ),
      ]);
    });

    test('Chained logical and', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = true & false & true',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('&', 1, 21)),
            arguments: [
              CallExpression(
                callee: IdentifierExpression(identifierToken('&', 1, 13)),
                arguments: [
                  BooleanExpression(booleanToken(true, 1, 8)),
                  BooleanExpression(booleanToken(false, 1, 15)),
                ],
              ),
              BooleanExpression(booleanToken(true, 1, 23)),
            ],
          ),
        ),
      ]);
    });

    // Double unary operations

    test('Double negation', () {
      final List<FunctionDefinition> functions = getFunctions('test = --5');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('-', 1, 8)),
            arguments: [
              NumberExpression(numberToken(0, 1, 8)),
              CallExpression(
                callee: IdentifierExpression(identifierToken('-', 1, 9)),
                arguments: [
                  NumberExpression(numberToken(0, 1, 9)),
                  NumberExpression(numberToken(5, 1, 10)),
                ],
              ),
            ],
          ),
        ),
      ]);
    });

    test('Double logical not', () {
      final List<FunctionDefinition> functions = getFunctions('test = !!true');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('!', 1, 8)),
            arguments: [
              CallExpression(
                callee: IdentifierExpression(identifierToken('!', 1, 9)),
                arguments: [
                  BooleanExpression(booleanToken(true, 1, 10)),
                ],
              ),
            ],
          ),
        ),
      ]);
    });

    // Precedence: logical operators

    test('Precedence: and before or', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = true | false & true',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('|', 1, 13)),
            arguments: [
              BooleanExpression(booleanToken(true, 1, 8)),
              CallExpression(
                callee: IdentifierExpression(identifierToken('&', 1, 21)),
                arguments: [
                  BooleanExpression(booleanToken(false, 1, 15)),
                  BooleanExpression(booleanToken(true, 1, 23)),
                ],
              ),
            ],
          ),
        ),
      ]);
    });

    test('Precedence: comparison before equality', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = 1 < 2 == true',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('==', 1, 14)),
            arguments: [
              CallExpression(
                callee: IdentifierExpression(identifierToken('<', 1, 10)),
                arguments: [
                  NumberExpression(numberToken(1, 1, 8)),
                  NumberExpression(numberToken(2, 1, 12)),
                ],
              ),
              BooleanExpression(booleanToken(true, 1, 17)),
            ],
          ),
        ),
      ]);
    });

    test('Precedence: unary before binary', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = -5 + 3',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('+', 1, 11)),
            arguments: [
              CallExpression(
                callee: IdentifierExpression(identifierToken('-', 1, 8)),
                arguments: [
                  NumberExpression(numberToken(0, 1, 8)),
                  NumberExpression(numberToken(5, 1, 9)),
                ],
              ),
              NumberExpression(numberToken(3, 1, 13)),
            ],
          ),
        ),
      ]);
    });

    // Expression toString methods

    test('StringExpression toString includes quotes', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = "hello"',
      );
      final StringExpression expression =
          functions[0].expression as StringExpression;
      expect(expression.toString(), equals('"hello"'));
    });

    test('MapExpression toString formats entries', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = {1: "a", 2: "b"}',
      );
      final MapExpression expression = functions[0].expression as MapExpression;
      expect(expression.toString(), equals('{1: "a", 2: "b"}'));
    });

    test('CallExpression toString formats as function call', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = foo(1, 2)',
      );
      final CallExpression expression =
          functions[0].expression as CallExpression;
      expect(expression.toString(), equals('foo(1, 2)'));
    });

    test('ListExpression toString formats elements', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = [1, 2, 3]',
      );
      final ListExpression expression =
          functions[0].expression as ListExpression;
      expect(expression.toString(), equals('[1, 2, 3]'));
    });

    // FunctionDefinitionBuilder tests

    test('FunctionDefinitionBuilder creates function with name', () {
      const FunctionDefinitionBuilder builder = FunctionDefinitionBuilder(
        name: 'myFunc',
      );
      final FunctionDefinition definition = builder.build(
        BooleanExpression(booleanToken(true, 1, 1)),
      );

      expect(definition.name, equals('myFunc'));
      expect(definition.parameters, isEmpty);
    });

    test('FunctionDefinitionBuilder withParameter adds parameter', () {
      const FunctionDefinitionBuilder builder = FunctionDefinitionBuilder(
        name: 'myFunc',
      );
      final FunctionDefinitionBuilder withParam = builder.withParameter('x');

      expect(withParam.parameters, equals(['x']));
    });

    test('FunctionDefinitionBuilder chains parameters', () {
      const FunctionDefinitionBuilder builder = FunctionDefinitionBuilder(
        name: 'myFunc',
      );
      final FunctionDefinitionBuilder withParams = builder
          .withParameter('x')
          .withParameter('y')
          .withParameter('z');

      expect(withParams.parameters, equals(['x', 'y', 'z']));
    });

    // CallExpression factory constructors

    test('CallExpression.fromIf creates if call', () {
      final CallExpression expression = CallExpression.fromIf(
        operator: identifierToken('if', 1, 1),
        condition: BooleanExpression(booleanToken(true, 1, 5)),
        ifTrue: NumberExpression(numberToken(1, 1, 11)),
        ifFalse: NumberExpression(numberToken(2, 1, 18)),
      );

      expect(expression.callee, isA<IdentifierExpression>());
      expect((expression.callee as IdentifierExpression).value, equals('if'));
      expect(expression.arguments.length, equals(3));
    });

    test('CallExpression.fromUnaryOperation creates unary call', () {
      final CallExpression expression = CallExpression.fromUnaryOperation(
        operator: identifierToken('!', 1, 1),
        expression: BooleanExpression(booleanToken(true, 1, 2)),
      );

      expect(expression.callee, isA<IdentifierExpression>());
      expect((expression.callee as IdentifierExpression).value, equals('!'));
      expect(expression.arguments.length, equals(1));
    });

    test('CallExpression.fromBinaryOperation creates binary call', () {
      final CallExpression expression = CallExpression.fromBinaryOperation(
        operator: identifierToken('+', 1, 3),
        left: NumberExpression(numberToken(1, 1, 1)),
        right: NumberExpression(numberToken(2, 1, 5)),
      );

      expect(expression.callee, isA<IdentifierExpression>());
      expect((expression.callee as IdentifierExpression).value, equals('+'));
      expect(expression.arguments.length, equals(2));
    });

    // CallExpression location inherits from callee

    test('CallExpression location equals callee location', () {
      final CallExpression expression = CallExpression(
        callee: IdentifierExpression(identifierToken('foo', 1, 5)),
        arguments: [],
      );

      expect(expression.location, equals(const Location(row: 1, column: 5)));
    });

    // LiteralExpression toString

    test('NumberExpression toString returns numeric value', () {
      final NumberExpression expression = NumberExpression(
        numberToken(42, 1, 1),
      );
      expect(expression.toString(), equals('42'));
    });

    test('BooleanExpression toString returns boolean value', () {
      final BooleanExpression expression = BooleanExpression(
        booleanToken(false, 1, 1),
      );
      expect(expression.toString(), equals('false'));
    });

    // Mixed expressions in collections

    test('List with mixed expression types', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = [1, "two", true]',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: ListExpression(
            location: const Location(row: 1, column: 8),
            value: [
              NumberExpression(numberToken(1, 1, 9)),
              StringExpression(stringToken('two', 1, 12)),
              BooleanExpression(booleanToken(true, 1, 19)),
            ],
          ),
        ),
      ]);
    });

    test('Map with different key types', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = {1: "a", "b": 2}',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: MapExpression(
            location: const Location(row: 1, column: 8),
            value: [
              MapEntryExpression(
                location: const Location(row: 1, column: 9),
                key: NumberExpression(numberToken(1, 1, 9)),
                value: StringExpression(stringToken('a', 1, 12)),
              ),
              MapEntryExpression(
                location: const Location(row: 1, column: 17),
                key: StringExpression(stringToken('b', 1, 17)),
                value: NumberExpression(numberToken(2, 1, 22)),
              ),
            ],
          ),
        ),
      ]);
    });

    // Complex expressions as arguments

    test('Function call with expression arguments', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = foo(1 + 2, 3 * 4)',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('foo', 1, 8)),
            arguments: [
              CallExpression(
                callee: IdentifierExpression(identifierToken('+', 1, 14)),
                arguments: [
                  NumberExpression(numberToken(1, 1, 12)),
                  NumberExpression(numberToken(2, 1, 16)),
                ],
              ),
              CallExpression(
                callee: IdentifierExpression(identifierToken('*', 1, 21)),
                arguments: [
                  NumberExpression(numberToken(3, 1, 19)),
                  NumberExpression(numberToken(4, 1, 23)),
                ],
              ),
            ],
          ),
        ),
      ]);
    });

    // Indexing result of function call

    test('Indexing result of function call', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = foo()[0]',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('@', 1, 13)),
            arguments: [
              CallExpression(
                callee: IdentifierExpression(identifierToken('foo', 1, 8)),
                arguments: [],
              ),
              NumberExpression(numberToken(0, 1, 14)),
            ],
          ),
        ),
      ]);
    });

    // Grouped expression with indexing

    test('Grouped expression with indexing', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test(list) = (list)[0]',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: ['list'],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('@', 1, 20)),
            arguments: [
              IdentifierExpression(identifierToken('list', 1, 15)),
              NumberExpression(numberToken(0, 1, 21)),
            ],
          ),
        ),
      ]);
    });

    // Error: invalid primary expression

    test('Error: invalid primary expression', () {
      expect(
        () => getFunctions('test = +'),
        throwsA(isA<InvalidTokenError>()),
      );
    });

    // Error: missing else keyword

    test('Error: missing else keyword', () {
      expect(
        () => getFunctions('test = if (true) 1 2'),
        throwsA(isA<ExpectedTokenError>()),
      );
    });

    // If expression with complex condition

    test('If expression with complex condition', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test(x) = if (x > 0 & x < 10) 1 else 0',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: ['x'],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('if', 1, 11)),
            arguments: [
              CallExpression(
                callee: IdentifierExpression(identifierToken('&', 1, 21)),
                arguments: [
                  CallExpression(
                    callee: IdentifierExpression(identifierToken('>', 1, 17)),
                    arguments: [
                      IdentifierExpression(identifierToken('x', 1, 15)),
                      NumberExpression(numberToken(0, 1, 19)),
                    ],
                  ),
                  CallExpression(
                    callee: IdentifierExpression(identifierToken('<', 1, 25)),
                    arguments: [
                      IdentifierExpression(identifierToken('x', 1, 23)),
                      NumberExpression(numberToken(10, 1, 27)),
                    ],
                  ),
                ],
              ),
              NumberExpression(numberToken(1, 1, 31)),
              NumberExpression(numberToken(0, 1, 38)),
            ],
          ),
        ),
      ]);
    });

    // If expression as argument

    test('If expression as function argument', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = foo(if (true) 1 else 2)',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('foo', 1, 8)),
            arguments: [
              CallExpression(
                callee: IdentifierExpression(identifierToken('if', 1, 12)),
                arguments: [
                  BooleanExpression(booleanToken(true, 1, 16)),
                  NumberExpression(numberToken(1, 1, 22)),
                  NumberExpression(numberToken(2, 1, 29)),
                ],
              ),
            ],
          ),
        ),
      ]);
    });

    // Whitespace handling with newlines

    test('Multiple functions separated by newlines', () {
      final List<FunctionDefinition> functions = getFunctions(
        'a = 1\n\nb = 2\n\nc = 3',
      );
      expect(functions.length, equals(3));
      expect(functions[0].name, equals('a'));
      expect(functions[1].name, equals('b'));
      expect(functions[2].name, equals('c'));
    });

    // Identifier expression

    test('Identifier expression', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test(x) = x',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: ['x'],
          expression: IdentifierExpression(identifierToken('x', 1, 11)),
        ),
      ]);
    });
  });
}
