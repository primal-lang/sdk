import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class ListReduce extends NativeFunctionNode {
  ListReduce()
      : super(
          name: 'list.reduce',
          parameters: [
            Parameter.list('a'),
            Parameter.any('b'),
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
    final Node c = arguments[2].evaluate();

    if ((a is ListNode) && (c is FunctionNode)) {
      Node accumulated = b;

      for (final Node element in a.value) {
        accumulated = c.apply([accumulated, element]);
      }

      return accumulated;
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
