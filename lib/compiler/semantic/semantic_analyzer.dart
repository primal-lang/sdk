import 'package:dry/compiler/errors/semantic_error.dart';
import 'package:dry/compiler/models/analyzer.dart';
import 'package:dry/compiler/semantic/function_prototype.dart';
import 'package:dry/compiler/semantic/intermediate_code.dart';
import 'package:dry/compiler/syntactic/expression.dart';
import 'package:dry/compiler/syntactic/function_definition.dart';

class SemanticAnalyzer
    extends Analyzer<List<FunctionDefinition>, IntermediateCode> {
  const SemanticAnalyzer(super.input);

  @override
  IntermediateCode analyze() {
    final List<FunctionPrototype> functions = getPrototypes(input);
    addNativeFunctions(functions);

    checkDuplicatedFunctions(functions);
    checkRepeatedParameters(functions);
    checkExpressions(functions);

    // TODO(momo): check mismatched types

    return const IntermediateCode(functions: {});
  }

  // TODO(momo): add types to parameters
  List<FunctionPrototype> getPrototypes(List<FunctionDefinition> functions) {
    final List<FunctionPrototype> result = [];

    for (final FunctionDefinition function in functions) {
      result.add(FunctionPrototype(
        name: function.name,
        parameters: function.parameters,
        expression: function.expression,
      ));
    }

    return result;
  }

  void addNativeFunctions(List<FunctionPrototype> functions) {
    functions.add(const FunctionPrototype(
      name: 'gt',
      parameters: ['x', 'y'],
      expression: EmptyExpression(),
    ));
  }

  void checkDuplicatedFunctions(List<FunctionPrototype> functions) {
    for (int i = 0; i < functions.length - 1; i++) {
      final FunctionPrototype function1 = functions[i];

      for (int j = i + 1; j < functions.length; j++) {
        final FunctionPrototype function2 = functions[j];

        if (function1.equalSignature(function2)) {
          throw DuplicatedFunctionError(
            function1: function1,
            function2: function2,
          );
        }
      }
    }
  }

  void checkRepeatedParameters(List<FunctionPrototype> functions) {
    for (final FunctionPrototype function in functions) {
      final Map<String, int> parameters = parametersCount(function);

      for (final MapEntry<String, int> entry in parameters.entries) {
        if (entry.value > 1) {
          throw DuplicatedParameterError(
            function: function.name,
            parameter: entry.key,
          );
        }
      }
    }
  }

  Map<String, int> parametersCount(FunctionPrototype function) {
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

  void checkExpressions(List<FunctionPrototype> functions) {
    for (final FunctionPrototype function in functions) {
      final Set<String> usedParameters = {};
      checkExpression(
        expression: function.expression,
        availableParameters: function.parameters,
        usedParameters: usedParameters,
        functions: functions,
      );

      for (final String parameter in function.parameters) {
        if (!usedParameters.contains(parameter)) {
          throw UnusedParameterError(
            function: function.name,
            parameter: parameter,
          );
        }
      }
    }
  }

  void checkExpression({
    required Expression expression,
    required List<String> availableParameters,
    required Set<String> usedParameters,
    required List<FunctionPrototype> functions,
  }) {
    if (expression is SymbolExpression) {
      if (availableParameters.contains(expression.value)) {
        usedParameters.add(expression.value);
      } else {
        throw UndefinedSymbolError(
          symbol: expression.value,
          location: expression.location,
        );
      }
    } else if (expression is FunctionCallExpression) {
      final FunctionPrototype? function = getFunctionByName(
        name: expression.name,
        functions: functions,
      );

      if (function == null) {
        throw UndefinedFunctionError(
          function: expression.name,
          location: expression.location,
        );
      } else {
        if (function.parameters.length != expression.arguments.length) {
          throw InvalidNumberOfArgumentsError(
            function: expression.name,
            location: expression.location,
          );
        }
      }

      for (final Expression expression in expression.arguments) {
        checkExpression(
          expression: expression,
          availableParameters: availableParameters,
          usedParameters: usedParameters,
          functions: functions,
        );
      }
    }
  }

  FunctionPrototype? getFunctionByName({
    required String name,
    required List<FunctionPrototype> functions,
  }) {
    try {
      return functions.firstWhere((f) => f.name == name);
    } catch (e) {
      return null;
    }
  }
}
