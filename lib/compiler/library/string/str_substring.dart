import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class StrSubstring extends NativeFunctionNode {
  StrSubstring()
      : super(
          name: 'str.substring',
          parameters: [
            Parameter.string('a'),
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
    final Node b = arguments[2].evaluate();
    final Node c = arguments[3].evaluate();

    if ((a is StringNode) && (b is NumberNode) && (c is NumberNode)) {
      return StringNode(a.value.substring(b.value.toInt(), c.value.toInt()));
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type, c.type],
      );
    }
  }
}
