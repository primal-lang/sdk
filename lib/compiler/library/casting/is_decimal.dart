import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/reducible.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class IsDecimal extends NativeFunctionPrototype {
  IsDecimal()
      : super(
          name: 'isDecimal',
          parameters: [
            Parameter.any('a'),
          ],
        );

  @override
  Reducible substitute(Scope<Reducible> arguments) {
    final Reducible a = arguments.get('a').reduce();

    if (a is NumberReducibleValue) {
      return BooleanReducibleValue(a.value != a.value.toInt());
    } else {
      return const BooleanReducibleValue(false);
    }
  }
}
