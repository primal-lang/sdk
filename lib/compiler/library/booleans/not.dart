import 'package:dry/compiler/errors/runtime_error.dart';
import 'package:dry/compiler/models/parameter.dart';
import 'package:dry/compiler/runtime/reducible.dart';
import 'package:dry/compiler/runtime/scope.dart';
import 'package:dry/compiler/semantic/function_prototype.dart';

class Not extends NativeFunctionPrototype {
  Not()
      : super(
          name: 'not',
          parameters: [
            Parameter.boolean('x'),
          ],
        );

  @override
  Reducible substitute(Scope<Reducible> arguments) {
    final Reducible x = arguments.get('x').evaluate();

    if (x is BooleanReducibleValue) {
      return BooleanReducibleValue(!x.value);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [x.type],
      );
    }
  }
}
