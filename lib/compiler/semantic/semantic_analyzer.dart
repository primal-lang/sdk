import 'package:primal/compiler/errors/semantic_error.dart';
import 'package:primal/compiler/library/standard_library.dart';
import 'package:primal/compiler/models/analyzer.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
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

    final List<FunctionNode> standardLibrary = StandardLibrary.get();
    final List<CustomFunctionNode> customFunctions = getCustomFunctions(input);
    final List<FunctionNode> allFunctions = [
      ...customFunctions,
      ...standardLibrary,
    ];

    checkDuplicatedFunctions(allFunctions);
    checkDuplicatedParameters(allFunctions);

    final List<CustomFunctionNode> checkedFunctions = checkCustomFunctions(
      customFunctions: customFunctions,
      allFunctions: Mapper.toMap(allFunctions),
      warnings: warnings,
    );

    return IntermediateCode(
      functions: Mapper.toMap([
        ...checkedFunctions,
        ...standardLibrary,
      ]),
      warnings: warnings,
    );
  }

  List<CustomFunctionNode> getCustomFunctions(
    List<FunctionDefinition> functions,
  ) {
    final List<CustomFunctionNode> result = [];

    for (final FunctionDefinition function in functions) {
      result.add(
        CustomFunctionNode(
          name: function.name,
          parameters: function.parameters.map(Parameter.any).toList(),
          node: function.expression.toNode(),
        ),
      );
    }

    return result;
  }

  void checkDuplicatedFunctions(List<FunctionNode> functions) {
    final Map<String, FunctionNode> seen = {};

    for (final FunctionNode function in functions) {
      final String name = function.name;

      if (seen.containsKey(name)) {
        throw DuplicatedFunctionError(
          function1: seen[name]!,
          function2: function,
        );
      }

      seen[name] = function;
    }
  }

  void checkDuplicatedParameters(List<FunctionNode> functions) {
    for (final FunctionNode function in functions) {
      final Set<String> seen = {};

      for (final Parameter parameter in function.parameters) {
        if (seen.contains(parameter.name)) {
          throw DuplicatedParameterError(
            function: function.name,
            parameter: parameter.name,
            parameters: function.parameters.map((e) => e.name).toList(),
          );
        }

        seen.add(parameter.name);
      }
    }
  }

  List<CustomFunctionNode> checkCustomFunctions({
    required List<CustomFunctionNode> customFunctions,
    required Map<String, FunctionNode> allFunctions,
    required List<GenericWarning> warnings,
  }) {
    final List<CustomFunctionNode> result = [];

    for (final CustomFunctionNode function in customFunctions) {
      final Set<String> usedParameters = {};

      final Node node = checkNode(
        node: function.node,
        availableParameters: function.parameters.map((e) => e.name).toList(),
        usedParameters: usedParameters,
        allFunctions: allFunctions,
      );

      for (final Parameter parameter in function.parameters) {
        if (!usedParameters.contains(parameter.name)) {
          warnings.add(
            UnusedParameterWarning(
              function: function.name,
              parameter: parameter.name,
            ),
          );
        }
      }

      result.add(
        CustomFunctionNode(
          name: function.name,
          parameters: function.parameters,
          node: node,
        ),
      );
    }

    return result;
  }

  Node checkNode({
    required Node node,
    required List<String> availableParameters,
    required Set<String> usedParameters,
    required Map<String, FunctionNode> allFunctions,
  }) {
    if (node is IdentifierNode) {
      return checkVariableIdentifier(
        node: node,
        availableParameters: availableParameters,
        usedParameters: usedParameters,
        allFunctions: allFunctions,
      );
    } else if (node is CallNode) {
      Node callee = node.callee;

      // Check for non-callable literals (e.g., 5(1))
      if (_isNonCallableLiteral(callee)) {
        throw NotCallableError(callee.toString());
      }

      // Note: Arity checking only works for direct calls (e.g., foo(1, 2)).
      // Indirect calls (e.g., f()(x)) cannot be statically checked without
      // return type information and are validated at runtime instead.

      // Check for @ operator with non-indexable first argument (e.g., 5[0])
      if (callee is IdentifierNode &&
          callee.value == '@' &&
          node.arguments.isNotEmpty) {
        final Node target = node.arguments[0];
        if (_isNonIndexableLiteral(target)) {
          throw NotIndexableError(target.toString());
        }
      }

      if (callee is IdentifierNode) {
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

      for (final Node argument in node.arguments) {
        newArguments.add(
          checkNode(
            node: argument,
            availableParameters: availableParameters,
            usedParameters: usedParameters,
            allFunctions: allFunctions,
          ),
        );
      }

      return CallNode(
        callee: callee,
        arguments: newArguments,
      );
    } else if (node is ListNode) {
      final List<Node> elements = [];

      for (final Node node in node.value) {
        elements.add(
          checkNode(
            node: node,
            availableParameters: availableParameters,
            usedParameters: usedParameters,
            allFunctions: allFunctions,
          ),
        );
      }

      return ListNode(elements);
    } else if (node is MapNode) {
      final Map<Node, Node> elements = {};

      for (final MapEntry<Node, Node> entry in node.value.entries) {
        final Node key = checkNode(
          node: entry.key,
          availableParameters: availableParameters,
          usedParameters: usedParameters,
          allFunctions: allFunctions,
        );

        final Node value = checkNode(
          node: entry.value,
          availableParameters: availableParameters,
          usedParameters: usedParameters,
          allFunctions: allFunctions,
        );

        elements[key] = value;
      }

      return MapNode(elements);
    }

    return node;
  }

  Node checkVariableIdentifier({
    required IdentifierNode node,
    required List<String> availableParameters,
    required Set<String> usedParameters,
    required Map<String, FunctionNode> allFunctions,
  }) {
    if (availableParameters.contains(node.value)) {
      usedParameters.add(node.value);

      return BoundVariableNode(node.value);
    } else if (allFunctions.containsKey(node.value)) {
      return node;
    } else {
      throw UndefinedIdentifierError(node.value);
    }
  }

  Node checkCalleeIdentifier({
    required CallNode node,
    required IdentifierNode callee,
    required List<String> availableParameters,
    required Set<String> usedParameters,
    required Map<String, FunctionNode> allFunctions,
  }) {
    final String functionName = callee.value;

    if (availableParameters.contains(functionName)) {
      usedParameters.add(functionName);

      return BoundVariableNode(functionName);
    } else if (allFunctions.containsKey(functionName)) {
      final FunctionNode function = allFunctions[functionName]!;

      if (function.parameters.length != node.arguments.length) {
        throw InvalidNumberOfArgumentsError(functionName);
      }

      return callee;
    } else {
      throw UndefinedFunctionError(functionName);
    }
  }

  bool _isNonCallableLiteral(Node node) {
    return node is NumberNode ||
        node is BooleanNode ||
        node is StringNode ||
        node is ListNode ||
        node is MapNode;
  }

  bool _isNonIndexableLiteral(Node node) {
    return node is NumberNode || node is BooleanNode;
  }
}
