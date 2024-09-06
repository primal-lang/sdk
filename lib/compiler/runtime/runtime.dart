import 'package:primal/compiler/compiler.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/intermediate_code.dart';
import 'package:primal/compiler/syntactic/expression.dart';

class Runtime {
  final IntermediateCode intermediateCode;

  // TODO(momo): pass it as a parameter
  static Scope<FunctionNode> SCOPE = const Scope();

  Runtime(this.intermediateCode) {
    SCOPE = Scope(intermediateCode.functions);
  }

  bool get hasMain => intermediateCode.functions.containsKey('main');

  String executeMain() {
    const Compiler compiler = Compiler();
    final Expression expression = compiler.expression('main()');

    return evaluate(expression);
  }

  String evaluate(Expression expression) {
    // TODO(momo): evaluate expression semantically before executing it
    final Node node = expression.toNode();

    return fullReduce(node).toString();
  }

  Node fullReduce(Node node) {
    if (node is ListNode) {
      return ListNode(node.value.map(fullReduce).toList());
    } else if (node is StringNode) {
      return StringNode('"${node.value}"');
    } else if (node is CallNode) {
      return fullReduce(node.evaluate());
    } else {
      return node;
    }
  }
}
