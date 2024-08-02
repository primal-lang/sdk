import 'package:purified/compiler/models/parameter.dart';
import 'package:purified/compiler/runtime/reducible.dart';
import 'package:purified/compiler/runtime/scope.dart';
import 'package:purified/compiler/semantic/function_prototype.dart';

class IsDecimal extends NativeFunctionPrototype {
  IsDecimal()
      : super(
          name: 'isDecimal',
          parameters: [
            Parameter.any('x'),
          ],
        );

  @override
  Reducible substitute(Scope<Reducible> arguments) {
    final Reducible x = arguments.get('x').reduce();

    if (x is NumberReducibleValue) {
      return BooleanReducibleValue(x.value != x.value.toInt());
    } else {
      return const BooleanReducibleValue(false);
    }
  }
}
