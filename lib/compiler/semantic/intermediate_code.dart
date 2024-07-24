import 'package:dry/compiler/models/reducible.dart';
import 'package:dry/compiler/models/scope.dart';
import 'package:dry/compiler/semantic/function_prototype.dart';
import 'package:dry/compiler/syntactic/expression.dart';
import 'package:dry/compiler/warnings/generic_warning.dart';

class IntermediateCode {
  final Map<String, FunctionPrototype> functions;
  final List<GenericWarning> warnings;

  static Scope SCOPE = const Scope();

  IntermediateCode({
    required this.functions,
    required this.warnings,
  }) {
    SCOPE = Scope(functions);
  }

  FunctionPrototype? get main {
    final FunctionPrototype? main = functions['main'];

    return ((main != null) && main.parameters.isEmpty) ? main : null;
  }

  bool get hasMain => main != null;

  String executeMain() {
    final Reducible result = main!.bind(const Scope()).evaluate();

    return result.toString();
  }

  String evaluate(Expression expression) {
    final FunctionPrototype function =
        AnonymousFunctionPrototype(reducible: expression.toReducible());
    final Reducible result = function.bind(const Scope()).evaluate();

    return result.toString();
  }

  factory IntermediateCode.empty() => IntermediateCode(
        functions: {},
        warnings: [],
      );
}
