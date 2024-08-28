import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/reducible.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class IsString extends NativeFunctionPrototype {
  IsString()
      : super(
          name: 'is.string',
          parameters: [
            Parameter.any('a'),
          ],
        );

  @override
  Reducible substitute(Scope<Reducible> arguments) {
    final Reducible a = arguments.get('a').reduce();

    if (a is StringReducibleValue) {
      return const BooleanReducibleValue(true);
    } else {
      return const BooleanReducibleValue(false);
    }
  }
}
