import 'package:dry/compiler/errors/generic_error.dart';
import 'package:dry/compiler/models/location.dart';
import 'package:dry/compiler/semantic/function_prototype.dart';

class SemanticError extends GenericError {
  const SemanticError(super.message);

  factory SemanticError.duplicatedFunction({
    required FunctionPrototype function1,
    required FunctionPrototype function2,
  }) =>
      SemanticError(
          'Duplicated function "${function1.name}" with paramters (${function1.parameters.join(', ')}) and (${function2.parameters.join(', ')})');

  factory SemanticError.duplicatedParameter({
    required String function,
    required String parameter,
  }) =>
      SemanticError(
          'Duplicated parameter "$parameter" in function "$function"');

  factory SemanticError.unusedParameter({
    required String function,
    required String parameter,
  }) =>
      SemanticError('Unused parameter "$parameter" in function "$function"');

  factory SemanticError.undefinedSymbol({
    required String symbol,
    required Location location,
  }) =>
      SemanticError('Undefined symbol "$symbol" at $location');

  factory SemanticError.undefinedFunction({
    required String function,
    required Location location,
  }) =>
      SemanticError('Undefined function "$function" at $location');

  factory SemanticError.invalidNumberOfArguments({
    required String function,
    required Location location,
  }) =>
      SemanticError('Invalid number of arguments calling function "$function" at $location');
}
