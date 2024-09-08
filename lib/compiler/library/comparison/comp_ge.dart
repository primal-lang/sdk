import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class CompGe extends NativeFunctionNode {
  CompGe()
      : super(
          name: 'comp.ge',
          parameters: [
            Parameter.any('a'),
            Parameter.any('b'),
          ],
        );

  @override
  Node node(List<Node> arguments) => NodeWithArguments(
        name: name,
        parameters: parameters,
        arguments: arguments,
      );

  static Node execute({
    required FunctionNode function,
    required Node a,
    required Node b,
  }) {
    if ((a is NumberNode) && (b is NumberNode)) {
      return BooleanNode(a.value >= b.value);
    } else if ((a is StringNode) && (b is StringNode)) {
      return BooleanNode(a.value.compareTo(b.value) >= 0);
    } else if ((a is TimestampNode) && (b is TimestampNode)) {
      return BooleanNode(a.value.compareTo(b.value) >= 0);
    } else {
      throw InvalidArgumentTypesError(
        function: function.name,
        expected: function.parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
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

    return CompGe.execute(
      function: this,
      a: a,
      b: b,
    );
  }
}
