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

  /// Validates an expression node against available functions.
  /// Used by [Runtime.evaluate] to ensure ad-hoc expressions undergo
  /// the same semantic checks as compiled top-level functions.
  static Node validateExpression(
    Node node,
    Map<String, FunctionNode> functions,
  ) {
    const SemanticAnalyzer analyzer = SemanticAnalyzer([]);

    return analyzer.checkNode(
      node: node,
      currentFunction: '<expression>',
      availableParameters: {},
      usedParameters: {},
      allFunctions: functions,
    );
  }

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
        currentFunction: function.name,
        availableParameters: function.parameters.map((e) => e.name).toSet(),
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
    required String currentFunction,
    required Set<String> availableParameters,
    required Set<String> usedParameters,
    required Map<String, FunctionNode> allFunctions,
  }) => switch (node) {
    // BoundVariableNode must come before IdentifierNode since it extends it
    BoundVariableNode() => throw StateError(
      'BoundVariableNode should not exist before semantic analysis',
    ),
    IdentifierNode() => _checkIdentifier(
      node: node,
      currentFunction: currentFunction,
      availableParameters: availableParameters,
      usedParameters: usedParameters,
      allFunctions: allFunctions,
    ),
    CallNode() => _checkCall(
      node: node,
      currentFunction: currentFunction,
      availableParameters: availableParameters,
      usedParameters: usedParameters,
      allFunctions: allFunctions,
    ),
    ListNode() => _checkList(
      node: node,
      currentFunction: currentFunction,
      availableParameters: availableParameters,
      usedParameters: usedParameters,
      allFunctions: allFunctions,
    ),
    MapNode() => _checkMap(
      node: node,
      currentFunction: currentFunction,
      availableParameters: availableParameters,
      usedParameters: usedParameters,
      allFunctions: allFunctions,
    ),
    // Literals contain no identifiers and need no checking
    BooleanNode() || NumberNode() || StringNode() => node,
    _ => throw StateError(
      'Unexpected node type in semantic analysis: ${node.runtimeType}',
    ),
  };

  Node _checkIdentifier({
    required IdentifierNode node,
    required String currentFunction,
    required Set<String> availableParameters,
    required Set<String> usedParameters,
    required Map<String, FunctionNode> allFunctions,
  }) {
    if (availableParameters.contains(node.value)) {
      usedParameters.add(node.value);
      return BoundVariableNode(node.value);
    } else if (allFunctions.containsKey(node.value)) {
      return node;
    } else {
      throw UndefinedIdentifierError(
        identifier: node.value,
        inFunction: currentFunction,
      );
    }
  }

  Node _checkCall({
    required CallNode node,
    required String currentFunction,
    required Set<String> availableParameters,
    required Set<String> usedParameters,
    required Map<String, FunctionNode> allFunctions,
  }) {
    // `callee` holds the checked/transformed callee for the output CallNode.
    // Literal checks below use `node.callee` (the original) to detect shape errors.
    Node callee = node.callee;

    // First, recursively check callee if it's a CallNode to surface nested errors
    if (callee is CallNode) {
      callee = checkNode(
        node: callee,
        currentFunction: currentFunction,
        availableParameters: availableParameters,
        usedParameters: usedParameters,
        allFunctions: allFunctions,
      );
    }

    // Next, recursively check all arguments to surface nested errors
    final List<Node> newArguments = node.arguments
        .map(
          (argument) => checkNode(
            node: argument,
            currentFunction: currentFunction,
            availableParameters: availableParameters,
            usedParameters: usedParameters,
            allFunctions: allFunctions,
          ),
        )
        .toList();

    // Check for non-callable literals (e.g., 5(1))
    if (_isNonCallableLiteral(node.callee)) {
      throw NotCallableError(
        value: node.callee.toString(),
        type: _literalTypeName(node.callee),
      );
    }

    // Note: Arity checking only works for direct calls (e.g., foo(1, 2)).
    // Indirect calls (e.g., f()(x)) cannot be statically checked without
    // return type information and are validated at runtime instead.

    // Check for @ operator with non-indexable first argument (e.g., 5[0])
    if (node.callee is IdentifierNode &&
        (node.callee as IdentifierNode).value == '@' &&
        newArguments.isNotEmpty) {
      final Node target = newArguments[0];
      if (_isNonIndexableLiteral(target)) {
        throw NotIndexableError(
          value: node.arguments[0].toString(),
          type: _literalTypeName(target),
        );
      }
    }

    // Finally, check callee identifier for validity and arity
    if (node.callee is IdentifierNode) {
      callee = _checkCalleeIdentifier(
        node: node,
        callee: node.callee as IdentifierNode,
        currentFunction: currentFunction,
        availableParameters: availableParameters,
        usedParameters: usedParameters,
        allFunctions: allFunctions,
      );
    }

    return CallNode(
      callee: callee,
      arguments: newArguments,
    );
  }

  Node _checkList({
    required ListNode node,
    required String currentFunction,
    required Set<String> availableParameters,
    required Set<String> usedParameters,
    required Map<String, FunctionNode> allFunctions,
  }) {
    final List<Node> elements = node.value
        .map(
          (element) => checkNode(
            node: element,
            currentFunction: currentFunction,
            availableParameters: availableParameters,
            usedParameters: usedParameters,
            allFunctions: allFunctions,
          ),
        )
        .toList();

    return ListNode(elements);
  }

  Node _checkMap({
    required MapNode node,
    required String currentFunction,
    required Set<String> availableParameters,
    required Set<String> usedParameters,
    required Map<String, FunctionNode> allFunctions,
  }) {
    final Map<Node, Node> elements = {};

    for (final MapEntry<Node, Node> entry in node.value.entries) {
      final Node key = checkNode(
        node: entry.key,
        currentFunction: currentFunction,
        availableParameters: availableParameters,
        usedParameters: usedParameters,
        allFunctions: allFunctions,
      );

      final Node value = checkNode(
        node: entry.value,
        currentFunction: currentFunction,
        availableParameters: availableParameters,
        usedParameters: usedParameters,
        allFunctions: allFunctions,
      );

      elements[key] = value;
    }

    return MapNode(elements);
  }

  Node _checkCalleeIdentifier({
    required CallNode node,
    required IdentifierNode callee,
    required String currentFunction,
    required Set<String> availableParameters,
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
        throw InvalidNumberOfArgumentsError(
          function: functionName,
          expected: function.parameters.length,
          actual: node.arguments.length,
        );
      }

      return callee;
    } else {
      throw UndefinedFunctionError(
        function: functionName,
        inFunction: currentFunction,
      );
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

  String _literalTypeName(Node node) {
    if (node is NumberNode) {
      return 'number';
    } else if (node is BooleanNode) {
      return 'boolean';
    } else if (node is StringNode) {
      return 'string';
    } else if (node is ListNode) {
      return 'list';
    } else if (node is MapNode) {
      return 'map';
    }
    return 'unknown';
  }
}
