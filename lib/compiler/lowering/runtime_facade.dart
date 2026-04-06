import 'package:primal/compiler/errors/semantic_error.dart';
import 'package:primal/compiler/lowering/lowerer.dart';
import 'package:primal/compiler/lowering/runtime_input_builder.dart';
import 'package:primal/compiler/models/function_signature.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:primal/compiler/runtime/runtime_input.dart';
import 'package:primal/compiler/runtime/term.dart';
import 'package:primal/compiler/semantic/intermediate_representation.dart';
import 'package:primal/compiler/semantic/semantic_analyzer.dart';
import 'package:primal/compiler/semantic/semantic_function.dart';
import 'package:primal/compiler/semantic/semantic_node.dart';
import 'package:primal/compiler/syntactic/expression.dart';
import 'package:primal/compiler/syntactic/function_definition.dart';

/// Parses a string into an [Expression].
typedef ExpressionParser = Expression Function(String input);

class RuntimeFacade {
  final IntermediateRepresentation intermediateRepresentation;
  final ExpressionParser _parseExpression;
  final RuntimeInput _runtimeInput;
  final Runtime _runtime;
  final Map<String, FunctionSignature> _allSignatures;
  final Set<String> _userDefinedFunctions;

  RuntimeFacade._internal(
    this.intermediateRepresentation,
    this._parseExpression,
    this._runtimeInput,
    this._allSignatures,
    this._userDefinedFunctions,
  ) : _runtime = Runtime(_runtimeInput);

  factory RuntimeFacade(
    IntermediateRepresentation intermediateRepresentation,
    ExpressionParser parseExpression,
  ) {
    final RuntimeInput input = const RuntimeInputBuilder().build(
      intermediateRepresentation,
    );

    // Build combined signature map for expression validation
    final Map<String, FunctionSignature> allSignatures = {
      ...intermediateRepresentation.standardLibrarySignatures,
      for (final SemanticFunction function
          in intermediateRepresentation.customFunctions.values)
        function.name: FunctionSignature(
          name: function.name,
          parameters: function.parameters,
        ),
    };

    // Track user-defined functions (from file and REPL)
    final Set<String> userDefinedFunctions = {
      ...intermediateRepresentation.customFunctions.keys,
    };

    return RuntimeFacade._internal(
      intermediateRepresentation,
      parseExpression,
      input,
      allSignatures,
      userDefinedFunctions,
    );
  }

  bool get hasMain => intermediateRepresentation.containsFunction('main');

  /// Returns the signatures of all user-defined functions.
  List<String> get userDefinedFunctionSignatures {
    final List<String> signatures = _userDefinedFunctions
        .map((String name) => _allSignatures[name]!.toString())
        .toList();
    signatures.sort();
    return signatures;
  }

  /// Clears all user-defined functions from the runtime.
  void reset() {
    for (final String name in _userDefinedFunctions) {
      _runtimeInput.functions.remove(name);
      _allSignatures.remove(name);
    }
    _userDefinedFunctions.clear();
  }

  /// Loads functions from an [IntermediateRepresentation].
  ///
  /// This clears all existing user-defined functions first, then loads
  /// all custom functions from the provided IR.
  ///
  /// Returns the number of functions loaded.
  int loadFromIntermediateRepresentation(
    IntermediateRepresentation representation,
  ) {
    reset();

    final Lowerer lowerer = Lowerer(_runtimeInput.functions);

    for (final SemanticFunction function
        in representation.customFunctions.values) {
      // Add signature
      final FunctionSignature signature = FunctionSignature(
        name: function.name,
        parameters: function.parameters,
      );
      _allSignatures[function.name] = signature;

      // Lower and add function term
      final CustomFunctionTerm functionTerm = lowerer.lowerFunction(function);
      _runtimeInput.functions[function.name] = functionTerm;

      // Track as user-defined
      _userDefinedFunctions.add(function.name);
    }

    return representation.customFunctions.length;
  }

  /// Deletes a user-defined function by name.
  ///
  /// Throws [FunctionNotFoundError] if the function doesn't exist.
  /// Throws [CannotDeleteStandardLibraryError] if trying to delete
  /// a standard library function.
  void deleteFunction(String name) {
    if (intermediateRepresentation.standardLibrarySignatures.containsKey(
      name,
    )) {
      throw CannotDeleteStandardLibraryError(function: name);
    }

    if (!_userDefinedFunctions.contains(name)) {
      throw FunctionNotFoundError(function: name);
    }

    _userDefinedFunctions.remove(name);
    _runtimeInput.functions.remove(name);
    _allSignatures.remove(name);
  }

  /// Renames a user-defined function.
  ///
  /// Throws [FunctionNotFoundError] if [oldName] doesn't exist.
  /// Throws [CannotRenameStandardLibraryError] if [oldName] is a standard
  /// library function.
  /// Throws [FunctionAlreadyExistsError] if [newName] is already in use.
  ///
  /// Note: This does not update references to the old function in other
  /// user-defined functions. Those will fail at runtime.
  void renameFunction(String oldName, String newName) {
    // Validate old name
    if (intermediateRepresentation.standardLibrarySignatures.containsKey(
      oldName,
    )) {
      throw CannotRenameStandardLibraryError(function: oldName);
    }

    if (!_userDefinedFunctions.contains(oldName)) {
      throw FunctionNotFoundError(function: oldName);
    }

    // Validate new name
    if (_allSignatures.containsKey(newName)) {
      throw FunctionAlreadyExistsError(function: newName);
    }

    // Get existing function and signature
    final FunctionTerm functionTerm = _runtimeInput.functions[oldName]!;
    final FunctionSignature oldSignature = _allSignatures[oldName]!;

    // Create new signature with updated name
    final FunctionSignature newSignature = FunctionSignature(
      name: newName,
      parameters: oldSignature.parameters,
    );

    // Remove old entries
    _userDefinedFunctions.remove(oldName);
    _runtimeInput.functions.remove(oldName);
    _allSignatures.remove(oldName);

    // Add new entries
    _userDefinedFunctions.add(newName);
    _runtimeInput.functions[newName] = functionTerm;
    _allSignatures[newName] = newSignature;
  }

  Expression mainExpression(List<String> arguments) {
    final FunctionTerm? main = _runtimeInput.getFunction('main');

    if ((main != null) && main.parameters.isNotEmpty) {
      final String escapedArgs = arguments
          .map(
            (String e) =>
                '"${e.replaceAll('\\', '\\\\').replaceAll('"', '\\"')}"',
          )
          .join(', ');
      return _parseExpression('main($escapedArgs)');
    } else {
      return _parseExpression('main()');
    }
  }

  String executeMain([List<String>? arguments]) {
    final Expression expression = mainExpression(arguments ?? []);

    return evaluate(expression);
  }

  String evaluate(Expression expression) {
    final Term result = evaluateToTerm(expression);
    return _runtime.format(result.native()).toString();
  }

  /// Evaluates an expression and returns the runtime term.
  ///
  /// Used by tests that need to inspect the term type.
  Term evaluateToTerm(Expression expression) {
    // Reset recursion depth at the start to clear any stale state from
    // previous failed evaluations.
    FunctionTerm.resetDepth();

    const SemanticAnalyzer analyzer = SemanticAnalyzer([]);
    final Lowerer lowerer = Lowerer(_runtimeInput.functions);

    // Proper pipeline: Expression → SemanticNode → Term → evaluate
    final SemanticNode semanticNode = analyzer.checkExpression(
      expression: expression,
      currentFunction: null,
      availableParameters: {},
      usedParameters: {},
      allSignatures: _allSignatures,
    );

    final Term lowered = lowerer.lowerTerm(semanticNode);
    return lowered.reduce();
  }

  dynamic format(dynamic value) => _runtime.format(value);

  /// Defines a new function in the runtime.
  ///
  /// This allows REPL users to define functions on the fly.
  /// User-defined functions can be redefined, but standard library
  /// functions cannot be overwritten.
  ///
  /// Throws [CannotRedefineStandardLibraryError] if trying to redefine
  /// a standard library function.
  void defineFunction(FunctionDefinition definition) {
    final String name = definition.name;

    // Check if trying to redefine a standard library function
    if (intermediateRepresentation.standardLibrarySignatures.containsKey(
          name,
        ) &&
        !_userDefinedFunctions.contains(name)) {
      throw CannotRedefineStandardLibraryError(function: name);
    }

    // Build signature and parameters
    final List<Parameter> parameters = definition.parameters
        .map(Parameter.any)
        .toList();
    final FunctionSignature signature = FunctionSignature(
      name: name,
      parameters: parameters,
    );

    // Check for duplicate parameters
    _checkDuplicateParameters(name, definition.parameters);

    // Add the signature to _allSignatures before semantic analysis so that
    // recursive calls can resolve the function's own signature.
    final FunctionSignature? previousSignature = _allSignatures[name];
    _allSignatures[name] = signature;

    // Perform semantic analysis on the function body
    SemanticNode body;
    try {
      const SemanticAnalyzer analyzer = SemanticAnalyzer([]);
      final Set<String> usedParameters = {};
      body = analyzer.checkExpression(
        expression: definition.expression,
        currentFunction: name,
        availableParameters: definition.parameters.toSet(),
        usedParameters: usedParameters,
        allSignatures: _allSignatures,
      );
    } catch (error) {
      // Restore previous signature on failure
      if (previousSignature != null) {
        _allSignatures[name] = previousSignature;
      } else {
        _allSignatures.remove(name);
      }
      rethrow;
    }

    // Create semantic function
    final SemanticFunction semanticFunction = SemanticFunction(
      name: name,
      parameters: parameters,
      body: body,
      location: definition.expression.location,
    );

    // Lower to runtime term
    final Lowerer lowerer = Lowerer(_runtimeInput.functions);
    final CustomFunctionTerm functionTerm = lowerer.lowerFunction(
      semanticFunction,
    );

    // Update runtime state (signature was already added before semantic analysis)
    _runtimeInput.functions[name] = functionTerm;
    _userDefinedFunctions.add(name);
  }

  void _checkDuplicateParameters(String functionName, List<String> parameters) {
    final Set<String> seen = {};
    for (final String parameter in parameters) {
      if (seen.contains(parameter)) {
        throw DuplicatedParameterError(
          function: functionName,
          parameter: parameter,
          parameters: parameters,
        );
      }
      seen.add(parameter);
    }
  }
}
