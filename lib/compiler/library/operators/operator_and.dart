import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class OperatorAnd extends NativeFunctionNode {
  OperatorAnd()
      : super(
          name: '&',
          parameters: [
            Parameter.boolean('a'),
            Parameter.boolean('b'),
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

    if (a is BooleanNode) {
      if (a.value) {
        final Node b = arguments[1].evaluate();

        if (b is BooleanNode) {
          return b;
        } else {
          throw InvalidArgumentTypesError(
            function: name,
            expected: parameterTypes,
            actual: [a.type, b.type],
          );
        }
      } else {
        return const BooleanNode(false);
      }
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
