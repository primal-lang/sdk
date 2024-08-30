import 'package:primal/compiler/library/comparison/comp_le.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/reducible.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class OperatorLe extends NativeFunctionPrototype {
  OperatorLe()
      : super(
          name: '<=',
          parameters: [
            Parameter.number('a'),
            Parameter.number('b'),
          ],
        );

  @override
  Reducible substitute(Scope<Reducible> arguments) =>
      CompLe().substitute(arguments);
}
