import 'package:primal/compiler/errors/generic_error.dart';
import 'package:primal/compiler/models/function_signature.dart';

class SemanticError extends CompilationError {
  const SemanticError(super.message);
}

class DuplicatedFunctionError extends SemanticError {
  DuplicatedFunctionError({
    required FunctionSignature function1,
    required FunctionSignature function2,
  }) : super(
         'Duplicated function "${function1.name}" with parameters (${function1.parameters.map((p) => p.name).join(', ')}) and (${function2.parameters.map((p) => p.name).join(', ')})',
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
  UndefinedIdentifierError({
    required String identifier,
    String? inFunction,
  }) : super(
         inFunction != null
             ? 'Undefined identifier "$identifier" in function "$inFunction"'
             : 'Undefined identifier "$identifier"',
       );
}

class UndefinedFunctionError extends SemanticError {
  UndefinedFunctionError({
    required String function,
    String? inFunction,
  }) : super(
         inFunction != null
             ? 'Undefined function "$function" in function "$inFunction"'
             : 'Undefined function "$function"',
       );
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
