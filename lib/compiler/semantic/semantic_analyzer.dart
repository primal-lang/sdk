import 'package:primal/compiler/errors/semantic_error.dart';
import 'package:primal/compiler/library/standard_library.dart';
import 'package:primal/compiler/models/analyzer.dart';
import 'package:primal/compiler/models/function_signature.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/semantic/intermediate_representation.dart';
import 'package:primal/compiler/semantic/semantic_function.dart';
import 'package:primal/compiler/semantic/semantic_node.dart';
import 'package:primal/compiler/syntactic/expression.dart';
import 'package:primal/compiler/syntactic/function_definition.dart';
import 'package:primal/compiler/warnings/generic_warning.dart';
import 'package:primal/compiler/warnings/semantic_warning.dart';

class SemanticAnalyzer
    extends Analyzer<List<FunctionDefinition>, IntermediateRepresentation> {
  const SemanticAnalyzer(super.input);

  @override
  IntermediateRepresentation analyze() {
    final List<GenericWarning> warnings = [];

    // Get standard library signatures for semantic analysis
    final List<FunctionSignature> standardLibraryList =
        StandardLibrary.getSignatures();
    final Map<String, FunctionSignature> standardLibrarySignatures = {
      for (final FunctionSignature sig in standardLibraryList) sig.name: sig,
    };

    // First pass: extract function signatures and check for duplicates
    final Map<String, FunctionSignature> customSignatures = {};
    for (final FunctionDefinition function in input) {
      final FunctionSignature signature = FunctionSignature(
        name: function.name,
        parameters: function.parameters.map(Parameter.any).toList(),
      );

      // Check for duplicate custom function
      if (customSignatures.containsKey(function.name)) {
        throw DuplicatedFunctionError(
          function1: customSignatures[function.name]!,
          function2: signature,
        );
      }

      // Check for conflict with standard library
      if (standardLibrarySignatures.containsKey(function.name)) {
        throw DuplicatedFunctionError(
          function1: standardLibrarySignatures[function.name]!,
          function2: signature,
        );
      }

      customSignatures[function.name] = signature;
    }

    // Check for duplicate parameters
    _checkDuplicatedParameters(customSignatures.values);

    // Build combined signature map for lookups
    final Map<String, FunctionSignature> allSignatures = {
      ...standardLibrarySignatures,
      ...customSignatures,
    };

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
        allSignatures: allSignatures,
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

    return IntermediateRepresentation(
      customFunctions: customFunctions,
      standardLibrarySignatures: standardLibrarySignatures,
      warnings: warnings,
    );
  }

  void _checkDuplicatedParameters(Iterable<FunctionSignature> signatures) {
    for (final FunctionSignature signature in signatures) {
      final Set<String> seen = {};

      for (final Parameter parameter in signature.parameters) {
        if (seen.contains(parameter.name)) {
          throw DuplicatedParameterError(
            function: signature.name,
            parameter: parameter.name,
            parameters: signature.parameters.map((e) => e.name).toList(),
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
    required Map<String, FunctionSignature> allSignatures,
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
      allSignatures: allSignatures,
    ),
    MapExpression() => _checkMapExpression(
      expression: expression,
      currentFunction: currentFunction,
      availableParameters: availableParameters,
      usedParameters: usedParameters,
      allSignatures: allSignatures,
    ),
    IdentifierExpression() => _checkIdentifierExpression(
      expression: expression,
      currentFunction: currentFunction,
      availableParameters: availableParameters,
      usedParameters: usedParameters,
      allSignatures: allSignatures,
    ),
    CallExpression() => _checkCallExpression(
      expression: expression,
      currentFunction: currentFunction,
      availableParameters: availableParameters,
      usedParameters: usedParameters,
      allSignatures: allSignatures,
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
    required Map<String, FunctionSignature> allSignatures,
  }) {
    final List<SemanticNode> elements = expression.value
        .map(
          (e) => checkExpression(
            expression: e,
            currentFunction: currentFunction,
            availableParameters: availableParameters,
            usedParameters: usedParameters,
            allSignatures: allSignatures,
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
    required Map<String, FunctionSignature> allSignatures,
  }) {
    final List<SemanticMapEntryNode> entries = expression.value
        .map(
          (e) => SemanticMapEntryNode(
            key: checkExpression(
              expression: e.key,
              currentFunction: currentFunction,
              availableParameters: availableParameters,
              usedParameters: usedParameters,
              allSignatures: allSignatures,
            ),
            value: checkExpression(
              expression: e.value,
              currentFunction: currentFunction,
              availableParameters: availableParameters,
              usedParameters: usedParameters,
              allSignatures: allSignatures,
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
    required Map<String, FunctionSignature> allSignatures,
  }) {
    final String name = expression.value;

    if (availableParameters.contains(name)) {
      usedParameters.add(name);
      return SemanticBoundVariableNode(
        location: expression.location,
        name: name,
      );
    } else if (allSignatures.containsKey(name)) {
      return SemanticIdentifierNode(
        location: expression.location,
        name: name,
        resolvedSignature: allSignatures[name],
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
    required Map<String, FunctionSignature> allSignatures,
  }) {
    // First, recursively check all arguments
    final List<SemanticNode> checkedArguments = expression.arguments
        .map(
          (argument) => checkExpression(
            expression: argument,
            currentFunction: currentFunction,
            availableParameters: availableParameters,
            usedParameters: usedParameters,
            allSignatures: allSignatures,
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
        allSignatures: allSignatures,
      );
    } else {
      callee = checkExpression(
        expression: expression.callee,
        currentFunction: currentFunction,
        availableParameters: availableParameters,
        usedParameters: usedParameters,
        allSignatures: allSignatures,
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
    required Map<String, FunctionSignature> allSignatures,
  }) {
    final String functionName = callee.value;

    if (availableParameters.contains(functionName)) {
      usedParameters.add(functionName);
      return SemanticBoundVariableNode(
        location: callee.location,
        name: functionName,
      );
    } else if (allSignatures.containsKey(functionName)) {
      final FunctionSignature signature = allSignatures[functionName]!;

      if (signature.arity != expression.arguments.length) {
        throw InvalidNumberOfArgumentsError(
          function: functionName,
          expected: signature.arity,
          actual: expression.arguments.length,
        );
      }

      return SemanticIdentifierNode(
        location: callee.location,
        name: functionName,
        resolvedSignature: signature,
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
}
