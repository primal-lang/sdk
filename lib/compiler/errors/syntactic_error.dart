import 'package:primal/compiler/errors/generic_error.dart';
import 'package:primal/compiler/lexical/token.dart';
import 'package:primal/compiler/syntactic/syntactic_analyzer.dart';

class SyntacticError extends GenericError {
  const SyntacticError(super.message);
}

class InvalidTokenError extends SyntacticError {
  const InvalidTokenError(Token token) : super('Invalid token $token');
}

class InvalidStackElementError extends SyntacticError {
  InvalidStackElementError(StackElement element)
      : super('Expression malfored at ${element.location}');
}

class UnexpectedEndOfFileError extends SyntacticError {
  const UnexpectedEndOfFileError() : super('Unexpected end of file');
}
