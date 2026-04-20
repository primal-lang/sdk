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
      final Set<String> usedLambdaParameters = {};
      final Set<String> availableParameters = function.parameters.toSet();

      final SemanticNode body = checkExpression(
        expression: function.expression,
        currentFunction: function.name,
        availableParameters: availableParameters,
        usedParameters: usedParameters,
        letBindingNames: {},
        lambdaParameterNames: {},
        usedLambdaParameters: usedLambdaParameters,
        warnings: warnings,
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
        parameters: customSignatures[function.name]!.parameters,
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
  ///
  /// The [currentFunction] parameter is optional and is used for error messages.
  /// When null (e.g., in REPL mode), error messages omit the function context.
  ///
  /// The [letBindingNames] parameter tracks which names in [availableParameters]
  /// are let bindings rather than function parameters, to set [isLetBinding]
  /// on [SemanticBoundVariableNode] and exclude let bindings from unused
  /// parameter warnings.
  ///
  /// The [lambdaParameterNames] parameter tracks which names in [availableParameters]
  /// are lambda parameters, to set [isLambdaParameter] on [SemanticBoundVariableNode].
  ///
  /// The [usedLambdaParameters] parameter tracks which lambda parameters have been
  /// used, for unused lambda parameter warnings.
  ///
  /// The [warnings] parameter collects semantic warnings during analysis.
  SemanticNode checkExpression({
    required Expression expression,
    required String? currentFunction,
    required Set<String> availableParameters,
    required Set<String> usedParameters,
    required Set<String> letBindingNames,
    required Set<String> lambdaParameterNames,
    required Set<String> usedLambdaParameters,
    required List<GenericWarning> warnings,
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
      letBindingNames: letBindingNames,
      lambdaParameterNames: lambdaParameterNames,
      usedLambdaParameters: usedLambdaParameters,
      warnings: warnings,
      allSignatures: allSignatures,
    ),
    MapExpression() => _checkMapExpression(
      expression: expression,
      currentFunction: currentFunction,
      availableParameters: availableParameters,
      usedParameters: usedParameters,
      letBindingNames: letBindingNames,
      lambdaParameterNames: lambdaParameterNames,
      usedLambdaParameters: usedLambdaParameters,
      warnings: warnings,
      allSignatures: allSignatures,
    ),
    IdentifierExpression() => _checkIdentifierExpression(
      expression: expression,
      currentFunction: currentFunction,
      availableParameters: availableParameters,
      usedParameters: usedParameters,
      letBindingNames: letBindingNames,
      lambdaParameterNames: lambdaParameterNames,
      usedLambdaParameters: usedLambdaParameters,
      allSignatures: allSignatures,
    ),
    CallExpression() => _checkCallExpression(
      expression: expression,
      currentFunction: currentFunction,
      availableParameters: availableParameters,
      usedParameters: usedParameters,
      letBindingNames: letBindingNames,
      lambdaParameterNames: lambdaParameterNames,
      usedLambdaParameters: usedLambdaParameters,
      warnings: warnings,
      allSignatures: allSignatures,
    ),
    LetExpression() => _checkLetExpression(
      expression: expression,
      currentFunction: currentFunction,
      availableParameters: availableParameters,
      usedParameters: usedParameters,
      letBindingNames: letBindingNames,
      lambdaParameterNames: lambdaParameterNames,
      usedLambdaParameters: usedLambdaParameters,
      warnings: warnings,
      allSignatures: allSignatures,
    ),
    LambdaExpression() => _checkLambdaExpression(
      expression: expression,
      currentFunction: currentFunction,
      availableParameters: availableParameters,
      usedParameters: usedParameters,
      letBindingNames: letBindingNames,
      lambdaParameterNames: lambdaParameterNames,
      usedLambdaParameters: usedLambdaParameters,
      warnings: warnings,
      allSignatures: allSignatures,
    ),
    _ => throw StateError(
      'Unexpected expression type in semantic analysis: ${expression.runtimeType}',
    ),
  };

  SemanticNode _checkListExpression({
    required ListExpression expression,
    required String? currentFunction,
    required Set<String> availableParameters,
    required Set<String> usedParameters,
    required Set<String> letBindingNames,
    required Set<String> lambdaParameterNames,
    required Set<String> usedLambdaParameters,
    required List<GenericWarning> warnings,
    required Map<String, FunctionSignature> allSignatures,
  }) {
    final List<SemanticNode> elements = expression.value
        .map(
          (element) => checkExpression(
            expression: element,
            currentFunction: currentFunction,
            availableParameters: availableParameters,
            usedParameters: usedParameters,
            letBindingNames: letBindingNames,
            lambdaParameterNames: lambdaParameterNames,
            usedLambdaParameters: usedLambdaParameters,
            warnings: warnings,
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
    required String? currentFunction,
    required Set<String> availableParameters,
    required Set<String> usedParameters,
    required Set<String> letBindingNames,
    required Set<String> lambdaParameterNames,
    required Set<String> usedLambdaParameters,
    required List<GenericWarning> warnings,
    required Map<String, FunctionSignature> allSignatures,
  }) {
    final List<SemanticMapEntryNode> entries = expression.value
        .map(
          (entry) => SemanticMapEntryNode(
            key: checkExpression(
              expression: entry.key,
              currentFunction: currentFunction,
              availableParameters: availableParameters,
              usedParameters: usedParameters,
              letBindingNames: letBindingNames,
              lambdaParameterNames: lambdaParameterNames,
              usedLambdaParameters: usedLambdaParameters,
              warnings: warnings,
              allSignatures: allSignatures,
            ),
            value: checkExpression(
              expression: entry.value,
              currentFunction: currentFunction,
              availableParameters: availableParameters,
              usedParameters: usedParameters,
              letBindingNames: letBindingNames,
              lambdaParameterNames: lambdaParameterNames,
              usedLambdaParameters: usedLambdaParameters,
              warnings: warnings,
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
    required String? currentFunction,
    required Set<String> availableParameters,
    required Set<String> usedParameters,
    required Set<String> letBindingNames,
    required Set<String> lambdaParameterNames,
    required Set<String> usedLambdaParameters,
    required Map<String, FunctionSignature> allSignatures,
  }) {
    final String name = expression.value;

    if (availableParameters.contains(name)) {
      final bool isLetBinding = letBindingNames.contains(name);
      final bool isLambdaParameter = lambdaParameterNames.contains(name);

      // Track usage for function parameters and lambda parameters
      if (isLambdaParameter) {
        usedLambdaParameters.add(name);
      } else if (!isLetBinding) {
        usedParameters.add(name);
      }

      return SemanticBoundVariableNode(
        location: expression.location,
        name: name,
        isLetBinding: isLetBinding,
        isLambdaParameter: isLambdaParameter,
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
    required String? currentFunction,
    required Set<String> availableParameters,
    required Set<String> usedParameters,
    required Set<String> letBindingNames,
    required Set<String> lambdaParameterNames,
    required Set<String> usedLambdaParameters,
    required List<GenericWarning> warnings,
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
            letBindingNames: letBindingNames,
            lambdaParameterNames: lambdaParameterNames,
            usedLambdaParameters: usedLambdaParameters,
            warnings: warnings,
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
        letBindingNames: letBindingNames,
        lambdaParameterNames: lambdaParameterNames,
        usedLambdaParameters: usedLambdaParameters,
        allSignatures: allSignatures,
      );
    } else {
      callee = checkExpression(
        expression: expression.callee,
        currentFunction: currentFunction,
        availableParameters: availableParameters,
        usedParameters: usedParameters,
        letBindingNames: letBindingNames,
        lambdaParameterNames: lambdaParameterNames,
        usedLambdaParameters: usedLambdaParameters,
        warnings: warnings,
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
    required String? currentFunction,
    required Set<String> availableParameters,
    required Set<String> usedParameters,
    required Set<String> letBindingNames,
    required Set<String> lambdaParameterNames,
    required Set<String> usedLambdaParameters,
    required Map<String, FunctionSignature> allSignatures,
  }) {
    final String functionName = callee.value;

    if (availableParameters.contains(functionName)) {
      final bool isLetBinding = letBindingNames.contains(functionName);
      final bool isLambdaParameter = lambdaParameterNames.contains(
        functionName,
      );

      // Track usage for function parameters and lambda parameters
      if (isLambdaParameter) {
        usedLambdaParameters.add(functionName);
      } else if (!isLetBinding) {
        usedParameters.add(functionName);
      }

      return SemanticBoundVariableNode(
        location: callee.location,
        name: functionName,
        isLetBinding: isLetBinding,
        isLambdaParameter: isLambdaParameter,
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

  SemanticNode _checkLetExpression({
    required LetExpression expression,
    required String? currentFunction,
    required Set<String> availableParameters,
    required Set<String> usedParameters,
    required Set<String> letBindingNames,
    required Set<String> lambdaParameterNames,
    required Set<String> usedLambdaParameters,
    required List<GenericWarning> warnings,
    required Map<String, FunctionSignature> allSignatures,
  }) {
    // Save the original outer scope for shadowing checks. This is the scope
    // BEFORE any names from this let are added. This ensures that
    // `let x = 1, x = 2 in x` correctly throws DuplicatedLetBindingError
    // (not ShadowedLetBindingError).
    final Set<String> originalOuterScope = Set<String>.of(availableParameters);

    // Create working copies to avoid polluting outer scope when we return.
    // This ensures `let x = 1 in (let y = 2 in y) + y` correctly errors on
    // the final `y` (which is outside the inner let's scope).
    // Note: usedParameters is NOT copied because parameter usage tracking
    // must persist across all scopes within a function.
    final Set<String> scopedAvailableParameters = Set<String>.of(
      availableParameters,
    );
    final Set<String> scopedLetBindingNames = Set<String>.of(letBindingNames);

    // Create local tracking set for this let's bindings (duplicate detection)
    final Set<String> localLetBindings = {};

    // Process each binding
    final List<SemanticLetBindingNode> checkedBindings = [];
    for (final LetBindingExpression binding in expression.bindings) {
      final String name = binding.name;

      // Check for duplicate within this let FIRST
      // This ensures `let x = 1, x = 2 in x` throws DuplicatedLetBindingError
      if (localLetBindings.contains(name)) {
        throw DuplicatedLetBindingError(
          binding: name,
          inFunction: currentFunction,
        );
      }

      // Check for shadowing against the ORIGINAL outer scope (not including
      // names added by earlier bindings in this let)
      if (originalOuterScope.contains(name)) {
        throw ShadowedLetBindingError(
          binding: name,
          inFunction: currentFunction,
        );
      }

      // Check the binding's value expression (before adding name to scope)
      final SemanticNode checkedValue = checkExpression(
        expression: binding.value,
        currentFunction: currentFunction,
        availableParameters: scopedAvailableParameters,
        usedParameters: usedParameters,
        letBindingNames: scopedLetBindingNames,
        lambdaParameterNames: lambdaParameterNames,
        usedLambdaParameters: usedLambdaParameters,
        warnings: warnings,
        allSignatures: allSignatures,
      );

      // Add to tracking sets for subsequent bindings
      localLetBindings.add(name);
      scopedAvailableParameters.add(name);
      scopedLetBindingNames.add(name);

      checkedBindings.add(
        SemanticLetBindingNode(
          name: name,
          value: checkedValue,
          location: binding.location,
        ),
      );
    }

    // Check the body with extended scope
    final SemanticNode checkedBody = checkExpression(
      expression: expression.body,
      currentFunction: currentFunction,
      availableParameters: scopedAvailableParameters,
      usedParameters: usedParameters,
      letBindingNames: scopedLetBindingNames,
      lambdaParameterNames: lambdaParameterNames,
      usedLambdaParameters: usedLambdaParameters,
      warnings: warnings,
      allSignatures: allSignatures,
    );

    // When this method returns, the scoped sets are discarded, so the outer
    // scope's availableParameters and letBindingNames remain unchanged.

    return SemanticLetNode(
      bindings: checkedBindings,
      body: checkedBody,
      location: expression.location,
    );
  }

  SemanticNode _checkLambdaExpression({
    required LambdaExpression expression,
    required String? currentFunction,
    required Set<String> availableParameters,
    required Set<String> usedParameters,
    required Set<String> letBindingNames,
    required Set<String> lambdaParameterNames,
    required Set<String> usedLambdaParameters,
    required List<GenericWarning> warnings,
    required Map<String, FunctionSignature> allSignatures,
  }) {
    // Track parameters for this lambda (duplicate detection)
    final Set<String> localLambdaParameters = {};

    // Check each parameter
    final List<String> checkedParameters = [];
    for (final String parameterName in expression.parameters) {
      // Check for duplicate within this lambda
      if (localLambdaParameters.contains(parameterName)) {
        throw DuplicatedLambdaParameterError(
          parameter: parameterName,
          inFunction: currentFunction,
        );
      }

      // Check for shadowing against outer scope
      if (availableParameters.contains(parameterName)) {
        throw ShadowedLambdaParameterError(
          parameter: parameterName,
          inFunction: currentFunction,
        );
      }

      localLambdaParameters.add(parameterName);
      checkedParameters.add(parameterName);
    }

    // Extend scope with lambda parameters
    final Set<String> extendedAvailableParameters = {
      ...availableParameters,
      ...localLambdaParameters,
    };
    final Set<String> extendedLambdaParameterNames = {
      ...lambdaParameterNames,
      ...localLambdaParameters,
    };

    // Check body with extended scope.
    // Note: usedLambdaParameters is NOT copied because lambda parameter usage
    // tracking must persist across nested lambdas. This mirrors how usedParameters
    // works for function parameters (see _checkLetExpression comment).
    final SemanticNode checkedBody = checkExpression(
      expression: expression.body,
      currentFunction: currentFunction,
      availableParameters: extendedAvailableParameters,
      usedParameters: usedParameters,
      letBindingNames: letBindingNames,
      lambdaParameterNames: extendedLambdaParameterNames,
      usedLambdaParameters: usedLambdaParameters,
      warnings: warnings,
      allSignatures: allSignatures,
    );

    // Warn about unused lambda parameters (only THIS lambda's parameters).
    // The shared usedLambdaParameters set contains all used lambda params
    // from this and nested scopes, so outer params used in inner lambdas
    // are correctly marked as used.
    for (final String parameterName in localLambdaParameters) {
      if (!usedLambdaParameters.contains(parameterName)) {
        warnings.add(
          UnusedLambdaParameterWarning(
            parameter: parameterName,
            inFunction: currentFunction,
          ),
        );
      }
    }

    return SemanticLambdaNode(
      parameters: checkedParameters,
      body: checkedBody,
      location: expression.location,
    );
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
