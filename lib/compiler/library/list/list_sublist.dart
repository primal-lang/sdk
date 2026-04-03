import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class ListSublist extends NativeFunctionNode {
  ListSublist()
    : super(
        name: 'list.sublist',
        parameters: [
          Parameter.list('a'),
          Parameter.number('b'),
          Parameter.number('c'),
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
    final Node c = arguments[2].evaluate();

    if ((a is ListNode) && (b is NumberNode) && (c is NumberNode)) {
      final int start = b.value.toInt();
      final int end = c.value.toInt();
      if (start < 0) {
        throw NegativeIndexError(function: name, index: start);
      }
      if (end < start) {
        throw IndexOutOfBoundsError(
          function: name,
          index: end,
          length: a.value.length,
        );
      }
      if (end > a.value.length) {
        throw IndexOutOfBoundsError(
          function: name,
          index: end,
          length: a.value.length,
        );
      }
      return ListNode(a.value.sublist(start, end));
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type, c.type],
      );
    }
  }
}
