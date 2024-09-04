import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class CompLt extends NativeFunctionNode {
  CompLt()
      : super(
          name: 'comp.lt',
          parameters: [
            Parameter.number('a'),
            Parameter.number('b'),
          ],
        );

  @override
  Node node(List<Node> arguments) => CompLtNode3(
        name: name,
        parameters: parameters,
        arguments: arguments,
      );
}

class CompLtNode3 extends FunctionNode {
  final List<Node> arguments;

  const CompLtNode3({
    required super.name,
    required super.parameters,
    required this.arguments,
  });

  @override
  Node evaluate() {
    final Node a = arguments[0].evaluate();
    final Node b = arguments[1].evaluate();

    if ((a is NumberNode) && (b is NumberNode)) {
      return BooleanNode(a.value < b.value);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
