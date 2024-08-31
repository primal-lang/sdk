import 'package:primal/compiler/errors/generic_error.dart';
import 'package:primal/compiler/lexical/token.dart';

class SyntacticError extends GenericError {
  const SyntacticError(super.message);
}

class InvalidTokenError extends SyntacticError {
  const InvalidTokenError(Token token, [String? expected])
      : super(
            'Invalid token $token${(expected != null) ? '. Expected: $expected' : ''}');
}

class ExpectedTokenError extends SyntacticError {
  const ExpectedTokenError(Token token, String expected)
      : super('Invalid token $token. Expected: $expected');
}

class UnexpectedEndOfFileError extends SyntacticError {
  const UnexpectedEndOfFileError() : super('Unexpected end of file');
}
