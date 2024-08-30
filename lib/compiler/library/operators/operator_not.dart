import 'package:primal/compiler/library/booleans/bool_not.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/reducible.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class OperatorNot extends NativeFunctionPrototype {
  OperatorNot()
      : super(
          name: '!',
          parameters: [
            Parameter.boolean('a'),
          ],
        );

  @override
  Reducible substitute(Scope<Reducible> arguments) =>
      BoolNot().substitute(arguments);
}
