import 'package:characters/characters.dart';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class StrSubstring extends NativeFunctionNode {
  StrSubstring()
    : super(
        name: 'str.substring',
        parameters: [
          Parameter.string('a'),
          Parameter.number('b'),
          Parameter.number('c'),
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

    if ((a is StringNode) && (b is NumberNode) && (c is NumberNode)) {
      final int start = b.value.toInt();
      final int end = c.value.toInt();
      final Characters chars = a.value.characters;
      if (start < 0) {
        throw NegativeIndexError(function: name, index: start);
      }
      if (end < start) {
        throw IndexOutOfBoundsError(
          function: name,
          index: end,
          length: chars.length,
        );
      }
      if (end > chars.length) {
        throw IndexOutOfBoundsError(
          function: name,
          index: end,
          length: chars.length,
        );
      }
      return StringNode(chars.skip(start).take(end - start).toString());
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type, c.type],
      );
    }
  }
}
