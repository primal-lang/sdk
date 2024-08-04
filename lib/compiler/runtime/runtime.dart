import 'package:primal/compiler/runtime/reducible.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';
import 'package:primal/compiler/semantic/intermediate_code.dart';
import 'package:primal/compiler/syntactic/expression.dart';

class Runtime {
  final IntermediateCode intermediateCode;

  // TODO(momo): pass it as a parameter
  static Scope SCOPE = const Scope();

  Runtime(this.intermediateCode) {
    SCOPE = Scope(intermediateCode.functions);
  }

  FunctionPrototype? get main {
    final FunctionPrototype? main = intermediateCode.functions['main/0'];

    return ((main != null) && main.parameters.isEmpty) ? main : null;
  }

  bool get hasMain => main != null;

  String executeMain() => reduceFunction(main!);

  String reduce(Expression expression) {
    final FunctionPrototype function = AnonymousFunctionPrototype(
      reducible: expression.toReducible(),
    );

    return reduceFunction(function);
  }

  String reduceFunction(FunctionPrototype function) {
    final Reducible result = function.substitute(const Scope()).reduce();

    return result.toString();
  }
}
