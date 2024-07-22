import 'package:dry/compiler/errors/generic_error.dart';
import 'package:dry/compiler/syntactic/function_definition.dart';

class SemanticError extends GenericError {
  const SemanticError(super.message);

  factory SemanticError.duplicatedFunction({
    required FunctionDefinition function1,
    required FunctionDefinition function2,
  }) =>
      SemanticError(
          'Duplicated function "${function1.name}" with paramters (${function1.parameters.join(', ')}) and (${function2.parameters.join(', ')})');

  factory SemanticError.duplicatedParameter({
    required String function,
    required String parameter,
  }) =>
      SemanticError(
          'Duplicated parameter "$parameter" in function "$function"');
}
