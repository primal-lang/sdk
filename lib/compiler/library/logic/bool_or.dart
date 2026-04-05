import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class BoolOr extends NativeFunctionNode {
  const BoolOr()
    : super(
        name: 'bool.or',
        parameters: const [
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

  static BooleanNode execute({
    required FunctionNode function,
    required List<Node> arguments,
  }) {
    final Node a = arguments[0].reduce();

    if (a is BooleanNode) {
      if (a.value) {
        return const BooleanNode(true);
      } else {
        final Node b = arguments[1].reduce();

        if (b is BooleanNode) {
          return b;
        } else {
          throw InvalidArgumentTypesError(
            function: function.name,
            expected: function.parameterTypes,
            actual: [a.type, b.type],
          );
        }
      }
    } else {
      throw InvalidArgumentTypesError(
        function: function.name,
        expected: function.parameterTypes,
        actual: [a.type],
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
  Node reduce() => BoolOr.execute(
    function: this,
    arguments: arguments,
  );
}
