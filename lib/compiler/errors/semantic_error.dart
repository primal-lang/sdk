import 'package:primal/compiler/errors/generic_error.dart';
import 'package:primal/compiler/models/location.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class SemanticError extends GenericError {
  const SemanticError(super.message);
}

class DuplicatedFunctionError extends SemanticError {
  DuplicatedFunctionError({
    required FunctionPrototype function1,
    required FunctionPrototype function2,
  }) : super(
            'Duplicated function "${function1.name}" with paramters (${function1.parameters.join(', ')}) and (${function2.parameters.join(', ')})');
}

class DuplicatedParameterError extends SemanticError {
  DuplicatedParameterError({
    required String function,
    required String parameter,
    required List<String> parameters,
  }) : super(
            'Duplicated parameter "$parameter" in function "$function(${parameters.join(', ')})"');
}

class UndefinedIdentifiersError extends SemanticError {
  const UndefinedIdentifiersError({
    required String identifier,
    required Location location,
  }) : super('Undefined identifier "$identifier" at $location');
}

class UndefinedFunctionError extends GenericError {
  const UndefinedFunctionError({
    required String function,
    required Location location,
  }) : super('Undefined function "$function" at $location');
}

class InvalidNumberOfArgumentsError extends GenericError {
  const InvalidNumberOfArgumentsError({
    required String function,
    required Location location,
  }) : super(
            'Invalid number of arguments calling function "$function" at $location');
}
