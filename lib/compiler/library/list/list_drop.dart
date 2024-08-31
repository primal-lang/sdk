import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/reducible.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class ListDrop extends NativeFunctionPrototype {
  ListDrop()
      : super(
          name: 'list.drop',
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
      return ListReducibleValue(
          a.value.sublist(b.value.toInt(), a.value.length));
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
