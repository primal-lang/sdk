import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class IsString extends NativeFunctionPrototype {
  IsString()
      : super(
          name: 'is.string',
          parameters: [
            Parameter.any('a'),
          ],
        );

  @override
  Node substitute(Scope<Node> arguments) {
    final Node a = arguments.get('a').evaluate();

    return BooleanNode(a is StringNode);
  }
}
