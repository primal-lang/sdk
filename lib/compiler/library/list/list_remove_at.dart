import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/reducible.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class ListRemoveAt extends NativeFunctionPrototype {
  ListRemoveAt()
      : super(
          name: 'list.removeAt',
          parameters: [
            Parameter.list('a'),
            Parameter.number('b'),
          ],
        );

  @override
  Reducible substitute(Scope<Reducible> arguments) {
    final Reducible a = arguments.get('a').reduce();
    final Reducible b = arguments.get('b').reduce();

    if ((a is ListReducibleValue) && (b is NumberReducibleValue)) {
      return ListReducibleValue(a.value.sublist(0, b.value.toInt()) +
          a.value.sublist(b.value.toInt() + 1));
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
