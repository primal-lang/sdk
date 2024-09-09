import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class SetAdd extends NativeFunctionNode {
  SetAdd()
      : super(
          name: 'set.add',
          parameters: [
            Parameter.set('a'),
            Parameter.any('b'),
          ],
        );

  @override
  Node node(List<Node> arguments) => NodeWithArguments(
        name: name,
        parameters: parameters,
        arguments: arguments,
      );

  static SetNode execute({
    required FunctionNode function,
    required Node a,
    required Node b,
  }) {
    if (a is SetNode) {
      if (a.native().contains(b.native())) {
        return a;
      } else {
        final Set<Node> set = {...a.value};
        set.add(b);

        return SetNode(set);
      }
    } else {
      throw InvalidArgumentTypesError(
        function: function.name,
        expected: function.parameterTypes,
        actual: [a.type, b.type],
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
  Node evaluate() {
    final Node a = arguments[0].evaluate();
    final Node b = arguments[1].evaluate();

    return SetAdd.execute(
      function: this,
      a: a,
      b: b,
    );
  }
}
