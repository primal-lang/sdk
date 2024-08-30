import 'package:primal/compiler/library/booleans/bool_or.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/reducible.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class OperatorOr extends NativeFunctionPrototype {
  OperatorOr()
      : super(
          name: '|',
          parameters: [
            Parameter.boolean('a'),
            Parameter.boolean('b'),
          ],
        );

  @override
  Reducible substitute(Scope<Reducible> arguments) =>
      BoolOr().substitute(arguments);
}
