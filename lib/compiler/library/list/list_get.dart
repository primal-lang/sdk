import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/reducible.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class ListGet extends NativeFunctionPrototype {
  ListGet()
      : super(
          name: 'list.get',
          parameters: [
            Parameter.list('a'),
            Parameter.number('b'),
          ],
        );

  @override
  Reducible substitute(Scope<Reducible> arguments) {
    final Reducible a = arguments.get('a');
    final Reducible b = arguments.get('b').reduce();

    if ((a is ListReducibleValue) && (b is NumberReducibleValue)) {
      final dynamic value = a.value[b.value.toInt()];

      if (value is String) {
        return StringReducibleValue(value);
      } else if (value is num) {
        return NumberReducibleValue(value);
      } else if (value is bool) {
        return BooleanReducibleValue(value);
      } else if (value is List) {
        return ListReducibleValue(value);
      } else {
        throw RuntimeError('Unsupported type: ${value.runtimeType}');
      }
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
