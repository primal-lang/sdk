import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class OperatorAdd extends NativeFunctionPrototype {
  OperatorAdd()
      : super(
          name: '+',
          parameters: [
            Parameter.number('a'),
            Parameter.number('b'),
          ],
        );

  @override
  FunctionNode toNode() => OperatorAddNode2(
        name: name,
        parameters: parameters,
      );
}

class OperatorAddNode2 extends NativeFunctionNode {
  const OperatorAddNode2({
    required super.name,
    required super.parameters,
  });

  @override
  Node body(List<Node> arguments) => OperatorAddNode3(
        name: name,
        parameters: parameters,
        arguments: arguments,
      );
}

class OperatorAddNode3 extends FunctionNode {
  final List<Node> arguments;

  const OperatorAddNode3({
    required super.name,
    required super.parameters,
    required this.arguments,
  });

  @override
  Node evaluate() {
    final Node a = arguments[0].evaluate();
    final Node b = arguments[1].evaluate();

    if ((a is NumberNode) && (b is NumberNode)) {
      return NumberNode(a.value + b.value);
    } else if ((a is StringNode) && (b is StringNode)) {
      return StringNode(a.value + b.value);
    } else if ((a is ListNode) && (b is ListNode)) {
      return ListNode([...a.value, ...b.value]);
    } else if (a is ListNode) {
      return ListNode([...a.value, b]);
    } else if (b is ListNode) {
      return ListNode([a, ...b.value]);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
