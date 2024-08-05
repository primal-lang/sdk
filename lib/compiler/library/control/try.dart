import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/reducible.dart';
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
  Reducible substitute(Scope<Reducible> arguments) {
    final Reducible a = arguments.get('a');
    final Reducible b = arguments.get('b');

    try {
      return a.reduce();
    } catch (e) {
      return b;
    }
  }
}
