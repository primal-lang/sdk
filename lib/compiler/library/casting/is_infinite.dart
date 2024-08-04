import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/reducible.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class IsInfinite extends NativeFunctionPrototype {
  IsInfinite()
      : super(
          name: 'isInfinite',
          parameters: [
            Parameter.any('x'),
          ],
        );

  @override
  Reducible substitute(Scope<Reducible> arguments) {
    final Reducible x = arguments.get('x').reduce();

    if (x is NumberReducibleValue) {
      return BooleanReducibleValue(x.value.isInfinite);
    } else {
      return const BooleanReducibleValue(false);
    }
  }
}
