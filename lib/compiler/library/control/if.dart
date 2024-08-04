import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/reducible.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class If extends NativeFunctionPrototype {
  If()
      : super(
          name: 'if',
          parameters: [
            Parameter.boolean('x'),
            Parameter.any('y'),
            Parameter.any('z'),
          ],
        );

  @override
  Reducible substitute(Scope<Reducible> arguments) {
    final Reducible x = arguments.get('x').reduce();
    final Reducible y = arguments.get('y');
    final Reducible z = arguments.get('z');

    if (x is BooleanReducibleValue) {
      if (x.value) {
        return y;
      } else {
        return z;
      }
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [x.type, y.type, z.type],
      );
    }
  }
}
