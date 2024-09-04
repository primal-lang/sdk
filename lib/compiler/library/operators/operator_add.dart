import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class OperatorAdd extends NativeFunctionNode {
  OperatorAdd()
      : super(
          name: '+',
          parameters: [
            Parameter.number('a'),
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

    if ((a is NumberNode) && (b is NumberNode)) {
      return NumberNode(a.value + b.value);
    } else if ((a is StringNode) && (b is StringNode)) {
      return StringNode(a.value + b.value);
    } else if ((a is ListNode) && (b is ListNode)) {
      return ListNode([...a.value, ...b.value]);
    } else if (a is ListNode) {
      return ListNode([...a.value, b]);
    } else if (b is ListNode) {
      return ListNode([a, ...b.value]);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
