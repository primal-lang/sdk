import 'dart:math';
import 'package:dry/compiler/errors/runtime_error.dart';
import 'package:dry/compiler/models/parameter.dart';
import 'package:dry/compiler/runtime/reducible.dart';
import 'package:dry/compiler/runtime/scope.dart';
import 'package:dry/compiler/semantic/function_prototype.dart';

class Sin extends NativeFunctionPrototype {
  Sin()
      : super(
          name: 'sin',
          parameters: [
            Parameter.number('x'),
          ],
        );

  @override
  Reducible bind(Scope<Reducible> arguments) {
    final Reducible x = arguments.get('x').evaluate();

    if (x is NumberReducibleValue) {
      return NumberReducibleValue(sin(x.value));
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameters.map((e) => e.type.toString()).toList(),
        actual: [x.type],
      );
    }
  }
}
