import 'package:dry/compiler/errors/semantic_error.dart';
import 'package:dry/compiler/models/analyzer.dart';
import 'package:dry/compiler/semantic/intermediate_code.dart';
import 'package:dry/compiler/syntactic/function_definition.dart';

// unused parameter
// undecleared symbol
// invalid number of parameters
// mismatch types
// repeated parameter
class SemanticAnalyzer
    extends Analyzer<List<FunctionDefinition>, IntermediateCode> {
  const SemanticAnalyzer(super.input);

  @override
  IntermediateCode analyze() {
    checkRepeatedParameters(input);

    return const IntermediateCode(functions: {});
  }

  void checkRepeatedParameters(List<FunctionDefinition> functions) {
    for (final FunctionDefinition function in functions) {
      final Map<String, int> parameters = parametersCount(function);

      for (final MapEntry<String, int> entry in parameters.entries) {
        if (entry.value > 1) {
          throw SemanticError.repeatedParameter(function.name, entry.key);
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
}
