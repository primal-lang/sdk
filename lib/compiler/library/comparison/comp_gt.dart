import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class CompGt extends NativeFunctionNode {
  CompGt()
      : super(
          name: 'comp.gt',
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

  static Node execute({
    required FunctionNode function,
    required Node a,
    required Node b,
  }) {
    if ((a is NumberNode) && (b is NumberNode)) {
      return BooleanNode(a.value > b.value);
    } else if ((a is StringNode) && (b is StringNode)) {
      final int comparison = a.value.compareTo(b.value);

      return BooleanNode(comparison > 0);
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

    return CompGt.execute(
      function: this,
      a: a,
      b: b,
    );
  }
}
