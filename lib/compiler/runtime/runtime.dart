import 'package:primal/compiler/compiler.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/intermediate_code.dart';
import 'package:primal/compiler/syntactic/expression.dart';

class Runtime {
  final IntermediateCode intermediateCode;

  // TODO(momo): pass it as a parameter
  static Scope SCOPE = const Scope();

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
    /*final Node result = function.substitute(const Scope()).evaluate();

    return fullReduce(result).toString();*/

    return '';
  }

  Node fullReduce(Node node) {
    if (node is ListNode) {
      return ListNode(node.value.map(fullReduce).toList());
    } else if (node is StringNode) {
      return StringNode('"${node.value}"');
    } else {
      return node.evaluate();
    }
  }
}
