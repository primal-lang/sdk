import 'package:dry/compiler/models/parameter.dart';
import 'package:dry/compiler/runtime/reducible.dart';
import 'package:dry/compiler/runtime/scope.dart';
import 'package:dry/compiler/semantic/function_prototype.dart';

class IsString extends NativeFunctionPrototype {
  IsString()
      : super(
          name: 'isString',
          parameters: [
            Parameter.any('x'),
          ],
        );

  @override
  Reducible bind(Scope<Reducible> arguments) {
    final Reducible x = arguments.get('x').evaluate();

    if (x is StringReducibleValue) {
      return const BooleanReducibleValue(true);
    } else {
      return const BooleanReducibleValue(false);
    }
  }
}
