import 'package:dry/compiler/errors/semantic_error.dart';
import 'package:dry/compiler/library/standard_library.dart';
import 'package:dry/compiler/models/analyzer.dart';
import 'package:dry/compiler/models/parameter.dart';
import 'package:dry/compiler/models/type.dart';
import 'package:dry/compiler/semantic/function_prototype.dart';
import 'package:dry/compiler/semantic/intermediate_code.dart';
import 'package:dry/compiler/syntactic/expression.dart';
import 'package:dry/compiler/syntactic/function_definition.dart';
import 'package:dry/compiler/warnings/generic_warning.dart';
import 'package:dry/compiler/warnings/semantic_warning.dart';

class SemanticAnalyzer
    extends Analyzer<List<FunctionDefinition>, IntermediateCode> {
  const SemanticAnalyzer(super.input);

  @override
  IntermediateCode analyze() {
    final List<GenericWarning> warnings = [];
    final List<FunctionPrototype> functions = getPrototypes(input);
    addNativeFunctions(functions);

    checkDuplicatedFunctions(functions);
    checkDuplicatedParameters(functions);

    final List<CustomFunctionPrototype> customFunctions =
        functions.whereType<CustomFunctionPrototype>().toList();
    checkExpressions(
      customFunctions: customFunctions,
      allFunctions: functions,
      warnings: warnings,
    );

    // TODO(momo): check mismatched types

    return IntermediateCode(
      functions: {},
      warnings: warnings,
    );
  }

  List<FunctionPrototype> getPrototypes(List<FunctionDefinition> functions) {
    final List<FunctionPrototype> result = [];

    for (final FunctionDefinition function in functions) {
      result.add(CustomFunctionPrototype(
        name: function.name,
        parameters: function.parameters
            .map((e) => Parameter(name: e, type: const AnyType()))
            .toList(),
        expression: function.expression,
      ));
    }

    return result;
  }

  void addNativeFunctions(List<FunctionPrototype> functions) {
    functions.add(const Gt());
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

  void checkDuplicatedParameters(List<FunctionPrototype> functions) {
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

    for (final Parameter parameter in function.parameters) {
      if (result.containsKey(parameter.name)) {
        result[parameter.name] = result[parameter.name]! + 1;
      } else {
        result[parameter.name] = 1;
      }
    }

    return result;
  }

  void checkExpressions({
    required List<CustomFunctionPrototype> customFunctions,
    required List<FunctionPrototype> allFunctions,
    required List<GenericWarning> warnings,
  }) {
    for (final CustomFunctionPrototype function in customFunctions) {
      final Set<String> usedParameters = {};
      checkExpression(
        expression: function.expression,
        availableParameters: function.parameters.map((e) => e.name).toList(),
        usedParameters: usedParameters,
        allFunctions: allFunctions,
      );

      for (final Parameter parameter in function.parameters) {
        if (!usedParameters.contains(parameter.name)) {
          warnings.add(UnusedParameterWarning(
            function: function.name,
            parameter: parameter.name,
          ));
        }
      }
    }
  }

  void checkExpression({
    required Expression expression,
    required List<String> availableParameters,
    required Set<String> usedParameters,
    required List<FunctionPrototype> allFunctions,
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
        functions: allFunctions,
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
          allFunctions: allFunctions,
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
