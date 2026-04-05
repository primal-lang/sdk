import 'package:primal/compiler/library/standard_library.dart';
import 'package:primal/compiler/models/function_signature.dart';
import 'package:primal/compiler/semantic/semantic_function.dart';
import 'package:primal/compiler/warnings/generic_warning.dart';

/// The output of semantic analysis.
///
/// Contains user-defined functions as [SemanticFunction] (with source locations
/// and resolved references) and standard library signatures for validation.
/// Runtime nodes are obtained separately during the lowering phase.
class IntermediateRepresentation {
  final Map<String, SemanticFunction> customFunctions;
  final Map<String, FunctionSignature> standardLibrarySignatures;
  final List<GenericWarning> warnings;

  IntermediateRepresentation({
    required this.customFunctions,
    required this.standardLibrarySignatures,
    required this.warnings,
  });

  factory IntermediateRepresentation.empty() => IntermediateRepresentation(
    customFunctions: {},
    standardLibrarySignatures: {
      for (final FunctionSignature sig in StandardLibrary.getSignatures())
        sig.name: sig,
    },
    warnings: [],
  );

  /// Returns all function names (custom + standard library).
  Set<String> get allFunctionNames => {
    ...customFunctions.keys,
    ...standardLibrarySignatures.keys,
  };

  /// Checks if a function with the given name exists.
  bool containsFunction(String name) =>
      customFunctions.containsKey(name) ||
      standardLibrarySignatures.containsKey(name);

  /// Returns the standard library signature with the given name, or null.
  FunctionSignature? getStandardLibrarySignature(String name) =>
      standardLibrarySignatures[name];

  /// Returns the custom function with the given name, or null.
  SemanticFunction? getCustomFunction(String name) => customFunctions[name];
}
