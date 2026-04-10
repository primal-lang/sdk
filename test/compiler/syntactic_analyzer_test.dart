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

    // IdentifierExpression toString and location

    test('IdentifierExpression toString returns identifier name', () {
      final IdentifierExpression expression = IdentifierExpression(
        identifierToken('myVariable', 1, 1),
      );
      expect(expression.toString(), equals('myVariable'));
    });

    test('IdentifierExpression location matches token location', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test(x) = x',
      );
      final IdentifierExpression expression =
          functions[0].expression as IdentifierExpression;
      expect(expression.location, equals(const Location(row: 1, column: 11)));
    });

    // ListExpression toString with single element

    test('ListExpression toString with single element', () {
      final List<FunctionDefinition> functions = getFunctions('test = [42]');
      final ListExpression expression =
          functions[0].expression as ListExpression;
      expect(expression.toString(), equals('[42]'));
    });

    // Empty ListExpression toString

    test('Empty ListExpression toString', () {
      final List<FunctionDefinition> functions = getFunctions('test = []');
      final ListExpression expression =
          functions[0].expression as ListExpression;
      expect(expression.toString(), equals('[]'));
    });

    // Empty MapExpression toString

    test('Empty MapExpression toString', () {
      final List<FunctionDefinition> functions = getFunctions('test = {}');
      final MapExpression expression = functions[0].expression as MapExpression;
      expect(expression.toString(), equals('{}'));
    });

    // Single entry MapExpression toString

    test('Single entry MapExpression toString', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = {1: "one"}',
      );
      final MapExpression expression = functions[0].expression as MapExpression;
      expect(expression.toString(), equals('{1: "one"}'));
    });

    // Expression location verification

    test('NumberExpression location matches token location', () {
      final List<FunctionDefinition> functions = getFunctions('test = 42');
      final NumberExpression expression =
          functions[0].expression as NumberExpression;
      expect(expression.location, equals(const Location(row: 1, column: 8)));
    });

    test('BooleanExpression location matches token location', () {
      final List<FunctionDefinition> functions = getFunctions('test = true');
      final BooleanExpression expression =
          functions[0].expression as BooleanExpression;
      expect(expression.location, equals(const Location(row: 1, column: 8)));
    });

    test('StringExpression location matches token location', () {
      final List<FunctionDefinition> functions = getFunctions('test = "hi"');
      final StringExpression expression =
          functions[0].expression as StringExpression;
      expect(expression.location, equals(const Location(row: 1, column: 8)));
    });

    test('ListExpression location matches opening bracket', () {
      final List<FunctionDefinition> functions = getFunctions('test = [1, 2]');
      final ListExpression expression =
          functions[0].expression as ListExpression;
      expect(expression.location, equals(const Location(row: 1, column: 8)));
    });

    test('MapExpression location matches opening brace', () {
      final List<FunctionDefinition> functions = getFunctions('test = {1: 2}');
      final MapExpression expression = functions[0].expression as MapExpression;
      expect(expression.location, equals(const Location(row: 1, column: 8)));
    });

    // Chained @ operators

    test('Chained @ operators', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = list @ 0 @ 1',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('@', 1, 17)),
            arguments: [
              CallExpression(
                callee: IdentifierExpression(identifierToken('@', 1, 13)),
                arguments: [
                  IdentifierExpression(identifierToken('list', 1, 8)),
                  NumberExpression(numberToken(0, 1, 15)),
                ],
              ),
              NumberExpression(numberToken(1, 1, 19)),
            ],
          ),
        ),
      ]);
    });

    // Mixed indexing with bracket and @ operator

    test('Mixed indexing with bracket and @ operator', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = list[0] @ 1',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('@', 1, 16)),
            arguments: [
              CallExpression(
                callee: IdentifierExpression(identifierToken('@', 1, 12)),
                arguments: [
                  IdentifierExpression(identifierToken('list', 1, 8)),
                  NumberExpression(numberToken(0, 1, 13)),
                ],
              ),
              NumberExpression(numberToken(1, 1, 18)),
            ],
          ),
        ),
      ]);
    });

    // Error: missing assignment after parameterized function

    test('Error: missing assignment after parameterized function', () {
      expect(
        () => getFunctions('test(a) b'),
        throwsA(isA<InvalidTokenError>()),
      );
    });

    // Deeply nested parentheses

    test('Deeply nested parentheses', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = (((1)))',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: NumberExpression(numberToken(1, 1, 11)),
        ),
      ]);
    });

    // Boolean false expression

    test('Literal boolean false', () {
      final List<FunctionDefinition> functions = getFunctions(
        'disabled = false',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'disabled',
          parameters: [],
          expression: BooleanExpression(booleanToken(false, 1, 12)),
        ),
      ]);
    });

    // Integer number format

    test('Literal integer number', () {
      final List<FunctionDefinition> functions = getFunctions('value = 42');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'value',
          parameters: [],
          expression: NumberExpression(numberToken(42, 1, 9)),
        ),
      ]);
    });

    // Zero number

    test('Literal zero', () {
      final List<FunctionDefinition> functions = getFunctions('zero = 0');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'zero',
          parameters: [],
          expression: NumberExpression(numberToken(0, 1, 8)),
        ),
      ]);
    });

    // Negative number via unary operator

    test('Negative number', () {
      final List<FunctionDefinition> functions = getFunctions('neg = -42');
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'neg',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('-', 1, 7)),
            arguments: [
              NumberExpression(numberToken(0, 1, 7)),
              NumberExpression(numberToken(42, 1, 8)),
            ],
          ),
        ),
      ]);
    });

    // Indexing on grouped expression

    test('Indexing on grouped expression with operation', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = (foo())[0]',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('@', 1, 15)),
            arguments: [
              CallExpression(
                callee: IdentifierExpression(identifierToken('foo', 1, 9)),
                arguments: [],
              ),
              NumberExpression(numberToken(0, 1, 16)),
            ],
          ),
        ),
      ]);
    });

    // Function definition with two parameters

    test('Function with two parameters', () {
      final List<FunctionDefinition> functions = getFunctions(
        'add(a, b) = a + b',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'add',
          parameters: ['a', 'b'],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('+', 1, 15)),
            arguments: [
              IdentifierExpression(identifierToken('a', 1, 13)),
              IdentifierExpression(identifierToken('b', 1, 17)),
            ],
          ),
        ),
      ]);
    });

    // Error: non-identifier as first token

    test('Error: number as first token', () {
      expect(
        () => getFunctions('1 = 2'),
        throwsA(isA<InvalidTokenError>()),
      );
    });

    // Error: string as function name

    test('Error: string as function name', () {
      expect(
        () => getFunctions('"hello" = true'),
        throwsA(isA<InvalidTokenError>()),
      );
    });

    // Error: missing expression after unary operator

    test('Error: missing expression after unary minus', () {
      expect(
        () => getFunctions('test = -'),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('Error: missing expression after unary not', () {
      expect(
        () => getFunctions('test = !'),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    // Whitespace only source

    test('Whitespace only source returns empty list', () {
      final List<FunctionDefinition> functions = getFunctions('   \n\t\n   ');
      expect(functions, isEmpty);
    });

    // If expression with function call branches

    test('If expression with function call branches', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = if (true) foo() else bar()',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('if', 1, 8)),
            arguments: [
              BooleanExpression(booleanToken(true, 1, 12)),
              CallExpression(
                callee: IdentifierExpression(identifierToken('foo', 1, 18)),
                arguments: [],
              ),
              CallExpression(
                callee: IdentifierExpression(identifierToken('bar', 1, 29)),
                arguments: [],
              ),
            ],
          ),
        ),
      ]);
    });

    // List with function call elements

    test('List with function call elements', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = [foo(), bar()]',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: ListExpression(
            location: const Location(row: 1, column: 8),
            value: [
              CallExpression(
                callee: IdentifierExpression(identifierToken('foo', 1, 9)),
                arguments: [],
              ),
              CallExpression(
                callee: IdentifierExpression(identifierToken('bar', 1, 16)),
                arguments: [],
              ),
            ],
          ),
        ),
      ]);
    });

    // Map with function call values

    test('Map with function call values', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = {1: foo()}',
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
                value: CallExpression(
                  callee: IdentifierExpression(identifierToken('foo', 1, 12)),
                  arguments: [],
                ),
              ),
            ],
          ),
        ),
      ]);
    });

    // Error: unclosed parameter list

    test('Error: unclosed parameter list', () {
      expect(
        () => getFunctions('test(a, b'),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    // Error: unexpected token in parameter list after identifier

    test('Error: unexpected token in parameter list', () {
      expect(
        () => getFunctions('test(a b) = 1'),
        throwsA(isA<InvalidTokenError>()),
      );
    });

    // Chained multiplication (left associativity)

    test('Chained multiplication (left associativity)', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = 2 * 3 * 4',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('*', 1, 14)),
            arguments: [
              CallExpression(
                callee: IdentifierExpression(identifierToken('*', 1, 10)),
                arguments: [
                  NumberExpression(numberToken(2, 1, 8)),
                  NumberExpression(numberToken(3, 1, 12)),
                ],
              ),
              NumberExpression(numberToken(4, 1, 16)),
            ],
          ),
        ),
      ]);
    });

    // Chained division (left associativity)

    test('Chained division (left associativity)', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = 24 / 4 / 2',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('/', 1, 15)),
            arguments: [
              CallExpression(
                callee: IdentifierExpression(identifierToken('/', 1, 11)),
                arguments: [
                  NumberExpression(numberToken(24, 1, 8)),
                  NumberExpression(numberToken(4, 1, 13)),
                ],
              ),
              NumberExpression(numberToken(2, 1, 17)),
            ],
          ),
        ),
      ]);
    });

    // Chained modulo (left associativity)

    test('Chained modulo (left associativity)', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = 17 % 10 % 3',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('%', 1, 16)),
            arguments: [
              CallExpression(
                callee: IdentifierExpression(identifierToken('%', 1, 11)),
                arguments: [
                  NumberExpression(numberToken(17, 1, 8)),
                  NumberExpression(numberToken(10, 1, 13)),
                ],
              ),
              NumberExpression(numberToken(3, 1, 18)),
            ],
          ),
        ),
      ]);
    });

    // Error: empty grouped expression

    test('Error: empty grouped expression', () {
      expect(
        () => getFunctions('test = ()'),
        throwsA(isA<InvalidTokenError>()),
      );
    });

    // FunctionDefinitionBuilder preserves parameters immutably

    test('FunctionDefinitionBuilder withParameter returns new builder', () {
      const FunctionDefinitionBuilder builder1 = FunctionDefinitionBuilder(
        name: 'test',
      );
      final FunctionDefinitionBuilder builder2 = builder1.withParameter('a');
      final FunctionDefinitionBuilder builder3 = builder1.withParameter('b');

      expect(builder1.parameters, isEmpty);
      expect(builder2.parameters, equals(['a']));
      expect(builder3.parameters, equals(['b']));
    });

    // FunctionDefinitionBuilder builds with expression

    test('FunctionDefinitionBuilder build creates FunctionDefinition', () {
      const FunctionDefinitionBuilder builder = FunctionDefinitionBuilder(
        name: 'myFunc',
        parameters: ['x', 'y'],
      );
      final FunctionDefinition definition = builder.build(
        NumberExpression(numberToken(42, 1, 1)),
      );

      expect(definition.name, equals('myFunc'));
      expect(definition.parameters, equals(['x', 'y']));
      expect(definition.expression, isA<NumberExpression>());
    });

    // CallExpression.fromIf creates correct structure

    test('CallExpression.fromIf has three arguments', () {
      final CallExpression expression = CallExpression.fromIf(
        operator: identifierToken('if', 1, 1),
        condition: BooleanExpression(booleanToken(true, 1, 5)),
        ifTrue: NumberExpression(numberToken(1, 1, 11)),
        ifFalse: NumberExpression(numberToken(0, 1, 18)),
      );

      expect(expression.arguments.length, equals(3));
      expect(expression.arguments[0], isA<BooleanExpression>());
      expect(expression.arguments[1], isA<NumberExpression>());
      expect(expression.arguments[2], isA<NumberExpression>());
    });

    // CallExpression toString with nested call

    test('CallExpression toString with nested call', () {
      final CallExpression expression = CallExpression(
        callee: IdentifierExpression(identifierToken('outer', 1, 1)),
        arguments: [
          CallExpression(
            callee: IdentifierExpression(identifierToken('inner', 1, 7)),
            arguments: [
              NumberExpression(numberToken(1, 1, 13)),
            ],
          ),
        ],
      );
      expect(expression.toString(), equals('outer(inner(1))'));
    });

    // CallExpression with no arguments toString

    test('CallExpression with no arguments toString', () {
      final CallExpression expression = CallExpression(
        callee: IdentifierExpression(identifierToken('empty', 1, 1)),
        arguments: [],
      );
      expect(expression.toString(), equals('empty()'));
    });

    // Indexing with negative index

    test('Indexing with negative index', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = list[-1]',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('@', 1, 12)),
            arguments: [
              IdentifierExpression(identifierToken('list', 1, 8)),
              CallExpression(
                callee: IdentifierExpression(identifierToken('-', 1, 13)),
                arguments: [
                  NumberExpression(numberToken(0, 1, 13)),
                  NumberExpression(numberToken(1, 1, 14)),
                ],
              ),
            ],
          ),
        ),
      ]);
    });

    // If expression as map value

    test('If expression as map value', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = {1: if (true) 1 else 0}',
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
                value: CallExpression(
                  callee: IdentifierExpression(identifierToken('if', 1, 12)),
                  arguments: [
                    BooleanExpression(booleanToken(true, 1, 16)),
                    NumberExpression(numberToken(1, 1, 22)),
                    NumberExpression(numberToken(0, 1, 29)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ]);
    });

    // Binary operator as list element

    test('Binary operator expression as list element', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = [1 + 2, 3 * 4]',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: ListExpression(
            location: const Location(row: 1, column: 8),
            value: [
              CallExpression(
                callee: IdentifierExpression(identifierToken('+', 1, 11)),
                arguments: [
                  NumberExpression(numberToken(1, 1, 9)),
                  NumberExpression(numberToken(2, 1, 13)),
                ],
              ),
              CallExpression(
                callee: IdentifierExpression(identifierToken('*', 1, 18)),
                arguments: [
                  NumberExpression(numberToken(3, 1, 16)),
                  NumberExpression(numberToken(4, 1, 20)),
                ],
              ),
            ],
          ),
        ),
      ]);
    });

    // Error: map missing value after colon

    test('Error: map missing value after colon', () {
      expect(
        () => getFunctions('test = {1: }'),
        throwsA(isA<InvalidTokenError>()),
      );
    });

    // Error: list with trailing comma and no closing bracket

    test('Error: list with element missing after comma', () {
      expect(
        () => getFunctions('test = [1, ]'),
        throwsA(isA<InvalidTokenError>()),
      );
    });

    // Combined precedence: all operator levels
    // The order by precedence (lowest to highest) is:
    // equality (==, !=) < or (|) < and (&) < comparison (<, >, <=, >=) < term (+, -) < factor (*, /, %)
    // So: true | false & 1 == 2 < 3 + 4 * 5
    // Parses as: ((true | (false & 1)) == ((2 < ((3 + (4 * 5))))))

    test('Combined precedence: equality is lowest', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = true | false & 1 == 2 < 3 + 4 * 5',
      );
      expect(functions.length, equals(1));
      expect(functions[0].expression, isA<CallExpression>());
      final CallExpression expression =
          functions[0].expression as CallExpression;
      // Equality has lowest precedence, so == is the outermost operator
      expect((expression.callee as IdentifierExpression).value, equals('=='));
    });

    // Function with long identifier names

    test('Function with long identifier names', () {
      final List<FunctionDefinition> functions = getFunctions(
        'calculateTotalPriceWithDiscount(originalPrice) = originalPrice',
      );
      expect(functions.length, equals(1));
      expect(functions[0].name, equals('calculateTotalPriceWithDiscount'));
      expect(functions[0].parameters, equals(['originalPrice']));
    });

    // Error: map with missing key

    test('Error: map starting with colon', () {
      expect(
        () => getFunctions('test = {: 1}'),
        throwsA(isA<InvalidTokenError>()),
      );
    });

    // String with special characters

    test('Literal string with special characters', () {
      final List<FunctionDefinition> functions = getFunctions(
        r'test = "hello\nworld"',
      );
      expect(functions.length, equals(1));
      expect(functions[0].expression, isA<StringExpression>());
    });

    // Multiple chained function calls

    test('Triple chained function call', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = f(1)(2)(3)',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: CallExpression(
              callee: CallExpression(
                callee: IdentifierExpression(identifierToken('f', 1, 8)),
                arguments: [
                  NumberExpression(numberToken(1, 1, 10)),
                ],
              ),
              arguments: [
                NumberExpression(numberToken(2, 1, 13)),
              ],
            ),
            arguments: [
              NumberExpression(numberToken(3, 1, 16)),
            ],
          ),
        ),
      ]);
    });

    // Indexing after function call with arguments

    test('Indexing after function call with arguments', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = foo(1, 2)[0]',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('@', 1, 17)),
            arguments: [
              CallExpression(
                callee: IdentifierExpression(identifierToken('foo', 1, 8)),
                arguments: [
                  NumberExpression(numberToken(1, 1, 12)),
                  NumberExpression(numberToken(2, 1, 15)),
                ],
              ),
              NumberExpression(numberToken(0, 1, 18)),
            ],
          ),
        ),
      ]);
    });

    // Error: function call missing closing parenthesis with argument

    test('Error: function call with argument missing closing paren', () {
      expect(
        () => getFunctions('test = foo(1'),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    // Error: if expression missing else branch value

    test('Error: if expression with incomplete else', () {
      expect(
        () => getFunctions('test = if (true) 1 else'),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    // Equality with string comparison

    test('String equality comparison', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = "a" == "b"',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('==', 1, 12)),
            arguments: [
              StringExpression(stringToken('a', 1, 8)),
              StringExpression(stringToken('b', 1, 15)),
            ],
          ),
        ),
      ]);
    });

    // Not equal with booleans

    test('Boolean not equal comparison', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = true != false',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('!=', 1, 13)),
            arguments: [
              BooleanExpression(booleanToken(true, 1, 8)),
              BooleanExpression(booleanToken(false, 1, 16)),
            ],
          ),
        ),
      ]);
    });

    // Unary not on comparison

    test('Unary not on comparison expression', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = !(1 < 2)',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('!', 1, 8)),
            arguments: [
              CallExpression(
                callee: IdentifierExpression(identifierToken('<', 1, 12)),
                arguments: [
                  NumberExpression(numberToken(1, 1, 10)),
                  NumberExpression(numberToken(2, 1, 14)),
                ],
              ),
            ],
          ),
        ),
      ]);
    });

    // Unary negation on grouped expression

    test('Unary negation on grouped expression', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = -(1 + 2)',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('-', 1, 8)),
            arguments: [
              NumberExpression(numberToken(0, 1, 8)),
              CallExpression(
                callee: IdentifierExpression(identifierToken('+', 1, 12)),
                arguments: [
                  NumberExpression(numberToken(1, 1, 10)),
                  NumberExpression(numberToken(2, 1, 14)),
                ],
              ),
            ],
          ),
        ),
      ]);
    });

    // Chained @ then bracket indexing
    // Note: @ operator has higher precedence than call/bracket indexing,
    // so `list @ 0 [1]` parses as `list @ (0[1])` not `(list @ 0)[1]`

    test('Mixed @ operator then bracket indexing parses @ first', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = list @ 0 [1]',
      );
      // Due to precedence, this parses as: list @ (0[1])
      // which becomes: @(list, @(0, 1))
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('@', 1, 13)),
            arguments: [
              IdentifierExpression(identifierToken('list', 1, 8)),
              CallExpression(
                callee: IdentifierExpression(identifierToken('@', 1, 17)),
                arguments: [
                  NumberExpression(numberToken(0, 1, 15)),
                  NumberExpression(numberToken(1, 1, 18)),
                ],
              ),
            ],
          ),
        ),
      ]);
    });

    // List of lists

    test('List of lists', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = [[], [1], [1, 2]]',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: ListExpression(
            location: const Location(row: 1, column: 8),
            value: [
              const ListExpression(
                location: Location(row: 1, column: 9),
                value: [],
              ),
              ListExpression(
                location: const Location(row: 1, column: 13),
                value: [NumberExpression(numberToken(1, 1, 14))],
              ),
              ListExpression(
                location: const Location(row: 1, column: 18),
                value: [
                  NumberExpression(numberToken(1, 1, 19)),
                  NumberExpression(numberToken(2, 1, 22)),
                ],
              ),
            ],
          ),
        ),
      ]);
    });

    // Map with expression key

    test('Map with expression as key', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = {1 + 2: "three"}',
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
                key: CallExpression(
                  callee: IdentifierExpression(identifierToken('+', 1, 11)),
                  arguments: [
                    NumberExpression(numberToken(1, 1, 9)),
                    NumberExpression(numberToken(2, 1, 13)),
                  ],
                ),
                value: StringExpression(stringToken('three', 1, 16)),
              ),
            ],
          ),
        ),
      ]);
    });

    // Additional chained comparison operators

    test('Chained greater than operators', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = 3 > 2 > 1',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('>', 1, 14)),
            arguments: [
              CallExpression(
                callee: IdentifierExpression(identifierToken('>', 1, 10)),
                arguments: [
                  NumberExpression(numberToken(3, 1, 8)),
                  NumberExpression(numberToken(2, 1, 12)),
                ],
              ),
              NumberExpression(numberToken(1, 1, 16)),
            ],
          ),
        ),
      ]);
    });

    test('Chained greater than or equal operators', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = 3 >= 2 >= 1',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('>=', 1, 15)),
            arguments: [
              CallExpression(
                callee: IdentifierExpression(identifierToken('>=', 1, 10)),
                arguments: [
                  NumberExpression(numberToken(3, 1, 8)),
                  NumberExpression(numberToken(2, 1, 13)),
                ],
              ),
              NumberExpression(numberToken(1, 1, 18)),
            ],
          ),
        ),
      ]);
    });

    test('Chained less than or equal operators', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = 1 <= 2 <= 3',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('<=', 1, 15)),
            arguments: [
              CallExpression(
                callee: IdentifierExpression(identifierToken('<=', 1, 10)),
                arguments: [
                  NumberExpression(numberToken(1, 1, 8)),
                  NumberExpression(numberToken(2, 1, 13)),
                ],
              ),
              NumberExpression(numberToken(3, 1, 18)),
            ],
          ),
        ),
      ]);
    });

    test('Chained not equal operators', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = 1 != 2 != 3',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('!=', 1, 15)),
            arguments: [
              CallExpression(
                callee: IdentifierExpression(identifierToken('!=', 1, 10)),
                arguments: [
                  NumberExpression(numberToken(1, 1, 8)),
                  NumberExpression(numberToken(2, 1, 13)),
                ],
              ),
              NumberExpression(numberToken(3, 1, 18)),
            ],
          ),
        ),
      ]);
    });

    // Multiple function definitions with varying parameter counts

    test('Multiple functions with different parameter counts', () {
      final List<FunctionDefinition> functions = getFunctions(
        'a = 1\nb(x) = x\nc(x, y) = x',
      );
      expect(functions.length, equals(3));
      expect(functions[0].name, equals('a'));
      expect(functions[0].parameters, isEmpty);
      expect(functions[1].name, equals('b'));
      expect(functions[1].parameters, equals(['x']));
      expect(functions[2].name, equals('c'));
      expect(functions[2].parameters, equals(['x', 'y']));
    });

    // Expression value property tests

    test('ListExpression value property contains elements', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = [1, 2, 3]',
      );
      final ListExpression listExpression =
          functions[0].expression as ListExpression;
      expect(listExpression.value.length, equals(3));
      expect(listExpression.value[0], isA<NumberExpression>());
      expect(listExpression.value[1], isA<NumberExpression>());
      expect(listExpression.value[2], isA<NumberExpression>());
    });

    test('MapExpression value property contains entries', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = {1: "a", 2: "b"}',
      );
      final MapExpression mapExpression =
          functions[0].expression as MapExpression;
      expect(mapExpression.value.length, equals(2));
      expect(mapExpression.value[0].key, isA<NumberExpression>());
      expect(mapExpression.value[0].value, isA<StringExpression>());
      expect(mapExpression.value[1].key, isA<NumberExpression>());
      expect(mapExpression.value[1].value, isA<StringExpression>());
    });

    test('IdentifierExpression value property returns identifier name', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test(myVar) = myVar',
      );
      final IdentifierExpression identifierExpression =
          functions[0].expression as IdentifierExpression;
      expect(identifierExpression.value, equals('myVar'));
    });

    // Complex nested expression with call inside bracket index

    test('Function call inside bracket index', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = list[foo()]',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('@', 1, 12)),
            arguments: [
              IdentifierExpression(identifierToken('list', 1, 8)),
              CallExpression(
                callee: IdentifierExpression(identifierToken('foo', 1, 13)),
                arguments: [],
              ),
            ],
          ),
        ),
      ]);
    });

    // Call expression with expression as callee in bracket index

    test('Expression result used as index', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = list[1 + 2 * 3]',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('@', 1, 12)),
            arguments: [
              IdentifierExpression(identifierToken('list', 1, 8)),
              CallExpression(
                callee: IdentifierExpression(identifierToken('+', 1, 15)),
                arguments: [
                  NumberExpression(numberToken(1, 1, 13)),
                  CallExpression(
                    callee: IdentifierExpression(identifierToken('*', 1, 19)),
                    arguments: [
                      NumberExpression(numberToken(2, 1, 17)),
                      NumberExpression(numberToken(3, 1, 21)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ]);
    });

    // Unary not on function call result

    test('Unary not on function call', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = !foo()',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('!', 1, 8)),
            arguments: [
              CallExpression(
                callee: IdentifierExpression(identifierToken('foo', 1, 9)),
                arguments: [],
              ),
            ],
          ),
        ),
      ]);
    });

    // Unary negation on function call result

    test('Unary negation on function call', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = -foo()',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('-', 1, 8)),
            arguments: [
              NumberExpression(numberToken(0, 1, 8)),
              CallExpression(
                callee: IdentifierExpression(identifierToken('foo', 1, 9)),
                arguments: [],
              ),
            ],
          ),
        ),
      ]);
    });

    // If expression inside list

    test('If expression as list element', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = [if (true) 1 else 0]',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: ListExpression(
            location: const Location(row: 1, column: 8),
            value: [
              CallExpression(
                callee: IdentifierExpression(identifierToken('if', 1, 9)),
                arguments: [
                  BooleanExpression(booleanToken(true, 1, 13)),
                  NumberExpression(numberToken(1, 1, 19)),
                  NumberExpression(numberToken(0, 1, 26)),
                ],
              ),
            ],
          ),
        ),
      ]);
    });

    // If expression as map key

    test('If expression as map key', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = {if (true) 1 else 2: "value"}',
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
                key: CallExpression(
                  callee: IdentifierExpression(identifierToken('if', 1, 9)),
                  arguments: [
                    BooleanExpression(booleanToken(true, 1, 13)),
                    NumberExpression(numberToken(1, 1, 19)),
                    NumberExpression(numberToken(2, 1, 26)),
                  ],
                ),
                value: StringExpression(stringToken('value', 1, 29)),
              ),
            ],
          ),
        ),
      ]);
    });

    // Function call with if expression as argument

    test('Function call with binary expression argument', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = foo(a | b)',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('foo', 1, 8)),
            arguments: [
              CallExpression(
                callee: IdentifierExpression(identifierToken('|', 1, 14)),
                arguments: [
                  IdentifierExpression(identifierToken('a', 1, 12)),
                  IdentifierExpression(identifierToken('b', 1, 16)),
                ],
              ),
            ],
          ),
        ),
      ]);
    });

    // Precedence: index before factor

    test('Precedence: index operator before multiplication', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = list @ 0 * 2',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('*', 1, 17)),
            arguments: [
              CallExpression(
                callee: IdentifierExpression(identifierToken('@', 1, 13)),
                arguments: [
                  IdentifierExpression(identifierToken('list', 1, 8)),
                  NumberExpression(numberToken(0, 1, 15)),
                ],
              ),
              NumberExpression(numberToken(2, 1, 19)),
            ],
          ),
        ),
      ]);
    });

    // Error cases: specific error message content

    test('Error: InvalidTokenError contains token information', () {
      try {
        getFunctions('123');
        fail('Expected InvalidTokenError');
      } on InvalidTokenError catch (error) {
        expect(error.message, contains('123'));
        expect(error.message, contains('identifier'));
      }
    });

    test('Error: ExpectedTokenError contains expected token', () {
      try {
        getFunctions('test = if true 1 else 2');
        fail('Expected ExpectedTokenError');
      } on ExpectedTokenError catch (error) {
        expect(error.message, contains('('));
      }
    });

    // Mixed unary operators

    test('Negation of not expression', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = -!true',
      );
      // -!true parses as -(0, !(true))
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('-', 1, 8)),
            arguments: [
              NumberExpression(numberToken(0, 1, 8)),
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

    test('Not of negation expression', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = !-5',
      );
      // !-5 parses as !(-(0, 5))
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('!', 1, 8)),
            arguments: [
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

    // Map with identifier keys

    test('Map with identifier keys', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test(x) = {x: 1}',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: ['x'],
          expression: MapExpression(
            location: const Location(row: 1, column: 11),
            value: [
              MapEntryExpression(
                location: const Location(row: 1, column: 12),
                key: IdentifierExpression(identifierToken('x', 1, 12)),
                value: NumberExpression(numberToken(1, 1, 15)),
              ),
            ],
          ),
        ),
      ]);
    });

    // List with identifier elements

    test('List with identifier elements', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test(x, y) = [x, y]',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: ['x', 'y'],
          expression: ListExpression(
            location: const Location(row: 1, column: 14),
            value: [
              IdentifierExpression(identifierToken('x', 1, 15)),
              IdentifierExpression(identifierToken('y', 1, 18)),
            ],
          ),
        ),
      ]);
    });

    // Chained function calls with indexing mixed

    test('Function call then index then function call', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = foo()[0]()',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: CallExpression(
              callee: IdentifierExpression(identifierToken('@', 1, 13)),
              arguments: [
                CallExpression(
                  callee: IdentifierExpression(identifierToken('foo', 1, 8)),
                  arguments: [],
                ),
                NumberExpression(numberToken(0, 1, 14)),
              ],
            ),
            arguments: [],
          ),
        ),
      ]);
    });

    // Deeply nested if expressions

    test('Triple nested if expression', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = if (true) if (false) 1 else 2 else if (true) 3 else 4',
      );
      expect(functions.length, equals(1));
      final CallExpression outerIf = functions[0].expression as CallExpression;
      expect((outerIf.callee as IdentifierExpression).value, equals('if'));
      // First argument is condition (true)
      expect(outerIf.arguments[0], isA<BooleanExpression>());
      // Second argument is nested if (the true branch)
      expect(outerIf.arguments[1], isA<CallExpression>());
      // Third argument is another nested if (the else branch)
      expect(outerIf.arguments[2], isA<CallExpression>());
    });

    // Error: incomplete map entry

    test('Error: map entry missing comma or closing brace', () {
      expect(
        () => getFunctions('test = {1: 2 3: 4}'),
        throwsA(isA<ExpectedTokenError>()),
      );
    });

    // Error: extra closing delimiter

    test('Error: list with extra closing bracket', () {
      expect(
        () => getFunctions('test = [1]]'),
        throwsA(isA<InvalidTokenError>()),
      );
    });

    // Comparison with boolean literals

    test('Comparison with boolean literal left side', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = true < false',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: [],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('<', 1, 13)),
            arguments: [
              BooleanExpression(booleanToken(true, 1, 8)),
              BooleanExpression(booleanToken(false, 1, 15)),
            ],
          ),
        ),
      ]);
    });

    // Indexing string literal

    test('Indexing on string literal with variable', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test(i) = "hello"[i]',
      );
      checkFunctions(functions, [
        FunctionDefinition(
          name: 'test',
          parameters: ['i'],
          expression: CallExpression(
            callee: IdentifierExpression(identifierToken('@', 1, 18)),
            arguments: [
              StringExpression(stringToken('hello', 1, 11)),
              IdentifierExpression(identifierToken('i', 1, 19)),
            ],
          ),
        ),
      ]);
    });

    // NumberExpression value property

    test('NumberExpression value property returns numeric value', () {
      final List<FunctionDefinition> functions = getFunctions('test = 3.14');
      final NumberExpression numberExpression =
          functions[0].expression as NumberExpression;
      expect(numberExpression.value, equals(3.14));
    });

    // BooleanExpression value property

    test('BooleanExpression value property returns boolean', () {
      final List<FunctionDefinition> functions = getFunctions('test = true');
      final BooleanExpression booleanExpression =
          functions[0].expression as BooleanExpression;
      expect(booleanExpression.value, equals(true));
    });

    test('BooleanExpression value property returns false', () {
      final List<FunctionDefinition> functions = getFunctions('test = false');
      final BooleanExpression booleanExpression =
          functions[0].expression as BooleanExpression;
      expect(booleanExpression.value, equals(false));
    });

    // StringExpression value property

    test('StringExpression value property returns string content', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = "hello world"',
      );
      final StringExpression stringExpression =
          functions[0].expression as StringExpression;
      expect(stringExpression.value, equals('hello world'));
    });

    // CallExpression callee and arguments properties

    test('CallExpression callee property returns callee expression', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = foo(1)',
      );
      final CallExpression callExpression =
          functions[0].expression as CallExpression;
      expect(callExpression.callee, isA<IdentifierExpression>());
      expect(
        (callExpression.callee as IdentifierExpression).value,
        equals('foo'),
      );
    });

    test('CallExpression arguments property returns argument list', () {
      final List<FunctionDefinition> functions = getFunctions(
        'test = foo(1, 2, 3)',
      );
      final CallExpression callExpression =
          functions[0].expression as CallExpression;
      expect(callExpression.arguments.length, equals(3));
      expect(callExpression.arguments[0], isA<NumberExpression>());
      expect(callExpression.arguments[1], isA<NumberExpression>());
      expect(callExpression.arguments[2], isA<NumberExpression>());
    });

    // FunctionDefinition properties

    test('FunctionDefinition name property returns function name', () {
      final List<FunctionDefinition> functions = getFunctions(
        'myFunction = 42',
      );
      expect(functions[0].name, equals('myFunction'));
    });

    test('FunctionDefinition parameters property returns parameter list', () {
      final List<FunctionDefinition> functions = getFunctions(
        'add(a, b, c) = a',
      );
      expect(functions[0].parameters, equals(['a', 'b', 'c']));
    });

    test('FunctionDefinition expression property returns body expression', () {
      final List<FunctionDefinition> functions = getFunctions(
        'answer = 42',
      );
      expect(functions[0].expression, isA<NumberExpression>());
      expect(
        (functions[0].expression as NumberExpression).value,
        equals(42),
      );
    });

    // Error: incomplete comparison chain

    test('Error: incomplete comparison expression', () {
      expect(
        () => getFunctions('test = 1 <'),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('Error: incomplete equality expression', () {
      expect(
        () => getFunctions('test = 1 =='),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('Error: incomplete logical or expression', () {
      expect(
        () => getFunctions('test = true |'),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('Error: incomplete logical and expression', () {
      expect(
        () => getFunctions('test = true &'),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('Error: incomplete factor expression', () {
      expect(
        () => getFunctions('test = 1 *'),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });

    test('Error: incomplete index expression', () {
      expect(
        () => getFunctions('test = list @'),
        throwsA(isA<UnexpectedEndOfFileError>()),
      );
    });
  });
}
