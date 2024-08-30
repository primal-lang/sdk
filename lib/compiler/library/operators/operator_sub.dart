import 'package:primal/compiler/library/numbers/num_sub.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/reducible.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class OperatorSub extends NativeFunctionPrototype {
  OperatorSub()
      : super(
          name: '-',
          parameters: [
            Parameter.number('a'),
            Parameter.number('b'),
          ],
        );

  @override
  Reducible substitute(Scope<Reducible> arguments) =>
      NumSub().substitute(arguments);
}
