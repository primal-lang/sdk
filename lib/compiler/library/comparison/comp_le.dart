import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class CompLe extends NativeFunctionPrototype {
  CompLe()
      : super(
          name: 'comp.le',
          parameters: [
            Parameter.number('a'),
            Parameter.number('b'),
          ],
        );

  @override
  FunctionNode toNode() => CompLeNode2(
        name: name,
        parameters: parameters,
      );
}

class CompLeNode2 extends NativeFunctionNode {
  const CompLeNode2({
    required super.name,
    required super.parameters,
  });

  @override
  Node body(List<Node> arguments) => CompLeNode3(
        name: name,
        parameters: parameters,
        arguments: arguments,
      );
}

class CompLeNode3 extends FunctionNode {
  final List<Node> arguments;

  const CompLeNode3({
    required super.name,
    required super.parameters,
    required this.arguments,
  });

  @override
  Node evaluate() {
    final Node a = arguments[0].evaluate();
    final Node b = arguments[1].evaluate();

    if ((a is NumberNode) && (b is NumberNode)) {
      return BooleanNode(a.value <= b.value);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
