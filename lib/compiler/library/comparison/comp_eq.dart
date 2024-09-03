import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class CompEq extends NativeFunctionPrototype {
  CompEq()
      : super(
          name: 'comp.eq',
          parameters: [
            Parameter.any('a'),
            Parameter.any('b'),
          ],
        );

  @override
  FunctionNode toNode() => CompEqNode2(
        name: name,
        parameters: parameters,
      );
}

class CompEqNode2 extends NativeFunctionNode {
  const CompEqNode2({
    required super.name,
    required super.parameters,
  });

  @override
  Node body(List<Node> arguments) => CompEqNode3(
        name: name,
        parameters: parameters,
        arguments: arguments,
      );
}

class CompEqNode3 extends FunctionNode {
  final List<Node> arguments;

  const CompEqNode3({
    required super.name,
    required super.parameters,
    required this.arguments,
  });

  @override
  Node evaluate() {
    final Node a = arguments[0].evaluate();
    final Node b = arguments[1].evaluate();

    return compare(a, b);
  }

  Node compare(Node a, Node b) {
    if ((a is NumberNode) && (b is NumberNode)) {
      return BooleanNode(a.value == b.value);
    } else if ((a is StringNode) && (b is StringNode)) {
      return BooleanNode(a.value == b.value);
    } else if ((a is BooleanNode) && (b is BooleanNode)) {
      return BooleanNode(a.value == b.value);
    } else if ((a is ListNode) && (b is ListNode)) {
      if (a.value.length != b.value.length) {
        return const BooleanNode(false);
      } else {
        for (int i = 0; i < a.value.length; i++) {
          final Node comparison = compare(
            a.value[i].evaluate(),
            b.value[i].evaluate(),
          );

          if (comparison is BooleanNode && !comparison.value) {
            return const BooleanNode(false);
          }
        }

        return const BooleanNode(true);
      }
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
