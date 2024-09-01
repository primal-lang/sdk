import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class ToString extends NativeFunctionPrototype {
  ToString()
      : super(
          name: 'to.string',
          parameters: [
            Parameter.any('a'),
          ],
        );

  @override
  Node substitute(Scope<Node> arguments) {
    final Node a = arguments.get('a').evaluate();

    if (a is StringNode) {
      return StringNode(a.value);
    } else {
      return StringNode(a.toString());
    }
  }
}
