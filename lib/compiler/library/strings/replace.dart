import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/reducible.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class Replace extends NativeFunctionPrototype {
  Replace()
      : super(
          name: 'str.replace',
          parameters: [
            Parameter.string('a'),
            Parameter.string('b'),
            Parameter.string('c'),
          ],
        );

  @override
  Reducible substitute(Scope<Reducible> arguments) {
    final Reducible a = arguments.get('a').reduce();
    final Reducible b = arguments.get('b').reduce();
    final Reducible c = arguments.get('c').reduce();

    if ((a is StringReducibleValue) &&
        (b is StringReducibleValue) &&
        (c is StringReducibleValue)) {
      return StringReducibleValue(a.value.replaceAll(b.value, c.value));
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type, c.type],
      );
    }
  }
}
