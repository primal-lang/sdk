import 'package:primal/compiler/errors/generic_error.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class SemanticError extends CompilationError {
  const SemanticError(super.message);
}

class DuplicatedFunctionError extends SemanticError {
  DuplicatedFunctionError({
    required FunctionPrototype function1,
    required FunctionPrototype function2,
  }) : super(
            'Duplicated function "${function1.name}" with parameters (${function1.parameters.join(', ')}) and (${function2.parameters.join(', ')})');
}

class DuplicatedParameterError extends SemanticError {
  DuplicatedParameterError({
    required String function,
    required String parameter,
    required List<String> parameters,
  }) : super(
            'Duplicated parameter "$parameter" in function "$function(${parameters.join(', ')})"');
}

class UndefinedIdentifierError extends SemanticError {
  const UndefinedIdentifierError(String identifier)
      : super('Undefined identifier "$identifier"');
}

class UndefinedFunctionError extends SemanticError {
  const UndefinedFunctionError(String function)
      : super('Undefined function "$function"');
}

class InvalidNumberOfArgumentsError extends SemanticError {
  const InvalidNumberOfArgumentsError(String function)
      : super('Invalid number of arguments calling function "$function"');
}
