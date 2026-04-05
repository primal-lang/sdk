import 'dart:math' show min;
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class ListDrop extends NativeFunctionNode {
  const ListDrop()
    : super(
        name: 'list.drop',
        parameters: const [
          Parameter.list('a'),
          Parameter.number('b'),
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
  Node evaluate() {
    final Node a = arguments[0].evaluate();
    final Node b = arguments[1].evaluate();

    if ((a is ListNode) && (b is NumberNode)) {
      final int count = b.value.toInt();
      if (count < 0) {
        throw NegativeIndexError(function: name, index: count);
      }
      final int clampedCount = min(count, a.value.length);
      return ListNode(a.value.sublist(clampedCount, a.value.length));
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
