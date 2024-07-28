import 'package:dry/compiler/models/parameter.dart';
import 'package:dry/compiler/runtime/reducible.dart';
import 'package:dry/compiler/runtime/scope.dart';
import 'package:dry/compiler/semantic/function_prototype.dart';

class Try extends NativeFunctionPrototype {
  Try()
      : super(
          name: 'try',
          parameters: [
            Parameter.any('x'),
            Parameter.any('y'),
          ],
        );

  @override
  Reducible substitute(Scope<Reducible> arguments) {
    final Reducible x = arguments.get('x');
    final Reducible y = arguments.get('y');

    try {
      return x.reduce();
    } catch (e) {
      return y;
    }
  }
}
