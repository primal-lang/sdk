import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/reducible.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class IsNumber extends NativeFunctionPrototype {
  IsNumber()
      : super(
          name: 'isNumber',
          parameters: [
            Parameter.any('x'),
          ],
        );

  @override
  Reducible substitute(Scope<Reducible> arguments) {
    final Reducible x = arguments.get('x').reduce();

    if (x is NumberReducibleValue) {
      return const BooleanReducibleValue(true);
    } else {
      return const BooleanReducibleValue(false);
    }
  }
}
