import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/library/set/set_remove.dart';
import 'package:primal/compiler/library/vector/vector_sub.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class OperatorSub extends NativeFunctionNode {
  OperatorSub()
      : super(
          name: '-',
          parameters: [
            Parameter.any('a'),
            Parameter.any('b'),
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

    if ((a is NumberNode) && (b is NumberNode)) {
      return NumberNode(a.value - b.value);
    } else if ((a is VectorNode) && (b is VectorNode)) {
      return VectorSub.execute(
        function: this,
        a: a,
        b: b,
      );
    } else if ((a is SetNode) && (b is! SetNode)) {
      return SetRemove.execute(
        function: this,
        a: a,
        b: b,
      );
    } else if ((a is! SetNode) && (b is SetNode)) {
      return SetRemove.execute(
        function: this,
        a: b,
        b: a,
      );
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
