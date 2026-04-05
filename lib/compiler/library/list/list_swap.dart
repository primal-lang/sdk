import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class ListSwap extends NativeFunctionNode {
  const ListSwap()
    : super(
        name: 'list.swap',
        parameters: const [
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
      final int indexB = b.value.toInt();
      final int indexC = c.value.toInt();
      if (indexB < 0) {
        throw NegativeIndexError(function: name, index: indexB);
      }
      if (indexC < 0) {
        throw NegativeIndexError(function: name, index: indexC);
      }
      if (indexB >= a.value.length) {
        throw IndexOutOfBoundsError(
          function: name,
          index: indexB,
          length: a.value.length,
        );
      }
      if (indexC >= a.value.length) {
        throw IndexOutOfBoundsError(
          function: name,
          index: indexC,
          length: a.value.length,
        );
      }
      final List<Node> result = [];
      final Node valueAtB = a.value[indexB];
      final Node valueAtC = a.value[indexC];

      for (int i = 0; i < a.value.length; i++) {
        final Node element = a.value[i];

        if (i == indexB) {
          result.add(valueAtC);
        } else if (i == indexC) {
          result.add(valueAtB);
        } else {
          result.add(element);
        }
      }

      return ListNode(result);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type, c.type],
      );
    }
  }
}
