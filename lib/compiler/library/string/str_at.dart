import 'package:characters/characters.dart';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class StrAt extends NativeFunctionNode {
  StrAt()
    : super(
        name: 'str.at',
        parameters: [
          Parameter.string('a'),
          Parameter.number('b'),
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

    if ((a is StringNode) && (b is NumberNode)) {
      final int index = b.value.toInt();
      final Characters chars = a.value.characters;
      if (index < 0) {
        throw NegativeIndexError(function: name, index: index);
      }
      if (index >= chars.length) {
        throw IndexOutOfBoundsError(
          function: name,
          index: index,
          length: chars.length,
        );
      }
      return StringNode(chars.elementAt(index));
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
