import 'dart:convert';
import 'dart:typed_data';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class StrBytes extends NativeFunctionNode {
  const StrBytes()
    : super(
        name: 'str.bytes',
        parameters: const [
          Parameter.string('a'),
        ],
      );

  @override
  Node node(List<Node> arguments) => NodeWithArguments(
    name: name,
    parameters: parameters,
    arguments: arguments,
  );
}

class NodeWithArguments extends NativeFunctionNodeWithArguments {
  const NodeWithArguments({
    required super.name,
    required super.parameters,
    required super.arguments,
  });

  @override
  Node reduce() {
    final Node a = arguments[0].reduce();

    if (a is StringNode) {
      final Uint8List bytes = Uint8List.fromList(utf8.encode(a.value));

      return ListNode(bytes.map(NumberNode.new).toList());
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
