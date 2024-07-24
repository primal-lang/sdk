import 'package:dry/compiler/runtime/reducible.dart';
import 'package:dry/compiler/runtime/scope.dart';
import 'package:dry/compiler/semantic/function_prototype.dart';
import 'package:dry/compiler/semantic/intermediate_code.dart';
import 'package:dry/compiler/syntactic/expression.dart';

class Runtime {
  final IntermediateCode intermediateCode;

  static Scope SCOPE = const Scope();

  Runtime(this.intermediateCode) {
    SCOPE = Scope(intermediateCode.functions);
  }

  FunctionPrototype? get main {
    final FunctionPrototype? main = intermediateCode.functions['main'];

    return ((main != null) && main.parameters.isEmpty) ? main : null;
  }

  bool get hasMain => main != null;

  String executeMain() => evaluateFunction(main!);

  String evaluate(Expression expression) {
    final FunctionPrototype function = AnonymousFunctionPrototype(
      reducible: expression.toReducible(),
    );

    return evaluateFunction(function);
  }

  String evaluateFunction(FunctionPrototype function) {
    final Reducible result = function.bind(const Scope()).evaluate();

    return result.toString();
  }
}
