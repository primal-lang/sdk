import 'package:primal/compiler/errors/semantic_error.dart';
import 'package:primal/compiler/library/standard_library.dart';
import 'package:primal/compiler/models/analyzer.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
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

    final List<CustomFunctionPrototype> customFunctions =
        getCustomFunctions(input);
    final List<FunctionPrototype> allFunctions = [
      ...customFunctions,
      ...StandardLibrary.get(),
    ];

    checkDuplicatedFunctions(allFunctions);
    checkDuplicatedParameters(allFunctions);

    final List<CustomFunctionPrototype> checkedFunctions = checkCustomFunctions(
      customFunctions: customFunctions,
      allFunctions: Mapper.toMap(allFunctions),
      warnings: warnings,
    );

    return IntermediateCode(
      functions: Mapper.toMap([
        ...checkedFunctions,
        ...StandardLibrary.get(),
      ]),
      warnings: warnings,
    );
  }

  List<CustomFunctionPrototype> getCustomFunctions(
      List<FunctionDefinition> functions) {
    final List<CustomFunctionPrototype> result = [];

    for (final FunctionDefinition function in functions) {
      result.add(CustomFunctionPrototype(
        name: function.name,
        parameters: function.parameters.map(Parameter.any).toList(),
        node: function.expression!.toNode(),
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

  List<CustomFunctionPrototype> checkCustomFunctions({
    required List<CustomFunctionPrototype> customFunctions,
    required Map<String, FunctionPrototype> allFunctions,
    required List<GenericWarning> warnings,
  }) {
    final List<CustomFunctionPrototype> result = [];

    for (final CustomFunctionPrototype function in customFunctions) {
      final Set<String> usedParameters = {};

      final Node node = checkNode(
        node: function.node,
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

      result.add(function.withNode(node));
    }

    return result;
  }

  Node checkNode({
    required Node node,
    required List<String> availableParameters,
    required Set<String> usedParameters,
    required Map<String, FunctionPrototype> allFunctions,
  }) {
    if (node is BoundedVariableNode) {
      return checkVariableIdentifier(
        node: node,
        availableParameters: availableParameters,
        usedParameters: usedParameters,
        allFunctions: allFunctions,
      );
    } else if (node is CallNode) {
      Node callee = node.callee;

      if (callee is BoundedVariableNode) {
        callee = checkCalleeIdentifier(
          node: node,
          callee: callee,
          availableParameters: availableParameters,
          usedParameters: usedParameters,
          allFunctions: allFunctions,
        );
      } else if (callee is CallNode) {
        callee = checkNode(
          node: callee,
          availableParameters: availableParameters,
          usedParameters: usedParameters,
          allFunctions: allFunctions,
        );
      }

      final List<Node> newArguments = [];

      for (final Node node in node.arguments) {
        newArguments.add(checkNode(
          node: node,
          availableParameters: availableParameters,
          usedParameters: usedParameters,
          allFunctions: allFunctions,
        ));
      }

      return CallNode(
        callee: callee,
        arguments: newArguments,
      );
    }

    return node;
  }

  Node checkVariableIdentifier({
    required BoundedVariableNode node,
    required List<String> availableParameters,
    required Set<String> usedParameters,
    required Map<String, FunctionPrototype> allFunctions,
  }) {
    if (availableParameters.contains(node.value)) {
      usedParameters.add(node.value);

      return BoundedVariableNode(node.value);
    } else if (allFunctions.containsKey(node.value)) {
      return node;
    } else {
      throw UndefinedIdentifierError(node.value);
    }
  }

  Node checkCalleeIdentifier({
    required CallNode node,
    required BoundedVariableNode callee,
    required List<String> availableParameters,
    required Set<String> usedParameters,
    required Map<String, FunctionPrototype> allFunctions,
  }) {
    final String functionName = callee.value;

    if (availableParameters.contains(functionName)) {
      usedParameters.add(functionName);

      return BoundedVariableNode(functionName);
    } else if (allFunctions.containsKey(functionName)) {
      final FunctionPrototype function = allFunctions[functionName]!;

      if (function.parameters.length != node.arguments.length) {
        throw InvalidNumberOfArgumentsError(functionName);
      }

      return callee;
    } else {
      throw UndefinedFunctionError(functionName);
    }
  }
}
