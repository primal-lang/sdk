import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class VectorNew extends NativeFunctionNode {
  const VectorNew()
    : super(
        name: 'vector.new',
        parameters: const [
          Parameter.list('a'),
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
  Node reduce() {
    final Node a = arguments[0].reduce();

    if (a is ListNode) {
      for (final Node element in a.value) {
        final dynamic value = element.native();

        if (value is! num) {
          throw InvalidArgumentTypesError(
            function: name,
            expected: parameterTypes,
            actual: [a.type],
          );
        }
      }

      return VectorNode(a.value);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
