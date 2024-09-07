import 'dart:math';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class ListZip extends NativeFunctionNode {
  ListZip()
      : super(
          name: 'list.zip',
          parameters: [
            Parameter.list('a'),
            Parameter.list('b'),
            Parameter.function('c'),
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
    final Node c = arguments[2];

    if ((a is ListNode) && (b is ListNode) && (c is FreeVariableNode)) {
      final FunctionNode function = c.evaluate();
      final List<Node> result = [];
      final int maxLength = max(a.value.length, b.value.length);

      for (int i = 0; i < maxLength; i++) {
        final Node? elementA = i < a.value.length ? a.value[i] : null;
        final Node? elementB = i < b.value.length ? b.value[i] : null;

        if (elementA != null && elementB != null) {
          final Node value = function.apply([elementA, elementB]);
          result.add(value);
        } else if (elementA != null) {
          result.add(elementA);
        } else if (elementB != null) {
          result.add(elementB);
        }
      }

      return ListNode(result);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
