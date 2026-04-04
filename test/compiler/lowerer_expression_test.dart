@Tags(['compiler'])
library;

import 'package:primal/compiler/lowering/lowerer.dart';
import 'package:primal/compiler/models/location.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/semantic/semantic_node.dart';
import 'package:test/test.dart';

void main() {
  const Location defaultLocation = Location(row: 1, column: 1);

  // Create mock functions for testing identifier lowering
  final Map<String, FunctionNode> functions = {
    'myVar': const FunctionNode(name: 'myVar', parameters: []),
    'foo': const FunctionNode(name: 'foo', parameters: []),
    'add': FunctionNode(
      name: 'add',
      parameters: [
        Parameter.number('a'),
        Parameter.number('b'),
      ],
    ),
    'outer': FunctionNode(name: 'outer', parameters: [Parameter.any('x')]),
    'inner': FunctionNode(name: 'inner', parameters: [Parameter.any('x')]),
  };
  final Lowerer lowerer = Lowerer(functions);

  group('Lowerer.lowerNode', () {
    group('SemanticBooleanNode', () {
      test('lowers true', () {
        const SemanticBooleanNode semantic = SemanticBooleanNode(
          location: defaultLocation,
          value: true,
        );
        final Node node = lowerer.lowerNode(semantic);

        expect(node, isA<BooleanNode>());
        expect((node as BooleanNode).value, isTrue);
      });

      test('lowers false', () {
        const SemanticBooleanNode semantic = SemanticBooleanNode(
          location: defaultLocation,
          value: false,
        );
        final Node node = lowerer.lowerNode(semantic);

        expect(node, isA<BooleanNode>());
        expect((node as BooleanNode).value, isFalse);
      });
    });

    group('SemanticNumberNode', () {
      test('lowers integer', () {
        const SemanticNumberNode semantic = SemanticNumberNode(
          location: defaultLocation,
          value: 42,
        );
        final Node node = lowerer.lowerNode(semantic);

        expect(node, isA<NumberNode>());
        expect((node as NumberNode).value, equals(42));
      });

      test('lowers decimal', () {
        const SemanticNumberNode semantic = SemanticNumberNode(
          location: defaultLocation,
          value: 3.14,
        );
        final Node node = lowerer.lowerNode(semantic);

        expect(node, isA<NumberNode>());
        expect((node as NumberNode).value, equals(3.14));
      });
    });

    group('SemanticStringNode', () {
      test('lowers string', () {
        const SemanticStringNode semantic = SemanticStringNode(
          location: defaultLocation,
          value: 'hello',
        );
        final Node node = lowerer.lowerNode(semantic);

        expect(node, isA<StringNode>());
        expect((node as StringNode).value, equals('hello'));
      });

      test('lowers empty string', () {
        const SemanticStringNode semantic = SemanticStringNode(
          location: defaultLocation,
          value: '',
        );
        final Node node = lowerer.lowerNode(semantic);

        expect(node, isA<StringNode>());
        expect((node as StringNode).value, equals(''));
      });
    });

    group('SemanticIdentifierNode', () {
      test('lowers identifier to FunctionRefNode', () {
        const SemanticIdentifierNode semantic = SemanticIdentifierNode(
          location: defaultLocation,
          name: 'myVar',
        );
        final Node node = lowerer.lowerNode(semantic);

        expect(node, isA<FunctionRefNode>());
        expect((node as FunctionRefNode).name, equals('myVar'));
      });
    });

    group('SemanticBoundVariableNode', () {
      test('lowers bound variable', () {
        const SemanticBoundVariableNode semantic = SemanticBoundVariableNode(
          location: defaultLocation,
          name: 'x',
        );
        final Node node = lowerer.lowerNode(semantic);

        expect(node, isA<BoundVariableNode>());
        expect((node as BoundVariableNode).name, equals('x'));
      });
    });

    group('SemanticListNode', () {
      test('lowers empty list', () {
        const SemanticListNode semantic = SemanticListNode(
          location: defaultLocation,
          value: [],
        );
        final Node node = lowerer.lowerNode(semantic);

        expect(node, isA<ListNode>());
        expect((node as ListNode).value, isEmpty);
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
        final Node node = lowerer.lowerNode(semantic);

        expect(node, isA<ListNode>());
        final ListNode list = node as ListNode;
        expect(list.value.length, equals(3));
        expect((list.value[0] as NumberNode).value, equals(1));
        expect((list.value[1] as NumberNode).value, equals(2));
        expect((list.value[2] as NumberNode).value, equals(3));
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
        final Node node = lowerer.lowerNode(semantic);

        expect(node, isA<ListNode>());
        final ListNode outer = node as ListNode;
        expect(outer.value.length, equals(1));
        expect(outer.value[0], isA<ListNode>());
        final ListNode inner = outer.value[0] as ListNode;
        expect((inner.value[0] as NumberNode).value, equals(1));
      });
    });

    group('SemanticMapNode', () {
      test('lowers empty map', () {
        const SemanticMapNode semantic = SemanticMapNode(
          location: defaultLocation,
          value: [],
        );
        final Node node = lowerer.lowerNode(semantic);

        expect(node, isA<MapNode>());
        expect((node as MapNode).value, isEmpty);
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
        final Node node = lowerer.lowerNode(semantic);

        expect(node, isA<MapNode>());
        final MapNode map = node as MapNode;
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
        final Node node = lowerer.lowerNode(semantic);

        expect(node, isA<CallNode>());
        final CallNode call = node as CallNode;
        expect(call.callee, isA<FunctionRefNode>());
        expect((call.callee as FunctionRefNode).name, equals('foo'));
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
        final Node node = lowerer.lowerNode(semantic);

        expect(node, isA<CallNode>());
        final CallNode call = node as CallNode;
        expect(call.arguments.length, equals(2));
        expect((call.arguments[0] as NumberNode).value, equals(1));
        expect((call.arguments[1] as NumberNode).value, equals(2));
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
        final Node node = lowerer.lowerNode(semantic);

        expect(node, isA<CallNode>());
        final CallNode outer = node as CallNode;
        expect(outer.arguments.length, equals(1));
        expect(outer.arguments[0], isA<CallNode>());
        final CallNode inner = outer.arguments[0] as CallNode;
        expect((inner.callee as FunctionRefNode).name, equals('inner'));
      });
    });
  });
}
