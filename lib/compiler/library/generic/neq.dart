import 'package:dry/compiler/errors/runtime_error.dart';
import 'package:dry/compiler/models/parameter.dart';
import 'package:dry/compiler/runtime/reducible.dart';
import 'package:dry/compiler/runtime/scope.dart';
import 'package:dry/compiler/semantic/function_prototype.dart';

class Neq extends NativeFunctionPrototype {
  Neq()
      : super(
          name: 'neq',
          parameters: [
            Parameter.any('x'),
            Parameter.any('y'),
          ],
        );

  @override
  Reducible bind(Scope<Reducible> arguments) {
    final Reducible x = arguments.get('x').evaluate();
    final Reducible y = arguments.get('y').evaluate();

    if ((x is NumberReducibleValue) && (y is NumberReducibleValue)) {
      return BooleanReducibleValue(x.value != y.value);
    } else if ((x is StringReducibleValue) && (y is StringReducibleValue)) {
      return BooleanReducibleValue(x.value != y.value);
    } else if ((x is BooleanReducibleValue) && (y is BooleanReducibleValue)) {
      return BooleanReducibleValue(x.value != y.value);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameters.map((e) => e.type.toString()).toList(),
        actual: [x.type, y.type],
      );
    }
  }
}
