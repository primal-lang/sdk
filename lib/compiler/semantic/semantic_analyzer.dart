import 'package:dry/compiler/errors/semantic_error.dart';
import 'package:dry/compiler/models/analyzer.dart';
import 'package:dry/compiler/semantic/intermediate_code.dart';
import 'package:dry/compiler/syntactic/expression.dart';
import 'package:dry/compiler/syntactic/function_definition.dart';

// unused parameter
// undecleared symbol
// invalid number of parameters
// mismatch types
class SemanticAnalyzer
    extends Analyzer<List<FunctionDefinition>, IntermediateCode> {
  const SemanticAnalyzer(super.input);

  @override
  IntermediateCode analyze() {
    checkDuplicatedFunctions(input);
    checkRepeatedParameters(input);
    checkExpressions(input);

    return const IntermediateCode(functions: {});
  }

  void checkDuplicatedFunctions(List<FunctionDefinition> functions) {
    for (int i = 0; i < functions.length - 1; i++) {
      final FunctionDefinition function1 = functions[i];

      for (int j = i + 1; j < functions.length; j++) {
        final FunctionDefinition function2 = functions[j];

        if (function1.equalSignature(function2)) {
          throw SemanticError.duplicatedFunction(
            function1: function1,
            function2: function2,
          );
        }
      }
    }
  }

  void checkRepeatedParameters(List<FunctionDefinition> functions) {
    for (final FunctionDefinition function in functions) {
      final Map<String, int> parameters = parametersCount(function);

      for (final MapEntry<String, int> entry in parameters.entries) {
        if (entry.value > 1) {
          throw SemanticError.duplicatedParameter(
            function: function.name,
            parameter: entry.key,
          );
        }
      }
    }
  }

  Map<String, int> parametersCount(FunctionDefinition function) {
    final Map<String, int> result = {};

    for (final String parameter in function.parameters) {
      if (result.containsKey(parameter)) {
        result[parameter] = result[parameter]! + 1;
      } else {
        result[parameter] = 1;
      }
    }

    return result;
  }

  void checkExpressions(List<FunctionDefinition> functions) {
    for (final FunctionDefinition function in functions) {
      checkExpression(function.expression);
    }
  }

  void checkExpression(Expression expression) {}
}
