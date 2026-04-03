import 'package:primal/compiler/errors/semantic_error.dart';
import 'package:primal/compiler/library/standard_library.dart';
import 'package:primal/compiler/models/analyzer.dart';
import 'package:primal/compiler/models/location.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/semantic/intermediate_code.dart';
import 'package:primal/compiler/semantic/lowerer.dart';
import 'package:primal/compiler/semantic/semantic_function.dart';
import 'package:primal/compiler/semantic/semantic_node.dart';
import 'package:primal/compiler/syntactic/expression.dart';
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
    const Lowerer lowerer = Lowerer();

    final SemanticNode semanticNode = analyzer.checkNode(
      node: node,
      currentFunction: '<expression>',
      availableParameters: {},
      usedParameters: {},
      allFunctions: functions,
    );

    return lowerer.lowerNode(semanticNode);
  }

  @override
  IntermediateCode analyze() {
    final List<GenericWarning> warnings = [];

    final List<FunctionNode> standardLibrary = StandardLibrary.get();
    final Map<String, FunctionNode> standardLibraryMap = Mapper.toMap(
      standardLibrary,
    );

    // First pass: extract function signatures for forward reference resolution
    final Map<String, _FunctionSignature> customSignatures = {};
    for (final FunctionDefinition function in input) {
      customSignatures[function.name] = _FunctionSignature(
        name: function.name,
        parameters: function.parameters.map(Parameter.any).toList(),
      );
    }

    // Build combined function map for lookups (signatures + stdlib)
    final Map<String, FunctionNode> allFunctions = {
      ...standardLibraryMap,
      // Add placeholder FunctionNodes for custom functions to enable lookups
      for (final sig in customSignatures.values)
        sig.name: FunctionNode(name: sig.name, parameters: sig.parameters),
    };

    // Check for duplicates
    _checkDuplicatedFunctions(input, standardLibrary);
    _checkDuplicatedParameters(customSignatures.values);

    // Second pass: semantic analysis producing SemanticFunction
    final Map<String, SemanticFunction> customFunctions = {};
    for (final FunctionDefinition function in input) {
      final Set<String> usedParameters = {};
      final Set<String> availableParameters = function.parameters.toSet();

      final SemanticNode body = checkExpression(
        expression: function.expression,
        currentFunction: function.name,
        availableParameters: availableParameters,
        usedParameters: usedParameters,
        allFunctions: allFunctions,
      );

      // Check for unused parameters
      for (final String parameter in function.parameters) {
        if (!usedParameters.contains(parameter)) {
          warnings.add(
            UnusedParameterWarning(
              function: function.name,
              parameter: parameter,
            ),
          );
        }
      }

      customFunctions[function.name] = SemanticFunction(
        name: function.name,
        parameters: function.parameters.map(Parameter.any).toList(),
        body: body,
        location: function.expression.location,
      );
    }

    return IntermediateCode(
      customFunctions: customFunctions,
      standardLibrary: standardLibraryMap,
      warnings: warnings,
    );
  }

  void _checkDuplicatedFunctions(
    List<FunctionDefinition> customFunctions,
    List<FunctionNode> standardLibrary,
  ) {
    final Set<String> seen = {};

    // Check custom functions against each other
    for (final FunctionDefinition function in customFunctions) {
      if (seen.contains(function.name)) {
        throw DuplicatedFunctionError(
          function1: FunctionNode(name: function.name, parameters: []),
          function2: FunctionNode(name: function.name, parameters: []),
        );
      }
      seen.add(function.name);
    }

    // Check custom functions against standard library
    for (final FunctionNode function in standardLibrary) {
      if (seen.contains(function.name)) {
        throw DuplicatedFunctionError(
          function1: FunctionNode(name: function.name, parameters: []),
          function2: function,
        );
      }
    }
  }

  void _checkDuplicatedParameters(Iterable<_FunctionSignature> functions) {
    for (final _FunctionSignature function in functions) {
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

  /// Converts an [Expression] to a [SemanticNode], performing semantic checks.
  SemanticNode checkExpression({
    required Expression expression,
    required String currentFunction,
    required Set<String> availableParameters,
    required Set<String> usedParameters,
    required Map<String, FunctionNode> allFunctions,
  }) => switch (expression) {
    BooleanExpression() => SemanticBooleanNode(
      location: expression.location,
      value: expression.value,
    ),
    NumberExpression() => SemanticNumberNode(
      location: expression.location,
      value: expression.value,
    ),
    StringExpression() => SemanticStringNode(
      location: expression.location,
      value: expression.value,
    ),
    ListExpression() => _checkListExpression(
      expression: expression,
      currentFunction: currentFunction,
      availableParameters: availableParameters,
      usedParameters: usedParameters,
      allFunctions: allFunctions,
    ),
    MapExpression() => _checkMapExpression(
      expression: expression,
      currentFunction: currentFunction,
      availableParameters: availableParameters,
      usedParameters: usedParameters,
      allFunctions: allFunctions,
    ),
    IdentifierExpression() => _checkIdentifierExpression(
      expression: expression,
      currentFunction: currentFunction,
      availableParameters: availableParameters,
      usedParameters: usedParameters,
      allFunctions: allFunctions,
    ),
    CallExpression() => _checkCallExpression(
      expression: expression,
      currentFunction: currentFunction,
      availableParameters: availableParameters,
      usedParameters: usedParameters,
      allFunctions: allFunctions,
    ),
    _ => throw StateError(
      'Unexpected expression type in semantic analysis: ${expression.runtimeType}',
    ),
  };

  SemanticNode _checkListExpression({
    required ListExpression expression,
    required String currentFunction,
    required Set<String> availableParameters,
    required Set<String> usedParameters,
    required Map<String, FunctionNode> allFunctions,
  }) {
    final List<SemanticNode> elements = expression.value
        .map(
          (e) => checkExpression(
            expression: e,
            currentFunction: currentFunction,
            availableParameters: availableParameters,
            usedParameters: usedParameters,
            allFunctions: allFunctions,
          ),
        )
        .toList();

    return SemanticListNode(
      location: expression.location,
      value: elements,
    );
  }

  SemanticNode _checkMapExpression({
    required MapExpression expression,
    required String currentFunction,
    required Set<String> availableParameters,
    required Set<String> usedParameters,
    required Map<String, FunctionNode> allFunctions,
  }) {
    final List<SemanticMapEntryNode> entries = expression.value
        .map(
          (e) => SemanticMapEntryNode(
            key: checkExpression(
              expression: e.key,
              currentFunction: currentFunction,
              availableParameters: availableParameters,
              usedParameters: usedParameters,
              allFunctions: allFunctions,
            ),
            value: checkExpression(
              expression: e.value,
              currentFunction: currentFunction,
              availableParameters: availableParameters,
              usedParameters: usedParameters,
              allFunctions: allFunctions,
            ),
          ),
        )
        .toList();

    return SemanticMapNode(
      location: expression.location,
      value: entries,
    );
  }

  SemanticNode _checkIdentifierExpression({
    required IdentifierExpression expression,
    required String currentFunction,
    required Set<String> availableParameters,
    required Set<String> usedParameters,
    required Map<String, FunctionNode> allFunctions,
  }) {
    final String name = expression.value;

    if (availableParameters.contains(name)) {
      usedParameters.add(name);
      return SemanticBoundVariableNode(
        location: expression.location,
        name: name,
      );
    } else if (allFunctions.containsKey(name)) {
      return SemanticIdentifierNode(
        location: expression.location,
        name: name,
        resolvedFunction: allFunctions[name],
      );
    } else {
      throw UndefinedIdentifierError(
        identifier: name,
        inFunction: currentFunction,
      );
    }
  }

  SemanticNode _checkCallExpression({
    required CallExpression expression,
    required String currentFunction,
    required Set<String> availableParameters,
    required Set<String> usedParameters,
    required Map<String, FunctionNode> allFunctions,
  }) {
    // First, recursively check all arguments
    final List<SemanticNode> checkedArguments = expression.arguments
        .map(
          (arg) => checkExpression(
            expression: arg,
            currentFunction: currentFunction,
            availableParameters: availableParameters,
            usedParameters: usedParameters,
            allFunctions: allFunctions,
          ),
        )
        .toList();

    // Check for non-callable literals (e.g., 5(1))
    if (_isNonCallableLiteral(expression.callee)) {
      throw NotCallableError(
        value: expression.callee.toString(),
        type: _literalTypeName(expression.callee),
      );
    }

    // Check for @ operator with non-indexable first argument (e.g., 5[0])
    if (expression.callee is IdentifierExpression &&
        (expression.callee as IdentifierExpression).value == '@' &&
        checkedArguments.isNotEmpty) {
      final Expression target = expression.arguments[0];
      if (_isNonIndexableLiteral(target)) {
        throw NotIndexableError(
          value: expression.arguments[0].toString(),
          type: _literalTypeName(target),
        );
      }
    }

    // Check the callee
    SemanticNode callee;
    if (expression.callee is IdentifierExpression) {
      callee = _checkCalleeIdentifier(
        expression: expression,
        callee: expression.callee as IdentifierExpression,
        currentFunction: currentFunction,
        availableParameters: availableParameters,
        usedParameters: usedParameters,
        allFunctions: allFunctions,
      );
    } else {
      callee = checkExpression(
        expression: expression.callee,
        currentFunction: currentFunction,
        availableParameters: availableParameters,
        usedParameters: usedParameters,
        allFunctions: allFunctions,
      );
    }

    return SemanticCallNode(
      location: expression.location,
      callee: callee,
      arguments: checkedArguments,
    );
  }

  SemanticNode _checkCalleeIdentifier({
    required CallExpression expression,
    required IdentifierExpression callee,
    required String currentFunction,
    required Set<String> availableParameters,
    required Set<String> usedParameters,
    required Map<String, FunctionNode> allFunctions,
  }) {
    final String functionName = callee.value;

    if (availableParameters.contains(functionName)) {
      usedParameters.add(functionName);
      return SemanticBoundVariableNode(
        location: callee.location,
        name: functionName,
      );
    } else if (allFunctions.containsKey(functionName)) {
      final FunctionNode function = allFunctions[functionName]!;

      if (function.parameters.length != expression.arguments.length) {
        throw InvalidNumberOfArgumentsError(
          function: functionName,
          expected: function.parameters.length,
          actual: expression.arguments.length,
        );
      }

      return SemanticIdentifierNode(
        location: callee.location,
        name: functionName,
        resolvedFunction: function,
      );
    } else {
      throw UndefinedFunctionError(
        function: functionName,
        inFunction: currentFunction,
      );
    }
  }

  bool _isNonCallableLiteral(Expression expression) {
    return expression is NumberExpression ||
        expression is BooleanExpression ||
        expression is StringExpression ||
        expression is ListExpression ||
        expression is MapExpression;
  }

  bool _isNonIndexableLiteral(Expression expression) {
    return expression is NumberExpression || expression is BooleanExpression;
  }

  String _literalTypeName(Expression expression) {
    if (expression is NumberExpression) {
      return 'number';
    } else if (expression is BooleanExpression) {
      return 'boolean';
    } else if (expression is StringExpression) {
      return 'string';
    } else if (expression is ListExpression) {
      return 'list';
    } else if (expression is MapExpression) {
      return 'map';
    }
    return 'unknown';
  }

  /// Validates a runtime [Node] against available functions.
  ///
  /// This is used by [validateExpression] to check ad-hoc expressions
  /// that were already converted to runtime nodes.
  SemanticNode checkNode({
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
    IdentifierNode() => _checkIdentifierNode(
      node: node,
      currentFunction: currentFunction,
      availableParameters: availableParameters,
      usedParameters: usedParameters,
      allFunctions: allFunctions,
    ),
    CallNode() => _checkCallNode(
      node: node,
      currentFunction: currentFunction,
      availableParameters: availableParameters,
      usedParameters: usedParameters,
      allFunctions: allFunctions,
    ),
    ListNode() => _checkListNode(
      node: node,
      currentFunction: currentFunction,
      availableParameters: availableParameters,
      usedParameters: usedParameters,
      allFunctions: allFunctions,
    ),
    MapNode() => _checkMapNode(
      node: node,
      currentFunction: currentFunction,
      availableParameters: availableParameters,
      usedParameters: usedParameters,
      allFunctions: allFunctions,
    ),
    // Literals contain no identifiers and need no checking
    BooleanNode() => SemanticBooleanNode(
      location: _syntheticLocation,
      value: node.value,
    ),
    NumberNode() => SemanticNumberNode(
      location: _syntheticLocation,
      value: node.value,
    ),
    StringNode() => SemanticStringNode(
      location: _syntheticLocation,
      value: node.value,
    ),
    _ => throw StateError(
      'Unexpected node type in semantic analysis: ${node.runtimeType}',
    ),
  };

  SemanticNode _checkIdentifierNode({
    required IdentifierNode node,
    required String currentFunction,
    required Set<String> availableParameters,
    required Set<String> usedParameters,
    required Map<String, FunctionNode> allFunctions,
  }) {
    if (availableParameters.contains(node.value)) {
      usedParameters.add(node.value);
      return SemanticBoundVariableNode(
        location: _syntheticLocation,
        name: node.value,
      );
    } else if (allFunctions.containsKey(node.value)) {
      return SemanticIdentifierNode(
        location: _syntheticLocation,
        name: node.value,
        resolvedFunction: allFunctions[node.value],
      );
    } else {
      throw UndefinedIdentifierError(
        identifier: node.value,
        inFunction: currentFunction,
      );
    }
  }

  SemanticNode _checkCallNode({
    required CallNode node,
    required String currentFunction,
    required Set<String> availableParameters,
    required Set<String> usedParameters,
    required Map<String, FunctionNode> allFunctions,
  }) {
    // Check all arguments first
    final List<SemanticNode> checkedArguments = node.arguments
        .map(
          (arg) => checkNode(
            node: arg,
            currentFunction: currentFunction,
            availableParameters: availableParameters,
            usedParameters: usedParameters,
            allFunctions: allFunctions,
          ),
        )
        .toList();

    // Check for non-callable literals
    if (_isNonCallableNode(node.callee)) {
      throw NotCallableError(
        value: node.callee.toString(),
        type: _nodeTypeName(node.callee),
      );
    }

    // Check for @ operator with non-indexable first argument
    if (node.callee is IdentifierNode &&
        (node.callee as IdentifierNode).value == '@' &&
        checkedArguments.isNotEmpty) {
      final Node target = node.arguments[0];
      if (_isNonIndexableNode(target)) {
        throw NotIndexableError(
          value: node.arguments[0].toString(),
          type: _nodeTypeName(target),
        );
      }
    }

    // Check the callee - special handling for identifier callees
    SemanticNode callee;
    if (node.callee is IdentifierNode) {
      callee = _checkCalleeIdentifierNode(
        node: node,
        callee: node.callee as IdentifierNode,
        currentFunction: currentFunction,
        availableParameters: availableParameters,
        usedParameters: usedParameters,
        allFunctions: allFunctions,
      );
    } else {
      callee = checkNode(
        node: node.callee,
        currentFunction: currentFunction,
        availableParameters: availableParameters,
        usedParameters: usedParameters,
        allFunctions: allFunctions,
      );
    }

    return SemanticCallNode(
      location: _syntheticLocation,
      callee: callee,
      arguments: checkedArguments,
    );
  }

  SemanticNode _checkCalleeIdentifierNode({
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
      return SemanticBoundVariableNode(
        location: _syntheticLocation,
        name: functionName,
      );
    } else if (allFunctions.containsKey(functionName)) {
      final FunctionNode function = allFunctions[functionName]!;

      if (function.parameters.length != node.arguments.length) {
        throw InvalidNumberOfArgumentsError(
          function: functionName,
          expected: function.parameters.length,
          actual: node.arguments.length,
        );
      }

      return SemanticIdentifierNode(
        location: _syntheticLocation,
        name: functionName,
        resolvedFunction: function,
      );
    } else {
      throw UndefinedFunctionError(
        function: functionName,
        inFunction: currentFunction,
      );
    }
  }

  SemanticNode _checkListNode({
    required ListNode node,
    required String currentFunction,
    required Set<String> availableParameters,
    required Set<String> usedParameters,
    required Map<String, FunctionNode> allFunctions,
  }) {
    final List<SemanticNode> elements = node.value
        .map(
          (e) => checkNode(
            node: e,
            currentFunction: currentFunction,
            availableParameters: availableParameters,
            usedParameters: usedParameters,
            allFunctions: allFunctions,
          ),
        )
        .toList();

    return SemanticListNode(
      location: _syntheticLocation,
      value: elements,
    );
  }

  SemanticNode _checkMapNode({
    required MapNode node,
    required String currentFunction,
    required Set<String> availableParameters,
    required Set<String> usedParameters,
    required Map<String, FunctionNode> allFunctions,
  }) {
    final List<SemanticMapEntryNode> entries = [];

    for (final MapEntry<Node, Node> entry in node.value.entries) {
      entries.add(
        SemanticMapEntryNode(
          key: checkNode(
            node: entry.key,
            currentFunction: currentFunction,
            availableParameters: availableParameters,
            usedParameters: usedParameters,
            allFunctions: allFunctions,
          ),
          value: checkNode(
            node: entry.value,
            currentFunction: currentFunction,
            availableParameters: availableParameters,
            usedParameters: usedParameters,
            allFunctions: allFunctions,
          ),
        ),
      );
    }

    return SemanticMapNode(
      location: _syntheticLocation,
      value: entries,
    );
  }

  bool _isNonCallableNode(Node node) {
    return node is NumberNode ||
        node is BooleanNode ||
        node is StringNode ||
        node is ListNode ||
        node is MapNode;
  }

  bool _isNonIndexableNode(Node node) {
    return node is NumberNode || node is BooleanNode;
  }

  String _nodeTypeName(Node node) {
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

/// Synthetic location for nodes created from runtime Node (no source info).
const _syntheticLocation = Location(row: 0, column: 0);

/// Internal helper for tracking function signatures during analysis.
class _FunctionSignature {
  final String name;
  final List<Parameter> parameters;

  const _FunctionSignature({
    required this.name,
    required this.parameters,
  });
}
