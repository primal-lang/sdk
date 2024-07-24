import 'package:dry/compiler/errors/runtime_error.dart';
import 'package:dry/compiler/models/parameter.dart';
import 'package:dry/compiler/runtime/reducible.dart';
import 'package:dry/compiler/runtime/scope.dart';
import 'package:dry/compiler/semantic/function_prototype.dart';

class Error extends NativeFunctionPrototype {
  Error()
      : super(
          name: 'error',
          parameters: [
            Parameter.any('x'),
          ],
        );

  @override
  Reducible bind(Scope<Reducible> arguments) {
    final Reducible x = arguments.get('x').evaluate();

    throw RuntimeError(x.toString());
  }
}
