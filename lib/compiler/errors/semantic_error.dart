import 'package:dry/compiler/errors/generic_error.dart';

class SemanticError extends GenericError {
  const SemanticError(super.message);

  factory SemanticError.repeatedParameter(String function, String parameter) =>
      SemanticError('Repeated parameter "$parameter" in function "$function"');
}
