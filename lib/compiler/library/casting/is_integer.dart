/*import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class IsInteger extends NativeFunctionPrototype {
  IsInteger()
      : super(
          name: 'is.integer',
          parameters: [
            Parameter.any('a'),
          ],
        );

  @override
  Node substitute(Scope<Node> arguments) {
    final Node a = arguments.get('a').evaluate();

    if (a is NumberNode) {
      return BooleanNode(a.value is int);
    } else {
      return const BooleanNode(false);
    }
  }
}
*/