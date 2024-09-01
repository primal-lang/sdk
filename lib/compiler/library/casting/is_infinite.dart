import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class IsInfinite extends NativeFunctionPrototype {
  IsInfinite()
      : super(
          name: 'is.infinite',
          parameters: [
            Parameter.any('a'),
          ],
        );

  @override
  Node substitute(Scope<Node> arguments) {
    final Node a = arguments.get('a').reduce();

    if (a is NumberNode) {
      return BooleanNode(a.value.isInfinite);
    } else {
      return const BooleanNode(false);
    }
  }
}
