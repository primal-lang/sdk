import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/reducible.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class ListSwap extends NativeFunctionPrototype {
  ListSwap()
      : super(
          name: 'list.swap',
          parameters: [
            Parameter.list('a'),
            Parameter.number('b'),
            Parameter.number('c'),
          ],
        );

  @override
  Reducible substitute(Scope<Reducible> arguments) {
    final Reducible a = arguments.get('a').reduce();
    final Reducible b = arguments.get('b').reduce();
    final Reducible c = arguments.get('c').reduce();

    if ((a is ListReducibleValue) &&
        (b is NumberReducibleValue) &&
        (c is NumberReducibleValue)) {
      final List<Reducible> result = [];
      final Reducible valueAtB = a.value[b.value.toInt()];
      final Reducible valueAtC = a.value[c.value.toInt()];

      for (int i = 0; i < a.value.length; i++) {
        final Reducible element = a.value[i];

        if (i == b.value.toInt()) {
          result.add(valueAtC);
        } else if (i == c.value.toInt()) {
          result.add(valueAtB);
        } else {
          result.add(element);
        }
      }

      return ListReducibleValue(result);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
