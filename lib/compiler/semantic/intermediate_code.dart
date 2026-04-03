import 'package:primal/compiler/library/standard_library.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/semantic/semantic_function.dart';
import 'package:primal/compiler/warnings/generic_warning.dart';
import 'package:primal/utils/mapper.dart';

/// The output of semantic analysis.
///
/// Contains user-defined functions as [SemanticFunction] (with source locations
/// and resolved references) and the standard library as [FunctionNode] (native
/// implementations).
class IntermediateCode {
  final Map<String, SemanticFunction> customFunctions;
  final Map<String, FunctionNode> standardLibrary;
  final List<GenericWarning> warnings;

  IntermediateCode({
    required this.customFunctions,
    required this.standardLibrary,
    required this.warnings,
  });

  factory IntermediateCode.empty() => IntermediateCode(
    customFunctions: {},
    standardLibrary: Mapper.toMap(StandardLibrary.get()),
    warnings: [],
  );

  /// Returns all function names (custom + standard library).
  Set<String> get allFunctionNames => {
    ...customFunctions.keys,
    ...standardLibrary.keys,
  };

  /// Checks if a function with the given name exists.
  bool containsFunction(String name) =>
      customFunctions.containsKey(name) || standardLibrary.containsKey(name);

  /// Returns the standard library function with the given name, or null.
  FunctionNode? getStandardLibraryFunction(String name) =>
      standardLibrary[name];

  /// Returns the custom function with the given name, or null.
  SemanticFunction? getCustomFunction(String name) => customFunctions[name];
}
