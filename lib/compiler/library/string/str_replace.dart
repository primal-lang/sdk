import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class StrReplace extends NativeFunctionNode {
  const StrReplace()
    : super(
        name: 'str.replace',
        parameters: const [
          Parameter.string('a'),
          Parameter.string('b'),
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
  Node reduce() {
    final Node a = arguments[0].reduce();
    final Node b = arguments[1].reduce();
    final Node c = arguments[2].reduce();

    if ((a is StringNode) && (b is StringNode) && (c is StringNode)) {
      return StringNode(a.value.replaceAll(RegExp(b.value), c.value));
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type, c.type],
      );
    }
  }
}
