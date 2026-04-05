@Tags(['runtime'])
@TestOn('vm')
library;

import 'dart:io';

import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/models/type.dart';
import 'package:primal/compiler/runtime/bindings.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:test/test.dart';

void main() {
  group('LiteralNode.from()', () {
    test('bool returns BooleanNode', () {
      final LiteralNode node = LiteralNode.from(true);
      expect(node, isA<BooleanNode>());
    });

    test('int returns NumberNode', () {
      final LiteralNode node = LiteralNode.from(42);
      expect(node, isA<NumberNode>());
    });

    test('double returns NumberNode', () {
      final LiteralNode node = LiteralNode.from(3.14);
      expect(node, isA<NumberNode>());
    });

    test('String returns StringNode', () {
      final LiteralNode node = LiteralNode.from('hello');
      expect(node, isA<StringNode>());
    });

    test('List<Node> returns ListNode', () {
      final LiteralNode node = LiteralNode.from(<Node>[const NumberNode(1)]);
      expect(node, isA<ListNode>());
    });

    test('Map<Node, Node> returns MapNode', () {
      final LiteralNode node = LiteralNode.from(
        <Node, Node>{const StringNode('a'): const NumberNode(1)},
      );
      expect(node, isA<MapNode>());
    });

    test('DateTime returns TimestampNode', () {
      final LiteralNode node = LiteralNode.from(DateTime(2024));
      expect(node, isA<TimestampNode>());
    });

    test('File returns FileNode', () {
      final LiteralNode node = LiteralNode.from(File('test.txt'));
      expect(node, isA<FileNode>());
    });

    test('Directory returns DirectoryNode', () {
      final LiteralNode node = LiteralNode.from(Directory('test'));
      expect(node, isA<DirectoryNode>());
    });

    test('Set<Node> returns SetNode', () {
      final LiteralNode node = LiteralNode.from(<Node>{const NumberNode(1)});
      expect(node, isA<SetNode>());
    });

    test('unsupported type throws InvalidLiteralValueError', () {
      expect(
        () => LiteralNode.from(Object()),
        throwsA(isA<InvalidLiteralValueError>()),
      );
    });
  });

  group('BooleanNode', () {
    const BooleanNode node = BooleanNode(true);

    test('type is BooleanType', () {
      expect(node.type, isA<BooleanType>());
    });

    test('value is correct', () {
      expect(node.value, true);
    });

    test('native() returns raw bool', () {
      expect(node.native(), true);
    });

    test('toString() returns string representation', () {
      expect(node.toString(), 'true');
    });

    test('substitute() returns itself', () {
      const Bindings bindings = Bindings({});
      expect(node.substitute(bindings), same(node));
    });

    test('evaluate() returns itself', () {
      expect(node.evaluate(), same(node));
    });

    test('false value', () {
      const BooleanNode falseNode = BooleanNode(false);
      expect(falseNode.native(), false);
      expect(falseNode.toString(), 'false');
    });
  });

  group('NumberNode', () {
    const NumberNode intNode = NumberNode(42);
    const NumberNode doubleNode = NumberNode(3.14);

    test('type is NumberType', () {
      expect(intNode.type, isA<NumberType>());
    });

    test('int value is correct', () {
      expect(intNode.value, 42);
    });

    test('double value is correct', () {
      expect(doubleNode.value, 3.14);
    });

    test('native() returns raw int', () {
      expect(intNode.native(), 42);
    });

    test('native() returns raw double', () {
      expect(doubleNode.native(), 3.14);
    });

    test('toString() for int', () {
      expect(intNode.toString(), '42');
    });

    test('toString() for double', () {
      expect(doubleNode.toString(), '3.14');
    });

    test('substitute() returns itself', () {
      const Bindings bindings = Bindings({});
      expect(intNode.substitute(bindings), same(intNode));
    });

    test('evaluate() returns itself', () {
      expect(intNode.evaluate(), same(intNode));
    });

    test('zero value', () {
      const NumberNode zeroNode = NumberNode(0);
      expect(zeroNode.native(), 0);
    });

    test('negative value', () {
      const NumberNode negNode = NumberNode(-7);
      expect(negNode.native(), -7);
    });
  });

  group('StringNode', () {
    const StringNode node = StringNode('hello');

    test('type is StringType', () {
      expect(node.type, isA<StringType>());
    });

    test('value is correct', () {
      expect(node.value, 'hello');
    });

    test('native() returns raw string', () {
      expect(node.native(), 'hello');
    });

    test('toString() returns string representation', () {
      expect(node.toString(), 'hello');
    });

    test('substitute() returns itself', () {
      const Bindings bindings = Bindings({});
      expect(node.substitute(bindings), same(node));
    });

    test('evaluate() returns itself', () {
      expect(node.evaluate(), same(node));
    });

    test('empty string', () {
      const StringNode emptyNode = StringNode('');
      expect(emptyNode.native(), '');
      expect(emptyNode.toString(), '');
    });
  });

  group('ListNode', () {
    test('native() returns list of native values', () {
      const ListNode node = ListNode([
        NumberNode(1),
        NumberNode(2),
        NumberNode(3),
      ]);
      expect(node.native(), [1, 2, 3]);
    });

    test('native() with mixed types', () {
      const ListNode node = ListNode([
        NumberNode(1),
        StringNode('two'),
        BooleanNode(true),
      ]);
      expect(node.native(), [1, 'two', true]);
    });

    test('native() with empty list', () {
      const ListNode node = ListNode([]);
      expect(node.native(), []);
    });

    test('type is ListType', () {
      const ListNode node = ListNode([]);
      expect(node.type, isA<ListType>());
    });

    test('substitute() substitutes inner elements', () {
      const ListNode node = ListNode([
        BoundVariableNode('x'),
        NumberNode(2),
      ]);
      const Bindings bindings = Bindings({'x': NumberNode(99)});
      final Node result = node.substitute(bindings);
      expect(result, isA<ListNode>());
      expect((result as ListNode).native(), [99, 2]);
    });
  });

  group('MapNode', () {
    test('native() returns map of native values', () {
      const MapNode node = MapNode({
        StringNode('a'): NumberNode(1),
        StringNode('b'): NumberNode(2),
      });
      expect(node.native(), {'a': 1, 'b': 2});
    });

    test('native() with empty map', () {
      const MapNode node = MapNode({});
      expect(node.native(), {});
    });

    test('type is MapType', () {
      const MapNode node = MapNode({});
      expect(node.type, isA<MapType>());
    });

    test('asMapWithKeys() returns map with native keys', () {
      const MapNode node = MapNode({
        StringNode('x'): NumberNode(10),
        StringNode('y'): NumberNode(20),
      });
      final Map<dynamic, Node> result = node.asMapWithKeys();
      expect(result.keys.toList(), ['x', 'y']);
      expect(result['x'], isA<NumberNode>());
      expect((result['x'] as NumberNode).value, 10);
    });

    test('substitute() substitutes keys and values', () {
      const MapNode node = MapNode({
        StringNode('key'): BoundVariableNode('x'),
      });
      const Bindings bindings = Bindings({'x': NumberNode(42)});
      final Node result = node.substitute(bindings);
      expect(result, isA<MapNode>());
      expect((result as MapNode).native(), {'key': 42});
    });
  });

  group('SetNode', () {
    test('native() returns set of native values', () {
      const SetNode node = SetNode({
        NumberNode(1),
        NumberNode(2),
        NumberNode(3),
      });
      expect(node.native(), {1, 2, 3});
    });

    test('native() with empty set', () {
      const SetNode node = SetNode({});
      expect(node.native(), <dynamic>{});
    });

    test('type is SetType', () {
      const SetNode node = SetNode({});
      expect(node.type, isA<SetType>());
    });

    test('substitute() substitutes inner elements', () {
      const SetNode node = SetNode({
        BoundVariableNode('x'),
        NumberNode(2),
      });
      const Bindings bindings = Bindings({'x': NumberNode(99)});
      final Node result = node.substitute(bindings);
      expect(result, isA<SetNode>());
      expect((result as SetNode).native(), {99, 2});
    });
  });

  group('VectorNode', () {
    test('native() returns list of native values', () {
      const VectorNode node = VectorNode([NumberNode(1), NumberNode(2)]);
      expect(node.native(), [1, 2]);
    });

    test('type is VectorType', () {
      const VectorNode node = VectorNode([]);
      expect(node.type, isA<VectorType>());
    });
  });

  group('BoundVariableNode', () {
    test('substitute() returns bound value', () {
      const BoundVariableNode node = BoundVariableNode('x');
      const Bindings bindings = Bindings({'x': NumberNode(42)});
      final Node result = node.substitute(bindings);
      expect(result, isA<NumberNode>());
      expect((result as NumberNode).value, 42);
    });

    test('substitute() with string binding', () {
      const BoundVariableNode node = BoundVariableNode('name');
      const Bindings bindings = Bindings({'name': StringNode('hello')});
      final Node result = node.substitute(bindings);
      expect(result, isA<StringNode>());
      expect((result as StringNode).value, 'hello');
    });

    test('substitute() with missing binding throws', () {
      const BoundVariableNode node = BoundVariableNode('y');
      const Bindings bindings = Bindings({'x': NumberNode(1)});
      expect(
        () => node.substitute(bindings),
        throwsA(isA<NotFoundInScopeError>()),
      );
    });

    test('type is AnyType', () {
      const BoundVariableNode node = BoundVariableNode('x');
      expect(node.type, isA<AnyType>());
    });

    test('toString() returns variable name', () {
      const BoundVariableNode node = BoundVariableNode('myVar');
      expect(node.toString(), 'myVar');
    });

    test('native() throws StateError', () {
      const BoundVariableNode node = BoundVariableNode('x');
      expect(() => node.native(), throwsStateError);
    });
  });

  group('FunctionReferenceNode', () {
    test('evaluate() returns the referenced function', () {
      const FunctionNode fn = FunctionNode(
        name: 'myFunc',
        parameters: [Parameter.number('x')],
      );
      final Map<String, FunctionNode> functions = {'myFunc': fn};
      final FunctionReferenceNode ref = FunctionReferenceNode(
        'myFunc',
        functions,
      );

      expect(ref.evaluate(), same(fn));
    });

    test('type is FunctionType', () {
      const FunctionNode fn = FunctionNode(name: 'f', parameters: []);
      final Map<String, FunctionNode> functions = {'f': fn};
      final FunctionReferenceNode ref = FunctionReferenceNode('f', functions);

      expect(ref.type, isA<FunctionType>());
    });

    test('toString() returns function name', () {
      const FunctionNode fn = FunctionNode(name: 'myFunc', parameters: []);
      final Map<String, FunctionNode> functions = {'myFunc': fn};
      final FunctionReferenceNode ref = FunctionReferenceNode(
        'myFunc',
        functions,
      );

      expect(ref.toString(), 'myFunc');
    });

    test('native() returns function string representation', () {
      const FunctionNode fn = FunctionNode(
        name: 'add',
        parameters: [Parameter.number('a'), Parameter.number('b')],
      );
      final Map<String, FunctionNode> functions = {'add': fn};
      final FunctionReferenceNode ref = FunctionReferenceNode('add', functions);

      expect(ref.native(), 'add(a: Number, b: Number)');
    });
  });

  group('FunctionNode', () {
    test('type is FunctionType', () {
      const FunctionNode node = FunctionNode(
        name: 'f',
        parameters: [Parameter.number('x')],
      );
      expect(node.type, isA<FunctionType>());
    });

    test('toString() includes name and parameters', () {
      const FunctionNode node = FunctionNode(
        name: 'add',
        parameters: [Parameter.number('a'), Parameter.number('b')],
      );
      expect(node.toString(), 'add(a: Number, b: Number)');
    });

    test('parameterTypes returns list of types', () {
      const FunctionNode node = FunctionNode(
        name: 'f',
        parameters: [Parameter.number('x'), Parameter.string('y')],
      );
      expect(node.parameterTypes.length, 2);
      expect(node.parameterTypes[0], isA<NumberType>());
      expect(node.parameterTypes[1], isA<StringType>());
    });

    test('native() returns string representation', () {
      const FunctionNode node = FunctionNode(
        name: 'f',
        parameters: [Parameter.number('x')],
      );
      expect(node.native(), 'f(x: Number)');
    });

    test('apply with wrong argument count throws', () {
      const FunctionNode node = FunctionNode(
        name: 'f',
        parameters: [Parameter.number('x')],
      );
      expect(
        () => node.apply([const NumberNode(1), const NumberNode(2)]),
        throwsA(isA<InvalidArgumentCountError>()),
      );
    });

    test('equalSignature compares names', () {
      const FunctionNode f1 = FunctionNode(
        name: 'f',
        parameters: [Parameter.number('x')],
      );
      const FunctionNode f2 = FunctionNode(
        name: 'f',
        parameters: [Parameter.string('y')],
      );
      const FunctionNode f3 = FunctionNode(
        name: 'g',
        parameters: [Parameter.number('x')],
      );
      expect(f1.equalSignature(f2), true);
      expect(f1.equalSignature(f3), false);
    });
  });

  group('TimestampNode', () {
    test('type is TimestampType', () {
      final TimestampNode node = TimestampNode(DateTime(2024, 1, 1));
      expect(node.type, isA<TimestampType>());
    });

    test('native() returns DateTime', () {
      final DateTime dt = DateTime(2024, 6, 15);
      final TimestampNode node = TimestampNode(dt);
      expect(node.native(), dt);
    });
  });

  group('FileNode', () {
    test('type is FileType', () {
      final FileNode node = FileNode(File('dummy'));
      expect(node.type, isA<FileType>());
    });
  });

  group('DirectoryNode', () {
    test('type is DirectoryType', () {
      final DirectoryNode node = DirectoryNode(Directory('dummy'));
      expect(node.type, isA<DirectoryType>());
    });
  });

  group('VectorNode', () {
    test('substitute() substitutes inner elements', () {
      const VectorNode node = VectorNode([
        BoundVariableNode('x'),
        NumberNode(2),
      ]);
      const Bindings bindings = Bindings({'x': NumberNode(99)});
      final Node result = node.substitute(bindings);
      expect(result, isA<VectorNode>());
      expect((result as VectorNode).native(), [99, 2]);
    });
  });

  group('StackNode', () {
    test('native() returns list of native values', () {
      const StackNode node = StackNode([NumberNode(1), NumberNode(2)]);
      expect(node.native(), [1, 2]);
    });

    test('type is StackType', () {
      const StackNode node = StackNode([]);
      expect(node.type, isA<StackType>());
    });

    test('substitute() substitutes inner elements', () {
      const StackNode node = StackNode([
        BoundVariableNode('x'),
        NumberNode(2),
      ]);
      const Bindings bindings = Bindings({'x': NumberNode(99)});
      final Node result = node.substitute(bindings);
      expect(result, isA<StackNode>());
      expect((result as StackNode).native(), [99, 2]);
    });
  });

  group('QueueNode', () {
    test('native() returns list of native values', () {
      const QueueNode node = QueueNode([NumberNode(1), NumberNode(2)]);
      expect(node.native(), [1, 2]);
    });

    test('type is QueueType', () {
      const QueueNode node = QueueNode([]);
      expect(node.type, isA<QueueType>());
    });

    test('substitute() substitutes inner elements', () {
      const QueueNode node = QueueNode([
        BoundVariableNode('x'),
        NumberNode(2),
      ]);
      const Bindings bindings = Bindings({'x': NumberNode(99)});
      final Node result = node.substitute(bindings);
      expect(result, isA<QueueNode>());
      expect((result as QueueNode).native(), [99, 2]);
    });
  });

  group('FunctionNode evaluate', () {
    test('evaluate returns itself', () {
      const FunctionNode node = FunctionNode(
        name: 'f',
        parameters: [Parameter.number('x')],
      );
      expect(node.evaluate(), same(node));
    });
  });

  group('CallNode', () {
    test('getFunctionNode with non-function callee throws', () {
      const CallNode call = CallNode(
        callee: NumberNode(42),
        arguments: [],
      );
      expect(call.evaluate, throwsA(isA<InvalidFunctionError>()));
    });

    test('type is FunctionCallType', () {
      const CallNode call = CallNode(
        callee: NumberNode(42),
        arguments: [],
      );
      expect(call.type, isA<FunctionCallType>());
    });

    test('toString() shows callee and arguments', () {
      const CallNode call = CallNode(
        callee: NumberNode(42),
        arguments: [NumberNode(1)],
      );
      expect(call.toString(), '42(1)');
    });
  });
}
