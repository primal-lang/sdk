import 'package:characters/characters.dart';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class StrIndexOf extends NativeFunctionNode {
  const StrIndexOf()
    : super(
        name: 'str.indexOf',
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
  Node reduce() {
    final Node a = arguments[0].reduce();
    final Node b = arguments[1].reduce();

    if ((a is StringNode) && (b is StringNode)) {
      final int codeUnitIndex = a.value.indexOf(b.value);
      if (codeUnitIndex == -1) {
        return const NumberNode(-1);
      }
      final int graphemeIndex = a.value
          .substring(0, codeUnitIndex)
          .characters
          .length;
      return NumberNode(graphemeIndex);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
