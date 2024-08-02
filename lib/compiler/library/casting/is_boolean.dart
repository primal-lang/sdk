import 'package:purified/compiler/models/parameter.dart';
import 'package:purified/compiler/runtime/reducible.dart';
import 'package:purified/compiler/runtime/scope.dart';
import 'package:purified/compiler/semantic/function_prototype.dart';

class IsBoolean extends NativeFunctionPrototype {
  IsBoolean()
      : super(
          name: 'isBoolean',
          parameters: [
            Parameter.any('x'),
          ],
        );

  @override
  Reducible substitute(Scope<Reducible> arguments) {
    final Reducible x = arguments.get('x').reduce();

    if (x is BooleanReducibleValue) {
      return const BooleanReducibleValue(true);
    } else {
      return const BooleanReducibleValue(false);
    }
  }
}
