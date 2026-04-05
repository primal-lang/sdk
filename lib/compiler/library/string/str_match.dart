import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class StrMatch extends NativeFunctionNode {
  const StrMatch()
    : super(
        name: 'str.match',
        parameters: const [
          Parameter.string('a'),
          Parameter.string('b'),
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

    if ((a is StringNode) && (b is StringNode)) {
      try {
        return BooleanNode(RegExp(b.value).hasMatch(a.value));
      } on FormatException {
        throw ParseError(function: name, input: b.value, targetType: 'regex');
      }
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
