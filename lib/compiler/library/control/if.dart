import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class If extends NativeFunctionPrototype {
  If()
      : super(
          name: 'if',
          parameters: [
            Parameter.boolean('a'),
            Parameter.any('b'),
            Parameter.any('c'),
          ],
        );

  @override
  FunctionNode toNode() => IfNode2(
        name: name,
        parameters: parameters,
      );
}

class IfNode2 extends NativeFunctionNode {
  const IfNode2({
    required super.name,
    required super.parameters,
  });

  @override
  Node body(List<Node> arguments) => IfNode3(
        name: name,
        parameters: parameters,
        arguments: arguments,
      );
}

class IfNode3 extends FunctionNode {
  final List<Node> arguments;

  const IfNode3({
    required super.name,
    required super.parameters,
    required this.arguments,
  });

  @override
  Node evaluate() {
    final Node a = arguments[0].evaluate();
    final Node b = arguments[1];
    final Node c = arguments[2];

    if (a is BooleanNode) {
      if (a.value) {
        return b;
      } else {
        return c;
      }
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type, c.type],
      );
    }
  }
}
