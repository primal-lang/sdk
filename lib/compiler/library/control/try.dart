/*import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class Try extends NativeFunctionPrototype {
  Try()
      : super(
          name: 'try',
          parameters: [
            Parameter.any('a'),
            Parameter.any('b'),
          ],
        );

  @override
  Node substitute(Scope<Node> arguments) {
    final Node a = arguments.get('a');
    final Node b = arguments.get('b');

    try {
      return a.evaluate();
    } catch (e) {
      return b;
    }
  }
}
*/