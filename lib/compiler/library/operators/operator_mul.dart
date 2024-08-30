import 'package:primal/compiler/library/numbers/num_mul.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/reducible.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class OperatorMul extends NativeFunctionPrototype {
  OperatorMul()
      : super(
          name: '*',
          parameters: [
            Parameter.number('a'),
            Parameter.number('b'),
          ],
        );

  @override
  Reducible substitute(Scope<Reducible> arguments) =>
      NumMul().substitute(arguments);
}
