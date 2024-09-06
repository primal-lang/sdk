import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class StrPadLeft extends NativeFunctionNode {
  StrPadLeft()
      : super(
          name: 'str.padLeft',
          parameters: [
            Parameter.string('a'),
            Parameter.number('b'),
            Parameter.string('c'),
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

    if ((a is StringNode) && (b is NumberNode) && (c is StringNode)) {
      return StringNode(a.value.padLeft(b.value.toInt(), c.value));
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type, c.type],
      );
    }
  }
}
