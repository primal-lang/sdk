import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';
import 'package:primal/compiler/semantic/intermediate_code.dart';
import 'package:primal/compiler/syntactic/expression.dart';

class Runtime {
  final IntermediateCode intermediateCode;

  // TODO(momo): pass it as a parameter
  static Scope SCOPE = const Scope();

  Runtime(this.intermediateCode) {
    SCOPE = Scope(intermediateCode.functions);
  }

  FunctionPrototype? get main => intermediateCode.functions['main'];

  bool get hasMain => main != null;

  String executeMain() => reduceFunction(main!);

  String reduce(Expression expression) {
    final FunctionPrototype function = AnonymousFunctionPrototype(
      node: expression.toNode(),
    );

    return reduceFunction(function);
  }

  String reduceFunction(FunctionPrototype function) {
    final Node result = function.substitute(const Scope()).reduce();

    return fullReduce(result).toString();
  }

  Node fullReduce(Node node) {
    if (node is ListNode) {
      return ListNode(node.value.map(fullReduce).toList());
    } else if (node is StringNode) {
      return StringNode('"${node.value}"');
    } else {
      return node.reduce();
    }
  }
}
