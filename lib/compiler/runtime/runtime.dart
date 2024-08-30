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

  FunctionPrototype? get main => intermediateCode.functions['main'];

  bool get hasMain => main != null;

  String executeMain() => reduceFunction(main!);

  String reduce(Expression expression) {
    final FunctionPrototype function = AnonymousFunctionPrototype(
      reducible: expression.toReducible(),
    );

    return reduceFunction(function);
  }

  String reduceFunction(FunctionPrototype function) {
    final Reducible result = fullReduce(function.substitute(const Scope()));

    return result.toString();
  }

  Reducible fullReduce(Reducible reducible) {
    if (reducible is ListReducibleValue) {
      return ListReducibleValue(reducible.value.map(fullReduce).toList());
    } else {
      return reducible.reduce();
    }
  }
}
