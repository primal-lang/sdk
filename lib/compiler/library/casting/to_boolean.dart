import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/reducible.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class ToBoolean extends NativeFunctionPrototype {
  ToBoolean()
      : super(
          name: 'toBoolean',
          parameters: [
            Parameter.any('a'),
          ],
        );

  @override
  Reducible substitute(Scope<Reducible> arguments) {
    final Reducible a = arguments.get('a').reduce();

    if (a is StringReducibleValue) {
      return BooleanReducibleValue(a.value.trim().isNotEmpty);
    } else if (a is NumberReducibleValue) {
      return BooleanReducibleValue(a.value != 0);
    } else if (a is BooleanReducibleValue) {
      return BooleanReducibleValue(a.value);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
