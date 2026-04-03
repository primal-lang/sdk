import 'package:primal/compiler/errors/generic_error.dart';
import 'package:primal/compiler/runtime/node.dart';

class SemanticError extends CompilationError {
  const SemanticError(super.message);
}

class DuplicatedFunctionError extends SemanticError {
  DuplicatedFunctionError({
    required FunctionNode function1,
    required FunctionNode function2,
  }) : super(
         'Duplicated function "${function1.name}" with parameters (${function1.parameters.join(', ')}) and (${function2.parameters.join(', ')})',
       );
}

class DuplicatedParameterError extends SemanticError {
  DuplicatedParameterError({
    required String function,
    required String parameter,
    required List<String> parameters,
  }) : super(
         'Duplicated parameter "$parameter" in function "$function(${parameters.join(', ')})"',
       );
}

class UndefinedIdentifierError extends SemanticError {
  const UndefinedIdentifierError({
    required String identifier,
    required String inFunction,
  }) : super('Undefined identifier "$identifier" in function "$inFunction"');
}

class UndefinedFunctionError extends SemanticError {
  const UndefinedFunctionError({
    required String function,
    required String inFunction,
  }) : super('Undefined function "$function" in function "$inFunction"');
}

class InvalidNumberOfArgumentsError extends SemanticError {
  const InvalidNumberOfArgumentsError({
    required String function,
    required int expected,
    required int actual,
  }) : super(
         'Invalid number of arguments calling function "$function": '
         'expected $expected, got $actual',
       );
}

class NotCallableError extends SemanticError {
  const NotCallableError({
    required String value,
    required String type,
  }) : super('Cannot call $type literal "$value"');
}

class NotIndexableError extends SemanticError {
  const NotIndexableError({
    required String value,
    required String type,
  }) : super('Cannot index $type literal "$value"');
}
