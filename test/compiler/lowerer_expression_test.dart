@Tags(['compiler'])
library;

import 'package:primal/compiler/lowering/lowerer.dart';
import 'package:primal/compiler/models/location.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';
import 'package:primal/compiler/semantic/semantic_function.dart';
import 'package:primal/compiler/semantic/semantic_node.dart';
import 'package:test/test.dart';

/// Test double for [FunctionTerm] since it is abstract.
class TestFunctionTerm extends FunctionTerm {
  const TestFunctionTerm({required super.name, required super.parameters});
}

/// Test double for [SemanticNode] to test the unknown type error path.
class UnknownSemanticNode extends SemanticNode {
  const UnknownSemanticNode({required super.location});
}

void main() {
  const Location defaultLocation = Location(row: 1, column: 1);

  // Create mock functions for testing identifier lowering
  final Map<String, FunctionTerm> functions = {
    'myVar': const TestFunctionTerm(name: 'myVar', parameters: []),
    'foo': const TestFunctionTerm(name: 'foo', parameters: []),
    'add': const TestFunctionTerm(
      name: 'add',
      parameters: [
        Parameter.number('a'),
        Parameter.number('b'),
      ],
    ),
    'outer': const TestFunctionTerm(
      name: 'outer',
      parameters: [Parameter.any('x')],
    ),
    'inner': const TestFunctionTerm(
      name: 'inner',
      parameters: [Parameter.any('x')],
    ),
  };
  final Lowerer lowerer = Lowerer(functions);

  group('Lowerer.lowerTerm', () {
    group('SemanticBooleanNode', () {
      test('lowers true', () {
        const SemanticBooleanNode semantic = SemanticBooleanNode(
          location: defaultLocation,
          value: true,
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<BooleanTerm>());
        expect((term as BooleanTerm).value, isTrue);
      });

      test('lowers false', () {
        const SemanticBooleanNode semantic = SemanticBooleanNode(
          location: defaultLocation,
          value: false,
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<BooleanTerm>());
        expect((term as BooleanTerm).value, isFalse);
      });
    });

    group('SemanticNumberNode', () {
      test('lowers integer', () {
        const SemanticNumberNode semantic = SemanticNumberNode(
          location: defaultLocation,
          value: 42,
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<NumberTerm>());
        expect((term as NumberTerm).value, equals(42));
      });

      test('lowers decimal', () {
        const SemanticNumberNode semantic = SemanticNumberNode(
          location: defaultLocation,
          value: 3.14,
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<NumberTerm>());
        expect((term as NumberTerm).value, equals(3.14));
      });
    });

    group('SemanticStringNode', () {
      test('lowers string', () {
        const SemanticStringNode semantic = SemanticStringNode(
          location: defaultLocation,
          value: 'hello',
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<StringTerm>());
        expect((term as StringTerm).value, equals('hello'));
      });

      test('lowers empty string', () {
        const SemanticStringNode semantic = SemanticStringNode(
          location: defaultLocation,
          value: '',
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<StringTerm>());
        expect((term as StringTerm).value, equals(''));
      });
    });

    group('SemanticIdentifierNode', () {
      test('lowers identifier to FunctionReferenceTerm', () {
        const SemanticIdentifierNode semantic = SemanticIdentifierNode(
          location: defaultLocation,
          name: 'myVar',
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<FunctionReferenceTerm>());
        expect((term as FunctionReferenceTerm).name, equals('myVar'));
      });
    });

    group('SemanticBoundVariableNode', () {
      test('lowers bound variable', () {
        const SemanticBoundVariableNode semantic = SemanticBoundVariableNode(
          location: defaultLocation,
          name: 'x',
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<BoundVariableTerm>());
        expect((term as BoundVariableTerm).name, equals('x'));
      });
    });

    group('SemanticListNode', () {
      test('lowers empty list', () {
        const SemanticListNode semantic = SemanticListNode(
          location: defaultLocation,
          value: [],
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<ListTerm>());
        expect((term as ListTerm).value, isEmpty);
      });

      test('lowers list with elements', () {
        const SemanticListNode semantic = SemanticListNode(
          location: defaultLocation,
          value: [
            SemanticNumberNode(location: defaultLocation, value: 1),
            SemanticNumberNode(location: defaultLocation, value: 2),
            SemanticNumberNode(location: defaultLocation, value: 3),
          ],
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<ListTerm>());
        final ListTerm list = term as ListTerm;
        expect(list.value.length, equals(3));
        expect((list.value[0] as NumberTerm).value, equals(1));
        expect((list.value[1] as NumberTerm).value, equals(2));
        expect((list.value[2] as NumberTerm).value, equals(3));
      });

      test('lowers nested list', () {
        const SemanticListNode semantic = SemanticListNode(
          location: defaultLocation,
          value: [
            SemanticListNode(
              location: defaultLocation,
              value: [
                SemanticNumberNode(location: defaultLocation, value: 1),
              ],
            ),
          ],
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<ListTerm>());
        final ListTerm outer = term as ListTerm;
        expect(outer.value.length, equals(1));
        expect(outer.value[0], isA<ListTerm>());
        final ListTerm inner = outer.value[0] as ListTerm;
        expect((inner.value[0] as NumberTerm).value, equals(1));
      });
    });

    group('SemanticMapNode', () {
      test('lowers empty map', () {
        const SemanticMapNode semantic = SemanticMapNode(
          location: defaultLocation,
          value: [],
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<MapTerm>());
        expect((term as MapTerm).value, isEmpty);
      });

      test('lowers map with entries', () {
        const SemanticMapNode semantic = SemanticMapNode(
          location: defaultLocation,
          value: [
            SemanticMapEntryNode(
              key: SemanticStringNode(location: defaultLocation, value: 'a'),
              value: SemanticNumberNode(location: defaultLocation, value: 1),
            ),
            SemanticMapEntryNode(
              key: SemanticStringNode(location: defaultLocation, value: 'b'),
              value: SemanticNumberNode(location: defaultLocation, value: 2),
            ),
          ],
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<MapTerm>());
        final MapTerm map = term as MapTerm;
        expect(map.value.length, equals(2));
      });
    });

    group('SemanticCallNode', () {
      test('lowers call with no arguments', () {
        const SemanticCallNode semantic = SemanticCallNode(
          location: defaultLocation,
          callee: SemanticIdentifierNode(
            location: defaultLocation,
            name: 'foo',
          ),
          arguments: [],
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<CallTerm>());
        final CallTerm call = term as CallTerm;
        expect(call.callee, isA<FunctionReferenceTerm>());
        expect((call.callee as FunctionReferenceTerm).name, equals('foo'));
        expect(call.arguments, isEmpty);
      });

      test('lowers call with arguments', () {
        const SemanticCallNode semantic = SemanticCallNode(
          location: defaultLocation,
          callee: SemanticIdentifierNode(
            location: defaultLocation,
            name: 'add',
          ),
          arguments: [
            SemanticNumberNode(location: defaultLocation, value: 1),
            SemanticNumberNode(location: defaultLocation, value: 2),
          ],
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<CallTerm>());
        final CallTerm call = term as CallTerm;
        expect(call.arguments.length, equals(2));
        expect((call.arguments[0] as NumberTerm).value, equals(1));
        expect((call.arguments[1] as NumberTerm).value, equals(2));
      });

      test('lowers nested call', () {
        const SemanticCallNode semantic = SemanticCallNode(
          location: defaultLocation,
          callee: SemanticIdentifierNode(
            location: defaultLocation,
            name: 'outer',
          ),
          arguments: [
            SemanticCallNode(
              location: defaultLocation,
              callee: SemanticIdentifierNode(
                location: defaultLocation,
                name: 'inner',
              ),
              arguments: [
                SemanticNumberNode(location: defaultLocation, value: 42),
              ],
            ),
          ],
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<CallTerm>());
        final CallTerm outer = term as CallTerm;
        expect(outer.arguments.length, equals(1));
        expect(outer.arguments[0], isA<CallTerm>());
        final CallTerm inner = outer.arguments[0] as CallTerm;
        expect((inner.callee as FunctionReferenceTerm).name, equals('inner'));
      });

      test('lowers call with bound variable as callee', () {
        const SemanticCallNode semantic = SemanticCallNode(
          location: defaultLocation,
          callee: SemanticBoundVariableNode(
            location: defaultLocation,
            name: 'f',
          ),
          arguments: [
            SemanticNumberNode(location: defaultLocation, value: 1),
          ],
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<CallTerm>());
        final CallTerm call = term as CallTerm;
        expect(call.callee, isA<BoundVariableTerm>());
        expect((call.callee as BoundVariableTerm).name, equals('f'));
      });

      test('lowers call with call as callee (higher-order)', () {
        const SemanticCallNode semantic = SemanticCallNode(
          location: defaultLocation,
          callee: SemanticCallNode(
            location: defaultLocation,
            callee: SemanticIdentifierNode(
              location: defaultLocation,
              name: 'outer',
            ),
            arguments: [
              SemanticNumberNode(location: defaultLocation, value: 1),
            ],
          ),
          arguments: [
            SemanticNumberNode(location: defaultLocation, value: 2),
          ],
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<CallTerm>());
        final CallTerm call = term as CallTerm;
        expect(call.callee, isA<CallTerm>());
        expect(call.arguments.length, equals(1));
      });
    });

    group('SemanticNumberNode edge cases', () {
      test('lowers negative number', () {
        const SemanticNumberNode semantic = SemanticNumberNode(
          location: defaultLocation,
          value: -42,
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<NumberTerm>());
        expect((term as NumberTerm).value, equals(-42));
      });

      test('lowers zero', () {
        const SemanticNumberNode semantic = SemanticNumberNode(
          location: defaultLocation,
          value: 0,
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<NumberTerm>());
        expect((term as NumberTerm).value, equals(0));
      });

      test('lowers negative decimal', () {
        const SemanticNumberNode semantic = SemanticNumberNode(
          location: defaultLocation,
          value: -3.14,
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<NumberTerm>());
        expect((term as NumberTerm).value, equals(-3.14));
      });

      test('lowers very large number', () {
        const SemanticNumberNode semantic = SemanticNumberNode(
          location: defaultLocation,
          value: 9007199254740991,
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<NumberTerm>());
        expect((term as NumberTerm).value, equals(9007199254740991));
      });
    });

    group('SemanticStringNode edge cases', () {
      test('lowers string with special characters', () {
        const SemanticStringNode semantic = SemanticStringNode(
          location: defaultLocation,
          value: 'hello\nworld\ttab',
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<StringTerm>());
        expect((term as StringTerm).value, equals('hello\nworld\ttab'));
      });

      test('lowers string with unicode', () {
        const SemanticStringNode semantic = SemanticStringNode(
          location: defaultLocation,
          value: 'Hello, 世界! 🌍',
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<StringTerm>());
        expect((term as StringTerm).value, equals('Hello, 世界! 🌍'));
      });
    });

    group('SemanticListNode edge cases', () {
      test('lowers single element list', () {
        const SemanticListNode semantic = SemanticListNode(
          location: defaultLocation,
          value: [
            SemanticNumberNode(location: defaultLocation, value: 42),
          ],
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<ListTerm>());
        final ListTerm list = term as ListTerm;
        expect(list.value.length, equals(1));
        expect((list.value[0] as NumberTerm).value, equals(42));
      });

      test('lowers list with mixed types', () {
        const SemanticListNode semantic = SemanticListNode(
          location: defaultLocation,
          value: [
            SemanticNumberNode(location: defaultLocation, value: 1),
            SemanticStringNode(location: defaultLocation, value: 'two'),
            SemanticBooleanNode(location: defaultLocation, value: true),
          ],
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<ListTerm>());
        final ListTerm list = term as ListTerm;
        expect(list.value.length, equals(3));
        expect(list.value[0], isA<NumberTerm>());
        expect(list.value[1], isA<StringTerm>());
        expect(list.value[2], isA<BooleanTerm>());
      });

      test('lowers deeply nested list', () {
        const SemanticListNode semantic = SemanticListNode(
          location: defaultLocation,
          value: [
            SemanticListNode(
              location: defaultLocation,
              value: [
                SemanticListNode(
                  location: defaultLocation,
                  value: [
                    SemanticNumberNode(location: defaultLocation, value: 42),
                  ],
                ),
              ],
            ),
          ],
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<ListTerm>());
        final ListTerm level1 = term as ListTerm;
        expect(level1.value[0], isA<ListTerm>());
        final ListTerm level2 = level1.value[0] as ListTerm;
        expect(level2.value[0], isA<ListTerm>());
        final ListTerm level3 = level2.value[0] as ListTerm;
        expect((level3.value[0] as NumberTerm).value, equals(42));
      });
    });

    group('SemanticMapNode edge cases', () {
      test('lowers single entry map', () {
        const SemanticMapNode semantic = SemanticMapNode(
          location: defaultLocation,
          value: [
            SemanticMapEntryNode(
              key: SemanticStringNode(location: defaultLocation, value: 'key'),
              value: SemanticNumberNode(location: defaultLocation, value: 42),
            ),
          ],
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<MapTerm>());
        final MapTerm map = term as MapTerm;
        expect(map.value.length, equals(1));
      });

      test('lowers map with nested map as value', () {
        const SemanticMapNode semantic = SemanticMapNode(
          location: defaultLocation,
          value: [
            SemanticMapEntryNode(
              key: SemanticStringNode(
                location: defaultLocation,
                value: 'outer',
              ),
              value: SemanticMapNode(
                location: defaultLocation,
                value: [
                  SemanticMapEntryNode(
                    key: SemanticStringNode(
                      location: defaultLocation,
                      value: 'inner',
                    ),
                    value: SemanticNumberNode(
                      location: defaultLocation,
                      value: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<MapTerm>());
        final MapTerm outerMap = term as MapTerm;
        expect(outerMap.value.length, equals(1));
        final Term innerValue = outerMap.value.values.first;
        expect(innerValue, isA<MapTerm>());
      });

      test('lowers map with number key', () {
        const SemanticMapNode semantic = SemanticMapNode(
          location: defaultLocation,
          value: [
            SemanticMapEntryNode(
              key: SemanticNumberNode(location: defaultLocation, value: 1),
              value: SemanticStringNode(
                location: defaultLocation,
                value: 'one',
              ),
            ),
          ],
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<MapTerm>());
        final MapTerm map = term as MapTerm;
        expect(map.value.length, equals(1));
        expect(map.value.keys.first, isA<NumberTerm>());
      });

      test('lowers map with boolean key', () {
        const SemanticMapNode semantic = SemanticMapNode(
          location: defaultLocation,
          value: [
            SemanticMapEntryNode(
              key: SemanticBooleanNode(location: defaultLocation, value: true),
              value: SemanticStringNode(
                location: defaultLocation,
                value: 'yes',
              ),
            ),
          ],
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<MapTerm>());
        final MapTerm map = term as MapTerm;
        expect(map.value.keys.first, isA<BooleanTerm>());
      });

      test('lowers map with list as value', () {
        const SemanticMapNode semantic = SemanticMapNode(
          location: defaultLocation,
          value: [
            SemanticMapEntryNode(
              key: SemanticStringNode(
                location: defaultLocation,
                value: 'items',
              ),
              value: SemanticListNode(
                location: defaultLocation,
                value: [
                  SemanticNumberNode(location: defaultLocation, value: 1),
                  SemanticNumberNode(location: defaultLocation, value: 2),
                ],
              ),
            ),
          ],
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<MapTerm>());
        final MapTerm map = term as MapTerm;
        expect(map.value.values.first, isA<ListTerm>());
      });
    });

    group('SemanticIdentifierNode edge cases', () {
      test('lowers identifier with functions reference', () {
        const SemanticIdentifierNode semantic = SemanticIdentifierNode(
          location: defaultLocation,
          name: 'foo',
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<FunctionReferenceTerm>());
        final FunctionReferenceTerm reference = term as FunctionReferenceTerm;
        expect(reference.name, equals('foo'));
        expect(reference.functions, same(functions));
      });
    });

    group('error cases', () {
      test('throws StateError for unknown semantic node type', () {
        const UnknownSemanticNode semantic = UnknownSemanticNode(
          location: defaultLocation,
        );

        expect(
          () => lowerer.lowerTerm(semantic),
          throwsA(
            isA<StateError>().having(
              (error) => error.message,
              'message',
              contains('Unknown semantic node type'),
            ),
          ),
        );
      });
    });
  });

  group('Lowerer.lowerFunction', () {
    test('lowers function with no parameters', () {
      const SemanticFunction function = SemanticFunction(
        name: 'constant',
        parameters: [],
        body: SemanticNumberNode(
          location: Location(row: 1, column: 1),
          value: 42,
        ),
        location: Location(row: 1, column: 1),
      );
      const Lowerer lowerer = Lowerer({});
      final CustomFunctionTerm result = lowerer.lowerFunction(function);

      expect(result.name, equals('constant'));
      expect(result.parameters, isEmpty);
      expect(result.term, isA<NumberTerm>());
      expect((result.term as NumberTerm).value, equals(42));
    });

    test('lowers function with single parameter', () {
      const SemanticFunction function = SemanticFunction(
        name: 'identity',
        parameters: [Parameter.any('x')],
        body: SemanticBoundVariableNode(
          location: Location(row: 1, column: 1),
          name: 'x',
        ),
        location: Location(row: 1, column: 1),
      );
      const Lowerer lowerer = Lowerer({});
      final CustomFunctionTerm result = lowerer.lowerFunction(function);

      expect(result.name, equals('identity'));
      expect(result.parameters.length, equals(1));
      expect(result.parameters[0].name, equals('x'));
      expect(result.term, isA<BoundVariableTerm>());
    });

    test('lowers function with multiple parameters', () {
      const SemanticFunction function = SemanticFunction(
        name: 'add',
        parameters: [Parameter.number('a'), Parameter.number('b')],
        body: SemanticCallNode(
          location: Location(row: 1, column: 1),
          callee: SemanticIdentifierNode(
            location: Location(row: 1, column: 1),
            name: 'plus',
          ),
          arguments: [
            SemanticBoundVariableNode(
              location: Location(row: 1, column: 1),
              name: 'a',
            ),
            SemanticBoundVariableNode(
              location: Location(row: 1, column: 1),
              name: 'b',
            ),
          ],
        ),
        location: Location(row: 1, column: 1),
      );
      final Map<String, FunctionTerm> functions = {
        'plus': const TestFunctionTerm(
          name: 'plus',
          parameters: [Parameter.number('a'), Parameter.number('b')],
        ),
      };
      final Lowerer lowerer = Lowerer(functions);
      final CustomFunctionTerm result = lowerer.lowerFunction(function);

      expect(result.name, equals('add'));
      expect(result.parameters.length, equals(2));
      expect(result.term, isA<CallTerm>());
    });

    test('lowers function with complex body', () {
      const SemanticFunction function = SemanticFunction(
        name: 'complex',
        parameters: [Parameter.list('items')],
        body: SemanticListNode(
          location: Location(row: 1, column: 1),
          value: [
            SemanticBoundVariableNode(
              location: Location(row: 1, column: 1),
              name: 'items',
            ),
            SemanticNumberNode(location: Location(row: 1, column: 1), value: 0),
          ],
        ),
        location: Location(row: 1, column: 1),
      );
      const Lowerer lowerer = Lowerer({});
      final CustomFunctionTerm result = lowerer.lowerFunction(function);

      expect(result.name, equals('complex'));
      expect(result.term, isA<ListTerm>());
      final ListTerm list = result.term as ListTerm;
      expect(list.value[0], isA<BoundVariableTerm>());
      expect(list.value[1], isA<NumberTerm>());
    });

    test('preserves parameter types', () {
      const SemanticFunction function = SemanticFunction(
        name: 'typed',
        parameters: [
          Parameter.string('text'),
          Parameter.number('count'),
          Parameter.boolean('flag'),
        ],
        body: SemanticBooleanNode(
          location: Location(row: 1, column: 1),
          value: true,
        ),
        location: Location(row: 1, column: 1),
      );
      const Lowerer lowerer = Lowerer({});
      final CustomFunctionTerm result = lowerer.lowerFunction(function);

      expect(result.parameters[0].name, equals('text'));
      expect(result.parameters[1].name, equals('count'));
      expect(result.parameters[2].name, equals('flag'));
    });
  });
}
