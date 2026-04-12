@Tags(['compiler'])
library;

import 'package:primal/compiler/lowering/lowerer.dart';
import 'package:primal/compiler/models/function_signature.dart';
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

      test('lowers bound variable with longer name', () {
        const SemanticBoundVariableNode semantic = SemanticBoundVariableNode(
          location: defaultLocation,
          name: 'myLongVariableName',
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<BoundVariableTerm>());
        expect((term as BoundVariableTerm).name, equals('myLongVariableName'));
      });

      test('lowers bound variable with underscore', () {
        const SemanticBoundVariableNode semantic = SemanticBoundVariableNode(
          location: defaultLocation,
          name: 'my_variable',
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<BoundVariableTerm>());
        expect((term as BoundVariableTerm).name, equals('my_variable'));
      });

      test('lowers bound variable with single character name', () {
        const SemanticBoundVariableNode semantic = SemanticBoundVariableNode(
          location: defaultLocation,
          name: 'a',
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<BoundVariableTerm>());
        expect((term as BoundVariableTerm).name, equals('a'));
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

      test('lowers list with call expression as element', () {
        const SemanticListNode semantic = SemanticListNode(
          location: defaultLocation,
          value: [
            SemanticCallNode(
              location: defaultLocation,
              callee: SemanticIdentifierNode(
                location: defaultLocation,
                name: 'foo',
              ),
              arguments: [],
            ),
          ],
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<ListTerm>());
        final ListTerm list = term as ListTerm;
        expect(list.value.length, equals(1));
        expect(list.value[0], isA<CallTerm>());
      });

      test('lowers list with bound variable as element', () {
        const SemanticListNode semantic = SemanticListNode(
          location: defaultLocation,
          value: [
            SemanticBoundVariableNode(location: defaultLocation, name: 'x'),
            SemanticBoundVariableNode(location: defaultLocation, name: 'y'),
          ],
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<ListTerm>());
        final ListTerm list = term as ListTerm;
        expect(list.value.length, equals(2));
        expect(list.value[0], isA<BoundVariableTerm>());
        expect(list.value[1], isA<BoundVariableTerm>());
      });

      test('lowers list with identifier as element', () {
        const SemanticListNode semantic = SemanticListNode(
          location: defaultLocation,
          value: [
            SemanticIdentifierNode(location: defaultLocation, name: 'foo'),
          ],
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<ListTerm>());
        final ListTerm list = term as ListTerm;
        expect(list.value[0], isA<FunctionReferenceTerm>());
      });

      test('lowers list with map as element', () {
        const SemanticListNode semantic = SemanticListNode(
          location: defaultLocation,
          value: [
            SemanticMapNode(
              location: defaultLocation,
              value: [
                SemanticMapEntryNode(
                  key: SemanticStringNode(
                    location: defaultLocation,
                    value: 'key',
                  ),
                  value: SemanticNumberNode(
                    location: defaultLocation,
                    value: 42,
                  ),
                ),
              ],
            ),
          ],
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<ListTerm>());
        final ListTerm list = term as ListTerm;
        expect(list.value.length, equals(1));
        expect(list.value[0], isA<MapTerm>());
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

      test('lowers map with list as key', () {
        const SemanticMapNode semantic = SemanticMapNode(
          location: defaultLocation,
          value: [
            SemanticMapEntryNode(
              key: SemanticListNode(
                location: defaultLocation,
                value: [
                  SemanticNumberNode(location: defaultLocation, value: 1),
                ],
              ),
              value: SemanticStringNode(
                location: defaultLocation,
                value: 'value',
              ),
            ),
          ],
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<MapTerm>());
        final MapTerm map = term as MapTerm;
        expect(map.value.keys.first, isA<ListTerm>());
      });

      test('lowers map with call expression as value', () {
        const SemanticMapNode semantic = SemanticMapNode(
          location: defaultLocation,
          value: [
            SemanticMapEntryNode(
              key: SemanticStringNode(location: defaultLocation, value: 'key'),
              value: SemanticCallNode(
                location: defaultLocation,
                callee: SemanticIdentifierNode(
                  location: defaultLocation,
                  name: 'foo',
                ),
                arguments: [],
              ),
            ),
          ],
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<MapTerm>());
        final MapTerm map = term as MapTerm;
        expect(map.value.values.first, isA<CallTerm>());
      });

      test('lowers map with call expression as key', () {
        const SemanticMapNode semantic = SemanticMapNode(
          location: defaultLocation,
          value: [
            SemanticMapEntryNode(
              key: SemanticCallNode(
                location: defaultLocation,
                callee: SemanticIdentifierNode(
                  location: defaultLocation,
                  name: 'foo',
                ),
                arguments: [],
              ),
              value: SemanticStringNode(
                location: defaultLocation,
                value: 'value',
              ),
            ),
          ],
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<MapTerm>());
        final MapTerm map = term as MapTerm;
        expect(map.value.keys.first, isA<CallTerm>());
      });

      test('lowers map with bound variable as key', () {
        const SemanticMapNode semantic = SemanticMapNode(
          location: defaultLocation,
          value: [
            SemanticMapEntryNode(
              key: SemanticBoundVariableNode(
                location: defaultLocation,
                name: 'x',
              ),
              value: SemanticNumberNode(location: defaultLocation, value: 42),
            ),
          ],
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<MapTerm>());
        final MapTerm map = term as MapTerm;
        expect(map.value.keys.first, isA<BoundVariableTerm>());
      });

      test('lowers map with identifier as key', () {
        const SemanticMapNode semantic = SemanticMapNode(
          location: defaultLocation,
          value: [
            SemanticMapEntryNode(
              key: SemanticIdentifierNode(
                location: defaultLocation,
                name: 'foo',
              ),
              value: SemanticNumberNode(location: defaultLocation, value: 42),
            ),
          ],
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<MapTerm>());
        final MapTerm map = term as MapTerm;
        expect(map.value.keys.first, isA<FunctionReferenceTerm>());
      });

      test('lowers map with multiple entries preserves all entries', () {
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
            SemanticMapEntryNode(
              key: SemanticStringNode(location: defaultLocation, value: 'c'),
              value: SemanticNumberNode(location: defaultLocation, value: 3),
            ),
          ],
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<MapTerm>());
        final MapTerm map = term as MapTerm;
        expect(map.value.length, equals(3));
      });

      test('lowers map with map as key', () {
        const SemanticMapNode semantic = SemanticMapNode(
          location: defaultLocation,
          value: [
            SemanticMapEntryNode(
              key: SemanticMapNode(
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
              value: SemanticStringNode(
                location: defaultLocation,
                value: 'outer_value',
              ),
            ),
          ],
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<MapTerm>());
        final MapTerm map = term as MapTerm;
        expect(map.value.length, equals(1));
        expect(map.value.keys.first, isA<MapTerm>());
      });

      test('lowers map with bound variable as value', () {
        const SemanticMapNode semantic = SemanticMapNode(
          location: defaultLocation,
          value: [
            SemanticMapEntryNode(
              key: SemanticStringNode(location: defaultLocation, value: 'key'),
              value: SemanticBoundVariableNode(
                location: defaultLocation,
                name: 'x',
              ),
            ),
          ],
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<MapTerm>());
        final MapTerm map = term as MapTerm;
        expect(map.value.values.first, isA<BoundVariableTerm>());
      });

      test('lowers map with identifier as value', () {
        const SemanticMapNode semantic = SemanticMapNode(
          location: defaultLocation,
          value: [
            SemanticMapEntryNode(
              key: SemanticStringNode(location: defaultLocation, value: 'key'),
              value: SemanticIdentifierNode(
                location: defaultLocation,
                name: 'foo',
              ),
            ),
          ],
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<MapTerm>());
        final MapTerm map = term as MapTerm;
        expect(map.value.values.first, isA<FunctionReferenceTerm>());
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

      test(
        'lowers identifier with resolvedSignature (signature ignored in lowering)',
        () {
          const SemanticIdentifierNode semantic = SemanticIdentifierNode(
            location: defaultLocation,
            name: 'add',
            resolvedSignature: FunctionSignature(
              name: 'add',
              parameters: [Parameter.number('a'), Parameter.number('b')],
            ),
          );
          final Term term = lowerer.lowerTerm(semantic);

          expect(term, isA<FunctionReferenceTerm>());
          final FunctionReferenceTerm reference = term as FunctionReferenceTerm;
          expect(reference.name, equals('add'));
        },
      );

      test('lowers identifier not in functions map', () {
        const SemanticIdentifierNode semantic = SemanticIdentifierNode(
          location: defaultLocation,
          name: 'unknownFunction',
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<FunctionReferenceTerm>());
        expect((term as FunctionReferenceTerm).name, equals('unknownFunction'));
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

    test('lowers function with map body', () {
      const SemanticFunction function = SemanticFunction(
        name: 'makeMap',
        parameters: [Parameter.any('key'), Parameter.any('value')],
        body: SemanticMapNode(
          location: Location(row: 1, column: 1),
          value: [
            SemanticMapEntryNode(
              key: SemanticBoundVariableNode(
                location: Location(row: 1, column: 1),
                name: 'key',
              ),
              value: SemanticBoundVariableNode(
                location: Location(row: 1, column: 1),
                name: 'value',
              ),
            ),
          ],
        ),
        location: Location(row: 1, column: 1),
      );
      const Lowerer lowerer = Lowerer({});
      final CustomFunctionTerm result = lowerer.lowerFunction(function);

      expect(result.term, isA<MapTerm>());
      final MapTerm map = result.term as MapTerm;
      expect(map.value.keys.first, isA<BoundVariableTerm>());
      expect(map.value.values.first, isA<BoundVariableTerm>());
    });

    test('lowers function with nested call body', () {
      final Map<String, FunctionTerm> functions = {
        'outer': const TestFunctionTerm(
          name: 'outer',
          parameters: [Parameter.any('x')],
        ),
        'inner': const TestFunctionTerm(
          name: 'inner',
          parameters: [Parameter.any('x')],
        ),
      };
      const SemanticFunction function = SemanticFunction(
        name: 'nested',
        parameters: [Parameter.any('x')],
        body: SemanticCallNode(
          location: Location(row: 1, column: 1),
          callee: SemanticIdentifierNode(
            location: Location(row: 1, column: 1),
            name: 'outer',
          ),
          arguments: [
            SemanticCallNode(
              location: Location(row: 1, column: 1),
              callee: SemanticIdentifierNode(
                location: Location(row: 1, column: 1),
                name: 'inner',
              ),
              arguments: [
                SemanticBoundVariableNode(
                  location: Location(row: 1, column: 1),
                  name: 'x',
                ),
              ],
            ),
          ],
        ),
        location: Location(row: 1, column: 1),
      );
      final Lowerer lowerer = Lowerer(functions);
      final CustomFunctionTerm result = lowerer.lowerFunction(function);

      expect(result.term, isA<CallTerm>());
      final CallTerm outerCall = result.term as CallTerm;
      expect(outerCall.arguments[0], isA<CallTerm>());
    });

    test('lowers function with string body', () {
      const SemanticFunction function = SemanticFunction(
        name: 'greeting',
        parameters: [],
        body: SemanticStringNode(
          location: Location(row: 1, column: 1),
          value: 'Hello, World!',
        ),
        location: Location(row: 1, column: 1),
      );
      const Lowerer lowerer = Lowerer({});
      final CustomFunctionTerm result = lowerer.lowerFunction(function);

      expect(result.term, isA<StringTerm>());
      expect((result.term as StringTerm).value, equals('Hello, World!'));
    });

    test('lowers function with boolean body', () {
      const SemanticFunction function = SemanticFunction(
        name: 'alwaysTrue',
        parameters: [],
        body: SemanticBooleanNode(
          location: Location(row: 1, column: 1),
          value: true,
        ),
        location: Location(row: 1, column: 1),
      );
      const Lowerer lowerer = Lowerer({});
      final CustomFunctionTerm result = lowerer.lowerFunction(function);

      expect(result.term, isA<BooleanTerm>());
      expect((result.term as BooleanTerm).value, isTrue);
    });

    test(
      'lowers function with identifier body (returns function reference)',
      () {
        final Map<String, FunctionTerm> functions = {
          'target': const TestFunctionTerm(name: 'target', parameters: []),
        };
        const SemanticFunction function = SemanticFunction(
          name: 'alias',
          parameters: [],
          body: SemanticIdentifierNode(
            location: Location(row: 1, column: 1),
            name: 'target',
          ),
          location: Location(row: 1, column: 1),
        );
        final Lowerer lowerer = Lowerer(functions);
        final CustomFunctionTerm result = lowerer.lowerFunction(function);

        expect(result.term, isA<FunctionReferenceTerm>());
        expect((result.term as FunctionReferenceTerm).name, equals('target'));
      },
    );
  });

  group('Lowerer constructor', () {
    test('accepts empty functions map', () {
      const Lowerer lowerer = Lowerer({});
      const SemanticNumberNode semantic = SemanticNumberNode(
        location: Location(row: 1, column: 1),
        value: 42,
      );
      final Term term = lowerer.lowerTerm(semantic);

      expect(term, isA<NumberTerm>());
    });

    test(
      'lowerer with functions map passes functions to FunctionReferenceTerm',
      () {
        final Map<String, FunctionTerm> functions = {
          'test': const TestFunctionTerm(name: 'test', parameters: []),
        };
        final Lowerer lowerer = Lowerer(functions);
        const SemanticIdentifierNode semantic = SemanticIdentifierNode(
          location: Location(row: 1, column: 1),
          name: 'test',
        );
        final Term term = lowerer.lowerTerm(semantic);

        expect(term, isA<FunctionReferenceTerm>());
        final FunctionReferenceTerm reference = term as FunctionReferenceTerm;
        expect(reference.functions, same(functions));
      },
    );
  });

  group('SemanticCallNode additional edge cases', () {
    const Location defaultLocation = Location(row: 1, column: 1);

    test('lowers call with list as argument', () {
      final Map<String, FunctionTerm> functions = {
        'process': const TestFunctionTerm(
          name: 'process',
          parameters: [Parameter.list('items')],
        ),
      };
      const SemanticCallNode semantic = SemanticCallNode(
        location: defaultLocation,
        callee: SemanticIdentifierNode(
          location: defaultLocation,
          name: 'process',
        ),
        arguments: [
          SemanticListNode(
            location: defaultLocation,
            value: [
              SemanticNumberNode(location: defaultLocation, value: 1),
              SemanticNumberNode(location: defaultLocation, value: 2),
            ],
          ),
        ],
      );
      final Lowerer lowerer = Lowerer(functions);
      final Term term = lowerer.lowerTerm(semantic);

      expect(term, isA<CallTerm>());
      final CallTerm call = term as CallTerm;
      expect(call.arguments[0], isA<ListTerm>());
    });

    test('lowers call with map as argument', () {
      final Map<String, FunctionTerm> functions = {
        'process': const TestFunctionTerm(
          name: 'process',
          parameters: [Parameter.map('data')],
        ),
      };
      const SemanticCallNode semantic = SemanticCallNode(
        location: defaultLocation,
        callee: SemanticIdentifierNode(
          location: defaultLocation,
          name: 'process',
        ),
        arguments: [
          SemanticMapNode(
            location: defaultLocation,
            value: [
              SemanticMapEntryNode(
                key: SemanticStringNode(
                  location: defaultLocation,
                  value: 'key',
                ),
                value: SemanticNumberNode(location: defaultLocation, value: 42),
              ),
            ],
          ),
        ],
      );
      final Lowerer lowerer = Lowerer(functions);
      final Term term = lowerer.lowerTerm(semantic);

      expect(term, isA<CallTerm>());
      final CallTerm call = term as CallTerm;
      expect(call.arguments[0], isA<MapTerm>());
    });

    test('lowers deeply nested calls', () {
      final Map<String, FunctionTerm> functions = {
        'f': const TestFunctionTerm(
          name: 'f',
          parameters: [Parameter.any('x')],
        ),
      };
      const SemanticCallNode semantic = SemanticCallNode(
        location: defaultLocation,
        callee: SemanticIdentifierNode(location: defaultLocation, name: 'f'),
        arguments: [
          SemanticCallNode(
            location: defaultLocation,
            callee: SemanticIdentifierNode(
              location: defaultLocation,
              name: 'f',
            ),
            arguments: [
              SemanticCallNode(
                location: defaultLocation,
                callee: SemanticIdentifierNode(
                  location: defaultLocation,
                  name: 'f',
                ),
                arguments: [
                  SemanticNumberNode(location: defaultLocation, value: 1),
                ],
              ),
            ],
          ),
        ],
      );
      final Lowerer lowerer = Lowerer(functions);
      final Term term = lowerer.lowerTerm(semantic);

      expect(term, isA<CallTerm>());
      final CallTerm call1 = term as CallTerm;
      expect(call1.arguments[0], isA<CallTerm>());
      final CallTerm call2 = call1.arguments[0] as CallTerm;
      expect(call2.arguments[0], isA<CallTerm>());
    });

    test('lowers call with multiple mixed argument types', () {
      final Map<String, FunctionTerm> functions = {
        'mixed': const TestFunctionTerm(
          name: 'mixed',
          parameters: [
            Parameter.number('n'),
            Parameter.string('s'),
            Parameter.boolean('b'),
            Parameter.list('l'),
          ],
        ),
      };
      const SemanticCallNode semantic = SemanticCallNode(
        location: defaultLocation,
        callee: SemanticIdentifierNode(
          location: defaultLocation,
          name: 'mixed',
        ),
        arguments: [
          SemanticNumberNode(location: defaultLocation, value: 42),
          SemanticStringNode(location: defaultLocation, value: 'hello'),
          SemanticBooleanNode(location: defaultLocation, value: true),
          SemanticListNode(location: defaultLocation, value: []),
        ],
      );
      final Lowerer lowerer = Lowerer(functions);
      final Term term = lowerer.lowerTerm(semantic);

      expect(term, isA<CallTerm>());
      final CallTerm call = term as CallTerm;
      expect(call.arguments.length, equals(4));
      expect(call.arguments[0], isA<NumberTerm>());
      expect(call.arguments[1], isA<StringTerm>());
      expect(call.arguments[2], isA<BooleanTerm>());
      expect(call.arguments[3], isA<ListTerm>());
    });

    test('lowers call with identifier as argument (function reference)', () {
      final Map<String, FunctionTerm> functions = {
        'higherOrder': const TestFunctionTerm(
          name: 'higherOrder',
          parameters: [Parameter.function('f')],
        ),
        'callback': const TestFunctionTerm(
          name: 'callback',
          parameters: [],
        ),
      };
      const SemanticCallNode semantic = SemanticCallNode(
        location: defaultLocation,
        callee: SemanticIdentifierNode(
          location: defaultLocation,
          name: 'higherOrder',
        ),
        arguments: [
          SemanticIdentifierNode(location: defaultLocation, name: 'callback'),
        ],
      );
      final Lowerer lowerer = Lowerer(functions);
      final Term term = lowerer.lowerTerm(semantic);

      expect(term, isA<CallTerm>());
      final CallTerm call = term as CallTerm;
      expect(call.arguments[0], isA<FunctionReferenceTerm>());
    });

    test('lowers call with bound variable as argument', () {
      final Map<String, FunctionTerm> functions = {
        'identity': const TestFunctionTerm(
          name: 'identity',
          parameters: [Parameter.any('x')],
        ),
      };
      const SemanticCallNode semantic = SemanticCallNode(
        location: defaultLocation,
        callee: SemanticIdentifierNode(
          location: defaultLocation,
          name: 'identity',
        ),
        arguments: [
          SemanticBoundVariableNode(location: defaultLocation, name: 'y'),
        ],
      );
      final Lowerer lowerer = Lowerer(functions);
      final Term term = lowerer.lowerTerm(semantic);

      expect(term, isA<CallTerm>());
      final CallTerm call = term as CallTerm;
      expect(call.arguments.length, equals(1));
      expect(call.arguments[0], isA<BoundVariableTerm>());
      expect((call.arguments[0] as BoundVariableTerm).name, equals('y'));
    });

    test('lowers call with string argument', () {
      final Map<String, FunctionTerm> functions = {
        'print': const TestFunctionTerm(
          name: 'print',
          parameters: [Parameter.string('message')],
        ),
      };
      const SemanticCallNode semantic = SemanticCallNode(
        location: defaultLocation,
        callee: SemanticIdentifierNode(
          location: defaultLocation,
          name: 'print',
        ),
        arguments: [
          SemanticStringNode(location: defaultLocation, value: 'hello'),
        ],
      );
      final Lowerer lowerer = Lowerer(functions);
      final Term term = lowerer.lowerTerm(semantic);

      expect(term, isA<CallTerm>());
      final CallTerm call = term as CallTerm;
      expect(call.arguments[0], isA<StringTerm>());
      expect((call.arguments[0] as StringTerm).value, equals('hello'));
    });

    test('lowers call with boolean argument', () {
      final Map<String, FunctionTerm> functions = {
        'not': const TestFunctionTerm(
          name: 'not',
          parameters: [Parameter.boolean('value')],
        ),
      };
      const SemanticCallNode semantic = SemanticCallNode(
        location: defaultLocation,
        callee: SemanticIdentifierNode(location: defaultLocation, name: 'not'),
        arguments: [
          SemanticBooleanNode(location: defaultLocation, value: true),
        ],
      );
      final Lowerer lowerer = Lowerer(functions);
      final Term term = lowerer.lowerTerm(semantic);

      expect(term, isA<CallTerm>());
      final CallTerm call = term as CallTerm;
      expect(call.arguments[0], isA<BooleanTerm>());
      expect((call.arguments[0] as BooleanTerm).value, isTrue);
    });

    test('lowers call where callee is lambda-like call', () {
      final Map<String, FunctionTerm> functions = {
        'makeAdder': const TestFunctionTerm(
          name: 'makeAdder',
          parameters: [Parameter.number('n')],
        ),
      };
      const SemanticCallNode semantic = SemanticCallNode(
        location: defaultLocation,
        callee: SemanticCallNode(
          location: defaultLocation,
          callee: SemanticIdentifierNode(
            location: defaultLocation,
            name: 'makeAdder',
          ),
          arguments: [
            SemanticNumberNode(location: defaultLocation, value: 5),
          ],
        ),
        arguments: [
          SemanticNumberNode(location: defaultLocation, value: 10),
        ],
      );
      final Lowerer lowerer = Lowerer(functions);
      final Term term = lowerer.lowerTerm(semantic);

      expect(term, isA<CallTerm>());
      final CallTerm outerCall = term as CallTerm;
      expect(outerCall.callee, isA<CallTerm>());
      final CallTerm innerCall = outerCall.callee as CallTerm;
      expect(innerCall.callee, isA<FunctionReferenceTerm>());
      expect(
        (innerCall.callee as FunctionReferenceTerm).name,
        equals('makeAdder'),
      );
      expect(outerCall.arguments.length, equals(1));
      expect((outerCall.arguments[0] as NumberTerm).value, equals(10));
    });
  });

  group('Lowerer const constructor', () {
    test('can be used as const', () {
      const Lowerer lowerer = Lowerer({});
      expect(lowerer.functions, isEmpty);
    });

    test('const lowerers with same empty map are identical', () {
      const Lowerer lowerer1 = Lowerer({});
      const Lowerer lowerer2 = Lowerer({});
      expect(identical(lowerer1, lowerer2), isTrue);
    });
  });

  group('Lowerer.lowerFunction edge cases', () {
    test('lowers function where body references parameter multiple times', () {
      const SemanticFunction function = SemanticFunction(
        name: 'duplicate',
        parameters: [Parameter.any('x')],
        body: SemanticListNode(
          location: Location(row: 1, column: 1),
          value: [
            SemanticBoundVariableNode(
              location: Location(row: 1, column: 1),
              name: 'x',
            ),
            SemanticBoundVariableNode(
              location: Location(row: 1, column: 1),
              name: 'x',
            ),
          ],
        ),
        location: Location(row: 1, column: 1),
      );
      const Lowerer lowerer = Lowerer({});
      final CustomFunctionTerm result = lowerer.lowerFunction(function);

      expect(result.term, isA<ListTerm>());
      final ListTerm list = result.term as ListTerm;
      expect(list.value.length, equals(2));
      expect(list.value[0], isA<BoundVariableTerm>());
      expect(list.value[1], isA<BoundVariableTerm>());
      expect((list.value[0] as BoundVariableTerm).name, equals('x'));
      expect((list.value[1] as BoundVariableTerm).name, equals('x'));
    });

    test('lowers function with deeply nested call in body', () {
      final Map<String, FunctionTerm> functions = {
        'f': const TestFunctionTerm(
          name: 'f',
          parameters: [Parameter.any('x')],
        ),
      };
      const SemanticFunction function = SemanticFunction(
        name: 'nested',
        parameters: [Parameter.any('x')],
        body: SemanticCallNode(
          location: Location(row: 1, column: 1),
          callee: SemanticIdentifierNode(
            location: Location(row: 1, column: 1),
            name: 'f',
          ),
          arguments: [
            SemanticCallNode(
              location: Location(row: 1, column: 1),
              callee: SemanticIdentifierNode(
                location: Location(row: 1, column: 1),
                name: 'f',
              ),
              arguments: [
                SemanticCallNode(
                  location: Location(row: 1, column: 1),
                  callee: SemanticIdentifierNode(
                    location: Location(row: 1, column: 1),
                    name: 'f',
                  ),
                  arguments: [
                    SemanticBoundVariableNode(
                      location: Location(row: 1, column: 1),
                      name: 'x',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        location: Location(row: 1, column: 1),
      );
      final Lowerer lowerer = Lowerer(functions);
      final CustomFunctionTerm result = lowerer.lowerFunction(function);

      expect(result.term, isA<CallTerm>());
      final CallTerm call1 = result.term as CallTerm;
      expect(call1.arguments[0], isA<CallTerm>());
      final CallTerm call2 = call1.arguments[0] as CallTerm;
      expect(call2.arguments[0], isA<CallTerm>());
      final CallTerm call3 = call2.arguments[0] as CallTerm;
      expect(call3.arguments[0], isA<BoundVariableTerm>());
    });

    test('lowers function with empty list body', () {
      const SemanticFunction function = SemanticFunction(
        name: 'emptyList',
        parameters: [],
        body: SemanticListNode(
          location: Location(row: 1, column: 1),
          value: [],
        ),
        location: Location(row: 1, column: 1),
      );
      const Lowerer lowerer = Lowerer({});
      final CustomFunctionTerm result = lowerer.lowerFunction(function);

      expect(result.term, isA<ListTerm>());
      expect((result.term as ListTerm).value, isEmpty);
    });

    test('lowers function with empty map body', () {
      const SemanticFunction function = SemanticFunction(
        name: 'emptyMap',
        parameters: [],
        body: SemanticMapNode(
          location: Location(row: 1, column: 1),
          value: [],
        ),
        location: Location(row: 1, column: 1),
      );
      const Lowerer lowerer = Lowerer({});
      final CustomFunctionTerm result = lowerer.lowerFunction(function);

      expect(result.term, isA<MapTerm>());
      expect((result.term as MapTerm).value, isEmpty);
    });

    test('lowers function with call as body that has no arguments', () {
      final Map<String, FunctionTerm> functions = {
        'getValue': const TestFunctionTerm(name: 'getValue', parameters: []),
      };
      const SemanticFunction function = SemanticFunction(
        name: 'wrapper',
        parameters: [],
        body: SemanticCallNode(
          location: Location(row: 1, column: 1),
          callee: SemanticIdentifierNode(
            location: Location(row: 1, column: 1),
            name: 'getValue',
          ),
          arguments: [],
        ),
        location: Location(row: 1, column: 1),
      );
      final Lowerer lowerer = Lowerer(functions);
      final CustomFunctionTerm result = lowerer.lowerFunction(function);

      expect(result.term, isA<CallTerm>());
      final CallTerm call = result.term as CallTerm;
      expect(call.arguments, isEmpty);
    });

    test('lowers function that returns another function reference', () {
      final Map<String, FunctionTerm> functions = {
        'otherFunction': const TestFunctionTerm(
          name: 'otherFunction',
          parameters: [],
        ),
      };
      const SemanticFunction function = SemanticFunction(
        name: 'getFn',
        parameters: [],
        body: SemanticIdentifierNode(
          location: Location(row: 1, column: 1),
          name: 'otherFunction',
        ),
        location: Location(row: 1, column: 1),
      );
      final Lowerer lowerer = Lowerer(functions);
      final CustomFunctionTerm result = lowerer.lowerFunction(function);

      expect(result.term, isA<FunctionReferenceTerm>());
      expect((result.term as FunctionReferenceTerm).name, 'otherFunction');
    });
  });

  // --- Let expression lowering tests ---

  group('SemanticLetNode', () {
    const Location defaultLocation = Location(row: 1, column: 1);

    test('lowers single binding let to LetTerm', () {
      const SemanticLetNode semantic = SemanticLetNode(
        location: defaultLocation,
        bindings: [
          SemanticLetBindingNode(
            name: 'x',
            value: SemanticNumberNode(location: defaultLocation, value: 1),
            location: defaultLocation,
          ),
        ],
        body: SemanticBoundVariableNode(
          location: defaultLocation,
          name: 'x',
          isLetBinding: true,
        ),
      );
      const Lowerer lowerer = Lowerer({});
      final Term term = lowerer.lowerTerm(semantic);

      expect(term, isA<LetTerm>());
      final LetTerm letTerm = term as LetTerm;
      expect(letTerm.bindings.length, equals(1));
      expect(letTerm.bindings[0].$1, equals('x'));
      expect(letTerm.bindings[0].$2, isA<NumberTerm>());
      expect(letTerm.body, isA<LetBoundVariableTerm>());
    });

    test('lowers multiple binding let to LetTerm', () {
      const SemanticLetNode semantic = SemanticLetNode(
        location: defaultLocation,
        bindings: [
          SemanticLetBindingNode(
            name: 'x',
            value: SemanticNumberNode(location: defaultLocation, value: 1),
            location: defaultLocation,
          ),
          SemanticLetBindingNode(
            name: 'y',
            value: SemanticNumberNode(location: defaultLocation, value: 2),
            location: defaultLocation,
          ),
        ],
        body: SemanticBoundVariableNode(
          location: defaultLocation,
          name: 'y',
          isLetBinding: true,
        ),
      );
      const Lowerer lowerer = Lowerer({});
      final Term term = lowerer.lowerTerm(semantic);

      expect(term, isA<LetTerm>());
      final LetTerm letTerm = term as LetTerm;
      expect(letTerm.bindings.length, equals(2));
      expect(letTerm.bindings[0].$1, equals('x'));
      expect(letTerm.bindings[1].$1, equals('y'));
    });

    test('lowers nested let in body', () {
      const SemanticLetNode semantic = SemanticLetNode(
        location: defaultLocation,
        bindings: [
          SemanticLetBindingNode(
            name: 'x',
            value: SemanticNumberNode(location: defaultLocation, value: 1),
            location: defaultLocation,
          ),
        ],
        body: SemanticLetNode(
          location: defaultLocation,
          bindings: [
            SemanticLetBindingNode(
              name: 'y',
              value: SemanticNumberNode(location: defaultLocation, value: 2),
              location: defaultLocation,
            ),
          ],
          body: SemanticBoundVariableNode(
            location: defaultLocation,
            name: 'y',
            isLetBinding: true,
          ),
        ),
      );
      const Lowerer lowerer = Lowerer({});
      final Term term = lowerer.lowerTerm(semantic);

      expect(term, isA<LetTerm>());
      final LetTerm outerLet = term as LetTerm;
      expect(outerLet.body, isA<LetTerm>());
      final LetTerm innerLet = outerLet.body as LetTerm;
      expect(innerLet.bindings[0].$1, equals('y'));
    });

    test('lowers nested let in binding value', () {
      const SemanticLetNode semantic = SemanticLetNode(
        location: defaultLocation,
        bindings: [
          SemanticLetBindingNode(
            name: 'x',
            value: SemanticLetNode(
              location: defaultLocation,
              bindings: [
                SemanticLetBindingNode(
                  name: 'y',
                  value: SemanticNumberNode(
                    location: defaultLocation,
                    value: 1,
                  ),
                  location: defaultLocation,
                ),
              ],
              body: SemanticBoundVariableNode(
                location: defaultLocation,
                name: 'y',
                isLetBinding: true,
              ),
            ),
            location: defaultLocation,
          ),
        ],
        body: SemanticBoundVariableNode(
          location: defaultLocation,
          name: 'x',
          isLetBinding: true,
        ),
      );
      const Lowerer lowerer = Lowerer({});
      final Term term = lowerer.lowerTerm(semantic);

      expect(term, isA<LetTerm>());
      final LetTerm letTerm = term as LetTerm;
      expect(letTerm.bindings[0].$2, isA<LetTerm>());
    });

    test('lowers let with call in binding value', () {
      final Map<String, FunctionTerm> functions = {
        'foo': const TestFunctionTerm(name: 'foo', parameters: []),
      };
      const SemanticLetNode semantic = SemanticLetNode(
        location: defaultLocation,
        bindings: [
          SemanticLetBindingNode(
            name: 'x',
            value: SemanticCallNode(
              location: defaultLocation,
              callee: SemanticIdentifierNode(
                location: defaultLocation,
                name: 'foo',
              ),
              arguments: [],
            ),
            location: defaultLocation,
          ),
        ],
        body: SemanticBoundVariableNode(
          location: defaultLocation,
          name: 'x',
          isLetBinding: true,
        ),
      );
      final Lowerer lowerer = Lowerer(functions);
      final Term term = lowerer.lowerTerm(semantic);

      expect(term, isA<LetTerm>());
      final LetTerm letTerm = term as LetTerm;
      expect(letTerm.bindings[0].$2, isA<CallTerm>());
    });

    test('lowers let with call in body', () {
      final Map<String, FunctionTerm> functions = {
        'foo': const TestFunctionTerm(
          name: 'foo',
          parameters: [Parameter.any('x')],
        ),
      };
      const SemanticLetNode semantic = SemanticLetNode(
        location: defaultLocation,
        bindings: [
          SemanticLetBindingNode(
            name: 'x',
            value: SemanticNumberNode(location: defaultLocation, value: 1),
            location: defaultLocation,
          ),
        ],
        body: SemanticCallNode(
          location: defaultLocation,
          callee: SemanticIdentifierNode(
            location: defaultLocation,
            name: 'foo',
          ),
          arguments: [
            SemanticBoundVariableNode(
              location: defaultLocation,
              name: 'x',
              isLetBinding: true,
            ),
          ],
        ),
      );
      final Lowerer lowerer = Lowerer(functions);
      final Term term = lowerer.lowerTerm(semantic);

      expect(term, isA<LetTerm>());
      final LetTerm letTerm = term as LetTerm;
      expect(letTerm.body, isA<CallTerm>());
      final CallTerm callTerm = letTerm.body as CallTerm;
      expect(callTerm.arguments[0], isA<LetBoundVariableTerm>());
    });
  });

  group('SemanticBoundVariableNode with isLetBinding', () {
    const Location defaultLocation = Location(row: 1, column: 1);

    test('isLetBinding true produces LetBoundVariableTerm', () {
      const SemanticBoundVariableNode semantic = SemanticBoundVariableNode(
        location: defaultLocation,
        name: 'x',
        isLetBinding: true,
      );
      const Lowerer lowerer = Lowerer({});
      final Term term = lowerer.lowerTerm(semantic);

      expect(term, isA<LetBoundVariableTerm>());
      expect((term as LetBoundVariableTerm).name, equals('x'));
    });

    test('isLetBinding false produces BoundVariableTerm', () {
      const SemanticBoundVariableNode semantic = SemanticBoundVariableNode(
        location: defaultLocation,
        name: 'x',
        isLetBinding: false,
      );
      const Lowerer lowerer = Lowerer({});
      final Term term = lowerer.lowerTerm(semantic);

      expect(term, isA<BoundVariableTerm>());
      expect((term as BoundVariableTerm).name, equals('x'));
    });

    test('default isLetBinding produces BoundVariableTerm', () {
      const SemanticBoundVariableNode semantic = SemanticBoundVariableNode(
        location: defaultLocation,
        name: 'x',
      );
      const Lowerer lowerer = Lowerer({});
      final Term term = lowerer.lowerTerm(semantic);

      expect(term, isA<BoundVariableTerm>());
    });
  });

  group('Mixed parameter and let binding lowering', () {
    const Location defaultLocation = Location(row: 1, column: 1);

    test('let with parameter reference produces both term types', () {
      // Represents: f(n) = let x = 1 in x + n
      // Body is a call with two different variable types
      final Map<String, FunctionTerm> functions = {
        'add': const TestFunctionTerm(
          name: 'add',
          parameters: [Parameter.any('a'), Parameter.any('b')],
        ),
      };
      const SemanticLetNode semantic = SemanticLetNode(
        location: defaultLocation,
        bindings: [
          SemanticLetBindingNode(
            name: 'x',
            value: SemanticNumberNode(location: defaultLocation, value: 1),
            location: defaultLocation,
          ),
        ],
        body: SemanticCallNode(
          location: defaultLocation,
          callee: SemanticIdentifierNode(
            location: defaultLocation,
            name: 'add',
          ),
          arguments: [
            SemanticBoundVariableNode(
              location: defaultLocation,
              name: 'x',
              isLetBinding: true,
            ),
            SemanticBoundVariableNode(
              location: defaultLocation,
              name: 'n',
              isLetBinding: false,
            ),
          ],
        ),
      );
      final Lowerer lowerer = Lowerer(functions);
      final Term term = lowerer.lowerTerm(semantic);

      expect(term, isA<LetTerm>());
      final LetTerm letTerm = term as LetTerm;
      final CallTerm callTerm = letTerm.body as CallTerm;
      expect(callTerm.arguments[0], isA<LetBoundVariableTerm>());
      expect(callTerm.arguments[1], isA<BoundVariableTerm>());
    });
  });

  group('SemanticLambdaNode', () {
    const Location defaultLocation = Location(row: 1, column: 1);

    test('lowers lambda with single parameter to LambdaTerm', () {
      const SemanticLambdaNode semantic = SemanticLambdaNode(
        location: defaultLocation,
        parameters: ['x'],
        body: SemanticBoundVariableNode(
          location: defaultLocation,
          name: 'x',
          isLambdaParameter: true,
        ),
      );
      const Lowerer lowerer = Lowerer({});
      final Term term = lowerer.lowerTerm(semantic);

      expect(term, isA<LambdaTerm>());
      final LambdaTerm lambdaTerm = term as LambdaTerm;
      expect(lambdaTerm.parameters.length, equals(1));
      expect(lambdaTerm.parameters[0].name, equals('x'));
      expect(lambdaTerm.body, isA<LambdaBoundVariableTerm>());
    });

    test('lowers zero-param lambda to LambdaTerm', () {
      const SemanticLambdaNode semantic = SemanticLambdaNode(
        location: defaultLocation,
        parameters: [],
        body: SemanticNumberNode(location: defaultLocation, value: 42),
      );
      const Lowerer lowerer = Lowerer({});
      final Term term = lowerer.lowerTerm(semantic);

      expect(term, isA<LambdaTerm>());
      final LambdaTerm lambdaTerm = term as LambdaTerm;
      expect(lambdaTerm.parameters, isEmpty);
      expect(lambdaTerm.body, isA<NumberTerm>());
    });

    test('lowers multi-param lambda to LambdaTerm', () {
      const SemanticLambdaNode semantic = SemanticLambdaNode(
        location: defaultLocation,
        parameters: ['x', 'y'],
        body: SemanticBoundVariableNode(
          location: defaultLocation,
          name: 'x',
          isLambdaParameter: true,
        ),
      );
      const Lowerer lowerer = Lowerer({});
      final Term term = lowerer.lowerTerm(semantic);

      expect(term, isA<LambdaTerm>());
      final LambdaTerm lambdaTerm = term as LambdaTerm;
      expect(lambdaTerm.parameters.length, equals(2));
      expect(lambdaTerm.parameters[0].name, equals('x'));
      expect(lambdaTerm.parameters[1].name, equals('y'));
    });

    test('lambda name format includes location', () {
      const SemanticLambdaNode semantic = SemanticLambdaNode(
        location: Location(row: 5, column: 10),
        parameters: ['x'],
        body: SemanticBoundVariableNode(
          location: Location(row: 5, column: 10),
          name: 'x',
          isLambdaParameter: true,
        ),
      );
      const Lowerer lowerer = Lowerer({});
      final Term term = lowerer.lowerTerm(semantic);

      expect(term, isA<LambdaTerm>());
      final LambdaTerm lambdaTerm = term as LambdaTerm;
      expect(lambdaTerm.name, equals('<lambda@5:10>'));
    });

    test('lowers nested lambda', () {
      const SemanticLambdaNode semantic = SemanticLambdaNode(
        location: defaultLocation,
        parameters: ['x'],
        body: SemanticLambdaNode(
          location: defaultLocation,
          parameters: ['y'],
          body: SemanticBoundVariableNode(
            location: defaultLocation,
            name: 'x',
            isLambdaParameter: true,
          ),
        ),
      );
      const Lowerer lowerer = Lowerer({});
      final Term term = lowerer.lowerTerm(semantic);

      expect(term, isA<LambdaTerm>());
      final LambdaTerm outerLambda = term as LambdaTerm;
      expect(outerLambda.body, isA<LambdaTerm>());
      final LambdaTerm innerLambda = outerLambda.body as LambdaTerm;
      expect(innerLambda.body, isA<LambdaBoundVariableTerm>());
    });

    test('lowers lambda with call in body', () {
      final Map<String, FunctionTerm> functions = {
        'add': const TestFunctionTerm(
          name: 'add',
          parameters: [Parameter.any('a'), Parameter.any('b')],
        ),
      };
      const SemanticLambdaNode semantic = SemanticLambdaNode(
        location: defaultLocation,
        parameters: ['x', 'y'],
        body: SemanticCallNode(
          location: defaultLocation,
          callee: SemanticIdentifierNode(
            location: defaultLocation,
            name: 'add',
          ),
          arguments: [
            SemanticBoundVariableNode(
              location: defaultLocation,
              name: 'x',
              isLambdaParameter: true,
            ),
            SemanticBoundVariableNode(
              location: defaultLocation,
              name: 'y',
              isLambdaParameter: true,
            ),
          ],
        ),
      );
      final Lowerer lowerer = Lowerer(functions);
      final Term term = lowerer.lowerTerm(semantic);

      expect(term, isA<LambdaTerm>());
      final LambdaTerm lambdaTerm = term as LambdaTerm;
      expect(lambdaTerm.body, isA<CallTerm>());
      final CallTerm callTerm = lambdaTerm.body as CallTerm;
      expect(callTerm.arguments[0], isA<LambdaBoundVariableTerm>());
      expect(callTerm.arguments[1], isA<LambdaBoundVariableTerm>());
    });

    test('lowers lambda with captured function parameter', () {
      final Map<String, FunctionTerm> functions = {
        'add': const TestFunctionTerm(
          name: 'add',
          parameters: [Parameter.any('a'), Parameter.any('b')],
        ),
      };
      const SemanticLambdaNode semantic = SemanticLambdaNode(
        location: defaultLocation,
        parameters: ['x'],
        body: SemanticCallNode(
          location: defaultLocation,
          callee: SemanticIdentifierNode(
            location: defaultLocation,
            name: 'add',
          ),
          arguments: [
            SemanticBoundVariableNode(
              location: defaultLocation,
              name: 'x',
              isLambdaParameter: true,
            ),
            SemanticBoundVariableNode(
              location: defaultLocation,
              name: 'n',
              isLambdaParameter: false,
              isLetBinding: false,
            ),
          ],
        ),
      );
      final Lowerer lowerer = Lowerer(functions);
      final Term term = lowerer.lowerTerm(semantic);

      expect(term, isA<LambdaTerm>());
      final LambdaTerm lambdaTerm = term as LambdaTerm;
      final CallTerm callTerm = lambdaTerm.body as CallTerm;
      expect(callTerm.arguments[0], isA<LambdaBoundVariableTerm>());
      expect(callTerm.arguments[1], isA<BoundVariableTerm>());
    });
  });

  group('SemanticBoundVariableNode with isLambdaParameter', () {
    const Location defaultLocation = Location(row: 1, column: 1);

    test('isLambdaParameter true produces LambdaBoundVariableTerm', () {
      const SemanticBoundVariableNode semantic = SemanticBoundVariableNode(
        location: defaultLocation,
        name: 'x',
        isLambdaParameter: true,
      );
      const Lowerer lowerer = Lowerer({});
      final Term term = lowerer.lowerTerm(semantic);

      expect(term, isA<LambdaBoundVariableTerm>());
      expect((term as LambdaBoundVariableTerm).name, equals('x'));
    });

    test(
      'isLambdaParameter takes precedence over isLetBinding',
      () {
        // This shouldn't happen in practice, but testing the priority
        const SemanticBoundVariableNode semantic = SemanticBoundVariableNode(
          location: defaultLocation,
          name: 'x',
          isLambdaParameter: true,
          isLetBinding: true,
        );
        const Lowerer lowerer = Lowerer({});
        final Term term = lowerer.lowerTerm(semantic);

        // isLambdaParameter is checked first
        expect(term, isA<LambdaBoundVariableTerm>());
      },
    );

    test('default flags produce BoundVariableTerm', () {
      const SemanticBoundVariableNode semantic = SemanticBoundVariableNode(
        location: defaultLocation,
        name: 'x',
      );
      const Lowerer lowerer = Lowerer({});
      final Term term = lowerer.lowerTerm(semantic);

      expect(term, isA<BoundVariableTerm>());
    });
  });
}
