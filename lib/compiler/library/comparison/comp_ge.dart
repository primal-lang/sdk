import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class CompGe extends NativeFunctionPrototype {
  CompGe()
      : super(
          name: 'comp.ge',
          parameters: [
            Parameter.number('a'),
            Parameter.number('b'),
          ],
        );

  @override
  FunctionNode toNode() => CompGeNode2(
        name: name,
        parameters: parameters,
      );
}

class CompGeNode2 extends NativeFunctionNode {
  const CompGeNode2({
    required super.name,
    required super.parameters,
  });

  @override
  Node body(List<Node> arguments) => CompGeNode3(
        name: name,
        parameters: parameters,
        arguments: arguments,
      );
}

class CompGeNode3 extends FunctionNode {
  final List<Node> arguments;

  const CompGeNode3({
    required super.name,
    required super.parameters,
    required this.arguments,
  });

  @override
  Node evaluate() {
    final Node a = arguments[0].evaluate();
    final Node b = arguments[1].evaluate();

    if ((a is NumberNode) && (b is NumberNode)) {
      return BooleanNode(a.value >= b.value);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
