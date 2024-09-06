import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class NumClamp extends NativeFunctionNode {
  NumClamp()
      : super(
          name: 'num.clamp',
          parameters: [
            Parameter.number('a'),
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

    if ((a is NumberNode) && (b is NumberNode) && (c is NumberNode)) {
      return NumberNode(a.value.clamp(b.value, c.value));
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type, c.type],
      );
    }
  }
}
