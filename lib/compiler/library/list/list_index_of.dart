import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/library/comparison/comp_eq.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/reducible.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class ListIndexOf extends NativeFunctionPrototype {
  ListIndexOf()
      : super(
          name: 'list.indexOf',
          parameters: [
            Parameter.list('a'),
            Parameter.any('b'),
          ],
        );

  @override
  Reducible substitute(Scope<Reducible> arguments) {
    final Reducible a = arguments.get('a').reduce();
    final Reducible b = arguments.get('b').reduce();

    if (a is ListReducibleValue) {
      final CompEq eq = CompEq();

      for (int i = 0; i < a.value.length; i++) {
        final Reducible element = a.value[i];
        final Reducible comparison = eq.compare(element.reduce(), b);

        if (comparison is BooleanReducibleValue && comparison.value) {
          return NumberReducibleValue(i);
        }
      }

      return const NumberReducibleValue(-1);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
