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

class CannotRedefineStandardLibraryError extends SemanticError {
  const CannotRedefineStandardLibraryError({
    required String function,
  }) : super('Cannot redefine standard library function "$function"');
}

class CannotDeleteStandardLibraryError extends SemanticError {
  const CannotDeleteStandardLibraryError({
    required String function,
  }) : super('Cannot delete standard library function "$function"');
}

class FunctionNotFoundError extends SemanticError {
  const FunctionNotFoundError({
    required String function,
  }) : super('Function "$function" not found');
}

class CannotRenameStandardLibraryError extends SemanticError {
  const CannotRenameStandardLibraryError({
    required String function,
  }) : super('Cannot rename standard library function "$function"');
}

class FunctionAlreadyExistsError extends SemanticError {
  const FunctionAlreadyExistsError({
    required String function,
  }) : super('Function "$function" already exists');
}

class ShadowedLetBindingError extends SemanticError {
  const ShadowedLetBindingError({
    required String binding,
    String? inFunction,
  }) : super(
         inFunction != null
             ? 'Shadowed let binding "$binding" in function "$inFunction"'
             : 'Shadowed let binding "$binding"',
       );
}

class DuplicatedLetBindingError extends SemanticError {
  const DuplicatedLetBindingError({
    required String binding,
    String? inFunction,
  }) : super(
         inFunction != null
             ? 'Duplicated let binding "$binding" in function "$inFunction"'
             : 'Duplicated let binding "$binding"',
       );
}
