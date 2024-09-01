import 'package:primal/compiler/errors/semantic_error.dart';
import 'package:primal/compiler/library/standard_library.dart';
import 'package:primal/compiler/models/analyzer.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/reducible.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';
import 'package:primal/compiler/semantic/intermediate_code.dart';
import 'package:primal/compiler/syntactic/function_definition.dart';
import 'package:primal/compiler/warnings/generic_warning.dart';
import 'package:primal/compiler/warnings/semantic_warning.dart';
import 'package:primal/utils/mapper.dart';

class SemanticAnalyzer
    extends Analyzer<List<FunctionDefinition>, IntermediateCode> {
  const SemanticAnalyzer(super.input);

  @override
  IntermediateCode analyze() {
    final List<GenericWarning> warnings = [];
    final List<FunctionPrototype> functions = getPrototypes(input);
    functions.addAll(StandardLibrary.get());

    checkDuplicatedFunctions(functions);
    checkDuplicatedParameters(functions);

    final List<CustomFunctionPrototype> customFunctions =
        functions.whereType<CustomFunctionPrototype>().toList();
    checkReducibles(
      customFunctions: customFunctions,
      allFunctions: functions,
      warnings: warnings,
    );

    return IntermediateCode(
      functions: Mapper.toMap(functions),
      warnings: warnings,
    );
  }

  List<FunctionPrototype> getPrototypes(List<FunctionDefinition> functions) {
    final List<FunctionPrototype> result = [];

    for (final FunctionDefinition function in functions) {
      result.add(CustomFunctionPrototype(
        name: function.name,
        parameters: function.parameters.map(Parameter.any).toList(),
        reducible: function.expression!.toReducible(),
      ));
    }

    return result;
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
            parameters: function.parameters.map((e) => e.name).toList(),
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

  void checkReducibles({
    required List<CustomFunctionPrototype> customFunctions,
    required List<FunctionPrototype> allFunctions,
    required List<GenericWarning> warnings,
  }) {
    for (final CustomFunctionPrototype function in customFunctions) {
      final Set<String> usedParameters = {};
      checkReducible(
        reducible: function.reducible,
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

  void checkReducible({
    required Reducible reducible,
    required List<String> availableParameters,
    required Set<String> usedParameters,
    required List<FunctionPrototype> allFunctions,
  }) {
    if (reducible is IdentifierReducible) {
      if (availableParameters.contains(reducible.value)) {
        usedParameters.add(reducible.value);
      } else if (!allFunctions.any((f) => f.name == reducible.value)) {
        throw UndefinedIdentifiersError(
          identifier: reducible.value,
          location: reducible.location,
        );
      }
    } else if (reducible is CallReducible) {
      final FunctionPrototype? function = getFunctionByName(
        name: reducible.name,
        functions: allFunctions,
      );

      if (function == null) {
        throw UndefinedFunctionError(
          function: reducible.name,
          location: reducible.location,
        );
      } else {
        if (function.parameters.length != reducible.arguments.length) {
          throw InvalidNumberOfArgumentsError(
            function: reducible.name,
            location: reducible.location,
          );
        }
      }

      for (final Reducible reducible in reducible.arguments) {
        checkReducible(
          reducible: reducible,
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
